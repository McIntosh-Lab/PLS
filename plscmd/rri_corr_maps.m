function maps=rri_corr_maps(behav,datamat,n,k,cormode);

% creates image-wide correlation map for k scans with behavior vector , or
% whatever is in the behav variable (eg. seed voxel)
%
% written 4.12.98 ARM
% syntax maps=rri_corr_maps(behav,datamat,n,k);

if ~exist('cormode','var'), cormode = 0; end

maps=[];

	for i=1:k
		temp=[];

		temp=rri_xcor((behav(1+(n* (i-1) ):n*i,:)),(datamat(1+(n*(i-1)):n*i,:)),cormode);

		maps=[maps;temp];

	end

%disp(' ')
%disp('Program complete')
