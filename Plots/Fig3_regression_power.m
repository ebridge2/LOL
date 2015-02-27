% this script either loads or runs a new simulation of both regression and
% power, and then plots the results.

clearvars, clc, 
fpath = mfilename('fullpath');
findex=strfind(fpath,'/');
rootDir=fpath(1:findex(end-1));
p = genpath(rootDir);
gits=strfind(p,'.git');
colons=strfind(p,':');
for i=0:length(gits)-1
    endGit=find(colons>gits(end-i),1);
    p(colons(endGit-1):colons(endGit)-1)=[];
end
addpath(p);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% regresssion %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

newsim=0;
task.save=1;
task.lasso=true;
if newsim==1;
    S = run_regression_sims(task);
else
    load([rootDir, '../Data/results/extensions'])
end
S{1}.savestuff=1;


%% plot figs
h=figure(1); clf,
height=0.3;
vspace=0.08;
bottom=0.13;
left=0.09;
width=0.4;
hspace=0.06;
b2=0.6;
pos(1)=left; pos(2)=width; pos(3)=hspace; pos(4)=bottom; pos(5)=height; 

for s=1:length(S)
    ytick=10.^[1:0.5:8];
    if s==1, ss=2; elseif s==2, ss=1; end
    %     subplot(2,length(S),ss),
    pos=[left+(ss-1)*(width+hspace), bottom, width, height]; %[left,bottom,width,height]
    subplot('position',pos)
    hold all
    col{1}='g'; col{2}='g';col{3}='m';col{4}='m';col{5}='r';col{6}='r';
    ls{1}='--'; ls{2}='-'; ls{3}='--';ls{4}='-'; ls{5}='-';
    for j=1:length(S{s}.transformers)
        plot(S{s}.ks,S{s}.mean_lol(j,:),'color',col{j},'linewidth',2,'linestyle',ls{j})
    end
    if isfield(S{s},'mean_lasso')
        plot(S{s}.mean_nlam,S{s}.mean_lasso(1:length(S{s}.mean_nlam)),'color','c','linestyle','-','linewidth',2)
    end
    plot([0 100],S{s}.mean_pls*ones(2,1),'k','linestyle','-','linewidth',2)
    T=S{s}.transformers;
    set(gca,'Yscale','linear')
    xlim([0 90])
    if s==1
        title('(B) Sparse Sphere: D=1000, n=100')
        ytick=10.^[1:0.05:8];
        set(gca,'Ylim',[0.28*10^5,0.4*10^5],'Ytick',ytick,'YTickLabel',log10(ytick)/0.5)
    elseif s==2
        ylabel('regression error')
        title('(A) Sparse Toeplitz: D=1000, n=100')
        set(gca,'Ylim',[10^4,4*10^5],'YTick',ytick,'YTickLabel',log10(ytick)/0.5)
    elseif s==3
        title('p=100, n=100, $\Sigma$=T','interpreter','none')
        set(gca,'Yscale','linear')
        ylim([0,1])
    end
    set(gca,'YScale','log')
    set(gca,'XTick',[0, 25, 50, 75])
    xlabel('# of embedded dimensions')
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% testing %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

newsim=0;
if newsim==1;
    tasknames={'trunk4, D=100';'toeplitz, D=100'};
    task.Ntrials=40;
    task.save=1;
    [T,S] = run_hotelling_sims(tasknames,task);
else
    load([rootDir, '../Data/results/Lopes11a'])
end
S{1}.savestuff=1;


%% plot fig
height=0.3;
vspace=0.08;
bottom=0.13;
left=0.09;
width=0.4;
hspace=0.06;
b2=0.6;
pos(1)=left; pos(2)=width; pos(3)=hspace; pos(4)=b2; pos(5)=height; 

plot_hotelling(T,S,pos)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% save fig %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if S{1}.savestuff
    H.wh=[4 4]*1.5;
    H.fname=[rootDir, '../Figs/regression_power'];
    print_fig(h,H)
end