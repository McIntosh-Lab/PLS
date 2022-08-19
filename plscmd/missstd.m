function ms=missstd(X)
%[ms]=missstd(X)
%Calculates the standard deviation of the columns of the
%matrix X, where X may have missing elements (NaN's).

[mv]=missvar(X);

ms=sqrt(mv);

