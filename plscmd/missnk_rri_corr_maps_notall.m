function maps=rri_corr_maps_notall(behav,datamat,n,bscans,cormode)
% syntax maps=rri_corr_maps_notall(behav,datamat,n,bscans)
%computes brain-behavior correlations on a subset of scans
%The scan numbers containing behavior measures should be stored as a vector
%in 'bscans'

if ~exist('cormode','var'), cormode = 0; end

  % If some data are NaN or Inf, then we must use 
  % miss version of the requested cormode
  if length(find(isfinite(behav(:))))<length(behav(:)) | ...
	length(find(isnan(datamat(:))))<length(datamat(:))
    switch(cormode)
     case 0, cormode = 1;
     case 2, cormode = 3;
     case 4, cormode = 5;
     case 6, cormode = 7;
    end
  end

maps=[];

for i=bscans
   temp=[];
   temp=missnk_rri_xcor((behav(1+(n*(i-1) ):n*i,:)),(datamat(1+(n*(i-1) ):n*i,:)),cormode);
   maps=[maps;temp];

end
