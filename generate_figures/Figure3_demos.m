% profile on
clearvars, clc, updatepath

task_list_name='toeplitzs';
switch task_list_name
    case 'Mai13'
        task.ks=unique(round(logspace(0,2,50)));
        task.Ntrials=500;
        task.algs={'naivebayes','PDA','SLOL','LOL','DRDA','RDA','treebagger','svm'};
        task.savestuff=1;
    case 'thin'
        task.ks=unique(round(logspace(0,2,50)));
        task.Ntrials=10;
        task.algs={'naivebayes','LDA','PDA','SLOL','LOL','DRDA','RDA','treebagger','svm'};
        task.savestuff=1;
    case 'sa'
        task.ks=unique(round(logspace(0,2,50)));
        task.Ntrials=10;
        task.algs={'naivebayes','treebagger','LOL'};
        task.savestuff=1;
    case 'toeplitzs'
        task.ks=unique(round(logspace(0,2,50)));
        task.Ntrials=20;
        task.algs={'naivebayes','LDA','PDA','SLOL','LOL','DRDA','RDA','treebagger','svm'};
        task.savestuff=1;
    case 'all_cigars'
        task.ks=unique(round(logspace(0,2,50)));
        task.Ntrials=100;
        task.algs={'PDA','SLOL','LOL','DRDA'};
        task.savestuff=1;
    otherwise
        task.name=task_list_name;
        task.Ntrials=5;
        task.algs={'naivebayes','LDA','LOL'};
        task.savestuff=1;
        task.ks=unique(round(logspace(0,2,50)));
end

[T,P,S] = run_benchmarks(task_list_name,task);
Figure_benchmarks(task_list_name)

% profile viewer
