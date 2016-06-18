function plot_hotelling(T,S,pos)

orange = [1 0.5 0];

col{1}=orange; col{2}='g';col{3}=orange;col{4}='m';col{5}='r';col{6}='r';
ls{1}='-'; ls{2}='-'; ls{3}='--';ls{4}='-'; ls{5}='-';

%%
for t=1:length(S)
    if length(pos)==3
        subplot(Nrows,Ncols,substart+t), cla
    else
        left=pos(1); width=pos(2); hspace=pos(3); b2=pos(4);  height=pos(5); 
        posit=[left+(t-1)*(width+hspace), b2, width, height]; %[left,bottom,width,height]
        subplot('position',posit), cla
    end
    hold all
    for d=1:size(S{t}.mean_power,1)
%         errorbar(T{t}.bvec,S{t}.mean_power(d,:),S{t}.std_power(d,:)/sqrt(T{t}.Ntrials),'linewidth',2,'color',col{d},'linestyle',ls{d})
        plot(T{t}.bvec,S{t}.mean_power(d,:),'linewidth',2,'color',col{d},'linestyle',ls{d})
    end
    xlabel('decay rate')
    axis('tight')
    set(gca,'xscale','linear')
    if T{t}.D < T{t}.n, legendcell{end+1}='Hotelling'; legendcell{end+1}='HotellingB'; end
     
    if t==1, 
        xlim([0,50]), 
        set(gca,'XTick',[10:20:100])
    else
        set(gca,'XTick',[100:200:1000])
    end
    
    if t==1
        ylabel('testing power')
        title([{'(A) Diagonal'}; {'D=200, n=100'}])
    elseif t==2
        title([{'(B) Dense'}; {'D=200, n=100'}])
        set(gca,'YTickLabel',[])
%         legend(legendcell,'location','Southeast')
   end
end