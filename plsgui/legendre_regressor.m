%  This program will create a matrix with Legendre Polynomials up to
%  pnum degree. This matrix will be appended to the Design Matrix to
%  form General Linear Regressors that will be used to compute fit 
%  images. By default, pnum is 0, which creates a matrix with a
%  single column of all ones.
%
%  Usage:  regressor = legendre_regressor(num_scan, pnum)
%
function regressor = legendre_regressor(num_scan, pnum)

   if nargin < 1
      error('Usage:  regressor = legendre_regressor(num_scan, pnum);');
   elseif nargin < 2
      pnum = 0;
   end

   regressor = [];

   for i = 0:pnum
      tmp = legendre(i,linspace(-1,1,num_scan));
      tmp = tmp(1,:);
      regressor = [regressor tmp'];
   end

   return;

