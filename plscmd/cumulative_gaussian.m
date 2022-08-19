%CUMULATIVE_GAUSSIAN: the integral of the Gaussian distribution, which
%  gives the probability that a variate will assume a value <= x, and also
%  equals to D(x) = (1 + erf((x-mu)/(sigma*sqrt(2)))) / 2   ( cited from
%  Eric W. Weisstein. "Normal Distribution." From MathWorld--A Wolfram Web
%  Resource. http://mathworld.wolfram.com/NormalDistribution.html )
%
%  Usage: D = cumulative_gaussian(x, mu, sigma)
%
function D = cumulative_gaussian(x, mu, sigma)

   if nargin < 3, 
      sigma = 1;
   end

   if nargin < 2;
      mu = 0;
   end

   if prod(size(mu)) == 1				% mu is a scalar
      mu = mu*ones(size(x));
   end

   if prod(size(sigma)) == 1				% sigma is a scalar
      sigma = sigma*ones(size(x));
   end

   D = zeros(size(x));					% init output D

   idx = find(sigma <= 0);				% bad data

   if any(idx)
      x1 = NaN;
      x(idx) = x1(ones(size(idx)));
   end

   idx = [1:length(sigma(:))];
   D(idx) = (1 + erf((x(idx) - mu(idx)) ./ (sigma(idx) * sqrt(2)))) / 2;

   %  D should be greater than or equal to 0, and less than or equal to 1
   %
   idx = find(D<0);

   if any(idx)
      D(idx) = zeros(size(idx));
   end

   idx = find(D>1);

   if any(idx)
      D(idx) = ones(size(idx));
   end

   return;						% cumulative_gaussian

