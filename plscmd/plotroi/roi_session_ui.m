function roi_session_ui(varargin)

   if nargin == 0
      if exist('plslog.m','file')
         plslog('Open ROI Session');
         plslog(pwd);
      end

      init;
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = varargin{1};

   switch action
   case 'flooded_file_radio'
      flooded_file_radio;
   case 'template_image_radio'
      template_image_radio;
   case 'flooded_file_edit'
      msg = 'Click the "Load" button to load Flooded Image File';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   case 'template_image_edit'
      msg = 'Click the "Load" button to load Template Image File';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   case 'template_location_edit'
      msg = 'Click the "Load" button to load ROI Seed Location File';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   case 'edit_compare_edit'
      msg = 'Click the "Load" button for bootstrap compare file';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   case 'select_roi_edit'
      msg = 'Click the "Select ROI" button to select ROI';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   case 'close'
      close(gcf);
   case 'flooded_file_browse'
      flooded_file_browse;
   case 'template_image_browse'
      template_image_browse;
   case 'template_location_browse'
      template_location_browse;
   case 'create_roi_flooded_file'
      create_roi_flooded_file;
   case 'edit_compare'
      edit_compare;
   case 'select_roi'
      select_roi;
   case 'max_value_edit'
      max_value_edit
   case 'min_value_edit'
      min_value_edit
   case 'lv_index_edit'
      lv_index_edit
   case 'threshold_edit'
      threshold_edit
   case 'saveas_fig'
      saveas_fig;
   case 'open_fig'
      open_fig;
   case 'reset1'
      reset1;
   case 'roi_plot'
      roi_plot;
   end;

   return;						% roi_session_ui


%----------------------------------------------------------------------------
function init

   w = 0.6;
   h = 0.7;
   x = (1-w)/2;
   y = (1-h)/2;

   pos = [x y w h];

   h0 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','Information to plot ROI', ...
        'NumberTitle','off', ...
        'Menubar', 'none', ...
   	'Position', pos, ...
	'buttondown','roi_session_ui(''fig'');', ...
	'Tag','EditSessionInformation', ...
   	'ToolBar','none');

   % numbers of inputing line excluding 'MessageLine'

   num_inputline = 10;
   factor_inputline = 1/(num_inputline+1);
   fnt = 12;

   x = 0.05;
   y = (num_inputline-4) * factor_inputline;
   w = 0.9;
   h = 4.5 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% radio frame
   	'Style','frame', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Position',pos, ...
   	'Tag','radio_frame');

   x = 0.1;
   y = (num_inputline-0.5) * factor_inputline;
   w = 0.05;
   h = 0.6 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% flooded file radio
   	'Style','radio', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'value',1, ...
	'callback','roi_session_ui(''flooded_file_radio'');', ...
   	'Tag','flooded_file_radio');

   x = x+w;
   y = y-0.01;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% flooded file label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Flooded Image File:', ...
	'enable', 'on', ...
   	'Tag','flooded_file_label');

   x = x+w;
   y = y+0.01;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% flooded file edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'ButtonDownFcn','roi_session_ui(''flooded_file_edit'');', ...
	'enable', 'inactive', ...
   	'Tag','flooded_file_edit');

   x = x+w+0.01;
   w = 0.12;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% flooded file browse
   	'Units','normal', ...
	'string', 'Load', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','roi_session_ui(''flooded_file_browse'');', ...
	'enable', 'on', ...
   	'Tag','flooded_file_browse');

   x = 0.15;
   y = (num_inputline-1.5) * factor_inputline -0.01;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% template location label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','ROI Seed Location File:', ...
	'enable', 'on', ...
   	'Tag','template_location_label');

   x = x+w;
   y = y+0.01;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% template location edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'ButtonDownFcn','roi_session_ui(''template_location_edit'');', ...
	'enable', 'inactive', ...
   	'Tag','template_location_edit');

   x = x+w+0.01;
   w = 0.12;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% template location browse
   	'Units','normal', ...
	'string', 'Load', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','roi_session_ui(''template_location_browse'');', ...
	'enable', 'on', ...
   	'Tag','template_location_browse');

   x = 0.1;
   y = (num_inputline-2.5) * factor_inputline;
   w = 0.05;
   h = 0.6 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% template image radio
   	'Style','radio', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','roi_session_ui(''template_image_radio'');', ...
   	'Tag','template_image_radio');

   x = x+w;
   y = y-0.01;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% template image label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Template Image File:', ...
	'enable', 'off', ...
   	'Tag','template_image_label');

   x = x+w;
   y = y+0.01;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% template image edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'ButtonDownFcn','roi_session_ui(''template_image_edit'');', ...
	'enable', 'off', ...
   	'Tag','template_image_edit');

   x = x+w+0.01;
   w = 0.12;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% template image browse
   	'Units','normal', ...
	'string', 'Load', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','roi_session_ui(''template_image_browse'');', ...
	'enable', 'off', ...
   	'Tag','template_image_browse');

   x = 0.3;
   y = (num_inputline-3.5) * factor_inputline -0.01;
   w = 0.35;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% create roi flooded file
   	'Units','normal', ...
	'string', 'Create Flooded Image File', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','roi_session_ui(''create_roi_flooded_file'');', ...
	'enable', 'off', ...
   	'Tag','create_roi_flooded_file');

   x = 0.15;
   y = (num_inputline-5) * factor_inputline;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% edit compare label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Bootstrap Compare File:', ...
	'enable', 'on', ...
   	'Tag','edit_compare_label');

   x = x+w;
   y = y+0.01;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% edit compare edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'ButtonDownFcn','roi_session_ui(''edit_compare_edit'');', ...
	'enable', 'inactive', ...
   	'Tag','edit_compare_edit');

   x = x+w+0.01;
   w = 0.12;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% edit compare
   	'Units','normal', ...
	'string', 'Load', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','roi_session_ui(''edit_compare'');', ...
	'enable', 'off', ...
   	'Tag','edit_compare');

   x = 0.15;
   y = (num_inputline-6) * factor_inputline;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% select roi label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Number of Selected ROI:', ...
	'enable', 'on', ...
   	'Tag','select_roi_label');

   x = x+w;
   y = y+0.01;
   w = 0.1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% select roi edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
   	'ButtonDownFcn','roi_session_ui(''select_roi_edit'');', ...
	'enable', 'inactive', ...
   	'Tag','select_roi_edit');

   x = x+w+0.01;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% select roi
   	'Units','normal', ...
	'string', 'Select ROIs', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','roi_session_ui(''select_roi'');', ...
	'enable', 'off', ...
   	'Tag','select_roi');

   x = 0.15;
   y = (num_inputline-7) * factor_inputline;
   w = 0.15;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% max value label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Max. Value:', ...
	'enable', 'on', ...
   	'Tag','max_value_label');

   x = x+w;
   y = y+0.01;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% max value edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
	'enable', 'on', ...
	'callback','roi_session_ui(''max_value_edit'');', ...
   	'Tag','max_value_edit');


   x = x+w+0.11;
   y = y-0.01;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% min value label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Min. Value:', ...
	'enable', 'on', ...
   	'Tag','min_value_label');

   x = x+w;
   y = y+0.01;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% min value edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
	'enable', 'on', ...
	'callback','roi_session_ui(''min_value_edit'');', ...
   	'Tag','min_value_edit');

   x = 0.15;
   y = (num_inputline-8) * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% LV index label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','LV Index:', ...
	'enable', 'on', ...
   	'Tag','lv_index_label');

   x = x+w;
   y = y+0.01;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% LV index edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','0', ...
	'enable', 'on', ...
	'callback','roi_session_ui(''lv_index_edit'');', ...
   	'Tag','lv_index_edit');

   x = x+w+0.11;
   y = y-0.01;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% threshold label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Threshold:', ...
	'enable', 'on', ...
   	'Tag','threshold_label');

   x = x+w;
   y = y+0.01;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% threshold edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
	'enable', 'on', ...
	'callback','roi_session_ui(''threshold_edit'');', ...
   	'Tag','threshold_edit');

   x = 0.15;
   y = (num_inputline-9) * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% title label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Title:', ...
	'enable', 'on', ...
   	'Tag','title_label');

   x = x+w;
   y = y+0.01;
   w = 0.25;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% title edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
	'enable', 'on', ...
   	'Tag','title_edit');

   x = x+w+0.06;
   w = 0.12;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% plot
   	'Units','normal', ...
	'string', 'Plot', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','roi_session_ui(''roi_plot'');', ...
	'enable', 'off', ...
   	'Tag','roi_plot');

   x = x+w+0.01;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% close
   	'Units','normal', ...
	'string', 'Close', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','roi_session_ui(''close'');', ...
	'enable', 'on', ...
   	'Tag','close');

   x = 0.01;
   y = 0;
   w = 1;
   h = 0.6 * factor_inputline;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Message Line
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ForegroundColor',[0.8 0.0 0.0], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Tag','MessageLine');

   %  menu bar
   %
   h_file = uimenu('Parent',h0, ...
	'Label', 'File', ...
	'Tag', 'FileMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Load information figure', ...
   	'Callback','roi_session_ui(''open_fig'');');
   m1 = uimenu(h_file, ...
        'Label', 'Save information figure', ...
   	'Callback','roi_session_ui(''saveas_fig'');');
   m1 = uimenu(h_file, ...
        'Label', 'Close', ...
        'separator', 'on', ...
	'callback','roi_session_ui(''close'');');

   roi_session_ui('reset1');

   return;						% init


%-------------------------------------------------------------------------------
function flooded_file_radio

   if get(findobj(gcf,'Tag','flooded_file_radio'),'Value') == 0	% click itself
      set(findobj(gcf,'Tag','flooded_file_radio'),'Value',1);
   else
      set(findobj(gcf,'Tag','template_image_radio'),'Value',0);

      set(findobj(gcf,'Tag','template_image_label'),'enable','off');
      set(findobj(gcf,'Tag','template_image_edit'),'enable','off','string','');
      set(findobj(gcf,'Tag','template_image_browse'),'enable','off');
      set(findobj(gcf,'Tag','create_roi_flooded_file'),'enable','off');

      set(findobj(gcf,'Tag','flooded_file_label'),'enable','on');
      set(findobj(gcf,'Tag','flooded_file_edit'),'enable','inactive','string','');
      set(findobj(gcf,'Tag','flooded_file_browse'),'enable','on');

      set(findobj(gcf,'Tag','template_image_edit'),'user','');
      set(findobj(gcf,'Tag','flooded_file_edit'),'user','');
   end

   roi_session_ui('reset1');

   return;						% flooded_file_radio


%-------------------------------------------------------------------------------
function template_image_radio

   if get(findobj(gcf,'Tag','template_image_radio'),'Value') == 0  % click itself
      set(findobj(gcf,'Tag','template_image_radio'),'Value',1);
   else
      set(findobj(gcf,'Tag','flooded_file_radio'),'Value',0);

      set(findobj(gcf,'Tag','flooded_file_label'),'enable','off');
      set(findobj(gcf,'Tag','flooded_file_edit'),'enable','off','string','');
      set(findobj(gcf,'Tag','flooded_file_browse'),'enable','off');
      set(findobj(gcf,'Tag','create_roi_flooded_file'),'enable','off');

      set(findobj(gcf,'Tag','template_image_label'),'enable','on');
      set(findobj(gcf,'Tag','template_image_edit'),'enable','inactive','string','');
      set(findobj(gcf,'Tag','template_image_browse'),'enable','on');

      set(findobj(gcf,'Tag','template_image_edit'),'user','');
      set(findobj(gcf,'Tag','flooded_file_edit'),'user','');
   end

   roi_session_ui('reset1');

   return;						% template_image_radio


%-------------------------------------------------------------------------------
function flooded_file_browse

   [fn, pn] = uigetfile('*.tif', 'Select a Flooded Image File');

   if isequal(fn, 0) | isequal(pn, 0)
      return;
   end;

   flooded_file = fullfile(pn, fn);

   set(findobj(gcf,'Tag','flooded_file_edit'),'string',fn);
   set(findobj(gcf,'Tag','flooded_file_edit'),'user',flooded_file);

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   flooded_image = imread(flooded_file);
   num_roi = flooded_image(find(flooded_image<150));
   num_roi = max(double(num_roi(:)))+1;

   for i=1:num_roi
      coord{i} = find(flooded_image==(i-1));
   end

   setappdata(gcf,'coord',coord);
   setappdata(gcf,'num_roi',num_roi);
   set(gcf,'Pointer',old_pointer);

   roi_session_ui('reset1');

   if ~isempty(get(findobj(gcf,'Tag','template_location_edit'),'user'))
      temp_loc_file = get(findobj(gcf,'Tag','template_location_edit'),'user');
      roi_name = read_ixy(temp_loc_file,1);

      if(size(roi_name,1) == num_roi)
         set(findobj(gcf,'Tag','edit_compare'),'enable','on');
      else
         set(findobj(gcf,'Tag','template_location_edit'),'user','','string','');
         msg = 'Wrong ROI seed location file';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      end
   end

   return;						% flooded_file_browse


%-------------------------------------------------------------------------------
function template_location_browse

   [fn, pn] = uigetfile('*.txt', 'Select an ROI Seed Location File');

   if isequal(fn, 0) | isequal(pn, 0)
      return;
   end;

   temp_loc_file = fullfile(pn, fn);

   set(findobj(gcf,'Tag','template_location_edit'),'string',fn);
   set(findobj(gcf,'Tag','template_location_edit'),'user',temp_loc_file);

   num_roi = getappdata(gcf,'num_roi');
   roi_name = read_ixy(temp_loc_file,1);

   if ~isempty(num_roi) & size(roi_name,1) ~= num_roi
      set(findobj(gcf,'Tag','template_location_edit'),'user','','string','');
      msg = 'Wrong ROI seed location file';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   roi_session_ui('reset1');

   if ~isempty(get(findobj(gcf,'Tag','flooded_file_edit'),'user'))
      set(findobj(gcf,'Tag','edit_compare'),'enable','on');
   end

   if ~isempty(get(findobj(gcf,'Tag','template_image_edit'),'user'))
      set(findobj(gcf,'Tag','create_roi_flooded_file'),'enable','on');
   end

   return;						% template_location_browse


%-------------------------------------------------------------------------------
function template_image_browse

   [fn, pn] = uigetfile('*.tif', 'Select a Template Image File');

   if isequal(fn, 0) | isequal(pn, 0)
      return;
   end;

   temp_image_file = fullfile(pn, fn);

   set(findobj(gcf,'Tag','template_image_edit'),'string',fn);
   set(findobj(gcf,'Tag','template_image_edit'),'user',temp_image_file);

   if ~isempty(get(findobj(gcf,'Tag','template_location_edit'),'user'))
      set(findobj(gcf,'Tag','create_roi_flooded_file'),'enable','on');
   end

   return;						% template_image_browse


%-------------------------------------------------------------------------------
function create_roi_flooded_file

   [fn, pn] = uiputfile('*.tif','Please input a flooded image file name to save');

   if isequal(fn, 0) | isequal(pn, 0)
      return;
   end;

   [tmp fn] = fileparts(fn);
   fn = [fn '.tif'];
   flooded_file = fullfile(pn, fn);

   fid = fopen(flooded_file,'w');

   if fid == -1
      msg = 'ERROR: Cannot save file';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   else
      fclose(fid);
   end

   temp_image_file = get(findobj(gcf,'Tag','template_image_edit'),'user');
   temp_image = double(imread(temp_image_file))+1;

   if size(temp_image,3) > 1
      temp_image = mean(temp_image,3);
   end

   %  gray(16) from 241
   %
   temp_image = (temp_image-min(temp_image(:)))*16/(max(temp_image(:))-min(temp_image(:)))+241;

   temp_loc_file = get(findobj(gcf,'Tag','template_location_edit'),'user');
   [roi_name, temp_loc] = read_ixy(temp_loc_file);

   flooded_image = uint8(roi_fill_map(temp_image, temp_loc) -1);

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   imwrite(flooded_image, flooded_file);
   num_roi = flooded_image(find(flooded_image<150));
   num_roi = max(double(num_roi(:)))+1;

   for i=1:num_roi
      coord{i} = find(flooded_image==(i-1));
   end

   setappdata(gcf,'coord',coord);
   setappdata(gcf,'num_roi',num_roi);
   set(gcf,'Pointer',old_pointer);

   set(findobj(gcf,'Tag','flooded_file_radio'),'Value',1);
   set(findobj(gcf,'Tag','template_image_radio'),'Value',0);
   set(findobj(gcf,'Tag','template_image_label'),'enable','off');
   set(findobj(gcf,'Tag','template_image_edit'),'enable','off','string','');
   set(findobj(gcf,'Tag','template_image_browse'),'enable','off');
   set(findobj(gcf,'Tag','create_roi_flooded_file'),'enable','off');
   set(findobj(gcf,'Tag','flooded_file_label'),'enable','on');
   set(findobj(gcf,'Tag','flooded_file_edit'),'enable','inactive','string',fn);
   set(findobj(gcf,'Tag','flooded_file_browse'),'enable','on');
   set(findobj(gcf,'Tag','edit_compare'),'enable','on');
   set(findobj(gcf,'Tag','template_image_edit'),'user','');
   set(findobj(gcf,'Tag','flooded_file_edit'),'user',flooded_file);

   return;						% create_roi_flooded_file


%-------------------------------------------------------------------------------
function edit_compare

   [fn, pn]=uigetfile('*.txt','Select Compare File');
        
   if isequal(fn, 0) | isequal(pn, 0)			% Cancel was clicked
      return;
   end;

   compare_file = fullfile(pn, fn);

   try
      compare = load(compare_file);
   catch						% cannot open file
      msg = ['ERROR: Could not open file'];
      msgbox(msg,'ERROR','modal');
      return;
   end

   temp_loc_file = get(findobj(gcf,'Tag','template_location_edit'),'user');
   roi_name = read_ixy(temp_loc_file,1);

   if size(compare,1) > size(roi_name,1)
      msg = 'Too many rows in compare file';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   set(findobj(gcf,'Tag','edit_compare_edit'),'string',fn,'user',compare);

   set(findobj(gcf,'Tag','select_roi_edit'),'user','','string','0');
   set(findobj(gcf,'Tag','select_roi'),'enable','on');

   set(findobj(gcf,'Tag','lv_index_edit'),'String','1','user',1);
   max_value1 = max(compare(:,1));
   set(findobj(gcf,'Tag','max_value_edit'),'String',num2str(max_value1),'user',max_value1);
   min_value1 = min(compare(:,1));
   set(findobj(gcf,'Tag','min_value_edit'),'String',num2str(min_value1),'user',min_value1);

   set(findobj(gcf,'Tag','threshold_edit'),'String','');
   set(findobj(gcf,'Tag','roi_plot'),'enable','off');

   return;						% edit_compare


%-------------------------------------------------------------------------------
function select_roi

   set(findobj(gcf,'Tag','threshold_edit'),'String','');
   set(findobj(gcf,'Tag','roi_plot'),'enable','off');

   old_selected_roi = get(findobj(gcf,'Tag','select_roi_edit'),'user');

   if isempty(old_selected_roi)
      old_selected_roi = '';
   end

   temp_loc_file = get(findobj(gcf,'Tag','template_location_edit'),'user');
   roi_name = read_ixy(temp_loc_file,1);

   selected_roi = roi_select(roi_name, old_selected_roi, 'Select ROIs (The order of "Selected ROI" must be the same as the one in compare file)');

   if isequal(selected_roi, old_selected_roi)
      return;
   end

   compare = get(findobj(gcf,'Tag','edit_compare_edit'),'user');

   if isempty(selected_roi) | size(selected_roi,1) ~= size(compare,1)
      msg = 'Selected ROI does not match ROI in compare file';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end   

   set(findobj(gcf,'Tag','select_roi_edit'),'user',selected_roi, ...
			'string',num2str(size(selected_roi,1)));

   return;						% select_roi


%-------------------------------------------------------------------------------
function lv_index_edit

   set(findobj(gcf,'Tag','threshold_edit'),'String','');
   set(findobj(gcf,'Tag','roi_plot'),'enable','off');
   old_lv = num2str(get(findobj(gcf,'Tag','lv_index_edit'),'user'));

   if(isempty(get(findobj(gcf,'Tag','edit_compare_edit'),'String')))
      msg = 'Load compare file first';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(findobj(gcf,'Tag','lv_index_edit'),'string',old_lv);
      return;
   end

   curr_lv = round(str2num(get(findobj(gcf,'Tag','lv_index_edit'),'String')));
   compare = get(findobj(gcf,'Tag','edit_compare_edit'),'user');

   if(size(compare,2)<curr_lv | curr_lv<1)
      msg = 'LV index should be positive integer and not exceed maximum LV in compare data';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(findobj(gcf,'Tag','lv_index_edit'),'string',old_lv);
      return;
   end

   set(findobj(gcf,'Tag','lv_index_edit'),'user',curr_lv);
   max_value1 = max(compare(:,curr_lv));
   set(findobj(gcf,'Tag','max_value_edit'),'String',num2str(max_value1),'user',max_value1);
   min_value1 = min(compare(:,curr_lv));
   set(findobj(gcf,'Tag','min_value_edit'),'String',num2str(min_value1),'user',min_value1);

   return;						% lv_index_edit


%-------------------------------------------------------------------------------
function threshold_edit

   if(isempty(get(findobj(gcf,'Tag','edit_compare_edit'),'String')))
      msg = 'Load compare file first';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(findobj(gcf,'Tag','threshold_edit'),'String','');
      set(findobj(gcf,'Tag','roi_plot'),'enable','off');
      return;
   end

   if(str2num(get(findobj(gcf,'Tag','threshold_edit'),'String'))<0)
      set(findobj(gcf,'Tag','threshold_edit'),'String', ...
	num2str(-1*str2num(get(findobj(gcf,'Tag','threshold_edit'),'String'))));
   end

if 0
   max_thresh = max( ...
	[abs(str2num(get(findobj(gcf,'Tag','max_value_edit'),'String'))), ...
	 abs(str2num(get(findobj(gcf,'Tag','min_value_edit'),'String')))]);

   if(str2num(get(findobj(gcf,'Tag','threshold_edit'),'String'))>=max_thresh)
      msg = 'Threshold is too large';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(findobj(gcf,'Tag','threshold_edit'),'String','');
      set(findobj(gcf,'Tag','roi_plot'),'enable','off');
      return;
   end
end

   selected_roi = get(findobj(gcf,'Tag','select_roi_edit'),'user');

   if ~isempty(selected_roi) & ~isempty(str2num(get(findobj(gcf,'Tag','threshold_edit'),'String')))
      set(findobj(gcf,'Tag','roi_plot'),'enable','on');
   else
      set(findobj(gcf,'Tag','roi_plot'),'enable','off');
   end

   return;						% threshold_edit


%-------------------------------------------------------------------------------
function saveas_fig

   [fn, pn] = uiputfile('*.fig','Save information figure');

   if isequal(fn, 0) | isequal(pn, 0)
      return;
   end;

   [tmp fn] = fileparts(fn);
   fn = [fn '.fig'];
   fig_file = fullfile(pn, fn);

   setappdata(gcf,'coord','');

   try
      saveas(gcf, fig_file);
   catch
      msg = 'ERROR: Cannot save file';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   return;						% saveas_fig


%-------------------------------------------------------------------------------
function open_fig

   [fn, pn] = uigetfile('*.fig','Load information figure');

   if isequal(fn, 0) | isequal(pn, 0)
      return;
   end;

   fig_file = fullfile(pn, fn);

   close(gcf);
   open(fig_file);

   set(findobj(gcf,'Tag','max_value_edit'),'enable','on', ...
	'ButtonDownFcn', '', ...
	'callback','roi_session_ui(''max_value_edit'');', ...
	'user',str2num(get(findobj(gcf,'Tag','max_value_edit'),'string')), ...
	'background',[1 1 1]);

   set(findobj(gcf,'Tag','min_value_edit'),'enable','on', ...
	'ButtonDownFcn', '', ...
	'callback','roi_session_ui(''min_value_edit'');', ...
	'user',str2num(get(findobj(gcf,'Tag','min_value_edit'),'string')), ...
	'background',[1 1 1]);

   flooded_file = get(findobj(gcf,'Tag','flooded_file_edit'),'user');

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   flooded_image = imread(flooded_file);
   num_roi = flooded_image(find(flooded_image<150));
   num_roi = max(double(num_roi(:)))+1;

   for i=1:num_roi
      coord{i} = find(flooded_image==(i-1));
   end

   setappdata(gcf,'coord',coord);
   set(gcf,'Pointer',old_pointer);

   return;						% open_fig


%-------------------------------------------------------------------------------
function reset1

   set(findobj(gcf,'Tag','edit_compare_edit'),'user',[],'string','');
   set(findobj(gcf,'Tag','edit_compare'),'enable','off');
   set(findobj(gcf,'Tag','select_roi_edit'),'user','','string','0');
   set(findobj(gcf,'Tag','select_roi'),'enable','off');
   set(findobj(gcf,'Tag','max_value_edit'),'user',[],'string','0');
   set(findobj(gcf,'Tag','min_value_edit'),'user',[],'string','0');
   set(findobj(gcf,'Tag','lv_index_edit'),'user',[],'String','0');
   set(findobj(gcf,'Tag','roi_plot'),'enable','off');

   return;						% reset1


%-------------------------------------------------------------------------------
function roi_plot

   lv = get(findobj(gcf,'Tag','lv_index_edit'),'user');
   compare = get(findobj(gcf,'Tag','edit_compare_edit'),'user');
   comparelv = compare(:,lv);

   roi.max_val = get(findobj(gcf,'Tag','max_value_edit'),'user');
   roi.min_val = get(findobj(gcf,'Tag','min_value_edit'),'user');

%   too_large = find(comparelv > max_val); comparelv(too_large) = max_val;
%   too_small = find(comparelv < min_val); comparelv(too_small) = min_val;

   roiselect = [str2num(get(findobj(gcf,'Tag','select_roi_edit'),'user'))]';
   threshold = str2num(get(findobj(gcf,'Tag','threshold_edit'),'String'));
   title = get(findobj(gcf,'Tag','title_edit'),'string');

   roi.comparelv = comparelv;
   roi.roiselect = roiselect;
   roi.threshold = threshold;
   roi.lv = lv;
   roi.title = deblank(title);

   roi.coord = getappdata(gcf,'coord');

   if isempty(roi.coord)
      flooded_file = get(findobj(gcf,'Tag','flooded_file_edit'),'user');
      flooded_image = imread(flooded_file);
      num_roi = flooded_image(find(flooded_image<150));
      num_roi = max(double(num_roi(:)))+1;

      for i=1:num_roi
         roi.coord{i} = find(flooded_image==(i-1));
      end

      setappdata(gcf,'coord',roi.coord);
   end

   temp_loc_file = get(findobj(gcf,'Tag','template_location_edit'),'user');
   roi.roi_name = read_ixy(temp_loc_file,1);

   flooded_file = get(findobj(gcf,'Tag','flooded_file_edit'),'user');
   roi.flooded_image = double(imread(flooded_file))+1;

   roi_plot_ui(roi);

   return;						% plot


%-------------------------------------------------------------------------------
function max_value_edit

   if(isempty(get(findobj(gcf,'Tag','edit_compare_edit'),'String')))
      msg = 'Load compare file first';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   lv = get(findobj(gcf,'Tag','lv_index_edit'),'user');
   compare = get(findobj(gcf,'Tag','edit_compare_edit'),'user');
   comparelv = compare(:,lv);

   old_val = num2str(get(findobj(gcf,'Tag','max_value_edit'),'user'));
   max_val = str2num(get(findobj(gcf,'Tag','max_value_edit'),'string'));
   min_val = get(findobj(gcf,'Tag','min_value_edit'),'user');

   if isempty(max_val) | max_val < min_val | max_val < max(comparelv)
      msg = 'Wrong Max. Value';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(findobj(gcf,'Tag','max_value_edit'),'string',old_val);
      return;
   else
      set(findobj(gcf,'Tag','max_value_edit'),'user',max_val);
   end

   return;						% max_value_edit


%-------------------------------------------------------------------------------
function min_value_edit

   if(isempty(get(findobj(gcf,'Tag','edit_compare_edit'),'String')))
      msg = 'Load compare file first';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   lv = get(findobj(gcf,'Tag','lv_index_edit'),'user');
   compare = get(findobj(gcf,'Tag','edit_compare_edit'),'user');
   comparelv = compare(:,lv);

   old_val = num2str(get(findobj(gcf,'Tag','min_value_edit'),'user'));
   max_val = get(findobj(gcf,'Tag','max_value_edit'),'user');
   min_val = str2num(get(findobj(gcf,'Tag','min_value_edit'),'string'));

   if isempty(min_val) | min_val > max_val | min_val > min(comparelv)
      msg = 'Wrong Min. Value';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(findobj(gcf,'Tag','min_value_edit'),'string',old_val);
      return;
   else
      set(findobj(gcf,'Tag','min_value_edit'),'user',min_val);
   end

   return;						% min_value_edit

