
% From SPM program

%---------------------------------------------
%---------------------------------------------
function [vX] = hrf_ml_spm_vec(varargin)

X     = varargin;
if length(X) == 1
    X = X{1};
end
vX    = [];
 
if iscell(X)
    X     = X(:);
    for i = 1:length(X)
         vX = cat(1,vX, hrf_ml_spm_vec(X{i}));
    end
    return
end
 
if isnumeric(X) | islogical(X)
    vX = X(:);
end

