function pct=erp_per(s)

% syntax erp_per(s)
% calculates proportion crossblock covar accounted for

[r,c]=size(s);
if (r==c | c>1); %1st case is the normal "s", 2nd case is for section of posthoc "s"
s =diag(s);
pct=(s.^2/sum(s.^2));
else		%have a single vector, as in the output from the permutation test.
   s=s;
   pct=(s.^2/sum(s.^2));
end

