clearvars, clc,

metatask='amen dementia';
[T,S,P] = run_task_list(metatask); 

F.ylim=[0 0.5];
plot_benchmarks(metatask,F)

