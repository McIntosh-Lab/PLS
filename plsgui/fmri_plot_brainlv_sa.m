function [blv_img,cmap,cbar_map] = fmri_plot_brainlv_sa(brainlv,coords,dims, ...
	slice_idx,thresh,thresh2,range,rot_amount,bg_img,sa,dims_sa,cluster_idx)
   
   rows = dims_sa(1);
   cols = dims_sa(2);
   slices = dims_sa(4);
   
   if ~exist('slice_idx','var') | isempty(slice_idx)
     slice_idx = [1:slices];
   end
   
   if ~exist('rot_amount','var') | isempty(rot_amount)
     rot_amount = 1;
   end

   if ~exist('bg_img','var') | isempty(bg_img)
     no_background_image = 1;
   else
     no_background_image = 0;
   end
   
   max_blv = max(brainlv(:));
   min_blv = min(brainlv(:));
   if ~exist('range','var') | (max_blv == min_blv)
if 0
     if (abs(min_blv) > abs(max_blv)),
       max_blv = abs(min_blv);
     else
       min_blv = -1 * max_blv;
     end;
end
   else
     min_blv = range(1);
     max_blv = range(2);
   end;
   
   if ~exist('thresh','var')
     thresh = max_blv; % (abs(max_blv) + abs(min_blv)) / 4,
   end

   if ~exist('thresh2','var')
     thresh2 = min_blv; % -thresh;
   end
   
   too_large = find(brainlv > max_blv); brainlv(too_large) = max_blv;
   too_small = find(brainlv < min_blv); brainlv(too_small) = min_blv;


   % create the appropriate colormap
   %
   % cmap = set_colormap(max_blv,min_blv,thresh,thresh2);
   
   bg_values = [1 1 1];
   num_blv_colors = 25;
   brain_region_color_idx = 51;
   first_lower_color_idx = 101;
   first_upper_color_idx = 126;

   % set up the colormap for the background 
   %
   bg_brain_values = [0.54 0.54 0.54];
   if (no_background_image),
      bg_cmap = ones(100,1)*bg_brain_values;	% the brain regions
   else
      bg_cmap = bone(140);
      bg_cmap = bg_cmap(1:100,:);
   end;
   

   %  colormap entries
   %     	 1 - 100    : for the brain regions (background) image
   %           101 - 125    : for the negative blv values below threshold
   %           126 - 150    : for the positive blv values above threshold
   %     	  151       : for the non-brain regions

   cmap = zeros(151,3);
   jetmap = jet(64);
   cmap(1:100,:) = bg_cmap;			% the brain regions
   cmap(101:125,:) = jetmap([1:25],:);		% the negative blv values
   cmap(126:150,:) = jetmap([36:60],:);		% the positive blv values
   cmap(end,:) = bg_values;			% the nonbrain regions


   %  set up the colormap for the display colorbar
   %
   cbar_size = 100;
   cbar_map = ones(cbar_size,1) * bg_brain_values; 
   cbar_step = (max_blv - min_blv) / cbar_size;

    %  prevent_num_lower_color_0
    %
    if 0 % (abs(min_blv) - thresh) < cbar_step & (abs(min_blv) - thresh) ~= 0
        cbar_size = ceil((max_blv - min_blv) / (abs(min_blv) - thresh));
        cbar_map = ones(cbar_size,1) * bg_brain_values;
        cbar_step = (max_blv - min_blv) / cbar_size;
    end
    if 0 % (abs(max_blv) - thresh) < cbar_step & (abs(max_blv) - thresh) ~= 0
        cbar_size = ceil((max_blv - min_blv) / (abs(max_blv) - thresh));
        cbar_map = ones(cbar_size,1) * bg_brain_values;
        cbar_step = (max_blv - min_blv) / cbar_size;
    end

   if cbar_step ~= 0
%      num_lower_color = round((abs(min_blv) - thresh) / cbar_step);

      if max_blv > thresh2 % -abs(thresh)
         num_lower_color = round((thresh2 - min_blv) / cbar_step);
      else
         num_lower_color = round((max_blv - min_blv) / cbar_step);
      end

      if round(64 / 25 * num_lower_color) > 0
         jetmap = jet(round(64 / 25 * num_lower_color));
         cbar_map(1:num_lower_color,:) = jetmap(1:num_lower_color,:);	
      end

%      num_upper_color = round((max_blv - thresh) / cbar_step);

      if min_blv < thresh % abs(thresh)
         num_upper_color = round((max_blv - thresh) / cbar_step);
      else
         num_upper_color = round((max_blv - min_blv) / cbar_step);
      end

      if round(64 / 25 * num_upper_color) > 0
         jetmap = jet(round(64 / 25 * num_upper_color));
         first_jet_color = round((36 / 64) * size(jetmap,1));
         jet_range = [first_jet_color:first_jet_color+num_upper_color-1];
         cbar_map(end-num_upper_color+1:end,:) = jetmap(jet_range,:);
      end

      % Create the image slices in which voxels are set to be within certain range
      %
%      lower_interval = (abs(min_blv) - thresh) / (num_blv_colors-1);
 %     upper_interval = (max_blv - thresh) / (num_blv_colors-1);

      if max_blv > thresh2 % -abs(thresh)
         lower_interval = (thresh2 - min_blv) / (num_blv_colors-1);
      else
         lower_interval = (max_blv - min_blv) / (num_blv_colors-1);
      end

      if min_blv < thresh % abs(thresh)
         upper_interval = (max_blv - thresh) / (num_blv_colors-1);
      else
         upper_interval = (max_blv - min_blv) / (num_blv_colors-1);
      end

      disp_blv = zeros(1,length(coords)) + brain_region_color_idx;
      lower_idx = find(brainlv < thresh2);
      blv_offset = brainlv(lower_idx) - min_blv; 

      if lower_interval ~=0
         lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
      else
         lower_color_idx = ones(size(blv_offset)) * first_lower_color_idx;
      end

      disp_blv(lower_idx) = lower_color_idx;

      upper_idx = find(brainlv > thresh);
      blv_offset = max_blv - brainlv(upper_idx); 

      if upper_interval ~=0
         upper_color_idx = num_blv_colors - round(blv_offset/upper_interval);
      else
         upper_color_idx = num_blv_colors * ones(size(blv_offset));
      end

      upper_color_idx = upper_color_idx + first_upper_color_idx - 1;
      disp_blv(upper_idx) = upper_color_idx;
    else
       disp_blv = zeros(1,length(coords)) + brain_region_color_idx;
    end

   % get non_cluster_coords
   %
   if isequal(coords, cluster_idx)
      non_cluster_coords = [];
   else
      [tmp cluster_coords] = intersect(coords,cluster_idx);
      non_cluster_coords = ones(1,length(coords));
      non_cluster_coords(cluster_coords) = 0;
      non_cluster_coords = find(non_cluster_coords);
   end

   if (no_background_image),
      non_brain_region_color_idx = size(cmap,1);
      img = zeros(1,rows*cols*slices) + non_brain_region_color_idx;

      disp_blv(non_cluster_coords) = brain_region_color_idx;

      img(coords) = disp_blv;
      img = reshape(img,[dims(1) dims(2) 1 dims(4)]);
   else
      max_bg = max(bg_img(:));
      min_bg = min(bg_img(:));
      img = (bg_img - min_bg) / (max_bg - min_bg) * 100;

      disp_blv(non_cluster_coords) = img(coords(non_cluster_coords));

      if exist('lower_idx','var') & ~isempty(lower_idx)
         img(coords(lower_idx)) = disp_blv(lower_idx);
      end

      if exist('upper_idx','var') & ~isempty(upper_idx)
         img(coords(upper_idx)) = disp_blv(upper_idx);
      end
   end;

   % convert image to sagittal view
   %
   img = rri_axial2other(img,sa);

   % Rotate each slice by 90 degree 
   %
   num_slices = length(slice_idx);
   if (mod(rot_amount,2) == 0)
      blv_img = zeros(rows,cols,1,num_slices); 
   else
      blv_img = zeros(cols,rows,1,num_slices); 
   end

   for i=1:num_slices,
       blv_img(:,:,1,i) = rot90(img(:,:,1,slice_idx(i)),rot_amount);
   end;
%   blv_img(1) = max_blv; blv_img(2) = min_blv;

   return;


%-------------------------------------------------------------------------
%
function [cmap] = set_colormap(max_value, min_value, thresh, thresh2)
%
%   set the display colormap based on the max/min display values and 
%   the threshold setting.
%
%   The upper colors are coming from the entries of [140:239] of the 
%   255 jet colormap, and the lower colors are from the entries of 
%   [1:100] of the colormap.
%

   range_interval = max_value - min_value;
   upper_interval = max_value - thresh;
   lower_interval = thresh2 - min_value; % abs(min_value) - abs(thresh2);
   
   %  colormap entries for the upper range values, using the
   %  entries of [140:239] from the 255 jet colormap
   %
   num_upper_colors = 0;
   if (upper_interval > 0)
      num_upper_colors = round(upper_interval / range_interval * 255); 
      cmap_size = round(255 * num_upper_colors/100);
      first_color_idx = round(140 / 255 * cmap_size);
      last_color_idx = first_color_idx + num_upper_colors - 1;
      uppermap = jet(cmap_size);
      upper_colors = uppermap(first_color_idx:last_color_idx,:);
   end;
   
   %  colormap entries for the lower range values, using the 
   %  entries of [1:100] from the 255 jet colormap
   %
   num_lower_colors = 0;
   if (lower_interval > 0)  
      num_lower_colors = round(lower_interval / range_interval * 255); 
      cmap_size = round(255 * num_lower_colors/100);
      first_color_idx = 1;
      last_color_idx = num_lower_colors;
      lowermap = jet(cmap_size);
      lower_colors = lowermap(first_color_idx:last_color_idx,:);
   end;
   
   cmap = zeros(256,3);
   cmap(1:255,:) = jet(255);
   
   ignore_pts = [num_lower_colors+1:255-num_upper_colors];
   
   if (num_lower_colors > 0),
     cmap(1:num_lower_colors,:) = lower_colors;
   end;
   if (num_upper_colors > 0),
     cmap(ignore_pts(end)+1:255,:) = upper_colors;
   end;
   
   cmap(ignore_pts,:) = ones(length(ignore_pts),3) * 140/255;
   cmap(256,:) = [1 1 1];
   
   return; 					% set_colormap

