% function rri_xcor
%  syntax:  outmat=rri_xcor(design,datamat)
%  Computes crosscorrelation of two matrices
%  Written by ARM 12-15-94


function[outmat]=rri_xcor(design,datamat,cormode)

if ~exist('cormode','var'), cormode=0; end;

[r c]=size(datamat);
[dr dc]=size(design);
  if r ~= dr
    error('Error in rri_xcor: input matrices must have same number of rows');
  end


  switch cormode
   case 0


avg=mean(datamat);
stdev=std(datamat);
checknan=find(stdev==0);

if (isempty(checknan)==0)
     datamat(:,checknan)=0;
     avg(checknan)=0;
     stdev(checknan)=1;
end %if

 for i=1:r
  datamat(i,:)=(datamat(i,:)-avg)./stdev;
 end

davg=mean(design);
dstdev=std(design);

checknan=find(dstdev==0);
if (isempty(checknan)==0)
     design(:,checknan)=0;
     davg(checknan)=0;
     dstdev(checknan)=1;
end %if

for i=1:dr
 design(i,:)=(design(i,:)-davg)./dstdev;
end

xprod=design'*datamat;
outmat=xprod./(r-1);



   case 2, % covariance

    avg = mean(datamat); % columnwise mean
    davg = mean(design);
    for i=1:r, datamat(i,:)=datamat(i,:)-avg; end    
    for i=1:dr, design(i,:)=design(i,:)-davg; end    
    xprod = design'*datamat;
    outmat = xprod./(r-1);

   case 4, % cosine angle

    stdev=std(datamat);
    checknan = find(stdev==0);     
    if (isempty(checknan)==0)
      datamat(:,checknan)=0;
      stdev(checknan)=1;
    end 
    
    % clean up columns with stdev=0 in design
    dstdev=std(design);    
    checknan = find(dstdev==0);
    if (isempty(checknan)==0)
      design(:,checknan)=0;
      dstdev(checknan)=1;
    end 
    
    for i=1:r, datamat(i,:)= datamat(i,:)./stdev; end    
    for i=1:dr, design(i,:)= design(i,:)./dstdev; end    
    outmat = design'*datamat;

   case 6, % dot product
    outmat = design'*datamat;

  end

