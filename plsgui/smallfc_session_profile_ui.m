function smallfc_session_profile_ui(varargin)

   if nargin == 0,

      if exist('plslog.m','file')
         plslog('Edit SmallFC Session');
      end

      init;

      setappdata(gcf,'CallingFigure',gcbf);
      set(gcbf,'visible','off');

      % uiwait(gcf);			% wait for user finish

      % close(gcf);

      % cd(curr_dir);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   if strcmp(action,'MENU_LOAD_PLS_SESSION_INFO'),
      LoadSessionInfo;
      ShowSessionInfo;
   elseif strcmp(action,'MENU_SAVE_PLS_SESSION_INFO'),
      SaveSessionInfo(0);
   elseif strcmp(action,'MENU_SAVE_AS_PLS_SESSION_INFO'),
      SaveSessionInfo(1);
   elseif strcmp(action,'MENU_CLOSE_SESSION_INPUT'),
      if (CloseSessionInput == 1);
         curr_dir = getappdata(gcf,'curr_dir');
	 % cd(curr_dir);
         % uiresume;
 	 close(gcbf);
      end
   elseif strcmp(action,'MENU_CLEAR_PLS_SESSION_INFO'),
      ClearSessionInfo(0);
      ShowSessionInfo;
   elseif strcmp(action,'MENU_PATH_PLS_SESSION_INFO'),
      PathSessionInfo(0);
      ShowSessionInfo;
   elseif strcmp(action,'MENU_CREATE_DATAMAT'),
      CreateDatamat;
   elseif strcmp(action,'MENU_MODIFY_DATAMAT'),
      ModifyDatamat;
   elseif strcmp(action,'EDIT_DESCRIPTION'),
      description = deblank(strjust(get(gcbo,'String'),'left'));
      set(gcbo,'String',description);
      setappdata(gcf,'SessionDescription',description);
   elseif strcmp(action,'EDIT_PLS_DATA_DIR'),
      EditPLSDataDir;
   elseif strcmp(action,'SELECT_PLS_DATA_DIR'),
      SelectPLSDataDir;
   elseif strcmp(action,'EDIT_CONTRAST_DATA'),
      is_dir_empty = isempty(getappdata(gcf,'SessionPLSDir'));
      if is_dir_empty
         msg = 'A working directory needs to be specified before inputting contrast data file.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      EditContrastData;
   elseif strcmp(action,'SELECT_CONTRAST_DATA'),
      is_dir_empty = isempty(getappdata(gcf,'SessionPLSDir'));
      if is_dir_empty
         msg = 'A working directory needs to be specified before inputting contrast data file.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      SelectContrastData;
   elseif strcmp(action,'EDIT_BEHAV_DATA'),
      is_dir_empty = isempty(getappdata(gcf,'SessionPLSDir'));
      if is_dir_empty
         msg = 'A working directory needs to be specified before inputting behav data file.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      EditBehavData;
   elseif strcmp(action,'SELECT_BEHAV_DATA'),
      is_dir_empty = isempty(getappdata(gcf,'SessionPLSDir'));
      if is_dir_empty
         msg = 'A working directory needs to be specified before inputting behav data file.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      SelectBehavData;
   elseif strcmp(action,'EDIT_CHAN_ORDER'),
      is_dir_empty = isempty(getappdata(gcf,'SessionPLSDir'));
      if is_dir_empty
         msg = 'A working directory needs to be specified before inputting channel data file.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      is_subj_empty = ...
         strcmp(get(findobj(gcf,'Tag','NumberSubjectsEdit'),'String'),'0');
      if is_subj_empty
         msg = 'Subjects need to be selected before selecting channels';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      EditChanOrder;
   elseif strcmp(action,'LOAD_MEG_SENSORS'),
      is_dir_empty = isempty(getappdata(gcf,'SessionPLSDir'));
      if is_dir_empty
         msg = 'A working directory needs to be specified before inputting channel data file.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
   elseif strcmp(action,'EDIT_DIGIT_INTERVAL')
      digit_interval = str2num(get(gcbo,'string'));
      if digit_interval <= 0
         msg = 'Digitization Interval should be greater than 0';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         set(gcbo,'string',num2str(getappdata(gcf,'SessionDigitInterval')));
         return;
      end
      setappdata(gcf,'SessionDigitInterval',digit_interval);
   elseif strcmp(action,'EDIT_PRESTIM_BASELINE')
      prestim = str2num(get(gcbo,'string'));
      if prestim > 0
         msg = 'Prestim Baseline should be less than or equal to 0';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         set(gcbo,'string',num2str(getappdata(gcf,'SessionPrestimBaseline')));
         return;
      end

      digit_interval = getappdata(gcf,'SessionDigitInterval');

      if ~isempty(digit_interval) & round(prestim/digit_interval)*digit_interval ~= prestim
         prestim = round(prestim/digit_interval)*digit_interval;
         set(gcbo,'string',num2str(prestim));
      end

      setappdata(gcf,'SessionPrestimBaseline',prestim);
   elseif strcmp(action,'EDIT_DATAMAT_PREFIX'),
      prefix_name = deblank(strjust(get(gcbo,'String'),'left'));
      setappdata(gcf,'SessionDatamatPrefix',prefix_name);
   elseif strcmp(action,'EDIT_DIMENSION'),
      dims_name = deblank(strjust(get(gcbo,'String'),'left'));
      setappdata(gcf,'SessionDataDimension',str2num(dims_name));
   elseif strcmp(action,'EDIT_CONDITIONS_NUM'),
      msg = 'Click the "Input Conditions" button to set the condition names';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_CONDITIONS'),
      is_dir_empty = isempty(getappdata(gcf,'SessionPLSDir'));
      if is_dir_empty
         msg = 'A working directory needs to be specified before inputting conditions.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      EditConditions;
   elseif strcmp(action,'EDIT_NUM_SUBJECTS'),
      msg = 'Click the "Select Subjects" button to set the subject directory';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_NUM_CHANNELS'),
      msg = 'Click the "Edit Channel Order" to load channels';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_NUM_CONTRAST'),
      msg = 'Click the "Edit Contrast Data" button to edit contrast data';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_NUM_BEHAVIOR'),
      msg = 'Click the "Edit Behavior Data" button to edit behavior data';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_SUBJECTS'),
      is_cond_empty = ...
         strcmp(get(findobj(gcf,'Tag','NumberConditionsEdit'),'String'),'0');
      if is_cond_empty
         msg = 'Conditions need to be selected before selecting subjects';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      EditSubjects;
   elseif strcmp(action,'DELETE_FIG'),
       delete_fig;
   elseif strcmp(action,'DELETE_FIGURE'),
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         smallfc_session_profile_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'smallfc_session_profile_pos');
      catch
      end

      calling_fig = getappdata(gcf,'CallingFigure');
      if ishandle(calling_fig)
         set(calling_fig,'visible','on');
      end
   elseif strcmp(action,'CLICK_CHAN_IN_COL'),
      click_chan_in_col;
   elseif strcmp(action,'READ_EEG_FORMAT'),
      eeg_format = getappdata(gcf, 'eeg_format');
      eeg_format = read_eeg_format(eeg_format);

      if isempty(eeg_format) | strcmp(eeg_format.vendor, 'BESA')
         format_str = 'BESA format';
         eeg_format = [];
      else
         format_str = [eeg_format.machineformat ' ' eeg_format.vendor ' format'];
      end

      h = findobj(gcf,'Tag','read_eeg_format');
      set(h,'string',format_str);
      setappdata(gcf,'eeg_format',eeg_format);
   end;

   return;


%----------------------------------------------------------------------------

function init

   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   curr_dir = curr;

   save_setting_status = 'on';
   smallfc_session_profile_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(smallfc_session_profile_pos) & strcmp(save_setting_status,'on')

      pos = smallfc_session_profile_pos;

   else

      w = 0.7;
      h = 0.5;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','', ...
        'NumberTitle','off', ...
        'Menubar', 'none', ...
   	'Position', pos, ...
        'DeleteFcn','smallfc_session_profile_ui(''DELETE_FIGURE'');', ...
   	'Tag','EditSessionInformation', ...
   	'ToolBar','none');

   % numbers of inputing line excluding 'MessageLine'

   num_inputline = 5;
   factor_inputline = 1/(num_inputline+1);

   % left label

   x = 0.03;
   y = (num_inputline-0) * factor_inputline;
   w = 0.25;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Session Description Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','Session Description:', ...
   	'Tag','SessionDescriptionLabel');

   x = x+w+0.01;
   y = (num_inputline-0) * factor_inputline - 0.1 * factor_inputline;
   w = 0.25;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Session Description Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String',' ', ...
   	'Callback','smallfc_session_profile_ui(''EDIT_DESCRIPTION'');', ...
   	'Tag','SessionDescriptionEdit');

   x = x+w;
   y = (num_inputline-0) * factor_inputline;
   w = 0.2;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Datamat Prefix Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Datamat Prefix:', ...
   	'Tag','DatamatPrefixLabel');

   x = x+w+0.01;
   y = (num_inputline-0) * factor_inputline - 0.1 * factor_inputline;
   w = 0.15;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Datamat Prefix Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String',' ', ...
   	'Callback','smallfc_session_profile_ui(''EDIT_DATAMAT_PREFIX'');', ...
   	'Tag','DatamatPrefixEdit');

   % left label

   x = 0.03;
   y = (num_inputline-1) * factor_inputline;
   w = 0.25;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% PLS Data Directory Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Working Directory:', ...
	'visible','off', ...
   	'Tag','PLSDataDirectoryLabel');

   x = x+w+0.01;
   y = (num_inputline-1) * factor_inputline - 0.1 * factor_inputline;
   w = 0.45;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% PLS Data Directory Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','                *  REQUIRED FIELD', ...
   	'Callback','smallfc_session_profile_ui(''EDIT_PLS_DATA_DIR'');', ...
	'visible','off', ...
   	'Tag','PLSDataDirectoryEdit');

   x = x+w+0.01;
   w = 0.15;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% PLS Data Directory Button
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'Position',pos, ...
        'String','Browse', ...
        'Enable','On', ...
   	'Callback','smallfc_session_profile_ui(''SELECT_PLS_DATA_DIR'');', ...
	'visible','off', ...
   	'Tag','PLSDataDirectoryButton');

   % left label

   x = 0.03;
   y = (num_inputline-1) * factor_inputline;
   w = 0.25;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Digitization Interval Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Digitization Interval:', ...
	'visible','off', ...
   	'Tag','DigitizationIntervalLabel');

   x = x+w+0.01;
   y = (num_inputline-1) * factor_inputline - 0.1 * factor_inputline;
   w = 0.07;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Digitization Interval Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','2', ...
   	'Callback','smallfc_session_profile_ui(''EDIT_DIGIT_INTERVAL'');', ...
	'visible','off', ...
   	'Tag','DigitIntervalEdit');

   x = x+w+0.01;
   y = (num_inputline-1) * factor_inputline;
   w = 0.06;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% (ms)
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
	'visible','off', ...
   	'String','(ms)');

   x = 0.49;
   w = 0.25;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Prestim Baseline Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Prestim Baseline:', ...
	'visible','off', ...
   	'Tag','PrestimBaselineLabel');

   x = x+w+0.01;
   y = (num_inputline-1) * factor_inputline - 0.1 * factor_inputline;
   w = 0.1;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Prestim Baseline Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
   	'Callback','smallfc_session_profile_ui(''EDIT_PRESTIM_BASELINE'');', ...
	'visible','off', ...
   	'Tag','PrestimBaselineEdit');

   x = x+w+0.01;
   y = (num_inputline-1) * factor_inputline;
   w = 0.06;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% (ms)
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
	'visible','off', ...
   	'String','(ms)');

   % left label

   x = 0.03;
   y = (num_inputline-1) * factor_inputline;
   w = 0.25;
   h = 0.3 	* factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Conditions Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Number of Conditions:', ...
   	'Tag','NumberConditionsLabel');

   x = x+w+0.01;
   y = (num_inputline-1) * factor_inputline - 0.1 * factor_inputline;
   w = 0.07;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Conditions Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
        'Enable','Inactive', ...
   	'ButtonDownFcn','smallfc_session_profile_ui(''EDIT_CONDITIONS_NUM'');', ...
   	'Tag','NumberConditionsEdit');

   x = x+w+0.03;
   w = 0.24;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Conditions Button
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'Position',pos, ...
        'String','Input Conditions', ...
        'Enable','On', ...
   	'Callback','smallfc_session_profile_ui(''EDIT_CONDITIONS'');', ...
   	'Tag','NumberConditionsButton');

   % left label

   x = 0.03;
   y = (num_inputline-2) * factor_inputline;
   w = 0.25;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Subjects Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Number of Subjects:', ...
   	'Tag','NumberSubjectsLabel');

   x = x+w+0.01;
   y = (num_inputline-2) * factor_inputline - 0.1 * factor_inputline;
   w = 0.07;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Subjects Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
        'Enable','Inactive', ...
   	'ButtonDownFcn','smallfc_session_profile_ui(''EDIT_NUM_SUBJECTS'');', ...
   	'Tag','NumberSubjectsEdit');

   x = x+w+0.03;
   w = 0.24;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Subjects Button
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'Position',pos, ...
        'String','Select Subjects', ...
        'Enable','On', ...
   	'Callback','smallfc_session_profile_ui(''EDIT_SUBJECTS'');', ...
   	'Tag','NumberSubjectsButton');

   x = x+w+0.03;
   w = 0.24;

   pos = [x y w h];

   chan_in_col = uicontrol('parent',h0, ... 		% read eeg format
        'unit','normal', ...
   	'Style','edit', ...
        'value',0, ...
        'fontunit','normal', ...
        'fontsize',0.5, ...
   	'HorizontalAlignment','left', ...
        'string','BESA format', ...
	'back',[1 1 1], ...
        'Enable','Inactive', ...
	'ButtonDownFcn','smallfc_session_profile_ui(''READ_EEG_FORMAT'');', ...
	'tag','read_eeg_format', ...
	'visible','off', ...
        'position',pos);

   % left label

   x = 0.03;
   y = (num_inputline-3) * factor_inputline;
   w = 0.25;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Channel Order Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Number of Channels:', ...
	'visible','off', ...
   	'Tag','ChanOrderLabel');

   x = x+w+0.01;
   y = (num_inputline-3) * factor_inputline - 0.1 * factor_inputline;
   w = 0.07;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Channel Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
        'Enable','Inactive', ...
   	'ButtonDownFcn','smallfc_session_profile_ui(''EDIT_NUM_CHANNELS'');', ...
	'visible','off', ...
   	'Tag','NumberChannelsEdit');

   x = x+w+0.03;
   w = 0.24;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Channel Order Edit
   	'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'Position',pos, ...
	'string', 'Edit Channel Order', ...
	'callback','smallfc_session_profile_ui(''EDIT_CHAN_ORDER'');', ...
	'visible','off', ...
   	'Tag','ChanOrderEdit');

   x = x+w+0.03;
   w = 0.24;

   pos = [x y w h];

   chan_in_col = uicontrol('parent',h0, ... 		% channel in column
        'unit','normal', ...
        'style','check', ...
        'value',0, ...
        'fontunit','normal', ...
        'fontsize',0.5, ...
        'string','Channel in column', ...
	'back',[0.8 0.8 0.8], ...
	'callback','smallfc_session_profile_ui(''CLICK_CHAN_IN_COL'');', ...
	'tag','chan_in_col', ...
	'visible','off', ...
        'position',pos);

   x = x+w+0.03;
   w = 0.24;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Load MEG Sensors Button
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'Position',pos, ...
        'String','Load MEG Sensors', ...
	'visible','off', ...
   	'Callback','smallfc_session_profile_ui(''LOAD_MEG_SENSORS'');', ...
   	'Tag','LoadMEGSensorsButton');

   % left label

   x = 0.03;
   y = (num_inputline-3) * factor_inputline;
   w = 0.25;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Dimension Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Data Dimension:', ...
   	'Tag','DimensionLabel');

   x = x+w+0.01;
   y = (num_inputline-3) * factor_inputline - 0.1 * factor_inputline;
   w = 0.25;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Dimension Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String',' ', ...
   	'Callback','smallfc_session_profile_ui(''EDIT_DIMENSION'');', ...
   	'Tag','DimensionEdit');

   % left label

   x = 0.12;	
   y = (num_inputline-4) * factor_inputline - 0.1 * factor_inputline;
   w = 0.24;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Create Datamat
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'Position',pos, ...
        'String','Create Datamat', ...
   	'Callback','smallfc_session_profile_ui(''MENU_CREATE_DATAMAT'');', ...
   	'Tag','CloseButton');

   x = x+w+0.03;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Modify Datamat
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'Position',pos, ...
        'String','Modify Datamat', ...
   	'Callback','smallfc_session_profile_ui(''MENU_MODIFY_DATAMAT'');', ...
	'visible','off', ...
   	'Tag','CloseButton');

   x = x+w+0.03;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Close Button
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'Position',pos, ...
        'String','CLOSE', ...
   	'Callback','smallfc_session_profile_ui(''DELETE_FIG'');', ...
   	'Tag','CloseButton');

   % left label

   x = 0.01;
   y = 0;
   w = 1;
   h = 0.3 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Message Line
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ForegroundColor',[0.8 0.0 0.0], ...
   	'FontUnits','normal', ...
   	'FontSize',0.8, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Tag','MessageLine');

   %  menu bar
   %
   h_file = uimenu('Parent',h0, ...
	'Label', '&File', ...
	'Tag', 'FileMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Load', ...
   	'Callback','smallfc_session_profile_ui(''MENU_LOAD_PLS_SESSION_INFO'');', ...
        'Tag', 'LoadPLSsession');
   m1 = uimenu(h_file, ...
        'Label', '&Create Datamat File ...', ...
   	'Callback','smallfc_session_profile_ui(''MENU_CREATE_DATAMAT'');', ...
        'Tag', 'CreateDatamatMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Save', ...
   	'Callback','smallfc_session_profile_ui(''MENU_SAVE_PLS_SESSION_INFO'');', ...
	'visible', 'off', ...
        'Tag', 'SavePLSsession');
   m1 = uimenu(h_file, ...
        'Label', 'S&ave as', ...
   	'Callback','smallfc_session_profile_ui(''MENU_SAVE_AS_PLS_SESSION_INFO'');', ...
	'visible', 'off', ...
        'Tag', 'SaveAsPLSsession');
   m1 = uimenu(h_file, ...
        'Label', '&Close', ...
   	'Callback','smallfc_session_profile_ui(''MENU_CLOSE_SESSION_INPUT'');', ...
        'Tag', 'CloseSsessionInput');

   h_file = uimenu('Parent',h0, ...
	'Label', '&Edit', ...
	'Tag', 'EditMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Change Data Paths', ...
   	'Callback','smallfc_session_profile_ui(''MENU_PATH_PLS_SESSION_INFO'');', ...
	'Enable','off', ...
        'Tag', 'PathPLSsessionMenu');
   m1 = uimenu(h_file, ...
	'separator', 'on', ...
        'Label', '&Clear Session', ...
   	'Callback','smallfc_session_profile_ui(''MENU_CLEAR_PLS_SESSION_INFO'');', ...
        'Tag', 'ClearPLSsessionMenu');

   h_file = uimenu('Parent',h0, ...
	'Label', '&Datamat', ...
	'visible', 'off', ...
	'Tag', 'DatamatMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Create Datamat File ...', ...
   	'Callback','smallfc_session_profile_ui(''MENU_CREATE_DATAMAT'');', ...
        'Tag', 'CreateDatamatMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Modify Datamat File ...', ...
   	'Callback','smallfc_session_profile_ui(''MENU_MODIFY_DATAMAT'');', ...
	'visible','off', ...
        'Tag', 'ModifyDatamatMenu');

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
           'Tag', 'Help');

%           'Callback','rri_helpfile_ui(''smallfc_session_profile_hlp.txt'',''How to use SESSION PROFILE'');', ...
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','web([''file:///'', which(''UserGuide.htm''), ''#_Toc128820716'']);', ...
	   'visible', 'on', ...
           'Tag', 'How');

   Hm_new = uimenu('Parent',Hm_topHelp, ...
           'Label', '&What''s new', ...
	   'Callback','rri_helpfile_ui(''whatsnew.txt'',''What''''s new'');', ...
           'Tag', 'New');
   Hm_about = uimenu('Parent',Hm_topHelp, ...
           'Label', '&About this program', ...
           'Tag', 'About', ...
           'Tag', 'About', ...
           'CallBack', 'plsgui_version');

%   setappdata(h0,'eeg_format',[]);
   setappdata(h0,'curr_dir',curr_dir);
%   setappdata(gcf,'SessionChanOrder','');
   ClearSessionInfo(1);

   return;						% init


%----------------------------------------------------------------------------

function delete_fig()
    if (CloseSessionInput == 1);
        curr_dir = getappdata(gcf,'curr_dir');
	% cd(curr_dir);
        % uiresume
	close(gcbf);
    end

    return


%----------------------------------------------------------------------------

function ClearSessionInfo(init_flag)
%  init_flag = 0  for clear operation
%  init_flag = 1  for initialization
%

   if (init_flag == 0 & ChkModified == 0)
   end;

   curr = getappdata(gcf,'curr_dir');

   session_info.description = '';
   session_info.pls_data_path = curr;
%   session_info.contrastdata = '';
   session_info.behavdata = '';
   session_info.behavname = {};
%   session_info.chan_order = '';
%   session_info.eeg_format =[];
%   session_info.num_contrast = 0;
%   session_info.num_behavior = 0;
%   session_info.num_channels = 0;
%   session_info.prestim_baseline = 0;
%   session_info.digit_interval = 2;
   session_info.datamat_prefix = '';
   session_info.dims = [];
   session_info.num_conditions = 0;
   session_info.condition = {};
   session_info.num_subjects = 0;
   session_info.subject = {};
   session_info.subj_name = {};
   session_info.subj_files = {};
%   session_info.chan_in_col = 0;
%   session_info.system = '';
   session_info.num_subj_init = -1;
   setappdata(gcf,'reselect_subj', 0);

   SetSessionInfo(session_info,'')
   set(findobj(gcf,'Tag','PathPLSsessionMenu'),'enable','off');

   return;						% ClearSessionInfo


%----------------------------------------------------------------------------
%
%       set session field. called by load session & clear session
%
%----------------------------------------------------------------------------

function SetSessionInfo(session_info,session_file)

   setappdata(gcf,'SessionDescription',session_info.description);
   setappdata(gcf,'SessionPLSDir',session_info.pls_data_path);
%   setappdata(gcf,'SessionContrastData',session_info.contrastdata);
   setappdata(gcf,'SessionBehavData',session_info.behavdata);

   if ~isfield(session_info,'behavname')
      session_info.behavname = {};
      for i=1:size(session_info.behavdata,2)
         session_info.behavname = [session_info.behavname, {['behav', num2str(i)]}];
      end
   end

   setappdata(gcf,'SessionBehavName',session_info.behavname);

%   setappdata(gcf,'SessionChanOrder',session_info.chan_order);

%   if ~isfield(session_info,'eeg_format')
 %     session_info.eeg_format = [];
  % end

%   setappdata(gcf,'eeg_format',session_info.eeg_format);

%   setappdata(gcf,'SessionNumContrast',session_info.num_contrast);
%   setappdata(gcf,'SessionNumBehavior',session_info.num_behavior);
%   setappdata(gcf,'SessionNumChannels',session_info.num_channels);
%   setappdata(gcf,'SessionPrestimBaseline',session_info.prestim_baseline);
%   setappdata(gcf,'SessionDigitInterval',session_info.digit_interval);
   setappdata(gcf,'SessionDatamatPrefix',session_info.datamat_prefix);

   if ~isfield(session_info,'dims')
      session_info.dims = [];
   end

   setappdata(gcf,'SessionDataDimension',session_info.dims);
   setappdata(gcf,'SessionNumConditions',session_info.num_conditions);
   setappdata(gcf,'SessionConditions',session_info.condition);
   setappdata(gcf,'SessionNumSubjects',session_info.num_subjects);
   setappdata(gcf,'SessionSubject',session_info.subject);
   setappdata(gcf,'subj_name',session_info.subj_name);
   setappdata(gcf,'subj_files',session_info.subj_files);
%   setappdata(gcf,'chan_in_col',session_info.chan_in_col);

%   if ~isfield(session_info,'system')
 %     session_info.system.class = 1;
  %    session_info.system.type = 1;
   %end

%   setappdata(gcf,'system',session_info.system);

   if ~isfield(session_info,'num_subj_init')
      session_info.num_subj_init = -1;
   end

   setappdata(gcf,'num_subj_init',session_info.num_subj_init);

   setappdata(gcf,'OldSessionInfo',session_info);
   setappdata(gcf,'SessionFile',session_file);

   if isempty(session_file)
      set(gcf,'Name','New Small FC Session Information');
   else
      [pathname, filename] = rri_fileparts(session_file);
      set(gcf,'Name',['Session File: ' filename]);
   end;

   return;						% SetSessionInfo


%----------------------------------------------------------------------------
%
%       get session field. called by saveSession, checkModify, & createDatamat
%
%----------------------------------------------------------------------------

function [session_info,session_file,old_session_info] = GetSessionInfo(),

   session_info.description = getappdata(gcf,'SessionDescription');
   session_info.pls_data_path = getappdata(gcf,'SessionPLSDir');
%   session_info.contrastdata = getappdata(gcf,'SessionContrastData');
   session_info.behavdata = getappdata(gcf,'SessionBehavData');
   session_info.behavname = getappdata(gcf,'SessionBehavName');
%   session_info.chan_order = getappdata(gcf,'SessionChanOrder');
%   session_info.eeg_format = getappdata(gcf,'eeg_format');
%   session_info.num_contrast = getappdata(gcf,'SessionNumContrast');
%   session_info.num_behavior = getappdata(gcf,'SessionNumBehavior');
%   session_info.num_channels = getappdata(gcf,'SessionNumChannels');
%   session_info.prestim_baseline = getappdata(gcf,'SessionPrestimBaseline');
%   session_info.digit_interval = getappdata(gcf,'SessionDigitInterval');
   session_info.datamat_prefix = getappdata(gcf,'SessionDatamatPrefix');
   session_info.dims = getappdata(gcf,'SessionDataDimension');
   session_info.num_conditions = getappdata(gcf,'SessionNumConditions');
   session_info.condition = getappdata(gcf,'SessionConditions');
   session_info.num_subjects = getappdata(gcf,'SessionNumSubjects');
   session_info.subject = getappdata(gcf,'SessionSubject');
   session_info.subj_name = getappdata(gcf,'subj_name');
   session_info.subj_files = getappdata(gcf,'subj_files');

%   h = findobj(gcf,'Tag','chan_in_col');
%   session_info.chan_in_col = get(h,'value');

%   session_info.system = getappdata(gcf,'system');
   session_info.num_subj_init = getappdata(gcf,'num_subj_init');

   session_file = getappdata(gcf,'SessionFile');
   old_session_info = getappdata(gcf,'OldSessionInfo');

   return;						% GetSessionInfo


%----------------------------------------------------------------------------
%
%       Display sessioninfo, called AFTER load session & clear session
%
%----------------------------------------------------------------------------

function ShowSessionInfo()

   h = findobj(gcf,'Tag','SessionDescriptionEdit'); 
   set(h,'String',getappdata(gcf,'SessionDescription'));

   h = findobj(gcf,'Tag','PLSDataDirectoryEdit');
   set(h,'String',getappdata(gcf,'SessionPLSDir'));

   h = findobj(gcf,'Tag','PrestimBaselineEdit');
   set(h,'String',num2str(getappdata(gcf,'SessionPrestimBaseline')));

   h = findobj(gcf,'Tag','DigitIntervalEdit');
   set(h,'String',num2str(getappdata(gcf,'SessionDigitInterval')));

   datamat_prefix = getappdata(gcf,'SessionDatamatPrefix');
   [fpath fname] = fileparts(datamat_prefix);
   h = findobj(gcf,'Tag','DatamatPrefixEdit'); 
   set(h,'String',fname);

   dims = getappdata(gcf,'SessionDataDimension');
   h = findobj(gcf,'Tag','DimensionEdit'); 
   set(h,'String',num2str(dims));

%   num_contrast = getappdata(gcf,'SessionNumContrast');
%   h = findobj(gcf,'Tag','NumberContrastEdit'); 
%   set(h,'String',num_contrast);

%   num_behavior = getappdata(gcf,'SessionNumBehavior');
%   h = findobj(gcf,'Tag','NumberBehaviorEdit'); 
%   set(h,'String',num_behavior);

%   num_channels = getappdata(gcf,'SessionNumChannels');
%   h = findobj(gcf,'Tag','NumberChannelsEdit'); 
%   set(h,'String',num_channels);

   num_subjects = getappdata(gcf,'SessionNumSubjects');
   h = findobj(gcf,'Tag','NumberSubjectsEdit'); 
   set(h,'String',num_subjects);

   num_conds = getappdata(gcf,'SessionNumConditions');
   h = findobj(gcf,'Tag','NumberConditionsEdit'); 
   set(h,'String',num_conds);

%   chan_in_col = getappdata(gcf,'chan_in_col');
%   h = findobj(gcf,'Tag','chan_in_col');
%   set(h,'value',chan_in_col);

%   eeg_format = getappdata(gcf,'eeg_format');
 %  h = findobj(gcf,'Tag','read_eeg_format');
  % if isempty(eeg_format) | strcmp(eeg_format.vendor, 'BESA')
   %   format_str = 'BESA format';
%   else
 %     format_str = [eeg_format.machineformat ' ' eeg_format.vendor ' format'];
  % end
   %set(h,'string',format_str);

   return;						% ShowSessionInfo


%----------------------------------------------------------------------------

function LoadSessionInfo()

   if ~isempty(getappdata(gcf,'OldSessionInfo'))
      if (ChkModified == 0)
      end;
   end;
   [filename, pathname] = rri_selectfile( '*_SmallFCsessiondata.mat', 'Load a PLS session file');

   if isequal(filename,0) | isequal(pathname,0)
      return;
   end;

   cd(pathname);
   session_file = fullfile(pathname, filename);

   try
      load(session_file);
   catch
      msg = 'ERROR: Cannot load the session information';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   if ~exist(session_info.pls_data_path,'dir') | ~exist(session_info.subject{1},'dir')
      msg = 'Invalid path inside. Click Edit menu to Change Data Paths';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   end

   %  move to the PLS directory
   %
   pls_dir = session_info.pls_data_path;
   if ( exist(pls_dir,'dir') == 7 ) 	   % specified directory exists
%      cd(pls_dir);
   else
%      msg = 'WARNING: The PLS directory does not exist!';
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   end;

   SetSessionInfo(session_info,session_file)
   set(findobj(gcf,'Tag','PathPLSsessionMenu'),'enable','on');

   return;						% LoadSessionInfo


%----------------------------------------------------------------------------

function status = SaveSessionInfo(save_as_flag)
%  save_as_flag = 0,  save to the loaded file
%  save_as_flag = 1,  save to a new file
%
   status = 0;

   if ~exist('save_as_flag','var')
     save_as_flag = 0;
   end;

   [session_info,session_file,old_session_info] = GetSessionInfo;

   if (getappdata(gcf,'reselect_subj'))
      msg = sprintf('All subjects need to be modified with new conditions before saving.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   if isempty(session_info.pls_data_path),
      msg = sprintf('A working directory needs to be specified before saving.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   if isempty(session_info.datamat_prefix),
      msg = sprintf('A datamat prefix needs to be specified before saving.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   if isempty(session_info.dims),
      msg = sprintf('Data dimensions need to be specified before saving.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   if (session_info.num_subjects == 0),
      msg = sprintf('Subjects need to be selected before saving.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   if (session_info.num_conditions == 0),
      msg = sprintf('Conditions need to be selected before saving.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   setappdata(gcf, 'session_info', session_info);
   status = 1;

   return;						% SaveSessionInfo


%----------------------------------------------------------------------------

function status = CloseSessionInput()

   if (ChkModified == 0)
        status = 0;
   end;

   status = 1;
   return;						% CloseSessionInput


%----------------------------------------------------------------------------

function EditPLSDataDir

   pls_dir = deblank(strjust(get(gcbo,'String'),'left')); 

   emptydir = 0;
   emptypath = 0;

   if isempty(pls_dir)
      emptydir = 1;
   end;

   set(gcbo,'String',pls_dir);
   
   %  
   if (~emptydir)
      if ( exist(pls_dir,'dir') == 7 ) 	   % specified directory exists
         setappdata(gcf,'SessionPLSDir',pls_dir);
         cd(pls_dir)
         return;
      end;

      if ( exist(pls_dir,'file') == 2 )	   % it is a file!
         msg = 'ERROR: The specified direcotry is a file!';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         setappdata(gcf,'SessionPLSDir','');
         return;
      end;
   end;

   %   the directory does not exist, how about the parent directory ?
   %
   [fpath,fname,fext] = fileparts(pls_dir);

   if isempty(fpath)
      emptypath = 1;
   end;

   if (~emptydir & ~emptypath & exist(fpath,'dir') == 7 ) % parent directory exists
      dlg_title = 'PLS Directory';
      msg = 'The directory does not exist.  Do you want to create it?';
      response = questdlg(msg,dlg_title,'Yes','No','Yes');

      switch response,
         case 'Yes',
            status = mkdir(fpath,[fname fext]);
            if (status ~= 1)
               msg = sprintf('ERROR: Directory cannot be created');
               set(findobj(gcf,'Tag','MessageLine'),'String',msg);
               setappdata(gcf,'SessionPLSDir','');
            else
               setappdata(gcf,'SessionPLSDir',pls_dir);
               cd(pls_dir);
            end
               return;
         case 'No',
            set(gcbo,'String','');
            setappdata(gcf,'SessionPLSDir','');
      end; 
   else   
      msg = 'ERROR: Invalid input direcotry!'; 
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   end;

   return;						% EditPLSDataDir


%----------------------------------------------------------------------------

function SelectPLSDataDir

   h = findobj(gcf,'Tag','PLSDataDirectoryEdit');
   pls_data_dir = rri_getdirectory({get(h,'String')});

   if ~isempty(pls_data_dir),
       set(h,'String',pls_data_dir); 
       set(h,'TooltipString',pls_data_dir); 
       setappdata(gcf,'SessionPLSDir',pls_data_dir);
       cd(pls_data_dir);
   end;

   return;						% SelectPLSDataDir


%----------------------------------------------------------------------------

function EditConditions()

   condition = getappdata(gcf,'SessionConditions');
   old_subj_files = getappdata(gcf,'subj_files');

   % Input conditions
   %
   [new_condition, subj_files, reselect_subj] = ...
		rri_input_condition_ui(condition, old_subj_files);

   num_conds = num2str(length(new_condition));
   set(findobj(gcf,'Tag','NumberConditionsEdit'),'String',num_conds);

   setappdata(gcf,'SessionNumConditions',length(new_condition));
   setappdata(gcf,'SessionConditions',new_condition);
   setappdata(gcf,'subj_files', subj_files);
   setappdata(gcf,'reselect_subj', reselect_subj);

   return;						% EditConditions


%----------------------------------------------------------------------------

function EditSubjects()

   num_subj_init = getappdata(gcf,'num_subj_init');
   num_subjects = getappdata(gcf,'SessionNumSubjects');
   old_subjects = getappdata(gcf,'SessionSubject');
   old_subj_files = getappdata(gcf,'subj_files');
   condition = getappdata(gcf,'SessionConditions');
   selected_conditions = ones(1,length(condition));

   % edit the names of subjects
   %
   [subjects, subj_files, num_subj_init] = ...
	rri_input_subject_ui(old_subjects, old_subj_files, ...
	condition, selected_conditions, num_subj_init, '*.txt');

   num_subjs = num2str(length(subjects));
   set(findobj(gcf,'Tag','NumberSubjectsEdit'),'String',num_subjs);

   % use subject file name as subject name
   %
   subj_name = [];
   for i=1:length(subjects)
      [fpath fname] = fileparts(subjects{i});
      subj_name{i} = fname;
   end

   setappdata(gcf,'num_subj_init',num_subj_init);
   setappdata(gcf,'SessionNumSubjects',length(subjects));
   setappdata(gcf,'SessionSubject',subjects);
   setappdata(gcf,'subj_name', subj_name);
   setappdata(gcf,'subj_files', subj_files);
   setappdata(gcf,'reselect_subj', 0);

   return;						% EditSubjects


%----------------------------------------------------------------------------

function status = ChkModified()
% Output:
%          status = 0, error
% 	   status = 1, ok

   status = 1;
return;
   [session_info,session_file,old_session_info] = GetSessionInfo;

   if (isequal(session_info,old_session_info) == 0),
      dlg_title = 'Session Information has been changed';
      msg = 'WARNING: The session information has been changed.  Do you want to save it?';
      response = questdlg(msg,dlg_title,'Yes','No','Cancel','Yes');

      switch response,
         case 'Yes'
 	      status = SaveSessionInfo;
         case 'Cancel'
 	      status = 0;
         case 'No'
 	      status = 2;
      end;
   end;

   return;						% ChkModified


%----------------------------------------------------------------------------

function CreateDatamat()

   %  make sure the session information has been saved
   %
   [session_info,session_file,old_session_info] = GetSessionInfo;


status = SaveSessionInfo;
session_info = getappdata(gcf, 'session_info');
if (status ~= 0),  smallfc_create_datamat({session_info});  end;
return;


   if isempty(session_file) | isequal(session_info,old_session_info) == 0

       status = ChkModified;

       session_file = getappdata(gcf,'SessionFile');

       if isempty(session_file)
          % status = 2;
          return;
       end

       if (status == 0)
          return;
       elseif (status == 2)
          msg =  'ERROR: Save the session information before creating datamat.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
       end
   end;

 %  calling_fig = getappdata(gcf,'CallingFigure');
 %  close(calling_fig);

%   h_session = gcf;


   subject = session_info.subject;
   subj_files = session_info.subj_files;
   subj = fullfile(subject{1}, subj_files{1,1});
   tmp = load(subj);
   tmp = tmp(:);

   if length(tmp) ~= prod(session_info.dims)
       msg =  'ERROR: Data dimension does not match subject file.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   end


   smallfc_create_datamat({session_file});

%   close(h_session);

   return;						% CreateDatamat


%----------------------------------------------------------------------------
function PathSessionInfo(init_flag)
%  init_flag = 0  for clear operation
%  init_flag = 1  for initialization
%

   if (init_flag == 0 & ChkModified == 0)
   end;

   old_session_info = getappdata(gcf,'OldSessionInfo');
   session_info = old_session_info;
   session_info = rri_changepath_se(session_info);

   if isempty(session_info)
      session_info = old_session_info;
   end

   setappdata(gcf,'SessionPLSDir',session_info.pls_data_path);
   setappdata(gcf,'SessionSubject',session_info.subject);

   return;						% PathSessionInfo

