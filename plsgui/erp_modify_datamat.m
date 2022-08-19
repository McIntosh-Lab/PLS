%ERP_MODIFY_DATAMAT
%
%   USAGE: erp_modify_datamat(modifier, datamat_file)
%
%   ERP_MODIFY_DATAMAT modify a datamat file based the re-selected
%	information.
%
%   modifier: a struct contains modified information. fields are:
%	modifier.selected_channels
%	modifier.selected_subjects

%   Called by erp_plot_ui
%
%   Created on 19-DEC-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h01 = erp_modify_datamat(varargin)

   if nargin == 0 | ~ischar(varargin{1})
      modifier = varargin{1};
      datamat_file = varargin{2};
      calling_fig = varargin{3};
      h01 = init(modifier, datamat_file, calling_fig);
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
      setappdata(gcf, 'filename', filename);
   elseif strcmp(action,'select_all_chan')
      select_all_chan;
   elseif strcmp(action,'select_all_subj')
      select_all_subj;
   elseif strcmp(action,'select_all_cond')
      select_all_cond;
   elseif strcmp(action,'select_all_behav')
      select_all_behav;
   elseif strcmp(action,'start_time_edit')
      start_time_edit;
   elseif strcmp(action,'end_time_edit')
      end_time_edit;
   elseif strcmp(action,'click_modify')
      click_modify;
   elseif strcmp(action,'delete_fig')
      delete_fig;
   elseif strcmp(action,'edit_chan_order')
      edit_chan_order;
   end

   return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   init: Initialize the GUI layout
%
%   I (datamat_file) - Matlab data file that contains a structure array
%			containing the session information for the study
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h01 = init(modifier, datamat_file, calling_fig)

   load(datamat_file);
%, 'session_info', 'time_info', 'setting1', 'selected_behav', ...
%	'selected_channels','selected_subjects','selected_conditions');

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

   old_time_info = time_info;
   old_selected_channels = selected_channels;
   old_selected_subjects = selected_subjects;
   selected_channels = modifier.selected_channels;
   selected_subjects = modifier.selected_subjects;

   prestim = time_info.prestim;
   digit_interval = time_info.digit_interval;
   end_epoch = time_info.end_epoch + digit_interval;			% for GUI
   sweep = end_epoch - prestim;
   timepoint = time_info.timepoint;
   start_timepoint = time_info.start_timepoint;
   start_time = time_info.start_time;
   end_time = time_info.end_time + digit_interval;			% for GUI

   old_chan_order = session_info.chan_order;
   chan_order = old_chan_order;
   chan_name = chan_nam(chan_order,:);
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

   h01 = erp_create_modify_ui(1);
   set(h01, 'name', 'Modify Datamat');

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

   setappdata(h01,'old_time_info',old_time_info);
   setappdata(h01,'old_selected_channels',old_selected_channels);
   setappdata(h01,'old_selected_subjects',old_selected_subjects);
   setappdata(h01,'old_chan_order',old_chan_order);
   setappdata(h01,'chan_order',chan_order);
   setappdata(h01,'calling_fig', calling_fig);
   setappdata(h01,'selected_channels', selected_channels);
   setappdata(h01,'selected_subjects', selected_subjects);
   setappdata(h01,'selected_conditions', selected_conditions);

   if ~exist('selected_behav','var')
      selected_behav = ones(1, size(session_info.behavdata, 2));
   end
   setappdata(h01,'selected_behav', selected_behav);

   setappdata(h01,'time_info', time_info);
   setappdata(h01,'setting1', setting1);

   if ~exist('create_ver','var')
      create_ver = plsgui_vernum;
   end
   setappdata(h01,'create_ver',create_ver);

   if ~exist('datafile','var')
      datafile = datamat_file;
   end
   setappdata(h01,'datafile',datafile);
%   setappdata(h01,'session_file',session_file);

   [filepath filename] = rri_fileparts(datamat_file);
   setappdata(h01,'filepath', filepath);
   setappdata(h01,'filename', filename);
   setappdata(h01,'old_filename', filename);
   set(filename_hdl, 'string', filename);

   setappdata(h01,'session_info', session_info);

   selected_lst = find(selected_channels);

   if isempty(selected_lst)
      msgbox('No channel was selected, the first one is now selected.','modal');
      selected_channels(1) = 1;
      selected_lst = 1;
   end

   set(chan_lst_hdl,'value',selected_lst,'list',selected_lst(1));

   selected_lst = find(selected_subjects);

   if isempty(selected_lst)
      msgbox('No subject was selected, the first one is now selected.','modal');
      selected_subjects(1) = 1;
      selected_lst = 1;
   end

   set(subj_lst_hdl,'value',selected_lst,'list',selected_lst(1));

   selected_lst = find(selected_conditions);

   if isempty(selected_lst)
      msgbox('No condition was selected, the first one is now selected.','modal');
      selected_conditions(1) = 1;
      selected_lst = 1;
   end

   set(cond_lst_hdl,'value',selected_lst,'list',selected_lst(1));

   selected_lst = find(selected_behav);

   if isempty(selected_lst)
%      msgbox('No behavior was selected, the first one is now selected.','modal');
      selected_conditions(1) = 1;
      selected_lst = 1;
   end

   set(behav_lst_hdl, 'value',find(selected_behav), 'list',1);

   return;					% init


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_all_chan: select all the channels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_all_chan

   chan_lst_hdl = getappdata(gcf, 'chan_lst_hdl');
   chan_selection = 1 : size(get(chan_lst_hdl, 'string'), 1);
   set(chan_lst_hdl, 'value', chan_selection, 'list', 1);

   return                                               % select_all_chan


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_all_subj: select all the subjects
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_all_subj

   subj_lst_hdl = getappdata(gcf, 'subj_lst_hdl');
   subj_selection = 1 : size(get(subj_lst_hdl, 'string'), 1);
   set(subj_lst_hdl, 'value', subj_selection, 'list', 1);

   return                                               % select_all_subj


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_all_cond: select all the conditions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_all_cond

   cond_lst_hdl = getappdata(gcf, 'cond_lst_hdl');
   cond_selection = 1 : size(get(cond_lst_hdl, 'string'), 1);
   set(cond_lst_hdl, 'value', cond_selection, 'list', 1);

   return                                               % select_all_cond


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_all_behav: select all the behaviors
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_all_behav

   behav_lst_hdl = getappdata(gcf, 'behav_lst_hdl');
   behav_selection = 1 : size(get(behav_lst_hdl, 'string'), 1);
   set(behav_lst_hdl, 'value', behav_selection, 'list', 1);

   return                                               % select_all_behav


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   start_time_edit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function start_time_edit

   time_info = getappdata(gcf, 'time_info');

   prestim = time_info.prestim;
   end_epoch = time_info.end_epoch;
   digit_interval = time_info.digit_interval;
   start_time = time_info.start_time;
   end_time = time_info.end_time;

   start_time_hdl = getappdata(gcf,'start_time_hdl');
   new_start_time = str2num(get(start_time_hdl,'string'));

   if isempty(new_start_time) | new_start_time < prestim ...
	| new_start_time >= end_time
      msg = 'Invalid Analysis Starting Time';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(start_time_hdl,'string',num2str(start_time));
      return;
   end

%	| mod(new_start_time-prestim, digit_interval)
   if round(new_start_time/digit_interval)*digit_interval ~= new_start_time
      new_start_time = round(new_start_time/digit_interval)*digit_interval;
      set(start_time_hdl,'string',num2str(new_start_time));
   end

   time_info.start_time = new_start_time;
   time_info.start_timepoint = floor(new_start_time / digit_interval);
   time_info.timepoint = round((end_time-new_start_time) / digit_interval + 1);

   setappdata(gcf,'time_info', time_info);

   return;					% start_time_edit


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   end_time_edit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function end_time_edit

   time_info = getappdata(gcf, 'time_info');

   prestim = time_info.prestim;
   end_epoch = time_info.end_epoch;
   digit_interval = time_info.digit_interval;
   start_time = time_info.start_time;
   end_time = time_info.end_time + digit_interval;		% add 1 timepoint for display

   end_time_hdl = getappdata(gcf,'end_time_hdl');
   new_end_time = str2num(get(end_time_hdl,'string'));

   if isempty(new_end_time) | new_end_time < digit_interval*2 ...
	| new_end_time > end_epoch + digit_interval ...
	| new_end_time <= start_time
      msg = 'Invalid Analysis Ending Time';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(end_time_hdl,'string',num2str(end_time));
      return;
   end

%	| mod(new_end_time-prestim, digit_interval)
   if round(new_end_time/digit_interval)*digit_interval ~= new_end_time
      new_end_time = round(new_end_time/digit_interval)*digit_interval;
      set(end_time_hdl,'string',num2str(new_end_time));
   end

   new_end_time = new_end_time - digit_interval;		% take out 1 timepoint
								% which was for display

   time_info.timepoint = round((new_end_time-start_time) / digit_interval + 1);
   time_info.end_time = new_end_time;

   setappdata(gcf,'time_info', time_info);

   return;					% end_time_edit


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   click_modify
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function click_modify

   chan_lst_hdl = getappdata(gcf,'chan_lst_hdl');
   selected_channels = getappdata(gcf,'selected_channels');
   selected_channels = zeros(1,length(selected_channels));
   selected_channels(get(chan_lst_hdl,'value')) = 1;

   subj_lst_hdl = getappdata(gcf,'subj_lst_hdl');

   %  old_ is the one before modified
   %
   old_time_info = getappdata(gcf,'old_time_info');
   old_selected_subjects = getappdata(gcf,'old_selected_subjects');
   old_selected_channels = getappdata(gcf,'old_selected_channels');

   old_chan_order = getappdata(gcf,'old_chan_order');
   old_selected_conditions = getappdata(gcf,'selected_conditions');
   old_selected_behav = getappdata(gcf,'selected_behav');

   setting1 = getappdata(gcf,'setting1');

   %  final selected_subjects
   %
   selected_subjects = zeros(1,length(old_selected_subjects));
   selected_subjects(get(subj_lst_hdl,'value')) = 1;

   cond_lst_hdl = getappdata(gcf,'cond_lst_hdl');

   %  final selected_conditions
   %
   selected_conditions = zeros(1,length(old_selected_conditions));
   selected_conditions(get(cond_lst_hdl,'value')) = 1;

   behav_lst_hdl = getappdata(gcf,'behav_lst_hdl');

   %  final selected_behav
   %
   selected_behav = zeros(1,length(old_selected_behav));
   selected_behav(get(behav_lst_hdl,'value')) = 1;

   time_info = getappdata(gcf,'time_info');

   calling_fig = getappdata(gcf,'calling_fig');

   %  remove any 0 in wave_selection & avg_selection
   %
   wave_selection = setting1.wave_selection;
   avg_selection = setting1.avg_selection;
   wave_selection(find(wave_selection==0)) = []; 
   avg_selection(find(avg_selection==0)) = [];

   %  selected_wave, before modify
   %
   old_idx = [];

   for i=find(old_selected_conditions)
      for j=find(old_selected_subjects)
         old_idx = [old_idx (i-1)*length(old_selected_subjects) + j];
      end
   end

   %  selected_wave, after modify
   %
   idx = [];

   for i=find(selected_conditions)
      for j=find(selected_subjects)
         idx = [idx (i-1)*length(selected_subjects) + j];
      end
   end

   %  calculate new available idx for wave_selection
   %
   [tmp new_available] = intersect(old_idx, idx);
   selected_new_available = intersect(wave_selection, new_available);
   [tmp setting1.wave_selection] = ...
	intersect(new_available, selected_new_available);

%   setting1.wave_selection = [0 setting1.wave_selection];	% always add 0 back
   if isempty(setting1.wave_selection)
      setting1.wave_selection = 1;		% select first new subj.
   end;

   %  selected_avg, before modify
   %
   old_idx = [];

   for i=find(old_selected_conditions)
      old_idx = [old_idx i];
   end


   %  selected_avg, after modify
   %
   idx = [];

   for i=find(selected_conditions)
      idx = [idx i];
   end

   %  calculate new available idx for avg_selection
   %
   [tmp new_available] = intersect(old_idx, idx);
   selected_new_available = intersect(avg_selection, new_available);
   [tmp setting1.avg_selection] = ...
	intersect(new_available, selected_new_available);

   setting1.avg_selection = [0 setting1.avg_selection];		% always add 0 back

   chan_order = getappdata(gcf,'chan_order');

   old_filename = getappdata(gcf,'old_filename');
   filename = getappdata(gcf,'filename');
   filepath = getappdata(gcf,'filepath');
   datamat_file = fullfile(filepath, filename);

   if isequal(selected_channels, old_selected_channels) & ...
	isequal(selected_conditions, old_selected_conditions) & ...
	isequal(selected_subjects, old_selected_subjects) & ...
	isequal(selected_behav, old_selected_behav) & ...
	isequal(filename, old_filename) & ...
	isequal(time_info, old_time_info) & isequal(chan_order, old_chan_order)

      close(gcf);
      return;

   end

   if ~rri_chkfname(filename, 'ERP', 'sessiondata')
      msg = 'File name must be ended with _ERPsessiondata.mat';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      
      return;
   end

   session_info = getappdata(gcf,'session_info');
   session_info.chan_order = chan_order;

   if isequal(filename, old_filename)
      try
         save(datamat_file, '-append', 'selected_channels', 'selected_subjects', ...
		'selected_conditions', 'selected_behav', 'time_info', ...
		'setting1', 'session_info');
      catch
         datamat_file = [];
         msg1 = ['ERROR: Unable to write datamat file.'];
         set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
         return;
      end
   else

%     session_file = getappdata(gcf,'session_file');
     datafile = getappdata(gcf,'datafile');
     create_ver = getappdata(gcf,'create_ver');

     savfig = [];
     if strcmpi(get(gcf,'windowstyle'),'modal')
        savfig = gcf;
        set(gcf,'windowstyle','normal');
     end

     %  save datamat file
     %
     done = 0;

     while ~done
       try
         save(datamat_file, 'datafile', 'create_ver', ...
		'session_info', 'selected_behav', ...
		'selected_conditions', 'selected_subjects', ...
		'selected_channels', 'time_info', 'setting1');
         done = 1;
       catch
         datamat_file = [];
         msg1 = ['ERROR: Unable to write datamat file.'];
         set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
         return;
       end
     end

     if ~isempty(savfig)
        set(savfig,'windowstyle','modal');
     end

   end

   close(gcf);

   if ~isequal(filename, old_filename)
      set(calling_fig, 'name', ['ERP Amplitude: ', datamat_file]);
   end

   erp_plot_ui({datamat_file, 1, calling_fig});

   return;                                      % click_modify


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   delete_fig
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      erp_create_modify_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'erp_create_modify_pos');
   catch
   end

   return;


%--------------------------------------------------------------------
function edit_chan_order

   session_info = getappdata(gcf,'session_info');
   chan_lst_hdl = getappdata(gcf,'chan_lst_hdl');
   old_chan_order = getappdata(gcf,'old_chan_order');
   chan_order = getappdata(gcf,'chan_order');

   % chan_order is [] when create datamat
   %
   if isempty(old_chan_order)
      old_chan_order = session_info.chan_order;
   end

   if isempty(chan_order)
      chan_order = session_info.chan_order;
   end

   chan_order = ...
	erp_select_chan(num2str(chan_order), session_info.system, 'Edit Channel Order', 0);
   chan_order = str2num(chan_order);

   if length(old_chan_order) ~= length(chan_order) | ...
	length(chan_order) ~= length(unique(chan_order)) | ...
	min(chan_order) < 1

      msg = 'Invalid Channel Order';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;

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

   chan_name = chan_nam(chan_order,:);
   set(chan_lst_hdl, 'string', chan_name);
   select_all_chan

   setappdata(gcf,'chan_order',chan_order);

   return;

