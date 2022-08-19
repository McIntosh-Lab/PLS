function [selected_file, selected_dir] = rri_selectfile(varargin)

   if nargin == 0
      [selected_file, selected_dir] = selectafile;
   elseif nargin == 1
      [selected_file, selected_dir] = selectafile(varargin{1});
   elseif nargin == 2
      [selected_file, selected_dir] = selectafile(varargin{1}, varargin{2});
   end;

   return;

