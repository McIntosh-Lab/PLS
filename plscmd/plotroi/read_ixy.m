%  Read an xyz file. If electrode coord name exists, it also output ec_name.
%
%  Usage: [ec_name xyz] = read_xyz(xyz_file);
%

%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%
%-------------------------------------------------------------------------
function [ec_name, xyz] = read_xyz(xyz_file, removeduplicate)

   if ~exist('removeduplicate','var')
      removeduplicate = 0;
   end

   try

      xyz = load(xyz_file);
      ec_name = '';

   catch

      fid = fopen(xyz_file);		% open file

      if fid == -1			% error to open the file
         error([xyz_file, ': Can''t open file']);
         return;
      end

%      fgetl(fid);			% ignore 1 line that is header

      %  read the rest line and convert it to double and char
      %
      ec_name = '';
      i = 1;
      while ~feof(fid)
         tmp = fgetl(fid);
         if ~ischar(tmp) | isempty(tmp), break, end

         [x tmp] = strtok(tmp);
         [y tmp] = strtok(tmp);
         [z tmp] = strtok(tmp);

         xyz(i,:) = str2num([x ' ' y ' ' z]);

         [nam r] = strtok(tmp);
         ec_name = strvcat(ec_name, nam);

         i = i + 1;
      end

      fclose(fid);			% close file

   end

   [tmp idx] = sort(xyz(:,1));
   xyz = xyz(idx,:);

   if ~isempty(ec_name)
      ec_name = ec_name(idx,:);
   end

   if removeduplicate
      [tmp idx] = unique(xyz(:,1));
      xyz = xyz(idx,:);

      if ~isempty(ec_name)
         ec_name = ec_name(idx,:);
      end
   end

%   xyz(:,1) = [1:size(xyz,1)]';

   if isempty(ec_name)
      ec_name = [char(ones(size(xyz,1),1)*'Region ') num2str(xyz(:,1),'%-1d')];
   end

   return;						% read_xyz

