%-----------------------------------------------------------------------------
function ssb_mat = ssb_rri_expandvec(mat, n)

   [r c]=size(mat);
   ssb_mat = [];

   for i=1:r
      tmp = mat(i,:);
      ssb_mat = [ssb_mat; repmat(tmp, [n(i), 1])];
   end

   return;

