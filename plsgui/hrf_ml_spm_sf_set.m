
% From SPM program

%---------------------------------------------
%---------------------------------------------
function x = hrf_ml_spm_sf_set(X)

x = struct(...
    'X',    [],...         % Matrix
    'tol',  [],...      % tolerance
    'ds',   [],...         % vectors of singular values 
    'u',    [],...         % u as in X = u*diag(ds)*v'
    'v',    [], ...        % v as in X = u*diag(ds)*v'
    'rk',   [],...         % rank
    'oP',   [],...      % orthogonal projector on X
    'oPp',  [],...      % orthogonal projector on X'
    'ups',  [],...      % space in which this one is embeded
    'sus',  []);           % subspace 

x.X = X;

if size(X,1) < size(X,2)
    [x.v, s, x.u] = svd(full(X'),0);
else  
    [x.u, s, x.v] = svd(full(X),0);
end

x.ds = diag(s); clear s;

x.tol =  max(size(x.X))*max(abs(x.ds))*eps;
x.rk =  sum(x.ds > x.tol);

return;

