%------------------------------------------------------------
function [pathname,filename] = rri_fileparts(full_filename)

   r = full_filename;
   o = r;

   %  can not use filesep, because the full_filename string
   %  is imported from a different platform
   %
   %  arch = computer;
   %  ispc = strcmp(arch(1:2),'PC');
   %
   while ~isempty(r)

      if isempty(findstr(r, '/'))
         [filename r] = strtok(r,'\');
      else
         [filename r] = strtok(r,'/');
      end

   end

   r = findstr(o,filename) - 2;		% take out '\' and last char
   pathname = o(1:r(end));

   return;

