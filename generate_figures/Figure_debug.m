profile on
clearvars, clc,
run([pwd,'/../helper_fcns/updatepath.m'])

task.D=1000;
task.ntrain=50;
task.name='s';
task.ks=[50, 100];
task.algs={'LOL','PDA','LDA'};
task.Ntrials=5;

% task_list_name=task_list_names{i};
% [T,P,S] = run_task_list(task_list_name);

[T,P,S] = run_task(task);

profile viewer

F.plot_bayes=true;
plot_benchmarks(task.name,F)


