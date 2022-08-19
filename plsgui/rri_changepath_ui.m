function rri_changepath_ui(varargin)
%
% usage: rri_changepath_ui(old_file, title)
%

   if nargin == 0 | ischar(varargin{1}) 	% create figure

      old_file = '';
      tit_nam = 'Change PLS Path';

      if (nargin >= 1), old_file = varargin{1}; end;
      if (nargin >= 2), tit_nam = varargin{2}; end;

      init(old_file, tit_nam);

      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1}{1});

   if strcmp(action,'UPDATE_FILE_LIST'),
      update_file_list;
   elseif strcmp(action,'SELECT_A_FILE'),
      select_a_file;
   elseif strcmp(action,'SELECT_ALL_FILE'),
      select_all_file;
   elseif strcmp(action,'SELECT_NEW_PATH_EDIT'),
      select_new_path_edit;
   elseif strcmp(action,'BROWSE_BUTTON_PRESSED'),
      new_path_edit_hdl = findobj(gcf,'tag','NewPathEdit');
      newpath = get(new_path_edit_hdl,'string');
      newpath = rri_getdirectory({newpath});
      if ~isempty(newpath), set(new_path_edit_hdl,'string',newpath); end;
   elseif strcmp(action,'SELECT_BUTTON_PRESSED'),
      click_select;
   elseif strcmp(action,'DONE_BUTTON_PRESSED'),
      select_save;
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      close(gcf);
   elseif strcmp(action,'DELETE_FIG')
      delete_fig;
   end;

   return;


% --------------------------------------------------------------------
function init(old_file, tit_nam)

   save_setting_status = 'on';
   rri_changepath_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(rri_changepath_pos) & strcmp(save_setting_status,'on')

      pos = rri_changepath_pos;

   else

      w = 0.7;
      h = 0.4;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name',tit_nam, ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Position',pos, ...
        'DeleteFcn','rri_changepath_ui({''DELETE_FIG''});', ...
        'WindowStyle', 'normal', ...
        'Tag','GetFilesFigure', ...
        'ToolBar','none');

   left_margin = 0.05;
   text_height = 0.1;

   x = left_margin;
   y = 0.85;
   w = 0.3 - left_margin;
   h = text_height;

   pos = [x y w h];

   fnt = 0.5;

   h1 = uicontrol('Parent',h0, ...            % file label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','File Name:', ...
        'Tag','FileLabel');

   y = 0.35;
   h = 0.5;

   pos = [x y w h];

   fnt = 0.1;

   h1 = uicontrol('Parent',h0, ...            % file listbox
        'Style','list', ...
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','', ...
        'Callback','rri_changepath_ui({''UPDATE_FILE_LIST''});', ...
        'Tag','FILE_LIST');

   y = 0.2;
   h = text_height;

   pos = [x y w h];

   fnt = 0.5;

   h1 = uicontrol('Parent',h0, ...            % select a file
        'Style','radio', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Select one file', ...
        'Callback','rri_changepath_ui({''SELECT_A_FILE''});', ...
	'value',1, ...
        'Tag','SELECT_A_FILE');

   y = 0.1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % select all files
        'Style','radio', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Select more files', ...
        'Callback','rri_changepath_ui({''SELECT_ALL_FILE''});', ...
	'value',0, ...
        'Tag','SELECT_ALL_FILE');

   x = left_margin+0.3;
   w = 1 - x - left_margin;
   y = 0.75;
   h = text_height;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % old path label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Old path (default: PLS Data Directory):', ...
        'Tag','OldPathLabel');

   y = 0.45;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % new path label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','New path (Old path will be changed to New path):', ...
        'Tag','NewPathLabel');

   y = 0.65;
   w = w - 0.2;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % old path edit
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','N/A', ...
	'enable','on', ...
        'Tag','OldPathEdit');

%	'enable','inactive', ...

   y = 0.35;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % new path edit
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','', ...
	'enable','inactive', ...
        'Tag','NewPathEdit');

%        'buttondown','rri_changepath_ui({''SELECT_NEW_PATH_EDIT''});', ...

   x = x + w + 0.05;
   w = 0.15;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % BROWSE
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Browse', ...
        'Callback','rri_changepath_ui({''BROWSE_BUTTON_PRESSED''});', ...
        'Tag','BROWSEButton');

   y = 0.65;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % SELECT
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Search', ...
        'Callback','rri_changepath_ui({''SELECT_BUTTON_PRESSED''});', ...
        'Tag','SELECTButton');

   w = 0.15;
   x = 1-w-left_margin;
   y = 0.1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % CANCEL
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Close', ...
        'Callback','rri_changepath_ui({''CANCEL_BUTTON_PRESSED''});', ...
        'Tag','CANCELButton');

   x = x-w-0.05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % DONE
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Change', ...
        'Callback','rri_changepath_ui({''DONE_BUTTON_PRESSED''});', ...
        'Tag','DONEButton');

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

   arch = computer;
   ispc = strcmp(arch(1:2),'PC');

   setappdata(gcf,'ispc',ispc);
   setappdata(gcf,'old_file',old_file);
   select_a_file;

   return;					% Init


%----------------------------------------------------------------------------
function num_dir = list_file(dir_name)

   file_list_hdl = findobj(gcf,'Tag','FILE_LIST');
   select_a_file_hdl = findobj(gcf,'Tag','SELECT_A_FILE');
   select_all_file_hdl = findobj(gcf,'Tag','SELECT_ALL_FILE');
   old_path_edit_hdl = findobj(gcf,'tag','OldPathEdit');
   new_path_edit_hdl = findobj(gcf,'tag','NewPathEdit');

   % get dir list
   %
   dir_struct11 = dir(dir_name);
   if isempty(dir_struct11)
       msg = 'ERROR: Directory not found!';
       msgbox(msg);
       return;
   end;

   % preserve old mouse pointer, and make current pointer as 'Busy'
   % it is useful to execute slow process
   %
   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   dir_list = dir_struct11(find([dir_struct11.isdir] == 1));
   [sorted_dir_names,sorted_dir_index] = sortrows({dir_list.name}');

   % get file list
   %
   dir_struct1 = dir([dir_name, filesep, '*session.mat']);
   dir_struct2 = dir([dir_name, filesep, '*datamat.mat']);
   dir_struct3 = dir([dir_name, filesep, '*result.mat']);

   sorted_file_names = [];

   % get sorted_file_name
   %
   if ~isempty(dir_struct1)
      file_list1 = dir_struct1(find([dir_struct1.isdir] == 0));
      sorted_file_names = [sorted_file_names {file_list1.name}];
   end

   if ~isempty(dir_struct2)
      file_list2 = dir_struct2(find([dir_struct2.isdir] == 0));
      sorted_file_names = [sorted_file_names {file_list2.name}];
   end

   if ~isempty(dir_struct3)
      file_list3 = dir_struct3(find([dir_struct3.isdir] == 0));
      sorted_file_names = [sorted_file_names {file_list3.name}];
   end

   [sorted_file_names, sorted_file_index] = sortrows(sorted_file_names');

   out_names = [sorted_dir_names; sorted_file_names];
   num_dir = length(sorted_dir_names);
   for i=1:num_dir,
      out_names{i} = sprintf('[%s]',sorted_dir_names{i}); 
   end;

   setappdata(gcf,'num_dir',num_dir);

   set(file_list_hdl, 'String',out_names, 'user',dir_name);

   if isempty(sorted_file_names)
      set(file_list_hdl, 'value',1, 'listboxtop',1);
   else
      set(file_list_hdl, 'value',num_dir+1, 'listboxtop',num_dir+1);
   end

   set(gcf,'Pointer',old_pointer);		% Put 'Arrow' pointer back

   return;					% list_file


%----------------------------------------------------------------------------
function update_file_list

   file_list_hdl = findobj(gcf,'Tag','FILE_LIST');
   select_a_file_hdl = findobj(gcf,'Tag','SELECT_A_FILE');
   select_all_file_hdl = findobj(gcf,'Tag','SELECT_ALL_FILE');
   old_path_edit_hdl = findobj(gcf,'tag','OldPathEdit');
   new_path_edit_hdl = findobj(gcf,'tag','NewPathEdit');
   dir_name = get(file_list_hdl,'user');

   listed_dir = get(gcbo,'String');
   selected_dir_idx = get(gcbo,'Value');

   if isempty(selected_dir_idx)
      return;
   end

   selected_dir_idx = selected_dir_idx(1);
   selected_dir_name1 = listed_dir{selected_dir_idx};
   selected_dir_name = selected_dir_name1(2:end-1);
   selected_dir = [dir_name filesep selected_dir_name];

   %  go into subdirectory
   %
   try

      cd (selected_dir);

   %  not subdirectory
   %
   catch

      if get(file_list_hdl,'max') == 1
         old_path = get_old_path(selected_dir_name1);
         set(old_path_edit_hdl,'string',old_path);
      end

      return;
   end

   if isempty(pwd)
       selected_dir = filesep;
   else
       selected_dir = pwd;
   end

   if get(file_list_hdl,'max') == 1
      select_a_file;
   else
      select_all_file;
   end

%   list_file(selected_dir);

   return;					% update_file_list


%----------------------------------------------------------------------------
function select_a_file;

   file_list_hdl = findobj(gcf,'Tag','FILE_LIST');
   select_a_file_hdl = findobj(gcf,'Tag','SELECT_A_FILE');
   select_all_file_hdl = findobj(gcf,'Tag','SELECT_ALL_FILE');
   old_path_edit_hdl = findobj(gcf,'tag','OldPathEdit');
   new_path_edit_hdl = findobj(gcf,'tag','NewPathEdit');
   select_button_hdl = findobj(gcf,'tag','SELECTButton');
%   set(select_button_hdl,'enable','on');

   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   list_file(curr);

   set(old_path_edit_hdl,'string','N/A');
   set(new_path_edit_hdl,'string',curr);
   set(select_a_file_hdl,'value',1);
   set(select_all_file_hdl,'value',0);
   set(file_list_hdl,'max',1);

   old_file = getappdata(gcf,'old_file');

   if ~isempty(old_file)
      listed_file = get(file_list_hdl,'string');
      [tmp1,tmp2,idx]=intersect(old_file,listed_file);
      set(file_list_hdl,'value',idx);
   end

   filename = get(file_list_hdl,'string');
   filename = filename(get(file_list_hdl,'value'));
   filename = filename{1};

   if filename(1) == '['
      set(new_path_edit_hdl,'enable','inactive');
      return;
   end

   set(new_path_edit_hdl,'enable','on');
   old_path = get_old_path(filename);
   set(old_path_edit_hdl,'string',old_path);

   return;					% select_a_file


%----------------------------------------------------------------------------
function select_all_file;

   file_list_hdl = findobj(gcf,'Tag','FILE_LIST');
   select_a_file_hdl = findobj(gcf,'Tag','SELECT_A_FILE');
   select_all_file_hdl = findobj(gcf,'Tag','SELECT_ALL_FILE');
   old_path_edit_hdl = findobj(gcf,'tag','OldPathEdit');
   new_path_edit_hdl = findobj(gcf,'tag','NewPathEdit');
   set(new_path_edit_hdl,'enable','on');
   select_button_hdl = findobj(gcf,'tag','SELECTButton');
%   set(select_button_hdl,'enable','off');

   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   num_dir = list_file(curr);

   set(new_path_edit_hdl,'string',curr);
   set(select_a_file_hdl,'value',0);
   set(select_all_file_hdl,'value',1);
   set(file_list_hdl, 'max',2);

   if length(get(file_list_hdl,'string')) > num_dir

      set(file_list_hdl, 'listboxtop',num_dir+1, ...
	'value',(num_dir+1):length(get(file_list_hdl,'string')));
      set(new_path_edit_hdl,'enable','on');
      set(old_path_edit_hdl,'string','Varied');

   else

      set(file_list_hdl, 'listboxtop',1, 'value', []);
      set(new_path_edit_hdl,'enable','inactive');
      set(old_path_edit_hdl,'string','N/A');

   end

   return;					% select_all_file


%----------------------------------------------------------------------------
function select_new_path_edit

   msg = 'Please select a valid PLS data file first';
   uiwait(msgbox(msg,'Error','modal'));

   return;


%----------------------------------------------------------------------------
function delete_fig

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       rri_changepath_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'rri_changepath_pos');
    catch
    end

   return;					% delete_fig


%----------------------------------------------------------------------------
function old_path = get_old_path(filename)

   old_path = '';

   if ~isempty(findstr('_PETsession.mat', filename))

      load(filename, 'session_info');
      old_path = session_info.pls_data_path;

      return;      

   elseif ~isempty(findstr('_PETdatamat.mat', filename))

      load(filename, 'session_info');
      old_path = session_info.pls_data_path;

      return;      

   elseif ~isempty(findstr('_PETresult.mat', filename))

      load(filename, 'datamat_files');
%      old_path = fileparts(datamat_files{1});
      old_path = rri_fileparts(datamat_files{1});

      return;      

   elseif ~isempty(findstr('_fMRIsession.mat', filename))

      load(filename, 'session_info');
      old_path = session_info.pls_data_path;

      return;      

   elseif ~isempty(findstr('_fMRIdatamat.mat', filename))

      load(filename, 'st_sessionFile');
%      old_path = fileparts(st_sessionFile);
      old_path = rri_fileparts(st_sessionFile);

      return;      

   elseif ~isempty(findstr('_fMRIresult.mat', filename))

      load(filename, 'SessionProfiles');
%      old_path = fileparts(SessionProfiles{1}{1});
      old_path = rri_fileparts(SessionProfiles{1}{1});

      return;      

   elseif ~isempty(findstr('_BfMRIsession.mat', filename))

      load(filename, 'session_info');
      old_path = session_info.pls_data_path;

      return;      

   elseif ~isempty(findstr('_BfMRIdatamat.mat', filename))

      load(filename, 'st_sessionFile');
%      old_path = fileparts(st_sessionFile);
      old_path = rri_fileparts(st_sessionFile);

      return;      

   elseif ~isempty(findstr('_BfMRIresult.mat', filename))

      load(filename, 'SessionProfiles');
%      old_path = fileparts(SessionProfiles{1}{1});
      old_path = rri_fileparts(SessionProfiles{1}{1});

      return;      

   elseif ~isempty(findstr('_ERPsession.mat', filename))

      load(filename, 'session_info');
      old_path = session_info.pls_data_path;

      return;      

   elseif ~isempty(findstr('_ERPdatamat.mat', filename))

      load(filename, 'session_info');
      old_path = session_info.pls_data_path;

      return;      

   elseif ~isempty(findstr('_ERPresult.mat', filename))

      load(filename, 'datamat_files');
%      old_path = fileparts(datamat_files{1});
      old_path = rri_fileparts(datamat_files{1});

      return;

   end

   return;					% get_old_path


%----------------------------------------------------------------------------
function select_save

   systype = '/';
   file_list_hdl = findobj(gcf,'Tag','FILE_LIST');
   select_a_file_hdl = findobj(gcf,'Tag','SELECT_A_FILE');
   select_all_file_hdl = findobj(gcf,'Tag','SELECT_ALL_FILE');
   old_path_edit_hdl = findobj(gcf,'tag','OldPathEdit');
   new_path_edit_hdl = findobj(gcf,'tag','NewPathEdit');
   dir_name = get(file_list_hdl,'user');

   file_list = get(file_list_hdl,'string');
   file_list = file_list(get(file_list_hdl,'value'));

   oldpath = get(old_path_edit_hdl,'string');

   if get(select_all_file_hdl,'value')
      org_oldpath = oldpath;
   end

   newpath = get(new_path_edit_hdl,'string');

   if isempty(newpath)
      msg = 'Please enter new PLS data path';
      uiwait(msgbox(msg,'Error','modal'));
      return;
   end

   newpath = [upper(newpath(1)) newpath(2:end)];

   if length(file_list) > 1
      progress_hdl = rri_progress_ui('initialize', 'Changing PLS path, please wait ...');
   end

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   for i = 1:length(file_list)

      filename = fullfile(dir_name, file_list{i});

      if length(file_list) > 1
         msg = ['Working on file: ', filename];
         rri_progress_ui(progress_hdl, '', msg);
         rri_progress_ui(progress_hdl, '', i/length(file_list));
      end

      if ~isempty(findstr('PETsession.mat', filename))

         load(filename, 'session_info');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = session_info.pls_data_path;      
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

%         session_info.pls_data_path = newpath;
         session_info.pls_data_path = ...
            [upper(session_info.pls_data_path(1)) session_info.pls_data_path(2:end)];
         session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'\','/');
         elseif strcmp(systype,'ux2pc')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'/','\');
         end

         for j = 1:session_info.num_subjects
            session_info.subject{j} = ...
               [upper(session_info.subject{j}(1)) session_info.subject{j}(2:end)];
            session_info.subject{j} = ...
               strrep(session_info.subject{j},oldpath,newpath);
            if strcmp(systype,'pc2ux')
               session_info.subject{j} = ...
                  strrep(session_info.subject{j},'\','/');
            elseif strcmp(systype,'ux2pc')
               session_info.subject{j} = ...
                  strrep(session_info.subject{j},'/','\');
            end
         end

         save(filename,'-append','session_info');

      elseif ~isempty(findstr('PETdatamat.mat', filename))

         load(filename, 'session_info','session_file');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = session_info.pls_data_path;
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         session_info.pls_data_path = ...
            [upper(session_info.pls_data_path(1)) session_info.pls_data_path(2:end)];
         session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'\','/');
         elseif strcmp(systype,'ux2pc')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'/','\');
         end

         for j = 1:session_info.num_subjects
            session_info.subject{j} = ...
               [upper(session_info.subject{j}(1)) session_info.subject{j}(2:end)];
            session_info.subject{j} = ...
               strrep(session_info.subject{j},oldpath,newpath);
            if strcmp(systype,'pc2ux')
               session_info.subject{j} = ...
                  strrep(session_info.subject{j},'\','/');
            elseif strcmp(systype,'ux2pc')
               session_info.subject{j} = ...
                  strrep(session_info.subject{j},'/','\');
            end
         end

         session_file = ...
            [upper(session_file(1)) session_file(2:end)];
         session_file = strrep(session_file,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            session_file = strrep(session_file,'\','/');
         elseif strcmp(systype,'ux2pc')
            session_file = strrep(session_file,'/','\');
         end

         save(filename,'-append','session_info','session_file');

      elseif ~isempty(findstr('PETresult.mat', filename))

         load(filename, 'datamat_files');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = rri_fileparts(datamat_files{1});
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         for j = 1:length(datamat_files)
            datamat_files{j} = ...
               [upper(datamat_files{j}(1)) datamat_files{j}(2:end)];
            datamat_files{j} = strrep(datamat_files{j},oldpath,newpath);
            if strcmp(systype,'pc2ux')
               datamat_files{j} = strrep(datamat_files{j},'\','/');
            elseif strcmp(systype,'ux2pc')
               datamat_files{j} = strrep(datamat_files{j},'/','\');
            end
         end

         save(filename,'-append','datamat_files');

      elseif ~isempty(findstr('fMRIsession.mat', filename))

         load(filename, 'session_info');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = session_info.pls_data_path;
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         session_info.pls_data_path = ...
            [upper(session_info.pls_data_path(1)) session_info.pls_data_path(2:end)];
         session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'\','/');
         elseif strcmp(systype,'ux2pc')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'/','\');
         end

         for j = 1:session_info.num_runs
            session_info.run(j).data_path = ...
               [upper(session_info.run(j).data_path(1)) session_info.run(j).data_path(2:end)];
            session_info.run(j).data_path = ...
		strrep(session_info.run(j).data_path,oldpath,newpath);
            if strcmp(systype,'pc2ux')
               session_info.run(j).data_path = ...
                  strrep(session_info.run(j).data_path,'\','/');
            elseif strcmp(systype,'ux2pc')
               session_info.run(j).data_path = ...
                  strrep(session_info.run(j).data_path,'/','\');
            end
         end

         save(filename,'-append','session_info');

      elseif ~isempty(findstr('fMRIdatamat.mat', filename))

         load(filename, 'st_sessionFile');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = rri_fileparts(st_sessionFile);
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         st_sessionFile = ...
            [upper(st_sessionFile(1)) st_sessionFile(2:end)];
         st_sessionFile = strrep(st_sessionFile,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            st_sessionFile = strrep(st_sessionFile,'\','/');
         elseif strcmp(systype,'ux2pc')
            st_sessionFile = strrep(st_sessionFile,'/','\');
         end

         save(filename,'-append','st_sessionFile');

      elseif ~isempty(findstr('fMRIresult.mat', filename))

         load(filename, 'SessionProfiles');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = rri_fileparts(SessionProfiles{1}{1});
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         for i = 1:length(SessionProfiles)
            for j = 1:length(SessionProfiles{i})
               SessionProfiles{i}{j} = ...
                  [upper(SessionProfiles{i}{j}(1)) SessionProfiles{i}{j}(2:end)];
               SessionProfiles{i}{j} = ...
                  strrep(SessionProfiles{i}{j},oldpath,newpath);
               if strcmp(systype,'pc2ux')
                  SessionProfiles{i}{j} = strrep(SessionProfiles{i}{j},'\','/');
               elseif strcmp(systype,'ux2pc')
                  SessionProfiles{i}{j} = strrep(SessionProfiles{i}{j},'/','\');
               end
            end
         end

         save(filename,'-append','SessionProfiles');

      elseif ~isempty(findstr('BfMRIsession.mat', filename))

         load(filename, 'session_info');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = session_info.pls_data_path;
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         session_info.pls_data_path = ...
            [upper(session_info.pls_data_path(1)) session_info.pls_data_path(2:end)];
         session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'\','/');
         elseif strcmp(systype,'ux2pc')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'/','\');
         end

         for j = 1:session_info.num_runs
            session_info.run(j).data_path = ...
               [upper(session_info.run(j).data_path(1)) session_info.run(j).data_path(2:end)];
            session_info.run(j).data_path = ...
		strrep(session_info.run(j).data_path,oldpath,newpath);
            if strcmp(systype,'pc2ux')
               session_info.run(j).data_path = ...
                  strrep(session_info.run(j).data_path,'\','/');
            elseif strcmp(systype,'ux2pc')
               session_info.run(j).data_path = ...
                  strrep(session_info.run(j).data_path,'/','\');
            end
         end

         save(filename,'-append','session_info');

      elseif ~isempty(findstr('BfMRIdatamat.mat', filename))

         load(filename, 'st_sessionFile');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = rri_fileparts(st_sessionFile);
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         st_sessionFile = ...
            [upper(st_sessionFile(1)) st_sessionFile(2:end)];
         st_sessionFile = strrep(st_sessionFile,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            st_sessionFile = strrep(st_sessionFile,'\','/');
         elseif strcmp(systype,'ux2pc')
            st_sessionFile = strrep(st_sessionFile,'/','\');
         end

         save(filename,'-append','st_sessionFile');

      elseif ~isempty(findstr('BfMRIresult.mat', filename))

         load(filename, 'SessionProfiles');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = rri_fileparts(SessionProfiles{1}{1});
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         for i = 1:length(SessionProfiles)
            for j = 1:length(SessionProfiles{i})
               SessionProfiles{i}{j} = ...
                  [upper(SessionProfiles{i}{j}(1)) SessionProfiles{i}{j}(2:end)];
               SessionProfiles{i}{j} = ...
		  strrep(SessionProfiles{i}{j},oldpath,newpath);
               if strcmp(systype,'pc2ux')
                  SessionProfiles{i}{j} = strrep(SessionProfiles{i}{j},'\','/');
               elseif strcmp(systype,'ux2pc')
                  SessionProfiles{i}{j} = strrep(SessionProfiles{i}{j},'/','\');
               end
            end
         end

         save(filename,'-append','SessionProfiles');

      elseif ~isempty(findstr('ERPsession.mat', filename))

         load(filename, 'session_info');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = session_info.pls_data_path;
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         session_info.pls_data_path = ...
            [upper(session_info.pls_data_path(1)) session_info.pls_data_path(2:end)];
         session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'\','/');
         elseif strcmp(systype,'ux2pc')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'/','\');
         end

         for j = 1:session_info.num_subjects
            session_info.subject{j} = ...
               [upper(session_info.subject{j}(1)) session_info.subject{j}(2:end)];
            session_info.subject{j} = ...
		strrep(session_info.subject{j},oldpath,newpath);
            if strcmp(systype,'pc2ux')
               session_info.subject{j} = ...
                  strrep(session_info.subject{j},'\','/');
            elseif strcmp(systype,'ux2pc')
               session_info.subject{j} = ...
                  strrep(session_info.subject{j},'/','\');
            end
         end

         save(filename,'-append','session_info');

      elseif ~isempty(findstr('ERPdatamat.mat', filename))

         load(filename, 'session_info','session_file','datafile');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = session_info.pls_data_path;
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         session_info.pls_data_path = ...
            [upper(session_info.pls_data_path(1)) session_info.pls_data_path(2:end)];
         session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'\','/');
         elseif strcmp(systype,'ux2pc')
            session_info.pls_data_path = ...
               strrep(session_info.pls_data_path,'/','\');
         end

         for j = 1:session_info.num_subjects
            session_info.subject{j} = ...
               [upper(session_info.subject{j}(1)) session_info.subject{j}(2:end)];
            session_info.subject{j} = ...
		strrep(session_info.subject{j},oldpath,newpath);
            if strcmp(systype,'pc2ux')
               session_info.subject{j} = ...
                  strrep(session_info.subject{j},'\','/');
            elseif strcmp(systype,'ux2pc')
               session_info.subject{j} = ...
                  strrep(session_info.subject{j},'/','\');
            end
         end

         session_file = ...
            [upper(session_file(1)) session_file(2:end)];
         session_file = strrep(session_file,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            session_file = strrep(session_file,'\','/');
         elseif strcmp(systype,'ux2pc')
            session_file = strrep(session_file,'/','\');
         end
         datafile = ...
            [upper(datafile(1)) datafile(2:end)];
         datafile = strrep(datafile,oldpath,newpath);
         if strcmp(systype,'pc2ux')
            datafile = strrep(datafile,'\','/');
         elseif strcmp(systype,'ux2pc')
            datafile = strrep(datafile,'/','\');
         end

         save(filename,'-append','session_info','session_file','datafile');

      elseif ~isempty(findstr('ERPresult.mat', filename))

         load(filename, 'datamat_files');

         if get(select_all_file_hdl,'value') & strcmp(org_oldpath,'Varied')
            oldpath = rri_fileparts(datamat_files{1});
         end
         oldpath = [upper(oldpath(1)) oldpath(2:end)];
         if isempty(findstr(oldpath, filesep))
            if getappdata(gcf,'ispc')
               systype = 'ux2pc';
            else
               systype = 'pc2ux';
            end
         end

         for j = 1:length(datamat_files)
            datamat_files{j} = ...
               [upper(datamat_files{j}(1)) datamat_files{j}(2:end)];
            datamat_files{j} = strrep(datamat_files{j},oldpath,newpath);
            if strcmp(systype,'pc2ux')
               datamat_files{j} = strrep(datamat_files{j},'\','/');
            elseif strcmp(systype,'ux2pc')
               datamat_files{j} = strrep(datamat_files{j},'/','\');
            end
         end

         save(filename,'-append','datamat_files');

      end

   end			% for i=1:length(filt_list)

   set(gcf,'Pointer',old_pointer);		% Put 'Arrow' pointer back

   if length(file_list) > 1
      close(progress_hdl);
   end

   if 1		% ~strcmp(org_oldpath,'Varied')
      set(old_path_edit_hdl,'string',newpath);
   end

   return;					% select_save


%----------------------------------------------------------------------------
function click_select

   file_list_hdl = findobj(gcf,'Tag','FILE_LIST');
   select_a_file_hdl = findobj(gcf,'Tag','SELECT_A_FILE');
   select_all_file_hdl = findobj(gcf,'Tag','SELECT_ALL_FILE');
   old_path_edit_hdl = findobj(gcf,'tag','OldPathEdit');
   new_path_edit_hdl = findobj(gcf,'tag','NewPathEdit');
   dir_name = get(file_list_hdl,'user');

   file_list = get(file_list_hdl,'string');
   file_list = file_list(get(file_list_hdl,'value'));

   progress_hdl = rri_progress_ui('initialize', 'Searching PLS path, please wait ...');

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   path_lst = {};

   for i = 1:length(file_list)

      filename = fullfile(dir_name, file_list{i});

      msg = ['Working on file: ', filename];
      rri_progress_ui(progress_hdl, '', msg);
      rri_progress_ui(progress_hdl, '', i/length(file_list));

      if ~isempty(findstr('PETsession.mat', filename))

         load(filename, 'session_info');

         path_lst = [path_lst; {session_info.pls_data_path}];

         for j = 1:session_info.num_subjects
            path_lst = [path_lst; {session_info.subject{j}}];
         end

      elseif ~isempty(findstr('PETdatamat.mat', filename))

         load(filename, 'session_info','session_file');

         path_lst = [path_lst; {session_info.pls_data_path}];

         for j = 1:session_info.num_subjects
            path_lst = [path_lst; {session_info.subject{j}}];
         end

         path_lst = [path_lst; {fileparts(session_file)}];

      elseif ~isempty(findstr('PETresult.mat', filename))

         load(filename, 'datamat_files');

         for j = 1:length(datamat_files)
            path_lst = [path_lst; {fileparts(datamat_files{j})}];
         end

      elseif ~isempty(findstr('fMRIsession.mat', filename))

         load(filename, 'session_info');

         path_lst = [path_lst; {session_info.pls_data_path}];

         for j = 1:session_info.num_runs
            path_lst = [path_lst; {session_info.run(j).data_path}];
         end

      elseif ~isempty(findstr('fMRIdatamat.mat', filename))

         load(filename, 'st_sessionFile');

         path_lst = [path_lst; {fileparts(st_sessionFile)}];

      elseif ~isempty(findstr('fMRIresult.mat', filename))

         load(filename, 'SessionProfiles');

         for i = 1:length(SessionProfiles)
            for j = 1:length(SessionProfiles{i})
               path_lst = [path_lst; {fileparts(SessionProfiles{i}{j})}];
            end
         end

      elseif ~isempty(findstr('BfMRIsession.mat', filename))

         load(filename, 'session_info');

         path_lst = [path_lst; {session_info.pls_data_path}];

         for j = 1:session_info.num_runs
            path_lst = [path_lst; {session_info.run(j).data_path}];
         end

      elseif ~isempty(findstr('BfMRIdatamat.mat', filename))

         load(filename, 'st_sessionFile');

         path_lst = [path_lst; {fileparts(st_sessionFile)}];

      elseif ~isempty(findstr('BfMRIresult.mat', filename))

         load(filename, 'SessionProfiles');

         for i = 1:length(SessionProfiles)
            for j = 1:length(SessionProfiles{i})
               path_lst = [path_lst; {fileparts(SessionProfiles{i}{j})}];
            end
         end

      elseif ~isempty(findstr('ERPsession.mat', filename))

         load(filename, 'session_info');

         path_lst = [path_lst; {session_info.pls_data_path}];

         for j = 1:session_info.num_subjects
            path_lst = [path_lst; {session_info.subject{j}}];
         end

      elseif ~isempty(findstr('ERPdatamat.mat', filename))

         load(filename, 'session_info','session_file','datafile');

         path_lst = [path_lst; {session_info.pls_data_path}];

         for j = 1:session_info.num_subjects
            path_lst = [path_lst; {session_info.subject{j}}];
         end

         path_lst = [path_lst; {fileparts(session_file)}];
         path_lst = [path_lst; {fileparts(datafile)}];

      elseif ~isempty(findstr('ERPresult.mat', filename))

         load(filename, 'datamat_files');

         for j = 1:length(datamat_files)
            path_lst = [path_lst; {fileparts(datamat_files{j})}];
         end

      end

   end			% for i=1:length(filt_list)

   set(gcf,'Pointer',old_pointer);		% Put 'Arrow' pointer back

   close(progress_hdl);

   %  display select window
   %
   oldpath = rri_getselectstr(unique(sort(path_lst)));

   if ~isempty(oldpath)
      set(old_path_edit_hdl,'string',oldpath);
   end

   return;					% click_select

