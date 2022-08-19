% img is image in Axial View [x, y, 1, slice]
% if sa == 1, output image in Sagittal View [y, slice, 1, x]
% if sa == 0, output image in Coronal View [x, slice, 1, y]
%
function img_sa = rri_axial2other(img, sa)

   if sa == 1
      img_sa = flipdim(permute(img,[2,4,3,1]),1);
   elseif sa == 0
      img_sa = permute(img,[1,4,3,2]);
   end

   return;

   dims = size(img);
   img = squeeze(img);

   if sa == 1
      for i = 1:dims(2)
         img_sa(i,:,:) = (squeeze(img(:,i,:)))';
      end
      img_sa = flipdim(img_sa,1);
   elseif sa == 0
      for i = 1:dims(1)
         img_sa(i,:,:) = (squeeze(img(i,:,:)))';
      end
   end

   dims = size(img_sa);
   img_sa = reshape(img_sa, [dims(1), dims(2), 1, dims(3)]);

   return;

