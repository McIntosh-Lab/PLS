% MATLAB7TO5: In order to load results generated using Matlab 7 on 
%	earlier versions of Matlab, a special Matlab 7 switch must 
%	be included during the saving process. Since such a switch
%	is not coded in the package, this small program is used to
%	covert the .mat files generated from Matlab 7 to be loaded
%	on earlier versions of Matlab that are above Matlab 5.
%
% Usage:	matlab7to5('abc.mat') or simply:
%		matlab7to5('*.mat')
%
function matlab7to5(files)

   v = version;
   v = str2num(v(1));

   if v < 7
      error('You must run this program under Matlab 7.');
   end

   if ~exist('files','var') | ~ischar(files)
      error('Usage: matlab7to5(''abc.mat''); or, matlab7to5(''*.mat'');');
   end

   files = dir(files);

   for i = 1:length(files)
      fn = files(i).name;
      s = load(fn);
      save(fn,'-V6','-STRUCT','s');
      disp(['File ', fn, ' has been converted.']);
   end

   return;						% matlab7to5

