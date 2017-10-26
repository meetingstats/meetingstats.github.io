clearvars;
global names order
names = {'Matthew','Xiaolei','Itay','Hannah','Maya'};
%names = {'Hannah','Matthew','Xiaolei','Itay','Maya'};


order = randperm(length(names));
%order = [order+1 1];

for m=1:length(order)
    disp([num2str(m) '. ' names{order(m)}]);
end