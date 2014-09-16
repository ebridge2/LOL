% this script generates the simulation and plots the results for Fig 1

%% set path correctly
clearvars, clc,
fpath = mfilename('fullpath');
findex=strfind(fpath,'/');
p = genpath(fpath(1:findex(end-2)));
% addpath(p);
s=rng;
save('~/Research/working/A/LOL/Data/randstate','s')
% load([fpath(1:findex(end-2)), 'Data/randstate']);
% rng(s);

%% set up tasks
clear idx
task_list_name='cs'; 
task.D=1000;
task.ntrain=100;
k=10;
task_list = set_task_list(task_list_name);
task.ks=1:20;
task.ntest=1000;
task.rotate=false;
task.algs={'LOL';'ROAD'};
task.types={'NEFL';'DEFL'};
task.savestuff=1;
orange=[1 0.6 0];


h(1)=figure(1); clf
Nsims=length(task_list);
Nalgs=length(task.algs)+length(task.types)-1;
Nrows=Nsims;
Ncols=Nalgs+3;
gray=0.7*[1 1 1];
for j=1:Nsims
    
    task.name=task_list{j};
    % generate data and embed it
    [task1, X, Y, P] = get_task(task);
    
    Z = parse_data(X,Y,task1.ntrain,task1.ntest,0);
        
    subplot(Nrows,Ncols,1+Ncols*(j-1)), hold on
    Xplot1=Z.Xtest(:,Z.Ytest==1);
    Xplot2=Z.Xtest(:,Z.Ytest==2);
    idx=randperm((task.ntest-100)/2);
    idx=idx(1:100);
    plot(Xplot1(1,idx),Xplot1(2,idx),'o','color',[0 0 0],'LineWidth',1.0,'markersize',4),
    plot(Xplot2(1,idx),Xplot2(2,idx),'x','color',gray,'LineWidth',1.0,'markersize',4)
    axis('equal')
    %     set(gca,'XTick',[-5:5:5],'YTick',[-10:5:10],'XLim',[-8 8], 'YLim',[-15 15])
    set(gca,'XTickLabel',[],'YTickLabel',[])
    grid('on')
    switch j
        case 1, tit='Aligned';
        case 2, tit='Orthogonal';
        case 3, tit='Rotated';
    end
    ylabel(tit)
    
    
    [transformers, deciders] = parse_algs(task1.types);
    Proj = LOL(Z.Xtrain,Z.Ytrain,transformers,task1.Kmax);
    PP{2}=Proj{1};
    PP{1}=Proj{2};
    Proj=PP;
    
    for i=1:Ncols-1
        if i<3
            Xtest=Proj{i}.V(1:k,:)*Z.Xtest;
            Xtrain=Proj{i}.V(1:k,:)*Z.Xtrain;
            [Yhat, parms, eta] = LDA_train_and_predict(Xtrain, Z.Ytrain, Xtest);
        elseif i==3
            para.K=20;
            fit = road(Z.Xtrain', Z.Ytrain,0,0,para);
            nl=0; kk=1;
            while nl<=k, nl=nnz(fit.wPath(:,kk)); kk=kk+1; end
            [~,Yhat,eta] = roadPredict(Z.Xtest', fit);
            eta=eta(:,kk);
        else
            parms.del=P.del;
            parms.InvSig=pinv(P.Sigma);
            parms.mu=P.mu*P.w;
            
            parms.del=P.mu(:,1)-P.mu(:,2);
            parms.mu=P.mu*P.w;
            parms.thresh=(log(P.w(1))-log(P.w(2)))/2;
            eta = parms.del'*parms.InvSig*Z.Xtest - parms.del'*parms.InvSig*parms.mu - parms.thresh;
        end
        
        
        % class 1 parms
        eta1=eta(Z.Ytest==1);
        mu1=mean(eta1);
        sig1=std(eta1);
        
        % class 2 parms
        eta2=eta(Z.Ytest==2);
        mu2=mean(eta2);
        sig2=std(eta2);
        
        % get plotting bounds
        min2=mu2-3*sig2;
        max2=mu2+3*sig2;
        min1=mu1-3*sig1;
        max1=mu1+3*sig1;
        
        t=linspace(min(min2,min1),max(max2,max1),100);
        y2=normpdf(t,mu2,sig2);
        y1=normpdf(t,mu1,sig1);
        maxy=max(max(y2),max(y1));
        ls1='-';
        ls2='--';
        
        if i==3
            col1='c'; col2=col1;
            tit='ROAD';
            si=2;
            ls1='--';
            ls2='-';
        elseif i==2
            col1='g'; col2=col1;
            tit='LOL';
            si=3;
        elseif i==1
            col1='m'; col2=col1;
            tit='LDA o PCA';
            si=1;
        elseif i==4
            tit='Bayes';
            col1='k';
            col2='k';
            si=4;
        end
        subplot(Nrows,Ncols,(si+1)+Ncols*(j-1)), hold on
        
        plot(t,y2,'linestyle',ls1,'color',col2,'linewidth',2)
        plot(t,y1,'linestyle',ls2,'color',col1, 'linewidth',2)
        if i~=3
            fill(t,[y1(1:50),y2(51:end)],col1,'EdgeColor',col1)
        else
            fill(t,[y2(1:50),y1(51:end)],col1,'EdgeColor',col1)
        end
        plot([0,0],[0, maxy],'k')
        
        grid on
        axis([min(min2,min1), max(max2,max1), 0, 1.05*maxy])
        if j==1, title(tit), end

        set(gca,'XTickLabel',[],'YTickLabel',[])
    end
end

%%
% [T,S,P] = run_task(task);



%% save figs
if task.savestuff
    F.fname=[fpath(1:findex(end-2)), 'Figs/cigars'];
    F.wh=[4 2]*2;
    print_fig(h(1),F)
end