function batch_create_datamat(fid)

   session.prefix = '';				% all
   session.dataset_path = '';			% struct
   session.brain_region = '';			% all but [erp fc]
   session.win_size = 8;			% fmri
   session.across_run = 1;			% mri
   session.single_subj = 0;			% mri
   session.single_ref_scan = 0;			% mri
   session.single_ref_onset = 0;		% mri
   session.single_ref_number = 1;		% mri
   session.normalize = '';			% all but [erp fc]

   session.cond_name = {};			% all
   session.cond_filter = {};			% struct
   ref_scan_onset = [];				% mri
   num_ref_scan = [];				% mri

   subj_file = {};				% erp, pet, struct, fc
   session.subject = {};			% erp, pet, struct, fc
   session.subj_name = {};			% erp, pet, struct, fc
   session.subj_files = {};			% erp, pet, struct, fc
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

   session.dims = [];				% fc

   wrongbatch = 0;

   while ~feof(fid)

      tmp = fgetl(fid);

      if ischar(tmp) & ~isempty(tmp)
         tmp = strrep(tmp, char(9), ' ');
%         tmp = deblank(fliplr(deblank(fliplr(tmp))));
         tmp = deblank(strjust(tmp, 'left'));
      end

      while ~feof(fid) & (isempty(tmp) | isnumeric(tmp) | strcmpi(tmp(1), '%'))
         tmp = fgetl(fid);

         if ischar(tmp) & ~isempty(tmp)
            tmp = strrep(tmp, char(9), ' ');
            tmp = deblank(strjust(tmp, 'left'));
         end
      end

      if ischar(tmp) & ~isempty(tmp)
         [tok rem] = strtok(tmp);

         if ~isempty(rem)
            [rem junk] = strtok(rem, '%');
            rem = deblank(strjust(rem, 'left'));
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
      case 'dims'
         if isempty(rem), wrongbatch = 1; end;
         session.dims = str2num(rem);
      end
   end

   fclose(fid);

   if wrongbatch
      error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
   end  

   session.num_cond = length(session.cond_name);

   if ~isempty(event_onsets)					% fmri

      if wrongbatch | isempty(session.data_files)
         error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
      end

      session.num_run = length(session.data_files);

      total_event_onsets = session.num_run * session.num_cond;

      if total_event_onsets ~= length(event_onsets)
         error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
      end

      for i = 1:session.num_run
         [session.data_path{i} session.file_pattern{i}] ...
				= rri_fileparts(session.data_files{i});

         for j = 1:session.num_cond
            session.evt_onsets{i}{j} = event_onsets{(i-1)*session.num_cond+j}(:);
         end
      end

      if session.single_subj & session.across_run
         for i = 1:session.num_cond
            for j = 2:session.num_run
               if length(session.evt_onsets{j}{i}) ~= length(session.evt_onsets{j-1}{i})
                  error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
               end
            end
         end
      end

      for i = 1:session.num_cond
         session.baseline{i} = [ref_scan_onset(i) num_ref_scan(i)];
      end

      create_fmri_datamat(session);

   elseif ~isempty(block_onsets)				% bfm

      if wrongbatch | isempty(session.data_files)
         error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
      end

      session.num_run = length(session.data_files);

      total_block_onsets = session.num_run * session.num_cond;

      if total_block_onsets ~= length(block_onsets)
         error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
      end

      for i = 1:session.num_run
         [session.data_path{i} session.file_pattern{i}] ...
				= rri_fileparts(session.data_files{i});

         for j = 1:session.num_cond
            session.blk_onsets{i}{j} = block_onsets{(i-1)*session.num_cond+j}(:);
            session.blk_length{i}{j} = block_length{(i-1)*session.num_cond+j}(:);
            if length(session.blk_length{i}{j}) < length(session.blk_onsets{i}{j})
               error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
            end
         end
      end

      if session.single_subj & session.across_run
         for i = 1:session.num_cond
            for j = 2:session.num_run
               if length(session.blk_onsets{j}{i}) ~= length(session.blk_onsets{j-1}{i})
                  error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
               end
            end
         end
      end

      for i = 1:session.num_cond
         session.baseline{i} = [ref_scan_onset(i) num_ref_scan(i)];
      end

      create_bfm_datamat(session);

   elseif ~isempty(session.chan_order)				% erp

      if isempty(binary_vendor)
         session.eeg_format = [];
      else
         session.eeg_format.vendor = binary_vendor;
         session.eeg_format.machineformat = binary_endian;
      end

      session.system.class = system_class;
      session.system.type = system_type;
      session.num_subj = round(length(subj_file) / session.num_cond);
      session.subj_files = cell(session.num_cond, session.num_subj);

      for i = 1:session.num_cond
         for j = 1:session.num_subj
            [session.subject{j} session.subj_files{i,j}] = ...
		rri_fileparts(subj_file{(i-1)*session.num_subj+j});
         end
      end

      for j = 1:session.num_subj
         [tmp subj_name] = rri_fileparts(session.subject{j});
         session.subj_name = [session.subj_name {subj_name}];
      end

      create_erp_datamat(session)

   elseif ~isempty(session.dataset_path)			% struct

      session.num_subj = round(length(subj_file) / session.num_cond);
      session.subj_files = cell(session.num_cond, session.num_subj);

      for i = 1:session.num_cond
         for j = 1:session.num_subj
            [junk session.subj_files{i,j}] = ...
		rri_fileparts(subj_file{(i-1)*session.num_subj+j});
         end
      end

      subject = session.subj_files(1,:);

      %  replace pattern with '*'
      %
      [p f] = fileparts(session.cond_filter{1});
      f = strrep(f, '*', '');			% remove * in pattern
      subject = strrep(subject, f, '*');	% replace with '*'

      %  replace '.nii' or '.img' with '.*'
      %
      subject = strrep(subject, '.nii', '.*');
      subject = strrep(subject, '.img', '.*');
      session.subject = subject;

      subject = session.subj_files{1,1};
      [p f e] = fileparts(subject);
      session.img_ext = ['*' e];

      create_struct_datamat(session)

   elseif ~isempty(session.dims)				% smallfc

      session.num_subj = round(length(subj_file) / session.num_cond);
      session.subj_files = cell(session.num_cond, session.num_subj);

      for i = 1:session.num_cond
         for j = 1:session.num_subj
            [session.subject{j} session.subj_files{i,j}] = ...
		rri_fileparts(subj_file{(i-1)*session.num_subj+j});
         end
      end

      for j = 1:session.num_subj
         [tmp subj_name] = rri_fileparts(session.subject{j});
         session.subj_name = [session.subj_name {subj_name}];
      end

      create_smallfc_datamat(session)

   else								% pet

      session.num_subj = round(length(subj_file) / session.num_cond);
      session.subj_files = cell(session.num_cond, session.num_subj);

      for i = 1:session.num_cond
         for j = 1:session.num_subj
            [session.subject{j} session.subj_files{i,j}] = ...
		rri_fileparts(subj_file{(i-1)*session.num_subj+j});
         end
      end

      for j = 1:session.num_subj
         [tmp subj_name] = rri_fileparts(session.subject{j});
         session.subj_name = [session.subj_name {subj_name}];
      end

      subject = session.subj_files{1,1};
      [p f e] = fileparts(subject);
      session.img_ext = ['*' e];

      create_pet_datamat(session)

   end

   return;					% batch_create_datamat


%---------------------------------------------------------------------------
function create_fmri_datamat(session)

   if exist('plslog.m','file')
      plslog('Batch create fMRI datamat');
   end

   session_info.description = '';
   session_info.pls_data_path = pwd;
   session_info.datamat_prefix = session.prefix;

   if session.across_run
      session_info.num_conditions = session.num_cond;
      session_info.condition = session.cond_name;
      session_info.condition_baseline = session.baseline;
   else
      session_info.num_conditions = session.num_run * session.num_cond;

      for i = 1:session.num_run
         for j = 1:session.num_cond
            session_info.condition{ (i-1)*session.num_cond + j } = ...
		[ 'Run' num2str(i) session.cond_name{j} ];
         end
      end

      session_info.condition_baseline = ...
	repmat(session.baseline, [session.num_run 1]);
      session_info.condition_baseline = session_info.condition_baseline';
      session_info.condition_baseline = [session_info.condition_baseline(:)]';
   end

   session_info.num_conditions0 = session.num_cond;
   session_info.condition0 = session.cond_name;
   session_info.condition_baseline0 = session.baseline;
   session_info.num_runs = session.num_run;

   for i = 1:session.num_run
      file_lst = dir(session.data_files{i});
      flist = {file_lst.name};
      flist = flist(:);

      session_info.run(i).num_scans = 0;

      for j = 1:length(flist)
         [p fn]=rri_fileparts(flist{j});
         session_info.run(i).num_scans = session_info.run(i).num_scans + ...
		get_nii_frame(fullfile(session.data_path{i}, fn));
      end

      session_info.run(i).data_path = session.data_path{i};
      session_info.run(i).data_files = flist;
      session_info.run(i).file_pattern = session.file_pattern{i};
      session_info.run(i).evt_onsets = session.evt_onsets{i};
   end

   session_info.across_run = session.across_run;
   session_info.behavname_all = {};
   session_info.behavdata_all = [];
   session_info.behavname_each = {};
   session_info.behavdata_each = [];
   session_info.behavname_all_single = {};
   session_info.behavdata_all_single = [];
   session_info.behavname_each_single = {};
   session_info.behavdata_each_single = [];

   filename = [session.prefix '_fMRIsessiondata.mat'];
   session_file = fullfile(session_info.pls_data_path, filename);

   %  create datamat
   %  ==============

   all_onsets = [session_info.run(:).evt_onsets];
   all_onsets = reshape(all_onsets, [session_info.num_conditions0 length(all_onsets)/session_info.num_conditions0]);

   empty_cond_across_run = 0;
   any_empty_cond_within_run = 0;

   for i = 1:size(all_onsets,1)
      empty_cond_within_run = 0;

      for j = 1:size(all_onsets,2)
         if isequal(all_onsets(i,j),{-1})
            empty_cond_within_run = empty_cond_within_run + 1;
            any_empty_cond_within_run = 1;
         end
      end

      if isequal(size(all_onsets,2),empty_cond_within_run)
         empty_cond_across_run = 1;
         break;
      end
   end

   if empty_cond_across_run
      msg = 'ERROR: At least one condition has no onset for all the runs';
      error(msg);
   end

   if ~session_info.across_run & any_empty_cond_within_run
      msg = 'ERROR: There is a condition without onset while merging data within each run';
      error(msg);
   end


   if isnumeric(session.brain_region)
      options.UseBrainRegionFile = 0;
      options.BrainRegionFile = [];
      options.Threshold = session.brain_region;
   else
      options.UseBrainRegionFile = 1;
      options.BrainRegionFile = session.brain_region;
      options.Threshold = [];
   end

   orient = [];
   progress_hdl = rri_progress_status('create', ['Processing "' session_file '"']);

   options.RunsIncluded = 1:session.num_run;
   options.MaxStdDev = 4;
   options.SliceIgnored = [];

   if isempty(session.normalize)
      options.NormalizeVolumeMean = 0;
   else
      options.NormalizeVolumeMean = session.normalize;
   end

   options.NumScansSkipped = 0;
   options.TemporalWindowSize = session.win_size;
   options.MergeDataAcrossRuns = session.across_run;
   options.BehavData = [];
   options.BehavName = {};
   options.session_win_hdl = [];
   options.NormalizeSignalMean = 1;
   options.ConsiderAllVoxels = 0;
   options.SingleSubject = session.single_subj;
   options.SingleRefScanButton = session.single_ref_scan;
   options.SingleRefScanOnset = session.single_ref_onset;
   options.SingleRefScanNumber = session.single_ref_number;

   if (options.UseBrainRegionFile == 1)
      fmri_get_datamat(session_info,options.RunsIncluded, ...
					options.BrainRegionFile, ...
             				options.MaxStdDev, ...
					options.SliceIgnored, ...
					options.NormalizeVolumeMean, ...
					options.NumScansSkipped, ...
					options.TemporalWindowSize, ...
					options.MergeDataAcrossRuns, ...
					options.BehavData, ...
					options.BehavName, ...
					options.session_win_hdl, ...
					options.NormalizeSignalMean, ...
					options.ConsiderAllVoxels, ...
					options.SingleSubject, ...
					options.SingleRefScanButton, ...
					options.SingleRefScanOnset, ...
					options.SingleRefScanNumber, ...
					orient, 1);
   else
      fmri_get_datamat(session_info,options.RunsIncluded, ...
					options.Threshold, ...
					options.MaxStdDev, ...
					options.SliceIgnored, ...
					options.NormalizeVolumeMean, ...
					options.NumScansSkipped, ...
					options.TemporalWindowSize, ...
					options.MergeDataAcrossRuns, ...
					options.BehavData, ...
					options.BehavName, ...
					options.session_win_hdl, ...
					options.NormalizeSignalMean, ...
					options.ConsiderAllVoxels, ...
					options.SingleSubject, ...
					options.SingleRefScanButton, ...
					options.SingleRefScanOnset, ...
					options.SingleRefScanNumber, ...
					orient, 1);
   end

   return;					% create_fmri_datamat


%---------------------------------------------------------------------------
function create_bfm_datamat(session)

   if exist('plslog.m','file')
      plslog('Batch create BfMRI datamat');
   end

   session_info.description = '';
   session_info.pls_data_path = pwd;
   session_info.datamat_prefix = session.prefix;

   if session.across_run
      session_info.num_conditions = session.num_cond;
      session_info.condition = session.cond_name;
      session_info.condition_baseline = session.baseline;
   else
      session_info.num_conditions = session.num_run * session.num_cond;

      for i = 1:session.num_run
         for j = 1:session.num_cond
            session_info.condition{ (i-1)*session.num_cond + j } = ...
		[ 'Run' num2str(i) session.cond_name{j} ];
         end
      end

      session_info.condition_baseline = ...
	repmat(session.baseline, [session.num_run 1]);
      session_info.condition_baseline = session_info.condition_baseline';
      session_info.condition_baseline = [session_info.condition_baseline(:)]';
   end

   session_info.num_conditions0 = session.num_cond;
   session_info.condition0 = session.cond_name;
   session_info.condition_baseline0 = session.baseline;
   session_info.num_runs = session.num_run;

   for i = 1:session.num_run
      file_lst = dir(session.data_files{i});
      flist = {file_lst.name};
      flist = flist(:);

      session_info.run(i).num_scans = 0;

      for j = 1:length(flist)
         [p fn]=rri_fileparts(flist{j});
         session_info.run(i).num_scans = session_info.run(i).num_scans + ...
		get_nii_frame(fullfile(session.data_path{i}, fn));
      end

      session_info.run(i).data_path = session.data_path{i};
      session_info.run(i).data_files = flist;
      session_info.run(i).file_pattern = session.file_pattern{i};
      session_info.run(i).blk_onsets = session.blk_onsets{i};
      session_info.run(i).blk_length = session.blk_length{i};
   end

   session_info.across_run = session.across_run;
   session_info.behavname_all = {};
   session_info.behavdata_all = [];
   session_info.behavname_each = {};
   session_info.behavdata_each = [];
   session_info.behavname_all_single = {};
   session_info.behavdata_all_single = [];
   session_info.behavname_each_single = {};
   session_info.behavdata_each_single = [];

   filename = [session.prefix '_BfMRIsessiondata.mat'];
   session_file = fullfile(session_info.pls_data_path, filename);

   %  create datamat
   %  ==============

   all_onsets = [session_info.run(:).blk_onsets];
   all_onsets = reshape(all_onsets, [session_info.num_conditions0 length(all_onsets)/session_info.num_conditions0]);

   all_length = [session_info.run(:).blk_length];
   all_length = reshape(all_length, [session_info.num_conditions0 length(all_length)/session_info.num_conditions0]);

   if ~isequal(cellfun('length',all_onsets),cellfun('length',all_length))
      msg = 'ERROR: Number of onsets and length are not match';
      error(msg);
   end

   empty_cond_across_run = 0;
   any_empty_cond_within_run = 0;

   for i = 1:size(all_onsets,1)
      empty_cond_within_run = 0;

      for j = 1:size(all_onsets,2)
         if isequal(all_onsets(i,j),{-1})
            empty_cond_within_run = empty_cond_within_run + 1;
            any_empty_cond_within_run = 1;
         end
      end

      if isequal(size(all_onsets,2),empty_cond_within_run)
         empty_cond_across_run = 1;
         break;
      end
   end

   if empty_cond_across_run
      msg = 'ERROR: At least one condition has no onset for all the runs';
      error(msg);
   end

   if ~session_info.across_run & any_empty_cond_within_run
      msg = 'ERROR: There is a condition without onset while merging data within each run';
      error(msg);
   end

   if isnumeric(session.brain_region)
      options.UseBrainRegionFile = 0;
      options.BrainRegionFile = [];
      options.Threshold = session.brain_region;
   else
      options.UseBrainRegionFile = 1;
      options.BrainRegionFile = session.brain_region;
      options.Threshold = [];
   end

   orient = [];
   progress_hdl = rri_progress_status('create', ['Processing "' session_file '"']);

   options.RunsIncluded = 1:session.num_run;
   options.MaxStdDev = 4;
   options.SliceIgnored = [];

   if isempty(session.normalize)
      options.NormalizeVolumeMean = 0;
   else
      options.NormalizeVolumeMean = session.normalize;
   end

   options.NumScansSkipped = 0;
   options.MergeDataAcrossRuns = session.across_run;
   options.BehavData = [];
   options.BehavName = {};
   options.session_win_hdl = [];
   options.NormalizeSignalMean = 1;
   options.ConsiderAllVoxels = 0;
   options.SingleSubject = session.single_subj;
   options.SingleRefScanButton = session.single_ref_scan;
   options.SingleRefScanOnset = session.single_ref_onset;
   options.SingleRefScanNumber = session.single_ref_number;

   if (options.UseBrainRegionFile == 1)
      bfm_get_datamat(session_info,options.RunsIncluded, ...
					options.BrainRegionFile, ...
             				options.MaxStdDev, ...
					options.SliceIgnored, ...
					options.NormalizeVolumeMean, ...
					options.NumScansSkipped, ...
					options.MergeDataAcrossRuns, ...
					options.BehavData, ...
					options.BehavName, ...
					options.session_win_hdl, ...
					options.NormalizeSignalMean, ...
					options.ConsiderAllVoxels, ...
					options.SingleSubject, ...
					options.SingleRefScanButton, ...
					options.SingleRefScanOnset, ...
					options.SingleRefScanNumber, ...
					orient, 1);
   else
      bfm_get_datamat(session_info,options.RunsIncluded, ...
					options.Threshold, ...
					options.MaxStdDev, ...
					options.SliceIgnored, ...
					options.NormalizeVolumeMean, ...
					options.NumScansSkipped, ...
					options.MergeDataAcrossRuns, ...
					options.BehavData, ...
					options.BehavName, ...
					options.session_win_hdl, ...
					options.NormalizeSignalMean, ...
					options.ConsiderAllVoxels, ...
					options.SingleSubject, ...
					options.SingleRefScanButton, ...
					options.SingleRefScanOnset, ...
					options.SingleRefScanNumber, ...
					orient, 1);
   end

   return;					% create_bfm_datamat


%---------------------------------------------------------------------------
function create_erp_datamat(session)

   if exist('plslog.m','file')
      plslog('Batch create ERP datamat');
   end

   session_info.description = '';
   session_info.pls_data_path = pwd;
   session_info.contrastdata = '';
   session_info.behavdata = '';
   session_info.behavname = {};
   session_info.chan_order = session.chan_order(:);
   session_info.eeg_format = session.eeg_format;
   session_info.num_contrast = 0;
   session_info.num_behavior = 0;
   session_info.num_channels = length(session.chan_order);
   session_info.prestim_baseline = session.prestim;
   session_info.digit_interval = session.interval;
   session_info.datamat_prefix = session.prefix;
   session_info.num_conditions = session.num_cond;
   session_info.condition = session.cond_name;
   session_info.num_subjects = session.num_subj;
   session_info.subject = session.subject;
   session_info.subj_name = session.subj_name;
   session_info.subj_files = session.subj_files;
   session_info.chan_in_col = session.chan_in_col;
   session_info.system = session.system;
   session_info.num_subj_init = -1;

   %  create datamat
   %  ==============

   switch session_info.system.class
      case 1
         type_str = 'BESAThetaPhi|EGI128|EGI256|EGI128_v2';

         switch session_info.system.type
            case 1
               load('erp_loc_besa148');
            case 2
               load('erp_loc_egi128');
            case 3
               load('erp_loc_egi256');
            case 4
               load('erp_loc_egi128_v2');
         end
      case 2
         type_str = 'CTF-150';

         switch session_info.system.type
            case 1
               load('erp_loc_ctf150');
         end
   end

   prescan_fn = fullfile(session_info.subject{1}, session_info.subj_files{1,1});
%   prescan = load(prescan_fn);				% prescan 1 wave

   if isfield(session_info,'eeg_format')
      eeg_format = session_info.eeg_format;
   else
      eeg_format = [];
   end

   [prescan, eeg_format] = read_eeg(prescan_fn, eeg_format);

   if session_info.chan_in_col
      prescan = prescan';
   end

   prescan_time = size(prescan, 2);
   chan_name = chan_nam(session_info.chan_order,:);
   subj_name = session_info.subj_name;
   cond_name = session_info.condition;

   if isfield(session_info,'behavname')
      behavname = session_info.behavname;
   else
      behavname = {};
      for i=1:size(session_info.behavdata,2)
         behavname = [behavname, {['behav', num2str(i)]}];
      end
      session_info.behavname = behavname;
   end

   pls_data_path = session_info.pls_data_path;
   filename = [session_info.datamat_prefix, '_ERPsessiondata.mat'];
   dataname = [session_info.datamat_prefix, '_ERPdata.mat'];

   selected_channels = ones(1, session_info.num_channels);	% select all
   selected_subjects = ones(1, session_info.num_subjects);	% select all
   selected_conditions = ones(1, session_info.num_conditions);	% select all
   selected_behav = ones(1, size(session_info.behavdata,2));	% select all

   prestim = session_info.prestim_baseline;
   digit_interval = session_info.digit_interval;
%   sweep = (prescan_time - 1) * digit_interval;		% -1 means start from 0
   sweep = prescan_time * digit_interval;			% "- digit_interval" later
   end_epoch = sweep + prestim;
   start_time = prestim;
   end_time = end_epoch;

   time_info.prestim = prestim;
   time_info.digit_interval = digit_interval;
   time_info.end_epoch = end_epoch - digit_interval;		% "- digit_interval" here
   time_info.timepoint = prescan_time;
   time_info.start_timepoint = floor(prestim/digit_interval);
   time_info.start_time = start_time;
   time_info.end_time = end_time - digit_interval;		% "- digit_interval" here

   chan_value = find(selected_channels);
   subj_value = find(selected_subjects);
   cond_value = find(selected_conditions);
   behav_value = find(selected_behav);

   pls_data_path = session_info.pls_data_path;
   datamat_prefix = session_info.datamat_prefix;
   num_channels = session_info.num_channels;
   num_subjects = session_info.num_subjects;
   num_conditions = session_info.num_conditions;
   num_behav = size(session_info.behavdata, 2);

   subject = session_info.subject;
   subj_files = session_info.subj_files;
   chan_in_col = session_info.chan_in_col;

   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   savepwd = curr;

   k = num_conditions;				% num of conditions
   n = num_subjects;				% num of subjects

   progress_hdl = rri_progress_status('create', ['Processing "' filename '"']);

   factor = 1/(n*k);
   rri_progress_ui(progress_hdl, '', 0.5*factor);

   % add path for all subject
   %
   for i = 1:k
      for j = 1:n
         subj_files{i,j} = [subject{j}, filesep, subj_files{i,j}];
      end
   end

   datamat=[];

   for i = 1:k

      temp=[];

      for j=1:n
         message=['Loading condition ',num2str(i),', subject ',num2str(j),'.'];
         rri_progress_ui(progress_hdl,'',message);

%         img = load(subj_files{i,j});
         img = read_eeg(subj_files{i,j}, eeg_format);

         if chan_in_col
            img = img';
         end

         % img =reshape(img',[1,length(img(:))]);
         % temp = [temp; img(:)'];
         % temp = [temp; img];
%         temp = cat(3, temp, img');
	temp = [temp img'];
      end

      [r c] = size(img');

      % datamat=[datamat;temp];
%      datamat(:,:,:,i) = temp;
	datamat(:,:,:,i) = reshape(temp,[r c n]);
      rri_progress_ui(progress_hdl, '', ((i-1)*n+j)*factor);

   end

   datamatfile = fullfile(curr, filename);
   datafile = fullfile(curr, dataname);

   if(exist(datamatfile,'file')==2)  % datamat file with same filename exist
      disp(['WARNING: File ',filename,' is overwritten.']);
   end

   if(exist(datafile,'file')==2)  % data file with same filename exist
      disp(['WARNING: File ',dataname,' is overwritten.']);
   end

   selected_channels = zeros(1, num_channels);
   selected_channels(chan_value) = 1;
   selected_subjects = zeros(1, num_subjects);
   selected_subjects(subj_value) = 1;
   selected_conditions = zeros(1, session_info.num_conditions);
   selected_conditions(cond_value) = 1;
   selected_behav = zeros(1, num_behav);
   selected_behav(behav_value) = 1;

   setting1.font_size_selection = 4;
   setting1.eta = 0.07;
   setting1.chan_name_status = 1;
   setting1.chan_axes_status = 1;
   setting1.chan_tick_status = 1;
   setting1.bs_field = [];
   setting1.wave_selection = 1;
   setting1.avg_selection = 0;
   setting1.bs_selection = 1;
   setting1.x_interval_selection = 1;
   setting1.y_interval_selection = 1;

   create_ver = plsgui_vernum;

   try
      save(datafile, 'datamat', 'create_ver');
   catch
      msg = sprintf('Cannot save ERP data to ''%s'' ',datafile);
      error(msg);
   end;

   try
      save(datamatfile, 'datafile', 'create_ver', ...
		'session_info', 'selected_behav', ...
		'selected_conditions', 'selected_subjects', ...
		'selected_channels', 'time_info', 'setting1');
   catch
      close(progress_hdl);
      msg = sprintf('Cannot save ERP datamat to ''%s'' ',datamatfile);
      error(msg);
   end;

   cd(savepwd);
   close(progress_hdl);

   return;					% create_erp_datamat


%----------------------------------------------------------------------------
function nonbrain_coords = find_nonbrain_coords(dataset,coord_thresh,considerall)

   [num_scans num_voxels] = size(dataset);
   nonbrain_coords = zeros(1,num_voxels);

   for i=1:num_scans,
      scan_threshold = double(max(dataset(i,:))) * coord_thresh;

      if considerall
         idx = find(dataset(i,:) < scan_threshold);
      else
         idx = find(dataset(i,:) <= scan_threshold);
      end

      nonbrain_coords(idx) = 1; 
   end

   return;					% find_nonbrain_coords


%---------------------------------------------------------------------------
function create_struct_datamat(session)

   if exist('plslog.m','file')
      plslog('Batch create STRUCT datamat');
   end

   session_info.description = '';
   session_info.pls_data_path = pwd;
   session_info.dataset_path = session.dataset_path;
   session_info.num_behavior = 0;
   session_info.behavdata = [];
   session_info.behavname = {};
   session_info.datamat_prefix = session.prefix;
   session_info.num_conditions = session.num_cond;
   session_info.condition = session.cond_name;
   session_info.num_subjects = session.num_subj;
   session_info.subject = session.subject;
   session_info.subj_name = session.subj_name;
   session_info.cond_filter = session.cond_filter;
   session_info.subj_files = session.subj_files;
   session_info.img_ext = session.img_ext;
   session_info.num_subj_init = -1;

   %  create datamat
   %  ==============

   if isnumeric(session.brain_region)
      msg = sprintf('A brain mask file must be given in "brain_region" field.');
      error(msg);
   else
      options.UseBrainRegionFile = 1;
      options.BrainRegionFile = session.brain_region;
      options.Threshold = [];
   end

   options.session_win_hdl = [];
   options.ConsiderAllVoxels = 0;

   if isempty(session.normalize)
      options.NormalizeVolumeMean = 0;
   else
      options.NormalizeVolumeMean = session.normalize;
   end

   behavdata = [];
   behavname = {};

    pls_data_path = session_info.pls_data_path;
    num_behavior = session_info.num_behavior;
    datamat_prefix = session_info.datamat_prefix;
    num_conditions = session_info.num_conditions;
    condition = session_info.condition;
    num_subjects = session_info.num_subjects;
    subject = session_info.subject;
    subj_name = session_info.subj_name;
    subj_files = session_info.subj_files;

    k = num_conditions;
    n = num_subjects;
    filename = [session_info.datamat_prefix, '_STRUCTsessiondata.mat'];
    dataname = [session_info.datamat_prefix, '_STRUCTdata.mat'];

    selected_subjects = ones(1, session_info.num_subjects);	% select all

    use_brain_mask = options.UseBrainRegionFile;
    brain_mask_file = options.BrainRegionFile;

    brain_mask = [];
    mask_dims = [];

    brain_mask = load_nii(brain_mask_file, 1);
    brain_mask = reshape(int8(brain_mask.img), [brain_mask.hdr.dime.dim(2:3) 1 brain_mask.hdr.dime.dim(4)]);
    mask_dims = size(brain_mask);

    create_datamat_info.brain_mask_file = brain_mask_file;

    normalize_volume_mean = options.NormalizeVolumeMean;
    create_datamat_info.normalize_volume_mean = normalize_volume_mean;

    curr = pwd;
    if isempty(curr)
       curr = filesep;
    end

    savepwd = curr;
    home = curr;	% pls_data_path;

    %  add path for all subject
    %
    for i = 1:k
        for j = 1:n
            subj_files{i,j} = fullfile(session.dataset_path, subj_files{i,j});
        end
    end

    orient_pattern = [];

    if isempty(orient_pattern)
       [dims, voxel_size, origin] = rri_imginfo(subj_files{1,1});
    else
       dims = getappdata(gcf, 'dims');
       voxel_size = getappdata(gcf, 'voxel_size');
       origin = getappdata(gcf, 'origin');
    end

    dims = [dims(1) dims(2) 1 dims(3)];

    if (use_brain_mask==1) & ~isequal(dims,mask_dims),
       errmsg ='ERROR: Dimensions of the data do not match that of the brain mask!';
       error(errmsg);
    end;

    if (use_brain_mask == 1)			% coords from brain_mask
       coords = find( brain_mask(:) > 0)';
       m = zeros(dims);		
       m(coords) = 1;
       coords = find(m == 1)';
    end;

    num_voxels = prod(dims);

    progress_hdl = rri_progress_status('create', ['Processing "' filename '"']);

    section1 = n*k/(n*k+10);		% 1st section of progress bar
    factor = 1/(n*k+10);		% factor for the 2nd section

    rri_progress_ui(progress_hdl, '', 0.5*factor);

    %  make tdatamat, which includes non_brain voxels
    %
    tdatamat=[];
    for i = 1:k

        temp=[];

        for j=1:n

            message=['Loading condition ',num2str(i),', subject ',num2str(j),'.'];
            rri_progress_ui(progress_hdl,'',message);

            img = load_nii(subj_files{i,j}, 1);

            v7 = version;
            if str2num(v7(1))<7
               img = reshape(double(img.img), [img.hdr.dime.dim(2:3) 1 img.hdr.dime.dim(4)]);
            else
               img = reshape(single(img.img), [img.hdr.dime.dim(2:3) 1 img.hdr.dime.dim(4)]);
            end

            if ~isempty(orient_pattern)
               img = img(orient_pattern);
            end

%            img = reshape(img,[size(img,1)*size(img,2),size(img,4)]);

            temp = [temp; img(:)'];

        end

        tdatamat=[tdatamat;temp];
        rri_progress_ui(progress_hdl, '', ((i-1)*n+j)*factor);

    end

    message = 'Selecting only the brain voxels ...';
    rri_progress_ui(progress_hdl,'',message);

    [dr,dc]=size(tdatamat);
    factor = 0.1/dr;			% factor for the 2nd section
    for i=1:dr
        rri_progress_ui(progress_hdl,'',section1+(i*factor)*(1-section1));
    end

    %  remap data to eliminate non-brain voxels
    %
    datamat = tdatamat(:,coords);

    %  Check zero variance voxels & NaN voxels, and remove them from coords
    %
    check_var = var(datamat);
    bad_coords = find( (check_var==0) | isnan(check_var) );
    coords(bad_coords) = [];
    datamat(:,bad_coords) = [];

    [dr,dc]=size(datamat);		% update dr/dc

    if (normalize_volume_mean == 1)

       % perform whole-brain ratio adjustment
       gmean=mean(datamat,2);		% grand mean for each image

       rri_progress_ui(progress_hdl,'Normalizing datamat',section1+0.2*(1-section1));

       message = 'Normalize datamat with its volume mean ...';
       rri_progress_ui(progress_hdl,'',message);

       factor = 0.8/dc;				% factor for the 2nd section
       checkpoint = floor(dc/10);		% set check point
       check = checkpoint;
       percentage = 10;

       for i=1:dc
           datamat(:,i)=double(datamat(:,i))./gmean;	% normalized on the mean of each img

           if(i==check)
               rri_progress_ui(progress_hdl,'',section1+(0.2+i*factor)*(1-section1));
               message = [num2str(percentage), '% of the volume is normalized.'];
               rri_progress_ui(progress_hdl,'',message);
               check = check + checkpoint;
               percentage = percentage + 10;
           end
       end

    end

    rri_progress_ui(progress_hdl,'',1);
    message = 'Saving to the disk ...';
    rri_progress_ui(progress_hdl,'',message);

%    elapsed_time = toc;
%    disp('Datamat is created ...');

    % save to disk

   datamatfile = fullfile(home, filename);
   datafile = fullfile(home, dataname);

   if(exist(datamatfile,'file')==2)	% datamat file with the same file name exist
      disp(['WARNING: File ',filename,' is overwritten.']);
   end

   if(exist(datafile,'file')==2)  % data file with same filename exist
      disp(['WARNING: File ',dataname,' is overwritten.']);
   end

   create_ver = plsgui_vernum;

    v7 = version;
    if str2num(v7(1))<7
%       datamat = double(datamat);
       singleprecision = 0;
    else
       singleprecision = 1;
    end

   try
          save(datafile,'datamat','create_ver');
   catch
      msg = sprintf('Cannot save Structural data to ''%s'' ',datafile);
      error(msg);
   end;

   try
      save(datamatfile,'datafile','coords','behavdata','behavname', ...
		'bad_coords', 'selected_subjects', ...
		'dims','voxel_size','origin','session_info', ...
		'create_ver','create_datamat_info','singleprecision');
   catch
      close(progress_hdl);
      msg = sprintf('Cannot save Structural datamat to ''%s'' ',datamatfile);
      error(msg);
   end;

   cd(savepwd);
   close(progress_hdl);

   return;					% create_struct_datamat


%---------------------------------------------------------------------------
function create_pet_datamat(session)

   if exist('plslog.m','file')
      plslog('Batch create PET datamat');
   end

   session_info.description = '';
   session_info.pls_data_path = pwd;
   session_info.num_behavior = 0;
   session_info.behavdata = [];
   session_info.behavname = {};
   session_info.datamat_prefix = session.prefix;
   session_info.num_conditions = session.num_cond;
   session_info.condition = session.cond_name;
   session_info.num_subjects = session.num_subj;
   session_info.subject = session.subject;
   session_info.subj_name = session.subj_name;
   session_info.subj_files = session.subj_files;
   session_info.img_ext = session.img_ext;
   session_info.num_subj_init = -1;

   %  create datamat
   %  ==============

   if isnumeric(session.brain_region)
      options.UseBrainRegionFile = 0;
      options.BrainRegionFile = [];
      options.Threshold = session.brain_region;
   else
      options.UseBrainRegionFile = 1;
      options.BrainRegionFile = session.brain_region;
      options.Threshold = [];
   end

   options.session_win_hdl = [];
   options.ConsiderAllVoxels = 0;

   if isempty(session.normalize)
      options.NormalizeVolumeMean = 1;
   else
      options.NormalizeVolumeMean = session.normalize;
   end

   behavdata = [];
   behavname = {};

    pls_data_path = session_info.pls_data_path;
    num_behavior = session_info.num_behavior;
    datamat_prefix = session_info.datamat_prefix;
    num_conditions = session_info.num_conditions;
    condition = session_info.condition;
    num_subjects = session_info.num_subjects;
    subject = session_info.subject;
    subj_name = session_info.subj_name;
    subj_files = session_info.subj_files;

    k = num_conditions;
    n = num_subjects;
    filename = [datamat_prefix, '_PETsessiondata.mat'];

    use_brain_mask = options.UseBrainRegionFile;
    brain_mask_file = options.BrainRegionFile;

    brain_mask = [];
    mask_dims = [];

    if use_brain_mask
       brain_mask = load_nii(brain_mask_file, 1);
       brain_mask = reshape(int8(brain_mask.img), [brain_mask.hdr.dime.dim(2:3) 1 brain_mask.hdr.dime.dim(4)]);
       mask_dims = size(brain_mask);

       create_datamat_info.brain_mask_file = brain_mask_file;
       create_datamat_info.brain_coord_thresh = [];
    else
       create_datamat_info.brain_mask_file = '';
       create_datamat_info.brain_coord_thresh = options.Threshold;
    end

    coord_thresh = options.Threshold;
    normalize_volume_mean = options.NormalizeVolumeMean;

    create_datamat_info.normalize_volume_mean = normalize_volume_mean;
    create_datamat_info.consider_all_voxels_as_brain = options.ConsiderAllVoxels;

    curr = pwd;
    if isempty(curr)
       curr = filesep;
    end

    savepwd = curr;
    home = curr;	% pls_data_path;

    %  add path for all subject
    %
    for i = 1:k
        for j = 1:n
            subj_files{i,j} = fullfile(subject{j}, subj_files{i,j});
        end
    end

    orient_pattern = [];

    if isempty(orient_pattern)
       [dims, voxel_size, origin] = rri_imginfo(subj_files{1,1});
    else
       dims = getappdata(gcf, 'dims');
       voxel_size = getappdata(gcf, 'voxel_size');
       origin = getappdata(gcf, 'origin');
    end

    dims = [dims(1) dims(2) 1 dims(3)];

    if (use_brain_mask==1) & ~isequal(dims,mask_dims),
       errmsg ='ERROR: Dimensions of the data do not match that of the brain mask!';
       error(errmsg);
    end;

    if (use_brain_mask == 1)			% coords from brain_mask
       coords = find( brain_mask(:) > 0)';
       m = zeros(dims);		
       m(coords) = 1;
       coords = find(m == 1)';
    end;

    num_voxels = prod(dims);

    if (use_brain_mask == 0)
       coords = zeros(1, num_voxels);		% initial st_coords
    end

    progress_hdl = rri_progress_status('create', ['Processing "' filename '"']);

    section1 = n*k/(n*k+10);		% 1st section of progress bar
    factor = 1/(n*k+10);		% factor for the 2nd section

    rri_progress_ui(progress_hdl, '', 0.5*factor);

    %  make tdatamat, which includes non_brain voxels
    %
    tdatamat=[];
    for i = 1:k

        temp=[];

        for j=1:n

            message=['Loading condition ',num2str(i),', subject ',num2str(j),'.'];
            rri_progress_ui(progress_hdl,'',message);

            img = load_nii(subj_files{i,j}, 1);

            v7 = version;
            if str2num(v7(1))<7
               img = reshape(double(img.img), [img.hdr.dime.dim(2:3) 1 img.hdr.dime.dim(4)]);
            else
               img = reshape(single(img.img), [img.hdr.dime.dim(2:3) 1 img.hdr.dime.dim(4)]);
            end

            if ~isempty(orient_pattern)
               img = img(orient_pattern);
            end

%            img = reshape(img,[size(img,1)*size(img,2),size(img,4)]);

            temp = [temp; img(:)'];

            %  find brain voxel coords, and
            %  accumulated to find common coords for all img
            %
            if (use_brain_mask == 0)
               coords = coords + find_nonbrain_coords(img(:)',coord_thresh,options.ConsiderAllVoxels);
            end

        end

        tdatamat=[tdatamat;temp];
        rri_progress_ui(progress_hdl, '', ((i-1)*n+j)*factor);

    end

    message = 'Selecting only the brain voxels ...';
    rri_progress_ui(progress_hdl,'',message);

    %  determine the coords of the brain region
    %
    if (use_brain_mask == 0)	% coords from thresh by 'find_nonbrain_coords' 
       coords = find(coords == 0);
    end

    [dr,dc]=size(tdatamat);
    factor = 0.1/dr;			% factor for the 2nd section
    for i=1:dr
        rri_progress_ui(progress_hdl,'',section1+(i*factor)*(1-section1));
    end

    %  remap data to eliminate non-brain voxels
    %
    datamat = tdatamat(:,coords);
%    raw_datamat = datamat;

    [dr,dc]=size(datamat);		% update dr/dc

    if (normalize_volume_mean == 1)

       % perform whole-brain ratio adjustment
       gmean=mean(datamat,2);		% grand mean for each image

       rri_progress_ui(progress_hdl,'Normalizing datamat',section1+0.2*(1-section1));

       message = 'Normalize datamat with its volume mean ...';
       rri_progress_ui(progress_hdl,'',message);

       factor = 0.8/dc;				% factor for the 2nd section
       checkpoint = floor(dc/10);		% set check point
       check = checkpoint;
       percentage = 10;

       for i=1:dc
           datamat(:,i)=double(datamat(:,i))./gmean;	% normalized on the mean of each img

           if(i==check)
               rri_progress_ui(progress_hdl,'',section1+(0.2+i*factor)*(1-section1));
               message = [num2str(percentage), '% of the volume is normalized.'];
               rri_progress_ui(progress_hdl,'',message);
               check = check + checkpoint;
               percentage = percentage + 10;
           end
       end

    end

    rri_progress_ui(progress_hdl,'',1);
    message = 'Saving to the disk ...';
    rri_progress_ui(progress_hdl,'',message);

%    elapsed_time = toc;
%    disp('Datamat is created ...');

    % save to disk

   datamatfile = fullfile(home, filename);

   if(exist(datamatfile,'file')==2)	% datamat file with the same file name exist
      disp(['WARNING: File ',filename,' is overwritten.']);
   end

   create_ver = plsgui_vernum;

    v7 = version;
    if str2num(v7(1))<7
%       datamat = double(datamat);
       singleprecision = 0;
    else
       singleprecision = 1;
    end

   try
      save(datamatfile,'datamat','coords','behavdata','behavname', ...
		'dims','voxel_size','origin','session_info', ...
		'create_ver','create_datamat_info','singleprecision');
   catch
      close(progress_hdl);
      msg = sprintf('Cannot save PET datamat to ''%s'' ',datamatfile);
      error(msg);
   end;

   cd(savepwd);
   close(progress_hdl);

   return;					% create_pet_datamat


%---------------------------------------------------------------------------
function create_smallfc_datamat(session)

   if exist('plslog.m','file')
      plslog('Batch create SmallFC datamat');
   end

   session_info.description = '';
   session_info.pls_data_path = pwd;
   session_info.behavdata = [];
   session_info.behavname = {};
   session_info.datamat_prefix = session.prefix;
   session_info.num_conditions = session.num_cond;
   session_info.condition = session.cond_name;
   session_info.num_subjects = session.num_subj;
   session_info.subject = session.subject;
   session_info.subj_name = session.subj_name;
   session_info.subj_files = session.subj_files;
   session_info.dims = session.dims;
   session_info.num_subj_init = -1;

   %  create datamat
   %  ==============
   datamat_prefix = session_info.datamat_prefix;
   num_subjects = session_info.num_subjects;
   num_conditions = session_info.num_conditions;

   subject = session_info.subject;
   subj_files = session_info.subj_files;

   subj_name = session_info.subj_name;
   cond_name = session_info.condition;

   pls_data_path = session_info.pls_data_path;


   filename = [datamat_prefix, '_SmallFCsessiondata.mat'];


   progress_hdl = rri_progress_status('create', ['Processing "' filename '"']);
   factor = 1/(num_subjects*num_conditions);
   rri_progress_ui(progress_hdl, '', 0.5*factor);

   datamat = [];

   for k = 1:num_conditions
      for n = 1:num_subjects
         message=['Loading condition ',num2str(k),', subject ',num2str(n),'.'];
         rri_progress_ui(progress_hdl,'Loading Subjects',message);

         subj = fullfile(subject{n}, subj_files{k,n});

         try
            tmp = load(subj);
         catch
             close(progress_hdl);
             msg =  ['ERROR: "' subj '" does not exist.'];
             error(msg);
         end

         if length(tmp) ~= prod(session_info.dims)
             close(progress_hdl);
             msg =  ['ERROR: "' subj '" does not match data dimension.'];
             error(msg);
         end

         datamat = [datamat; tmp(:)'];
      end

      rri_progress_ui(progress_hdl, '', ((k-1)*num_subjects+n)*factor);
   end


   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   savepwd = curr;

   message = 'Saving to the disk ...';
   rri_progress_ui(progress_hdl,'Save',message);

   %  save to disk
   %
   datamatfile = fullfile(curr, filename);

   %  check if exist datamat file
   %
   if(exist(datamatfile,'file')==2)  % datamat file with same filename exist
      disp(['WARNING: File ',filename,' is overwritten.']);
   end

   create_ver = plsgui_vernum;

%   selected_conditions = ones(1, session_info.num_conditions);
 %  selected_subjects = ones(1, session_info.num_subjects);

   v7 = version;
   if str2num(v7(1))<7
      singleprecision = 0;
   else
      singleprecision = 1;
   end

   try
      save(datamatfile, 'create_ver', 'datamat', ...
		'session_info', 'singleprecision');

%		'selected_conditions', 'selected_subjects', ...
   catch
      close(progress_hdl);
      msg = sprintf('Cannot save SmallFC datamat to ''%s'' ',datamatfile);
      error(msg);
   end

   cd(savepwd);
   close(progress_hdl);

   return;					% create_smallfc_datamat

