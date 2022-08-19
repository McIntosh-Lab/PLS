function [varargout] = hrf_ml_spm_unvec(vX,varargin)

if nargout > 1
    varargout = hrf_ml_spm_unvec(vX,varargin);
    return
end
if length(varargin) == 1
    X = varargin{1};
else
    X = varargin;
end

vX    = hrf_ml_spm_vec(vX);

if iscell(X)
    for i = 1:length(X(:))
        n     = length(hrf_ml_spm_vec(X{i}));
        X{i}  = hrf_ml_spm_unvec(vX(1:n),X{i});
        vX    = vX(n + 1:end);
    end
    varargout      = {X};
    return
end

if isnumeric(X)
    if length(size(X) > 2)
        X(:) = full(vX);
    else
        X(:) = vX;
    end
else
    X     = [];
end
varargout = {X};

