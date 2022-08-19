function selected_item = rri_getitem1(varargin)
%
%  USAGE: selected_item = rri_getitem1(fig_title, path, pattern, old_item)
%
%  Example:
%
%  selected_item = rri_getitem1('Select a subject','/data','*gm.nii','subject2*')
%
%  See also RRI_GETFILE1.
%

   if nargin == 0 | ischar(varargin{1}) 	% create rri_getitem1 figure

      selected_item = [];
      dir_name = pwd;
      if isempty(dir_name)
         dir_name = filesep;
      end

      filter_pattern = '*';
      old_item = [];

      if (nargin == 0),
         fig_title = 'Select a subject';
      else
         fig_title = varargin{1};
         if (nargin > 1), dir_name = varargin{2};       end;
         if (nargin > 2), filter_pattern = varargin{3}; end;
         if (nargin > 3), old_item = varargin{4}; end;
      end;

      init(fig_title,dir_name,filter_pattern,old_item);
      uiwait;                           % wait for user finish

      h = findobj(gcf,'Tag','FileList');
      list_files = get(h,'String');

      if isempty(list_files)
         selected_item = [];
      else
         selected_idx = get(h,'Value');

         if length(selected_idx) > 1
            selected_item = {list_files{selected_idx}};
         else
            selected_item = list_files{selected_idx};
         end
      end;

      cd (getappdata(gcf,'StartDirectory'));

      close(gcf);
      return;
   end;


   action = varargin{1}{1};

   if strcmp(action,'CreateEditFilter'),
      filter_pattern = getappdata(gcf,'FilterPattern');
      dir_name = pwd;
      if isempty(dir_name),
         dir_name = filesep;
      end;

      set(gcbo,'String',fullfile(dir_name, filter_pattern));
   elseif strcmp(action,'UpdateDirectoryList'),
      UpdateDirectoryList;
   elseif strcmp(action,'UpdateFileList'),
      UpdateFileList;
   elseif strcmp(action,'EditFilter'),
      EditFilter;
   elseif strcmp(action,'delete_fig'),
      delete_fig;
   elseif strcmp(action,'SELECT_BUTTON_PRESSED'),
      SelectAllFiles;
   elseif strcmp(action,'DONE_BUTTON_PRESSED'),
      h = findobj(gcf,'Tag','FilterEdit');
%      [filepath,filename,fileext] = fileparts(get(h,'String'));
%      setappdata(gcf,'SelectedDirectory',filepath);
%      setappdata(gcf,'FilterPattern',[filename fileext]);
      uiresume;
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      setappdata(gcf,'SelectedDirectory',[]);
      setappdata(gcf,'FilterPattern',[]);
      set(findobj(gcf,'Tag','FileList'),'String','');
      uiresume;
   end;

   return;


% --------------------------------------------------------------------
function init(fig_title,dir_name,filter_pattern,old_item),

   StartDirectory = pwd;
   if isempty(StartDirectory),
       StartDirectory = filesep;
   end;

   save_setting_status = 'on';
   rri_getitem1_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(rri_getitem1_pos) & strcmp(save_setting_status,'on')

      pos = rri_getitem1_pos;

   else

      w = 0.3;
      h = 0.4;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('parent',0, 'Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name',fig_title, ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Position', pos, ...
        'deleteFcn','rri_getitem1({''delete_fig''});', ...
        'WindowStyle', 'modal', ...
	'interruptible', 'off', ...
	'busyaction', 'cancel', ...
        'Tag','GetFilesFigure', ...
        'ToolBar','none');

   x = 0.1;
   y = 0.8;
   w = 1-2*x;
   h = 0.1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % File Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit', 'normal', ...
        'FontSize', 0.5, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','File Name:', ...
        'Tag','FileLabel');

   y = 0.25;
   h = 0.55;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % File Listbox
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit', 'normal', ...
        'FontSize', 0.09, ...
        'Min',0, ...
        'Max',10, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', '', ...
        'Callback','rri_getitem1({''UpdateFileList''});', ...
        'Tag','FileList');

   y = 0.1;
   w = 0.3;
   h = 0.1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % DONE
        'Units','normal', ...
	'fontunit', 'normal', ...
        'FontSize', 0.5, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Select', ...
        'Callback','rri_getitem1({''DONE_BUTTON_PRESSED''});', ...
        'Tag','DONEButton');

   x = 1-x-w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % CANCEL
        'Units','normal', ...
	'fontunit', 'normal', ...
        'FontSize', 0.5, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Cancel', ...
        'Callback','rri_getitem1({''CANCEL_BUTTON_PRESSED''});', ...
        'Tag','CANCELButton');

   setappdata(gcf,'FilterPattern',filter_pattern);
   setappdata(gcf,'StartDirectory',StartDirectory);
   setappdata(gcf,'old_item',old_item);

   if ~isempty(dir_name),
      try
         cd(dir_name);
      catch
         msg = 'ERROR: Invalid directory.';
         msgbox(msg);
	 return;
      end;
   end;
   
   update_dirlist(dir_name);

   return;					% init


% --------------------------------------------------------------------
function UpdateFileList()

   selected_item = get(gcbo,'Value');

   h = findobj(gcf,'Tag','NumFiles');
   msg = sprintf('Selected Files: %d',length(selected_item));
   set(h,'String',msg);

   return;					% UpdateFileList


% --------------------------------------------------------------------
function update_dirlist(filter_path);

   filter_pattern = getappdata(gcf,'FilterPattern');
   old_item = getappdata(gcf,'old_item');

   dir_struct = dir(filter_path);
   if isempty(dir_struct)
       msg = 'ERROR: Directory not found!';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;

   dir_list = dir_struct(find([dir_struct.isdir] == 1));
   [sorted_dir_names,sorted_dir_index] = sortrows({dir_list.name}');

   dir_struct = dir([filter_path filesep filter_pattern]);
   if isempty(dir_struct)
      sorted_file_names = [];
      return;
   else
      file_list = dir_struct(find([dir_struct.isdir] == 0));
      [sorted_file_names,sorted_file_index] = sortrows({file_list.name}');
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');
   
   %  replace pattern with '*'
   %
   [p f] = fileparts(filter_pattern);
   f = strrep(f, '*', '');		% remove * in pattern
   sorted_file_names = strrep(sorted_file_names, f, '*');	% replace with '*'

   %  replace '.nii' or '.img' with '.*'
   %
   sorted_file_names = strrep(sorted_file_names, '.nii', '.*');
   sorted_file_names = strrep(sorted_file_names, '.img', '.*');

   if ischar(old_item) & iscell(sorted_file_names)
      file_value = strmatch(old_item, sorted_file_names);
   else
      file_value = [];
   end

   h = findobj(gcf,'Tag','FileList');

   if file_value
      set(h,'String',sorted_file_names,'Value',file_value);
   else
      set(h,'String',sorted_file_names,'Value',1);
   end

   set(gcf,'Pointer',old_pointer);

   return; 					% update_dirlist


% --------------------------------------------------------------------
function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      rri_getitem1_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'rri_getitem1_pos');
   catch
   end

   return;

