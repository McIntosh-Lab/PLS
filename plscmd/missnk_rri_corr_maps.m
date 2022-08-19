function maps=rri_corr_maps(behav,datamat,n,k,cormode);

% creates image-wide correlation map for k scans with behavior vector , or
% whatever is in the behav variable (eg. seed voxel)
%
% written 4.12.98 ARM
% syntax maps=rri_corr_maps(behav,datamat,n,k);

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

	for i=1:k
		temp=[];

		temp=missnk_rri_xcor((behav(1+(n* (i-1) ):n*i,:)),(datamat(1+(n*(i-1)):n*i,:)),cormode);

		maps=[maps;temp];

	end

%disp(' ')
%disp('Program complete')
