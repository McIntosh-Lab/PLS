%XYZMM2XYZ  Convert from new voxel location XYZmm (with unit
%	in millimeters) to old voxel location XYZ (with unit
%	in absolute voxels).
%
%  Usage: xyz = xyzmm2xyz(xyzmm, result_file);
%
%  xyzmm:  Voxel location file with unit in millimeters.
%	 Warning: This file will be overwritten using the 
%	 same voxel location with unit in absolute voxels.
%	 (xyzmm can also be voxel location matrix)
%
%  result_file:  PLS result file ended with "result.mat"
%
%  xyzmm:  Old voxel location matrix with unit in absolute voxels.
%

%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%
%----------------------------------------------------------------------------
function xyz = xyzmm2xyz(xyzmm, result_file)

   xyz_is_file = 0;

   if ~isnumeric(xyzmm) & ischar(xyzmm)
      xyz_is_file = 1;
      xyz_file = xyzmm;
      xyzmm = load(xyz_file, '-ascii');
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

   xyz=round(double(xyzmm./(ones(size(xyzmm,1),1)*voxel_size)+ones(size(xyzmm,1),1)*origin));

   if xyz_is_file
      save(xyz_file, '-ascii', 'xyz');
   end

   return;

