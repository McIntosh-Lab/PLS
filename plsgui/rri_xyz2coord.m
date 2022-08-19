function coord = rri_xyz2coord(xyz, dim)

   coord = sub2ind(dim, xyz(:,1), xyz(:,2), xyz(:,3));

   return;

   coord = ones(size(xyz,1),1);

   for i = 1:size(xyz,1)
      x = xyz(i,1);
      y = xyz(i,2);
      z = xyz(i,3);

      coord(i) = (z-1)*dim(1)*dim(2) + (y-1)*dim(1) + x;
   end

   return;

