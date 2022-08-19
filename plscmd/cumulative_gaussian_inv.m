%CUMULATIVE_GAUSSIAN_INV: the inverse function of the Cumulative Gaussian
%  distribution function. Since Cumulative Gaussian distribution function
%  D=(1+erf((x-mu)/(sigma*sqrt(2))))/2   ( cited from Eric W. Weisstein.
%  "Normal Distribution." From MathWorld--A Wolfram Web Resource. 
%  http://mathworld.wolfram.com/NormalDistribution.html ), we now have:
%  (x-mu)/(sigma*sqrt(2)) = erfinv(2*D-1), thus we can get:
%  x = sigma*sqrt(2)*erfinv(2*D-1)+mu
%
%  Usage: x = cumulative_gaussian_inv(D, mu, sigma)
%
function x = cumulative_gaussian_inv(D, mu, sigma)

   if nargin < 3, 
      sigma = 1;
   end

   if nargin < 2;
      mu = 0;
   end

   if prod(size(mu)) == 1				% mu is a scalar
      mu = mu*ones(size(D));
   end

   if prod(size(sigma)) == 1				% sigma is a scalar
      sigma = sigma*ones(size(D));
   end

   x = zeros(size(D));					% init output x

   idx = find(sigma <= 0 | D < 0 | D > 1);		% bad data

   if any(idx)
      x1 = NaN;
      x(idx) = x1(ones(size(idx)));
   end

   idx = find(sigma > 0 & D > 0  &  D < 1);

   if any(idx)
      x(idx) = sigma(idx) .* sqrt(2) .* erfinv(2 * D(idx) - 1) + mu(idx);
   end

   idx = find(D == 0);

   if any(idx)
      x1 = Inf;
      x(idx) = -x1(ones(size(idx)));
   end

   idx = find(D == 1);

   if any(idx)
      x1 = Inf;
      x(idx) = x1(ones(size(idx)));
   end

   return;						% cumulative_gaussian_inv

