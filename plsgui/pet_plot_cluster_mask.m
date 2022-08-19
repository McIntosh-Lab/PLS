function pet_plot_cluster_mask(cluster_info)

   sa = getappdata(gcf,'sa');
   st_dims = getappdata(gcf,'STDims');
   cluster_mask_size = getappdata(gcf,'ClusterMaskSize');

   rows_disp = getappdata(gcf,'RowsDisp');
   cols_disp = getappdata(gcf,'ColsDisp');
   img_width = getappdata(gcf,'ImgWidth');
   img_height = getappdata(gcf,'ImgHeight');
   rot_amount = getappdata(gcf,'RotateAmount');

   if sa
      rot_amount = rot_amount + 1;
   end

   hold on;

   idx = cluster_info.data{1}.idx;
   xyz = rri_coord2xyz(idx, st_dims);

   if ~isempty(sa) & ~isempty(xyz)
      if sa
         xyz = xyz(:,[3,2,1]);
      else
         xyz = xyz(:,[1,3,2]);
      end
   end

   for i = 1:size(xyz,1)
      org_z = xyz(i,3);
      org_y = ceil(org_z/cols_disp) - 1;
      org_x = org_z - org_y*cols_disp - 1;

      org_x = org_x * img_width;
      org_y = org_y * img_height;

      if ~isempty(org_x) & ~isempty(org_y)
         switch mod(rot_amount,4)
            case {0},
               cur_x = xyz(i,2) + org_x;
               cur_y = xyz(i,1) + org_y;
            case {1},
               cur_x = xyz(i,1) + org_x;
               cur_y = img_height - xyz(i,2) + 1 + org_y;
            case {2},
               cur_x = img_width - xyz(i,2) + 1 + org_x;
               cur_y = img_height - xyz(i,1) + 1 + org_y;
            case {3},
               cur_x = img_width - xyz(i,1) + 1 + org_x;
               cur_y = xyz(i,2) + org_y;
         end

         plot(cur_x, cur_y, 'k*', 'markersize', cluster_mask_size);
      end
   end

   hold off;

   return

