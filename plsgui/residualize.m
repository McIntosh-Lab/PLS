function residdata=residualize(xvecs,datamat)
%syntax residdata=residualize(xvecs,datamat)
%
% residualizes a set of values (datamat) on a set of predictors (xvecs)
% using linear regression.  Assumes model has an intercept
% Regression modeled after example in MATLAB User's guide page 2-37
%
% 3-16-97 ARM


[r c]=size(datamat);
%disp('Begining regression')

intercept=ones(r,1);

beta=[double(intercept) double(xvecs)] \ double(datamat);

pred=[double(intercept) double(xvecs)]*beta;
%disp('Obtaining residuals')

residdata=datamat-pred;

%disp(' ')
%disp('Done')
