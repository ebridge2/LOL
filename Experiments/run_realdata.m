function [T,S,P,task] = run_realdata(rootDir)


%% task properties consistent across all tasks
task.algs={'LOL';'GLM';'RF';'ROAD';'SVM'}; %add svm
task.simulation=0;
task.percent_unlabeled=0;
task.types={'DENL'};
task.ntrials=40;
task.savestuff=1;

%% prostate

j=1;
task1=task;
task1.name=['Prostate'];
task1.ks=1:50;
task1.ks=unique(round(logspace(0,log10(67),50)));
[T{j},S{j},P{j}] = run_task(task1);

%% prostate

j=2;
task1=task;
task1.name=['Colon'];
task1.ks=unique(round(logspace(0,log10(40),50)));
[T{j},S{j},P{j}] = run_task(task1);


%% mnist

j=3;
task1=task;
task1.name=['MNIST'];
task1.ntrain=100;
task1.ntest=500;
task1.algs={'LOL';'GLM';'RF';'SVM'}; 
task1.ks=unique(round(logspace(0,log10(task1.ntrain-1),50)));
[T{j},S{j},P{j}] = run_task(task1);


%% CIFAR-10
j=4;
task1=task;
task1.name=['CIFAR-10'];
task1.ntrain=300;
task1.ntest=500;
task1.algs={'LOL';'GLM';'RF';'SVM'}; 
task1.ks=unique(round(logspace(0,log10(task1.ntrain-1),50)));
[T{j},S{j},P{j}] = run_task(task1);



%% save stuff

if task.savestuff
    save([rootDir, '../Data/Results/realdata.mat'],'task','T','S','P')
end