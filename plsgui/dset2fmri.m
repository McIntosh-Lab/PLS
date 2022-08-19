%  'dset2fmri' will read SUMA processed dset text file (ended with
%  .1D.dset) and PLSgui sessiondata file. It will replace 'st_datamat'
%  variable in fMRI sessiondata with SUMA processed data. i.e. The
%  original fMRI sessiondata file will be overwritten.
%
%  The input of 'dset2fmri' function is a SUMA processed dset text file
%  (ended with .1D.dset), and a file name of PLSgui fMRI sessiondata
%  (*fMRIsessiondata.mat).
%
%  As a result, the original PLSgui fMRI datamat file will be overwritten.
%
%  Usage:  dset2fmri(dset_text_filename, fmri_sessiondata_filename);
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function dset2fmri(dset_text_filename, fmri_sessiondata_filename)

   if nargin < 2
      error('Usage:  dset2fmri(dset_text_filename, fmri_sessiondata_filename);');
   end

   if length(dset_text_filename) < 9 | ~strcmp(dset_text_filename(end-7:end), '.1D.dset')
      error('dataset text filename must be ended with ''.1D.dset''');
   end

   if length(fmri_sessiondata_filename) < 20 | ~strcmp(fmri_sessiondata_filename(end-14:end), 'sessiondata.mat')
      error('PLSgui session filename must be ended with ''*sessiondata.mat''');
   end

   load(fmri_sessiondata_filename);
   prefix = session_info.datamat_prefix;
   clear session_info;
   brain_size = length(st_coords);

   img = load(dset_text_filename);
   img = img';
   st_datamat = reshape(img, [round(size(img,1)/st_win_size), round(size(img,2)*st_win_size)]);

   clear dset_text_filename fmri_sessiondata_filename prefix brain_size img;
   save(fmri_sessiondata_filename);

   return;

