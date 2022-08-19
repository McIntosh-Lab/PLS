%RRI_RUBBERBAND provide a rubberband to let user select a rectangular
%	region, and output the positions
%
%   Usage: [ll ur] = rri_rubberband;
%
%   O (ll) - means lower left [x y] position;
%   O (ur) - means upper right [x y] position;
%

%   Created on Jan 20, 2003
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [p1, p2] = rri_rubberband

   set(gcf,'pointer','crosshair');
   waitforbuttonpress;	point1 = get(gca,'CurrentPoint');
   rbbox;		point2 = get(gca,'CurrentPoint');
   set(gcf,'pointer','arrow');

   point1 = point1(1,1:2);
   point2 = point2(1,1:2);
   offset = abs(point1-point2);

   p1 = min([point1;point2]);
   p2 = [p1(1)+offset(1), p1(2)+offset(2)];

   return;

