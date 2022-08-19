%-----------------------------------------------------------------------------
function mat = rri_expandvec(mat, n)

   [r c]=size(mat);

   mat = reshape(mat, [1 length(mat(:))]);
   mat = repmat(mat, [n, 1]);
   mat = reshape(mat, [r*n c]);

   return;

