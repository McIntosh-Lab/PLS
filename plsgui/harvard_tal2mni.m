% function [xyz_mni] = tal2mni(xyz_tal)
%
% This script was written by Lauren R. Moo and is intended for free use by the neuroimaging community
%
% Modified 1/08/05, for updated version see http://www.wjh.harvard.edu/~slotnick/scripts.htm
%
% This script should not be used, in full or part, for financial gain
%
% Use at your own risk
%
% If you find a bug, please e-mail lmoo@partners.org
%
% This function converts from Talairach coordinates to MNI coordinates
%
% For example, mni2tal([40, -17, -24])
%
function [xyz_mni] = tal2mni(xyz_tal)

x = xyz_tal(:,1); 
y = xyz_tal(:,2); 
z = xyz_tal(:,3);

a=0.99;
b=0.9688;
c=0.0460;

d=-0.0485;
e=0.9189;

f=0.0420;
g=0.8390;

if (z-d*y)/e >= 0
  xm = x/a;
  ym = (e*y)/(b*e-c*d) - (c*z)/(b*e-c*d);
  zm = (z/e) - (d/e)*((e*y-c*z)/(b*e-c*d));
else
  xm = x/a;
  ym = (e*y)/(b*e-f*d) - (f*z)/(b*e-f*d);
  zm = (z/g) - (d/g)*((e*y-c*z)/(b*e-c*d));
end

xyz_mni = [xm ym zm];

