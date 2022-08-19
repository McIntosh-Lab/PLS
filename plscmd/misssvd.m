function [U,S,V]=misssvd(X,defp)
%[U,S,V]=misssvd(X)
%
% 'misssvd.m'
% $ Version 0.01 $ Date 10. July 1997 $ Not compiled $
%
% This algorithm requires the presence of:
% 'gsm.m' 'missmean.m'
%
% Copyright
% Claus A. Andersson 1995-
% claus@andersson.dk
%
% ----------------------------------------------------
%        Find eigenvectors according to SVD
% ----------------------------------------------------
%
% [U S V]=misssvd(X);
% [U S V]=misssvd(X,0);
%
% U, S and V are found so that X = U*S*V', s.t ||U||=||V||=I, ||S|| is diagonal
%
% X        : The matrix to be decomposed. If the additional argument '0' is
%            used the U,S,V model is truncated corresponding to the rank of X.
%
% It handles missing values NaNs (very dispersed, less than 15%)

% scalar ConvLim WarnLim ItMax a b i

ConvLim=1e-12;
WarnLim=1e-4;
ConvLimMiss=100*ConvLim;
ItMax=100;
defp=0;
if ~exist('defp') | isempty(defp) | defp~=0,
   defp=1;
end;

[a b]=size(X);

MissingExist = any(~isfinite(X)); % NK fix to handle both NaN's and Inf's

if ~MissingExist, %no missing
   if defp==0,
      [U,S,V]=svd(X,0);
   else
      [U,S,V]=svd(X);
   end;
else %Handles missing data
   MissIdx=find(isnan(X));
   [i j]=find(isnan(X));
   mnx=missmean(X)/3;
   mny=missmean(X')/3;
   n=size(i,1);
   for k=1:n,
      i_=i(k);
      j_=j(k);
      X(i_,j_) = mny(i_) + mnx(j_);
   end;
   mnz=(missmean(mnx)+missmean(mny))/2;
   p=find(isnan(X));
   X(p)=mnz;
   if defp==0,
      [U,S,V]=svd(X,0);
   else
      [U,S,V]=svd(X);
   end;
   Xm=U*S*V';
   X(MissIdx)=Xm(MissIdx);
   ssmisold=sum(sum( Xm(MissIdx).^2 ));
   sstotold=sum(sum( X.^2 ));
   ssrealold=sstotold-ssmisold;
   iterate=1;
   while iterate
      if defp==0,
         [U,S,V]=svd(X,0);
      else
         [U,S,V]=svd(X);
      end;
      Xm=U*S*V';
      X(MissIdx)=Xm(MissIdx);
      ssmis=sum(sum( Xm(MissIdx).^2 ));
      sstot=sum(sum( X.^2 ));
      ssreal=sstot-ssmis;
      if abs(ssreal-ssrealold)<ConvLim*ssrealold & abs(ssmis-ssmisold)<ConvLimMiss*ssmisold,
         iterate=0;
      end;
      ssrealold=ssreal;
      ssmisold=ssmis;
   end;
end;

