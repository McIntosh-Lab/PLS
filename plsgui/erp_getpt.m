% ERP_GETPT given x & y, return [phi, theta]
%
%    Usage: [phi, theta] = erp_getpt(x, y)
%
function [phi, theta] = erp_getpt(x, y)

   theta = -sqrt( ((x - 10) * 10).^2 + ((y - 10) * 100).^2 ) / 8.5;

   idx = find(theta==0);
   theta(idx) = 1;
   phi = asin( (y - 10) * 100 ./ (8.5 * theta) ) * 360 / (2*pi);
   phi(idx) = 0;

   return

