function get_cluster_info(report_prefix, PLSResultFile, ...
		is_bs, LV, min_size, min_dist, threshold, threshold2, ...
		peak_thresh, peak_thresh2)


      try
         warning off;
         load(PLSResultFile, 'create_ver', 'method', 'SessionProfiles', 'session_files_timestamp', 'datamat_files_timestamp', 'singleprecision');
         warning on;
      catch
         error('Can not open file');
      end

      if exist('create_ver','var') & exist('method','var') & ...
	method >=3 & method <=5 & ...
	str2num(create_ver) > 5.0908261 & str2num(create_ver) < 5.0910111

         error('This result was created by a problematic PLSgui version, please re-run the analysis. Sorry for the inconvenience!');
      end

      rri_changepath('fmriresult');

      v7 = version;
      if exist('singleprecision','var') & singleprecision & str2num(v7(1))<7
         error('MATLAB Version 7 (R14) above must be used.');
      end

      warning off
      subj_name = {};
      try
         load(PLSResultFile,'subj_name');
      catch
         error('Can not open file');
      end

      warning on


   load(PLSResultFile);
   rri_changepath('fmriresult');

   if exist('result','var')
      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end

      brainlv = result.u;
   end

   if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
   end



   if (~is_bs)
      data = brainlv(:,LV);
   else
      if isempty(boot_result)
         error('There is no bootstrap ratio in the result.');
      end

      data = boot_result.compare_brain(:,LV);
   end

   if isempty(threshold)
      if (~is_bs)
         threshold = (abs(max(data)) + abs(min(data))) / 6;
      else
         threshold = abs(percentile(data, 95));
      end

      if max(data) < threshold
         threshold = max(data);
      end
   end

   if isempty(threshold2)
      threshold2 = -threshold;

      if min(data) > threshold2
         threshold2 = min(data);
      end
   end

   if isempty(peak_thresh)
      peak_thresh = threshold;
   end

   if isempty(peak_thresh2)
      peak_thresh2 = threshold2;
   end



   cluster_info = [];

   
   %  extract the brain LV data or Bootstrap Ratio
   %

   lv_idx = LV;
%   st_dims
   win_size = st_win_size;
   voxel_size = st_voxel_size;
%   st_origin

   if isempty(st_origin) | all(st_origin == 0)

      if all(st_dims == [40 48 1 34]) & all(st_voxel_size == [4 4 4])
         st_origin = [20 29 12];
      elseif all(st_dims == [91 109 1 91]) & all(st_voxel_size == [2 2 2])
         st_origin = [46 64 37];
      else
         % according to SPM: if the origin field contains 0, then the origin is
         % assumed to be at the center of the volume.
         %
         st_origin = floor((dims([1 2 4])+1)/2);
         % st_origin = round(st_dims([1 2 4])/2);
      end;
   end;

   if (~is_bs),
      std_ratio = [];
   else
      curr_bs_ratio = data;
      curr_bs_ratio(isnan(curr_bs_ratio)) = 0;

      % avoid the outliers
      idx = find(abs(curr_bs_ratio) < std(curr_bs_ratio) * 5); 
      std_ratio = std(curr_bs_ratio(idx));
   end;

   %  extract voxels that have values above the threshold
   %
   pos_active_list = cell(1,win_size);
   neg_active_list = cell(1,win_size);
   for i=1:win_size,
      voxels = data(i:win_size:end);

      pos_active_voxel_idx = find(voxels > threshold);
      pos_active_voxels = voxels(pos_active_voxel_idx);

      neg_active_voxel_idx = find(voxels < threshold2);
      neg_active_voxels = voxels(neg_active_voxel_idx);

      [dummy_voxels, sorted_order] = sort(pos_active_voxels);
      sorted_order = sorted_order(end:-1:1);
      pos_active_list{i}.voxels = pos_active_voxels(sorted_order)';
      pos_active_list{i}.coords = st_coords(pos_active_voxel_idx(sorted_order));

      [dummy_voxels, sorted_order] = sort(neg_active_voxels);
      neg_active_list{i}.voxels = neg_active_voxels(sorted_order)';
      neg_active_list{i}.coords = st_coords(neg_active_voxel_idx(sorted_order));
   end;


   %  now compute the cluster information of the active voxels
   %
   cluster_info.source = PLSResultFile;
   cluster_info.min_size = min_size;
   cluster_info.min_dist = min_dist;
   cluster_info.threshold = threshold;
   cluster_info.threshold2 = threshold2;
   cluster_info.peak_thresh = peak_thresh;
   cluster_info.peak_thresh2 = peak_thresh2;
   cluster_info.std_ratio = std_ratio;
   cluster_info.lv_idx = lv_idx;
   cluster_info.data = cell(1,win_size);

   for i=1:win_size
      pos_cluster = compute_cluster_stat(pos_active_list{i}, st_origin, ...
					voxel_size,st_dims,min_size,min_dist);
      neg_cluster = compute_cluster_stat(neg_active_list{i}, st_origin, ...
					voxel_size,st_dims,min_size,min_dist);

      %  Apply peak threshold here
      %
      peak_thresh_idx = find(pos_cluster.peak_values < peak_thresh);
      peak_thresh_id = pos_cluster.id(peak_thresh_idx);
      pos_cluster.id(peak_thresh_idx) = [];
      pos_cluster.size(peak_thresh_idx) = [];
      pos_cluster.peak_values(peak_thresh_idx) = [];
      pos_cluster.peak_coords(peak_thresh_idx) = [];
      pos_cluster.peak_xyz(peak_thresh_idx,:) = [];
      pos_cluster.peak_loc(peak_thresh_idx,:) = [];
      for pid = 1:length(peak_thresh_id)
         mask_idx = find( pos_cluster.mask == peak_thresh_id(pid) );
         pos_cluster.mask(mask_idx) = [];
         pos_cluster.idx(mask_idx) = [];
      end
      peak_thresh_idx = find(neg_cluster.peak_values > peak_thresh2);
      peak_thresh_id = neg_cluster.id(peak_thresh_idx);
      neg_cluster.id(peak_thresh_idx) = [];
      neg_cluster.size(peak_thresh_idx) = [];
      neg_cluster.peak_values(peak_thresh_idx) = [];
      neg_cluster.peak_coords(peak_thresh_idx) = [];
      neg_cluster.peak_xyz(peak_thresh_idx,:) = [];
      neg_cluster.peak_loc(peak_thresh_idx,:) = [];
      for pid = 1:length(peak_thresh_id)
         mask_idx = find( neg_cluster.mask == peak_thresh_id(pid) );
         neg_cluster.mask(mask_idx) = [];
         neg_cluster.idx(mask_idx) = [];
      end

      % put the positive and negative cluster info together
      %
      curr_cluster.id = [ pos_cluster.id -neg_cluster.id ];
      curr_cluster.size = [ pos_cluster.size neg_cluster.size ];
      curr_cluster.peak_values = ...
		   	[ pos_cluster.peak_values neg_cluster.peak_values ];
      curr_cluster.peak_coords = ...
			[ pos_cluster.peak_coords neg_cluster.peak_coords ];
      curr_cluster.peak_xyz = [ pos_cluster.peak_xyz; neg_cluster.peak_xyz ];
      curr_cluster.peak_loc = [ pos_cluster.peak_loc; neg_cluster.peak_loc ];
      curr_cluster.idx = [ pos_cluster.idx neg_cluster.idx ];
      curr_cluster.mask = [ pos_cluster.mask -neg_cluster.mask ];

      sort_by_cluster=[];
      for j=1:length(curr_cluster.id)
         sort_by_cluster = [sort_by_cluster find(curr_cluster.mask==curr_cluster.id(j))];
      end
      curr_cluster.idx = curr_cluster.idx(sort_by_cluster);
      curr_cluster.mask = curr_cluster.mask(sort_by_cluster);

      cluster_info.data{i} = curr_cluster;
   end;

   save_cluster_report(is_bs, cluster_info, PLSResultFile, report_prefix);

   return;					% get_cluster_info


%-------------------------------------------------------------------------
function [cluster_info] = compute_cluster_stat(active_list,st_origin, ...
					voxel_size,st_dims,min_size,min_dist),
%   
   num_active_voxels = length(active_list.voxels);

   mask = zeros(st_dims([1 2 4]));
   mask(active_list.coords) = -1;

   y_idx = repmat([1:st_dims(2)],1,st_dims(4)); 
   z_idx = repmat([1:st_dims(4)],st_dims(2),1); 

   coords = active_list.coords;
   cluster_id = zeros(1,num_active_voxels);
   cluster_size = zeros(1,num_active_voxels);
   for i=1:num_active_voxels,
       x = mod(coords(i)-1,st_dims(1)) + 1;
       col_idx = floor((coords(i)-x)/st_dims(1));
       y = y_idx(col_idx+1);
       z = z_idx(col_idx+1);

       [updated_mask,csize,same_clusters] = fillmask([x y z],i,mask);

       if ~isempty(updated_mask)
          cluster_id(i) = i;
          cluster_size(i) =  csize;
	  mask = updated_mask;

          if ~isempty(same_clusters)
	     same_clusters = [same_clusters i];
             min_cnt = min(cluster_id(same_clusters));
	     cluster_id(same_clusters) = min_cnt;
          end;
       end;
   end;

   %  Fix Wilkin's cluster report bug: in case of combination
   %  (i.e. cluster_id(i) ~= i), we should trace all the way
   %  to the min. cluster_id
   %
   for i=1:num_active_voxels
      y = cluster_id(i);

      if y ~= 0
         x = i;

         while x ~= y
            x = y;
            y = cluster_id(x);
         end

         cluster_id(i) = y;
      end
   end

   %  merge clusters when needed
   %
   active_voxels = find(mask > 0);
   active_clusters = [];
   for i=1:num_active_voxels,
      if (cluster_id(i) ~= 0),

         curr_cluster_id = i;
	 cluster_set = find(cluster_id == curr_cluster_id);
         total_cluster_size = sum(cluster_size(cluster_set));

	 cluster_id(cluster_set) = 0;
	 cluster_size(cluster_set) = 0;
         if (total_cluster_size >= min_size)
            active_clusters = [active_clusters curr_cluster_id];
	    cluster_id(curr_cluster_id) = curr_cluster_id;
   	    cluster_size(curr_cluster_id) = total_cluster_size;
         else
            curr_cluster_id = 0;
         end;

	 for j=1:length(cluster_set),
	    idx = find(mask(active_voxels) == cluster_set(j));
            mask(active_voxels(idx)) = curr_cluster_id;
         end;
      end;
   end;


   cluster_id = cluster_id(active_clusters);
   cluster_size = cluster_size(active_clusters);

   peak_values = active_list.voxels(cluster_id); peak_values(:)';
   peak_coords = active_list.coords(cluster_id); peak_coords(:)';

   [peak_xyz, peak_loc] = coords2xyz(peak_coords,st_origin,voxel_size,st_dims);
   mask_idx = find(mask > 0);
   mask_value = mask(mask_idx);

   %  combine clusters that are close together (i.e. their peaks are less
   %  than the distance specified by min_dist);
   %
   min_dist_sq = min_dist^2;
   num_clusters = length(cluster_id);
   is_not_merged = ones(1,num_clusters);
   for i=1:num_clusters-1,
     if (is_not_merged(i)),
        for j=i+1:num_clusters,
         if (is_not_merged(j)),
          dist = (peak_xyz(i,:) - peak_xyz(j,:)) .* voxel_size;
          if ((dist * dist') <= min_dist_sq),	   % cluster needed to be merged
	     cluster_size(i) = cluster_size(i)+cluster_size(j);
	     mask_value(find(mask_value==cluster_id(j))) = cluster_id(i);
	     is_not_merged(j) = 0;
          end;
         end
        end;
     end;
   end;


   %  setup the cluster record 
   %
   final_cluster_idx = find(is_not_merged == 1);
   cluster_info.id = cluster_id(final_cluster_idx);
   cluster_info.size = cluster_size(final_cluster_idx);
   cluster_info.peak_values = peak_values(final_cluster_idx);
   cluster_info.peak_coords = peak_coords(final_cluster_idx);
   cluster_info.peak_xyz = peak_xyz(final_cluster_idx,:);
   cluster_info.peak_loc = peak_loc(final_cluster_idx,:);
   cluster_info.idx = mask_idx(:)';
   cluster_info.mask = mask_value(:)';

   return;					% compute_cluster_stat


%-------------------------------------------------------------------------
%
function [updated_mask,c_size,same_clusters] = fillmask(xyz,cnt,initial_mask),
%   
   persistent mask
   persistent mask_dims
   persistent cluster_size
   persistent start_xzy
   persistent recursion_cnt
   persistent recursion_limit
   persistent combine_clusters

   updated_mask = []; 
   same_clusters = [];
   c_size = 0;

   if exist('initial_mask','var')  
      first_iteration = 1;
      mask = initial_mask;
      mask_dims = size(mask);
      cluster_size = 0;
      start_xyz = xyz;
      combine_clusters = [];
      recursion_cnt = 1;
      recursion_limit = get(0,'RecursionLimit');
   else
      recursion_cnt = recursion_cnt+1;
      first_iteration = 0;
   end;

   x=xyz(1); y=xyz(2); z=xyz(3);
   curr_voxel_value = mask(x,y,z);
   if (curr_voxel_value == 0 | curr_voxel_value == cnt)
      return;
   end;

   %  handle the missing voxels for the previous clusters due to 
   %  run out of stack space (i.e. recursive limitation)
   if (curr_voxel_value > 0)
      combine_clusters = [combine_clusters curr_voxel_value];
      return;
   end;						  
   
   mask(x,y,z) = cnt;
   cluster_size = cluster_size+1;

   if (recursion_cnt >= recursion_limit)
      return;					% too many recursion
   end;

   neighbor_voxels = [  x-1 y   z;   x+1 y   z;
			x   y-1 z;   x   y+1 z;
      			x   y   z-1; x   y   z+1 ];
   for i=1:size(neighbor_voxels,1), 
      % exclude points that are out of boundary
      %
      curr_xyz = neighbor_voxels(i,:);
      within_boundary = and(curr_xyz>=[1 1 1],curr_xyz<=mask_dims);
      if isempty(find(~within_boundary)),
	  fillmask(curr_xyz,cnt);
      end;
   end;

   if (first_iteration)			% done all recursive calls, setup
      if ~isempty(combine_clusters) 
          same_clusters = unique(combine_clusters);
      end;
      updated_mask = mask;		%   return values
      c_size = cluster_size;
   end;

   return;					% fillmask


%-------------------------------------------------------------------------
%
function [xyz, xyz_mm] = coords2xyz(coords, origin, voxel_size, dim);

   sa = [];   % getappdata(fig, 'sa');

   if isempty(sa)
      [xyz, xyz_mm] = rri_coord2xyz(coords, dim, origin, voxel_size);
   elseif sa
      origin = origin([3 1 2]);
      voxel_size = voxel_size([3 1 2]);
      [xyz, xyz_mm] = rri_coord2xyz(coords, dim, origin, voxel_size);
   else
      origin = origin([1 3 2]);
      voxel_size = voxel_size([1 3 2]);
      [xyz, xyz_mm] = rri_coord2xyz(coords, dim, origin, voxel_size);
   end

   return;

%
   if isempty(coords),
      xyz = [];
      xyz_mm = [];
      return;
   end;

   y_idx = repmat([1:st_dims(2)],1,st_dims(4)); 
   z_idx = repmat([1:st_dims(4)],st_dims(2),1); 
   
   x = mod(coords-1,st_dims(1)) + 1;
   col_idx = floor((coords-x)/st_dims(1));
%   y = st_dims(2) - y_idx(col_idx+1) + 1;
   y = y_idx(col_idx+1);
   z = z_idx(col_idx+1);

   xyz = [x(:) y(:) z(:)];

   xyz_offset = xyz - ones(length(x),1) * st_origin;
%   xyz_offset = [ x(:)-st_origin(1) ...
%		  (st_dims(2)-st_origin(2)+1)-y(:) ...
%	          z(:)-st_origin(3)];

   xyz_mm = xyz_offset * diag(voxel_size);

   return; 					% coords2xyz


%--------------------------------------------------------------------------
function  p_value = ratio2p(x,mu,sigma)

   p_value = (1 + erf((x - mu) / (sqrt(2)*sigma))) / 2;
   p_value = (1 - p_value) * 2;

   return; 						% ratio2p


%--------------------------------------------------------------------------
function  save_cluster_report(report_type, cluster_info, result_name, report_prefix)

   if (report_type == 0)		% BLV value report
      cluster_info.type = 'BLV Report';
   else
      cluster_info.type = 'Bootstrap Ratio Report';
   end;

   if findstr('BfMRIresult.mat', result_name)
      report_file = [report_prefix, '_BfMRIcluster.mat'];
   else
      report_file = [report_prefix, '_fMRIcluster.mat'];
   end
   
   try
      save (report_file, 'cluster_info', 'report_type' );
      disp(['File "', report_file, '" has been saved.']);
   catch
      error(['File "', report_file, '" can not be open to write.']);
   end;

   return; 					% save_cluster_report

