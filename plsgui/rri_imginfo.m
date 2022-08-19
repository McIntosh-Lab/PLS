function [dims,voxel_size,origin] = rri_imginfo(fname)
%
% syntax:    [dims,voxel_size,origin] = rri_imginfo(fname)
%   
%    Output:
%	dims - dimension of the image, i.e. [rows, cols, slices]
%       voxel_size - size of voxels in mm, i.e. [x_mm, y_mm, z_mm] 
%       origin - the origin of the image, i.e. [x, y, z]
%
%    This script reads the img header to determine the dimension, voxel
%    size and the origin of the IMG file.
%
%    If only a single output agrument is specified, the output is a vector
%    of [rows, cols, 1, slices].  If three output agurments are specified,
%    it outputs the numbers of rows, cols, and slices. 
%
%  W. Chau (July 2001)

%  determine the dimensions and data type, as well as the data byte ordering 

   nii = load_nii(fname,1);
   dims = nii.hdr.dime.dim(2:4);
   voxel_size = nii.hdr.dime.pixdim(2:4);
   origin = round(nii.hdr.hist.originator(1:3));

   return;					% rri_imginfo


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  [fpath,iname] = fileparts(fname);
  hfile = fullfile(fpath,[iname,'.hdr']);

  mf = 'ieee-le';
  fid = fopen(hfile,'r',mf);    % try little-endian byte ordering

  [fn,perm,mf]=fopen(fid);
  fseek(fid,70,'bof');
  [datatype]=fread(fid,1,'int16');  % 2=8 bits   4=16 bits

  % Test whether the machine and data byte ordering are the same 
  % It is a hack, datatype cannot be bigger than 500
  if datatype >= 512	% machine and data byte ordering is different

     fclose(fid);

     %  reopen the data file with big-endian byte order
     mf = 'ieee-be';  
     fid = fopen(hfile,'r',mf);
  end

  fseek(fid,42,'bof');
  [dims]=fread(fid,3,'int16');		
  dims = dims';
  
  fseek(fid,80,'bof'); 
  [voxel_size]=fread(fid,3,'float'); 
  voxel_size = voxel_size';

  fseek(fid,253,'bof');
  [origin]=fread(fid,3,'int16');
  origin = origin';

  fclose(fid);

