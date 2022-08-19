%  Used by:	bfm_hrf_get_datamat
%  Usage:	nii = hrf_load_untouch1_nii(fname,1);
%  Purpose:	Just get the correct nii.hdr
%		(neither pure NIfTI nor pure ANALYZE)
%		nii.img = nii_all(result).img
%		then, apply nii = xform_nii(nii);
%		then, nii.img = nii.img(orient_pattern);
%
%		In order to get nii_all(result).img,
%		we have to get it slice by slice:
%		First, use nii = load_nii(fname,1) to check xform validility
%		then, nii_slice = load_untouch_nii(fname, img_idx, '', '', '', '', slice_idx);
%		combine all slices, and process, will get nii_all(result).img
%
function nii = hrf_load_untouch1_nii(filename, img_idx, dim5_idx, dim6_idx, dim7_idx, ...
			old_RGB, slice_idx)

   if ~exist('filename','var')
      error('Usage: nii = hrf_load_untouch1_nii(filename, [img_idx], [dim5_idx], [dim6_idx], [dim7_idx], [old_RGB], [slice_idx])');
   end

   if ~exist('img_idx','var') | isempty(img_idx)
      img_idx = [];
   end

   if ~exist('dim5_idx','var') | isempty(dim5_idx)
      dim5_idx = [];
   end

   if ~exist('dim6_idx','var') | isempty(dim6_idx)
      dim6_idx = [];
   end

   if ~exist('dim7_idx','var') | isempty(dim7_idx)
      dim7_idx = [];
   end

   if ~exist('old_RGB','var') | isempty(old_RGB)
      old_RGB = 0;
   end

   if ~exist('slice_idx','var') | isempty(slice_idx)
      slice_idx = [];
   end

   %  Read the dataset header
   %
   [nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = load_nii_hdr(filename);

%   if nii.filetype == 0
 %     nii.hdr = load_untouch0_nii_hdr(nii.fileprefix,nii.machine);
  %    nii.ext = [];
   %else
%      nii.hdr = load_untouch_nii_hdr(nii.fileprefix,nii.machine,nii.filetype);

%      %  Read the header extension
 %     %
  %    nii.ext = load_nii_ext(filename);
   %end

   %  Read the dataset body
   %
   [nii.img,nii.hdr] = load_untouch_nii_img(nii.hdr,nii.filetype,nii.fileprefix, ...
		nii.machine,img_idx,dim5_idx,dim6_idx,dim7_idx,old_RGB,slice_idx);

   %  Perform some of sform/qform transform
   %
%   nii = xform_nii(nii, tolerance, preferredForm);

   nii.untouch = 1;

   return					% load_untouch_nii

