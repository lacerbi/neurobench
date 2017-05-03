%% Make Figures for BADS whitepaper
function badsFigures(fig)

axesfontsize = 16;
fontsize = 24;

figure(fig); clf;
currentDir = pwd();

grid = [1 1 1 2 2 2 3 3 3];
hg = plotify(grid,'Margins',[0.05 0.05 0.15 0.1],'Gutter',0.075,'FontSize',18);

filenames = 'benchdata_1';
switch fig
    case 1
        folders = {'bbob09','bbob09','bbob09@hetnoise'};
        titles = {'BBOB09 noiseless (BADS variants)', ...
            'BBOB09 noiseless', ...
            'BBOB09 with heteroskedastic noise'};
        filenames = {'benchdata_bads1','benchdata_1','benchdata_1'};
        noisyflag = [0 0 1];
    case 2
        folders = {'ccn17-visvest','ccn17-adler2016','ccn17-goris2014'};
        titles = {'Acerbi, Dokka, et al. (2017), 6 subjects (D = 10)', ...
            'Adler and Ma (2016), 6 subjects (D = 13)', ...
            'Goris et al. (2015), 6 neurons (D = 12)'};
        titles = {'CCN17 causal inference', ...
            'CCN17 Bayesian confidence', ...
            'CCN17 neuronal selectivity'};
        noisyflag = 0;
    case 3
        folders = {'ccn17-vandenberg2017','ccn17-targetloc','ccn17-vanopheusden2016'};
        titles = {'CCN17 word recognition memory', ...
            'CCN17 target detection/localization', ...
            'CCN17 combinatorial game playing'};
        noisyflag = 1;
    % Supplementary Figures
    case 11
        folders = {'bbob09','bbob09','bbob09@hetnoise500D'};
        titles = {'BBOB09 noiseless (BADS variants)', ...
            'BBOB09 noiseless', ...
            'BBOB09 with heteroskedastic noise'};
        filenames = {'benchdata_bads1_eps','benchdata_1_eps','benchdata_1'};
        noisyflag = [0 0 1];
end

%% Plot panels
for iPanel = 1:numel(folders)
    if iscell(filenames); filename = filenames{iPanel}; else filename = filenames; end
    plotPanel(folders{iPanel},filename,hg(iPanel),titles{iPanel},fontsize,axesfontsize,noisyflag(min(iPanel,end)));
    fixLegend(fig == 1 && iPanel == 1);
    drawnow;
end

cd(currentDir);

%% Add final touches

%axes(hg(4)); axis off;
if fig == 2
    overheads = [24 68 14];
    for iPanel = 1:numel(folders)
        axes(hg(iPanel));
        ht = text(0.46,0.9,['<overhead> = ' num2str(overheads(iPanel)) '%'],'Units','normalized','HorizontalAlignment','left','FontSize',axesfontsize,'BackGroundColor','w');
        % uistack(ht,'top');
    end
end

if fig == 11
    axes(hg(3));
    ylabel('Fraction solved at 500×D fun evals');
end

%% Save

figname = ['bads_fig' num2str(fig)];
set(gcf,'Position',[1 241 1920 720],'PaperPositionMode','auto');

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
