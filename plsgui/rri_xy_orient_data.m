function blv = rri_xy_orient_data(blv, old_coord, new_coord, dims, origin_pattern)

   orient_img = zeros(dims);
   orient_img = repmat(orient_img(:),[1,size(blv,2)]);
   orient_img(old_coord,:) = blv;
   orient_img = orient_img(origin_pattern,:);
   blv = orient_img(new_coord,:);

   return;

