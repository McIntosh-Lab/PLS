function [num_scans,selected_path,selected_files,filter_pattern] = ...
		fmri_getfiles(varargin)
%
%  USAGE: [selected_path,selected_files,filter_pattern] = ...
%             fmri_getfiles(fig_title,dirname,pattern,selected_files)
%
%  Allow user to select a set of files from a single directory. 
%
%  Example:
%
%    [num_scans,s_path,s_files] = ...
%		fmri_getfiles('Select Data File','/usr','*.img');
%
%
%  -- Created June 2001 by Wilkin Chau, Rotman Research Institute
%

   if nargin == 0 | ischar(varargin{1}) 	% create fmri_getfiles figure

      dir_name = '';
      filter_pattern = '*';
      selected_files = [];

      if (nargin == 0),
         fig_title = 'Select Files';
      else
         fig_title = varargin{1};
         if (nargin > 1), dir_name = varargin{2};       end;
         if (nargin > 2), filter_pattern = varargin{3}; end;
         if (nargin > 3), selected_files = varargin{4}; end;
      end;

      init(fig_title,dir_name,filter_pattern,selected_files);
      uiwait;                           % wait for user finish

      h = findobj(gcf,'Tag','FileList');
      list_files = get(h,'String');

      if isempty(list_files)
         selected_files = [];
      else
         selected_idx = get(h,'Value');
         selected_files = list_files(selected_idx);
      end;

      num_scans = getappdata(gcf,'NumScans');
      selected_path = getappdata(gcf,'SelectedDirectory');
      filter_pattern = getappdata(gcf,'FilterPattern');

      cd(getappdata(gcf,'StartDirectory'));

      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

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
      h = findobj(gcf,'Tag','NumFiles');
      NumFiles = get(h,'value');

      h = findobj(gcf,'Tag','NumScans');
      NumScans = get(h,'value');

      if (NumFiles==1 & NumScans>=1) | (NumFiles>1 & NumScans==NumFiles)
         h = findobj(gcf,'Tag','FilterEdit');
         [filepath,filename,fileext] = fileparts(get(h,'String'));
         setappdata(gcf,'NumScans',NumScans);
         setappdata(gcf,'SelectedDirectory',filepath);
         setappdata(gcf,'FilterPattern',[filename fileext]);
         uiresume;
      else
         msg = 'Accept only 1 multiple scan file or more single scan file.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      setappdata(gcf,'NumScans',[]);
      setappdata(gcf,'SelectedDirectory',[]);
      setappdata(gcf,'FilterPattern',[]);
      set(findobj(gcf,'Tag','FileList'),'String','');
      uiresume;
   end;

   return;


% --------------------------------------------------------------------
function init(fig_title,dir_name,filter_pattern,selected_files),

   StartDirectory = pwd;
   if isempty(StartDirectory),
       StartDirectory = filesep;
   end;

   save_setting_status = 'on';
   fmri_getfiles_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_getfiles_pos) & strcmp(save_setting_status,'on')

      pos = fmri_getfiles_pos;

   else

      w = 0.55;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('parent',0, 'Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name',fig_title, ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Position',pos, ...
        'deleteFcn','fmri_getfiles({''delete_fig''});', ...
        'WindowStyle', 'modal', ...
        'Tag','GetFilesFigure', ...
        'ToolBar','none');

   left_margin = 0.06;
   text_height = 0.06;

   x = left_margin;
   y = 0.9;
   w = 1 - x*2;
   h = text_height;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Filter Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
        'FontSize',.5, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','Filter', ...
        'Tag','FilterLabel');

   y = y-.06;

   pos = [x y w h];

   e_h = uicontrol('Parent',h0, ...            % Filter Edit
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
        'FontSize',.5, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String', '', ...
        'CreateFcn','fmri_getfiles({''CreateEditFilter''});', ...
        'Callback','fmri_getfiles({''EditFilter''});', ...
        'Tag','FilterEdit');

   y = y -.08;
   w = .5 - left_margin - .02;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Directory Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal',...
        'FontSize',.5, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Directories', ...
        'Tag','DirectoryLabel');

   x = .5;
   w = .5 - left_margin;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % File Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'fontunit','normal', ...
        'FontSize',.5, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Files', ...
        'Tag','FileLabel');

   x = left_margin;
   y = .25;
   w = .5 - left_margin - .02;
   h = .5;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Directory Listbox
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit','normal',...
        'FontSize',.06, ...
        'HorizontalAlignment','left', ...
        'Interruptible', 'off', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', '', ...
        'Value',[], ...
        'Callback','fmri_getfiles({''UpdateDirectoryList''});', ...
        'Tag','DirectoryList');

   x = .5;
   w = .5 - left_margin;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % File Listbox
        'Style','listbox', ...
        'Units','normal', ...
        'fontunit','normal', ...
        'FontSize',.06, ...
        'Min',0, ...
        'Max',10, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', '', ...
        'CreateFcn','fmri_getfiles({''CreateFileList''});', ...
        'Callback','fmri_getfiles({''UpdateFileList''});', ...
        'Tag','FileList');

   x = left_margin;
   y = y - .08;
   w = .3;
   h = text_height;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Number of Selected Files 
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
        'FontSize',.5, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', 'Selected Files: ', ...
	'value', [], ...
        'Tag','NumFiles');

   x = x + w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Number of Selected Scans 
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
        'FontSize',.5, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', 'Selected Scans: ', ...
	'value', [], ...
        'Tag','NumScans');

   w = .2;
   x = 1 - left_margin - w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % SELECT
        'Units','normal', ...
	'fontunit','normal',...
        'FontSize',.5, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Select All', ...
        'Callback','fmri_getfiles({''SELECT_BUTTON_PRESSED''});', ...
        'Tag','SELECTButton');

   x = left_margin + .15;
   y = y - .08;
   w = .2;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % DONE
        'Units','normal', ...
	'fontunit','normal',...
        'FontSize',.5, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','DONE', ...
        'Callback','fmri_getfiles({''DONE_BUTTON_PRESSED''});', ...
        'Tag','DONEButton');

   x = 1 - left_margin - .15 - w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % CANCEL
        'Units','normal', ...
	'fontunit','normal',...
        'FontSize',.5, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','CANCEL', ...
        'Callback','fmri_getfiles({''CANCEL_BUTTON_PRESSED''});', ...
        'Tag','CANCELButton');

   x = .01;
   y = 0;
   w = 1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Message Line
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ForegroundColor',[0.8 0.0 0.0], ...
	'fontunit','normal',...
   	'FontSize',.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Tag','MessageLine');

   setappdata(gcf,'FilterPattern',filter_pattern);
   setappdata(gcf,'StartDirectory',StartDirectory);


   if ~isempty(dir_name),
      try
         cd(dir_name);
      catch
         msg = 'Warning: Invalid directory.  Use current directory to start';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      end;
   end;
   
   dir_name = pwd;
   if isempty(dir_name)
      dir_name = filesep; 
   end;

   set(e_h,'String',fullfile(dir_name, filter_pattern));

   update_dirlist(dir_name);

   if isempty(pwd)
      curr_dir = filesep;
   else
      curr_dir = pwd;
   end;

   if ~isempty(selected_files) & exist(fullfile(curr_dir, selected_files{1}),'file')
      update_selection(selected_files);
   end;

   return;					% init


% --------------------------------------------------------------------
function SelectAllFiles()

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   h = findobj(gcf,'Tag','FileList');		% update selected list
   flist = get(h,'String');

   if isempty(pwd)
      curr_dir = filesep;
   else
      curr_dir = pwd;
   end;

   count = 0;

   for i = 1:length(flist)
      count = count+get_nii_frame(fullfile(curr_dir, flist{i}));
   end

   set(h,'Value',[1:length(flist)]);

   h = findobj(gcf,'Tag','NumFiles');		% update # of files selected
   set(h,'String',sprintf('Selected Files: %d',length(flist)),'value',length(flist));

   h = findobj(gcf,'Tag','NumScans');
   set(h,'String',sprintf('Selected Scans: %d',count),'value',count);

   set(gcf,'Pointer',old_pointer);

   return;					% SelectAllFiles


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

   set(h,'Units','points');

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
function UpdateFileList()

   if isempty(pwd)
      curr_dir = filesep;
   else
      curr_dir = pwd;
   end;

   selected_files = get(gcbo,'Value');
   flist=get(gco, 'string');

   count = 0;

   for i = 1:length(selected_files)
      count = count+get_nii_frame(fullfile(curr_dir, flist{selected_files(i)}));
   end

   h = findobj(gcf,'Tag','NumFiles');
   msg = sprintf('Selected Files: %d',length(selected_files));
   set(h,'String',msg,'value',length(selected_files));

   h = findobj(gcf,'Tag','NumScans');
   msg = sprintf('Selected Scans: %d',count);
   set(h,'String',msg,'value',count);

   return;					% UpdateFileList


% --------------------------------------------------------------------
function UpdateDirectoryList()


   listed_dir = get(gcbo,'String');
   selected_dir_idx = get(gcbo,'Value');
    
   selected_dir = listed_dir{selected_dir_idx};
   
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
   
   if isempty(pwd)
      curr_dir = filesep;
   else
      curr_dir = pwd;
   end;

   filter_pattern = getappdata(gcf,'FilterPattern');
   h = findobj(gcf,'Tag','FilterEdit');
   set(h,'String', fullfile(curr_dir, filter_pattern));

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
      flist = dir_struct(find([dir_struct.isdir] == 0));
      [sorted_file_names,sorted_file_index] = sortrows({flist.name}');
   end;

   h = findobj(gcf,'Tag','DirectoryList');
   set(h,'String',sorted_dir_names,'Value',1);
   
   h = findobj(gcf,'Tag','FileList');
   set(h,'String',sorted_file_names,'Value',[]);

   h = findobj(gcf,'Tag','NumFiles');
   set(h,'String','Selected Files: 0','value',0);

   h = findobj(gcf,'Tag','NumScans');
   set(h,'String','Selected Scans: 0','value',0);

   set(gcf,'Pointer',old_pointer);

   return; 					% update_dirlist

% --------------------------------------------------------------------
function update_selection(selected_files);

   if isempty(pwd)
      curr_dir = filesep;
   else
      curr_dir = pwd;
   end;

   h = findobj(gcf,'Tag','FileList');
   flist = get(h,'String');

   selected_idx = [];
   count = 0;

   for i=1:length(selected_files),
      isduplicate = 0;

      for j=1:length(flist),
         if strcmp(selected_files{i},flist{j})
            if any(ismember(selected_idx, j))
               isduplicate = 1;
            else
               selected_idx = [selected_idx j];
            end

            break;
         end;
      end;

      if ~isduplicate
         count = count + get_nii_frame(fullfile(curr_dir, selected_files{i}));
      end
   end;

   if ~isempty(selected_idx)
       first_selected = min(selected_idx); 
       set(h,'Value',selected_idx,'ListboxTop',first_selected);

       h = findobj(gcf,'Tag','NumFiles');
       set(h,'String',sprintf('Selected Files: %d',length(selected_idx)), ...
		'value',length(selected_idx));

       h = findobj(gcf,'Tag','NumScans');
       set(h,'String',sprintf('Selected Scans: %d',count),'value',count);
   end;

   return; 					% update_selection


% --------------------------------------------------------------------
function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      fmri_getfiles_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'fmri_getfiles_pos');
   catch
   end

   return;

