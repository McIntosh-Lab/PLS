%  'plsgui2dset' will read PLSgui result file (ended with *result.mat), and
%  convert it to brain dataset text files (ended with .1D.dset). The dset
%  files can be loaded in SUMA's Surface Controller window, together with
%  other files: .spec, .sphere.asc, sphere.reg, .inflated.asc, .pial.asc,
%  .white.asc, .smoothwm.asc, .annot.niml.dset, etc.
%
%  The input of 'plsgui2dset' function is a PLSgui result file *result.mat.
%  Optionally, you can also provide which latent variable (LV) of data you
%  will get from the result. You can specify a range like [1,2,5] or [1:3].
%  By default, LV is set to 1.
%
%  The output files will look like .BLV.LV#.1D.dset (for Brain LV result).
%  If there is Bootstrap test, the output files will have .BSR.LV#.1D.dset
%  (for Bootstrap Ratio result). The prefix will of the output files will
%  use the portion of PLSgui result file before 'result.mat'. If it is an
%  Event Related fMRI PLS result, all lags of the temporal window will be
%  stored in one 1D.dset file, which is like multi-scan (e.g. 140) data.
%
%  Usage:  plsgui2dset(plsgui_result_filename, [LV#s]);
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function plsgui2dset(plsgui_result_filename, LV)

   bsr = [];
   blv = [];

   if nargin < 1
      error('Usage: plsgui2dset(plsgui_result_filename, [LV#s]);');
   end

   if length(plsgui_result_filename) < 15 | ~strcmp(plsgui_result_filename(end-9:end), 'result.mat')
      error('PLSgui result filename must be ended with ''*result.mat''');
   end

   if nargin < 2
      LV = 1;
   end

   prefix = plsgui_result_filename;
   prefix = strrep(prefix, 'result.mat', '');

   if length(plsgui_result_filename)>15 & strcmp(plsgui_result_filename(end-13:end),'fMRIresult.mat')

      load(plsgui_result_filename);
      brain_size = length(st_coords);

      blv = brainlv;
      blv = reshape(blv, [st_win_size, brain_size, size(blv,2)]);
      blv = permute(blv, [2 1 3]);
      blv = squeeze(blv);

      if exist('boot_result','var') & isfield(boot_result,'compare')
         bsr = boot_result.compare;
         bsr = reshape(bsr, [st_win_size, brain_size, size(bsr,2)]);
         bsr = permute(bsr, [2 1 3]);
         bsr = squeeze(bsr);
      end

   elseif ~isempty(findstr(plsgui_result_filename, '_PETresult.mat'))

      load(plsgui_result_filename);
      blv = brainlv;
      bsr = boot_result.compare;

   elseif ~isempty(findstr(plsgui_result_filename, '_STRUCTresult.mat'))

      load(plsgui_result_filename);
      blv = brainlv;
      bsr = boot_result.compare;

   else
      error('Unknown PLSgui module.');
   end

   for i = LV

      fid = fopen([prefix '.BLV.' num2str(i) '.1D.dset'], 'wb');

      if ndims(blv) == 3
         img = blv(:,:,i);

         for j = 1:size(img,1)
            for k = 1:size(img,2)
               fprintf(fid, '%.6f   ', img(j,k));
            end

            fprintf(fid, '\n');
         end
      else
         img = blv(:,i);

         for j = 1:length(img)
            fprintf(fid, '%.6f   ', img(j));
            fprintf(fid, '\n');
         end
      end

      fclose(fid);

      if ~isempty(bsr)
         fid = fopen([prefix '.BSR.' num2str(i) '.1D.dset'], 'wb');

         if ndims(bsr) == 3
            img = bsr(:,:,i);

            for j = 1:size(img,1)
               for k = 1:size(img,2)
                  fprintf(fid, '%.6f   ', img(j,k));
               end

               fprintf(fid, '\n');
            end
         else
            img = bsr(:,i);

            for j = 1:length(img)
               fprintf(fid, '%.6f   ', img(j));
               fprintf(fid, '\n');
            end
         end

         fclose(fid);
      end

   end

   return;

