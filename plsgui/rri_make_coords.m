function coords = rri_make_coords(dataset,thresh_factor)
%
%  Usage: coords = rri_make_coords(dataset,threshold)
%
%	This script determine index brain voxels from the dataset by 
%	thresholding.  Brain voxel is defined as a voxel that has 
%	scanned values higher than the threshold for all scans.
%
%	dataset:  a 2D matrix represents all voxels (column) in the
%		  volume across different scans (row)
%
%       thresh_factor:  (optional) the factor of threshold to define
%		  the brain voxels.  The threshold, which different 
%		  for each scan, is defined as
%                     (1 / thresh_factor) * max(dataset(i,:))
%		  DEFAULT: thresh_factor = 7
%
%	coords:   the index of dataset corresponding the brain voxels
%
%  Example:  dataset = gen_dataset('I_*.img');
%            coords = make_coords(dataset);
%            datamat = dataset(:,coords);
%            clear dataset;
%            n_datamat = norm_datamat(datamat);
%

if ~exist('thresh_factor','var')
  thresh_factor = 7;
end


[num_scans num_voxels] = size(dataset); 
nonbrain_coords = zeros(1,num_voxels);
for i=1:num_scans,
   scan_threshold = max(dataset(i,:)) / thresh_factor;

   idx = find(dataset(i,:) <= scan_threshold);
   nonbrain_coords(idx) = 1; 
end
coords = find(nonbrain_coords == 0);

