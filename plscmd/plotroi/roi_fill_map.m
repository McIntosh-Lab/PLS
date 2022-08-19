function flooded_image = roi_fill_map(temp_image, temp_xy_loc)

   flooded_image = temp_image;

   if (nargin ~= 2)
      error('ERROR using roi_fill_map!');
   end

   B = ones(size(temp_image));
   B(find(temp_image==max(temp_image(:)))) = 0;

   progress_hdl = rri_progress_ui('init','Creating ROI Flooded File');
   set(gcf,'Pointer','watch');

   for i = 1:size(temp_xy_loc,1)
      x = temp_xy_loc(i,2);
      y = temp_xy_loc(i,3);
      new_val = temp_xy_loc(i,1);

      tmp = double(bwfill(B,x,y))-B;
      flooded_image(find(tmp)) = new_val;

      msg = ['Working on Region:  ',num2str(i),' out of ',num2str(size(temp_xy_loc,1))];
      rri_progress_ui(progress_hdl, '', msg);
      rri_progress_ui(progress_hdl,'',i/size(temp_xy_loc,1));

      if get(progress_hdl,'user')
         break;
      end
   end

   close(progress_hdl);

   return;

