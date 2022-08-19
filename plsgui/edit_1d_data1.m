%  "edit_1d_data" is a GUI interface for draw_edit program. You can edit
%  the plotted 1-D data by picking any point on the curve and moving the
%  mouse freely. In "Data:" field, you can either provide a 1-D matrix,
%  or prepare your 1-D matrix in a text file and use load function (e.g.
%  load('my_1D_data.txt'), or a matlab function (e.g. log(1:10)). After 
%  the data is edited, the modified one can be saved for output if you 
%  click "Save", or the output will be empty if you click "Cancel".
%
%  Usage:  y = edit_1d_data(y, [title], [npts])
%
%	y:	A 1-D matrix, or obtained by load a 1-D text file, or
%		the result of a matlab function.
%
%	title:	Optional. The title of the GUI window. By default, it
%		is called "Edit Data".
%
%	npts:	Optional. If specified, input y will be interpolated
%		to the number of data points that you provided.
%
%  Example:	y = edit_1d_data([1 3 2 7 9]);
%		y = edit_1d_data(load('my_1D_data.txt'));
%		y = edit_1d_data(log(1:10), 'Log fxn', 15);
%
%  jimmy@rotman-baycrest.on.ca
%
%----------------------------------------------------------------------

function y = edit_1d_data(action, fig_title, npts)

   if ~exist('action', 'var')
      action = [];
   end

   if ~exist('fig_title', 'var')
      fig_title = 'Edit Data';
   end

   if ~exist('npts', 'var')
      npts = 0;
   end

   if ~iscell(action)
      if isnumeric(npts) & npts > 0 & ...
	~isempty(action) & (ischar(action) | isnumeric(action))

         if ischar(action)
            action = str2num(action);
            action = action(:);
         else
            action = action(:);
         end

         npts = npts(1);

         if length(action) ~= npts
            action = interp1([1:length(action)], action, linspace(1,length(action),npts));
         end
      end

      init(action, fig_title, npts);
      uiwait;

      y = getappdata(gcf, 'draw_edit_new_y');

      edit_1d_data_fig_hdl = getappdata(gcf, 'edit_1d_data_fig_hdl');

      if ~isempty(edit_1d_data_fig_hdl) & ishandle(edit_1d_data_fig_hdl)
         close(edit_1d_data_fig_hdl);
      end

      return;
   end

   switch action{1}
   case 'zoom'
      zoom_on_state = get(gcbo,'Userdata');

      if (zoom_on_state == 1)
         zoom on;
         set(gcbo,'Userdata',0,'String','Zoom off');
         set(gcbf,'pointer','crosshair');
      else
         zoom off;
         set(gcbo,'Userdata',1,'String','Zoom on');
         set(gcbf,'pointer','arrow');
      end
   case 'CANCEL_BUTTON_PRESSED'
      setappdata(gcf, 'draw_edit_new_y', getappdata(gcf, 'draw_edit_org_y'));
      uiresume;
   case 'DONE_BUTTON_PRESSED'
      uiresume;
   case 'UNDO_BUTTON_PRESSED'
      org_y = getappdata(gcf, 'draw_edit_org_y');
      old_y = getappdata(gcf, 'draw_edit_old_y');
      new_y = getappdata(gcf, 'draw_edit_new_y');
      ax_hdl = getappdata(gcf, 'ax_hdl');
      draw_edit1(old_y, ax_hdl);
      set(gca,'xgrid','on');
      set(gca,'ygrid','on');
      setappdata(gcf, 'draw_edit_org_y', org_y);
      setappdata(gcf, 'draw_edit_old_y', new_y);
      setappdata(gcf, 'draw_edit_new_y', old_y);
   case 'BROWSE_BUTTON_PRESSED'
      [f p] =uigetfile('*.*', 'Select a 1-D text data');
      if p==0, return; end

      field_hdl = getappdata(gcf, 'field_hdl');
      set(field_hdl,'string',['load(''' fullfile(p,f) ''')']);
      edit_1d_data1({'Change_Data'});
   case 'Change_Data'
      org_y = getappdata(gcf, 'draw_edit_org_y');
      old_y = getappdata(gcf, 'draw_edit_new_y');
      ax_hdl = getappdata(gcf, 'ax_hdl');
      field_hdl = getappdata(gcf, 'field_hdl');
      new_y = str2num(get(field_hdl,'string'));
      new_y = new_y(:);
      npts = getappdata(gcf, 'npts');

      if isnumeric(npts) & npts > 0
         npts = npts(1);

         if length(new_y) ~= npts
            new_y = interp1([1:length(new_y)], new_y, linspace(1,length(new_y),npts));
         end
      end

      draw_edit1(new_y, ax_hdl);
      set(gca,'xgrid','on');
      set(gca,'ygrid','on');
      setappdata(gcf, 'draw_edit_org_y', org_y);
      setappdata(gcf, 'draw_edit_old_y', old_y);
      set(field_hdl,'string','');
   end

   return;						% edit_1d_data

%----------------------------------------------------------------------

function init(action, fig_title, npts)

   w = 0.95;
   h = 0.88;
   x = (1-w)/2;
   y = (1-h)/2;
   pos = [x y w h];

   edit_1d_data_fig_hdl = figure('Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name',fig_title, ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Position',pos, ...
        'WindowStyle', 'modal', ...
	'interruptible', 'off', ...
	'busyaction', 'cancel', ...
        'ToolBar','none');

   x = 0.05;
   w = 1-2*x;
   y = 0.25;
   h = 0.69;

   pos = [x y w h];

   ax_hdl = axes('Parent',edit_1d_data_fig_hdl, ...
   	'Color',[1 1 1], ...
	'box', 'on', ...
   	'Position',pos);

   x = 0.05;
   h = 0.05;
   w = 0.05;
   y = y - 0.11;

   pos = [x y w h];

   h1 = uicontrol('Parent',edit_1d_data_fig_hdl, ...                    % Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','Data:');

   x = x + w + 0.01;
   w = 0.71 - x;

   pos = [x y w h];

   field_hdl = uicontrol('Parent',edit_1d_data_fig_hdl, ...               % Data Field
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String', '', ...
        'tooltipstring', 'e.g.: [1 3 2 7 9] or load(''my_1D_data.txt'') or log(1:10)', ...
        'Callback','edit_1d_data1({''Change_Data''});');

   x=0.77;
   w = 0.18;

   pos = [x y w h];

   browse_hdl = uicontrol('Parent',edit_1d_data_fig_hdl, ...               % Browse
        'Units','normal', ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Browse', ...
        'Callback','edit_1d_data1({''BROWSE_BUTTON_PRESSED''});');

   x = 0.05;
   y = 0.05;
   w = 0.18;

   pos = [x y w h];

   zoom_hdl = uicontrol('Parent',edit_1d_data_fig_hdl, ...                % Zoom
        'Units','normal', ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Zoom On', ...
        'Callback','edit_1d_data1({''zoom''});', ...
        'Userdata', 1);

   x = x + .24;
   pos = [x y w h];

   undo_hdl = uicontrol('Parent',edit_1d_data_fig_hdl, ...                % Undo
        'Units','normal', ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Undo', ...
        'Callback','edit_1d_data1({''UNDO_BUTTON_PRESSED''});');

   x = x + .24;
   pos = [x y w h];

   save_hdl = uicontrol('Parent',edit_1d_data_fig_hdl, ...                 % Save
        'Units','normal', ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Save', ...
        'Callback','edit_1d_data1({''DONE_BUTTON_PRESSED''});');

   x = x + .24;
   pos = [x y w h];

   cancel_hdl = uicontrol('Parent',edit_1d_data_fig_hdl, ...               % Cancel
        'Units','normal', ...
	'fontunit','point', ...
   	'FontSize',12, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','Cancel', ...
        'Callback','edit_1d_data1({''CANCEL_BUTTON_PRESSED''});');

   if ~isempty(action) & (ischar(action) | isnumeric(action))
      draw_edit1(action, ax_hdl);
      set(gca,'xgrid','on');
      set(gca,'ygrid','on');
   else
      setappdata(gcf, 'draw_edit_org_y', []);
      setappdata(gcf, 'draw_edit_old_y', []);
      setappdata(gcf, 'draw_edit_new_y', []);
   end

   setappdata(gcf, 'edit_1d_data_fig_hdl', edit_1d_data_fig_hdl);
   setappdata(gcf, 'ax_hdl', ax_hdl);
   setappdata(gcf, 'field_hdl', field_hdl);
   setappdata(gcf, 'zoom_hdl', zoom_hdl);
   setappdata(gcf, 'undo_hdl', undo_hdl);
   setappdata(gcf, 'save_hdl', save_hdl);
   setappdata(gcf, 'cancel_hdl', cancel_hdl);
   setappdata(gcf, 'npts', npts);

   return;						% init

%----------------------------------------------------------------

function reset_zoom(fig)

   old_handle_vis = get(fig, 'HandleVisibility');
   set(fig, 'HandleVisibility', 'on');

   zoom_hdl = getappdata(gcf, 'zoom_hdl');
   set(zoom_hdl, 'Userdata', 1, 'String', 'Zoom on');
   set(fig,'pointer','arrow');
   zoom off;

   ax_hdl = getappdata(gcf, 'ax_hdl');
   axes(ax_hdl);
   setappdata(get(gca,'zlabel'), 'ZOOMAxesData', ...
			[get(gca, 'xlim') get(gca, 'ylim')])
   zoom out;
   set(fig, 'HandleVisibility', old_handle_vis);

   return;					% reset_zoom

