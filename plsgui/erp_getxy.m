% ERP_GETXY given phi & theta, return [x y]
%
%    Usage: [x y] = erp_getxy(phi, theta)
%
function [x, y] = erp_getxy(phi, theta)

   x = 10 + 8.5 * cos(phi * 2*pi/360) .* theta/10;
   y = 10 + 8.5 * sin(phi * 2*pi/360) .* theta/100;

   return

