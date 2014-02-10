function plot_tasks(tasks,Stats,task_list_name)
% plot results for a set of tasks
% generate a row of panels for each task
% each row has the following columns:
%   1) Lhat vs. k for each algorithm, including chance, Bayes, and Risk
%   2) Relative Lhat
%   3) Spectra and estimated spectra for data
%   4) sensitivity and specificity
% 
% INPUT:
%   tasks: a structure for each task, containing all necessary meta.data
%   Stats: a structure for each task, containing all statistics
% 
% OUTPUT: none


%% set some figure parameters
figure(1); clf
% figure('visible','off');

% LDA: gray
% chance: black
% risk: dashed red
% bayes: solid red
% PCA: pink
% LOL/SDA: green
% DRDA: blue
% SDQA: cyan

F.gray=0.5*[1 1 1];
F.colors{1}='m';
F.colors{2}='g';
F.colors{3}='b';
F.colors{4}='c';
F.colors{5}='y';
F.colors{6}='r';

F.markers{1}='o';
F.markers{2}='+';
F.markers{3}='x';
F.markers{4}='*';
F.markers{5}='v';
F.markers{6}='s';

F.Ncols=4;
F.Nrows=length(tasks);

%% make various plots
for j=1:F.Nrows

    % rename variables for task j for legibility
    T=tasks{j};
    S=Stats{j};
    
    plot_Lhat(T,S,F,j,1)                % column 1: plot Lhats
    plot_relative(T,S,F,j,2)            % column 2: plot performance vs LDA
    plot_sens_spec(T,S,F,j,1)           % column 3 & 4: sensitivity and specificity

end

%% save plots
if T.savestuff
    wh=[8 F.Nrows]*1.2;
    fname=char(strcat('performance_', task_list_name));
    print_fig(gcf,wh,fname)
end
