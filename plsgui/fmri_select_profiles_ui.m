function [selected_profiles] = fmri_select_profiles_ui(varargin)
%
%  USAGE: [selected_profiles] = fmri_select_profiles_ui(dirname,selected_files)
%
%  Allow user to select a set of session profiles 
%
%  Example:
%
%    selected_profiles = fmri_select_profiles_ui('/home/wilkin/');
%
%
%  -- Created July 2001 by Wilkin Chau, Rotman Research Institute
%

   if nargin == 0 | ischar(varargin{1}) 	% create figure

      dir_name = '';
      tit_nam = get(gcbf,'name');

      if findstr('Block', tit_nam)
         filter_pattern = '*_BfMRIsessiondata.mat';
      else
         filter_pattern = '*_fMRIsessiondata.mat';
      end

      selected_files = [];

      if (nargin >= 1), dir_name = varargin{1};       end;
      if (nargin >= 2), selected_files = varargin{2}; end;

      init(dir_name,filter_pattern,selected_files);
      uiwait;                           % wait for user finish

      selected_profiles = getappdata(gcf,'SelectedProfiles');

      start_dir = getappdata(gcf,'StartDirectory');

      if ~isempty(start_dir)
         cd (start_dir);
      end

      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1}{1});

   if strcmp(action,'CREATE_EDIT_FILTER'),
      filter_pattern = getappdata(gcf,'FilterPattern');
      dir_name = pwd;
      if isempty(dir_name),
         dir_name = filesep;
      end;

      set(gcbo,'String',fullfile(dir_name, filter_pattern));
   elseif strcmp(action,'UPDATE_DIRECTORY_LIST'),
      UpdateDirectoryList;
   elseif strcmp(action,'EDIT_FILTER'),
      EditFilter;
   elseif strcmp(action,'RESIZE_FIGURE'),
      SetObjectPositions;
   elseif strcmp(action,'ADD_SESSION_PROFILE'),
      AddSessionProfile;
   elseif strcmp(action,'REMOVE_SESSION_PROFILE'),
      RemoveSessionProfile;
   elseif strcmp(action,'MOVE_UP_PROFILE'),
      MoveUpSessionProfile;
   elseif strcmp(action,'MOVE_DOWN_PROFILE'),
      MoveDownSessionProfile;
   elseif strcmp(action,'TOGGLE_FULL_PATH'),
      SwitchFullPath;
   elseif strcmp(action,'DELETE_FIG')
      delete_fig;
   elseif strcmp(action,'LOAD_TXT')
      load_txt;
   elseif strcmp(action,'SAVE_TXT')
      save_txt;
   elseif strcmp(action,'DONE_BUTTON_PRESSED'),
      profiles = get(findobj(gcf,'Tag','SessionProfileList'),'Userdata');
      setappdata(gcf,'SelectedProfiles',profiles);
      uiresume;
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      setappdata(gcf,'SelectedProfiles',[]);
      uiresume;
   end;

   return;


% --------------------------------------------------------------------
function init(dir_name,filter_pattern,selected_files),

   StartDirectory = pwd;
   if isempty(StartDirectory),
       StartDirectory = filesep;
   end;

   save_setting_status = 'on';
   fmri_select_profiles_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_select_profiles_pos) & strcmp(save_setting_status,'on')

      pos = fmri_select_profiles_pos;

   else

      w = 0.7;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name','Select Session Profiles', ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Position',pos, ...
        'DeleteFcn','fmri_select_profiles_ui({''DELETE_FIG''});', ...
        'WindowStyle', 'normal', ...
        'Tag','GetFilesFigure', ...
        'ToolBar','none');

   left_margin = .05;
   text_height = .05;

   x = left_margin;
   y = .9;
   w = 1-2*left_margin;
   h = text_height;

   pos = [x y w h];

   fnt = 0.5;

   h1 = uicontrol('Parent',h0, ...            % Filter Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','Filter', ...
        'Tag','FilterLabel');

   y = y-h;

   pos = [x y w h];

   e_h = uicontrol('Parent',h0, ...            % Filter Edit
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String', '', ...
        'CreateFcn','fmri_select_profiles_ui({''CREATE_EDIT_FILTER''});', ...
        'Callback','fmri_select_profiles_ui({''EDIT_FILTER''});', ...
        'Tag','FilterEdit');

   y = y-2*h;
   w = .34;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % File/Directory Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Files:', ...
        'Tag','File/DirectoryLabel');

   x = left_margin+.44;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Session Profile Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Selected Session Profiles:', ...
        'Tag','SessionProfileLabel');

   h = y - 0.18;
   x = left_margin;
   y = 0.18;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % File/Directory Listbox
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',0.05, ...
        'BackgroundColor',[1 1 1], ...
        'HorizontalAlignment','left', ...
        'Interruptible', 'off', ...
 	'Min',1, ...
 	'Max',10, ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', '', ...
        'Callback','fmri_select_profiles_ui({''UPDATE_DIRECTORY_LIST''});', ...
        'Tag','File/DirectoryList');

   x = left_margin+.44;
   w = .34;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Session Profile Listbox
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',0.05, ...
        'BackgroundColor',[1 1 1], ...
        'HorizontalAlignment','left', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', '', ...
        'Tag','SessionProfileList');

   x = left_margin + .34 + .01;
   y = .5;
   w = .08;
   h = text_height;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% ">>" Button
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','>>', ...
        'Callback','fmri_select_profiles_ui({''ADD_SESSION_PROFILE''});', ...
        'Tag','>>Button');

   x = left_margin + .78 + .01;
   y = .65;
   w = 1-left_margin-x;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% UP Button
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','UP', ...
        'Callback','fmri_select_profiles_ui({''MOVE_UP_PROFILE''});', ...
        'Tag','UPButton');

   y = y - h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% DOWN Button
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','DOWN', ...
        'Callback','fmri_select_profiles_ui({''MOVE_DOWN_PROFILE''});', ...
        'Tag','DOWNButton');

   y = .3;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% REMOVE Button
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','REMOVE', ...
        'Callback','fmri_select_profiles_ui({''REMOVE_SESSION_PROFILE''});', ...
        'Tag','REMOVEButton');

   x = left_margin;
   y = .08;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % DONE
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','DONE', ...
        'Callback','fmri_select_profiles_ui({''DONE_BUTTON_PRESSED''});', ...
        'Tag','DONEButton');

   x = left_margin+.34-w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % CANCEL
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','CANCEL', ...
        'Callback','fmri_select_profiles_ui({''CANCEL_BUTTON_PRESSED''});', ...
        'Tag','CANCELButton');

   x = left_margin+.44;
   w = 1-left_margin-x;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% Full Path Checkbox
	'Style','checkbox', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
	'Value', 0, ...
        'Position',pos, ...
        'HorizontalAlignment','left', ...
        'String','Show full path for the selected profiles', ...
        'Callback','fmri_select_profiles_ui({''TOGGLE_FULL_PATH''});', ...
        'Tag','FullPathChkbox');

   x = .01;
   y = 0;
   w = 1;

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

      %--------------------------- menu ----------------------

      %  file
      %
      h_file = uimenu('parent',h0, ...
           'label','&File', ...
           'visible', 'on', ...
	   'tag','menu_file');
      h2 = uimenu('parent', h_file, ...
           'callback','fmri_select_profiles_ui({''LOAD_TXT''});', ...
           'label','&Load from a text file', ...
   	   'tag', 'menu_load');
      h2 = uimenu('parent', h_file, ...
           'callback','fmri_select_profiles_ui({''SAVE_TXT''});', ...
           'label','&Save to a text file', ...
	   'tag', 'menu_save');
      h2 = uimenu('parent', h_file, ...
           'callback','close(gcbf);', ...
           'label','&Close', ...
	   'tag', 'menu_close');

   pause(0.01)

   setappdata(gcf,'FilterPattern',filter_pattern);
   setappdata(gcf,'StartDirectory',StartDirectory);

   if ~isempty(dir_name),
      try
         cd(dir_name);
      catch
         msg = 'ERROR: Invalid directory.  Use current directory to start';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      end;
   end;
   
   dir_name = pwd;
   if isempty(dir_name)
      dir_name = filesep; 
   end;

   set(e_h,'String',fullfile(dir_name, filter_pattern));

   update_dirlist(dir_name);

   if ~isempty(selected_files)
      init_selection(selected_files);
   end;

   SetEditAlignment;

   return;					% Init


% --------------------------------------------------------------------
function AddSessionProfile()

   h = findobj(gcf,'Tag','File/DirectoryList');    % get the selected file
   selected_dir_idx = get(h,'Value');
   dir_info = get(h,'Userdata');

   dir_entry = find([dir_info.is_dir(selected_dir_idx)] == 1);

   if isempty(dir_entry)			  % only select files 
      selected_files = dir_info.names(selected_dir_idx);
   else
      msg = 'ERROR: Cannot select a directory.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   num_files = length(selected_files); 
   full_selected_files = cell(num_files,1);
   for i=1:num_files,
      curr = pwd;
      if isempty(curr)
         curr = filesep;
      end

      full_selected_files{i} = fullfile(curr,selected_files{i});
   end;
   
   %  update the session profile list
   %
   h = findobj(gcf,'Tag','SessionProfileList');	   
   profile_list = get(h,'String');
   full_profile_list = get(h,'Userdata');

   % check for duplication
   %
   for i=1:length(full_profile_list),
     for j=1:length(selected_files),
       if isequal(full_profile_list{i},full_selected_files{j})
          msg = 'ERROR: Duplicate session profile is not allowed.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
       end;  
     end;
   end; 

   updated_profile_list = [profile_list; selected_files];
   updated_full_profile_list = [full_profile_list; full_selected_files];

   use_full_path = get(findobj(gcf,'Tag','FullPathChkbox'),'Value');
   if (use_full_path)
      set(h,'String',updated_full_profile_list);
   else
      set(h,'String',updated_profile_list);
   end
   set(h,'Userdata',updated_full_profile_list);

   return;					% AddSessionProfile


% --------------------------------------------------------------------
function RemoveSessionProfile()

   %  update the session profile list
   %
   h = findobj(gcf,'Tag','SessionProfileList');	   
   profile_idx = get(h,'Value');
   profile_list = get(h,'String');
   full_profile_list = get(h,'Userdata');

   mask = zeros(1,length(profile_list));
   mask(profile_idx) = 1;
   remain_idx = find(mask == 0);

   if isempty(remain_idx)
      updated_profile_list = [];
      updated_full_profile_list = [];
   else
      updated_profile_list = profile_list(remain_idx);
      updated_full_profile_list = full_profile_list(remain_idx); 
   end;

   if (profile_idx > length(updated_profile_list)) & (profile_idx ~= 1)
       set(h,'Value',profile_idx - 1);
   end;

   use_full_path = get(findobj(gcf,'Tag','FullPathChkbox'),'Value');
   if (use_full_path)
      set(h,'String',updated_full_profile_list);
   else
      set(h,'String',updated_profile_list);
   end
   set(h,'Userdata',updated_full_profile_list);

   return;					% RemoveSessionProfile


% --------------------------------------------------------------------
function SwitchFullPath()
 
   h = findobj(gcf,'Tag','FullPathChkbox');
   use_full_path = get(h,'Value');

   h = findobj(gcf,'Tag','SessionProfileList');	   
   profile_list = get(h,'String');
   full_profile_list = get(h,'Userdata');

   if (use_full_path),
      set(h,'String',full_profile_list);
   else
      num_profiles = length(profile_list);
      for i=1:num_profiles,
         [p_path,p_name,p_ext] = fileparts(profile_list{i});
         profile_list{i} = [p_name p_ext];
      end;
      set(h,'String',profile_list);
   end;

   return;					% SwitchFullPath


% --------------------------------------------------------------------
function MoveUpSessionProfile()

   %  update the session profile list
   %
   h = findobj(gcf,'Tag','SessionProfileList');	   
   list_top = get(h,'ListboxTop');
   profile_idx = get(h,'Value');
   profile_list = get(h,'String');
   full_profile_list = get(h,'Userdata');

   if (profile_idx == 1),		% already on the top of list
      return;
   end;
   
   temp_buffer = profile_list(profile_idx-1);
   profile_list(profile_idx-1) = profile_list(profile_idx);
   profile_list(profile_idx) = temp_buffer;

   temp_buffer = full_profile_list(profile_idx-1);
   full_profile_list(profile_idx-1) = full_profile_list(profile_idx);
   full_profile_list(profile_idx) = temp_buffer;


   curr_value = profile_idx - 1;
   set(h,'String',profile_list,'Userdata',full_profile_list, ...
         'Value',curr_value);

   if (curr_value < list_top)
      set(h,'ListBoxTop',curr_value);
   else
      set(h,'ListBoxTop',list_top);
   end;

   return;					% MoveUpSessionProfile


% --------------------------------------------------------------------
function MoveDownSessionProfile()

   %  update the session profile list
   %
   h = findobj(gcf,'Tag','SessionProfileList');	   
   list_top = get(h,'ListboxTop');
   profile_idx = get(h,'Value');
   profile_list = get(h,'String');
   full_profile_list = get(h,'Userdata');

   if (profile_idx == length(profile_list)),	% already on the top of list
      return;
   end;
   
   temp_buffer = profile_list(profile_idx+1);
   profile_list(profile_idx+1) = profile_list(profile_idx);
   profile_list(profile_idx) = temp_buffer;

   temp_buffer = full_profile_list(profile_idx+1);
   full_profile_list(profile_idx+1) = full_profile_list(profile_idx);
   full_profile_list(profile_idx) = temp_buffer;

   set(h,'String',profile_list,'Userdata',full_profile_list, ...
         'Value',profile_idx+1);
   set(h,'ListBoxTop',list_top);

   return;					% MoveDownSessionProfile


% --------------------------------------------------------------------
function SetEditAlignment()

   h = findobj(gcf,'Tag','FilterEdit');
   set(h,'Units','characters');

   pos = get(h,'Position'); 

   dir_name = get(h,'String');
   len = length(dir_name);

   if (len > pos(3)+5),
      set(h,'HorizontalAlignment','right','String',dir_name);
   else
      set(h,'HorizontalAlignment','left','String',dir_name);
   end;

   set(h,'Units','normal');

   return;					% SetEditAlignment


% --------------------------------------------------------------------
function EditFilter()

   filename = get(gcbo,'String');
   [filter_path,filter_name,filter_ext] = fileparts(filename);
   filter_pattern = [filter_name filter_ext];

   setappdata(gcf,'FilterPattern',filter_pattern);

   if isempty(filter_path),
       filter_path = '/';
   end;

   try
       cd (filter_path);
   catch
       msg = 'ERROR: Invalid directory';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;
   
   update_dirlist(filter_path);

   return;					% EditFilter

   

% --------------------------------------------------------------------
function UpdateDirectoryList()

   listed_dir = get(gcbo,'String');
   selected_dir_idx = get(gcbo,'Value');
   dir_info = get(gcbo,'Userdata');

   dir_entry = find([dir_info.is_dir(selected_dir_idx)] == 1);

   if isempty(dir_entry) 		% only file have been selected
      return;
   end;

   if length(selected_dir_idx) > 1,     % set to the first selected directory
      set(gcbo,'Value',selected_dir_idx(1));
      return;
   end;

   if ~(dir_info.is_dir(selected_dir_idx))
      return; 
   else
      selected_dir = dir_info.names{selected_dir_idx};
   end;
   
   %  update the filter edit box
   %
   try 
      cd (selected_dir);
   catch
       msg = 'ERROR: Cannot access the directory';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   curr_dir = curr;

   filter_pattern = getappdata(gcf,'FilterPattern');
   h = findobj(gcf,'Tag','FilterEdit');
   set(h,'String',fullfile(curr, filter_pattern));

   SetEditAlignment;
   update_dirlist(curr_dir);

   set(gcf,'Pointer',old_pointer);

   return;					% UpdateDirectoryList


% --------------------------------------------------------------------
function update_dirlist(filter_path);

   filter_pattern = getappdata(gcf,'FilterPattern');

   dir_struct = dir(filter_path);
   if isempty(dir_struct)
       msg = 'ERROR: Directory not found!';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');
   
   dir_list = dir_struct(find([dir_struct.isdir] == 1));
   [sorted_dir_names,sorted_dir_index] = sortrows({dir_list.name}');

   dir_struct = dir([filter_path filesep filter_pattern]);
   if isempty(dir_struct)
      sorted_file_names = [];
   else
      file_list = dir_struct(find([dir_struct.isdir] == 0));
      [sorted_file_names,sorted_file_index] = sortrows({file_list.name}');
   end;

   h = findobj(gcf,'Tag','File/DirectoryList');

   out_names = [sorted_dir_names; sorted_file_names];
   num_dir = length(sorted_dir_names);
   for i=1:num_dir,
      out_names{i} = sprintf('[%s]',sorted_dir_names{i}); 
   end;

   dir_info.is_dir = zeros(1,length(out_names));
   dir_info.is_dir(1:num_dir) = 1;
   dir_info.names = [sorted_dir_names; sorted_file_names];

   set(h,'String',out_names,'Userdata',dir_info,'Value',2) 
   
   set(gcf,'Pointer',old_pointer);

   return; 					% update_dirlist

% --------------------------------------------------------------------
function init_selection(selected_files);

   if isempty(selected_files{1}),
       return;
   end;

   set(findobj(gcf,'Tag','FullPathChkbox'),'Value',1);
   
   h = findobj(gcf,'Tag','SessionProfileList');	   
   set(h,'String',selected_files);
   set(h,'Userdata',selected_files);

   return; 					% init_selection


%----------------------------------------------------------------------------
function load_txt

   h = findobj(gcf,'Tag','FullPathChkbox');
   use_full_path = get(h,'Value');

   [fn, pn] = rri_selectfile('*.txt','Open Session Profile Group File');
   grp_file = [pn filesep fn];

   try
      full_profile_list = fmri_read_profiles(grp_file);
   catch
      return;
   end

   num_profiles = length(full_profile_list);
   for i=1:num_profiles,
      [junk profile_list{i}] = rri_fileparts(full_profile_list{i});
      full_profile_list{i} = fullfile(pwd, profile_list{i});
   end;

   h = findobj(gcf,'Tag','SessionProfileList');
   set(h,'Userdata',full_profile_list);
   set(h,'String',profile_list);

   if (use_full_path),
      set(h,'String',full_profile_list);
   else
      set(h,'String',profile_list);
   end;

   return


%----------------------------------------------------------------------------
function save_txt

   full_profile_list = get(findobj(gcf,'Tag','SessionProfileList'),'Userdata');

   num_profiles = length(full_profile_list);
   for i=1:num_profiles,
      [junk profile_list{i}] = rri_fileparts(full_profile_list{i});
   end;

   [fn, pn] = rri_selectfile('*.txt','Save Session Profile Group File');

   if ~fn
      return;
   else
      grp_file = [pn filesep fn];

      try
         fmri_save_profiles(grp_file, profile_list);
      catch
         msg = 'Cannot Save Session Profile Group File';
         uiwait(msgbox(msg,'ERROR'));
      end
   end

   return


%----------------------------------------------------------------------------
function delete_fig

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       fmri_select_profiles_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'fmri_select_profiles_pos');
    catch
    end

   return;

