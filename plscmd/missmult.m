function [X]=missmult(A,B)
%[X]=missmult(A,B)
%This function determines the product of two matrices containing NaNs
%by finding X according to
%     X = A*B
%If there are columns in A or B that are pur missing values,
%then there will be entries in X that are missing too.
%
%The result is standardized, that is, corrected for the lower
%number of contributing terms.
%
%Missing elements should be denoted by 'NaN's

%INBOUNDS
%REALONLY  
  
%  if ( sum(isfinite(reshape(A,1,[])))<numel(A) | sum(isfinite(reshape(B,1,[])))<numel(B) ) 
   if ( sum(isfinite(A(:)))<length(A(:)) | sum(isfinite(B(:)))<length(B(:)) ) 

    [ia ja]=size(A);
    [ib jb]=size(B);
    X=zeros(ia,jb);
    
    one_arry=ones(ia,1);
    for col=1:jb,
      p=one_arry*B(:,col)';
      tmpMat=A.*p;
      X(:,col)=misssum(tmpMat')';
    end;
    
  else
    X = A*B;
  end
