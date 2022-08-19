function fmri_plot_cluster_mask(cluster_info)

   sa = getappdata(gcf,'sa');
   st_dims = getappdata(gcf,'STDims');
   cluster_mask_size = getappdata(gcf,'ClusterMaskSize');

   img_width = getappdata(gcf,'ImgWidth');
   img_height = getappdata(gcf,'ImgHeight');
   rot_amount = getappdata(gcf,'RotateAmount');

   if sa
      rot_amount = rot_amount + 1;
   end

   slice_idx = getappdata(gcf,'SliceIdx');

   hold on;

   for j = 1:length(cluster_info.data)

      idx = cluster_info.data{j}.idx;
      xyz = rri_coord2xyz(idx, st_dims);

      if ~isempty(sa) & ~isempty(xyz)
         if sa
            xyz = xyz(:,[3,2,1]);
         else
            xyz = xyz(:,[1,3,2]);
         end
      end

      for i = 1:size(xyz,1)
         cur_z = find(slice_idx == xyz(i,3));

         if ~isempty(cur_z)
            switch mod(rot_amount,4)
               case {0},
                  cur_x = xyz(i,2) + (cur_z - 1) * img_width;
                  cur_y = xyz(i,1) + (j - 1) * img_height;
               case {1},
                  cur_x = xyz(i,1) + (cur_z - 1) * img_width;
                  cur_y = img_height - xyz(i,2) + 1 + (j - 1) * img_height;
               case {2},
                  cur_x = img_width - xyz(i,2) + 1 + (cur_z - 1) * img_width;
                  cur_y = img_height - xyz(i,1) + 1 + (j - 1) * img_height;
               case {3},
                  cur_x = img_width - xyz(i,1) + 1 + (cur_z - 1) * img_width;
                  cur_y = xyz(i,2) + (j - 1) * img_height;
            end

            plot(cur_x, cur_y, 'k*', 'markersize', cluster_mask_size);
         end
      end
   end

   hold off;

   return

