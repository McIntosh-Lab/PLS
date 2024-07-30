%  MATLAB changed their UIGETFILE & UIPUTFILE, which causes some of our
%  scripts no longer to be able to run on some platform with new version
%  of MATLAB (version 7 and above). Therefore, I created a simplified 
%  vesion of SELECTAFILE to work around this issue.
%
%  Usage:  [fname, pname] = selectafile(filter_pattern, fig_title)
%
function [selected_file, selected_dir] = selectafile(varargin)

   if nargin == 0 | ischar(varargin{1})

      start_dir = pwd;
      filter_pattern = '*.*';
      fig_title = 'Select a file';

      if nargin > 0
         filter_pattern = varargin{1};
         [p f e] = fileparts(filter_pattern);
         filter_pattern = [f e];

         try
            cd(p);
         catch
         end;
      end;

      if nargin > 1, fig_title = varargin{2}; end;

      selected_file = '';
      selected_dir = pwd;

      if isempty(selected_dir)
         selected_dir = filesep;
      else
         if ~isequal(selected_dir(end), filesep)
            selected_dir = [selected_dir filesep];
         end
      end

      if isempty(findstr(filter_pattern, '*')) & isempty(findstr(filter_pattern, '?'))
         selected_file = filter_pattern;
      end

      init(filter_pattern, fig_title, selected_file, selected_dir);
      uiwait;

      h = findobj(gcf,'Tag','FileNameEdit');
      selected_file = get(h,'String');
      selected_dir = getappdata(gcf,'selected_dir');

      if isempty(selected_file) | isempty(selected_dir)
         selected_file = 0;
         selected_dir = 0;
      else
         [p f e] = fileparts(selected_file);
         selected_file = [f e];

         if ~isempty(p)
            selected_dir = p;
         end

         if ~isequal(selected_dir(end), filesep)
            selected_dir = [selected_dir filesep];
         end
      end;

      cd(start_dir);
      close(gcf);
      return;
   end;

   action = upper(varargin{1}{1});

   if strcmp(action,'UPDATE_DIRECTORY_LIST'),
      UpdateDirectoryList;
   elseif strcmp(action,'UPDATE_DIR_NAME'),
      UpdateDirName;
   elseif strcmp(action,'EDIT_FILTER'),
      EditFilter;
   elseif strcmp(action,'DELETE_FIG')
      delete_fig;
   elseif strcmp(action,'DONE_BUTTON_PRESSED'),
      h = findobj(gcf,'Tag','FileNameEdit');
      selected_file = get(h,'String');

      if ~isempty(selected_file)
         uiresume;
      end;
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      setappdata(gcf,'selected_dir','');
      uiresume;
   end;

   return;


%--------------------------------------------------------------------
function init(filter_pattern, fig_title, selected_file, selected_dir)

   save_setting_status = 'on';
   selectafile_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(selectafile_pos) & strcmp(save_setting_status,'on')

      pos = selectafile_pos;

   else

      w = 0.6;
      h = 0.8;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name',fig_title, ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Position',pos, ...
        'DeleteFcn','selectafile({''DELETE_FIG''});', ...
        'WindowStyle', 'modal', ...
	'interruptible', 'off', ...
	'busyaction', 'cancel', ...
        'Tag','GetFilesFigure', ...
        'ToolBar','none');

   x = 0.08;
   w = 1-2*x;
   y = 0.32;
   h = 0.6;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % File/Directory Listbox
        'Style','listbox', ...
        'Units','normal', ...
	'Fontunit','point', ...
   	'FontSize',12, ...
 	'Min',0, ...
 	'Max',1, ...
        'BackgroundColor',[1 1 1], ...
        'HorizontalAlignment','left', ...
        'Interruptible', 'off', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', '', ...
        'Callback','selectafile({''UPDATE_DIRECTORY_LIST''});', ...
        'Tag','File/DirectoryList');

   x = 0.08;
   w = 0.11;
   y = 0.25;
   h = 0.04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Dir Name Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'Fontunit', 'point', ...
        'FontSize', 12, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Directory:', ...
        'Tag','DirNameLabel');

   x = x + w + 0.01;
   w = 0.92 - x;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Dir Name Edit
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
	'Fontunit', 'point', ...
        'FontSize', 12, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',selected_dir, ...
        'Callback','selectafile({''UPDATE_DIR_NAME''});', ...
        'Tag','DirNameEdit');

   x = 0.08;
   w = 0.11;
   y = y - 0.05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % File Name Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit', 'point', ...
        'FontSize', 12, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','File Name:', ...
        'Tag','FileNameLabel');

   x = x + w + 0.01;
   w = 0.92 - x;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % File Name Edit
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
	'fontunit', 'point', ...
        'FontSize', 12, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',selected_file, ...
        'Tag','FileNameEdit');

   x = 0.08;
   w = 0.11;
   y = y - 0.05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Filter Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','Filter:', ...
        'Tag','FilterLabel');

   x = x + w + 0.01;
   w = 0.92 - x;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Filter Edit
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String', filter_pattern, ...
        'Callback','selectafile({''EDIT_FILTER''});', ...
        'Tag','FilterEdit');

   x = 0.08;
   y = 0.08;
   h = 0.05;
   w = 0.2;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % DONE
        'Units','normal', ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Select', ...
        'Callback','selectafile({''DONE_BUTTON_PRESSED''});', ...
        'Tag','DONEButton');

   x = 1-x-w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % CANCEL
        'Units','normal', ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Cancel', ...
        'Callback','selectafile({''CANCEL_BUTTON_PRESSED''});', ...
        'Tag','CANCELButton');

   setappdata(gcf,'FilterPattern',filter_pattern);
   setappdata(gcf,'selected_dir',selected_dir);
   update_dirlist(selected_dir);

   return;					% Init


%--------------------------------------------------------------------
function UpdateDirectoryList()

   listed_dir = get(gcbo,'String');
   selected_dir_idx = get(gcbo,'Value');
   dir_info = get(gcbo,'Userdata');

   dir_entry = find([dir_info.is_dir(selected_dir_idx)] == 1);

   if isempty(dir_entry) 		% only file have been selected
      h = findobj(gcf,'Tag','FileNameEdit');
      set(h,'String',dir_info.names{selected_dir_idx});
      return;
   else
      h = findobj(gcf,'Tag','FileNameEdit');
      set(h,'String','');
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
   
   %  update directory
   %
   try 
      cd(selected_dir);
   catch
       msg = 'ERROR: Cannot access the directory';
       msgbox(msg,'Error');
       return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   selected_dir = pwd;
   if isempty(selected_dir)
      selected_dir = filesep;
   end

   if ~isequal(selected_dir(end), filesep)
      selected_dir = [selected_dir filesep];
   end

   h = findobj(gcf,'Tag','DirNameEdit');
   set(h,'String',selected_dir);

   setappdata(gcf,'selected_dir',selected_dir);
   update_dirlist(selected_dir);
   set(gcf,'Pointer',old_pointer);

   return;					% UpdateDirectoryList


%--------------------------------------------------------------------
function UpdateDirName()

   selected_dir = get(gcbo, 'string');

   if ~isequal(selected_dir(end), filesep)
      selected_dir = [selected_dir filesep];
      set(gcbo, 'string', selected_dir);
   end

   %  update directory
   %
   try 
      cd(selected_dir);
   catch
      msg = 'ERROR: Cannot access the directory';
      msgbox(msg,'Error');

      selected_dir = pwd;

      if ~isequal(selected_dir(end), filesep)
         selected_dir = [selected_dir filesep];
      end

      set(gcbo, 'string', selected_dir);
      return;
   end;

   setappdata(gcf,'selected_dir',selected_dir);
   update_dirlist(selected_dir);

   return;					% UpdateDirName


%--------------------------------------------------------------------
function update_dirlist(filter_path)

   dir_struct = dir(filter_path);

   if isempty(dir_struct)
       return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   if length(dir_struct) == 1
      [p f e] = fileparts(dir_struct.name);
      dir_struct.name = [f e];
   end
   
   dir_list = dir_struct(find([dir_struct.isdir] == 1));
   [sorted_dir_names,sorted_dir_index] = sortrows({dir_list.name}');

   filter_pattern = getappdata(gcf,'FilterPattern');

   lt = findstr(filter_pattern,'<');
   gt = findstr(filter_pattern,'>');

   if gt > lt
      filter_pattern = filter_pattern(gt+1:end);
   end

   filter_pattern = deblank(fliplr(deblank(fliplr(filter_pattern))));
   dir_struct = dir(fullfile(filter_path, filter_pattern));

   if isempty(dir_struct)
      sorted_file_names = '';
   else
      if length(dir_struct) == 1
         [p f e] = fileparts(dir_struct.name);
         dir_struct.name = [f e];
      end

      file_list = dir_struct(find([dir_struct.isdir] == 0));
      [sorted_file_names,sorted_file_index] = sortrows({file_list.name}');
   end;

   h = findobj(gcf,'Tag','File/DirectoryList');

   out_names = [sorted_dir_names; sorted_file_names];
   num_dir = length(sorted_dir_names);

   for i=1:num_dir
      out_names{i} = sprintf('[%s]',sorted_dir_names{i}); 
   end;

   dir_info.is_dir = zeros(1,length(out_names));
   dir_info.is_dir(1:num_dir) = 1;
   dir_info.names = [sorted_dir_names; sorted_file_names];

   set(h,'String',out_names,'Userdata',dir_info,'Value',1);   
   set(gcf,'Pointer',old_pointer);

   return; 					% update_dirlist


%--------------------------------------------------------------------
function EditFilter()

   filename = get(gcbo,'String');
   [filter_path,filter_name,filter_ext] = fileparts(filename);
   filter_pattern = [filter_name, filter_ext];
   setappdata(gcf,'FilterPattern',filter_pattern);

   if isempty(filter_path)
      filter_path = pwd;
   end

   update_dirlist(filter_path);

   return;					% EditFilter


%--------------------------------------------------------------------
function delete_fig

    try
       load('pls_profile');
       
       pls_profile = which('pls_profile.mat');

       selectafile_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'selectafile_pos');
    catch
    end

   return;

