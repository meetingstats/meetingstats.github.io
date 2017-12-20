clearvars;
global names order
names = {'Itay','Hannah','Xiaolei','Grace'};


order = randperm(length(names));

% order = randperm(length(names)-2);
% order = [order+2 2 1];

for m=1:length(order)
    disp([num2str(m) '. ' names{order(m)}]);
end