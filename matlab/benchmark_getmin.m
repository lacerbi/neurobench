function [x,fval] = benchmark_getmin(data,stringid)
%BENCHMARK_GETMIN Find minimum from benchmark data.

ff = fieldnames(data);

x = [];
fval = Inf;

for iField = 1:numel(ff)
    idx = strfind(ff{iField}, ['_' stringid '_']);
    if isempty(idx); continue; end
    history = data.(ff{iField}).history;
    for iHist = 1:numel(history)
        Output = history{iHist}.Output;
        [fval_tmp,idx] = min(Output.fval);
        if fval_tmp < fval
            x = Output.x(idx,:);
            fval = fval_tmp;
        end
    end
end
    
fprintf('\n\tx = %s;\n\tfval = %s;\n', mat2str(x), mat2str(fval));

end
