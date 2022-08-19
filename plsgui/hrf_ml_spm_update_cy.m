
% From SPM program

%---------------------------------------------
%---------------------------------------------
function [s,Cy] = hrf_ml_spm_update_cy(s,Cy,Y,beta,ResSS,Hsqr,trRV,trMV,UF)

   j   = sum((Hsqr*beta).^2,1)/trMV > UF*ResSS/trRV;
   j   = find(j);
   if ~isempty(j)
       q  = size(j,2);
       s  = s + q;
       q  = spdiags(sqrt(trRV./ResSS(j)'),0,q,q);
       Y  = double(Y(:,j))*q;
       Cy = Cy + Y*Y';
   end

