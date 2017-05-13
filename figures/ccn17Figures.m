%% Make Figures for CCN17 abstract
function ccn17Figures(fig)

axesfontsize = 16;
fontsize = 24;

figure(fig); clf;
currentDir = pwd();

grid = [1 1 1 2 2 2 3 3 3 4];
hg = plotify(grid,'Margins',[0.05 0.05 0.15 0.1],'Gutter',0.075,'FontSize',18,'Labels',{'A','B','C'});

filenames = 'benchdata_1';
switch fig
    case 1
        folders = {'ccn17-visvest','ccn17-adler2016','ccn17-goris2014'};
        titles = {'Causal inference', ...
            'Bayesian confidence', ...
            'Neuronal selectivity'};
        noisyflag = 0;
    case 2
        folders = {'ccn17-vandenberg2017','ccn17-targetloc','ccn17-vanopheusden2016'};
        titles = {'Word recognition memory', ...
            'Target detection/localization', ...
            'Combinatorial game playing'};
        noisyflag = 1;
end

%% Plot panels
for iPanel = 1:numel(folders)
    if iscell(filenames); filename = filenames{iPanel}; else filename = filenames; end
    plotPanel(folders{iPanel},filename,hg(iPanel),titles{iPanel},fontsize,axesfontsize,noisyflag(min(iPanel,end)));
    fixLegend(0);
    drawnow;
end

cd(currentDir);

%% Add final touches

axes(hg(4)); axis off;

%% Save

figname = ['ccn17_fig' num2str(fig)];
set(gcf,'Position',[1 241 1920 480],'PaperPositionMode','auto');

pause(0.5);
saveas(gcf,[figname '.fig']);
try
    saveas(gcf,[figname '.svg']);
    saveas(gcf,[figname '.png']);   
catch
    warning(['Could not save figure ''' figname '''.']);
end


%--------------------------------------------------------------------------
function plotPanel(folder,filename,haxis,titlestring,fontsize,axesfontsize,noisyflag)

% Folder that contains benchmark data
datafolder = 'C:\Users\Luigi\Dropbox\Postdoc\BenchMark\data';

cd([datafolder filesep folder]);
temp = load(filename);
if noisyflag; temp.benchdata.options.Method = 'FST'; end

axes(haxis);
benchmark_summaryplot(temp.benchdata);

set(gca,'FontSize',axesfontsize);
xl = get(gca,'xlabel');
yl = get(gca,'ylabel');

xlabel(xl.String,'FontSize',fontsize);
ylabel(yl.String,'FontSize',fontsize);

if ~isempty(titlestring)
    title(titlestring,'FontSize',fontsize);
end

%--------------------------------------------------------------------------
function fixLegend(bads_flag)

stringsIn =     {'bads (lcbnearest)',   'bads (lcbnearest-overhead)',   'bads (acqlcb)',   'bads (acqlcb-overhead)',   'bads (acqlcb-m5)', 'bads (matern5)', ...
        'bads',             'bads (nearest)',   'bads (sqexp)', ...
        'bads (acqpi-m5)',  'bads (acqpi)',     'bads (acqpi-se)',      'bads (onesearch)', ...
        'bads (searchwcm)', 'bads (searchell)'};
stringsOut =    {'bads',    'bads', 'bads',    'bads',                             'bads (m5,lcb)',    'bads (m5,ei)', ...
        'bads (rq,ei)',     'bads (rq,ei)',     'bads (se,ei)', ...
        'bads (m5,pi)',     'bads (rq,pi)',     'bads (se,pi)',     'bads (nsearch=1)', ...
        'bads (search-wcm)', 'bads (search-?)'};

if bads_flag
    stringsOut{1} = 'bads (rq,lcb,default)';
    stringsOut{2} = 'bads (rq,lcb,default)';
    stringsOut{3} = 'bads (rq,lcb,default)';
    stringsOut{4} = 'bads (rq,lcb,default)';
end
    
hl = legend();
legString = hl.String;
for i = 1:numel(legString)
    idx = find(strcmp(legString{i},stringsIn),1);
    if ~isempty(idx); legString{i} = stringsOut{idx}; end
end
set(hl,'String',legString);
