function mm = nk_missmean(X,dim)
% Usage [mm] = nk_missmean(X,dim)
%
% This function calculates the mean of a matrix X along dimension dim.
% If dim is not specified then it defaults to dim=1.
% X may hold missing elements denoted by NaN's which
% are ignored (weighted to zero).
%
% Check that for no column of X, all values are missing
%
% C. A. Andersson
%KVL
  
%%%% NK: rework to allow meaning anlong any dimension in the same way as standard mean function

% If X is a row vector, then reshape- this is to be consistent with standard mean function
if size(X,1)==1 & ndims(X)==2
  X = X(:);
end
% Default is to calculate mean along first dimension
if ~exist('dim','var')
  dim = 1;
end

% find NaN's
missidx = isnan(X);

% Insert zeros for missing, correct afterwards
X(find(missidx)) = 0;

% Find the number of real (non-missing objects)
n_real = size(X,dim) - sum(missidx,dim); 

bad_cols = find(n_real==0); % find columns with all values missing

if isempty(bad_cols) % all values are real and can be corrected
   mm = sum(X,dim) ./ n_real;
else % there are columns with all missing, for those columns result must be NaN
   n_real(bad_cols)=1;
   mm = sum(X,dim) ./ n_real;
   mm(bad_cols) = bad_cols + NaN;
end
