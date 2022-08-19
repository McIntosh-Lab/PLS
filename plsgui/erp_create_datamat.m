%ERP_CREATE_DATAMAT Creates a datamat file
%
%  USAGE: erp_create_datamat({session_file})
%
%   ERP_CREATE_DATAMAT({session_file}) creates a datamat file based the
%   session information. In addition, it provides users some flexabilities
%   like choosing different conditions to study etc.
%

%   Called by erp_session_profile_ui
%
%   I (session_file) - Matlab data file that contains a structure array
%			containing the session information for the study
%
%   Created on 12-DEC-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function erp_create_datamat(varargin)

   if nargin == 0 | ~ischar(varargin{1})
      session_file = varargin{1}{1};
      init(session_file);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = varargin{1};

   if strcmp(action,'filename_edit')
      filename_hdl = getappdata(gcf, 'filename_hdl');
      filename = get(filename_hdl, 'string');
      setappdata(gcf,'filename',filename);
   elseif strcmp(action,'create_bn_pressed')
      CreateDatamat;
   elseif strcmp(action,'merge_conditions')
      MergeConditions;
   elseif strcmp(action,'close_bn_pressed')
      close(gcf);
      plsgui(3);
   end

   return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   init: Initialize the GUI layout
%
%   I (session_file) - Matlab data file that contains a structure array
%			containing the session information for the study
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function init(session_file)

   session_info = session_file;

   if ~isfield(session_info,'system')
      session_info.system.class = 1;
      session_info.system.type = 1;
   end

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
   end_time = end_epoch;					% "- digit_interval" later

   h01 = erp_create_modify_ui(0);

   chan_lst_hdl = getappdata(h01,'chan_lst_hdl');
   subj_lst_hdl = getappdata(h01,'subj_lst_hdl');
   cond_lst_hdl = getappdata(h01,'cond_lst_hdl');
   behav_lst_hdl = getappdata(h01,'behav_lst_hdl');

   prestim_hdl = getappdata(h01,'prestim_hdl');
   sweep_hdl = getappdata(h01,'sweep_hdl');
   epoch_hdl = getappdata(h01,'epoch_hdl');
   start_time_hdl = getappdata(h01,'start_time_hdl');
   end_time_hdl = getappdata(h01,'end_time_hdl');
   filename_hdl = getappdata(h01,'filename_hdl');

   set(chan_lst_hdl, 'string', chan_name);
   set(subj_lst_hdl, 'string', subj_name);
   set(cond_lst_hdl, 'string', cond_name);
   set(behav_lst_hdl, 'string', behavname);

   set(prestim_hdl, 'string', num2str(prestim));
   set(sweep_hdl, 'string', num2str(sweep));
   set(epoch_hdl, 'string', num2str(end_epoch));
   set(start_time_hdl, 'string', num2str(start_time));
   set(end_time_hdl, 'string', num2str(end_time));
   set(filename_hdl, 'string', filename);

   time_info.prestim = prestim;
   time_info.digit_interval = digit_interval;
   time_info.end_epoch = end_epoch - digit_interval;		% "- digit_interval" here
   time_info.timepoint = prescan_time;
   time_info.start_timepoint = floor(prestim/digit_interval);
   time_info.start_time = start_time;
   time_info.end_time = end_time - digit_interval;		% "- digit_interval" here

   setappdata(h01,'time_info', time_info);
   setappdata(h01,'selected_channels', selected_channels);
   setappdata(h01,'selected_subjects', selected_subjects);
   setappdata(h01,'selected_conditions', selected_conditions);
   setappdata(h01,'selected_behav', selected_behav);

   setappdata(h01,'filename', filename);
   setappdata(h01,'dataname', dataname);
   setappdata(h01,'session_info', session_info);
   setappdata(h01,'session_file', session_file);
   setappdata(h01,'eeg_format', eeg_format);

   set(chan_lst_hdl, 'value',find(selected_channels), 'list',1);
   set(subj_lst_hdl, 'value',find(selected_subjects), 'list',1);
   set(cond_lst_hdl, 'value',find(selected_conditions), 'list',1);
   set(behav_lst_hdl, 'value',find(selected_behav), 'list',1);

   return;					% init


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   SelectCondition: Respond to the select conditions listbox
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_conditions()

   cond_lst_hdl = getappdata(gcf,'cond_lst_hdl');
   selected_conditions = zeros(1,size(get(cond_lst_hdl,'string'),1));
   selected_conditions(get(cond_lst_hdl, 'value')) = 1;
   setappdata(gcf,'selected_conditions',selected_conditions);

   return;						% SelectCondition


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   CreateDatamat: Create Datamat file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CreateDatamat()

   if exist('plslog.m','file')
      plslog('Create ERP Datamat');
   end

   session_win_hdl = getappdata(gcf, 'session_win_hdl');
   merged_conds = getappdata(gcf, 'merged_conds');
   session_info = getappdata(gcf,'session_info');
   session_file = getappdata(gcf,'session_file');
   eeg_format = getappdata(gcf,'eeg_format');
   time_info = getappdata(gcf,'time_info');
   filename = getappdata(gcf,'filename');
   dataname = getappdata(gcf,'dataname');

   chan_value = get(getappdata(gcf,'chan_lst_hdl'), 'value');
   subj_value = get(getappdata(gcf,'subj_lst_hdl'), 'value');
   cond_value = get(getappdata(gcf,'cond_lst_hdl'), 'value');
   behav_value = get(getappdata(gcf,'behav_lst_hdl'), 'value');

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

   if(~k)
      msg = sprintf('No condition was selected.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end

   progress_hdl = rri_progress_ui('initialize', 'Creating Datamat');
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
         rri_progress_ui(progress_hdl,'Loading Subjects',message);

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

   if ~isempty(merged_conds)
      new_num_conditions = length(merged_conds);
      new_condition = {merged_conds.name};
      behavdata = session_info.behavdata;
      [d1 d2 d3 d4] = size(datamat);
      [b_dr b_dc] = size(behavdata);

      for i = 1:k
         datamat_cond{i} = datamat(:,:,:,i);
         datamat_cond{i} = datamat_cond{i}(:)';

         if ~isempty(behavdata)
            behav_cond{i} = behavdata((i-1)*n+1:i*n,:);
            behav_cond{i} = behav_cond{i}(:)';
         end
      end

      clear datamat;

      for i = 1:new_num_conditions
         new_datamat_cond{i} = ...
		mean(cat(1, datamat_cond{merged_conds(i).cond_idx}), 1);
         new_datamat_cond{i} = reshape(new_datamat_cond{i}, [d1 d2 d3]);

         if ~isempty(behavdata)
            new_behav_cond{i} = ...
		mean(cat(1, behav_cond{merged_conds(i).cond_idx}), 1);
            new_behav_cond{i} = reshape(new_behav_cond{i}, [n b_dc]);
         end
      end

      clear datamat_cond behav_cond;
      datamat = cat(4, new_datamat_cond{:});

      if ~isempty(behavdata)
         behavdata = cat(1, new_behav_cond{:});
         session_info.behavdata = behavdata;
         session_info.num_behavior = size(behavdata,1);
      end

      clear new_datamat_cond new_behav_cond;
      session_info.num_conditions = new_num_conditions;
      session_info.condition = new_condition;

   end

   message = 'Saving to the disk ...';
   rri_progress_ui(progress_hdl,'Save',message);

   %  save to disk
   %
%   datamatfile = [pls_data_path, filesep, filename];
%   datafile = [pls_data_path, filesep, dataname];
   datamatfile = fullfile(curr, filename);
   datafile = fullfile(curr, dataname);

   %  check if exist data file
   %
   if(exist(datafile,'file')==2)  % data file with same filename exist
      dlg_title = 'Confirm File Overwrite';
      msg = ['File ',dataname,' exist. Are you sure you want to overwrite it?'];
      response = questdlg(msg,dlg_title,'Yes','No','Yes');

      if(strcmp(response,'No'))
           close(progress_hdl);
           msg1 = ['WARNING: Data file is not saved.'];
           set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
           return;
      end
   end

   %  check if exist datamat file
   %
   if(exist(datamatfile,'file')==2)  % datamat file with same filename exist
      dlg_title = 'Confirm File Overwrite';
      msg = ['File ',filename,' exist. Are you sure you want to overwrite it?'];
      response = questdlg(msg,dlg_title,'Yes','No','Yes');

      if(strcmp(response,'No'))
           close(progress_hdl);
           msg1 = ['WARNING: Datamat file is not saved.'];
           set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
           return;
      end
   end

   selected_channels = zeros(1, num_channels);
   selected_channels(chan_value) = 1;
   selected_subjects = zeros(1, num_subjects);
   selected_subjects(subj_value) = 1;
   selected_conditions = zeros(1, session_info.num_conditions);
   selected_conditions(cond_value) = 1;
   selected_behav = zeros(1, num_behav);
   selected_behav(behav_value) = 1;

   setting1 = [];

   create_ver = plsgui_vernum;

   savfig = [];
   if strcmpi(get(gcf,'windowstyle'),'modal')
      savfig = gcf;
      set(gcf,'windowstyle','normal');
   end

   %  first save data file
   %
   done = 0;

   while ~done
      try
         save(datafile, 'datamat', 'create_ver');
         done = 1;
      catch
%         putfile_filter = [datamat_prefix,'_ERPdata.mat'];
 %        [datafile, status] = prompt_save(putfile_filter, 'Can not save datamat file, please try again', ''', ''ERP'',''data'')', progress_hdl);
  %       if isempty(datafile) & status, return; end;
          close(progress_hdl);
          msg1 = ['ERROR: Unable to write data file.'];
          set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
          return;
      end
   end

   %  then save datamat file
   %
   done = 0;

   while ~done
      try
         save(datamatfile, 'datafile', 'create_ver', ...
		'session_info', 'selected_behav', ...
		'selected_conditions', 'selected_subjects', ...
		'selected_channels', 'time_info', 'setting1');
         done = 1;
      catch
%         putfile_filter = [datamat_prefix,'_ERPsessiondata.mat'];
 %        [datafile, status] = prompt_save(putfile_filter, 'Can not save datamat file, please try again', ''', ''ERP'',''sessiondata'')', progress_hdl);
  %       if isempty(datamatfile) & status, return; end;
          close(progress_hdl);
          msg1 = ['ERROR: Unable to write datamat file.'];
          set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
          return;
      end
   end

   if ~isempty(savfig)
      set(savfig,'windowstyle','modal');
   end

   cd(savepwd);
   close(progress_hdl);


   [filepath filename] = rri_fileparts(datamatfile);
   set(session_win_hdl,'Name',['Session File: ' filename]);


   h_createdatamat = gcf;
   erp_plot_ui({datamatfile, 1});
   close(h_createdatamat);

%   msg1 = ['WARNING: Do not change file name manually in command window.'];
%   uiwait(msgbox(msg1,'File has been saved'));

   return;					% CreateDatamat


%----------------------------------------------------------------------------
function MergeConditions()

   session_info = getappdata(gcf, 'session_info');
   condition = session_info.condition;
   merged_conds = fmri_merge_condition_ui(condition);
   setappdata(gcf, 'merged_conds', merged_conds);

   if ~isempty(merged_conds)
      cond_lst_hdl = getappdata(gcf,'cond_lst_hdl');
      set(cond_lst_hdl, 'string', {merged_conds.name}, 'list', 1, ...
		'value', [1:length(merged_conds)]);
   end

   return;					% MergeConditions

