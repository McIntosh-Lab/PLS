
% From SPM program

%---------------------------------------------
%---------------------------------------------
function [varargout] = hrf_ml_spm_diff(varargin)

f     = varargin{1};
 
if iscell(varargin{end})
    x = varargin(2:(end - 2));
    n = varargin{end - 1};
    V = varargin{end};
elseif isnumeric(varargin{end})
    x = varargin(2:(end - 1));
    n = varargin{end};
    V = cell(1,length(x));
else
    error('improper call')
end
 
for i = 1:length(x)
    try
        V{i};
    catch
        V{i} = [];
    end
    if isempty(V{i}) & any(n == i);
        V{i} = speye(length(hrf_ml_spm_vec(x{i})));
    end
end
 
m     = n(end);
xm    = hrf_ml_spm_vec(x{m});
dx    = exp(-8);
J     = cell(1,size(V{m},2));
 
if length(n) == 1 
    f0    = feval(f,x{:});
    for i = 1:length(J)
        xi    = x;
        xmi   = xm + V{m}(:,i)*dx;
        xi{m} = hrf_ml_spm_unvec(xmi,x{m});
        fi    = feval(f,xi{:});
        J{i}  = hrf_spm_dfdx(fi,f0,dx);
    end

    f  = hrf_ml_spm_vec(f0);
 
    if isempty(xm)
        J = sparse(length(f),0); 
    elseif isempty(f)
        J = sparse(0,length(xm));
    end
        
    if hrf_isvec(f0)        
        if size(f0,2) == 1
            J = hrf_ml_spm_cat(J);
        else
            J = hrf_ml_spm_cat(J')';
        end
    end
    
    varargout{1} = J;
    varargout{2} = f0;
else 
    f0        = cell(1,length(n));
    [f0{:}]   = hrf_ml_spm_diff(f,x{:},n(1:end - 1),V);
    
    for i = 1:length(J)
        xi    = x;
        xmi   = xm + V{m}(:,i)*dx;
        xi{m} = hrf_ml_spm_unvec(xmi,x{m});
        fi    = hrf_ml_spm_diff(f,xi{:},n(1:end - 1),V);
        J{i}  = hrf_spm_dfdx(fi,f0{1},dx);
    end
    varargout = {J f0{:}};
end


%---------------------------------------------
%--------------------------------------------- 
function dfdx = hrf_spm_dfdx(f,f0,dx)

if iscell(f)
    dfdx  = f;
    for i = 1:length(f(:))
        dfdx{i} = hrf_spm_dfdx(f{i},f0{i},dx);
    end
elseif isstruct(f)
    dfdx  = (hrf_ml_spm_vec(f) - hrf_ml_spm_vec(f0))/dx;
else
    dfdx  = (f - f0)/dx;
end


%---------------------------------------------
%--------------------------------------------- 
function is = hrf_isvec(v)

is = length(size(v)) == 2 & isnumeric(v);
is = is & (size(v,1) == 1 | size(v,2) == 1);

