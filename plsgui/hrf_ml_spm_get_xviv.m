
% From SPM program

%---------------------------------------------
%---------------------------------------------
function V = hrf_ml_spm_get_xviv(Cy, K, X, nScan)

   Vi = hrf_spm_ce(nScan, 0.2);

   m     = length(Vi);
   h     = zeros(m,1);
   V     = sparse(nScan,nScan);

   for i = 1:length(K)
       q     = K(i).row;
       p     = [];
       Qp    = {};
       for j = 1:m
           if nnz(Vi{j}(q,q))
               Qp{end + 1} = Vi{j}(q,q);
               p           = [p j];
           end
       end

       Xp     = X(q,:);
       try
           Xp = [Xp K(i).X0];
       catch
       end

       [Vp,hp]  = hrf_spm_reml(Cy(q,q),Xp,Qp);
       V(q,q)   = V(q,q) + Vp;
       h(p)     = hp;
   end

   V         = V*nScan/trace(V);


%---------------------------------------------
%---------------------------------------------
function [C] = hrf_spm_ce(v,a)

C    = {};
n    = sum(v);
k    = 0;

C{1}  = hrf_ml_spm_q(a,v);
dCda  = hrf_ml_spm_diff('hrf_ml_spm_q',a,v,1);
for i = 1:length(a)
  try
    C{i + 1} = dCda{i};
  catch
    C{i + 1} = dCda;
  end
end


%---------------------------------------------
%---------------------------------------------
function [V,h,Ph,F,Fa,Fc] = hrf_spm_reml(YY,X,Q,N);

try, N; catch, N  = 1;  end
try, K; catch, K  = 128; end
 
W     = Q;
q     = find(all(isfinite(YY)));
YY    = double(YY(q,q));
for i = 1:length(Q)
    Q{i} = Q{i}(q,q);
end
 
n     = length(Q{1});
m     = length(Q);

if isempty(X)
    X = sparse(n,0);
else
    X = hrf_ml_spm_svd(X(q,:));
end
 
for i = 1:m
    h(i,1) = full(any(diag(Q{i})));
end
hE  = sparse(m,1);
hP  = speye(m,m)/exp(32);
 
for k = 1:K
 
    C     = sparse(n,n);
    for i = 1:m
        C = C + Q{i}*h(i);
    end
    iC    = inv(C + speye(n,n)/exp(32));
 
    iCX    = iC*X;
    if ~isempty(X)
        Cq = inv(X'*iCX);
    else
        Cq = sparse(0);
    end
 
    P     = double(iC - iCX*Cq*iCX');
    U     = double(speye(n)) - P*YY/N;
    for i = 1:m 
        PQ{i}     = P*Q{i};
        dFdh(i,1) =  full( -sum(sum(PQ{i}'.*U))*N/2 );
    end
 
    for i = 1:m
        for j = i:m 
            dFdhh(i,j) = full( -sum(sum(PQ{i}'.*PQ{j}))*N/2 );
            dFdhh(j,i) =  dFdhh(i,j);
        end
    end

    e     = h     - hE;
    dFdh  = dFdh  - hP*e;
    dFdhh = dFdhh - hP;
    dh    = hrf_spm_dx(dFdhh,dFdh,{4});
    h     = h + dh; 
    dF    = dFdh'*dh;
    
    if dF < 1e-1
        V     = 0;
        for i = 1:m
            V = V + W{i}*h(i);
        end
        break
    end
end

if ~exist('V','var')
   error('Either your scan data or the brain mask is not correct');
end
 
Ph    = -dFdhh;
if nargout > 3
    Ft = trace(hP*inv(Ph)) - length(Ph) - length(Cq);    
    Fc = Ft/2 + e'*hP*e/2 + hrf_spm_logdet(Ph*inv(hP))/2 - N*hrf_spm_logdet(Cq)/2;
    
    Fa = Ft/2 - trace(C*P*YY*P)/2 - N*n*log(2*pi)/2 - N*hrf_spm_logdet(C)/2;
    
    F  = Fa - Fc;    
end


%---------------------------------------------
%---------------------------------------------
function [H] = hrf_spm_logdet(C)

TOL   = 1e-16;                                        % c.f. n*max(s)*eps
n     = length(C);
s     = diag(C);
i     = find(s > TOL & s < 1/TOL);
C     = C(i,i);
H     = sum(log(diag(C)));

warning off;
[i j] = find(C);
if any(i ~= j)
      n = length(C);
      a = exp(H/n);
      H = H + log(det(C/a));           
end
warning on;

if imag(H) | isinf(H)
    s  = svd(full(C));
    H  = sum(log(s(s > TOL & s < 1/TOL)));
end


%---------------------------------------------
%---------------------------------------------
function [dx] = hrf_spm_dx(dfdx,f,t)

if nargin < 3, t = Inf; end

warning off;
if iscell(t)
    t  = exp(t{:} - log(diag(-dfdx)));
end
warning on;

if min(t) > exp(16)

    dx = -hrf_spm_pinv(dfdx)*hrf_ml_spm_vec(f);
    dx =  hrf_ml_spm_unvec(dx,f);

else
    
    if my_isvector(t), t = diag(t); end

    if length(dfdx) > 128
        dx = hrf_ml_spm_expm((hrf_ml_spm_cat({0 []; t*hrf_ml_spm_vec(f) t*dfdx})));
    else
        dx = expm(full(hrf_ml_spm_cat({0 []; t*hrf_ml_spm_vec(f) t*dfdx})));
    end
    dx = hrf_ml_spm_unvec(dx(2:end,1),f);
end
dx     = real(dx);


%---------------------------------------------
%---------------------------------------------
function X = hrf_spm_pinv(A)

[m,n] = size(A);
if isempty(A), X = sparse(n,m); return, end

warning off;
X     = inv(A'*A);
warning on;

if ~any(isnan(diag(X)))
    X = X*A';
    return
end

[U,S,V] = hrf_ml_spm_svd(A,0);

S   = full(diag(S));
TOL = max(m,n)*eps;
r   = sum(abs(S) > TOL);
if ~r
    X = sparse(n,m);
else
    i = 1:r;
    S = sparse(i,i,1./S(i),r,r);
    X = V(:,i)*S*U(:,i)';
end


%---------------------------------------------
%---------------------------------------------
function x = my_isvector(v)

   if (ndims(v) < 3) & ( size(v,1)==1 | size(v,2)==1 )
      x = 1;
   else
      x = 0;
   end

