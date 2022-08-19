%  This function is used to alter the onset values in type one batch script
%  for creating fMRI session/datamat files.
%
%  Usage: batch_alter_fmri_onset(old_batch_script, new_batch_script, ...
%			new_onset_files, new_cond_name)
%  Where,
%
%  - old_batch_script:  The file name for old batch script;
%
%  - new_batch_script:  The file name for new batch script;
%
%  - new_onset_files:   It can be a file pattern (use wildcard) for the new
%	onset files if their file names are in the order of runs, or a cell
%	array that lists all the new onset files run by run.
%
%  - new_cond_name:	It can be a text file containing new condition names
%	row by row, or a cell array listing them one by one.
%
%  e.g.:  batch_alter_fmri_onset( 'batch_fmri_data1_1438_s1.txt', ...
%			'batch_fmri_data1_1438_s1_4cond.txt', ...
%			{'four_JM_58_learning_scan11.txt', ...
%			 'four_JM_58_learning_scan12.txt', ...
%			 'four_JM_58_learning_scan13.txt', ...
%			 'four_JM_58_learning_scan14.txt', ...
%			 'four_JM_58_learning_scan15.txt'}, ...
%			{'correct_correct', 'correct_incorrect', ...
%			 'incorrect_correct', 'incorrect_incorrect'} )
%
%  or:    batch_alter_fmri_onset( 'batch_fmri_data1_1438_s1.txt', ...
%			'batch_fmri_data1_1438_s1_4cond.txt', ...
%			'four*.txt', 'new_cond_name.txt' )
%
function batch_alter_fmri_onset(old_batch_script, new_batch_script, ...
			new_onset_files, new_cond_name)

   if nargin < 4
      error('Usage: batch_alter_fmri_onset(old_batch_script, new_batch_script, new_onset_files, new_cond_name)');
   end

   if ischar(new_onset_files)
      file_lst=dir(new_onset_files);
      new_onset_files = {file_lst.name};
   end

   if ischar(new_cond_name)
      new_cond_name = read_cond_name(new_cond_name);
   end

   new_num_run = length(new_onset_files);

   for i=1:new_num_run
      onset{i} = read_onset_file(new_onset_files{i});

      if i>1 & length(onset{i}) ~= new_num_cond
         error(['Number of rows does not match in onset file: ' new_onset_files{i}]);
      end

      new_num_cond = length(onset{i});

      if length(new_cond_name) ~= new_num_cond
         error(['Number of rows does not match in onset file: ' new_onset_files{i}]);
      end
   end

   fid = fopen(old_batch_script);

   if fid == -1			% error to open the file
      error([old_batch_script, ': Can''t open file']);
   end

   session.prefix = '';				% all
   session.dataset_path = '';			% struct
   session.brain_region = '';			% all but erp
   session.win_size = 8;			% fmri
   session.across_run = 1;			% mri
   session.single_subj = 0;			% mri
   session.single_ref_scan = 0;			% mri
   session.single_ref_onset = 0;		% mri
   session.single_ref_number = 1;		% mri
   session.normalize = '';			% struct

   session.cond_name = {};			% all
   session.cond_filter = {};			% struct
   ref_scan_onset = [];				% mri
   num_ref_scan = [];				% mri

   subj_file = {};				% erp, pet, struct
   session.subject = {};			% erp, pet, struct
   session.subj_name = {};			% struct, (erp, pet)
   session.subj_files = {};			% erp, pet, struct
   session.img_ext = '*.img';			% pet, struct
   session.chan_in_col = 0;			% erp

   session.prestim = 0;				% erp
   session.interval = 2;			% erp
   session.chan_order = [];			% erp
   system_class = 1;				% erp
   system_type = 1;				% erp
   binary_vendor = '';				% erp
   binary_endian = 'ieee-le';			% erp

   session.data_files = {};			% mri
   session.data_path = {};			% mri
   session.file_pattern = {};			% mri
   event_onsets = {};				% fmri
   block_onsets = {};				% bfm
   block_length = {};				% bfm

   wrongbatch = 0;

   while ~feof(fid)

      tmp = fgetl(fid);

      if ischar(tmp) & ~isempty(tmp)
         tmp = strrep(tmp, char(9), ' ');
         tmp = deblank(fliplr(deblank(fliplr(tmp))));
      end

      while ~feof(fid) & (isempty(tmp) | isnumeric(tmp) | strcmpi(tmp(1), '%'))
         tmp = fgetl(fid);

         if ischar(tmp) & ~isempty(tmp)
            tmp = strrep(tmp, char(9), ' ');
            tmp = deblank(fliplr(deblank(fliplr(tmp))));
         end
      end

      if ischar(tmp) & ~isempty(tmp)
         [tok rem] = strtok(tmp);

         if ~isempty(rem)
            [rem junk] = strtok(rem, '%');
            rem = deblank(fliplr(deblank(fliplr(rem))));
         end
      else
         tok = '';
      end

      switch tok
      case 'prefix'
         if isempty(rem), wrongbatch = 1; end;
         session.prefix = rem;
      case 'dataset_path'
         if isempty(rem), wrongbatch = 1; end;
         session.dataset_path = rem;
      case 'brain_region'
         if isempty(rem), wrongbatch = 1; end;

         if isempty(str2num(rem))
            session.brain_region = rem;
         else
            session.brain_region = str2num(rem);
         end
      case 'win_size'
         session.win_size = str2num(rem);
         if isempty(session.win_size), session.win_size = 8; end;
      case 'across_run'
         session.across_run = str2num(rem);
         if isempty(session.across_run), session.across_run = 1; end;
      case 'single_subj'
         session.single_subj = str2num(rem);
         if isempty(session.single_subj), session.single_subj = 0; end;
      case 'single_ref_scan'
         session.single_ref_scan = str2num(rem);
         if isempty(session.single_ref_scan), session.single_ref_scan = 0; end;
      case 'single_ref_onset'
         session.single_ref_onset = str2num(rem);
         if isempty(session.single_ref_onset), session.single_ref_onset = 0; end;
      case 'single_ref_number'
         session.single_ref_number = str2num(rem);
         if isempty(session.single_ref_number), session.single_ref_number = 1; end;
      case 'cond_name'
         if isempty(rem), wrongbatch = 1; end;
         session.cond_name = [session.cond_name {rem}];
      case 'cond_filter'
         if isempty(rem), wrongbatch = 1; end;
         session.cond_filter = [session.cond_filter {rem}];
      case 'ref_scan_onset'
         rem = str2num(rem);
         if isempty(rem), rem = 0; end;
         ref_scan_onset = [ref_scan_onset rem];
      case 'num_ref_scan'
         rem = str2num(rem);
         if isempty(rem), rem = 1; end;
         num_ref_scan = [num_ref_scan rem];
      case 'data_files'
         session.data_files = [session.data_files {rem}];
      case 'event_onsets'
         if isempty(rem), wrongbatch = 1; end;
         event_onsets = [event_onsets {str2num(rem)}];
      case 'block_onsets'
         if isempty(rem), wrongbatch = 1; end;
         block_onsets = [block_onsets {str2num(rem)}];
      case 'block_length'
         if isempty(rem), wrongbatch = 1; end;
         block_length = [block_length {str2num(rem)}];
      case 'prestim'
         session.prestim = str2num(rem);
         if isempty(session.prestim), session.prestim = 0; end;
      case 'interval'
         session.interval = str2num(rem);
         if isempty(session.interval), session.interval = 2; end;
      case 'chan_order'
         if isempty(rem), wrongbatch = 1; end;
         session.chan_order = str2num(rem);
      case 'system_class'
         system_class = str2num(rem);
         if isempty(system_class), system_class = 1; end;
      case 'system_type'
         system_type = str2num(rem);
         if isempty(system_type), system_type = 1; end;
      case 'binary_vendor'
         binary_vendor = rem;
         if ~strcmpi(binary_vendor, 'NeuroScan') & ...
		~strcmpi(binary_vendor, 'ANT') & ...
		~strcmpi(binary_vendor, 'EGI')
            binary_vendor = '';
         end
      case 'binary_endian'
         binary_endian = rem;
         if ~strcmpi(binary_endian, 'ieee-be') & ~strcmpi(binary_endian, 'b') ...
	& ~strcmpi(binary_endian, 'ieee-le.l64') & ~strcmpi(binary_endian, 'a') ...
	& ~strcmpi(binary_endian, 'ieee-be.l64') & ~strcmpi(binary_endian, 's') ...
	& ~strcmpi(binary_endian, 'vaxd') & ~strcmpi(binary_endian, 'd') ...
	& ~strcmpi(binary_endian, 'vaxg') & ~strcmpi(binary_endian, 'g') ...
	& ~strcmpi(binary_endian, 'cray') & ~strcmpi(binary_endian, 'c') ...
	& ~strcmpi(binary_endian, 'native') & ~strcmpi(binary_endian, 'n')
            binary_endian = 'ieee-le';
         end
      case 'chan_in_col'
         session.chan_in_col = str2num(rem);
         if isempty(session.chan_in_col), session.chan_in_col = 0; end;
      case 'subj_name'
         if isempty(rem), wrongbatch = 1; end;
         session.subj_name = [session.subj_name {rem}];
      case 'subj_file'
         if isempty(rem), wrongbatch = 1; end;
         subj_file = [subj_file {rem}];
      case 'normalize'
         if isempty(rem), wrongbatch = 1; end;
         session.normalize = str2num(rem);
      end
   end

   fclose(fid);

   if wrongbatch
      error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
   end  

   num_cond = length(session.cond_name);
   num_run = length(session.data_files);

   if num_run ~= new_num_run
      error(['# of run in new onset files does not match those in: ' old_batch_script]);
   end

   fid = fopen(new_batch_script, 'wt');

   if fid == -1			% error to open the file
      error([new_batch_script, ': Can''t open file']);
   end

   fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  General Section Start  %');
   fprintf(fid, '\t%s\n\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, 'prefix\t\t%s\t%s\n', session.prefix, '% prefix for session file and datamat file');
   fprintf(fid, 'brain_region\t%g\t%s\n', session.brain_region,'% threshold or file name for brain region');
   fprintf(fid, 'win_size\t%g\t%s\n', session.win_size,'% temporal window size in scans');
   fprintf(fid, 'across_run\t%g\t%s\n', session.across_run,'% 1 for merge data across all run, 0 for within each run');
   fprintf(fid, 'single_subj\t%g\t%s\n', session.single_subj,'% 1 for single subject analysis, 0 for normal analysis');
   fprintf(fid, 'single_ref_scan\t%g\t%s\n', session.single_ref_scan,'% 1 for single reference scan, 0 for normal reference scan');
   fprintf(fid, 'single_ref_onset  %g\t%s\n', session.single_ref_onset,'% single reference scan onset');
   fprintf(fid, 'single_ref_number  %g\t%s\n\n', session.single_ref_number,'% single reference scan number');

   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  General Section End  %');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  Condition Section Start  %');
   fprintf(fid, '\t%s\n\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

   for i=1:new_num_cond
      fprintf(fid, 'cond_name\t%s\t%s%d%s\n', new_cond_name{i}, '% condition ', i, ' name');
      fprintf(fid, 'ref_scan_onset\t%d\t%s%d\n', 0, '% reference scan onset for condition ', i);
      fprintf(fid, 'num_ref_scan\t%d\t%s%d\n\n', 1, '% number of reference scan for condition ', i);
   end

   fprintf(fid, '%s\n\n', '% ... following above pattern for more conditions');

   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  Condition Section End  %');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  Run Section Start  %');
   fprintf(fid, '\t%s\n\n', '%%%%%%%%%%%%%%%%%%%%%%%');

   for i=1:new_num_run
      fprintf(fid, 'data_files\t%s  %s%d%s\n', session.data_files{i}, '% run ', i, ' data pattern (must use wildcard)');

      for j=1:new_num_cond
         fprintf(fid, 'event_onsets\t%s  %s%d%s%d\n', num2str(onset{i}{j}), '% for run ', i, ' cond ', j);
      end

      fprintf(fid, '%s %d\n\n', '% ... following above pattern for more conditions of event_onsets in run', i);
   end

   fprintf(fid, '%s\n\n', '% ... following above pattern for more runs');

   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  Run Section End  %');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');

   fclose(fid);

   disp(' ');
   disp(['New batch file: "', new_batch_script, '" is saved.']);
   disp(' ');
   disp('Please check the ref_scan_onset / num_ref_scan values in');
   disp('the condition section in the new batch file to make sure');
   disp('that they are correct.');
   disp(' ');

   return;


%-----------------------------------------------------------------------
function data = read_onset_file(filename)

   data = {};

   fid = fopen(filename);

   if fid == -1			% error to open the file
      error([filename, ': Can''t open file']);
   end

   while ~feof(fid)
      data = [data {str2num(fgetl(fid))}];
   end

   fclose(fid);

   return;


%-----------------------------------------------------------------------
function cond = read_cond_name(filename)

   cond = {};

   fid = fopen(filename);

   if fid == -1			% error to open the file
      error([filename, ': Can''t open file']);
   end

   while ~feof(fid)
      cond = [cond {fgetl(fid)}];
   end

   fclose(fid);

   return;

