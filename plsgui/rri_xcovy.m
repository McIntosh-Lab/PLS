% function rri_xcovy
%  syntax:  function[outmat]=rri_xcovy(design,datamat)
%  Computes crosscovariance of two matrices
%  Written by ARM 12-15-94


function[outmat]=rri_xcovy(design,datamat)

[r c]=size(datamat);

avg=mean(datamat);
zdevmat=zeros(size(datamat));
 for i=1:r
  zdevmat(i,:)=(datamat(i,:)-avg);
 end

[dr dc]=size(design);

davg=mean(design);

zdesign=zeros(size(design));

for i=1:dr
 zdesign(i,:)=(design(i,:)-davg);
end

xprod=zdesign'*zdevmat;
outmat=xprod./(r-1);
