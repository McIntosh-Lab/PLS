%PET_SESSION_PROFILE_UI Form to input the group info, including session name,
%		working directory, subjects directories, conditions names etc.
%
%   Usage: pet_session_profile_ui
%
%   See also PLS_SESSION_PROFILE_UI
%

%   Called by plsgui
%
%   I - the action word to call itself recursively. If none, initialize session window.
%   O - none
%
%   Modified on 12-SEP-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pet_session_profile_ui(varargin)

   if nargin == 0,

      if exist('plslog.m','file')
         plslog('Edit PET Session');
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
   elseif strcmp(action,'MENU_CREATE_DATAMAT'),
      CreateDatamat;
   elseif strcmp(action,'MENU_MODIFY_BEHAV'),
      ModifyBehav;
   elseif strcmp(action,'EDIT_DESCRIPTION'),
      description = deblank(strjust(get(gcbo,'String'),'left'));
      set(gcbo,'String',description);
      setappdata(gcf,'SessionDescription',description);
   elseif strcmp(action,'EDIT_PLS_DATA_DIR'),
      EditPLSDataDir;
   elseif strcmp(action,'SELECT_PLS_DATA_DIR'),
      SelectPLSDataDir;
   elseif strcmp(action,'EDIT_BEHAV_DATA_FILE'),
      is_dir_empty = isempty(getappdata(gcf,'SessionPLSDir'));
      if is_dir_empty
         msg = 'A working directory needs to be specified before inputting conditions.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      EditBehavDataFile;
   elseif strcmp(action,'SELECT_BEHAV_DATA_FILE'),
      is_dir_empty = isempty(getappdata(gcf,'SessionPLSDir'));
      if is_dir_empty
         msg = 'A working directory needs to be specified before inputting conditions.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      SelectBehavDataFile;
   elseif strcmp(action,'EDIT_DATAMAT_PREFIX'),
      prefix_name = deblank(strjust(get(gcbo,'String'),'left'));
      setappdata(gcf,'SessionDatamatPrefix',prefix_name);
   elseif strcmp(action,'EDIT_CONDITIONS_NUM'),
      msg = 'Click the "Input Conditions ..." button to set the condition names';
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
      msg = 'Click the "Select Subjects ..." button to set the subject directory';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_SUBJECTS'),
      is_cond_empty = ...
         strcmp(get(findobj(gcf,'Tag','NumberConditionsEdit'),'String'),'0');
      if is_cond_empty
         msg = 'Conditions need to be selected before selecting object.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      EditSubjects;
   elseif strcmp(action,'RESIZE_FIGURE'),
      ResizeFigure;
   elseif strcmp(action,'DELETE_FIG'),
       delete_fig;
   elseif strcmp(action,'DELETE_FIGURE'),
       delete_figure;
   elseif strcmp(action,'EDIT_NUM_BEHAVIOR'),
      msg = 'Click the "Edit Behavior Data ..." button to edit behavior data';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_BEHAV_DATA'),
      is_dir_empty = isempty(getappdata(gcf,'SessionPLSDir'));
      if is_dir_empty
         msg = 'A working directory needs to be specified before inputting conditions.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      behavdata = getappdata(gcf,'SessionBehavData');
      behavname = getappdata(gcf,'SessionBehavName');
      [behavdata, behavname] = rri_edit_behav(num2str(behavdata), behavname, 'Edit Behavior Data');
      setappdata(gcf,'SessionBehavData',str2num(behavdata));
      setappdata(gcf,'SessionBehavName',behavname);
      setappdata(gcf,'SessionNumBehavior',size(str2num(behavdata), 1));
      set(findobj(gcf,'Tag','NumberBehaviorEdit'),'String',size(str2num(behavdata),1));
   end;

   return;


%----------------------------------------------------------------------------
function init

   save_setting_status = 'on';
   pet_session_profile_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(pet_session_profile_pos) & strcmp(save_setting_status,'on')

      pos = pet_session_profile_pos;

   else

      w = 0.65;
      h = 0.4;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','New PET Session Information', ...
        'NumberTitle','off', ...
        'Menubar', 'none', ...
   	'Position', pos, ...
        'DeleteFcn','pet_session_profile_ui(''DELETE_FIGURE'');', ...
	'Tag','EditSessionInformation', ...
   	'ToolBar','none');

   % numbers of inputing line excluding 'MessageLine'

   num_inputline = 4;
   factor_inputline = 1/(num_inputline+1);

   % left label

   x = 0.05;
   y = (num_inputline-0) * factor_inputline;
   w = 0.25;
   h = 0.5 * factor_inputline;

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
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Session Description Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Callback','pet_session_profile_ui(''EDIT_DESCRIPTION'');', ...
   	'Tag','SessionDescriptionEdit');

   x = 0.05;
   y = (num_inputline-1) * factor_inputline;
   w = 0.25;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% PLS Data Directory Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Working Directory: ', ...
	'visible','off', ...
   	'Tag','PLSDataDirectoryLabel');

   x = x+w+0.01;
   w = 0.43;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% PLS Data Directory Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','                  *  REQUIRED FIELD', ...
   	'Callback','pet_session_profile_ui(''EDIT_PLS_DATA_DIR'');', ...
	'visible','off', ...
   	'Tag','PLSDataDirectoryEdit');

   x = x+w+0.01;
   w = 0.15;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% PLS Data Directory Button
   	'Style','pushbutton', ...
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
        'Position',pos, ...
        'String','Browse ...', ...
        'Enable','On', ...
   	'Callback','pet_session_profile_ui(''SELECT_PLS_DATA_DIR'');', ...
	'visible','off', ...
   	'Tag','PLSDataDirectoryButton');

   x = 0.05;
   y = (num_inputline-1) * factor_inputline;
   w = 0.25;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Datamat Prefix Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Datamat Prefix: ', ...
   	'Tag','DatamatPrefixLabel');

   x = x+w+0.01;
   w = 0.3;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Datamat Prefix Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Callback','pet_session_profile_ui(''EDIT_DATAMAT_PREFIX'');', ...
   	'Tag','DatamatPrefixEdit');

   x = 0.05;
   y = (num_inputline-2) * factor_inputline;
   w = 0.25;
   h = 0.5 * factor_inputline;

   pos = [x y w h];






   c = uicontrol('Parent',h0, ...		% Behav Data Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','Behavior Data:', ...
	'enable', 'on', ...
	'visible', 'off', ...
   	'Tag','BehavDataLabel');

   x = x+w+0.01;
   w = 0.07;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Behavior Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
   	'ButtonDownFcn','erp_session_profile_ui(''EDIT_NUM_BEHAVIOR'');', ...
	'enable', 'inactive', ...
	'visible', 'off', ...
   	'Tag','NumberBehaviorEdit');

   x = x+w+0.01;
   w = 0.22;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Behav Data Edit
   	'Units','normal', ...
	'string', 'Edit Behavior Data...', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','erp_session_profile_ui(''EDIT_BEHAV_DATA'');', ...
	'enable', 'on', ...
	'visible', 'off', ...
   	'Tag','BehavDataEdit');




if(0)
   x = 0.05;
   y = (num_inputline-2) * factor_inputline;
   w = 0.25;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Behav Data File Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','Behavior Data File: ', ...
	'enable', 'on', ...
   	'Tag','BehavDataFileLabel');

   x = x+w+0.01;
   w = 0.43;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Behav Data File Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Callback','pet_session_profile_ui(''EDIT_BEHAV_DATA_FILE'');', ...
   	'Tag','BehavDataFileEdit');

   x = x+w+0.01;
   w = 0.15;
   h = 0.4 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Behav Data File Button
   	'Style','pushbutton', ...
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
        'Position',pos, ...
        'String','Browse ...', ...
        'Enable','On', ...
   	'Callback','pet_session_profile_ui(''SELECT_BEHAV_DATA_FILE'');', ...
	'enable', 'on', ...
   	'Tag','BehavDataFileButton');
end

   x = 0.05;
   y = (num_inputline-2) * factor_inputline;
   w = 0.25;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Conditions Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Number of Conditions: ', ...
   	'Tag','NumberConditionsLabel');

   x = x+w+0.01;
   w = 0.07;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Conditions Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
        'Enable','Inactive', ...
   	'ButtonDownFcn','pet_session_profile_ui(''EDIT_CONDITIONS_NUM'');', ...
   	'Tag','NumberConditionsEdit');

   x = x+w+0.01;
   w = 0.22;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Conditions Button
   	'Style','pushbutton', ...
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
        'Position',pos, ...
        'String','Input Conditions ...', ...
        'Enable','On', ...
   	'Callback','pet_session_profile_ui(''EDIT_CONDITIONS'');', ...
   	'Tag','NumberConditionsButton');

   x = x+w+0.04;
   w = 0.25;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Create Datamat
   	'Style','pushbutton', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','Create Datamat ...', ...
   	'Callback','pet_session_profile_ui(''MENU_CREATE_DATAMAT'');', ...
   	'Tag','CreateDatamatButton');

   x = 0.05;
   y = (num_inputline-3) * factor_inputline;
   w = 0.25;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Subjects Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','*  Number of Subjects: ', ...
   	'Tag','NumberSubjectsLabel');

   x = x+w+0.01;
   w = 0.07;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Subjects Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
        'Enable','Inactive', ...
   	'ButtonDownFcn','pet_session_profile_ui(''EDIT_NUM_SUBJECTS'');', ...
   	'Tag','NumberSubjectsEdit');

   x = x+w+0.01;
   w = 0.22;
   h = 0.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Subjects Button
   	'Style','pushbutton', ...
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
        'Position',pos, ...
        'String','Select Subjects ...', ...
        'Enable','On', ...
   	'Callback','pet_session_profile_ui(''EDIT_SUBJECTS'');', ...
   	'Tag','NumberSubjectsButton');

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
   	'Callback','pet_session_profile_ui(''DELETE_FIG'');', ...
   	'Tag','CloseButton');

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
   	'Callback','pet_session_profile_ui(''MENU_LOAD_PLS_SESSION_INFO'');', ...
        'Tag', 'LoadPLSsession');
   m1 = uimenu(h_file, ...
        'Label', '&Create Datamat File ...', ...
   	'Callback','pet_session_profile_ui(''MENU_CREATE_DATAMAT'');', ...
        'Tag', 'CreateDatamatMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Save', ...
   	'Callback','pet_session_profile_ui(''MENU_SAVE_PLS_SESSION_INFO'');', ...
	'visible', 'off', ...
        'Tag', 'SavePLSsession');
   m1 = uimenu(h_file, ...
        'Label', 'S&ave as', ...
   	'Callback','pet_session_profile_ui(''MENU_SAVE_AS_PLS_SESSION_INFO'');', ...
	'visible', 'off', ...
        'Tag', 'SaveAsPLSsession');
   m1 = uimenu(h_file, ...
        'Label', '&Close', ...
   	'Callback','pet_session_profile_ui(''MENU_CLOSE_SESSION_INPUT'');', ...
        'Tag', 'CloseSsessionInput');

   h_file = uimenu('Parent',h0, ...
	'Label', '&Edit', ...
	'Tag', 'EditMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Change Data Paths', ...
   	'Callback','pet_session_profile_ui(''MENU_PATH_PLS_SESSION_INFO'');', ...
	'Enable','off', ...
        'Tag', 'PathPLSsessionMenu');
   m1 = uimenu(h_file, ...
	'separator', 'on', ...
        'Label', '&Clear Session', ...
   	'Callback','pet_session_profile_ui(''MENU_CLEAR_PLS_SESSION_INFO'');', ...
        'Tag', 'ClearPLSsessionMenu');

   h_file = uimenu('Parent',h0, ...
	'Label', '&Datamat', ...
	'visible', 'off', ...
	'Tag', 'DatamatMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Create Datamat File ...', ...
   	'Callback','pet_session_profile_ui(''MENU_CREATE_DATAMAT'');', ...
        'Tag', 'CreateDatamatMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Input Seed PLS Behav Data and Modify Datamat', ...
   	'Callback','pet_session_profile_ui(''MENU_MODIFY_BEHAV'');', ...
        'Enable','off', ...
	'visible', 'off', ...
        'Tag', 'ModifyBehavMenu');

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
           'Tag', 'Help');

%           'Callback','rri_helpfile_ui(''pet_session_profile_hlp.txt'',''How to use SESSION PROFILE'');', ...
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','web([''file:///'', which(''UserGuide.htm''), ''#_Toc128820714'']);', ...
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

   ClearSessionInfo(1);


   session_lst = dir('*_PETsession.mat');
   sessiondata_lst = dir('*_PETsessiondata.mat');

   if ~isempty(session_lst) & isempty(sessiondata_lst)
      msg = 'PLS now combines session/datamat files to sessiondata ';
      msg = [msg 'file. You must use commmand session2sessiondata '];
      msg = [msg 'to convert session/datamat into sessiondata. For '];
      msg = [msg 'more detail, please type: help session2sessiondata'];
      uiwait(msgbox(msg,'Error','modal'));
   end


   return;						% init


%----------------------------------------------------------------------------
function delete_fig()
    if (CloseSessionInput == 1);
        uiresume
    end

    return


%----------------------------------------------------------------------------
function delete_figure()

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       pet_session_profile_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'pet_session_profile_pos');
    catch
    end

    calling_fig = getappdata(gcf,'CallingFigure');
    set(calling_fig,'visible','on');

    return


%----------------------------------------------------------------------------
function ClearSessionInfo(init_flag)
%  init_flag = 0  for clear operation
%  init_flag = 1  for initialization
%

   if (init_flag == 0 & ChkModified == 0)
   end;

   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   session_info.description = '';
   session_info.pls_data_path = curr;
%   session_info.behav_data_file = '';
   session_info.num_behavior = 0;
   session_info.behavdata = [];
   session_info.behavname = {};
   session_info.datamat_prefix = '';
   session_info.num_conditions = 0;
   session_info.condition = {};
   session_info.num_subjects = 0;
   session_info.subject = {};
   session_info.subj_name = {};
   session_info.subj_files = {};
   session_info.img_ext = '*.img';
   session_info.num_subj_init = -1;
   setappdata(gcf,'reselect_subj', 0);

   SetSessionInfo(session_info,'')
   set(findobj(gcf,'Tag','ModifyBehavMenu'),'enable','off');
   set(findobj(gcf,'Tag','PathPLSsessionMenu'),'enable','off');

   return;						% ClearSessionInfo


%----------------------------------------------------------------------------
function LoadSessionInfo()

   if ~isempty(getappdata(gcf,'OldSessionInfo'))
      if (ChkModified == 0)
      end;
   end;
   [filename, pathname] = rri_selectfile( '*_PETsessiondata.mat', 'Load a PLS session file');

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

   if ~exist(pls_session.session_info.pls_data_path,'dir') | ~exist(pls_session.session_info.subject{1},'dir')
      msg = 'Invalid path inside. Click Edit menu to Change Data Paths';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   end

try
 tmp = pls_session.session_info.subj_files;
catch
 msgbox('The version of this program has been changed, you have to create your session file, and run analysis again. Sorry for the inconvenience. -Jan.8,2003');
 return;
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

%   if isempty(session_info.behav_data_file),
%      msg = sprintf('A Behavior Data file needs to be specified before saving.');
%      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
%      return;
%   end;

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
%
%       Display sessioninfo, called AFTER load session & clear session
%
%----------------------------------------------------------------------------
function ShowSessionInfo()

   h = findobj(gcf,'Tag','SessionDescriptionEdit'); 
   set(h,'String',getappdata(gcf,'SessionDescription'));

   h = findobj(gcf,'Tag','PLSDataDirectoryEdit');
   set(h,'String',getappdata(gcf,'SessionPLSDir'));

%   h = findobj(gcf,'Tag','BehavDataFileEdit');
%   set(h,'String',getappdata(gcf,'SessionBehavDataFile'));

   num_behavior = getappdata(gcf,'SessionNumBehavior');
   h = findobj(gcf,'Tag','NumberBehaviorEdit'); 
   set(h,'String',num_behavior);

   datamat_prefix = getappdata(gcf,'SessionDatamatPrefix');
   [fpath fname] = fileparts(datamat_prefix);
   h = findobj(gcf,'Tag','DatamatPrefixEdit'); 
   set(h,'String',fname);

   num_subjects = getappdata(gcf,'SessionNumSubjects');
   h = findobj(gcf,'Tag','NumberSubjectsEdit'); 
   set(h,'String',num_subjects);

   num_conds = getappdata(gcf,'SessionNumConditions');
   h = findobj(gcf,'Tag','NumberConditionsEdit'); 
   set(h,'String',num_conds);

   return;						% ShowSessionInfo


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
function EditBehavDataFile

   behav_data_file = deblank(strjust(get(gcbo,'String'),'left')); 

   set(gcbo,'String',behav_data_file);

   if ~isempty(behav_data_file)
      if ( exist(behav_data_file,'file') == 2 )		% specified file exists
         setappdata(gcf,'SessionBehavDataFile',behav_data_file);
         return;
      elseif ( exist(behav_data_file,'dir') == 7 )		% it is a directory!
         msg = 'ERROR: The specified behav file is a direcotry!';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         setappdata(gcf,'SessionBehavDataFile','');
         return;
      else
         msg = 'ERROR: The specified behav file does not exist!';
         uiwait(msgbox(msg,'Error','modal'));
         return;
      end;
   else
%      msg = 'ERROR: Invalid input file!';
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'SessionBehavDataFile','');
      return;
   end;

   return;						% EditBehavDataFile


%----------------------------------------------------------------------------
function SelectBehavDataFile

   h = findobj(gcf,'Tag','BehavDataFileEdit');

   [filename,pathname]=rri_selectfile('*.*','Select Behavior Data File');
        
   if isequal(filename,0) | isequal(pathname,0)
      return;
   end;
   
   behav_data_file = [pathname, filename];

   set(h,'String',behav_data_file); 
   set(h,'TooltipString',behav_data_file); 
   setappdata(gcf,'SessionBehavDataFile',behav_data_file);

   return;						% SelectBehavDataFile


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
   img_ext = getappdata(gcf,'img_ext');
   condition = getappdata(gcf,'SessionConditions');
   selected_conditions = ones(1,length(condition));

   % edit the names of subjects
   %
   [subjects, subj_files, num_subj_init, img_ext] = ...
	rri_input_subject_ui(old_subjects, old_subj_files, ...
	condition, selected_conditions, num_subj_init, img_ext);

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
   setappdata(gcf,'img_ext', img_ext);
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
%
%       set session field. called by load session & clear session
%
%----------------------------------------------------------------------------
function SetSessionInfo(session_info,session_file)

   setappdata(gcf,'SessionDescription',session_info.description);
   setappdata(gcf,'SessionPLSDir',session_info.pls_data_path);
%   setappdata(gcf,'SessionBehavDataFile',session_info.behav_data_file);

   if ~isfield(session_info,'behavdata')
      session_info.num_behavior = 0;
   end
   setappdata(gcf,'SessionNumBehavior',session_info.num_behavior);

   if ~isfield(session_info,'behavdata')
      session_info.behavdata = [];
   end
   setappdata(gcf,'SessionBehavData',session_info.behavdata);

   if ~isfield(session_info,'behavname')
      session_info.behavname = {};
   end
   setappdata(gcf,'SessionBehavName',session_info.behavname);

   setappdata(gcf,'SessionDatamatPrefix',session_info.datamat_prefix);
   setappdata(gcf,'SessionNumConditions',session_info.num_conditions);
   setappdata(gcf,'SessionConditions',session_info.condition);
   setappdata(gcf,'SessionNumSubjects',session_info.num_subjects);
   setappdata(gcf,'SessionSubject',session_info.subject);
   setappdata(gcf,'subj_name',session_info.subj_name);
   setappdata(gcf,'subj_files',session_info.subj_files);

   if ~isfield(session_info,'img_ext')
      if isempty(session_file)
         session_info.img_ext = '*.img';
      else
         [p f e] = fileparts(session_info.subj_files{1});
         session_info.img_ext = ['*' e];
      end
   end

   setappdata(gcf,'img_ext',session_info.img_ext);

   if ~isfield(session_info,'num_subj_init')
      session_info.num_subj_init = -1;
   end

   setappdata(gcf,'num_subj_init',session_info.num_subj_init);

   setappdata(gcf,'OldSessionInfo',session_info);
   setappdata(gcf,'SessionFile',session_file);

   if isempty(session_file)
      set(gcf,'Name','New PET Session Information');
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
%   session_info.behav_data_file = getappdata(gcf,'SessionBehavDataFile');

   session_info.num_behavior = getappdata(gcf,'SessionNumBehavior');
   session_info.behavdata = getappdata(gcf,'SessionBehavData');
   session_info.behavname = getappdata(gcf,'SessionBehavName');

   session_info.datamat_prefix = getappdata(gcf,'SessionDatamatPrefix');
   session_info.num_conditions = getappdata(gcf,'SessionNumConditions');
   session_info.condition = getappdata(gcf,'SessionConditions');
   session_info.num_subjects = getappdata(gcf,'SessionNumSubjects');
   session_info.subject = getappdata(gcf,'SessionSubject');
   session_info.subj_name = getappdata(gcf,'subj_name');
   session_info.subj_files = getappdata(gcf,'subj_files');
   session_info.img_ext = getappdata(gcf,'img_ext');
   session_info.num_subj_init = getappdata(gcf,'num_subj_init');

   session_file = getappdata(gcf,'SessionFile');
   old_session_info = getappdata(gcf,'OldSessionInfo');

   return;						% GetSessionInfo


%----------------------------------------------------------------------------
function CreateDatamat(),

   %  make sure the session information has been saved
   %
   [session_info,session_file,old_session_info] = GetSessionInfo;


status = SaveSessionInfo;
session_info = getappdata(gcf, 'session_info');
if (status ~= 0),  pet_create_datamat_ui({session_info});  end;
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

   pet_create_datamat_ui({session_file});

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

