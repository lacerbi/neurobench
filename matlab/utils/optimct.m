function varargout = optimct(varargin)
%OPTIMCT Coordinate transform for guided optimization.

NumEps = 1e-10; % Accepted numerical error

% MaxPrecision = 17; % Maximum precision for a double

if nargin >= 5

    nvars = varargin{1};
    lb = varargin{2}(:);
    ub = varargin{3}(:);
    plb = varargin{4}(:);
    pub = varargin{5}(:);
    if nargin < 6; octstruct.logct = []; else octstruct.logct = varargin{6}(:); end

    % Convert scalar inputs to column vectors
    if isscalar(lb); lb = lb*ones(nvars,1); end
    if isscalar(ub); ub = ub*ones(nvars,1); end
    if isscalar(plb); plb = plb*ones(nvars,1); end
    if isscalar(pub); pub = pub*ones(nvars,1); end

    assert(~any(isinf(([plb; pub]))), ...
        'Plausible interval ranges PLB and PUB need to be finite.');

    plb = max(plb,lb);
    pub = min(pub,ub);
    
    if isempty(octstruct.logct)
        % A variable is converted to log scale if all bounds are positive and 
        % the plausible range spans at least one order of magnitude
        octstruct.logct = all([lb, ub, plb, pub] > 0, 2) & (pub./plb >= 10);    
    elseif isscalar(octstruct.logct)
        octstruct.logct = ones(nvars,1);
    end
    
    % Transform to log coordinates
    octstruct.oldbounds.lb = lb;
    octstruct.oldbounds.ub = ub;
    octstruct.oldbounds.plb = plb;
    octstruct.oldbounds.pub = pub;    
    octstruct.lb = lb; octstruct.ub = ub; octstruct.plb = plb; octstruct.pub = pub;
    octstruct.lb(octstruct.logct) = log(octstruct.lb(octstruct.logct));
    octstruct.ub(octstruct.logct) = log(octstruct.ub(octstruct.logct));
    octstruct.plb(octstruct.logct) = log(octstruct.plb(octstruct.logct));
    octstruct.pub(octstruct.logct) = log(octstruct.pub(octstruct.logct));

    octstruct.mu = 0.5*(octstruct.plb + octstruct.pub);
    octstruct.gamma = 0.5*(octstruct.pub - octstruct.plb);
        
    z = ['( (x - ' vec2str(octstruct.mu) ') ./ ' vec2str(octstruct.gamma) ' )'];
    zlog = ['( (log(abs(x) + (x == 0)) - ' vec2str(octstruct.mu) ') ./ ' vec2str(octstruct.gamma) ' )'];
    
    switch sum(octstruct.logct)
        case 0
            octstruct.g = ['@(x) linlog(' z ')'];
            octstruct.ginv = ['@(y) ' vec2str(octstruct.gamma) ' .* linexp(y) + ' vec2str(octstruct.mu) ];        
            
        case nvars
            octstruct.g = ['@(x) linlog(' zlog ')'];
            octstruct.ginv = ['@(y) exp(' vec2str(octstruct.gamma) ' .* linexp(y) + ' vec2str(octstruct.mu) ')'];        
            
        otherwise
            octstruct.g = ['@(x) (1-' vec2str(octstruct.logct) ').*linlog(' z ')' ... 
                '+ ' vec2str(octstruct.logct) '.*linlog(' zlog ')'];
            octstruct.ginv = ['@(y) (1-' vec2str(octstruct.logct) ') .* (' vec2str(octstruct.gamma) ' .* linexp(y) + ' vec2str(octstruct.mu) ') + ' ...
                vec2str(octstruct.logct) ' .* exp(' vec2str(octstruct.gamma) ' .* linexp(y) + ' vec2str(octstruct.mu) ')'];        
    end
    
    % Convert starting values to transformed coordinates
    octstruct.g = str2func(octstruct.g);
    octstruct.ginv = str2func(octstruct.ginv);
    
    if ischar(octstruct.g); g = str2func(octstruct.g); else g = octstruct.g; end
    if ischar(octstruct.ginv); ginv = str2func(octstruct.ginv); else ginv = octstruct.ginv; end
    
    % Check that the transform works correctly in the range
    t(1) = all(abs(ginv(g(lb)) - lb) < NumEps);
    t(2) = all(abs(ginv(g(ub)) - ub) < NumEps);
    t(3) = all(abs(ginv(g(plb)) - plb) < NumEps);
    t(4) = all(abs(ginv(g(pub)) - pub) < NumEps);    
    assert(all(t), 'Cannot invert the transform to obtain the identity at the provided boundaries.');
    
    octstruct.lb = g(lb);
    octstruct.ub = g(ub);
    octstruct.plb = g(plb);
    octstruct.pub = g(pub);
    
    varargout{1} = octstruct;

elseif nargin >= 2
    
    octstruct = varargin{2};    

    if isempty(octstruct)
        varargout{1} = varargin{1}; % Return untransformed input
    else
        if (nargin < 3); direction = 'd'; else direction = varargin{3}(1); end
        
        if direction == 'd' || direction == 'D'
            x = varargin{1};
            if ischar(octstruct.g); g = str2func(octstruct.g); else g = octstruct.g; end
            y = g(x(:));
            y = min(max(y,octstruct.lb),octstruct.ub);    % Force to stay within bounds

            varargout{1} = reshape(y,size(x));
        else
            y = varargin{1};
            if ischar(octstruct.ginv); ginv = str2func(octstruct.ginv); else ginv = octstruct.ginv; end
            x = ginv(y(:));
            x = min(max(x,octstruct.oldbounds.lb),octstruct.oldbounds.ub);    % Force to stay within bounds
            varargout{1} = reshape(x,size(y));
        end
    end
    
end

%--------------------------------------------------------------------------
function s = vec2str(v)
% Convert numerical vector to string

MaxPrecision = 17;  % Maximum precision for a double
if size(v,1) > 1; transp = ''''; else transp = []; end
s = '[';
for i = 1:length(v)-1; s = [s, num2str(v(i),MaxPrecision), ',']; end
s = [s, num2str(v(end),MaxPrecision), ']' transp];

% s = ['[' num2str(v(:)',MaxPrecision) ']' transp];




