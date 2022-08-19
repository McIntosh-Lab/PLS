function [xyz, xyz_mm] = rri_coord2xyz(coord, dim, origin, voxel_size)

   coord = coord(:);
   [xyz(:,1) xyz(:,2) xyz(:,3)] = ind2sub(dim, coord);

   if exist('origin','var') & exist('voxel_size','var')
      origin = repmat(origin, [size(xyz,1),1]);
      voxel_size = repmat(voxel_size, [size(xyz,1),1]);
      xyz_mm = (xyz - origin) .* voxel_size;
   else
      xyz_mm = [];
   end

   return;

   xyz = [];

   for i = 1:length(coord)
      this_coord = coord(i);
      this_z = ceil(this_coord / (dim(1)*dim(2)));
      this_y = ceil(mod(this_coord, (dim(1)*dim(2))) / dim(1));
      this_x = mod(this_coord, (dim(1)*dim(2))) - dim(1)*(this_y-1);
      xyz = [xyz ; [this_x, this_y, this_z]];
   end

   return;

