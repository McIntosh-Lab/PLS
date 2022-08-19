%  'dset2img' will take a brain dataset text file (ended with .1D.dset),
%  and convert it to a 4D NIfTI image file and a 3D brain mask file to be
%  used for PLSgui.
%
%  Since the location of each voxel is not on regular cubic grid, the above
%  NIfTI file does not make sense by itself. However, this won't affect the
%  computation in PLSgui.
%
%  Although you cannot show PLS result of this dataset directly under PLSgui
%  window, you can use 'plsgui2dset' to convert BrainLV (BSRatio) into brain
%  dataset text file (ended with .1D.dset), and load it into SUMA for
%  visualization.
%
%  The input of 'dset2img' function is a brain dataset text file .1D.dset.
%  Optionally, you can also provide the NIfTI image file name. Otherwise,
%  it will take the prefix of the '.1D.dset' file as the prefix of the NIfTI
%  file. Besides outputing the NIfTI file, it will also output a 3D brain
%  mask file for brain region.
%
%  Usage:  dset2img(dataset_text_filename, [output_filename_prefix]);
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function dset2img(dataset_text_filename, output_filename_prefix)

   if nargin < 1
      error('Usage: dset2img(dataset_text_filename, [output_filename_prefix]);');
   end

   if length(dataset_text_filename) < 9 | ~strcmp(dataset_text_filename(end-7:end), '.1D.dset')
      error('dataset text filename must be ended with ''.1D.dset''');
   end

   if nargin < 2
      output_filename_prefix = dataset_text_filename(1:end-8);
   end

   dataset = load(dataset_text_filename);

   [brain_length, num_vol] = size(dataset);

   dimx = ceil(brain_length^(1/3));
   dim = [dimx dimx dimx];

   img = zeros(dimx^3, 1);
   img(1:brain_length) = 1;
   img = reshape(img, dim);
   brain_mask = make_nii(img);
   save_nii(brain_mask, [output_filename_prefix '.brainmask.img']);

   img = zeros(dimx^3, num_vol);
   img(1:brain_length, :) = dataset;
   img = reshape(img, [dim num_vol]);
   nii = make_nii(img);
   save_nii(nii, [output_filename_prefix '.nii']);

   return;

