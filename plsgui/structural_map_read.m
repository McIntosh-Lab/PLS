%  Usage: [value label mapimg] = structural_map_read('structural_map');
%         (make sure to use 'structural_map', not 'structural_map.txt')
%
function [value,label,mapimg] = structural_map_read(fn)

   [value label] = textread([fn '.txt'], '%d %s');
   mapimg = load_nii([fn '.nii']);
   mapimg = mapimg.img(:);

   return;

