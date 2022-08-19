function maps=rri_corr_maps_notall(behav,datamat,n,bscans,cormode)
% syntax maps=rri_corr_maps_notall(behav,datamat,n,bscans)
%computes brain-behavior correlations on a subset of scans
%The scan numbers containing behavior measures should be stored as a vector
%in 'bscans'

if ~exist('cormode','var'), cormode = 0; end

maps=[];

for i=bscans
   temp=[];
   temp=rri_xcor((behav(1+(n*(i-1) ):n*i,:)),(datamat(1+(n*(i-1) ):n*i,:)),cormode);
   maps=[maps;temp];

end
