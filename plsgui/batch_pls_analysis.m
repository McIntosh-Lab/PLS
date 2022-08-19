function batch_pls_analysis(fid)

   result_file = '';
   group_files = {};
   method = 1;
   num_perm = 0;
   num_boot = 0;
   clim = 95;
   save_data = 0;
   has_unequal_subj = 0;
   intel_system = 1;
   is_struct = 0;

   num_split = 0;
   mean_type = 0;
   cormode = 0;
   boot_type = 'strat';
   nonrotated_boot = 0;

   contrasts = [];
   behavdata = [];
   behavname = {};
   selected_cond = [];
   selected_bcond = [];
   bscan = [];

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
      case 'result_file'
         result_file = rem;
         if isempty(rem), wrongbatch = 1; end;
      case 'group_files'
         this_group = {};

         while ~isempty(rem)
            [tmp rem] = strtok(rem);


            if isempty(findstr(tmp, 'sessiondata.mat'))
               msg = '\nATTENTION\n';
               msg = [msg '=========\n\n'];
               msg = [msg 'PLS now combines session/datamat files to sessiondata file. File name\n'];
               msg = [msg 'after group_files keyword must be sessiondata file. You need to use\n'];
               msg = [msg 'commmand session2sessiondata to convert session/datamat into sessiondata.\n'];
               msg = [msg 'For more detail, please type: help session2sessiondata\n\n'];
               fprintf(msg);
               wrongbatch = 1;
            end


            this_group = [this_group; {tmp}];
         end

         if isempty(this_group), wrongbatch = 1; end;
         group_files = [group_files {this_group}];
      case 'pls'
         method = str2num(rem);
         if isempty(method), method = 1; end;
      case 'num_perm'
         num_perm = str2num(rem);
         if isempty(num_perm), num_perm = 0; end;
      case 'num_boot'
         num_boot = str2num(rem);
         if isempty(num_boot), num_boot = 0; end;
      case 'clim'
         clim = str2num(rem);
         if isempty(clim), clim = 95; end;

      case 'num_split'
         num_split = str2num(rem);
         if isempty(num_split), num_split = 0; end;
      case 'mean_type'
         mean_type = str2num(rem);
         if isempty(mean_type), mean_type = 0; end;
      case 'cormode'
         cormode = str2num(rem);
         if isempty(cormode), cormode = 0; end;
      case 'boot_type'
         boot_type = rem;
         if isempty(cormode), cormode = 'strat'; end;
      case 'nonrotated_boot'
         nonrotated_boot = str2num(rem);
         if isempty(nonrotated_boot), nonrotated_boot = 0; end;

      case 'save_data'
         save_data = str2num(rem);
         if isempty(save_data), save_data = 0; end;
      case 'intel_system'
         intel_system = str2num(rem);
         if isempty(intel_system), intel_system = 1; end;
      case 'is_struct'
         is_struct = str2num(rem);
         if isempty(is_struct), is_struct = 0; end;
      case 'selected_cond'
         selected_cond = str2num(rem);
      case 'selected_bcond'
         selected_bcond = str2num(rem);
      case 'contrast_data'
         this_row = [];

         while ~isempty(rem)
            [tmp rem] = strtok(rem);
            this_row = [this_row str2num(tmp)];
         end

         if isempty(this_row)
            wrongbatch = 1;
            break;
         end

         if ~isempty(contrasts) & size(contrasts,2) ~= length(this_row)
            wrongbatch = 1;
            break;
         end

         contrasts = [contrasts; this_row];
      case 'behavior_data'
         this_row = [];

         while ~isempty(rem)
            [tmp rem] = strtok(rem);
            this_row = [this_row str2num(tmp)];
         end

         if isempty(this_row)
            wrongbatch = 1;
            break;
         end

         if ~isempty(behavdata) & size(behavdata,2) ~= length(this_row)
            wrongbatch = 1;
            break;
         end

         behavdata = [behavdata; this_row];
      case 'behavior_name'
         while ~isempty(rem)
            [tmp rem] = strtok(rem);
            behavname = [behavname {tmp}];
         end
      end
   end

   fclose(fid);

   if wrongbatch
      error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
   end

   if(exist(result_file, 'file')==2)
      disp(['WARNING: File ',result_file,' is overwritten.']);
   end

   fid = fopen(result_file,'wb');

   if fid < 0
      msg1 = ['ERROR: Please check whether you have write permission'];
      fprintf('%s\n', msg1);
      msg1 = ['       to save the result file to this folder.'];
      fprintf('%s\n\n', msg1);
      return;
   else
      fclose(fid);
   end

   progress_hdl = rri_progress_status('create','PLS Analysis');
   first_file = group_files{1}{1};
   load(first_file, 'session_info');

   if isempty(selected_cond) | sum(selected_cond) == 0 | ...
	( length(selected_cond) ~= session_info.num_conditions & ...
          isempty(findstr(first_file, '_ERPsessiondata.mat')) )
      selected_cond = ones(1, session_info.num_conditions);
   end

   if isempty(selected_bcond) | sum(selected_bcond) == 0 | ...
	( length(selected_bcond) ~= session_info.num_conditions & ...
          isempty(findstr(first_file, '_ERPsessiondata.mat')) )
      selected_bcond = ones(1, length(selected_cond));
   end

   selected_bcond = selected_bcond .* selected_cond;

   if sum(selected_bcond) == 0
      selected_bcond = selected_cond;
   end

   bscan = find(selected_bcond(find(selected_cond)));

%   if isempty(bscan) | length(bscan) > sum(selected_cond) ...
%	| max(bscan) > sum(selected_cond)
%      bscan = 1:sum(selected_cond);
%   end

%   if ~isempty(findstr(first_file, '_BfMRIsessiondata.mat'))	 % Blocked fMRI
%   elseif ~isempty(findstr(first_file, '_fMRIsessiondata.mat')) % E.R. fMRI

   if length(first_file)>18 & strcmpi(first_file(end-18:end),'fMRIsessiondata.mat')

      PLSoptions.profiles = group_files;
      PLSoptions.group_analysis = 1;
      PLSoptions.num_perm = num_perm;
      PLSoptions.num_boot = num_boot;
      PLSoptions.posthoc = [];
      PLSoptions.Clim = clim;
      PLSoptions.save_datamat = save_data;
      PLSoptions.cond_selection = selected_cond;

      PLSoptions.behavname = {};
      PLSoptions.behavdata = [];
      PLSoptions.behavdata_lst = {};
      PLSoptions.bscan = bscan;

      PLSoptions.method = method;
      PLSoptions.output_file = result_file;
      PLSoptions.intel_system = intel_system;

      PLSoptions.meancentering_type = mean_type;
      PLSoptions.cormode = cormode;
      PLSoptions.boot_type = boot_type;
      PLSoptions.nonrotated_boot = nonrotated_boot;
      PLSoptions.num_split = num_split;

      if exist('plslog.m','file')
         if length(first_file)>19 & strcmpi(first_file(end-19:end),'BfMRIsessiondata.mat')
            switch method
            case 1
               plslog('Batch BfMRI Mean-Centering Analysis');
            case 2
               plslog('Batch BfMRI Non-Rotated Task Analysis');
            case 3
               plslog('Batch BfMRI Regular Behavior Analysis');
            case 4
               plslog('Batch BfMRI Multiblock Analysis');
            case 5
               plslog('Batch BfMRI Non-Rotated Behavior Analysis');
            end
         else
            switch method
            case 1
               plslog('Batch fMRI Mean-Centering Analysis');
            case 2
               plslog('Batch fMRI Non-Rotated Task Analysis');
            case 3
               plslog('Batch fMRI Regular Behavior Analysis');
            case 4
               plslog('Batch fMRI Multiblock Analysis');
            case 5
               plslog('Batch fMRI Non-Rotated Behavior Analysis');
            end
         end
      end

      switch method
      case 1
         PLSoptions.ContrastFile = [];
         PLSoptions.has_unequal_subj = 0;

         for g = 1:length(group_files)
            session_files = group_files{g};
            for s = 1:length(session_files)
               fn = session_files{s};
               warning off;
               load(fn, 'unequal_subj');
               warning on;
               if exist('unequal_subj','var') & unequal_subj == 1
                  PLSoptions.has_unequal_subj = 1;
               end
            end
         end
      case 2
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.has_unequal_subj = 0;

         for g = 1:length(group_files)
            session_files = group_files{g};
            for s = 1:length(session_files)
               fn = session_files{s};
               warning off;
               load(fn, 'unequal_subj');
               warning on;
               if exist('unequal_subj','var') & unequal_subj == 1
                  PLSoptions.has_unequal_subj = 1;
               end
            end
         end
      case 3
         PLSoptions.ContrastFile = 'BEHAV';
         PLSoptions.has_unequal_subj = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         total_rows = 0;

         for g = 1:length(group_files)
            session_files = group_files{g};

            for s = 1:length(session_files)
               fn = session_files{s};
               load(fn, 'st_evt_list');
               cond_lst = find(selected_cond);
               for t = 1:length(cond_lst)
                  total_rows = total_rows + length(find(st_evt_list==cond_lst(t)));
               end
            end
         end

         if size(behavdata,1) ~= total_rows
            error(['Wrong number of rows in behavior data file, which should be ' num2str(total_rows) '.']);
         end

         for g = 1:length(group_files)
            session_files = group_files{g};
            count = 0;

            for s = 1:length(session_files)
               fn = session_files{s};
               warning off;
               load(fn, 'st_evt_list', 'unequal_subj');
               warning on;
               if exist('unequal_subj','var') & unequal_subj == 1
                  PLSoptions.has_unequal_subj = 1;
               end
               cond_lst = find(selected_cond);
               for t = 1:length(cond_lst)
                  count = count + length(find(st_evt_list==cond_lst(t)));
               end
            end

            PLSoptions.behavdata_lst{g} = behavdata(1:count, :);
            behavdata(1:count, :) = [];
         end
      case 4
         PLSoptions.ContrastFile = 'MULTIBLOCK';
         PLSoptions.has_unequal_subj = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         total_rows = 0;

         for g = 1:length(group_files)
            session_files = group_files{g};

            for s = 1:length(session_files)
               fn = session_files{s};
               load(fn, 'st_evt_list');
               cond_lst = find(selected_cond);
               for t = 1:length(cond_lst)
                  total_rows = total_rows + length(find(st_evt_list==cond_lst(t)));
               end
            end
         end

         if size(behavdata,1) ~= total_rows
            error(['Wrong number of rows in behavior data file, which should be ' num2str(total_rows) '.']);
         end

         for g = 1:length(group_files)
            session_files = group_files{g};
            count = 0;

            for s = 1:length(session_files)
               fn = session_files{s};
               warning off;
               load(fn, 'st_evt_list', 'unequal_subj');
               warning on;
               if exist('unequal_subj','var') & unequal_subj == 1
                  PLSoptions.has_unequal_subj = 1;
               end
               cond_lst = find(selected_cond);
               for t = 1:length(cond_lst)
                  count = count + length(find(st_evt_list==cond_lst(t)));
               end
            end

            PLSoptions.behavdata_lst{g} = behavdata(1:count, :);
            behavdata(1:count, :) = [];
         end
      case 5
         PLSoptions.group_analysis = 2;
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.has_unequal_subj = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         total_rows = 0;

         for g = 1:length(group_files)
            session_files = group_files{g};

            for s = 1:length(session_files)
               fn = session_files{s};
               load(fn, 'st_evt_list');
               cond_lst = find(selected_cond);
               for t = 1:length(cond_lst)
                  total_rows = total_rows + length(find(st_evt_list==cond_lst(t)));
               end
            end
         end

         if size(behavdata,1) ~= total_rows
            error(['Wrong number of rows in behavior data file, which should be ' num2str(total_rows) '.']);
         end

         for g = 1:length(group_files)
            session_files = group_files{g};
            count = 0;

            for s = 1:length(session_files)
               fn = session_files{s};
               warning off;
               load(fn, 'st_evt_list', 'unequal_subj');
               warning on;
               if exist('unequal_subj','var') & unequal_subj == 1
                  PLSoptions.has_unequal_subj = 1;
               end
               cond_lst = find(selected_cond);
               for t = 1:length(cond_lst)
                  count = count + length(find(st_evt_list==cond_lst(t)));
               end
            end

            PLSoptions.behavdata_lst{g} = behavdata(1:count, :);
            behavdata(1:count, :) = [];
         end
      case 6
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.has_unequal_subj = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         total_rows = 0;

         for g = 1:length(group_files)
            session_files = group_files{g};

            for s = 1:length(session_files)
               fn = session_files{s};
               load(fn, 'st_evt_list');
               cond_lst = find(selected_cond);
               for t = 1:length(cond_lst)
                  total_rows = total_rows + length(find(st_evt_list==cond_lst(t)));
               end
            end
         end

         if size(behavdata,1) ~= total_rows
            error(['Wrong number of rows in behavior data file, which should be ' num2str(total_rows) '.']);
         end

         for g = 1:length(group_files)
            session_files = group_files{g};
            count = 0;

            for s = 1:length(session_files)
               fn = session_files{s};
               warning off;
               load(fn, 'st_evt_list', 'unequal_subj');
               warning on;
               if exist('unequal_subj','var') & unequal_subj == 1
                  PLSoptions.has_unequal_subj = 1;
               end
               cond_lst = find(selected_cond);
               for t = 1:length(cond_lst)
                  count = count + length(find(st_evt_list==cond_lst(t)));
               end
            end

            PLSoptions.behavdata_lst{g} = behavdata(1:count, :);
            behavdata(1:count, :) = [];
         end
      end

      if PLSoptions.has_unequal_subj == 1
         if PLSoptions.num_split ~= 0
            PLSoptions.num_split = 0;
            msg = 'WARNING: Number of split has to be reset to 0 for single subject analysis.';
            disp(msg);
         end

         if ~strcmp(PLSoptions.boot_type,'strat')
            PLSoptions.boot_type = 'strat';
            msg = 'WARNING: Bootstrap type has to be reset to strat for single subject analysis.';
            disp(msg);
         end
      end

      fmri_pls_analysis(PLSoptions.profiles, PLSoptions.ContrastFile, ...
				   PLSoptions.num_perm, ...
				   PLSoptions.num_boot, ...
				   PLSoptions.Clim, ...
				   PLSoptions.posthoc, ...
				   PLSoptions.save_datamat, ...
				   PLSoptions.group_analysis, ...
				   PLSoptions.cond_selection, ...
				   PLSoptions.behavname, ...
				   PLSoptions.behavdata, ...
				   PLSoptions.behavdata_lst, ...
				   PLSoptions.bscan, ...
				   PLSoptions.has_unequal_subj, ...
				   PLSoptions.num_split, ...
				   PLSoptions.meancentering_type, ...
				   PLSoptions.cormode, ...
				   PLSoptions.boot_type, ...
				   PLSoptions.nonrotated_boot, ...
				   PLSoptions.method, ...
				   PLSoptions.output_file, ...
				   PLSoptions.intel_system);

      if exist('progress_hdl','var') & ishandle(progress_hdl)
         close(progress_hdl);
      end

   elseif ~isempty(findstr(first_file, '_ERPsessiondata.mat'))	% ERP

      if exist('plslog.m','file')
         switch method
         case 1
            plslog('Batch ERP Mean-Centering Analysis');
         case 2
            plslog('Batch ERP Non-Rotated Task Analysis');
         case 3
            plslog('Batch ERP Regular Behavior Analysis');
         case 4
            plslog('Batch ERP Multiblock Analysis');
         case 5
            plslog('Batch ERP Non-Rotated Behavior Analysis');
         case 6
            plslog('Batch ERP Non-Rotated Multiblock Analysis');
         end
      end

      PLSoptions.profiles = [group_files{:}];
      PLSoptions.num_perm = num_perm;
      PLSoptions.num_boot = num_boot;
      PLSoptions.posthoc = [];
      PLSoptions.Clim = clim;
      PLSoptions.save_datamat = save_data;
      PLSoptions.cond_selection = selected_cond;
      PLSoptions.system = session_info.system;
      PLSoptions.ishelmert = 0;

      PLSoptions.behavname = {};
      PLSoptions.behavdata = [];
      PLSoptions.behavdata_lst = {};
      PLSoptions.bscan = bscan;
      PLSoptions.BehavDataCol = 1;
      PLSoptions.ContrastDataCol = 1;

      PLSoptions.output_file = result_file;

      PLSoptions.meancentering_type = mean_type;
      PLSoptions.cormode = cormode;
      PLSoptions.boot_type = boot_type;
      PLSoptions.nonrotated_boot = nonrotated_boot;
      PLSoptions.num_split = num_split;

      switch method
      case 1
         PLSoptions.ContrastFile = [];
         PLSoptions.ismean = 1;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;
      case 2
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 1;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;
      case 3
         PLSoptions.ContrastFile = [];
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 1;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end

         PLSoptions.BehavDataCol = size(PLSoptions.behavdata, 2);
      case 4
         PLSoptions.ContrastFile = [];
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 1;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end

         PLSoptions.BehavDataCol = size(PLSoptions.behavdata, 2);
      case 5
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 1;
         PLSoptions.isnonrotatemultiblock = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end

         PLSoptions.BehavDataCol = size(PLSoptions.behavdata, 2);
      case 6
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 1;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end

         PLSoptions.BehavDataCol = size(PLSoptions.behavdata, 2);
      end

      erp_analysis(PLSoptions.ismean, ...
		PLSoptions.ishelmert, PLSoptions.iscontrast, PLSoptions.isbehav, ...
		PLSoptions.BehavDataCol, PLSoptions.ContrastDataCol, ...
		PLSoptions.posthoc, PLSoptions.profiles, PLSoptions.save_datamat, ...
		PLSoptions.num_perm, PLSoptions.num_boot, PLSoptions.Clim, ...
		PLSoptions.system, PLSoptions.ContrastFile, PLSoptions.cond_selection, ...
		PLSoptions.behavdata_lst, PLSoptions.behavname, ...
		PLSoptions.ismultiblock, PLSoptions.bscan, PLSoptions.isnonrotatebehav, ...
		PLSoptions.num_split, PLSoptions.meancentering_type, ...
		PLSoptions.cormode, PLSoptions.boot_type, PLSoptions.nonrotated_boot, ...
		PLSoptions.isnonrotatemultiblock, ...
		PLSoptions.output_file);

      if exist('progress_hdl','var') & ishandle(progress_hdl)
         close(progress_hdl);
      end

   elseif ~isempty(findstr(first_file, '_STRUCTsessiondata.mat'))	% STRUCT

      if exist('plslog.m','file')
         switch method
         case 1
            plslog('Batch STRUCT Mean-Centering Analysis');
         case 2
            plslog('Batch STRUCT Non-Rotated Task Analysis');
         case 3
            plslog('Batch STRUCT Regular Behavior Analysis');
         case 4
            plslog('Batch STRUCT Multiblock Analysis');
         case 5
            plslog('Batch STRUCT Non-Rotated Behavior Analysis');
         case 6
            plslog('Batch STRUCT Non-Rotated Multiblock Analysis');
         end
      end

      PLSoptions.profiles = [group_files{:}];
      PLSoptions.num_perm = num_perm;
      PLSoptions.num_boot = num_boot;
      PLSoptions.posthoc = [];
      PLSoptions.Clim = clim;
      PLSoptions.save_datamat = save_data;
      PLSoptions.cond_selection = selected_cond;

      PLSoptions.behavname = {};
      PLSoptions.behavdata = [];
      PLSoptions.behavdata_lst = {};
      PLSoptions.bscan = bscan;

      PLSoptions.output_file = result_file;
      PLSoptions.intel_system = intel_system;
      PLSoptions.is_struct = is_struct;

      PLSoptions.meancentering_type = mean_type;
      PLSoptions.cormode = cormode;
      PLSoptions.boot_type = boot_type;
      PLSoptions.nonrotated_boot = nonrotated_boot;
      PLSoptions.num_split = num_split;

      switch method
      case 1
         PLSoptions.ContrastFile = [];
         PLSoptions.ismean = 1;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;
      case 2
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 1;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;
      case 3
         PLSoptions.ContrastFile = [];
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 1;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end
      case 4
         PLSoptions.ContrastFile = [];
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 1;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end
      case 5
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 1;
         PLSoptions.isnonrotatemultiblock = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end
      case 6
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 1;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'selected_subjects');
            bidx = last + [1: sum(selected_cond)*sum(selected_subjects)];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end
      end

      struct_analysis(PLSoptions.isbehav, ...
		PLSoptions.profiles, PLSoptions.num_perm, ...
		PLSoptions.num_split, PLSoptions.meancentering_type, ...
		PLSoptions.cormode, PLSoptions.boot_type, PLSoptions.nonrotated_boot, ...
		PLSoptions.num_boot, PLSoptions.Clim, ...
		PLSoptions.posthoc, ...
		PLSoptions.cond_selection, PLSoptions.behavname, ...
		PLSoptions.behavdata, PLSoptions.behavdata_lst, ...
		PLSoptions.ContrastFile, ...
		PLSoptions.iscontrast, PLSoptions.ismean, ...
		PLSoptions.save_datamat, ...
		PLSoptions.ismultiblock, PLSoptions.bscan, ...
		PLSoptions.isnonrotatebehav, ...
		PLSoptions.isnonrotatemultiblock, ...
		PLSoptions.is_struct, ...
		PLSoptions.output_file, ...
		PLSoptions.intel_system);

      if exist('progress_hdl','var') & ishandle(progress_hdl)
         close(progress_hdl);
      end

   elseif ~isempty(findstr(first_file, '_PETsessiondata.mat'))	% PET

      if exist('plslog.m','file')
         switch method
         case 1
            plslog('Batch PET Mean-Centering Analysis');
         case 2
            plslog('Batch PET Non-Rotated Task Analysis');
         case 3
            plslog('Batch PET Regular Behavior Analysis');
         case 4
            plslog('Batch PET Multiblock Analysis');
         case 5
            plslog('Batch PET Non-Rotated Behavior Analysis');
         case 6
            plslog('Batch PET Non-Rotated Multiblock Analysis');
         end
      end

      PLSoptions.profiles = [group_files{:}];
      PLSoptions.num_perm = num_perm;
      PLSoptions.num_boot = num_boot;
      PLSoptions.posthoc = [];
      PLSoptions.Clim = clim;
      PLSoptions.save_datamat = save_data;
      PLSoptions.cond_selection = selected_cond;

      PLSoptions.behavname = {};
      PLSoptions.behavdata = [];
      PLSoptions.behavdata_lst = {};
      PLSoptions.bscan = bscan;

      PLSoptions.output_file = result_file;
      PLSoptions.intel_system = intel_system;

      PLSoptions.meancentering_type = mean_type;
      PLSoptions.cormode = cormode;
      PLSoptions.boot_type = boot_type;
      PLSoptions.nonrotated_boot = nonrotated_boot;
      PLSoptions.num_split = num_split;

      switch method
      case 1
         PLSoptions.ContrastFile = [];
         PLSoptions.ismean = 1;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;
      case 2
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 1;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;
      case 3
         PLSoptions.ContrastFile = [];
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 1;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end
      case 4
         PLSoptions.ContrastFile = [];
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 1;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end
      case 5
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 1;
         PLSoptions.isnonrotatemultiblock = 0;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end
      case 6
         PLSoptions.ContrastFile = contrasts;
         PLSoptions.ismean = 0;
         PLSoptions.iscontrast = 0;
         PLSoptions.isbehav = 0;
         PLSoptions.ismultiblock = 0;
         PLSoptions.isnonrotatebehav = 0;
         PLSoptions.isnonrotatemultiblock = 1;

%         for bcol=1:size(behavdata, 2)
 %           PLSoptions.behavname = ...
%		[PLSoptions.behavname, {['behav', num2str(bcol)]}];
 %        end

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
         end

         if size(behavdata,1) ~= last
            error(['Wrong number of rows in behavior data file, which should be ' num2str(last) '.']);
         end

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end
      end

      pet_analysis(PLSoptions.isbehav, ...
		PLSoptions.profiles, PLSoptions.num_perm, ...
		PLSoptions.num_split, PLSoptions.meancentering_type, ...
		PLSoptions.cormode, PLSoptions.boot_type, PLSoptions.nonrotated_boot, ...
		PLSoptions.num_boot, PLSoptions.Clim, ...
		PLSoptions.posthoc, ...
		PLSoptions.cond_selection, PLSoptions.behavname, ...
		PLSoptions.behavdata, PLSoptions.behavdata_lst, ...
		PLSoptions.ContrastFile, ...
		PLSoptions.iscontrast, PLSoptions.ismean, ...
		PLSoptions.save_datamat, ...
		PLSoptions.ismultiblock, PLSoptions.bscan, ...
		PLSoptions.isnonrotatebehav, ...
		PLSoptions.isnonrotatemultiblock, ...
		PLSoptions.output_file, ...
		PLSoptions.intel_system);

      if exist('progress_hdl','var') & ishandle(progress_hdl)
         close(progress_hdl);
      end

   elseif ~isempty(findstr(first_file, '_SmallFCsessiondata.mat'))	% SmallFC

      if exist('plslog.m','file')
         switch method
         case 1
            plslog('Batch SmallFC Mean-Centering Analysis');
         case 2
            plslog('Batch SmallFC Non-Rotated Task Analysis');
         case 3
            plslog('Batch SmallFC Regular Behavior Analysis');
         case 4
            plslog('Batch SmallFC Multiblock Analysis');
         case 5
            plslog('Batch SmallFC Non-Rotated Behavior Analysis');
         case 6
            plslog('Batch SmallFC Non-Rotated Multiblock Analysis');
         end
      end

      msg = 'Loading datamat ...';
      rri_progress_ui(progress_hdl, '', msg);

      datamat_lst = {};
      num_subj = [];
      subj_name_lst = {};
      singledatamat = 0;		% init singledatamat to false
      create_ver = plsgui_vernum;
      datamat_files = [group_files{:}];
      datamat_files_timestamp = datamat_files;

      for i = 1:length(datamat_files)
         tmp = dir(datamat_files{i});
         datamat_files_timestamp{i} = tmp.date;

         tmp = load(datamat_files{i});

         if tmp.singleprecision
            singledatamat = 1;
         end

         datamat_lst{i} = tmp.datamat;
         subj_name_lst{i} = tmp.session_info.subj_name;
         num_subj = [num_subj  tmp.session_info.num_subjects];

         rri_progress_ui(progress_hdl,'',i/length(datamat_files));
%         rri_progress_ui(progress_hdl,'',1/10+i/(10*length(PLSoptions.profiles)));
%         rri_progress_ui(progress_hdl,'',1/10+6*i/(10*length(PLSoptions.profiles)));
      end

      dims = tmp.session_info.dims;
      cond_name = tmp.session_info.condition;
      num_subj_lst = num_subj;
      cond_selection = selected_cond;
      num_cond_lst = ones(1,length(num_subj_lst))*sum(cond_selection);
      num_conds = sum(cond_selection);

      opt.progress_hdl = progress_hdl;
      opt.method = method;
      opt.num_perm = num_perm;
      opt.is_struct = 0;			% 1 only for Structure PLS
      opt.num_boot = num_boot;
      opt.clim = clim;
      opt.bscan = bscan;

      if method==2 | method==5 | method==6
         opt.stacked_designdata = contrasts;
      end

      if method==3 | method==4 | method==5 | method==6
         opt.stacked_behavdata = behavdata;
      end

      opt.num_split = num_split;
      opt.meancentering_type = mean_type;
      opt.cormode = cormode;
      opt.boot_type = boot_type;
      opt.nonrotated_boot = nonrotated_boot;

      datamat_lst = rri_apply_deselect(datamat_lst, num_subj, cond_selection);
      result = pls_analysis(datamat_lst, num_subj, num_conds, opt);

      saved_info=['''result'', ''method'', ''dims'', ''behavname'', ', ...
		'''cond_name'', ''cond_selection'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ', ...
		'''subj_name_lst'', ''datamat_files'', ', ...
		'''datamat_files_timestamp'', ''create_ver'''];

      if save_data
         saved_info = [saved_info, ', ''datamat_lst'''];
      end

      v7 = version;
      if str2num(v7(1))<7
         singleanalysis = 0;
      else
         singleanalysis = 1;
      end

      %  Either used "single" in analysis or had "single" in datamat
      %
      if singleanalysis | singledatamat
         singleprecision = 1;
      else
         singleprecision = 0;
      end

      saved_info = [saved_info, ', ''singleprecision'''];

      done = 0;

      while ~done
         try
            eval(['save(''', result_file, ''',' saved_info,');']);
            done = 1;
         catch
            if exist('progress_hdl','var') & ishandle(progress_hdl)
               close(progress_hdl);
            end

            msg1 = ['ERROR: Unable to write result file.'];
            fprintf('%s\n\n', msg1);
%            set(findobj(session_win_hdl,'Tag','MessageLine'),'String',msg1);
%            uiwait(msgbox(msg1,'Error','modal'));
            return;
         end;
      end

      if exist('progress_hdl','var') & ishandle(progress_hdl)
         close(progress_hdl);
      end

   else
      error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
   end

   return;					% batch_pls_analysis

