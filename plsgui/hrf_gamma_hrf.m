%  AFNI 3dDeconvolve -stim_times 'GAM' default option
%  http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dDeconvolve.html
%
function hrf = hrf_gamma_hrf(TR)

   p = 8.6; q = 0.547;
   t = [0:TR:11]';
   hrf = (t./(p*q)).^p.*exp(p-t./q);

   return;

