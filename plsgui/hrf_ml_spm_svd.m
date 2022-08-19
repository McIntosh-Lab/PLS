
% From SPM program

%---------------------------------------------
%---------------------------------------------
function [U,S,V] = hrf_ml_spm_svd(X,U,T)

if nargin < 2
    U = 1e-6;
end

if nargin < 3
    T = 0;
end

[M N] = size(X);
p     = find(any(X,2));
q     = find(any(X,1));
X     = X(p,q);

[i j s] = find(X);
[m n]   = size(X);

if any(i - j)
    X     = full(X);
    if m > n

        [v S v] = svd(X'*X,0);
        S       = sparse(S);
        s       = diag(S);
        j       = find(s*length(s)/sum(s) >= U & s >= T);
        v       = v(:,j);
        u       = hrf_spm_en(X*v);
        S       = sqrt(S(j,j));

    elseif m < n

        [u S u] = svd(X*X',0);
        S       = sparse(S);
        s       = diag(S);
        j       = find(s*length(s)/sum(s) >= U & s >= T);
        u       = u(:,j);
        v       = hrf_spm_en(X'*u);
        S       = sqrt(S(j,j));

    else

        [u S v] = svd(X,0);
        S       = sparse(S);
        s       = diag(S).^2;
        j       = find(s*length(s)/sum(s) >= U & s >= T);
        v       = v(:,j);
        u       = u(:,j);
        S       = S(j,j);
    end

else
    S     = sparse(1:n,1:n,s,m,n);
    u     = speye(m,n);
    v     = speye(m,n);
    [i j] = sort(-s);
    S     = S(j,j);
    v     = v(:,j);
    u     = u(:,j);
    s     = diag(S).^2;
    j     = find(s*length(s)/sum(s) >= U & s >= T);
    v     = v(:,j);
    u     = u(:,j);
    S     = S(j,j);

end

j      = length(j);
U      = sparse(M,j);
V      = sparse(N,j);
if j
    U(p,:) = u;
    V(q,:) = v;
end


%---------------------------------------------
%---------------------------------------------
function [X] = hrf_spm_en(X)

for i = 1:size(X,2)
    if any(X(:,i))
        X(:,i) = X(:,i)/sqrt(sum(X(:,i).^2));
    end
end

