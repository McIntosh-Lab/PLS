% function [xyz_tal] = mni2tal(xyz_mni)
%
% This script was written by Scott D. Slotnick and is intended for free use by the neuroimaging community
%
% Modified 12/14/03, for updated version see http://www.wjh.harvard.edu/~slotnick/scripts.htm
%
% This script should not be used, in full or part, for financial gain
%
% Use at your own risk
%
% If you find a bug, please e-mail slotnick@wjh.harvard.edu
%
% This function converts from MNI coordinates (i.e. SPM analysis output) to Talairach coordinates
%
% Each to-be-converted MNI coordinate constitutes a row in data matrix xyz_mni, separated by semi-colons
%
% function [xyz_tal] = mni2tal(xyz_mni)
%
% Example, mni2tal([40 -16 -30; -45 -73 -12])
%
function [xyz_tal] = mni2tal(xyz_mni)

x = xyz_mni(:,1); 
y = xyz_mni(:,2); 
z = xyz_mni(:,3);

if z >= 0
  x_tal = 0.99*x;
  y_tal = 0.9688*y + 0.0460*z;
  z_tal = -0.0485*y + 0.9189*z;
else
  x_tal = 0.99*x;
  y_tal = 0.9688*y + 0.0420*z;
  z_tal = -0.0485*y + 0.8390*z;
end

xyz_tal = [x_tal y_tal z_tal];

