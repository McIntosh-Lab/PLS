function [selected_dir] = rri_getdirectory(varargin)

   if nargin == 0 | ~ischar(varargin{1}) 

      if (nargin == 0),
         dir_name = '';
      else
         dir_name = varargin{1}{1};
      end;

      init(dir_name);
      uiwait;                           % wait for user finish

      cd (getappdata(gcf,'StartDirectory'));
      selected_dir = getappdata(gcf,'SelectedDirectory');

      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = varargin{1};

   if strcmp(action,'CreateEditDirectory'),
      dir_name = pwd;
      if isempty(dir_name),
         set(gcbo,'String',filesep);
      else
         set(gcbo,'String',dir_name);
      end;
   elseif strcmp(action,'CreateDirectoryList'),
      dir_name = pwd;
      if isempty(dir_name),
         dir_name = filesep;
      end;
      update_dirlist(dir_name);
   elseif strcmp(action,'UpdateDirectoryList'),
      UpdateDirectoryList;
   elseif strcmp(action,'EditDirectory'),
      EditDirectory;
   elseif strcmp(action,'ResizeFigure'),
      SetObjectPositions;
   elseif strcmp(action,'DONE_BUTTON_PRESSED'),
      h = findobj(gcf,'Tag','DirectoryEdit');
      setappdata(gcf,'SelectedDirectory',get(h,'String'));
      uiresume;
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      setappdata(gcf,'SelectedDirectory',[]);
      uiresume;
   elseif strcmp(action,'DELETE_FIGURE'),
      delete_fig;
   end;

   return;


% --------------------------------------------------------------------
function init(dir_name),

   save_setting_status = 'on';
   rri_getdirectory_pos = [];

   try
      load('pls_profile');
   catch
   end

   try
      load('rri_pos_profile');
   catch
   end

   if ~isempty(rri_getdirectory_pos) & strcmp(save_setting_status,'on')

      pos = rri_getdirectory_pos;

   else

      w = 0.4;
      h = 0.6;
      x = (1-w)/2;
      y = (1-h)/2;
      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name','Get Directory', ...
        'MenuBar','none', ...
        'NumberTitle','off', ...
	'deletefcn','rri_getdirectory(''DELETE_FIGURE'');', ...
        'Position',pos, ...
        'Tag','GetDirectoryFigure', ...
        'ToolBar','none');

   if isempty(pwd)
      setappdata(h0,'StartDirectory',filesep);
   else
      setappdata(h0,'StartDirectory',pwd);
   end;

   if ~isempty(dir_name),
      try
         cd(dir_name);
      catch
         msg = 'ERROR: Invalid initial directory.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      end;
   end;

   x = 0.1;
   y = 0.9;
   w = 1-2*x;
   h = 0.06;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Directory Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit', 'normal', ...
        'FontSize',0.5, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Directories: ', ...
        'Tag','DirectoryLabel');

   y = 0.3;
   h = 0.6;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Directory Listbox
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit', 'normal', ...
        'FontSize',0.06, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', '', ...
        'CreateFcn','rri_getdirectory(''CreateDirectoryList'');', ...
        'Callback','rri_getdirectory(''UpdateDirectoryList'');', ...
        'Tag','DirectoryList');

   y = 0.2;
   h = 0.06;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Selected Directory Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit', 'normal', ...
        'FontSize',0.5, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','Selected Directory: ', ...
        'Tag','SelectedDirectoryLabel');

   y = 0.15;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Directory Edit
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
	'fontunit', 'normal', ...
        'FontSize',0.5, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String', '', ...
        'CreateFcn','rri_getdirectory(''CreateEditDirectory'');', ...
        'Callback','rri_getdirectory(''EditDirectory'');', ...
        'Tag','DirectoryEdit');

   y = 0.06;
   w = 0.3;
   h = 0.07;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % DONE
        'Units','normal', ...
	'fontunit', 'normal', ...
        'FontSize',0.5, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','DONE', ...
        'Callback','rri_getdirectory(''DONE_BUTTON_PRESSED'');', ...
        'Tag','DONEButton');

   x = 1-x-w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % CANCEL
        'Units','normal', ...
	'fontunit', 'normal', ...
        'FontSize',0.5, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','CANCEL', ...
        'Callback','rri_getdirectory(''CANCEL_BUTTON_PRESSED'');', ...
        'Tag','CANCELButton');

   x = 0.01;
   y = 0;
   w = 1;
   h = 0.06;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...               % Message Line
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ForegroundColor',[0.8 0.0 0.0], ...
	'fontunit', 'normal', ...
        'FontSize',0.5, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','', ...
        'Tag','MessageLine');
 
   return;					% Init


% --------------------------------------------------------------------
function SetEditAlignment()

   h = findobj(gcf,'Tag','DirectoryEdit');
   set(h,'Units','characters');

   pos = get(h,'Position'); 

   dir_name = get(h,'String');
   len = length(dir_name);

   if (len > pos(3)),
      set(h,'HorizontalAlignment','right','String',dir_name);
   else
      set(h,'HorizontalAlignment','left','String',dir_name);
   end;

   set(h,'Units','normal');

   return;					% SetEditAlignment


% --------------------------------------------------------------------
function EditDirectory()

   filter_path = get(gcbo,'String');
   if isempty(filter_path),
       filter_path = pwd;
       if isempty(filter_path)
          filter_path = filesep;
       end

       set(h,filter_path);
   end;

   try
       cd (filter_path);
   catch
       msg = 'Invalid directory';
       uiwait(msgbox(msg,'Error','modal'));
       return;
   end;
   
   update_dirlist(filter_path);

   return;					% EditDirectory


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
       msg = 'Cannot access the directory';
       uiwait(msgbox(msg,'Error','modal'));
       return;
   end;

   if isempty(pwd)
      curr_dir = filesep;
   else
      curr_dir = pwd;
   end;

   h = findobj(gcf,'Tag','DirectoryEdit');
   set(h,'String',curr_dir);
   SetEditAlignment;
   update_dirlist(curr_dir);

   return;					% UpdateDirectoryList


% --------------------------------------------------------------------
function update_dirlist(filter_path);

   dir_struct = dir(filter_path);
   if isempty(dir_struct)
       msg = 'Directory not found!';
       uiwait(msgbox(msg,'Error','modal'));
       return;
   end;
   
   dir_list = dir_struct(find([dir_struct.isdir] == 1));
   [sorted_dir_names,sorted_dir_index] = sortrows({dir_list.name}');
     
   h = findobj(gcf,'Tag','DirectoryList');
   set(h,'String',sorted_dir_names,'Value',1);
   
   return;


% --------------------------------------------------------------------
function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      rri_getdirectory_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'rri_getdirectory_pos');
   catch
   end

   try
      load('rri_pos_profile');
      rri_pos_profile = which('rri_pos_profile.mat');

      rri_getdirectory_pos = get(gcbf,'position');

      save(rri_pos_profile, '-append', 'rri_getdirectory_pos');
   catch
   end

   return;

