function sg_clock()
global currname totaltimes startt names order nstories storytimes storyname cstorystart

currname = 1;
totaltimes = zeros(size(names),'double');
ta = datevec(now);
startt = ta(4:6);

nstories = 0;
storytimes = 0;
cstorystart = 0;
storyname{1} = '';

fh = figure('Name','Subgroup Clock','NumberTitle','off','MenuBar','none','ToolBar','none');
set(gcf,'Position',[50 50 300 200],'Resize','off');

nh = uicontrol('Style','text','String',names{order(1)},'Position',[5 170 90 25], ...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','left','BackgroundColor','w');

tch = uicontrol('Style','text','String',[num2str(0,'%02d') ':' num2str(0,'%02d') ':' num2str(0,'%02d')],'Position',[100 170 90 25], ...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','center','BackgroundColor','y');

th = uicontrol('Style','text','String',[num2str(0,'%02d') ':' num2str(0,'%02d') ':' num2str(0,'%02d')],'Position',[195 170 90 25], ...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','center','BackgroundColor','c');

norbsth = uicontrol('Style','text','String',[num2str(0) ' - ' num2str(0,'%02d') ':' num2str(0,'%02d') ':' num2str(0,'%02d')],'Position',[175 140 110 25], ...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','center','BackgroundColor','g');

for m=1:length(names)
   inh(m) =  uicontrol('Style','text','String',[num2str(m) '. ' names{order(m)}],'Position',[5, 140-20*(m-1), 90, 20], ...
    'FontSize',10,'HorizontalAlignment','left');
   ith(m) =  uicontrol('Style','text','String','00:00:00','Position',[100, 140-20*(m-1), 70, 20], ...
    'FontSize',10,'HorizontalAlignment','left');
end

set(inh(1),'FontWeight','bold');
set(ith(1),'FontWeight','bold');

uicontrol('Style','pushbutton','String','Next','Position',[180 75 95 50],'FontSize',14,...
    'Callback',{@NextCallback,nh,inh,fh,ith});

uicontrol('Style','togglebutton','String','Story Time','Position',[180 20 95 50],'FontSize',10,...
    'Callback',@StoryTimeCallback,'Value',0);


drawnow;
tic 

timeh = timer('ExecutionMode','fixedRate', 'Period', 1, 'TimerFcn', {@RunLoop,fh,th,tch,norbsth});
start(timeh);

set(fh,'CloseRequestFcn',{@sg_shutdown,timeh});


end

function RunLoop(~,~,fh,th,tch,norbsth)
global totaltimes nstories storytimes storyname cstorystart
if ishghandle(fh)
    time = toc;
    hr = floor(time/3600);
    mins = floor((time-3600*hr)/60);
    sec = floor(time-hr*3600-mins*60);
    set(th,'String',[num2str(hr,'%02d') ':' num2str(mins,'%02d') ':' num2str(sec,'%02d')]);
    
    
    time = time - sum(totaltimes);
    hr = floor(time/3600);
    mins = floor((time-3600*hr)/60);
    sec = floor(time-hr*3600-mins*60);
    
    set(tch,'String',[num2str(hr,'%02d') ':' num2str(mins,'%02d') ':' num2str(sec,'%02d')]);
    
    time = sum(storytimes);
    if cstorystart > 0 %if there is a story currently running compute the additional time so far
        time = time + (toc - cstorystart);
    end
    hr = floor(time/3600);
    mins = floor((time-3600*hr)/60);
    sec = floor(time-hr*3600-mins*60);
    
    set(norbsth,'String',[num2str(nstories) ' - ' num2str(hr,'%02d') ':' num2str(mins,'%02d') ':' num2str(sec,'%02d')]);
    
    drawnow;
end

end

function StoryTimeCallback(src,~)
global nstories storytimes storyname cstorystart currname names order
s = get(src,'Value');

if s == 0 %turn off
    set(src,'FontWeight','normal');
    storytimes(nstories) = toc - cstorystart;
    cstorystart = 0;
else %turn on
    set(src,'FontWeight','bold');
    nstories = nstories + 1;
    storytimes(nstories) = 0;
    storyname{nstories} = names{order(currname)};
    cstorystart = toc;
end

end

function NextCallback(~,~,nh,inh,fh,ith)
global currname totaltimes startt names order nstories storytimes storyname cstorystart

totaltimes(currname) = toc - sum(totaltimes);

time = totaltimes(currname);
hr = floor(time/3600);
mins = floor((time-3600*hr)/60);
sec = round(time-hr*3600-mins*60);
set(ith(currname),'FontWeight','normal','String',[num2str(hr,'%02d') ':' num2str(mins,'%02d') ':' num2str(sec,'%02d')]);


if(currname == length(inh)) %end of subgroup
    
    dstr = datestr(now,'yymmdd');
    ta = datevec(now);
    endt = ta(4:6);
    if nstories > 0 %if there are stories
        if storytimes(nstories) == 0 %if the last story wasn't stopped
            storytimes(nstories) = toc - cstorystart; %record the time of the story
        end
    end
    filename = ['Subgroup Stats/' dstr '_data.mat'];
    filename2 = ['Subgroup Stats/' dstr '_data.csv'];
    filename3 = ['Subgroup Stats/' dstr '_stories.csv'];
    save(filename,'totaltimes','names','order','dstr','startt','endt','nstories','storytimes','storyname');
    nnames = length(names);
    cellt = cell(nnames,4);
    for m = 1:nnames
        cellt{m,1} = names{order(m)};
        cellt{m,2} = totaltimes(m);
        cellt{m,3} = m;
        cellt{m,4} = dstr;
    end
    T = cell2table(cellt, 'VariableNames', {'name','time','order','date'});
    writetable(T,filename2);
    if nstories > 0
        cellstor = cell(nstories,4);
        for m = 1:nstories
            cellstor{m,1} = storyname{m};
            cellstor{m,2} = storytimes(m);
            cellstor{m,3} = m;
            cellstor{m,4} = dstr;
        end
    else
        cellstor = cell(1,4);
        cellstor{1,1} = 'null';
        cellstor{1,2} = 0;
        cellstor{1,3} = 0;
        cellstor{1,4} = dstr;
    end
    Ts = cell2table(cellstor, 'VariableNames', {'name','storytime','story','date'});
    writetable(Ts,filename3);
    close(fh);
    msgbox(['Subgroup over! File saved as: ' filename2]);    
    return;
end

currname = currname+1;
set(nh,'String',names{order(currname)});
set(inh(currname),'FontWeight','bold');
set(inh(currname-1),'FontWeight','normal');

set(ith(currname),'FontWeight','bold');


end

function sg_shutdown(src,~,timeh)
if strcmp(get(timeh,'Running'), 'on')
    stop(timeh)
end
delete(timeh)
delete(src)
end