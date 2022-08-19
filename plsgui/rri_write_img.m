function write_img(fname,img,scaling_flg,dims,voxel_size,datatype,origin,descrip)
%
%USAGE: write_img(fname,img)  or
% 	write_img(fname,img,scaling_flg)  or
%       write_img(fname,img,scaling_flg,dims,voxel_size,datatype,origin,descrip)
%
%    This script is used to create the img file specified by fname.
%    The corresponding header file (with name of image.hdr) is read to 
%    determine the data type and dimensions.  If the function is called with
%    "dims", "voxel_size", and "type" being set, the header file will be 
%    created as well.
%
% INPUT:
%    fname - the file name of IMG to be used
%    img - the volume to be saved
%    scaling_flg - set to 1 to scale the voxel values between 0 and max values 
%		   for the type (note: scaling only has affect on the 
%                  type 2,4, or 8 file).
%
%    dims - 3 element vector to specify the volume dimension 
%    voxel_size - size of voxel in mm	
%    datatype - output IMG type: 
%		 2 - uint8, 4 - int16, 8 - int32, 16 - float, 64 - double
%    origin - (optional) the AC origin [default: (0,0,0)]
%    descrip - (optional) description about the IMG volume
%
% OUTPUT:
%    IMG file with name of 'fname'
%
%
% Examples:
%
%   write_img('out_img',img);
%
%   dims = [40 48 34]; v_size = [4 4 4]; datatype = 4; origin = [21 29 14];
%   write_img('out_img',img,0,dims,v_size,datatype,origin,'description');
%
 
%---------------------------------------------------------------------------
%   History:
%     W. Chau (July 20,99) - Script created
%     W. Chau (July 25,02) - Modified for creating header 
%     J. Shen (Sept 29,03) - Set glmax/glmin with maxval/minval of img 
%---------------------------------------------------------------------------
%

   if exist('fname','var')
      [img_path,iname,iext] = fileparts(fname);
      hfile = fullfile(img_path, [iname '.hdr']);
   end;

   maxval = round(max(img(:)));
   minval = round(min(img(:)));

   switch (nargin)
     case {2,3}
       [datatype,dims,mf] = get_header(hfile);
     case {6,7,8}
       if ~exist('origin','var'), origin = []; end;
       if ~exist('descrip','var'), descrip = 'Created using "write_img"'; end;

       mf = create_header(hfile,dims,voxel_size,datatype,origin,descrip,maxval,minval);

       if isempty(mf), return; end;		% encountered error and return

     otherwise
       help write_img
       return;
   end;
   
   

   if ~exist('scaling_flg','var')
     scaling_flg = 0;
   end
   
   out_file(fname,img,scaling_flg,datatype,dims,mf,maxval,minval);
   
   return;
   

%------------------------------------------------------------------------
function [datatype,dims,mf] = get_header(hfile)
%
%

   %  determine the dimensions and data type, as well as the data byte 
   %  ordering 

   mf = 'ieee-le';
   fid = fopen(hfile,'r',mf);    % try little-endian byte ordering
   
     [fn,perm,mf]=fopen(fid);
   
     fseek(fid,42,'bof');
     [dims]=fread(fid,3,'int16');		
   
     fseek(fid,70,'bof');
     [datatype]=fread(fid,1,'int16');  % 2=8 bits   4=16 bits
   
     % Test whether the machine and data byte ordering are the same 
     % It is a hack, datatype cannot be bigger than 500
   
     if datatype >= 512	% machine and data byte ordering is different
   
        fclose(fid);
   
        %  reread the data again
   
        mf = 'ieee-be';  % use little-endian byte ordering 
        fid = fopen(hfile,'r',mf);
   
        fseek(fid,42,'bof');
        [dims]=fread(fid,3,'int16');		
   
        fseek(fid,70,'bof');
        [datatype]=fread(fid,1,'int16');  % 2=8 bits   4=16 bits
   
     end
   
   fclose(fid);
   
   return;


%------------------------------------------------------------------------
function mf = create_header(hfile,dims,voxel_size,datatype,origin,descrip,maxval,minval);
%
%

   if (length(dims) < 4); dims = [dims(:)' 1]; end;
   if (length(voxel_size) < 4); voxel_size = [voxel_size(:)' 0]; end;
   
   dims = [4 dims 0 0 0];
   pixdim = [0 voxel_size 0 0 0];
   glmin = 0; 

   switch (datatype) 
      case  {1},  bits=1;  glmax = 1;
      case  {2},  bits=8;  glmax = 255;
      case  {4},  bits=16; glmax = 32767;
      case  {8},  bits=32; glmax = (2^31-1);
      case  {16}, bits=32; glmax = maxval; glmin = minval; % glmax = 1;
      case  {64}, bits=64; glmax = maxval; glmin = minval; % glmax = 1;
      otherwise,  
	 mf = [];
	 disp('ERROR:  specified datatype is not supported');
	 return;
   end

   if isempty(origin)
      origin = [0 0 0 0 0];
   else
      origin = [origin(:)' 0 0];
   end;

   description = zeros(1,80);
   idx = (1:min([length(descrip) 79]));
   description(idx) = descrip(idx);

   %  start the file i/o operations
   %
   fid = fopen(hfile,'w');
   [fname,fperm,mf] = fopen(fid);	% obtain the machine format

   db_name = [hfile '                 '];

   fwrite(fid,348,'int32');
   fwrite(fid,['dsr      ' 0],'char'); 
   fwrite(fid,[db_name(1:17) 0],'char'); 
   fwrite(fid,0,'int32');
   fwrite(fid,0,'int16');
   fwrite(fid,'r','char');
   fwrite(fid,'0','char');


   fseek(fid,40,'bof');

   fwrite(fid,dims,'int16');
   fwrite(fid,'mm','char');
   fwrite(fid,zeros(1,10),'char');
   fwrite(fid,0,'int16');
   fwrite(fid,datatype,'int16');
   fwrite(fid,bits,'int16');
   fwrite(fid,0,'int16');
   fwrite(fid,pixdim,'float');
   fwrite(fid,0,'float');
   fwrite(fid,1,'float');
   fwrite(fid,zeros(1,4),'float');
   fwrite(fid,zeros(1,2),'int32');
   fwrite(fid,glmax,'int32');
   fwrite(fid,glmin,'int32');

   fwrite(fid,description,'char');
   fwrite(fid,['none                   ' 0],'char');
   fwrite(fid,0,'char');
   fwrite(fid,origin,'int16');
   fwrite(fid,zeros(1,85),'char');

   fclose(fid);

   return;



%------------------------------------------------------------------------
function  out_file(fname,img,scaling_flg,datatype,dims,mf,maxval,minval);
%
%
   [img_path,iname,iext] = fileparts(fname);

   switch (datatype) 
      case  {2},  glmax = 255;
      case  {4},  glmax = 32767;
      case  {8},  glmax = (2^31-1);
      otherwise,  glmax = maxval; % glmax = 1;
   end

   % write the image data 
   
   num_voxels = prod(dims);
   img=reshape(img,[1,num_voxels]);
   
   if (scaling_flg == 1 & glmax > 1)
     max_img = max(img(:));
     min_img = min(img(:));
   
     factor = glmax / (max_img - min_img);
     img = (img - min_img) * factor; 
   end
   
   ofile = fullfile(img_path, [iname '.img']); 
   fid = fopen(ofile,'w',mf);
     switch datatype 
        case 2, out_num = fwrite(fid,img,'uchar');
        case 4, out_num = fwrite(fid,img,'int16');
        case 8, out_num = fwrite(fid,img,'int32');
        case 16, out_num = fwrite(fid,img,'float');
        case 64, out_num = fwrite(fid,img,'double');
        otherwise,  disp('Image data type is not supported!')
     end
   fclose(fid);
   
   if num_voxels ~= out_num
     disp('Error for writing IMG data');
   end

   return;

