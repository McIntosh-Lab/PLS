%NORMALIZE  Normalize Euclidean distance of vectors in original 
%	matrix to unit 1.
%
%  Usage: normal = normalize(origin, [DIM]);
%
%  origin:	original matrix
%  normal:	vectors in original matrix have been normalized
%  DIM:		direction of vectors in original matrix. It can
%	be either 1 or 2. DIM = 1 stands for vectors are stacked
%	in column-wise. DIM = 2 stands for vectors are stacked in
%	row-wise.
%
%  By default, DIM is 1, which means that vector [x, y, z, ...] is
%  stacked in column-wise (e.g. to test orthonormal matrix). Some
%  time, DIM needs to be set to 2 (e.g. ec.xyz or dg.xyz file).
%

%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%
%-------------------------------------------------------------------------
function normal = normalize(origin, DIM)

   if ~exist('DIM','var')
      DIM = 1;
   end;

   normal_base = sqrt(sum(origin.^2, DIM));

   if DIM == 1
      normal_base = repmat(normal_base, [size(origin, DIM), 1]);
   elseif DIM == 2
      normal_base = repmat(normal_base, [1, size(origin, DIM)]);
   end

   zero_items = find(normal_base==0);			% bad col. or row.
   normal_base(zero_items) = 1;

   normal = origin ./ normal_base;
   normal(zero_items) = 0;

   return;						% normalize

