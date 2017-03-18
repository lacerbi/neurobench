function benchmark_plot_bestx(varargin)
%BENCHMARK_PLOT Display optimization benchmark results.
%
%   BENCHMARK_PLOT(PROBSET,PROB,SUBPROB,NOISE,ALGO,ALGOSET,ORDER) 
%   factorially plots optimization benchmark results for the following 
%   factors: problem set PROBSET, problem(s) PROB, subproblem(s) SUBPROB, 
%   noise level NOISE, algorithm(s) ALGO, algorithm setting(s) ALGOSET. 
%   PROBSET, PROB, SUBPROB, NOISE, ALGO, and ALGOSET can be strings or cell 
%   arrays of strings. ORDER is a cell array of string such that: ORDER{1} 
%   is the factor expanded across rows, ORDER{2} is the factor expanded 
%   across columns, and ORDER{3} (if present) is the factor expanded across
%   figures. Unassigned factors are plotted in the same panel. The factors
%   are 'probset', 'prob', 'subprob', 'noise', 'algo', and 'algoset'.
%
%   BENCHMARK_PLOT(PROBSET,PROB,SUBPROB,NOISE,ALGO,ALGOSET,ORDER,BESTOUTOF) 
%   plots an estimate of the 'minimum out of BESTOUTOF runs'. By default
%   BESTOUTOF is 1.
%
%   Example
%      A typical usage of BENCHMARK_PLOT:
%         benchmark_plot('ccn15',{'trevor_unimodal','trevor_bimodal'},...
%         {'S1','S3','S6','S9','S12'},[],{'fminseach','fmincon'},'base',{'prob','subprob'})
%      plots 'trevor_unimodal' benchmark on the first row and 
%      'trevor_bimodal' on the second row, each column is a different 
%      subject in {'S1','S3','S6','S9','S12'}, and each panel compares 
%      'fminsearch' and 'fmincon'.
%
%   See also BENCHMARK_RUN.

% Base options
defopts.BestOutOf = 1;
defopts.ErrorBar = [];
defopts.NumZero = 1e-8;
defopts.Method = 'IR';          % Immediate regret (IR) or fraction solved (FS)
defopts.SolveThreshold = 1e-6;  
defopts.FileName = ['.' filesep 'benchdata.mat'];

% Plotting options
defopts.YlimMax = 1e3;
defopts.AbsolutePlot = 0;
defopts.DisplayFval = 0;

StatMismatch = 0;

if isstruct(varargin{end}); options = varargin{end}; else options = []; end

% Assign default values to OPTIONS struct
for f = fieldnames(defopts)'
    if ~isfield(options,f{:}) || isempty(options.(f{:}))
        options.(f{:}) = defopts.(f{:});
    end
end

NumZero = options.NumZero;

labels = {'probset','prob','subprob','noise','algo','algoset'};
for i = 1:length(labels); varargin{i} = cellify(varargin{i}); end

linstyle = {'k-','b-','r-','g-','m:','r:','c:','g:','k-.','r-.'};

order = varargin{7};

% Find out what to plot on rows, columns and figures
dimrows = order{1};
if ischar(dimrows); dimrows = find(strcmp(labels,dimrows),1); end
nrows = numel(varargin{dimrows});

dimcols = order{2};
if ischar(dimcols); dimcols = find(strcmp(labels,dimcols),1); end
ncols = numel(varargin{dimcols});

if length(order) > 2
    dimfig = order{3};
    if ischar(dimfig); dimfig = find(strcmp(labels,dimfig),1); end
    nfigs = numel(varargin{dimfig});
else
    nfigs = 1;
    dimfig = [];
end

for i = 1:numel(labels); benchlist{i} = []; end

dimlayers = [];

% Loop over figures
for iFig = 1:nfigs
    if nfigs > 1; benchlist{dimfig} = varargin{dimfig}{iFig}; end

    % Loop over rows
    for iRow = 1:nrows
        benchlist{dimrows} = varargin{dimrows}{iRow};
        if isempty(benchlist{dimrows}); continue; end
        
        % Loop over columns
        for iCol = 1:ncols 
            benchlist{dimcols} = varargin{dimcols}{iCol};
            if isempty(benchlist{dimcols}); continue; end
                    
            subplot(nrows,ncols+1,(iRow-1)*(ncols+1) + iCol);
            cla(gca,'reset');
            
            % Find data dimension to be plotted in each panel
            for i = 1:length(labels)
                if isempty(benchlist{i})
                    benchlist{i} = varargin{i}; 
                    if numel(benchlist{i}) > 1 && isempty(dimlayers)
                        dimlayers = i;
                    else
                        benchlist{i} = varargin{i}{1};
                    end
                end
            end
            if isempty(dimlayers)
                dims = setdiff(1:length(labels),[dimfig dimrows dimcols]);
                dimlayers = dims(1); 
            end
                                                            
            % Loop over layers within panel
            for iLayer = 1:numel(varargin{dimlayers})
                benchlist{dimlayers} = varargin{dimlayers}{iLayer};

                display([benchlist{dimrows} '@' benchlist{dimcols} '@' benchlist{dimlayers}]);
                if isempty(benchlist{4}); noise = [];
                else noise = ['@' benchlist{4} 'noise']; end
                
                % Read data files
                basedir = [benchlist{1} '@' benchlist{2}];
                % if ~strcmpi(benchlist{3}(end),'d'); benchlist{3}(end+1) = 'D'; end 
                subdir = [upper(benchlist{3}) noise];
                
                % Check algorithm subtype
                index = find(benchlist{5} == '@',1);
                if ~isempty(index)
                    algo = benchlist{5}(1:index-1);
                    algoset = benchlist{5}(index+1:end);
                else
                    algo = benchlist{5};
                    algoset = benchlist{6};
                end
                if isempty(algoset); algoset = 'base'; end
                
                basefilename = [algo '@' algoset '@*.mat'];
                filesearch = dir([basedir filesep subdir filesep basefilename]);
                
                if isempty(filesearch)
                    warning(['No files found for ''' [basedir filesep subdir filesep basefilename] ''' in path.']);
                    continue;
                end
                
                % Read history from each file
                history = [];
                for iFile = 1:length(filesearch)
                    filename = [basedir filesep subdir filesep filesearch(iFile).name];                
                    temp = load(filename);
                    if ~isfield(temp,'history'); continue; end
                    for i = 1:length(temp.history); history{end+1} = temp.history{i}; end
                end
        
                x = []; y = []; ysd = [];
                for i = 1:numel(history)
                    [ynew,index] = min(history{i}.Output.fval);
                    x = [x; history{i}.Output.x(index,:)];
                    y = [y; ynew];
                    ysd = [ysd; history{i}.Output.fsd(index,:)];
                end
                
                iLayer
                                                                
                if ~isempty(history)
                    % scatter(iLayer*ones(size(x,1),1),x(:,2));
                    hold on;
                    % xx = median(x,1);
                    
                    xx = y(:);
                    n = numel(y);
                    
                    if 0
                        g = mean(xx);
                        gerr = sqrt(sum(ysd.^2))/n;
                    else
                        obs = bsxfun(@plus,y(:),bsxfun(@times,ysd(:),randn(n,1000)));
                        g = mean(median(obs,1));
                        gerrl = mean(median(obs,1) - prctile(obs,25,1));
                        gerru = mean(prctile(obs,75,1) - median(obs,1));
                        %gerrl = std(obs);
                        %gerru = std(obs);
                    end
                    
                    errorbar(iLayer,g,gerrl,gerru,linstyle{iLayer});
                    
                    %plotErrorBar = options.ErrorBar;
                    %if isempty(plotErrorBar)
                    %    plotErrorBar = numel(varargin{dimlayers}) <= 3;
                    %end                    
                    %if plotErrorBar
                    %    h = shadedErrorBar(xx,yy,yyerr,{linstyle{iLayer},'LineWidth',2},1); hold on;
                    %else
                    %    h = plot(xx,yy,linstyle{iLayer},'LineWidth',2); hold on;
                    %end
                    
                end
            end
                        
            ystring = 'Median f';            
            %if options.DisplayFval; string = [' (f_{min} = ' num2str(MinFval,'%.2f') ')']; 
            %else string = []; end
            
            if iRow == 1; title([benchlist{dimcols}]); end
            % if iCol == 1; ylabel(benchlist{dimrows}); end
            if iCol == 1; ylabel(ystring); end
            if iRow == nrows; xlabel('Algorithms'); end
            if iCol == 1
                textstr = benchlist{dimrows};
                textstr(textstr == '_') = ' ';
                text(-1/6*(dimcols+1),0.9,textstr,'Units','Normalized','Rotation',0,'FontWeight','bold','HorizontalAlignment','center');
            end
            xlims = [0,numel(varargin{dimlayers})+1];
            %xtick = [1e2,1e3,1e4,1e5];
            % xtick = [1e2,1e3,2e3,3e3,4e3,5e3,6e3,1e4,1e5];
            %set(gca,'Xlim',xlims,'XTick',xtick)

            ylims = [0,1];
            ytick = [0,0.5,1];
            yticklabel = {'0','0.5','1'};
            liney = [1 1];
            %set(gca,'Ylim',ylims,'YTick',ytick,'YTickLabel',yticklabel);
            set(gca,'TickDir','out','TickLength',3*get(gca,'TickLength'));
            set(gca,'FontSize',12);
            box off;
            % plot(xlims,liney,'k--','Linewidth',0.5);
        end
    end
    
    % Add legend
    if 1
    subplot(nrows,ncols+1,ncols+1);
    cla(gca,'reset');
    for iLayer = 1:length(varargin{dimlayers})
        temp = varargin{dimlayers}{iLayer};
        index = find(temp == '@',1);
        if isempty(index)
            legendlist{iLayer} = temp;
        else
            first = temp(1:index-1);
            second = temp(index+1:end);
            if ~strcmpi(second,'base')
                legendlist{iLayer} = [first, ' (', second, ')'];
            else
                legendlist{iLayer} = first;                
            end
        end
        h = shadedErrorBar(min(xlims)*[1 1],min(ylims)*[1 1],[0 0],{linstyle{iLayer},'LineWidth',2},1); hold on;
        hlines(iLayer) = h.mainLine;
    end
    hl = legend(hlines,legendlist{:});
    set(hl,'Box','off','Location','NorthWest','FontSize',14);
    end

    axis off;

    set(gcf,'Color','w');
end

%benchdata = benchdatanew;
%benchdata.options = options;

% save(options.FileName,'benchdata');

%--------------------------------------------------------------------------
function c = cellify(x)

    if ~iscell(x); c = {x}; else c = x; end 
