function mv=missvar(X)
%[mv]=missvar(X)
%This function calculates the variance of the columns of X.
%X may hold missing elements (NaN's)
%
%C. A. Andersson
%KVL

%Insert zeros for missing, correct afterwards
missidx = isnan(X);
i = find(missidx);
mn=missmean(X);
X=X-ones(size(X,1),1)*mn;
X(i) = 0;

%Find the number of real(non-missing objects)
if min(size(X))==1,
   n_real=length(X)-sum(missidx)-1;
   weight=length(X);
else
   n_real=size(X,1)-sum(missidx)-1;
   weight=size(X,1);
end

i=find(n_real==0);
if isempty(i) %All values are real and can be corrected
   mv=sum(X.*X)./n_real;
else %There are columns with all missing, insert missing
   n_real(i)=1;
   mv=sum(X.*X)./n_real;
   mv(i)=i + NaN;
end

