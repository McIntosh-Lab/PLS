function get_cluster_info(report_prefix, PLSResultFile, ...
		is_bs, LV, min_size, min_dist, threshold, threshold2, ...
		peak_thresh, peak_thresh2)


      try
         warning off;
         load(PLSResultFile, 'datamat_files', 'datamat_files_timestamp', 'singleprecision');
         warning on;
      catch
         error('Can not open file');
      end

      rri_changepath('petresult');

      v7 = version;
      if exist('singleprecision','var') & singleprecision & str2num(v7(1))<7
         error('MATLAB Version 7 (R14) above must be used.');
      end


   load(PLSResultFile);
   rri_changepath('petresult');

   if exist('result','var')
      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end

      brainlv = result.u * diag(result.s);
   else
      brainlv = brainlv * diag(s);
   end



   if (~is_bs)
      data = brainlv(:,LV);
   else
      if isempty(boot_result)
         error('There is no bootstrap ratio in the result.');
      end

      data = boot_result.compare(:,LV);
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
   st_dims = dims;
   win_size = 1;
%   voxel_size
   st_coords = newcoords;
   st_origin = origin;

   if isempty(st_origin)
      st_origin = round(st_dims([1 2 4])/2);
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


%   old_pointer = get(gcf,'Pointer');
%   set(gcf,'Pointer','watch');


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

   % calculate voxel mean for the subjects in a task/scan
   %
   datamat_file_lst = datamat_files;
   datamat_file = load(datamat_file_lst{1},'coords','datamat','session_info');



   cond_selection = [];

   warning off;
   try
      load(PLSResultFile,'cond_selection');
   catch
   end
   warning on;

   num_subj = datamat_file.session_info.num_subjects;

   if isempty(cond_selection)
      num_cond = datamat_file.session_info.num_conditions;
      cond_selection = ones(1,num_cond);
   else
      num_cond = sum(cond_selection);
   end

   selected_subjects = ones(num_subj,1);
   bmask = selected_subjects * cond_selection;
   bmask = find(bmask(:));
   datamat_file.datamat = datamat_file.datamat(bmask,:);

   % coord is the coord of all active voxels
   % peak_coord is the coord of peak active voxels
   %
   coord = curr_cluster.idx;
   peak_coord = curr_cluster.peak_coords;

   if isempty(coord)
      return;
   end

   % calculate index of coord & peak_coord
   %
   for i=1:length(coord)
      coord_idx(i) = find(datamat_file.coords == coord(i));
   end

   % for i=1:length(peak_coord)
   %    peak_coord_idx(i) = find(datamat_file.coords == peak_coord(i));
   % end

   % find location of peak_coord_idx inside coord_idx
   %
   % [tmp,peak_idx] = intersect(coord,peak_coord);

   for i=1:length(peak_coord)
      peak_idx(i) = find(peak_coord(i) == coord);
   end


   % calc intensity
   %
   for v = 1:length(coord_idx)			% traverse active voxels
      for k = 1:num_cond			% cond
         for n = 1:num_subj			% subj
            j = n+(k-1)*num_subj;		% row number in datamat
            intensity(v,k,n) = ...
		datamat_file.datamat(j, coord_idx(v));
         end
      end
   end

%   set(gcf,'Pointer',old_pointer);

   % voxel_means are the mean for subjects in a task/scan
   % voxel_means_avg are mean across all scan, for display
   %
   voxel_means = mean(intensity,3);
   voxel_means = voxel_means([peak_idx],:);

   voxel_means_avg = mean(voxel_means,2);
%   voxel_means_avg = voxel_means_avg';
%   voxel_means_avg = voxel_means_avg([peak_idx])';

   cluster_info.voxel_means = voxel_means;
   cluster_info.voxel_means_avg = voxel_means_avg;

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


%-------------------------------------------------------------------------
function cluster_fig = show_cluster_report(cluster_info,report_type,mainfig),
%
   cluster_fig = [];

   isbsr = getappdata(mainfig,'ViewBootstrapRatio');
   curr_lv_idx = getappdata(mainfig,'CurrLVIdx');
   cluster_blv = getappdata(mainfig,'cluster_blv');
   cluster_bsr = getappdata(mainfig,'cluster_bsr');

   if isbsr
      cluster_bsr{curr_lv_idx} = cluster_info;
      setappdata(mainfig,'cluster_bsr',cluster_bsr);
   else
      cluster_blv{curr_lv_idx} = cluster_info;
      setappdata(mainfig,'cluster_blv',cluster_blv);
   end

   cluster_fig = create_report_figure(report_type,mainfig);
   setup_cluster_data_idx(cluster_info);

   setup_header;
   setup_footer;

   show_report_page(1);

   return; 					% show_cluster_report


%-------------------------------------------------------------------------
function show_report_page(page_num),
%
   report_type = getappdata(gcf,'ReportType');
   num_rows = getappdata(gcf,'NumRows');
   top_margin = getappdata(gcf,'TopMargin');
   line_height = getappdata(gcf,'LineHeight');
   cluster_info = getappdata(gcf,'ClusterInfo');
   cluster_data_idx = getappdata(gcf,'ClusterDataIdx');
   standard_text_obj = getappdata(gcf,'StandardTextObj');
   h_list = getappdata(gcf,'HdlList');

   axes_h = findobj(gcf,'Tag','ClusterReportAxes');
   axes_pos = get(axes_h,'Position');
   first_row_pos = 1 - top_margin;
   last_row_pos = first_row_pos - (num_rows-1)*line_height;

   if isempty(cluster_data_idx)
      return;
   end;

   show_page_keys(page_num);

   %  display the cluster information for the current page
   %
   start_row = num_rows * (page_num - 1) + 1;
   if (cluster_data_idx(1,start_row) == 0),	% the first row is empty
	start_row = start_row - 1;		
	num_rows = num_rows - 1;
   end;

   v_pos = [first_row_pos:-line_height:last_row_pos];

   if (report_type == 0)		% BLV value report
      h_pos = [0.06 0.18 0.28 0.44 0.71 0.88];
      h_pvalue_pos = 0;
   else					% Bootstrap ratio report
      h_pos = [0.06 0.18 0.28 0.44 0.67 0.88];
      h_pvalue_pos = 0.75;
   end;

   delete(h_list);
   h_list = [];
   last_row = min(size(cluster_data_idx,2),start_row+num_rows-1);
   for idx=start_row:last_row,

      v_idx = idx-start_row+1;
      cluster_id  = cluster_data_idx(1,idx);
      if (cluster_id ~= 0),
         cluster_lag = cluster_data_idx(2,idx);
         cluster_idx = cluster_data_idx(3,idx);
         c_data = cluster_info.data{cluster_lag};

         h = copyobj_legacy(standard_text_obj,axes_h);			% cluster # 
         cluster_num = sprintf('%3d',cluster_id);
         set(h, 'String',cluster_num, ...
		'Position',[h_pos(1) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];

         h = copyobj_legacy(standard_text_obj,axes_h);			% voxel mean
         voxel_mean_str = sprintf('%6.2f',cluster_info.voxel_means_avg(cluster_idx));
         set(h, 'String',voxel_mean_str, ...
		'Position',[h_pos(2) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];

	 h = copyobj_legacy(standard_text_obj,axes_h);			% peak xyz
         peak_xyz_str = sprintf('[%3d %3d %3d]',c_data.peak_xyz(cluster_idx,:));
	 set(h, 'String',peak_xyz_str, ...
		'Position',[h_pos(3) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];

	 h = copyobj_legacy(standard_text_obj,axes_h);			% peak loc
         peak_loc_str = sprintf('[%6.1f %6.1f %6.1f]', ...
					c_data.peak_loc(cluster_idx,:));
	 set(h, 'String',peak_loc_str, ...
		'Position',[h_pos(4) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];

	 h = copyobj_legacy(standard_text_obj,axes_h);			% peak value
         peak_value_str = sprintf('%8.4f',c_data.peak_values(cluster_idx));
	 set(h, 'String',peak_value_str, ...
		'Position',[h_pos(5) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];

	 if (h_pvalue_pos ~= 0)
	    h = copyobj_legacy(standard_text_obj,axes_h);		% P value
	    p_value = ratio2p(abs(c_data.peak_values(cluster_idx)), ...
						0,1 );
            p_value_str = sprintf('(%6.4f)',p_value);
	    set(h, 'String',p_value_str, ...
		'Position',[h_pvalue_pos v_pos(v_idx) 0], ...
		'Visible','on'); 
	    h_list = [h_list h];
         end;

	 h = copyobj_legacy(standard_text_obj,axes_h);			% cluster size
         size_str = sprintf('%4d',c_data.size(cluster_idx));
	 set(h, 'String',size_str, ...
		'Position',[h_pos(6) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];
      end;
	
   end;

   setappdata(gcf,'CurrPage',page_num);
   setappdata(gcf,'HdlList',h_list);

   return; 					% show_report_page


%--------------------------------------------------------------------------
function  save_cluster_report(report_type, cluster_info, result_name, report_prefix)

   if (report_type == 0)		% BLV value report
      cluster_info.type = 'BLV Report';
   else
      cluster_info.type = 'Bootstrap Ratio Report';
   end;

   report_file = [report_prefix, '_PETcluster.mat'];

   try
      save (report_file, 'cluster_info', 'report_type' );
      disp(['File "', report_file, '" has been saved.']);
   catch
      error(['File "', report_file, '" can not be open to write.']);
   end;

   return; 					% save_cluster_report


%--------------------------------------------------------------------------
function  save_cluster_txt()

   [filename, pathname] = ...
           rri_selectfile('*_PETcluster.txt','Save to .txt file');

   if ischar(filename) & (length(filename)<9 | isempty(findstr(lower(filename),'_petcluster.txt')))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_PETcluster.txt'];
   end
   
   if isequal(filename,0)
         status = 0;
         return;
   end;
   report_file = fullfile(pathname,filename);

   fid = fopen(report_file, 'wt');

   if fid == -1
      msg = ['File ', filename, ' can not be open to write'];
      msgbox(msg, 'Error');
      return;
   end

   cluster_info = getappdata(gcf,'ClusterInfo');
   cluster_data_idx = getappdata(gcf, 'ClusterDataIdx');
   report_type = getappdata(gcf,'ReportType');

   str = sprintf('Clu#\tV_Mean\tX\tY\tZ\tX(mm)\tY(mm)\tZ(mm)\t');

   if report_type
      str = [str sprintf('BSR\tAppro.P\tClu_Size(voxels)\n')];
      str = [str '--------------------------------------------------------'];
      str = [str '----------------------------------------'];
   else
      str = [str sprintf('BLV\tClu_Size(voxels)\n')];
      str = [str '--------------------------------------------------------'];
      str = [str '--------------------------------'];
   end

   fprintf(fid, '\n%s\n\n', str);

   for idx = 1 : size(cluster_data_idx, 2)
      cluster_id = cluster_data_idx(1, idx);

      if cluster_id ~= 0
         cluster_lag = cluster_data_idx(2, idx);
         cluster_idx = cluster_data_idx(3, idx);
         c_data = cluster_info.data{cluster_lag};

         cluster_num = sprintf('%d\t', cluster_id);
         voxel_mean_str = ...
		sprintf('%.2f\t',cluster_info.voxel_means_avg(cluster_idx));
         peak_xyz_str = ...
		sprintf('%d\t%d\t%d\t',c_data.peak_xyz(cluster_idx,:));
         peak_loc_str = ...
		sprintf('%.1f\t%.1f\t%.1f\t',c_data.peak_loc(cluster_idx,:));
         peak_value_str = sprintf('%.4f\t',c_data.peak_values(cluster_idx));

         if report_type
            p_value = ...
		ratio2p(abs(c_data.peak_values(cluster_idx)), 0, ...
			1);
            p_value_str = sprintf('%.4f\t',p_value);
         else
            p_value_str = '';
         end

         size_str = sprintf('%d\n',c_data.size(cluster_idx));

         str = [cluster_num,voxel_mean_str,peak_xyz_str,peak_loc_str];
         str = [str peak_value_str,p_value_str,size_str];
         fprintf(fid, '%s', str);
      end
   end

   %  display the footer
   %
   source_file = cluster_info.source;
   source_line = sprintf('Source: %s',source_file);

   lv_str = sprintf('LV Idx: %d',cluster_info.lv_idx);
   thresh_str = sprintf('Pos.Thresh: %2.4f',cluster_info.threshold);
   thresh_str2 = sprintf('Neg.Thresh: %2.4f',cluster_info.threshold2);
   peak_thresh_str = sprintf('Pos.Peak Thresh: %2.4f',cluster_info.peak_thresh);
   peak_thresh_str2 = sprintf('Neg.Peak Thresh: %2.4f',cluster_info.peak_thresh2);

   min_size_str = sprintf('Min Size: %d(voxels)',cluster_info.min_size);
   min_dist_str = sprintf('Min Distance: %3.1fmm ',cluster_info.min_dist);
   parameters_line = sprintf('%s, %s, %s, %s\n%s, %s, %s', ...
				lv_str,thresh_str,thresh_str2,min_size_str,peak_thresh_str,peak_thresh_str2,min_dist_str);

   if report_type
      str = ['--------------------------------------------------------'];
      str = [str '----------------------------------------'];
      str = [str sprintf('\n%s\n%s',source_line,parameters_line)];
   else
      str = ['--------------------------------------------------------'];
      str = [str '--------------------------------'];
      str = [str sprintf('\n%s\n%s',source_line,parameters_line)];
   end

   fprintf(fid, '\n%s\n\n', str);

   fclose(fid);

   msg = ['File ', filename, ' has been saved'];
   msgbox(msg, 'Info');

   return; 					% save_cluster_txt


%--------------------------------------------------------------------------
function  save_peak_location()

   result_file = get(findobj(getappdata(gcf,'mainfig'),'tag','ResultFile'),'UserData');
   cluster_info = getappdata(gcf,'ClusterInfo');

   xyz = cluster_info.data{1}.peak_xyz;
   xyz = double(xyz2xyzmm(xyz, result_file));

   [filename, pathname] = ...
           rri_selectfile('*_PETcluster_peak.txt','Export Peak Location');

   if ischar(filename) & (length(filename)<9 | isempty(findstr(lower(filename),'_petcluster_peak.txt')))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_PETcluster_peak.txt'];
   end
   
   if isequal(filename,0)
         status = 0;
         return;
   end;
   report_file = fullfile(pathname,filename);

   try
      save (report_file, '-ascii', 'xyz' );
      msg = ['File ', filename, ' has been saved'];
      msgbox(msg, 'Info');
   catch
      msg = ['File ', filename, ' can not be open to write'];
      msgbox(msg, 'Error');
%      msg = sprintf('Cannot export peak location to %s',report_file),
 %     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      status = 0;
      return;
   end;

   return; 					% save_peak_location


%--------------------------------------------------------------------------
function  save_all_location()

   result_file = get(findobj(getappdata(gcf,'mainfig'),'tag','ResultFile'),'UserData');
   dims = getappdata(getappdata(gcf,'mainfig'),'Dims');
   cluster_info = getappdata(gcf,'ClusterInfo');

   xyz = cluster_info.data{1}.idx;
   xyz = rri_coord2xyz(xyz, dims);

   cnum = cluster_info.data{1}.mask;
   for i=1:length(cluster_info.data{1}.id)
      cnum(find(cluster_info.data{1}.mask==cluster_info.data{1}.id(i)))=i; 
   end;

   coord = getappdata(getappdata(gcf,'mainfig'),'BSRatioCoords');

   if isempty(coord)
      coord = getappdata(getappdata(gcf,'mainfig'),'BLVCoords');
   end

   if getappdata(gcf,'ReportType')
      data = getappdata(getappdata(gcf,'mainfig'), 'BSRatio');
   else
      data = getappdata(getappdata(gcf,'mainfig'), 'BLVData');
   end

   data = data(:, cluster_info.lv_idx);

   coord_idx = ones(size(cluster_info.data{1}.idx));

   for i=1:length(coord_idx)
      coord_idx(i) = find(coord==cluster_info.data{1}.idx(i));
   end

   data = data(coord_idx);

   xyz = double(xyz2xyzmm(xyz, result_file));
   xyz2 = double([cnum' double(data) xyz]);

   [filename, pathname] = ...
           rri_selectfile('*_PETcluster_all.txt','Export All Location');

   if ischar(filename) & (length(filename)<9 | isempty(findstr(lower(filename),'_petcluster_all.txt')))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_PETcluster_all.txt'];
   end
   
   if isequal(filename,0)
         status = 0;
         return;
   end;

   report_file = fullfile(pathname,filename);

   try
      save (report_file, '-ascii', 'xyz' );
      msg = ['File ', filename, ' has been saved'];
      msgbox(msg, 'Info');
   catch
      msg = ['File ', filename, ' can not be open to write'];
      msgbox(msg, 'Error');
%      msg = sprintf('Cannot export all location to %s',report_file),
 %     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      status = 0;
      return;
   end;

   filename2 = strrep(filename,'_PETcluster_all.txt','_PETcluster_num.txt');
   report_file2 = fullfile(pathname,filename2);

   try
      save (report_file2, '-ascii', 'xyz2' );
      msg = ['File ', filename2, ' has been saved'];
      msgbox(msg, 'Info');
   catch
      msg = ['File ', filename2, ' can not be open to write'];
      msgbox(msg, 'Error');
%      msg = sprintf('Cannot export all location to %s',report_file),
 %     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      status = 0;
      return;
   end;

   return; 					% save_all_location


%--------------------------------------------------------------------------
function  cluster_fig = load_cluster_report(mainfig)

   cluster_fig = [];

   result_name = getappdata(gcbf, 'ResultName');

   [filename, pathname] = ...
           rri_selectfile('*_PETcluster.mat','Load the cluster report');

   if isequal(filename,0)
         status = 0;
         return;
   end;
   report_file = fullfile(pathname,filename);

   try
      load(report_file);
   catch
      msg = sprintf('Cannot open the cluster report file: %s',report_file),
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      status = 0;
      return;
   end;

   if ~isfield(cluster_info,'peak_thresh')
      cluster_info.peak_thresh = cluster_info.threshold;
      cluster_info.peak_thresh2 = cluster_info.threshold2;
   end

   cluster_fig = show_cluster_report(cluster_info,report_type,mainfig);

   return; 					% load_cluster_report


%--------------------------------------------------------------------------
function fig_h = create_report_figure(report_type,mainfig)
%

   save_setting_status = 'on';
   pet_cluster_report_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(pet_cluster_report_pos) & strcmp(save_setting_status,'on')

      pos = pet_cluster_report_pos;

   else

      w = 0.9;
      h = 0.85;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   if isequal(get(gcbf,'Tag'),'ClusterReportFigure'),
       fig_h = gcbf;
       setappdata(gcf,'HdlList',[]);
       clf(fig_h);
   else
       fig_h = figure('Color',[0.8 0.8 0.8], ...
  	  'Units','normal', ...
	  'Name','PLS Active Clusters Report', ...
	  'NumberTitle', 'off', ...
   	  'DoubleBuffer','on', ...
   	  'MenuBar','none',...
   	  'Position',pos, ...
          'DeleteFcn','pet_cluster_report(''delete_fig'');', ...
	  'PaperPositionMode','auto', ...
   	  'Tag','ClusterReportFigure', ...
   	  'ToolBar','none');
   end;

   w = 0.94;
   h = 0.94;
   x = (1-w)/2;
   y = (1-h)/2;

   pos = [x y w h];

   axes_h = axes('Parent',fig_h, ...
        'Units','normal', ...
        'Box','on', ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',[1 1 1], ...
  	'Position',pos, ...
   	'XTick', [], ...
   	'XLim', [0 1], ...
   	'YTick', [], ...
   	'YLim', [0 1], ...
   	'Tag','ClusterReportAxes');
	
   standard_text = text('Fontname','courier', ...
	'FontWeight','Normal', ...
	'FontAngle','Normal', ...
	'FontUnit','point', ...
	'FontSize',10, ...
	'Units','normal', ...
	'Color',[0 0 0], ...
	'Visible','off','Interpreter','none');

   %  File submenu
   %
   h_file = uimenu('Parent',fig_h, ...
   	   'Label','&File', ...
   	   'Tag','FileMenu', ...
   	   'Visible','on');
   h2 = uimenu(h_file, ...
           'Label','&Load', ...
   	   'Tag','MenuLoad', ...
   	   'Visible','off', ...
           'Callback','pet_cluster_report(''LoadClusterReport'');'); 
   h2 = uimenu(h_file, ...
           'Label','Save to .mat file', ...
   	   'Tag','MenuSave', ...
           'Callback','pet_cluster_report(''SaveClusterReport'');'); 
   h2 = uimenu(h_file, ...
           'Label','Save to .txt file', ...
   	   'Tag','MenuSaveTxt', ...
           'Callback','pet_cluster_report(''SaveClusterTXT'');'); 
   h2 = uimenu(h_file, ...
           'Label','Export All Location', ...
   	   'Tag','MenuSaveAllLocation', ...
           'Callback','pet_cluster_report(''SaveAllLocation'');'); 
   h2 = uimenu(h_file, ...
           'Label','Export Peak Location', ...
   	   'Tag','MenuSavePeakLocation', ...
           'Callback','pet_cluster_report(''SavePeakLocation'');'); 
   h2 = uimenu(h_file, ...
	   'Separator', 'on', ...
           'Label','&Print...', ...
   	   'Tag','MenuPrint', ...
	'visible', 'off', ...
           'Callback','printdlg'); 
   h2 = uimenu(h_file, ...
           'Label','Print Pre&view...', ...
   	   'Tag','MenuPrintPreview', ...
	'visible', 'off', ...
           'Callback','printpreview(gcbf)'); 
   h2 = uimenu(h_file, ...
           'Label','Print Set&up...', ...
   	   'Tag','MenuPrintSetup', ...
	'visible', 'off', ...
           'Callback','filemenufcn(gcbf,''FilePrintSetup'')'); 
   h2 = uimenu(h_file, ...
           'Label','Pa&ge Setup...', ...
   	   'Tag','MenuPageSetup', ...
	'visible', 'off', ...
           'Callback','pagesetupdlg(gcbf)'); 

   rri_file_menu(fig_h);

   setappdata(gcf,'ResultName', get(gcbf,'name'));
   setappdata(gcf,'LineHeight', 0.03);
   setappdata(gcf,'TopMargin', 0.14);
   setappdata(gcf,'BottomMargin', 0.11);
   setappdata(gcf,'StandardTextObj', standard_text);
   setappdata(gcf,'ReportType', report_type);

   if ~isempty(mainfig) & ishandle(mainfig)
      setappdata(gcf,'mainfig',mainfig);
   end

   return; 					% create_figure;


%--------------------------------------------------------------------------
function setup_header();

   standard_text_obj = getappdata(gcf,'StandardTextObj');
   report_type = getappdata(gcf,'ReportType');

   axes_h = findobj(gcf,'Tag','ClusterReportAxes');
   axes_pos = get(axes_h,'Position');
   total_height = 1;

   header_text = { ...   % {label, [x y z], type}, where y is counted from top
	{ 'Cluster #',  	     [0.05 0.08 0], -1 }, ...
	{ 'Voxel Mean',	    	     [0.17 0.08 0], -1 }, ...
	{ 'Peak Location',  	     [0.39 0.05 0], -1 }, ...
	{ 'XYZ',		     [0.33 0.08 0], -1 }, ...
	{ 'XYZ(mm)',		     [0.52 0.08 0], -1 }, ...
	{ 'Brain LV',		     [0.71 0.05 0],  0 }, ...
	{ 'Value',	     	     [0.73 0.08 0],  0 }, ...
	{ 'Bootstrap',		     [0.71 0.05 0],  1 }, ...
	{ 'Ratio',	     	     [0.69 0.08 0],  1 }, ...
	{ 'Appro.P',	     	     [0.76 0.08 0],  1 }, ...
	{ 'Cluster Size',	     [0.85 0.05 0], -1 }, ...
	{ '(voxels)',    	     [0.87 0.08 0], -1 }};

   str_field = 1; pos_field = 2; type_field = 3;
   for i=1:length(header_text),
     if (header_text{i}{type_field}<0 | report_type==header_text{i}{type_field})
 	 h = copyobj_legacy(standard_text_obj,axes_h);
	 text_pos = header_text{i}{pos_field}; 
	 text_pos(2) = total_height - text_pos(2);    % text pos=[x height-y z]
	 set(h,'String', header_text{i}{str_field},  ...
	       'Position', text_pos, ...
	       'Visible','on');
     end;
   end;

   % line is located at the 0.08 from top
   % 
   y_pos = 1 -  0.11;
   line_hdl = line( ...
	'XData', [0.040 0.960], ...
	'YData', [y_pos y_pos], ...
	'LineStyle', '-', ...	
	'LineWidth', 1, ...	
	'Color', [0 0 0], ...
	'Marker', 'none');

   return; 					% setup_header;


%--------------------------------------------------------------------------
function setup_footer(),

   axes_h = findobj(gcf,'Tag','ClusterReportAxes');
   standard_text_obj = getappdata(gcf,'StandardTextObj');
   cluster_info = getappdata(gcf,'ClusterInfo');

   key_text = { ...
	{ '<<prev.',  	     [0.80 0.06 0], 'PrevPage'}, ...
	{ 'next>>',	     [0.90 0.06 0], 'NextPage'}};

   str_field = 1; pos_field = 2; tag_field = 3; 
   for i=1:length(key_text),
      h = copyobj_legacy(standard_text_obj,axes_h);
      bd_fn = sprintf('pet_cluster_report(''%s'');',key_text{i}{tag_field});
      set(h,'String', key_text{i}{str_field},  ...
	    'Position',key_text{i}{pos_field}, ...
	    'ButtonDownFcn',bd_fn, ...
	    'Tag',key_text{i}{tag_field}, ...
	    'Visible','off');
   end;


   %  display the footer
   %
   source_file = cluster_info.source;
   len_str = length(source_file);
   if (len_str > 80) 
	source_file = [ '...' source_file(len_str-76:end)];
   end;

   source_line = sprintf('Source: %s',source_file);

   h = copyobj_legacy(standard_text_obj,axes_h);

   x = 0.03;
   y = 0.08;

   pos = [x y 0];

   set(h,'String', source_line, ...
	 'Interpreter','none', ...
         'Fontname','courier', ...
         'FontWeight','Normal', ...
         'FontAngle','Normal', ...
         'FontUnit','point', ...
         'FontSize',10, ...
         'Position',pos, ...
         'Visible','on');

   lv_str = sprintf('LV Idx: %d',cluster_info.lv_idx);
   thresh_str = sprintf('Pos.Thresh: %2.4f',cluster_info.threshold);
   thresh_str2 = sprintf('Neg.Thresh: %2.4f',cluster_info.threshold2);

   peak_thresh_str = sprintf('Pos.Peak Thresh: %2.4f',cluster_info.peak_thresh);
   peak_thresh_str2 = sprintf('Neg.Peak Thresh: %2.4f',cluster_info.peak_thresh2);

   min_size_str = sprintf('Min Size: %d(voxels)', ...
						cluster_info.min_size);
   min_dist_str = sprintf('Min Distance: %3.1fmm ', ...
						cluster_info.min_dist);
   parameters_line = sprintf('%s, %s, %s, %s\n%s, %s, %s', ...
				lv_str,thresh_str,thresh_str2,min_size_str,peak_thresh_str,peak_thresh_str2,min_dist_str);

   h = copyobj_legacy(standard_text_obj,axes_h);

   y = 0.05;

   pos = [x y 0];

   set(h,'String', parameters_line, ...
	 'Position',pos, ...
         'Fontname','courier', ...
         'FontWeight','Normal', ...
         'FontAngle','Normal', ...
         'FontUnit','point', ...
         'FontSize',10, ...
	 'Visible','on');

   return; 					% setup_footer;


%--------------------------------------------------------------------------
function show_page_keys(page_num),

   total_pages = getappdata(gcf,'TotalPages');

   h = findobj(gcf,'Tag','PrevPage');
   if (page_num ~= 1),
	set(h,'Visible','on');
   else
	set(h,'Visible','off');
   end;

   h = findobj(gcf,'Tag','NextPage');
   if (page_num ~= total_pages)
	set(h,'Visible','on');
   else
	set(h,'Visible','off');
   end;


   return; 					% show_page_keys;


%--------------------------------------------------------------------------
function setup_cluster_data_idx(cluster_info),
%
   standard_text_obj = getappdata(gcf,'StandardTextObj');
   line_height = getappdata(gcf,'LineHeight');
   top_margin = getappdata(gcf,'TopMargin');
   bottom_margin = getappdata(gcf,'BottomMargin');

   axes_h = findobj(gcf,'Tag','ClusterReportAxes');
   axes_pos = get(axes_h,'Position');
   total_height = 1;
   num_rows = floor((total_height - top_margin - bottom_margin) / line_height);

   lag_idx = [];
   cluster_id = [];
   cluster_idx = [];
   start_cluster_id = 1;
   cluster_data = cluster_info.data;
   for i=1:length(cluster_data),
      num_clusters = length(cluster_data{i}.id);
      if (num_clusters ~= 0)
         lag_idx = [lag_idx repmat(i,1,num_clusters+1)];
         cluster_idx = [cluster_idx [1:num_clusters 0]];

         last_cluster_id = start_cluster_id+num_clusters-1;
         cluster_id = [cluster_id [start_cluster_id:last_cluster_id 0]];
         start_cluster_id = last_cluster_id+1;
      end;
   end;
   cluster_data_idx = [cluster_id; lag_idx; cluster_idx];
   cluster_data_idx = cluster_data_idx(:,1:end-1);

   total_clusters = size(cluster_data_idx,2);
   total_pages = ceil(total_clusters / num_rows);

   setappdata(gcf,'ClusterInfo',cluster_info);
   setappdata(gcf,'ClusterDataIdx',cluster_data_idx);
   setappdata(gcf,'TotalPages',total_pages);
   setappdata(gcf,'NumRows',num_rows);

   return; 					% setup_page_rows


%--------------------------------------------------------------------------
function  p_value = ratio2p(x,mu,sigma)

   p_value = (1 + erf((x - mu) / (sqrt(2)*sigma))) / 2;
   p_value = (1 - p_value) * 2;

   return; 						% ratio2p


%----------------------------------------------------------------------------
function delete_fig

    link_figure = getappdata(gcbf,'LinkFigureInfo');

    try
       rmappdata(link_figure.hdl,link_figure.name);
    end;

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       pet_cluster_report_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'pet_cluster_report_pos');
    catch
    end

   return;

