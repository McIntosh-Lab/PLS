function mm=missmean(X)
%[mm]=missmean(X)
%
%This function calculates the mean of a matrix X.
%X may hold missing elements denoted by NaN's which
%are ignored (weighted to zero).
%
%Check that for no column of X, all values are missing
%
%C. A. Andersson
%KVL

%Insert zeros for missing, correct afterwards
missidx = isnan(X);
i = find(missidx);
X(i) = 0;

%Find the number of real(non-missing objects)
if min(size(X))==1,
   n_real=length(X)-sum(missidx);
else
   n_real=size(X,1)-sum(missidx);
end

i=find(n_real==0);
if isempty(i) %All values are real and can be corrected
   mm=sum(X)./n_real;
else %There are columns with all missing, insert missing
   n_real(i)=1;
   mm=sum(X)./n_real;
   mm(i)=i + NaN;
end

