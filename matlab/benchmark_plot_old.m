function benchmark_plot_old(varargin)
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

defopts.BestOutOf = 1;
defopts.NumZero = 1e-8;
defopts.FileName = ['.' filesep 'benchdata.mat'];

StatMismatch = 0;

if isstruct(varargin{end}); options = varargin{end}; else options = []; end

% Assign default values to OPTIONS struct
for f = fieldnames(defopts)'
    if ~isfield(options,f{:}) || isempty(options.(f{:}))
        options.(f{:}) = defopts.(f{:});
    end
end

BestOutOf = options.BestOutOf;
NumZero = options.NumZero;

labels = {'probset','prob','subprob','noise','algo','algoset'};
for i = 1:length(labels); varargin{i} = cellify(varargin{i}); end

linstyle = {'k-','b-','r-','g-','m:','r:','c:','g:','k-.'};

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

        %while meetingdur>60 && strcmp(topic, 'subjectrecruitment')
        %    fthinkf('kill meeeeeeeeee')
        %end
        
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
                        
            IsMinKnown = true;
            MinFvalNew = Inf;
            MinFval = Inf;
            
            % Read summary statistics from benchmark file if present
            if exist(options.FileName,'file')
                load(options.FileName);
                
                for iLayer = 1:numel(varargin{dimlayers})
                    benchlist{dimlayers} = varargin{dimlayers}{iLayer};
                    index = find(benchlist{5} == '@',1);
                    if ~isempty(index)
                        algo = benchlist{5}(1:index-1);
                        algoset = benchlist{5}(index+1:end);
                    else
                        algo = benchlist{5};
                        algoset = benchlist{6};
                    end                    
                    field1 = ['f1_' benchlist{1} '_' benchlist{2}];
                    field2 = ['f2_' upper(benchlist{3})];
                    field3 = ['f3_' algo '_' algoset];
                                        
                    % Summary statistics
                    try
                        MinFval = min(MinFval, ...
                            benchdata.(field1).(field2).(field3).MinFval);
                    catch
                        % Field not present, just skip
                    end
                end
            else
                benchdata = [];
            end
                        
            if IsMinKnown; MinPlot = NumZero; end
            
                        
            % Loop over layers within panel
            for iLayer = 1:numel(varargin{dimlayers})
                benchlist{dimlayers} = varargin{dimlayers}{iLayer};

                display([benchlist{dimrows} '@' benchlist{dimcols} '@' benchlist{dimlayers}]);
                
                % Read data files
                basedir = [benchlist{1} '@' benchlist{2}];
                % if ~strcmpi(benchlist{3}(end),'d'); benchlist{3}(end+1) = 'D'; end 
                subdir = upper(benchlist{3});
                
                % Check algorithm subtype
                index = find(benchlist{5} == '@',1);
                if ~isempty(index)
                    algo = benchlist{5}(1:index-1);
                    algoset = benchlist{5}(index+1:end);
                else
                    algo = benchlist{5};
                    algoset = benchlist{6};
                end
                
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
        
                x = []; y = []; FunCallsPerIter = [];
                for i = 1:numel(history)
                    x = [x; history{1}.SavePeriod*(1:length(history{i}.MinScores))];
                    if isnan(history{i}.TrueMinFval)
                        ynew = history{i}.MinScores;
                        IsMinKnown = false;
                    else
                        ynew = history{i}.MinScores - history{i}.TrueMinFval;
                    end
                    y = [y; ynew];
                    if ~isempty(history)
                        MinFvalNew = min(MinFvalNew,min(y(:)));
                        if isfield(history{i},'FunCallsPerIter')
                            FunCallsPerIter{i} = history{i}.FunCallsPerIter;
                        else
                            FunCallsPerIter{i} = NaN;                        
                        end
                    end                    
                end
                
                % Save summary statistics
                field1 = ['f1_' benchlist{1} '_' benchlist{2}];
                field2 = ['f2_' upper(benchlist{3})];
                field3 = ['f3_' algo '_' algoset];
                benchdatanew.(field1).(field2).(field3).MinFval = MinFvalNew;
                                
                % Check if summary statistics match with loaded ones
                if ~isempty(benchdata)
                    try
                        if benchdatanew.(field1).(field2).(field3).MinFval ~= MinFvalNew
                            StatMismatch = StatMismatch + 1;
                        end
                    catch
                        StatMismatch = StatMismatch + 1;
                    end
                end
                
                if isempty(benchdata) || StatMismatch
                    MinFval = MinFvalNew;
                end
                
                itersPerRun = cellfun(@length,FunCallsPerIter);
                display(['Average # of algorithm starts per run: ' num2str(mean(itersPerRun)) ' ± ' num2str(std(itersPerRun)) '.']);
                                
                if ~isempty(history)
                    y = y - MinFval;
                    y(y < NumZero) = NumZero;
                    xx = median(x,1);
                    if BestOutOf > 1
                        nbest = floor(size(y,1)/BestOutOf);
                        ymin = zeros(nbest,size(y,2));
                        for ii = 1:nbest
                            index = (1:BestOutOf) + (ii-1)*BestOutOf;
                            temp = y(index,:);
                            ymin(ii,:) = min(temp,[],1);
                        end
                        yy = median(ymin,1);
                        yyerr = abs(bsxfun(@minus,[quantile(ymin,0.75,1);quantile(ymin,0.25,1)],yy));                        
                    else
                        yy = median(y,1);
                        % yy = quantile(y,0.75,1);
                        % yyerr = abs(bsxfun(@minus,[quantile(y,0.75,1);quantile(y,0.25,1)],yy));
                    end
                    h = plot(xx,yy,linstyle{iLayer},'LineWidth',2); hold on;
                    % h = shadedErrorBar(xx,yy,yyerr,{linstyle{iLayer},'LineWidth',2},1); hold on;
                    % MinFval = min(MinFval,min(y(:)));
                end
            end
            
            if BestOutOf > 1; ystring = ['Median best-of-' num2str(BestOutOf) ' IR']; else ystring = 'Median IR'; end
            
            if iRow == 1; title(benchlist{dimcols}); end
            % if iCol == 1; ylabel(benchlist{dimrows}); end
            if iCol == 1; ylabel(ystring); end
            if iRow == nrows; xlabel('Fun evals'); end
            if iCol == 1
                textstr = benchlist{dimrows};
                textstr(textstr == '_') = ' ';
                text(-1/6*(dimcols+1),0.9,textstr,'Units','Normalized','Rotation',0,'FontWeight','bold','HorizontalAlignment','center');
            end
            xlims = [min(xx,[],2) max(xx,[],2)];
            xtick = [1e2,1e3,1e4,1e5];
            % xtick = [1e2,1e3,2e3,3e3,4e3,5e3,6e3,1e4,1e5];
            set(gca,'Xlim',xlims,'XTick',xtick)
            if IsMinKnown
                ylims = [NumZero,1e3];
                if NumZero < 1e-5
                    ytick = [NumZero,1e-5,0.1,1,10,1e5,1e10];
                    yticklabel = {'0','10^{-5}','0.1','1','10','10^5','10^{10}'};
                else
                    ytick = [NumZero,0.1,1,10,1e3];                    
                    yticklabel = {'10^{-3}','0.1','1','10','10^3'};
                end
                set(gca,'Ylim',ylims,'YTick',ytick,'YTickLabel',yticklabel);
                liney = [1 1];
            else
                if BestOutOf > 1; yrange = 100; else yrange = 200; end
                % ylims = [MinFval,MinFval + yrange];
                ylims = [NumZero,yrange];
                ytick = [0.01,0.1,1,10,100];
                yticklabel = {'0.01','0.1','1','10','100'};
                liney = MinFval*[1 1];                
                set(gca,'Ylim',ylims,'YTick',ytick,'YTickLabel',yticklabel);
            end
            set(gca,'TickDir','out','Xscale','log','Yscale','log','TickLength',3*get(gca,'TickLength'));
            set(gca,'FontSize',12);
            % set(gca,'TickDir','out','Yscale','log','TickLength',3*get(gca,'TickLength'));
            box off;

            
            plot(xlims,liney,'k--','Linewidth',0.5);
            
        end
    end
    
    % Add legend
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

    %if BestOutOf > 1
    %    text(0.5,0.1,['Min f(x*) out of ' num2str(BestOutOf) ' runs'],'Units','Normalized','HorizontalAlignment','Center');
    %end
    
    if 0
        axis([xlims, NumZero 1e3]);
        xlabel('Func evaluations');
        ylabel('Min value');
        set(gca,'TickDir','out','Xscale','log','Yscale','log','TickLength',3*get(gca,'TickLength'));
        %set(gca,'Xlim',xlims);
        %set(gca,'Ylim',ylims);
        set(gca,'XTick',xtick);
        set(gca,'YTick',ytick,'YTickLabel',yticklabel);
        box off;
    else
        axis off;
    end

    set(gcf,'Color','w');
end

if StatMismatch == 1 || isempty(benchdata)
    warning('Summary statistics are not up to date. Replot to have the correct graphs.');
end


benchdata = benchdatanew;
save(options.FileName,'benchdata');

%--------------------------------------------------------------------------
function c = cellify(x)

    if ~iscell(x); c = {x}; else c = x; end 
