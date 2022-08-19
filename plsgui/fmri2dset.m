%  'fmri2dset' will read PLSgui fMRI sessiondata file. The 'st_datamat'
%  variable will be converted to dset text file (ended with .1D.dset)
%  for SUMA processing.
%
%  The input of 'fmri2dset' function is a file name of PLSgui fMRI
%  sessiondata (*fMRIsessiondata.mat).
%
%  The output file will look like .1D.dset. The prefix of the output file
%  will use 'session_info.datamat_prefix' stored in fMRI session / datamat
%  prefix.
%
%  Usage:  fmri2dset(fmri_sessiondata_filename);
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function fmri2dset(fmri_sessiondata_filename)

   img = [];

   if nargin < 1
      error('Usage:  fmri2dset(fmri_sessiondata_filename);');
   end

   if length(fmri_sessiondata_filename) < 20 | ~strcmp(fmri_sessiondata_filename(end-14:end), 'sessiondata.mat')
      error('PLSgui session filename must be ended with ''*sessiondata.mat''');
   end

   load(fmri_sessiondata_filename);
   prefix = session_info.datamat_prefix;
   brain_size = length(st_coords);

   img = st_datamat;
   img = reshape(img, [size(img,1) * st_win_size, brain_size]);
   img = img';

   fid = fopen([prefix '.1D.dset'], 'wb');

   for j = 1:size(img,1)
      for k = 1:size(img,2)
         fprintf(fid, '%.6f   ', img(j,k));
      end

      fprintf(fid, '\n');
   end

   fclose(fid);

   return;

