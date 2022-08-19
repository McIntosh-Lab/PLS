
% From SPM program

%---------------------------------------------
%---------------------------------------------
function [iX0, xCon, X1o, Hsqr, trRV, trMV, UFp, UF] = hrf_ml_spm_get_fc(xKXs)

   [sC sL] = size(xKXs.X);
   iX0 = sL;

   xCon = struct(...
    'name',     'effects of interest',...
    'STAT',     'F',...
    'c',        [],...
    'X0',       struct('ukX0',[]),... %!15/10
    'iX0',      iX0,...
    'X1o',      struct('ukX1o',[]),...  %!15/10
    'eidf',     [],...
    'Vcon',     [],...
    'Vspm',     []  );

   xCon.X0.ukX0 = hrf_spm_ox(xKXs)' * hrf_spm_xi(xKXs, iX0);

   if xKXs.rk == 0
      error('null rank');
   end

   c0 = eye(sL); c0 = c0(:, iX0);
   c1 = eye(sL); c1 = c1(:, setdiff(1:sL, iX0));
   opp = hrf_spm_sf_opp(xKXs);

   if ~all(all( abs(opp*c0 - c0) <= xKXs.tol ))
      c0 = hrf_spm_sf_tol(opp*c0, xKXs.tol);
   end

   if ~all(all( abs(opp*c1 - c1) <= xKXs.tol ))
      c1 = hrf_spm_sf_tol(opp*c1, xKXs.tol);
   end

   if ~isempty(c1)
      if ~isempty(c0)
         sX = hrf_ml_spm_sf_set(c0);
         xCon.c = hrf_spm_sf_tol(hrf_ml_spm_sf_ry(sX,c1), sX.tol);
      else
         xCon.c = hrf_spm_sf_xpx(xKXs);
      end
   else
      xCon.c = [];
   end

   if ~isempty(xCon.c) & any(any(xCon.c))
      xCon.X1o.ukX1o = hrf_spm_sf_tol(hrf_spm_sf_cukpinvxp(xKXs)*xCon.c, xKXs.tol);
   else
      xCon.X1o.ukX1o = hrf_spm_sf_cukx(xKXs)*xCon.c;
   end

   X1o = hrf_spm_sf_x1o(xCon(1), xKXs);
   Hsqr = hrf_spm_hsqr(xCon(1), xKXs);
   trRV = hrf_spm_trrv(xKXs);
   trMV = hrf_spm_trmv(X1o);

   UFp = 0.001;
   UF = hrf_spm_invfcdf(1 - UFp,[trMV,trRV]);

   return;


%---------------------------------------------
%---------------------------------------------
function x = hrf_spm_sf_tol(x,t)
x(abs(x) < t) = 0;


%---------------------------------------------
%---------------------------------------------
function opp = hrf_spm_sf_opp(sX)

if sX.rk > 0 
    opp = sX.v(:,[1:sX.rk])*sX.v(:,[1:sX.rk])';
else  
    opp = zeros( size(sX.X,2) ); 
end;


%---------------------------------------------
%---------------------------------------------
function x = hrf_spm_sf_xpx(sX)

r = sX.rk;
if r > 0 
    x = sX.v(:,1:r)*diag( sX.ds(1:r).^2 )*sX.v(:,1:r)';
else
    x = zeros(size(sX.X,2));
end


%---------------------------------------------
%---------------------------------------------
function x = hrf_spm_sf_cukpinvxp(sX) 

r = sX.rk;
if r > 0 
    x = diag( ones(r,1)./sX.ds(1:r) )*sX.v(:,1:r)';
else 
    x = zeros( size(sX.X,2) );
end


%---------------------------------------------
%---------------------------------------------
function x = hrf_spm_sf_cukx(sX) 

r = sX.rk;
if r > 0 
    x = diag( sX.ds(1:r) )*sX.v(:,1:r)';
else 
    x = zeros( size(sX.X,2) );
end


%---------------------------------------------
%---------------------------------------------
function b = hrf_spm_sf_x1o(Fc,sX)

if hrf_spm_sf_ver(Fc) > 1, 
   b = hrf_spm_ox(sX)*Fc.X1o.ukX1o;
else, 
   b = Fc.X1o;
end


%---------------------------------------------
%---------------------------------------------
function v = hrf_spm_sf_ver(Fc)

if isstruct(Fc.X0), v = 2; else v = 1; end


%---------------------------------------------
%---------------------------------------------
function ox = hrf_spm_ox(sX)

if sX.rk > 0 
   ox = hrf_spm_sf_uk(sX);
else
   ox = zeros(hrf_spm_sf_s1(sX),1);
end


%---------------------------------------------
%---------------------------------------------
function uk = hrf_spm_sf_uk(x)

uk = x.u(:,1:x.rk);


%---------------------------------------------
%---------------------------------------------
function s1 = hrf_spm_sf_s1(x)

s1 = size(x.X,1);


%---------------------------------------------
%---------------------------------------------
function s2 = hrf_spm_sf_s2(x)

s2 = size(x.X,2);


%---------------------------------------------
%---------------------------------------------
function xi = hrf_spm_xi(sX, i)

xi = sX.X(:,i);


%---------------------------------------------
%---------------------------------------------
function hsqr = hrf_spm_hsqr(Fc, sX)

if hrf_spm_sf_isempty_x1o(Fc)
   if ~hrf_spm_sf_isempty_x0(Fc)
      hsqr = zeros(1,hrf_spm_sf_s2(sX));
   else
      error(' Fc must be set ');
   end
else
   hsqr = hrf_spm_sf_hsqr(Fc,sX);
end


%---------------------------------------------
%---------------------------------------------
function b = hrf_spm_sf_isempty_x1o(Fc)

if hrf_spm_sf_ver(Fc) > 1, 
   b = isempty(Fc.X1o.ukX1o); 

   if b ~= isempty(Fc.c), 
      Fc.c, Fc.X1o.ukX1o, error('Contrast internally not consistent');
   end
else, 
   b = isempty(Fc.X1o);

   if b ~= isempty(Fc.c), 
      Fc.c, Fc.X1o, error('Contrast internally not consistent');
   end
end


%---------------------------------------------
%---------------------------------------------
function b = hrf_spm_sf_isempty_x0(Fc)

if hrf_spm_sf_ver(Fc) > 1, 
   b = isempty(Fc.X0.ukX0); 
else, 
   b = isempty(Fc.X0);
end


%---------------------------------------------
%---------------------------------------------
function hsqr = hrf_spm_sf_hsqr(Fc,sX)

if hrf_spm_sf_ver(Fc) > 1,    
   hsqr = hrf_spm_ox(hrf_ml_spm_sf_set(Fc.X1o.ukX1o))' * hrf_spm_sf_cukx(sX);
else, 
   hsqr = hrf_spm_ox(hrf_ml_spm_sf_set(Fc.X1o))' * sX.X;
end


%---------------------------------------------
%---------------------------------------------
function trRV = hrf_spm_trrv(sX)

rk = sX.rk;
sL = hrf_spm_sf_s1(sX);

if  sL == 0,
    warning('space with no dimension ');    
    trRV = [];
else, 
        if rk==0 | isempty(rk), trRV = sL; 
        else, trRV = sL - rk; 
        end;
end 


%---------------------------------------------
%---------------------------------------------
function trMV = hrf_spm_trmv(sX)

if ~isstruct(sX)
  sX = hrf_ml_spm_sf_set(sX);
end

rk = sX.rk;

if isempty(rk)
    warning('Rank is empty');   
    trMV = [];
    return;
elseif  rk==0, warning('Rank is null');
    trMV = 0;
    return; 
end;

trMV = rk;


%---------------------------------------------
%---------------------------------------------
function x = hrf_spm_invfcdf(F,v,w)

if nargin<2, error('Insufficient arguments'), end

if nargin<3
    vs = size(v);
    if prod(vs)==2
        %-DF is a 2-vector
        w = v(2); v = v(1);
    elseif vs(end)==2
        %-DF has last dimension 2 - unpack v & w
        nv = prod(vs);
        w  = reshape(v(nv/2+1:nv),vs(1:end-1));
        v  = reshape(v(1:nv/2)   ,vs(1:end-1));
    else
        error('Can''t unpack both df components from single argument')
    end
end

ad = [ndims(F);ndims(v);ndims(w)];
rd = max(ad);
as = [  [size(F),ones(1,rd-ad(1))];...
    [size(v),ones(1,rd-ad(2))];...
    [size(w),ones(1,rd-ad(3))]     ];
rs = max(as);
xa = prod(as,2)>1;
if sum(xa)>1 & any(any(diff(as(xa,:)),1))
    error('non-scalar args must match in size'), end

x = zeros(rs);

md = ( F>=0  &  F<=1  &  v>0  &  w>0 );
if any(~md(:)), x(~md) = NaN;
    warning('Returning NaN for out of range arguments'), end

x(md & F==1) = Inf;

Q  = find( md  &  F>0  &  F<1 );
if isempty(Q), return, end
if xa(1), QF=Q; else QF=1; end
if xa(2), Qv=Q; else Qv=1; end
if xa(3), Qw=Q; else Qw=1; end

bQ   = hrf_spm_invBcdf(1-F(QF),w(Qw)/2,v(Qv)/2);
x(Q) = (w(Qw)./bQ -w(Qw))./v(Qv);


%---------------------------------------------
%---------------------------------------------
function x = hrf_spm_invBcdf(F,v,w,tol)

Dtol   = 10^-8;
maxIt = 10000;

if nargin<4, tol = Dtol; end
if nargin<3, error('Insufficient arguments'), end

ad = [ndims(F);ndims(v);ndims(w)];
rd = max(ad);
as = [  [size(F),ones(1,rd-ad(1))];...
    [size(v),ones(1,rd-ad(2))];...
    [size(w),ones(1,rd-ad(3))]     ];
rs = max(as);
xa = prod(as,2)>1;
if sum(xa)>1 & any(any(diff(as(xa,:)),1))
    error('non-scalar args must match in size'), end

x = zeros(rs);

md = ( F>=0  &  F<=1  &  v>0  &  w>0 );
if any(~md(:)), x(~md) = NaN;
    warning('Returning NaN for out of range arguments'), end

x(md & F==1) = 1;
Q  = find( md  &  F>0  &  F<1 );
if isempty(Q), return, end
if xa(1), FQ=F(Q); FQ=FQ(:); else, FQ=F*ones(length(Q),1); end
if xa(2), vQ=v(Q); vQ=vQ(:); else, vQ=v*ones(length(Q),1); end
if xa(3), wQ=w(Q); wQ=wQ(:); else, wQ=w*ones(length(Q),1); end

a  = zeros(length(Q),1); fa = a-FQ;
b  =  ones(length(Q),1); fb = b-FQ;
i  = 0;
xQ = a+1/2;
QQ = 1:length(Q);

while length(QQ) &  i<maxIt
    fxQQ        = betainc(xQ(QQ),vQ(QQ),wQ(QQ))-FQ(QQ);
    mQQ         = fa(QQ).*fxQQ > 0;
    a(QQ(mQQ))  = xQ(QQ(mQQ));   fa(QQ(mQQ))  = fxQQ(mQQ);
    b(QQ(~mQQ)) = xQ(QQ(~mQQ));  fb(QQ(~mQQ)) = fxQQ(~mQQ);
    xQ(QQ)      = a(QQ) + (b(QQ)-a(QQ))/2;
    QQ          = QQ( (b(QQ)-a(QQ))>tol );
    i           = i+1;
end

if i==maxIt, warning('convergence criteria not reached - maxIt reached'), end

x(Q) = xQ;

