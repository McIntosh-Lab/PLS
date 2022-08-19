function h_matrix = rri_helmert_matrix(num_rows)
%
% USAGE:  helmert_matrix = rri_helmert_matrix(num_rows)
%
%   Generate the Helmert matrix with a given row size
%

  nc = num_rows-1;
  nr = num_rows;

  c = zeros(nr,nc);
  for i=1:nc;
     c(i,i) = num_rows-i;
     c(i+1:nr,i) = -1;
  end;

  h_matrix = normalize(c);

  return;					% rri_helmert_matrix

