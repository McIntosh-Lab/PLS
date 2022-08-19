function [outmat] = missnk_rri_xcor(design,datamat,cormode)
%    syntax:  outmat = rri_xcor(design,datamat,cormode)
%    Computes crosscorrelation between columns of 2 matrices
%    Written by ARM 12-15-94, edited by NK to handle missing data and diffrent corr options
%
% INPUTS:
%          design, datamat - two input matrices with same number of rows
%          cormode - correaltion mode determines type of correlations to analyze.
%                     0 --> (default) Pearson correlation
%                     1 --> Pearson correlation which handles missing data (NaN's)
%                     2 --> covaraince no missing data
%                     3 --> covariance with missing data
%                     4 --> cosine angle no missing data
%                     5 --> cosine angle with missing data
%                     6 --> dot product no missing data
%                     7 --> dot product with missing data
% function will check for NaN's or Inf's in two input matrices and switch to appropriate implementation which handles missing data

  % defualt is usual Pearson correlation
  if ~exist('cormode','var'), cormode = 0; end
  
  % If some data are NaN or Inf, then we must use 
  % miss version of the requested cormode
  % isfinite function takes care of both NaN's and Inf's
  if (  sum(isfinite(design(:)))<length(design(:)) |  sum(isfinite(datamat(:)))<length(datamat(:)) )
     warning('In missnk_rri_xcorr: NaN or Inf found in one or both input matrices. Using slow, implementation for missing data');
    switch(cormode)
     case 0, cormode = 1;
     case 2, cormode = 3;
     case 4, cormode = 5;
     case 6, cormode = 7;
    end
  end
 
  % clean up columns with stdev=0 in booth design and datamat
  [r c]=size(datamat);
  [dr dc]=size(design);    
  if r ~= dr
    error('Error in rri_xcor: input matrices must have same number of rows');
  end
      
  switch cormode
   case 0
    
    % clean up columns with stdev=0 in datamat
    avg=mean(datamat); % columnwise mean
    stdev=std(datamat);
    checknan=find(stdev==0);     
    if (isempty(checknan)==0)
      datamat(:,checknan)=0;
      avg(checknan)=0;
      stdev(checknan)=1;
    end 
    
    % clean up columns with stdev=0 in design
    davg=mean(design);
    dstdev=std(design);    
    checknan=find(dstdev==0);
    if (isempty(checknan)==0)
      design(:,checknan)=0;
      davg(checknan)=0;
      dstdev(checknan)=1;
    end 
    
    for i=1:r, datamat(i,:)=(datamat(i,:)-avg)./stdev; end    
    for i=1:dr, design(i,:)=(design(i,:)-davg)./dstdev; end    
    xprod = design'*datamat;
    outmat = xprod./(r-1);
    
   case 1, % Pearson correaltion with missing data
    % clean up columns with stdev=0 in datamat
    avg = missnk_mean(datamat,1); % columnwise mean
    stdev = missstd(datamat);
    checknan = find(stdev==0);     
    if (isempty(checknan)==0)
      datamat(:,checknan)=0;
      avg(checknan)=0;
      stdev(checknan)=1;
    end 
    
    % clean up columns with stdev=0 in design
    davg = missnk_mean(design,1);
    dstdev = missstd(design);    
    checknan = find(dstdev==0);
    if (isempty(checknan)==0)
      design(:,checknan)=0;
      davg(checknan)=0;
      dstdev(checknan)=1;
    end 
    
    for i=1:r, datamat(i,:)=(datamat(i,:)-avg)./stdev; end    
    for i=1:dr, design(i,:)=(design(i,:)-davg)./dstdev; end    
    xprod = missmult(design',datamat);
    outmat = xprod./(r-1);
    
   case 2, % covariance, no missing data
    avg = mean(datamat); % columnwise mean
    davg = mean(design);
    for i=1:r, datamat(i,:)=datamat(i,:)-avg; end    
    for i=1:dr, design(i,:)=design(i,:)-davg; end    
    xprod = design'*datamat;
    outmat = xprod./(r-1);
    
   case 3, % covariance, with missing data
    avg = missnk_mean(datamat,1); % columnwise mean
    davg = missnk_mean(design,1);
    for i=1:r, datamat(i,:)=datamat(i,:)-avg; end    
    for i=1:dr, design(i,:)=design(i,:)-davg; end    
    xprod = missmult(design',datamat);
    outmat = xprod./(r-1);
    
   case 4, % cosine angle, no missing data
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
    
   case 5, % cosine angle, with missing data
    stdev = missstd(datamat);
    checknan = find(stdev==0);     
    if (isempty(checknan)==0)
      datamat(:,checknan)=0;
      stdev(checknan)=1;
    end 
    
    % clean up columns with stdev=0 in design
    dstdev = missstd(design);    
    checknan = find(dstdev==0);
    if (isempty(checknan)==0)
      design(:,checknan)=0;
      dstdev(checknan)=1;
    end 
    
    for i=1:r, datamat(i,:)= datamat(i,:)./stdev; end    
    for i=1:dr, design(i,:)= design(i,:)./dstdev; end    
    outmat = missmult(design',datamat);
    
   case 6, % dot product, no missing data
    outmat = design'*datamat;
   case 7, % dot product, with missing data
    outmat = missmult(design',datamat);
  end
    
