%XYZ2XYZMM  Convert from old voxel location XYZ (with unit
%	in absolute voxels) to new voxel location XYZmm (with
%	unit in millimeters).
%
%  Usage: xyzmm = xyz2xyzmm(xyz, result_file);
%
%  xyz:  Voxel location file with unit in absolute voxels.
%	 Warning: This file will be overwritten using the 
%	 same voxel location with unit in millimeters.
%	 (xyz can also be voxel location matrix)
%
%  result_file:  PLS result file ended with "result.mat"
%
%  xyzmm:  New voxel location matrix with unit in millimeters.
%

%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%
%----------------------------------------------------------------------------
function xyzmm = xyz2xyzmm(xyz, result_file)

   xyz_is_file = 0;

   if ~isnumeric(xyz) & ischar(xyz)
      xyz_is_file = 1;
      xyz_file = xyz;
      xyz = load(xyz_file, '-ascii');
   end

   warning off;
   load(result_file,'origin','voxel_size','st_origin','st_voxel_size');
   warning on;

   if exist('st_origin','var')
      origin = st_origin;
   end

   if exist('st_voxel_size','var')
      voxel_size = st_voxel_size;
   end

   xyzmm=double((xyz-ones(size(xyz,1),1)*origin).*(ones(size(xyz,1),1)*voxel_size));

   if xyz_is_file
      save(xyz_file, '-ascii', 'xyzmm');
   end

   return;

