
% From SPM program

%---------------------------------------------
%---------------------------------------------
function [x] = hrf_ml_spm_expm(J,x)

if nargin == 1
    J     = sparse(J);
    I     = speye(size(J));
    [f,e] = log2(norm(J,'inf'));
    s     = max(0,e+1);
    J     = J/2^s;
    X     = J; 
    c     = 1/2;
    E     = I + c*J;
    D     = I - c*J;
    q     = 6;
    p     = 1;
    for k = 2:q
        c   = c*(q - k + 1)/(k*(2*q - k + 1));
        X   = J*X;
        cX  = c*X;
        E   = E + cX;
        if p
            D = D + cX;
        else
            D = D - cX;
        end
        p = ~p;
    end
    E = D\E;

    for k = 1:s
        E = E*E;
    end
    x     = E;
else
    J     = sparse(J);
    x     = sparse(x);
    x0    = x;
    fx    = J*x;
    j     = 1;

    while norm(fx,1) > 1e-16
        j  = j + 1;
        x  = x + fx;
        fx = J*fx/j;

        if norm(x,1) > 1e16
            x = hrf_ml_spm_expm(J)*x0;
            return
        end
    end
end

