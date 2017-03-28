function summary = benchmark_summarybarplot(benchdata,fieldname,summary)
%BENCHMARK_SUMMARYPLOT Display summary optimization benchmark results.
%
%   See also BENCHMARK_PLOT.

if nargin < 2; fieldname = []; end
if nargin < 3; summary = []; end

% Get options and remove field
if isfield(benchdata,'options')
    options = benchdata.options;
    benchdata = rmfield(benchdata,'options');
else
    options = [];
end

if isfield(benchdata,'MinBag')
    benchdata = rmfield(benchdata,'MinBag');
end

ff = fields(benchdata)';
if any(strcmp(ff,'yy'))
    xx = benchdata.xx;
    yy = benchdata.yy;
    
    if isfield(summary,fieldname)
        summary.(fieldname).xx = xx;
        summary.(fieldname).yy = yy + summary.(fieldname).yy;
        summary.(fieldname).n = summary.(fieldname).n + 1;
        % summary.(fieldname).MinFval = min(summary.(fieldname).MinFval,benchdata.MinFval);
    else
        summary.(fieldname).xx = xx;
        summary.(fieldname).yy = yy;
        summary.(fieldname).n = 1;
        % summary.(fieldname).MinFval = benchdata.MinFval;
    end
else
    for f = ff        
        summary = benchmark_summarybarplot(benchdata.(f{:}),f{:},summary);
    end
end

if ~isempty(fieldname); return; end

defaults = benchmark_defaults('options');
linstyle = defaults.LineStyle;
lincol = defaults.LineColor;

ff = fields(summary)';
for iField = 1:numel(ff)
    f = ff{iField};
    hold on;    
    xx(iField) = summary.(f).xx;
    yy(iField) = summary.(f).yy./summary.(f).n;
    %xx = xx(~isnan(yy));
    %yy = yy(~isnan(yy));
    bar(xx(iField),yy(iField),'LineStyle','none','FaceColor',lincol(iField,:));
    % MinFval(iField) = summary.(f).MinFval;
    fieldname{iField} = f;
end

fieldname

% MinFval = min(MinFval);
NumZero = options.NumZero;

xlims = [min(xx)-1, max(xx)+1];
xtick = 1:max(xx);
% xtick = [1e2,1e3,2e3,3e3,4e3,5e3,6e3,1e4,1e5];
set(gca,'Xlim',xlims,'XTick',xtick,'XTickLabel',{'5·D','50·D','500·D'})

switch lower(options.Method)
    case 'fs'
        if max(yy) < 0.4
            ylims = [0,0.4]; ytick = [0,0.2,0.4]; yticklabel = {'0','0.2','0.4'};
        else
            ylims = [0,1]; ytick = [0,0.5,1]; yticklabel = {'0','0.5','1'};
        end
        liney = [1 1];
        set(gca,'Ylim',ylims,'YTick',ytick,'YTickLabel',yticklabel);
        set(gca,'TickDir','out');
end

set(gca,'FontSize',14);
box off;

set(gcf,'Color','w');

% xlabel('Algorithms','FontSize',16);
switch lower(options.Method)
    case 'fs'
        ystring = 'Fraction solved';
end
ylabel(ystring,'FontSize',16);

% Add legend
for iField = 1:numel(fieldname)
    temp = fieldname{iField};
    idx = [find(temp == '_'), numel(temp)+1, numel(temp)+1];
    first = temp(idx(1)+1:idx(2)-1);
    second = temp(idx(2)+1:idx(3)-1);
    if ~strcmpi(second,'base')
        legendlist{iField} = [first, ' (', second, ')'];
    else
        legendlist{iField} = first;
    end
    h = plot(min(xlims)*[1 1],min(ylims)*[1 1],linstyle{iField},'LineWidth',2); hold on;    
    hlines(iField) = h;
end
hl = legend(hlines,legendlist{:});
set(hl,'Box','off','Location','NorthWest','FontSize',16);

set(gca,'XTickLabel',legendlist);
xticklabel_rotate([],45);

