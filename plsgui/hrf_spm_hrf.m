
% From SPM program

%---------------------------------------------
%---------------------------------------------
function [hrf,p] = hrf_spm_hrf(TR,fMRI_T,P)

p   = [6 16 1 1 6 0 32];

if nargin < 2
    fMRI_T = 16;
end

if nargin > 2
    p(1:length(P)) = P;
end

RT = TR/fMRI_T;
dt  = RT/fMRI_T;
u   = [0:(p(7)/dt)] - p(6)/dt;
hrf = hrf_spm_Gpdf(u,p(1)/p(3),dt/p(3))-hrf_spm_Gpdf(u,p(2)/p(4),dt/p(4))/p(5);
hrf = hrf([0:(p(7)/RT)]*fMRI_T + 1);
hrf = hrf'/sum(hrf);
hrf = hrf_spm_orth(hrf);


%---------------------------------------------
%---------------------------------------------
function f = hrf_spm_Gpdf(x,h,l)

if nargin<3, error('Insufficient arguments'), end

ad = [ndims(x);ndims(h);ndims(l)];
rd = max(ad);
as = [  [size(x),ones(1,rd-ad(1))];...
    [size(h),ones(1,rd-ad(2))];...
    [size(l),ones(1,rd-ad(3))]     ];
rs = max(as);
xa = prod(as,2)>1;
if sum(xa)>1 & any(any(diff(as(xa,:)),1))
    error('non-scalar args must match in size'), end

f = zeros(rs);

md = ( ones(size(x))  &  h>0  &  l>0 );
if any(~md(:)), f(~md) = NaN;
    warning('Returning NaN for out of range arguments'), end

ml = ( md  &  x==0  &  h<1 );
f(ml) = Inf;
ml = ( md  &  x==0  &  h==1 ); if xa(3), mll=ml; else mll=1; end
f(ml) = l(mll);

Q  = find( md  &  x>0 );
if isempty(Q), return, end
if xa(1), Qx=Q; else Qx=1; end
if xa(2), Qh=Q; else Qh=1; end
if xa(3), Ql=Q; else Ql=1; end

%-Compute
f(Q) = exp( (h(Qh)-1).*log(x(Qx)) +h(Qh).*log(l(Ql)) - l(Ql).*x(Qx)...
        -gammaln(h(Qh)) );


%---------------------------------------------
%---------------------------------------------
function X = hrf_spm_orth(X,OPT)

try
    OPT;
catch
    OPT = 'pad';
end
 
warning off;
[n m] = size(X);
i     = find(any(X));
X     = X(:,i);
try
    x     = X(:,1);
    j     = 1;
    for i = 2:size(X,2)
        D = X(:,i);
        D = D - x*(inv(x'*x)*x'*D);
        if norm(D,1) > exp(-32)
            x          = [x D];
            j(end + 1) = i;
        end
    end
catch
    x     = zeros(n,0);
    j     = [];
end
warning on;
 
switch OPT
    case{'pad'}
        X      = zeros(n,m);
        X(:,j) = x;
    otherwise
        X      = hrf_spm_en(x);
end


%---------------------------------------------
%---------------------------------------------
function [X] = hrf_spm_en(X)
for i = 1:size(X,2)
    if any(X(:,i))
        X(:,i) = X(:,i)/sqrt(sum(X(:,i).^2));
    end
end

