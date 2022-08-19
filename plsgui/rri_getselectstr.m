function [selected_dir] = rri_getselectstr(varargin)

   if nargin == 0 | ~ischar(varargin{1}) 

      if (nargin == 0),
         dir_str = {};
      else
         dir_str = varargin{1};
      end;

      init(dir_str);
      uiwait;                           % wait for user finish

      selected_dir = getappdata(gcf,'SelectedDirectory');

      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = varargin{1};

   if strcmp(action,'DONE_BUTTON_PRESSED'),
      h = findobj('tag','DirectoryList');
      SelectedDirectoryIdx = get(h, 'value');
      SelectedDirectoryList = get(h, 'string');

      if isempty(SelectedDirectoryList)
         setappdata(gcf,'SelectedDirectory','');
      else
         setappdata(gcf,'SelectedDirectory',SelectedDirectoryList{SelectedDirectoryIdx});
      end

      uiresume;
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      setappdata(gcf,'SelectedDirectory','');
      uiresume;
   elseif strcmp(action,'DELETE_FIGURE'),
      delete_fig;
   end;

   return;


% --------------------------------------------------------------------
function init(dir_str),

   save_setting_status = 'on';
   rri_getselectstr_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(rri_getselectstr_pos) & strcmp(save_setting_status,'on')

      pos = rri_getselectstr_pos;

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
	'deletefcn','rri_getselectstr(''DELETE_FIGURE'');', ...
        'Position',pos, ...
        'Tag','GetDirectoryFigure', ...
        'ToolBar','none');

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

   y = 0.18;
   h = 0.72;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Directory Listbox
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit', 'normal', ...
        'FontSize',0.05, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', dir_str, ...
        'Tag','DirectoryList');

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
        'Callback','rri_getselectstr(''DONE_BUTTON_PRESSED'');', ...
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
        'Callback','rri_getselectstr(''CANCEL_BUTTON_PRESSED'');', ...
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
function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      rri_getselectstr_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'rri_getselectstr_pos');
   catch
   end

   return;

