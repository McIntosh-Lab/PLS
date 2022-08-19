function data = fmri_read_profiles(filename)
%function data = fmri_read_profiles(filename)

   fid = fopen(filename);

   if fid == -1
      error([filename, ': Can''t open file']);
      return;
   end

   i = 1;
   while ~feof(fid)
      tmp = fliplr(deblank(fliplr(deblank(fgetl(fid)))));

      if ~isempty(tmp)
         data{i,1} = tmp;
         i = i + 1;
      end
   end

   fclose(fid);

   return;

