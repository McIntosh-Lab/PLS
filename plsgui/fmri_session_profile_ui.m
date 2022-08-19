function fmri_session_profile_ui(varargin) 
% 
%  USAGE:  fmri_session_profile_ui(varargin) 
% 
%  fmri_session_profile_ui - create input condition GUI 
% 


   if nargin == 0, 

      if exist('plslog.m','file')
         plslog('Edit fMRI Session');
      end

      curr = pwd;
      if isempty(curr)
         curr = filesep;
      end

      start_dir = curr;

      init;

      setappdata(gcf,'CallingFigure',gcbf); 
      set(gcbf,'visible','off');

      uiwait(gcf);			% wait for user finish 
      close(gcf);

%      cd(start_dir);
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
         uiresume;
      end
   elseif strcmp(action,'MENU_CLEAR_PLS_SESSION_INFO'),
      ClearSessionInfo(0);
      ShowSessionInfo;
   elseif strcmp(action,'MENU_PATH_PLS_SESSION_INFO'),
      PathSessionInfo(0);
      ShowSessionInfo;
   elseif strcmp(action,'MENU_MERGE_CONDITIONS'),
      MergeConditions;
   elseif strcmp(action,'MENU_CREATE_CONTRASTS'),
      conditions = getappdata(gcf,'SessionConditions');
      contrast_ui_fig = fmri_input_contrast_ui([],conditions);
      waitfor(contrast_ui_fig);
   elseif strcmp(action,'MENU_CREATE_ST_DATAMAT'),
      CreateSTDatamat;
   elseif strcmp(action,'MENU_MODIFY_BEHAV'),
      ModifyBehav;
   elseif strcmp(action,'MENU_MERGE_ST_DATAMAT'),
      MergeSTDatamat;
   elseif strcmp(action,'MENU_STD'),
      datamat_prefix = getappdata(gcf,'SessionDatamatPrefix');
      pls_data_path = getappdata(gcf,'SessionPLSDir');

      if isempty(datamat_prefix) | isempty(pls_data_path)
         msg = 'Please have session saved and datamat created';
         uiwait(msgbox(msg,'Error'));
      else
         fmri_apply_std(1, datamat_prefix, pls_data_path);
      end;
   elseif strcmp(action,'EDIT_DESCRIPTION'),
      description = deblank(strjust(get(gcbo,'String'),'left')); 
      set(gcbo,'String',description);
      setappdata(gcf,'SessionDescription',description);
   elseif strcmp(action,'EDIT_PLS_DATA_DIR'),
      EditPLSDataDir;
   elseif strcmp(action,'SELECT_PLS_DATA_DIR'),
      SelectPLSDataDir;
   elseif strcmp(action,'EDIT_DATAMAT_PREFIX'),
      EditDatamatPrefix;
   elseif strcmp(action,'EDIT_CONDITIONS_NUM'),
      msg = 'Click the "Edit Conditions ..." button to set the condition names';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_CONDITIONS'),
      EditConditions;
   elseif strcmp(action,'EDIT_NUM_RUNS'),
      EditRunNumber;
   elseif strcmp(action,'EDIT_RUNS'),
      EditRuns;
   elseif strcmp(action,'DELETE_FIG'),
      delete_fig;
   elseif strcmp(action,'DELETE_FIGURE'),
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         fmri_session_profile_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'fmri_session_profile_pos');
      catch
      end

      calling_fig = getappdata(gcf,'CallingFigure');
      set(calling_fig,'visible','on');
   elseif strcmp(action,'MERGE_DATA_WITH_RUN_BUTTON'),
      SelectMergeDataWithinRun;
   elseif strcmp(action,'MERGE_DATA_ACROSS_RUNS_BUTTON'),
      SelectMergeDataAcrossRuns;
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
   fmri_session_profile_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_session_profile_pos) & strcmp(save_setting_status,'on')

      pos = fmri_session_profile_pos;

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
        'DeleteFcn','fmri_session_profile_ui(''DELETE_FIGURE'');', ...
   	'Tag','EditSessionInformation', ...
   	'ToolBar','none');

   % numbers of inputing line excluding 'MessageLine'

   num_inputline = 5;
   factor_inputline = 1/(num_inputline+1);

   % left label

   x = 0.05;
   y = (num_inputline-0) * factor_inputline;
   w = 0.25;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   fnt = 0.5;

   c = uicontrol('Parent',h0, ...		% Session Description Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','Session Description: ', ...
   	'Tag','SessionDescriptionLabel');

   x = x+w+0.01;
   w = 0.59;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Session Description Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'FontUnit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Callback','fmri_session_profile_ui(''EDIT_DESCRIPTION'');', ...
   	'Tag','SessionDescriptionEdit');

   x = 0.05;
   y = (num_inputline-1) * factor_inputline;
   w = 0.25;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% PLS Data Directory Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','PLS Data Directory: ', ...
	'visible','off', ...
   	'Tag','PLSDataDirectoryLabel');

   x = x+w+0.01;
   w = 0.43;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% PLS Data Directory Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Callback','fmri_session_profile_ui(''EDIT_PLS_DATA_DIR'');', ...
	'visible','off', ...
   	'Tag','PLSDataDirectoryEdit');

   x = x+w+0.01;
   w = 0.15;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% PLS Data Directory Button
   	'Style','pushbutton', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','Browse ...', ...
   	'Callback','fmri_session_profile_ui(''SELECT_PLS_DATA_DIR'');', ...
	'visible','off', ...
   	'Tag','PLSDataDirectoryButton');


   x = 0.05;
   y = (num_inputline-1) * factor_inputline;
   w = 0.25;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Datamat Prefix  Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Datamat Prefix: ', ...
   	'Tag','DatamatPrefixLabel');

   x = x+w+0.01;
   w = 0.3;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Datamat Prefix Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Callback','fmri_session_profile_ui(''EDIT_DATAMAT_PREFIX'');', ...
   	'Tag','DatamatPrefixEdit');

   x = 0.05;
   y = (num_inputline-2) * factor_inputline;
   w = 0.25;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Merge Data Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Merge Data: ', ...
   	'Tag','MergeDataLabel');

   x = x+w+0.01;
   w = 0.3;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Merge Data Across Runs Button
   	'Style','radiobutton', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
        'Value', 1, ...
   	'Position',pos, ...
   	'String','Across All Runs', ...
   	'Callback','fmri_session_profile_ui(''MERGE_DATA_ACROSS_RUNS_BUTTON'');', ...
   	'Tag','MergeDataAcrossRunsButton');

   x = x+w;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Merge Data Within Run Button
   	'Style','radiobutton', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
        'Value', 0, ...
   	'Position',pos, ...
   	'String','Within Each Run', ...
   	'Callback','fmri_session_profile_ui(''MERGE_DATA_WITH_RUN_BUTTON'');', ...
   	'Tag','MergeDataWithinRunButton');

   x = 0.05;
   y = (num_inputline-3) * factor_inputline;
   w = 0.25;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Conditions Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Number of Conditions: ', ...
   	'Tag','NumberConditionsLabel');

   x = x+w+0.01;
   w = 0.07;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Conditions Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','0', ...
        'Enable','Inactive', ...
   	'ButtonDownFcn','fmri_session_profile_ui(''EDIT_CONDITIONS_NUM'');', ...
   	'Tag','NumberConditionsEdit');

   x = x+w+0.01;
   w = 0.22;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Conditions Button
   	'Style','pushbutton', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','Edit Conditions ...', ...
   	'Callback','fmri_session_profile_ui(''EDIT_CONDITIONS'');', ...
   	'Tag','NumberConditionsButton');

   x = x+w+0.04;
   w = 0.25;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Create ST Datamat
   	'Style','pushbutton', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','Create ST Datamat ...', ...
   	'Callback','fmri_session_profile_ui(''MENU_CREATE_ST_DATAMAT'');', ...
   	'Tag','CreateSTDatamatButton');

   x = 0.05;
   y = (num_inputline-4) * factor_inputline;
   w = 0.25;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Runs Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Number of Runs: ', ...
   	'Tag','NumberRunsLabel');

   x = x+w+0.01;
   w = 0.07;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Runs Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit', 'normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','0', ...
   	'Callback','fmri_session_profile_ui(''EDIT_NUM_RUNS'');', ...
   	'Tag','NumberRunsEdit');

   x = x+w+0.01;
   w = 0.22;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Runs Button
   	'Style','pushbutton', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','Edit Runs ...', ...
        'Enable','off', ...
   	'Callback','fmri_session_profile_ui(''EDIT_RUNS'');', ...
   	'Tag','NumberRunsButton');

   x = x+w+0.04;
   w = 0.25;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Close Button
   	'Style','pushbutton', ...
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
        'Position',pos, ...
        'String','CLOSE', ...
   	'Callback','fmri_session_profile_ui(''DELETE_FIG'');', ...
   	'Tag','CloseButton');

   x = 0.01;
   y = 0;
   w = 1;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Message Line
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ForegroundColor',[0.8 0.0 0.0], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
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
   	'Callback','fmri_session_profile_ui(''MENU_LOAD_PLS_SESSION_INFO'');', ...
        'Tag', 'LoadPLSsession');
   m1 = uimenu(h_file, ...
        'Label', '&Create ST Datamat', ...
   	'Callback','fmri_session_profile_ui(''MENU_CREATE_ST_DATAMAT'');', ...
        'Tag', 'CreateDatamatMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Save', ...
   	'Callback','fmri_session_profile_ui(''MENU_SAVE_PLS_SESSION_INFO'');', ...
	'visible', 'off', ...
        'Tag', 'SavePLSsession');
   m1 = uimenu(h_file, ...
        'Label', 'S&ave as', ...
   	'Callback','fmri_session_profile_ui(''MENU_SAVE_AS_PLS_SESSION_INFO'');', ...
	'visible', 'off', ...
        'Tag', 'SaveAsPLSsession');
   m1 = uimenu(h_file, ...
        'Label', '&Close', ...
   	'Callback','fmri_session_profile_ui(''MENU_CLOSE_SESSION_INPUT'');', ...
        'Tag', 'CloseSsessionInput');

   h_file = uimenu('Parent',h0, ...
	'Label', '&Edit', ...
	'Tag', 'EditMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Change Data Paths', ...
   	'Callback','fmri_session_profile_ui(''MENU_PATH_PLS_SESSION_INFO'');', ...
	'Enable','off', ...
        'Tag', 'PathPLSsessionMenu');
   m1 = uimenu(h_file, ...
	'separator', 'on', ...
        'Label', '&Clear Session', ...
   	'Callback','fmri_session_profile_ui(''MENU_CLEAR_PLS_SESSION_INFO'');', ...
        'Tag', 'ClearPLSsessionMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Merge Conditions', ...
   	'Callback','fmri_session_profile_ui(''MENU_MERGE_CONDITIONS'');', ...
        'Enable','off', ...
        'Tag', 'MergeConditionsMenu');
   m1 = uimenu(h_file, ...
        'Label', 'C&reate Contrasts', ...
   	'Callback','fmri_session_profile_ui(''MENU_CREATE_CONTRASTS'');', ...
	'visible', 'off', ...
        'Tag', 'CreateContrastsMenu');

   h_file = uimenu('Parent',h0, ...
	'Label', '&Datamat', ...
	'visible', 'off', ...
	'Tag', 'DatamatMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Create ST Datamat', ...
   	'Callback','fmri_session_profile_ui(''MENU_CREATE_ST_DATAMAT'');', ...
        'Tag', 'CreateDatamatMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Input Seed PLS Behav Data and Modify Datamat', ...
   	'Callback','fmri_session_profile_ui(''MENU_MODIFY_BEHAV'');', ...
        'Enable','off', ...
	'visible', 'off', ...
        'Tag', 'ModifyBehavMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Apply STD to Datamat', ...
   	'Callback','fmri_session_profile_ui(''MENU_STD'');', ...
	'enable','off', ...
	'visible', 'off', ...
        'Tag', 'STDDatamatMenu');
%   m1 = uimenu(h_file, ...
%        'Label', '&Merge ST Datamat', ...
%   	'Callback','fmri_session_profile_ui(''MENU_MERGE_ST_DATAMAT'');', ...
%        'Tag', 'MergeDatamatMenu');

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
           'Tag', 'Help');

%           'Callback','rri_helpfile_ui(''fmri_session_profile_hlp.txt'',''How to use SESSION PROFILE'');', ...
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','web([''file:///'', which(''UserGuide.htm''), ''#_Toc128820719'']);', ...
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

   setappdata(h0,'curr_dir',curr_dir);
   ClearSessionInfo(1);


   session_lst = dir('*_fMRIsession.mat');
   sessiondata_lst = dir('*_fMRIsessiondata.mat');

   if ~isempty(session_lst) & isempty(sessiondata_lst)
      msg = 'PLS now combines session/datamat files to sessiondata ';
      msg = [msg 'file. You must use commmand session2sessiondata '];
      msg = [msg 'to convert session/datamat into sessiondata. For '];
      msg = [msg 'more detail, please type: help session2sessiondata'];
      uiwait(msgbox(msg,'Error','modal'));
   end


   return;						% init


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
   session_info.datamat_prefix = '';
   session_info.num_conditions = 0;
   session_info.condition = [];
   session_info.condition_baseline = {};
   session_info.num_conditions0 = 0;
   session_info.condition0 = [];
   session_info.condition_baseline0 = {};
   session_info.num_runs = 0;
   session_info.run = [];
   session_info.across_run = 1;

   SetSessionInfo(session_info,'')
   set(findobj(gcf,'Tag','STDDatamatMenu'),'enable','off');
   set(findobj(gcf,'Tag','ModifyBehavMenu'),'enable','off');
   set(findobj(gcf,'Tag','PathPLSsessionMenu'),'enable','off');

   return;						% ClearSessionInfo


%----------------------------------------------------------------------------
function LoadSessionInfo()

   if ~isempty(getappdata(gcf,'OldSessionInfo'))
      if (ChkModified == 0)
      end;
   end;

   [filename, pathname] = rri_selectfile( '*_fMRIsessiondata.mat', 'Load a PLS session file');

   if isequal(filename,0) | isequal(pathname,0)
      return;
   end;

   cd(pathname);
   session_file = fullfile(pathname, filename);

   try
      pls_session = load(session_file);
   catch
      msg = 'ERROR: Cannot load the session information';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   if ~exist(pls_session.session_info.pls_data_path,'dir') | ~exist(pls_session.session_info.run(1).data_path,'dir')
      msg = 'Invalid path inside. Click Edit menu to Change Data Paths';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   end

   %  move to the PLS directory
   %
   pls_dir = pls_session.session_info.pls_data_path;
   if ( exist(pls_dir,'dir') == 7 ) 	   % specified directory exists
%      cd(pls_dir);
   else
%      msg = 'WARNING: The PLS directory does not exist!';
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   end;
   
   SetSessionInfo(pls_session.session_info,session_file)
   set(findobj(gcf,'Tag','STDDatamatMenu'),'enable','on');
   set(findobj(gcf,'Tag','ModifyBehavMenu'),'enable','on');
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

   if isempty(session_info.pls_data_path),
      msg = sprintf('PLS directory has to be specified before saving.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   if isempty(session_info.datamat_prefix),
      msg = sprintf('A datamat prefix needs to be specified before saving.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   num_conditions = session_info.num_conditions0;
   num_runs = session_info.num_runs; 

   if num_conditions == 0 | num_runs == 0
      msg = sprintf('Need both Condition & Run information.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end

   if ( length(session_info.run) >= num_runs )
      session_info.run = session_info.run(1:num_runs);
   else
      msg = sprintf('Run number exceed existing run.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   %  check if there is any empty condition across run
   %
   for i = 1:num_runs
      run_cond(i,:) = cellfun('isempty', session_info.run(i).evt_onsets);
      run_cond(i,:) = ~run_cond(i,:);
   end

%   run_cond = sum(run_cond, 1);

   if ~isempty(find(run_cond == 0))
%      msg = sprintf('One condition onsets is empty across run.');
      msg = sprintf('onset field should not be empty.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end

%   if session_info.across_run
      session_info.num_conditions = session_info.num_conditions0;
      session_info.condition = session_info.condition0;
      session_info.condition_baseline = session_info.condition_baseline0;
   if ~session_info.across_run  % else
      session_info.num_conditions = session_info.num_runs * session_info.num_conditions0;

      for i = 1:session_info.num_runs
         for j = 1:session_info.num_conditions0
            session_info.condition{ (i-1)*session_info.num_conditions0 + j } = ...
		[ 'Run' num2str(i) session_info.condition0{j} ];
         end
      end

      session_info.condition_baseline = ...
	repmat(session_info.condition_baseline0, [session_info.num_runs 1]);
      session_info.condition_baseline = session_info.condition_baseline';
      session_info.condition_baseline = [session_info.condition_baseline(:)]';
   end

   setappdata(gcf,'SessionNumConditions',session_info.num_conditions);
   setappdata(gcf,'SessionConditions',session_info.condition);
   setappdata(gcf,'SessionConditionBaseline',session_info.condition_baseline);

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
function ShowSessionInfo()

   h = findobj(gcf,'Tag','SessionDescriptionEdit'); 
   set(h,'String',getappdata(gcf,'SessionDescription'));

   h = findobj(gcf,'Tag','PLSDataDirectoryEdit'); 
   set(h,'String',getappdata(gcf,'SessionPLSDir'));

   h = findobj(gcf,'Tag','DatamatPrefixEdit'); 
   set(h,'String',getappdata(gcf,'SessionDatamatPrefix'));

   num_conds = getappdata(gcf,'SessionNumConditions0');
   h = findobj(gcf,'Tag','NumberConditionsEdit'); 
   set(h,'String',num_conds);

   if (num_conds <= 0),
     set(findobj(gcf,'Tag','MergeConditionsMenu'),'Enable','off');
   else
     set(findobj(gcf,'Tag','MergeConditionsMenu'),'Enable','on');
   end;

   num_runs = getappdata(gcf,'SessionNumRuns');
   h = findobj(gcf,'Tag','NumberRunsEdit'); 
   if (num_runs <= 0)
     set(h,'String','0');
     set(findobj(gcf,'Tag','NumberRunsButton'),'Enable','off');
   else
     set(h,'String',num2str(num_runs));
     set(findobj(gcf,'Tag','NumberRunsButton'),'Enable','on');
   end;

   h1 = findobj(gcf,'Tag','MergeDataAcrossRunsButton'); 
   h2 = findobj(gcf,'Tag','MergeDataWithinRunButton'); 
   if getappdata(gcf,'SessionAcrossRun')
      set(h1,'value',1);
      set(h2,'value',0);
   else
      set(h1,'value',0);
      set(h2,'value',1);
   end

   return;						% ShowSessionInfo


%----------------------------------------------------------------------------
function EditPLSDataDir

   pls_dir = deblank(strjust(get(gcbo,'String'),'left')); 
   set(gcbo,'String',pls_dir);
   
   %  
   if ( exist(pls_dir,'dir') == 7 ) 	   % specified directory exists
      setappdata(gcf,'SessionPLSDir',pls_dir);
      return;
   end;

   if ( exist(pls_dir,'file') == 2 )	   % it is a file!
      msg = 'ERROR: The specified direcotry is a file!';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   %   the directory does not exist, how about the parent directory ?
   %
   [fpath,fname,fext] = fileparts(pls_dir);

   if ( exist(fpath,'dir') == 7 ) 	   % parent directory exists
      dlg_title = 'PLS Directory';
      msg = 'The directory does not exist.  Do you want to create it?';
      response = questdlg(msg,dlg_title,'Yes','No','Yes');

      switch response,
         case 'Yes',
            status = mkdir(fpath,[fname fext]);
            if (status ~= 1)
              msg = sprintf('ERROR: Directory cannot be created');
              set(findobj(gcf,'Tag','MessageLine'),'String',msg);
            end;
	    cd (fpath);
         case 'No',
            set(gcbo,'String','');
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
   end;

   return;						% SelectPLSDataDir


%----------------------------------------------------------------------------
function EditConditions()

   condition0 = getappdata(gcf,'SessionConditions0');
   condition_baseline0 = getappdata(gcf,'SessionConditionBaseline0');
   num_conditions0 = getappdata(gcf,'SessionNumConditions0');

   run_info = getappdata(gcf,'SessionRunInfo');


   % determine which conditions that cannot be removed as onsets are defined
   % for some of the runs
   %
   used_conditions = zeros(1,num_conditions0);
   for i=1:length(run_info),
         cond_idx = find(used_conditions == 0);
         for j=1:length(cond_idx),
            if ~isempty(run_info(i).evt_onsets{cond_idx(j)}),
               used_conditions(cond_idx(j)) = 1;
            end;
         end;
   end;
   protected_cond = []; % find(used_conditions == 1);

   % edit the names of the conditions 
   %
   [new_condition0,new_condition_baseline0,removed_condition_idx] = ...
        fmri_input_condition_ui(condition0,condition_baseline0,protected_cond);

   % remove the deleted conditions from the runs
   %
   keep_conditions = ones(1,num_conditions0);
   keep_conditions(removed_condition_idx) = 0;
   cond_idx = find(keep_conditions == 1);

   for i=1:length(run_info),
      new_onsets = cell(1,length(new_condition0));
      new_onsets(1:length(cond_idx)) = run_info(i).evt_onsets(cond_idx);  
      run_info(i).evt_onsets = new_onsets;
   end;

   num_conds = length(new_condition0);

   if (num_conds <= 0),
     set(findobj(gcf,'Tag','MergeConditionsMenu'),'Enable','off');
   else
     set(findobj(gcf,'Tag','MergeConditionsMenu'),'Enable','on');
   end;

   set(findobj(gcf,'Tag','NumberConditionsEdit'),'String',num2str(num_conds));
   setappdata(gcf,'SessionConditions0',new_condition0);
   setappdata(gcf,'SessionConditionBaseline0',new_condition_baseline0);
   setappdata(gcf,'SessionNumConditions0',length(new_condition0));
   setappdata(gcf,'SessionRunInfo',run_info);

   return;						% EditConditions


%----------------------------------------------------------------------------
function MergeConditions()

   condition = getappdata(gcf,'SessionConditions0');
   cond_baseline = getappdata(gcf,'SessionConditionBaseline0');
   num_conditions = getappdata(gcf,'SessionNumConditions0');

   run_info = getappdata(gcf,'SessionRunInfo');

   merged_conds = fmri_merge_condition_ui(condition);

   if isempty(merged_conds) 			% cancel merging 
      return;
   end;

   %  update the condition names
   %
   num_new_conditions = length(merged_conds);
   unmatch_cond = [];			% conditions that cond_baseline can not match
   for i=1:num_new_conditions,
      new_condition{i} = merged_conds(i).name;
      idx = merged_conds(i).cond_idx;
      new_cond_baseline{i} = cond_baseline{idx(1)};

      %  compare the cond_baseline consistency for merged_cond
      if length(merged_conds(i).cond_idx) > 1
         same_baseline = 1;
         for j = 2:length(idx)
            if ~isequal(cond_baseline{idx(1)}, cond_baseline{idx(j)})
               same_baseline = 0;
            end
         end
         if ~same_baseline
            unmatch_cond = [unmatch_cond, ' ', new_condition{i}];
            new_cond_baseline{i} = [0 1];
         end
      end
   end;

   if ~isempty(unmatch_cond)
%      msg = ['WARNING: The [ref_scan_onset,num_ref_scan] in condition', unmatch_cond];
      msg = ['WARNING: The [ref_scan_onset,num_ref_scan] in some new conditions'];
      msg = [msg, ' has been reset to [0,1].'];
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   end

   %  update the onsets for the new conition
   %
   for i=1:length(run_info),
      old_onsets = run_info(i).evt_onsets;

      new_onsets = cell(1,num_new_conditions);

      for j=1:num_new_conditions,
         c_idx = merged_conds(j).cond_idx;

         merge_onsets = [];
         for k=c_idx
            merge_onsets = [merge_onsets; old_onsets{k}];
         end

         new_onsets{j} = sort(merge_onsets);
      end;
      run_info(i).evt_onsets = new_onsets;
   end;

   h = findobj(gcf,'Tag','NumberConditionsEdit');
   set(h,'String',num2str(num_new_conditions));

   setappdata(gcf,'SessionConditions0',new_condition);
   setappdata(gcf,'SessionNumConditions0',num_new_conditions);
   setappdata(gcf,'SessionConditionBaseline0',new_cond_baseline);
   setappdata(gcf,'SessionRunInfo',run_info);

   return;						% MergeConditions


%----------------------------------------------------------------------------
function EditRunNumber()

   num_runs = str2num(get(gcbo,'String'));

   if isempty(num_runs) | (num_runs <= 0) 
      set(gcbo,'String','');
      h = findobj(gcf,'Tag','NumberRunsButton');
      set(h,'Enable','off');
      return;
   end;

   h = findobj(gcf,'Tag','NumberRunsButton');
   set(h,'Enable','on');
   setappdata(gcf,'SessionNumRuns',num_runs);

   return;						% EditRunNumber


%----------------------------------------------------------------------------
function EditRuns()

   if (getappdata(gcf,'SessionNumConditions0') <= 0);
      msg = 'ERROR: Cannot edit run information without defining the conditions first';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   run_info = getappdata(gcf,'SessionRunInfo');
   num_runs = getappdata(gcf,'SessionNumRuns');
   conditions0 = getappdata(gcf,'SessionConditions0');

   [new_run_info,new_num_runs] = fmri_input_run_ui(run_info,num_runs,conditions0);

   if ~isempty(new_run_info),
      setappdata(gcf,'SessionRunInfo',new_run_info);

      h = findobj(gcf,'Tag','NumberRunsEdit'); 
      set(h,'String',num2str(new_num_runs));
      setappdata(gcf,'SessionNumRuns',new_num_runs);
   end;
   
   return;						% EditRuns


%----------------------------------------------------------------------------
function EditDatamatPrefix

   datamat_prefix = deblank(strjust(get(gcbo,'String'),'left')); 
   set(gcbo,'String',datamat_prefix);

   if ~isempty(findstr(datamat_prefix,' '));
      msg = sprintf('ERROR: Datamat prefix cannot contain any space');
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   setappdata(gcf,'SessionDatamatPrefix',datamat_prefix);

   return;						% EditDatamatPrefix


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
function SetSessionInfo(session_info,session_file)

   setappdata(gcf,'SessionDescription',session_info.description);
   setappdata(gcf,'SessionDatamatPrefix',session_info.datamat_prefix);
   setappdata(gcf,'SessionPLSDir',session_info.pls_data_path);
   setappdata(gcf,'SessionNumConditions',session_info.num_conditions);
   setappdata(gcf,'SessionConditions',session_info.condition);
   setappdata(gcf,'SessionNumRuns',session_info.num_runs);
   setappdata(gcf,'SessionRunInfo',session_info.run);

   if ~isfield(session_info,'across_run')
      session_info.across_run = 1;
   end

   setappdata(gcf,'SessionAcrossRun',session_info.across_run);

   if ~isfield(session_info,'condition_baseline')
      session_info.condition_baseline = {};
      for i=1:session_info.num_conditions
         session_info.condition_baseline=[session_info.condition_baseline, ...
                                                {[0 1]}];
      end
   end

   setappdata(gcf,'SessionConditionBaseline',session_info.condition_baseline);

   if ~isfield(session_info,'num_conditions0')
      session_info.num_conditions0 = session_info.num_conditions;
   end

   setappdata(gcf,'SessionNumConditions0',session_info.num_conditions0);

   if ~isfield(session_info,'condition0')
      session_info.condition0 = session_info.condition;
   end

   setappdata(gcf,'SessionConditions0',session_info.condition0);

   if ~isfield(session_info,'condition_baseline0')
      session_info.condition_baseline0 = session_info.condition_baseline;
   end

   setappdata(gcf,'SessionConditionBaseline0',session_info.condition_baseline0);

   if ~isfield(session_info,'behavname_all')
      session_info.behavname_all = {};
      session_info.behavdata_all = [];
   end
   setappdata(gcf,'SessionBehavNameAll',session_info.behavname_all);
   setappdata(gcf,'SessionBehavDataAll',session_info.behavdata_all);

   if ~isfield(session_info,'behavname_each')
      session_info.behavname_each = {};
      session_info.behavdata_each = [];
   end
   setappdata(gcf,'SessionBehavNameEach',session_info.behavname_each);
   setappdata(gcf,'SessionBehavDataEach',session_info.behavdata_each);

   if ~isfield(session_info,'behavname_all_single')
      session_info.behavname_all_single = {};
      session_info.behavdata_all_single = [];
   end
   setappdata(gcf,'SessionBehavNameAllSingle',session_info.behavname_all_single);
   setappdata(gcf,'SessionBehavDataAllSingle',session_info.behavdata_all_single);

   if ~isfield(session_info,'behavname_each_single')
      session_info.behavname_each_single = {};
      session_info.behavdata_each_single = [];
   end
   setappdata(gcf,'SessionBehavNameEachSingle',session_info.behavname_each_single);
   setappdata(gcf,'SessionBehavDataEachSingle',session_info.behavdata_each_single);

   setappdata(gcf,'OldSessionInfo',session_info);
   setappdata(gcf,'SessionFile',session_file);

   if isempty(session_file)
      set(gcf,'Name','New Event Related fMRI Session Information');
   else
      [pathname, filename] = rri_fileparts(session_file);
      set(gcf,'Name',['Session File: ' filename]);
   end;

   return;						% SetSessionInfo


%----------------------------------------------------------------------------
function [session_info,session_file,old_session_info] = GetSessionInfo(),

   session_info.description = getappdata(gcf,'SessionDescription');
   session_info.pls_data_path = getappdata(gcf,'SessionPLSDir');
   session_info.datamat_prefix = getappdata(gcf,'SessionDatamatPrefix');
   session_info.num_conditions = getappdata(gcf,'SessionNumConditions');
   session_info.condition = getappdata(gcf,'SessionConditions');
   session_info.condition_baseline = getappdata(gcf,'SessionConditionBaseline');
   session_info.num_conditions0 = getappdata(gcf,'SessionNumConditions0');
   session_info.condition0 = getappdata(gcf,'SessionConditions0');
   session_info.condition_baseline0 = getappdata(gcf,'SessionConditionBaseline0');
   session_info.num_runs = getappdata(gcf,'SessionNumRuns');
   session_info.run = getappdata(gcf,'SessionRunInfo');
   session_info.across_run = getappdata(gcf,'SessionAcrossRun');
   session_info.behavname_all = getappdata(gcf,'SessionBehavNameAll');
   session_info.behavdata_all = getappdata(gcf,'SessionBehavDataAll');
   session_info.behavname_each = getappdata(gcf,'SessionBehavNameEach');
   session_info.behavdata_each = getappdata(gcf,'SessionBehavDataEach');
   session_info.behavname_all_single = getappdata(gcf,'SessionBehavNameAllSingle');
   session_info.behavdata_all_single = getappdata(gcf,'SessionBehavDataAllSingle');
   session_info.behavname_each_single = getappdata(gcf,'SessionBehavNameEachSingle');
   session_info.behavdata_each_single = getappdata(gcf,'SessionBehavDataEachSingle');

   session_file = getappdata(gcf,'SessionFile');
   old_session_info = getappdata(gcf,'OldSessionInfo');

   return;						% GetSessionInfo


%----------------------------------------------------------------------------
function CreateSTDatamat(),

   %  make sure the session information has been saved
   %
   [session_info,session_file,old_session_info] = GetSessionInfo;


status = SaveSessionInfo;
session_info = getappdata(gcf, 'session_info');
%if (status ~= 0),  pet_create_datamat_ui({session_info});  end;

  if (status ~= 0)
   num_runs = getappdata(gcf,'SessionNumRuns');
   data_path = session_info.run(1).data_path;
   img_file = session_info.run(1).data_files{1};
   try
      dims = rri_imginfo(fullfile(data_path,img_file));
      num_slices = dims(3); 
   catch
      msg = sprintf('ERROR: Cannot access the image file: %s',img_file);
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;
   fmri_create_datamat_ui(session_info,num_runs,num_slices);
  end;

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
          msg1 = 'ERROR: Please save the session information';
          msg =  [msg1 ' before creating the datamat.'];

          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
       end
   end;

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

      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   if ~session_info.across_run & any_empty_cond_within_run
      msg = 'ERROR: There is a condition without onset while merging data within each run';

      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   num_runs = getappdata(gcf,'SessionNumRuns');

   data_path = session_info.run(1).data_path;
   img_file = session_info.run(1).data_files{1};
   try
      dims = rri_imginfo(fullfile(data_path,img_file));
      num_slices = dims(3); 
   catch
      msg = sprintf('ERROR: Cannot access the image file: %s',img_file);
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   fmri_create_datamat_ui(session_file,num_runs,num_slices);

   return;						% CreateSTDatamat


%------------------------------------------------------------------------------
function ModifyBehav

   session_file = getappdata(gcbf,'SessionFile');

   if isempty(session_file)
      return;
   end

   load(session_file);

   repeat = 1;

   while repeat
      [new_behavdata, new_behavname] = ...
         rri_edit_behav(num2str(behavdata),behavname,'Edit Behavior Data');

      if isempty(new_behavname) | isempty(new_behavdata)
         return;
      elseif size(st_datamat,1) == size(str2num(new_behavdata),1)
         repeat = 0;
      else
         msg = ['Number of rows should be equal to ' num2str(size(st_datamat,1))];
         uiwait(msgbox(msg, 'Error'));
         repeat = 1;
      end
   end

   if isequal(new_behavname, behavname) & isequal(str2num(new_behavdata), behavdata)
      return;
   end

   if ~exist('create_ver','var')
      create_ver = plsgui_vernum;
   end

   behavdata = str2num(new_behavdata);
   behavname = new_behavname;

   save(session_file,'behavdata','behavname','create_ver', ...
	'normalize_volume_mean','st_coords','st_datamat','st_dims', ...
	'st_evt_list','st_origin','st_sessionFile','st_voxel_size', ...
	'st_win_size','session_info');

   msg = 'Datamat has been modified with new behavior data';
   uiwait(msgbox(msg, 'Error'));

   return;						% ModifyBehav


%------------------------------------------------------------------------------
function delete_fig()
    if (CloseSessionInput == 1);
        uiresume
    end

    return


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
   setappdata(gcf,'SessionRunInfo',session_info.run);

   return;						% PathSessionInfo


%----------------------------------------------------------------------------
function SelectMergeDataWithinRun()

if get(findobj(gcf,'Tag','MergeDataWithinRunButton'),'Value') == 0		% click itself
   set(findobj(gcf,'Tag','MergeDataWithinRunButton'),'Value',1);
else
   set(findobj(gcf,'Tag','MergeDataAcrossRunsButton'),'Value',0);
   setappdata(gcf,'SessionAcrossRun',0);
end

   return;					% SelectMergeDataWithinRun


%----------------------------------------------------------------------------
function SelectMergeDataAcrossRuns()

if get(findobj(gcf,'Tag','MergeDataAcrossRunsButton'),'Value') == 0		% click itself
   set(findobj(gcf,'Tag','MergeDataAcrossRunsButton'),'Value',1);
else
   set(findobj(gcf,'Tag','MergeDataWithinRunButton'),'Value',0);
   setappdata(gcf,'SessionAcrossRun',1);
end

   return;					% SelectMergeDataAcrossRuns

