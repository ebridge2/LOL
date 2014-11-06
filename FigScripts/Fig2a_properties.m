%% set path correctly
clearvars, clc,
fpath = mfilename('fullpath');
findex=strfind(fpath,'/');
p = genpath(fpath(1:findex(end-2)));
addpath(p);

%% load example data
load([fpath(1:findex(end-2)), 'Data/Results/example_sims'])


%% plot example panels

% clear G F H
h=figure(1); clf,
G.plot_chance=false;
G.plot_bayes=false;
G.plot_risk=false;
G.plot_time=false;
G.legendOn=0;
G.legend = {'LOL';'PCA'};

G.Nrows=5;
G.Ncols=4;

G.linestyle={'-';'-';'-';'-';'-';'-';'-'};

G.ytick=[0.1:.1:.5];
G.ylim=[0, 0.5];
G.yscale='log';

G.xtick=[25:25:task.ntrain];
G.xlim=[0, 80];
G.xscale='linear';


orange=[1 0.6 0];
gray=0.75*[1 1 1];
purple=[0.5 0 0.5];
G.colors = {'g';'m';'c'};
dd=2;
gg=dd*0.75;
% G.tick_ids{1}=G.xtick;
% G.tick_ids{2}=G.xtick-2;
% G.tick_ids{3}=G.xtick-1;

height=0.12;
vspace=0.08;
bottom=0.06;
left=0.09;
width=0.17;
hspace=0.06;
% sample

for j=1:length(T)
    task1=T{j};
    task1.rotate=false;
    [task1, X, Y, PP] = get_task(task1);
    
    Z = parse_data(X,Y,task1.ntrain,task1.ntest,0);
    
    pos=[left+(j-1)*(width+hspace) bottom+(height+vspace)*4-0.03 width height];
    subplot('position',pos), %[left,bottom,width,height]
    hold on
    
    maxd=task1.ntrain;
    mu=PP.mu; mu=mu/max(mu(:));
    plot(1:length(mu(:,2)),mu(:,1),'color','k','linestyle','-','linewidth',1.5)
    dashline(1:length(mu(:,2)),mu(:,2),dd,gg,dd,gg,'color',gray,'linewidth',1.5)
    
    xlim=[0,100];
    ylim=[-1,1];
    xtick=50:50:xlim(end);
    xticklabel=xtick;
    if j==1
        title('(A) Rotated Trunk')
        ylabel('means')
        ytick=[-1,0,1];
    elseif j==2,
        title('(B) Toeplitz')
        xlim=[1,8];
        xtick=2:2:xlim(end);
        xticklabel=[{'2'};{'4'};{'...'};{'100'}];
        xlabel('ambient dimension index');
        ytick=[];
    elseif j==3,
        title('(C) Fat Tails')
        ytick=[];
    end
    set(gca,'XTick',xtick,'XTickLabel',xticklabel,'Xlim',xlim,'ylim',ylim,'ytick',ytick)
    grid('off')
    
    
    % plot Lhat vs d
    pos=[left+(j-1)*(width+hspace) bottom+(height+vspace)*2 width height]; %[left,bottom,width,height]
    if j==1
        F=G;
        F.doxlabel=false;
        F.title='';
        F.ylabel='error rate';
        F.ytick=[0.05, 0.15, 0.35]; %[0.06, [0.1:0.1:0.3]];
        F.ylim=[0.03,0.5];
        ids=1:10:100;
    elseif j==2
        F=G;
        F.doxlabel=false;
        F.ylim=[0.30,0.5];
        F.ytick=[0:0.1:0.5];
        F.title='';
        F.xlabel='# of embedded dimensions';
        ids=1:10;
    elseif j==3
        F=G;
        F.doxlabel=false;
        F.ylim=[0.15,0.5];
        F.ytick=[0.2,0.3,0.5]; %:0.1:0.5];
        F.title='';
        F.xticklabel=[];
        ids=1:10:100;
    end
    plot_Lhat(T{j},S{j},F,pos)
    
    % plot covariances
    pos=[left+(j-1)*(width+hspace) bottom+(height+vspace)*3-0.06 0.15 0.15]; %[left,bottom,width,height]
    subplot('position',pos)
    imagesc(PP.Sigma(ids,ids))
    set(gca,'xticklabel',[],'yticklabel',[])
    colormap('bone')
    if j==1, ylabel('covariance'), end
    
end


%% load generalization data

load([fpath(1:findex(end-2)), 'Data/Results/generalizations'])

%% make figs
% set figure parameters that are consistent across panels

G.colors = {'k';gray;0.5*[1 1 1]}; %'g';'k';'c';orange;'c';'m'};
G.ms=14;
G.lw=0.5;

G.ms1=1;
G.ms2=2;
%% scatter plots

for j=1:length(T)
    task1=T{j};
    task1.rotate=false;
    task1.ntest=5000;
    [task1, X, Y, PP] = get_task(task1);
    
    Z = parse_data(X,Y,task1.ntrain,task1.ntest,0);
    
    siz=0.11;
    pos=[left+(j-1)*(width+hspace)+0.02 bottom+(height+vspace)*1-0.03 siz siz]; %[left,bottom,width,height]
    subplot('position',pos)
    cla, hold on
    Xplot1=Z.Xtest(:,Z.Ytest==1);
    Xplot2=Z.Xtest(:,Z.Ytest==2);
    idx=1:100;
    
    % plot samples
    plot(Xplot1(1,idx),Xplot1(2,idx),'o','color',G.colors{1},'LineWidth',G.lw,'MarkerSize',G.ms1),
    plot(Xplot2(1,idx),Xplot2(2,idx),'x','color',G.colors{2},'LineWidth',G.lw,'MarkerSize',G.ms2)
    
    % plot means
    plot(PP.mu(1,1),PP.mu(2,1),'.','color',G.colors{1},'linewidth',4,'MarkerSize',G.ms)
    plot(PP.mu(1,2),PP.mu(2,2),'.','color',G.colors{2},'linewidth',4,'MarkerSize',G.ms)
    
    % plot contours
    for nsig=1:2
        if size(PP.Sigma,3)==1,
            Sig=PP.Sigma(1:2,1:2);
        else
            Sig=PP.Sigma(1:2,1:2,nsig);
        end
        C = chol(Sig);
        angle = linspace(0,2*pi,200)';
        xy = [sin(angle) cos(angle)];
        XY = xy*C;
        if j~=4, ct=1; else ct=0.3; end
        plot(PP.mu(1,nsig)+ct*XY(:,1), PP.mu(2,nsig)+ct*XY(:,2),'-','color',G.colors{nsig},'linewidth',1.5); %M(1)+2*XY(:,1), M(2)+2*XY(:,2), 'b--')
    end
    
    if j==4 % for the multimodal example
        % plot more means
        plot(PP.mu(1,3),PP.mu(2,3),'.','color',G.colors{1},'linewidth',2,'MarkerSize',G.ms)
        plot(PP.mu(1,4),PP.mu(2,4),'.','color',G.colors{2},'linewidth',2,'MarkerSize',G.ms)
        
        % plot more contours
        plot(PP.mu(1,3)+ct*XY(:,1), PP.mu(2,3)+ct*XY(:,2),'-','color',G.colors{1},'linewidth',1.5); %M(1)+2*XY(:,1), M(2)+2*XY(:,2), 'b--')
        plot(PP.mu(1,4)+ct*XY(:,1), PP.mu(2,4)+ct*XY(:,2),'-','color',G.colors{2},'linewidth',1.5); %M(1)+2*XY(:,1), M(2)+2*XY(:,2), 'b--')
        
    end
    
    if j==1     % if there is a 3rd class
        Xplot3=Z.Xtest(:,Z.Ytest==3);
        plot(Xplot3(1,idx),Xplot3(2,idx),'s','color',G.colors{3},'LineWidth',G.lw,'MarkerSize',1.5)
        plot(PP.mu(1,3),PP.mu(2,3),'.','color',G.colors{3},'linewidth',2,'MarkerSize',G.ms)
        plot(PP.mu(1,3)+ct*XY(:,1), PP.mu(2,3)+ct*XY(:,2),'-','color',G.colors{3},'linewidth',2); %M(1)+2*XY(:,1), M(2)+2*XY(:,2), 'b--')
    end
    
    if j==1
        zlabel('samples')
        title('(D) 3 Classes')
        lims=[-12,12];
        ticks=-10:10:10;
        idx=1:100;
    elseif j==2
        title('(E) Nonlinear')
        lims=[-2.5, 2.5];
        ticks=-3:1.5:3;
        idx=1:100;
    elseif j==3
        title('(F) Outliers')
        axis('tight')
        idx=1:100;
    elseif j==4
        title('(G) XOR')
        idx=1:200;
        lims=[-2,2];
        ticks=[-1:1];
    end
    
    set(gca,'XTick',ticks,'YTick',ticks,'ZTick',ticks,'XLim',lims, 'YLim',lims, 'ZLim',lims)
    set(gca,'xticklabel',[],'yticklabel',[],'zticklabel',[])
    grid('off')
    
end

%%
G.title='';
% G=rmfield(G,'tick_ids');

for j=1:4
    F=G;
    if j==1
        F.title='';
        F.legendOn=0;
        F.yscale='linear';
        F.doxlabel=1;
        F.xtick=[20:20:50];
        F.xlim=[1, 49];
        F.ytick=[0.25:.2:.7];
        F.ylim=[0.24,0.67];
        F.legend = {'LOL';'PCA'};
        F.colors = {'g';'m'};
        F.ylabel='error rate';
        
    elseif j==2;
        F.legendOn=0;
        F.colors = {'g';'b'};
        F.ylim=[0.28 0.44];
        F.xlim=[1 19];
        F.xtick=[5:5:max(F.xlim)];
        F.ytick=[0.2:0.1:0.5];
        F.xlabel='';
        F.linestyle={'-';'--'};
        
    elseif j==3
        F.ylim = [0.25, 0.27];
        F.ytick = [0:0.01:0.5]; %[F.ylim(1): 0.01: F.ylim(2)];
        F.xlim = [1 150];
        F.xtick=[50:50:F.xlim(end)];
        F.legendOn=0;
        F.colors = {'g';'r'};
        F.scale=1;
        
    elseif j==4
        F.title = '';
        F.ylim = [0.2, 0.45];
        F.ytick = [0:0.1:0.5]; %[F.ylim(1): 0.01: F.ylim(2)];
        F.xlim = [1 15];
        F.xtick=[5:5:max(F.xlim)]; %:F.xlim(end)];
        F.legendOn=0;
        F.colors = {orange;purple;'y'};
        F.linestyle={'--';'--';'--'};
        
    end
    
    pos=[left+(j-1)*(width+hspace) bottom+(height+vspace)*0+0.02 width height]; %[left,bottom,width,height]
    plot_Lhat(T{j},S{j},F,pos)
    
end
str = {'# of embedded dimensions'};
annotation('textbox', [0.35,bottom-0.05,0.6,0.04],'String', str,'EdgeColor','none'); %[x y w h]

% %% load speed stuff
% 
% load([fpath(1:findex(end-2)), 'Data/Results/speed'])
% fpath = mfilename('fullpath');
% findex=strfind(fpath,'/');
% 
% %% plot time vs. k & D
% 
% spacer=-0.02;
% h2=0.08;
% b2=bottom-(height+vspace+0.01);
% 
% types=      {'NENL';'DENL';'DVFL';'NEAL';'DEFL';'DVFQ'};
% F.colors=   {'m';   'g';   purple;'y';   'k';purple};
% F.linestyle={'-';   '-';   '-';   '-';   '-';'--'};
% % F.colors={'m';'g';'b';'y';'k';orange};
% ytick=[0.005, 0.01, 0.02, 0.05, 0.1];
% xtick=[10,30,50,90];
% kk=0;
% for i=[1,3]
%     kk=kk+1;
%     pos=[left+(kk-1)*(width+hspace) b2 width h2]; %[left,bottom,width,height]
%     subplot('position',pos), hold all
%     for j=1:Ntypes
%         eh=errorbar(ks, mean_total(j,:,i),std_total(j,:,i)/sqrt(task.ntrials),'linewidth',2,'color',F.colors{j},'linestyle',F.linestyle{j});
%         set(gca,'xscale','log','Xtick',ks,'yscale','log')
%         errorbar_tick(eh,5000);
%     end
%     grid off, axis('tight')
%     title(['(H', num2str(kk),') D=', num2str(Ds(i)), ', n=', num2str(task.ntrain)])
%     if i==1,
%         ylabel('time (msec)'),
%         ymax=0.05;
%     else
%         ymax=0.1;
%     end
%     %     ymax=max(mean_total(:,:,i),[],2);
%     %     ymax([3,6])=[];
%     %     ylim=[min(min(mean_total(:,:,i))), max(ymax)]; %max(max(mean_total(:,:,i)))];
%     ylim=[min(min(mean_total(:,:,i))),ymax];
%     set(gca,'Ytick',ytick,'YTickLabel',ytick*1000,'XTick',xtick,'YLim',ylim) %:0.02:0.09)
% end
% 
% ytick=[0.005, 0.01, 0.02, 0.05, 0.1];
% for i=[1,3]
%     kk=kk+1;
%     pos=[left+(kk-1)*(width+hspace) b2 width h2]; %[left,bottom,width,height]
%     subplot('position',pos), hold all,
%     if i==1, 
%         ii=1; 
%         ymax=0.05;
%         ymin=min(min(mean_total(:,:,i)))-0.002;
%     elseif i==2, 
%         ii=3; 
%     else
%         ii=5; 
%         ymax=0.1;
%         ymin=0.01; %min(min(mean_total(:,:,i)))-0.004;
%     end
%     for j=1:Ntypes
%         eh=errorbar(Ds, squeeze(mean_total(j,ii,:)),squeeze(std_total(j,ii,:))/sqrt(task.ntrials),'linewidth',2,'color',F.colors{j},'linestyle',F.linestyle{j});
%         set(gca,'xscale','log','Xtick',Ds,'yscale','log')
%         errorbar_tick(eh,5000);
%     end
%     grid off, axis('tight')
% %     ymax=max(mean_total(:,:,i),[],2);
% %     ymax([3,6])=[];
%     ylim=[ymin, ymax]; %max(max(mean_total(:,:,i)))];
%     %     ylim=[min(min(mean_total(:,:,i)))-0.005, 0.1]; %max(max(mean_total(:,:,i)))];
%     title(['(I', num2str(kk-2),') k=', num2str(ks(ii)),', n=', num2str(task.ntrain)])
%     set(gca,'Ytick',ytick,'YTickLabel',ytick*1000,'YLim',ylim) %:0.02:0.09)
% end
% 
% b3=0.0;
% annotation('textbox', [0.15,b3,0.6,0.04],'String', str,'EdgeColor','none'); %[x y w h]
% annotation('textbox', [0.6,b3,0.6,0.04],'String', '# of ambient dimensions','EdgeColor','none'); %[x y w h]


%% legend

pos=[left+(4-1)*(width+hspace)+0.02 bottom+(height+vspace)*3-0.08 width height]; %[left,bottom,width,height]
% hl=subplot(F.Nrows,F.Ncols,F.Ncols);
hl=subplot('position',pos);
hold all, i=1; clear g
g(i)=plot(0,0,'color','c','linewidth',2); i=i+1;
g(i)=plot(0,0,'color','g','linewidth',2); i=i+1;
g(i)=plot(0,0,'color','m','linewidth',2); i=i+1;
g(i)=plot(0,0,'color','b','linewidth',2,'linestyle','--'); i=i+1;
g(i)=plot(0,0,'color','r','linewidth',2); i=i+1;
g(i)=plot(0,0,'color','y','linewidth',2,'linestyle','--'); i=i+1;
g(i)=plot(0,0,'color',orange,'linewidth',2,'linestyle','--'); i=i+1;
g(i)=plot(1,1,'color',purple,'linewidth',2,'linestyle','--'); i=i+1;
g(i)=plot(0,0,'color','k','linewidth',2); i=i+1;

l=legend(g,...
    'ROAD',...
    'LDA o \delta+PCA',...
    'LDA o PCA',...
    'QDA o \delta+PCA^m',...
    'LDA o \delta+rPCA',...
    'QDA o RP',...
    'QDA o \delta+RP',...
    'QDA o \delta+fPCA^m');
legend1 = legend(hl,'show');
% set(legend1,'YColor',[1 1 1],'XColor',[1 1 1],'FontName','FixedWidth');
set(gca,'XTick',[],'YTick',[],'Box','off','xcolor','w','ycolor','w')


%% print figure
if task.savestuff
    H.wh=[7.5 6];
    H.fname=[fpath(1:findex(end-2)), 'Figs/properties'];
    print_fig(h,H)
end