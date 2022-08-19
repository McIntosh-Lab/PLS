%rri_ceil: ceil the quotient to its range (not just 1)
%
%  usage: rounded_div = rri_ceil(divident, dividor)
%
%  e.g. rri_ceil(1.1,4) will return 0.3
%	rri_cell(0.11,4) will return 0.03
%
%-------------------------------------------------

function div = rri_ceil(divident, divisor)

   div = divident / divisor;
   factor = power(10, ceil(log10(1/div)));
   div = ceil(div * factor) / factor;

   return;


