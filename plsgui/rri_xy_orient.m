%  Convert image of different orientations to standard Analyze orientation
%  It is a 2D version of the rri_orient function
%

%  Jimmy Shen, Oct.21,2004
%___________________________________________________________________

function [orient, new_dims, new_voxel_size, new_origin, ...
	new_coord, pattern] = rri_xy_orient(old_dims, ...
	old_voxel_size, old_origin, old_coord)

   %  get orient of the current image
   %
   orient = rri_xy_orient_ui;
   pause(.1);

   %  no need for conversion
   %
   if isequal(orient, [1 2])
      new_dims = old_dims;
      new_voxel_size = old_voxel_size;
      new_origin = old_origin;
      new_coord = old_coord;
      pattern = [];

      return;
   end

   pattern = 1:prod(old_dims);
   pattern = reshape(pattern, old_dims);

   %  calculate after flip orient
   %
   rot_orient = mod(orient + 1, 2) + 1;

   %  do flip:
   %
   flip_orient = orient - rot_orient;

   for i = 1:2
      if flip_orient(i)
         pattern = flipdim(pattern, i);
      end
   end

   %  get index of orient (do inverse)
   %
   [tmp rot_orient] = sort(rot_orient);

   %  do rotation:
   %
   pattern = permute(pattern, [rot_orient 3]);
   pattern = [pattern(:)]';

   %  rotate resolution, or 'dim'
   %
   new_dims = old_dims([rot_orient 3]);

   %  rotate voxel_size, or 'pixdim'
   %
   new_voxel_size = old_voxel_size([rot_orient 3]);

   %  re-calculate originator
   %
   tmp = old_origin([rot_orient 3]);
   flip_orient = flip_orient(rot_orient);

   for i = 1:2
      if flip_orient(i) & ~isequal(tmp(i), 0)
         tmp(i) = new_dims(i) - tmp(i) + 1;
      end
   end

   new_origin = tmp;

   tst_img = zeros(1, prod(old_dims));
   tst_img(old_coord) = 1;
   tst_img = tst_img(pattern);
   new_coord = find(tst_img);

   return;						% rri_xy_orient

