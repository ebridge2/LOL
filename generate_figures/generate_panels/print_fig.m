function print_fig(h,wh,fname,renderer)
% h: figure handle
% fname: name of fig file & script
% wh: set paper width and height

set(h,'PaperSize',wh,'PaperPosition',[0 0 wh],'color','w');
set(h, 'InvertHardCopy', 'off');
set(h,'renderer',renderer)
saveas(h,fname,'fig')
print(h,fname,'-dpdf')
print(h,fname,'-dpng','-r300')

