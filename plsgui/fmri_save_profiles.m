function fmri_save_profiles(filename, data)

   fid = fopen(filename, 'wt');

   if fid == -1
      error([filename, ': Can''t open file']);
      return;
   end

   num_profiles = length(data);
   for i=1:num_profiles,
      fprintf(fid,'%s\n',data{i});
   end;

   fclose(fid);

   return;

