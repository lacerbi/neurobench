function summary = benchmark_summaryplot(benchdata,fieldname,summary,options)
%BENCHMARK_SUMMARYPLOT Display summary optimization benchmark results.
%
%   See also BENCHMARK_PLOT.

% Luigi Acerbi 2016

if nargin < 2; fieldname = []; end
if nargin < 3; summary = []; end
if nargin < 4; options = []; end

% Get options and remove field
if isfield(benchdata,'options') && isempty(options)
    options = benchdata.options;
    benchdata = rmfield(benchdata,'options');
end

benchdata
ff = fields(benchdata)';

if any(strcmp(ff,'yy'))
    
    switch lower(options.Method)
        case 'ert'
            xrange = exp(linspace(log(10),log(1e3),200));
            xx = benchdata.xx;
            yy = interp1(xx,benchdata.yy,xrange);
            xtick = [1e-2,1e-1,1];
            xticklabel = {'5·D','50·D','500·D'};
        case {'ir','fs'}
            % xrange = logspace(-2,0,200);
            xrange = exp(linspace(log(10),log(1e3),200));
            xx = benchdata.xx;
            yy = interp1(xx,benchdata.yy,xrange);
            xtick = [1,1e1,1e2,1e3];
            xticklabel = {'1','10','100','1000'};
        case {'fst'}
            xrange = exp(linspace(log(10),log(0.1),200));
            xx = benchdata.xx;
            yy = interp1(xx,benchdata.yy,xrange);
            xtick = [0.1,1,10];
            xticklabel = {'0.1','1','10'};
            
            
    end
    
    MinFval = NaN;
    if isfield(benchdata,'MinFval'); MinFval = benchdata.MinFval; end
    
    if isfield(summary,fieldname)
        summary.(fieldname).yy = yy + summary.(fieldname).yy;
        summary.(fieldname).n = summary.(fieldname).n + 1;
        summary.(fieldname).MinFval = min(summary.(fieldname).MinFval,MinFval);
    else
        summary.(fieldname).xrange = xrange;
        summary.(fieldname).yy = yy;
        summary.(fieldname).n = 1;
        summary.(fieldname).MinFval = MinFval;
    end
else
    for f = ff
        if isstruct(benchdata.(f{:}))
            summary = benchmark_summaryplot(benchdata.(f{:}),f{:},summary,options);
        end
    end
end

if ~isempty(fieldname); return; end

defaults = benchmark_defaults('options');
linstyle = defaults.LineStyle;
lincol = defaults.LineColor;
reverseX_flag = 0;


ff = fields(summary)';
xlims = [Inf,-Inf];
for iField = 1:numel(ff)
    f = ff{iField};
    hold on;    
    xx = summary.(f).xrange;
    xlims = [min(xlims(1),min(xx)*0.999),max(xlims(2),max(xx)*1.001)];
    yy = summary.(f).yy./summary.(f).n;
    xx = xx(~isnan(yy));
    yy = yy(~isnan(yy));

    enhance = enhanceline(numel(ff),options);    
    if iField == enhance; lw = 4; else lw = 2; end
    plot(xx,yy,linstyle{iField},'LineWidth',lw,'Color',lincol(iField,:));
    MinFval(iField) = summary.(f).MinFval;
    fieldname{iField} = f;
end

NumZero = options.NumZero;
% xlims = [min(xrange,[],2) max(xrange,[],2)];
% set(gca,'Xlim',xlims,'XTick',xtick,'XTickLabel',xticklabel)

switch lower(options.Method)
    case 'ir'
        ylims = [NumZero,1e3];
        if NumZero < 1e-5
            ytick = [NumZero,1e-5,0.1,1,10,1e5,1e10];
            yticklabel = {'0','10^{-5}','0.1','1','10','10^5','10^{10}'};
        else
            ytick = [NumZero,0.1,1,10,1e3];                    
            yticklabel = {'10^{-3}','0.1','1','10','10^3'};
        end
        liney = [1 1];
        set(gca,'Ylim',ylims,'YTick',ytick,'YTickLabel',yticklabel);
        set(gca,'TickDir','out','Xscale','log','Yscale','log','TickLength',3*get(gca,'TickLength'));

    case {'fs'}
        ylims = [0,1];
        ytick = [0,0.5,1];
        yticklabel = {'0','0.5','1'};
        liney = [1 1];
        xtick = [10:10:100,200:100:1000];
        for i = 1:numel(xtick); xticklabel{i} = ''; end
        xticklabel{1} = '10';
        xticklabel{5} = '50';
        xticklabel{10} = '100';
        xticklabel{14} = '500';
        xticklabel{19} = '1000';
        set(gca,'TickDir','out','Xscale','log');
        set(gca,'Xlim',xlims,'XTick',xtick,'XTickLabel',xticklabel);
        set(gca,'Ylim',ylims,'YTick',ytick,'YTickLabel',yticklabel);
        % set(gca,'TickDir','out','Xscale','log','TickLength',3*get(gca,'TickLength'));
        set(gca,'TickDir','out','Xscale','log');
        
    case {'fst'}
        ylims = [0,1];
        ytick = [0,0.5,1];
        yticklabel = {'0','0.5','1'};
        liney = [1 1];
        xtick = [0.1 0.3 1 3 10];
        for i = 1:numel(xtick); xticklabel{i} = num2str(xtick(i)); end
%        for i = 1:numel(xtick); xticklabel{i} = ''; end
%        xticklabel{1} = '10';
%        xticklabel{5} = '50';
%       xticklabel{10} = '100';
%       xticklabel{14} = '500';
%       xticklabel{19} = '1000';
        set(gca,'TickDir','out','Xscale','log');
        set(gca,'Xlim',xlims,'XTick',xtick,'XTickLabel',xticklabel);
        set(gca,'Ylim',ylims,'YTick',ytick,'YTickLabel',yticklabel);
        % set(gca,'TickDir','out','Xscale','log','TickLength',3*get(gca,'TickLength'));
        set(gca,'TickDir','out','Xscale','log');
        reverseX_flag = 1;
        
        
    case 'ert'
        ylims = [0,1];
        ytick = [0,0.5,1];
        yticklabel = {'0','0.5','1'};
        liney = [1 1];
        xtick = [10:10:100,200:100:1000];
        for i = 1:numel(xtick); xticklabel{i} = ''; end
        xticklabel{1} = '10';
        xticklabel{5} = '50';
        xticklabel{10} = '100';
        xticklabel{14} = '500';
        xticklabel{19} = '1000';
        set(gca,'TickDir','out','Xscale','log');
        set(gca,'Xlim',xlims,'XTick',xtick,'XTickLabel',xticklabel);
        set(gca,'Ylim',ylims,'YTick',ytick,'YTickLabel',yticklabel);
        % set(gca,'TickDir','out','Xscale','log','TickLength',3*get(gca,'TickLength'));
        
end

set(gca,'FontSize',14,'TickDir','out');
% set(gca,'TickDir','out','Yscale','log','TickLength',3*get(gca,'TickLength'));
box off;

set(gcf,'Color','w');

switch lower(options.Method)
    case 'ir'
        xstring = 'Fun evals / Dim';
        ystring = 'Median IR';
    case 'fs'
        xstring = 'Fun evals / Dim';
        ystring = 'Fraction solved';
    case 'ert'
        xstring = 'FEvals / Dim';
        ystring = 'Fraction solved';        
    case 'fst'
        xstring = 'Accepted error threshold';
        ystring = 'Fraction solved';        
end
xlabel(xstring,'FontSize',16);
ylabel(ystring,'FontSize',16);
if isfield(options,'VerticalThreshold') && ~isempty(options.VerticalThreshold)
    plot(options.VerticalThreshold*[1,1],[0,1],'k--','LineWidth',1);
end

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
    h = plot(min(xlims)*[1 1],min(ylims)*[1 1],linstyle{iField},'LineWidth',2,'Color',lincol(iField,:)); hold on;    
    % h = shadedErrorBar(min(xlims)*[1 1],min(ylims)*[1 1],[0 0],{linstyle{iField},'LineWidth',2},1); h = h.mainline; hold on;
    hlines(iField) = h;
end
hl = legend(hlines,legendlist{:});
set(hl,'Box','off','Location','NorthWest','FontSize',16);

if reverseX_flag
    set(gca,'Xdir','reverse'); 
    set(hl,'Location','NorthEast');
end