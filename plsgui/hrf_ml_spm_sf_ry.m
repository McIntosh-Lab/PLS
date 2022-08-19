
% From SPM program

%---------------------------------------------
%---------------------------------------------
function Y = hrf_ml_spm_sf_ry(sX,Y)

r = sX.rk;
[q p]= size(sX.X);

if r > 0 %- else returns the input;
    
    if r < q-r %- we better do I - u*u' 
        Y = Y - sX.u(:,[1:r])*(sX.u(:,[1:r])'*Y); % warning('route1');
    else
        %- is it worth computing the n ortho basis ? 
        if size(Y,2) < 5*q
            Y = hrf_spm_sf_r(sX)*Y;            % warning('route2');
        else 
            n = hrf_spm_sf_n(hrf_spm_sf_transp(sX));   % warning('route3');
            Y = n*(n'*Y);
        end
    end

end


%---------------------------------------------
%---------------------------------------------
function r = hrf_spm_sf_r(sX)
r = eye(size(sX.X,1)) - hrf_spm_sf_op(sX) ;


%---------------------------------------------
%---------------------------------------------
function op = hrf_spm_sf_op(sX)
if sX.rk > 0 
    op = sX.u(:,[1:sX.rk])*sX.u(:,[1:sX.rk])';
else  
    op = zeros( size(sX.X,1) ); 
end;


%---------------------------------------------
%---------------------------------------------
function n = hrf_spm_sf_n(sX)

r = sX.rk;
[q p]= size(sX.X);
if r > 0
    if q >= p  %- the null space is entirely in v
        if r == p, n = zeros(p,1); else, n = sX.v(:,r+1:p); end
    else %- only part of n is in v: same as computing the null sp of sX'

        n = null(sX.X); 
    end
else 
    n = eye(p);
end


%---------------------------------------------
%---------------------------------------------
function x = hrf_spm_sf_transp(x)

x.X     = x.X';

tmp     = x.v;
x.v     = x.u;
x.u     = tmp;

tmp     = x.oP;
x.oP    = x.oPp;
x.oPp   = tmp;
clear   tmp;

