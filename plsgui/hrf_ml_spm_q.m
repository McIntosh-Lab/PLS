
% From SPM program

%---------------------------------------------
%---------------------------------------------
function [Q] = hrf_ml_spm_q(a,n,q)

try, q; catch, q = 0; end

p    = length(a);

if q
    A    = [-a(1) (1 + a(1)^2) -a(1)];
    Q    = spdiags(ones(n,1)*A,[-p:p],n,n);
else
    A    = [1 -a(:)'];
    P    = spdiags(ones(n,1)*A,-[0:p],n,n);
    K    = inv(P);
    K    = K.*(abs(K) > 1e-4);
    Q    = K*K';
    Q    = toeplitz(Q(:,1));
end

%Q = sparse(Q);

