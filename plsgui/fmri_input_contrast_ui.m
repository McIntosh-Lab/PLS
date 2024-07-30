function contrast_fig = fmri_input_contrast_ui(varargin) 
% 
%  USAGE: contrast_fig = fmri_input_contrast_ui(contrasts,conditions,view_only) 
% 

   if nargin == 0 
      old_contrasts = [];
   end;

   if nargin == 0 | ~ischar(varargin{1})
      old_contrasts = [];
      conditions = [];
      view_only = 0;

      if (nargin >= 1) 
         old_contrasts = varargin{1};
      end;

      if (nargin >= 2) 
         conditions = varargin{2};
      end;

      if (nargin >= 3) 
         view_only = varargin{3};
      end;
      
      fig_hdl = init(old_contrasts,conditions,view_only);

      if nargout >= 1,
         contrast_fig = fig_hdl;
      end;
      
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   switch (action)
     case {'MENU_LOAD_CONTRASTS'},
	LoadContrasts;
        DisplayContrasts;
        UpdateSlider;
        ShowConditions;
     case {'MENU_SAVE_CONTRASTS'},
        DisplayContrasts;			% refresh the contrasts first
	SaveContrasts(0);
     case {'MENU_SAVE_AS_CONTRASTS'},
	SaveContrasts(1);
     case {'MENU_CLOSE_CONTRASTS'},
        if (CloseContrastInput == 1)
            close(gcbf);
        end;
     case {'DELETE_FIGURE'},
        DeleteFigure;
     case {'MENU_CLEAR_CONTRASTS'},
	ClearContrasts;
     case {'MENU_LOAD_CONDITIONS'},
	LoadConditions;
     case {'UPDATE_CONTRAST_NAME'},
        UpdateContrastName;
     case {'UPDATE_CONTRAST_VALUE'},
        UpdateContrastValue;
     case {'DELETE_CONTRAST'},
        DeleteContrast;
     case {'ADD_CONTRAST'},
        AddContrast;
     case {'PLOT_CONTRAST'},
        PlotContrast;
     case {'MOVE_SLIDER'},
        MoveSlider;
     case {'RESIZE_FIGURE'},
        ResizeFigure;
     otherwise
        disp(sprintf('ERROR: Unknown action "%s".',action));
   end;
   
   return;


%----------------------------------------------------------------------------
function fig_hdl = init(old_contrasts,conditions,view_only)

   curr_dir = pwd;

   save_setting_status = 'on';
   fmri_input_contrast_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_input_contrast_pos) & strcmp(save_setting_status,'on')

      pos = fmri_input_contrast_pos;

   else

      w = 0.75;
      h = 0.8;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','New Contrasts', ...
        'NumberTitle','off', ...
        'Doublebuffer', 'on', ...
   	'Position',pos, ...
   	'DeleteFcn','fmri_input_contrast_ui(''DELETE_FIGURE'');', ...
        'Menubar','none', ...
   	'Tag','InputContrast', ...
   	'ToolBar','none');

   %-------------------------- contrast --------------------------------

   x = 0.04;
   y = 0.38;
   w = 0.46;
   h = 0.57;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               	% Contrast Frame
        'Style','frame', ...
        'Units','normal', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
        'Position',pos, ...
        'Tag','ContrastFrame');

   x = x+.01;
   y = 0.88;
   w = 0.3;
   h = 0.05;

   pos = [x y w h];

   fnt = 0.6;

   c = uicontrol('Parent',h0, ...			% contrast label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
	'FontName', 'FixedWidth', ...
   	'FontAngle','italic', ...
   	'FontWeight','bold', ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Contrasts: ', ...
   	'Tag','ContrastTitleLabel');

   x = 0.05;
   y = 0.82;
   w = 0.03;

   pos = [x y w h];

   fnt = fnt-0.1;

   c_h1 = uicontrol('Parent',h0, ...		% contrast idx
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','1.', ...
   	'Tag','ContrastIdxLabel');

   x = x+w+.01;
   w = 0.24;

   pos = [x y w h];

   c_h2 = uicontrol('Parent',h0, ...		% contrast name 
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','edit string', ...
        'TooltipString','Enter the name of the contrast', ...
   	'Tag','ContrastNameEdit');

   x = x+w+.02;
   w = 0.1;

   pos = [x y w h];

   c_h3 = uicontrol('Parent',h0, ...		% contrast button
   	'Units','normal', ...
   	'ListboxTop',0, ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'Position',pos, ...
   	'String','Add', ...
   	'Tag','ADD/DELButton');

   x = .10;
   y = y - .05;
   w = 0.24;

   pos = [x y w h];

   c_h4 = uicontrol('Parent',h0, ...		% contrast value
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','contrast value', ...
        'TooltipString','Enter a series of contrast values', ...
   	'Tag','ContrastValueEdit');

   x = x+w+.01;
   w = 0.1;

   pos = [x y w h];

   c_h5 = uicontrol('Parent',h0, ...		% plot button
   	'Units','normal', ...
   	'ListboxTop',0, ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'Position',pos, ...
   	'String','Plot', ...
   	'Tag','PLOTButton');

   x = x+w+.02;
   y = 0.4;
   w = 0.03;
   h = 0.55;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% scroll bar
	'Style', 'slider', ...
   	'Units','normal', ...
   	'Min',1, ...
   	'Max',20, ...
   	'Value',20, ...
   	'Position',pos, ...
   	'Callback','fmri_input_contrast_ui(''MOVE_SLIDER'');', ...
   	'Tag','ContrastSlider');

   %-------------------------- condition list -----------------------------

   x = .54;
   y = 0.38;
   w = 0.42;
   h = 0.57;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               	% Condition Frame
        'Style','frame', ...
        'Units','normal', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
        'Position',pos, ...
        'Tag','ConditionFrame');
   	
   x = x+.01;
   y = 0.88;
   w = 0.3;
   h = 0.05;

   pos = [x y w h];

   fnt = fnt+0.1;

   c = uicontrol('Parent',h0, ...
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
	'FontName', 'FixedWidth', ...
   	'FontAngle','italic', ...
   	'FontWeight','bold', ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Conditions: ', ...
   	'Tag','ConditionTitleLabel');

   x = x+.03;
   y = .45;
   w = .34;
   h = .42;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               % condition list box
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',.06, ...              
        'HorizontalAlignment','left', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String','', ...
        'Tag','ConditionListBox');

   x = .01;
   y = 0;
   w = 1;
   h = .05;

   pos = [x y w h];

   fnt = fnt-0.1;

   h1 = uicontrol('Parent',h0, ...               % MessageLine
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ForegroundColor',[0.8 0.0 0.0], ...
	'fontunit','normal',...
        'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','', ...
        'Tag','MessageLine');

   %-------------------------- condition axes -----------------------------

   x = .08;
   y = .1;
   w = 1 - x*2;
   h = .22;

   pos = [x y w h];

   ax_hdl = axes('Parent',h0, ...
	 'units', 'normal', ...
	 'Position', pos, ...
	 'box','on', ...
	 'XTick',[], 'YTick', []);
	
   %---------------------------- figure menu ------------------------------

   h_file = uimenu('Parent',h0, ...
        'Label', '&File', ...
        'Tag', 'FileMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Load', ...
        'Callback','fmri_input_contrast_ui(''MENU_LOAD_CONTRASTS'');', ...
        'Tag', 'LoadContrasts');
   m1 = uimenu(h_file, ...
        'Label', '&Save', ...
        'Callback','fmri_input_contrast_ui(''MENU_SAVE_CONTRASTS'');', ...
        'Tag', 'SaveContrasts');
   m1 = uimenu(h_file, ...
        'Label', 'S&ave as', ...
        'Callback','fmri_input_contrast_ui(''MENU_SAVE_AS_CONTRASTS'');', ...
        'Tag', 'SaveAsContrasts');
   m1 = uimenu(h_file, ...
        'Label', '&Close', ...
        'Callback','fmri_input_contrast_ui(''MENU_CLOSE_CONTRASTS'');', ...
        'Tag', 'CloseContrasts');

   h_file = uimenu('Parent',h0, ...
        'Label', '&Edit', ...
        'Tag', 'EditMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Clear', ...
        'Callback','fmri_input_contrast_ui(''MENU_CLEAR_CONTRASTS'');', ...
        'Tag', 'ClearContrasts');

   h_file = uimenu('Parent',h0, ...
        'Label', '&Condition', ...
        'Tag', 'ConditionMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Load', ...
        'Callback','fmri_input_contrast_ui(''MENU_LOAD_CONDITIONS'');', ...
        'Tag', 'LoadConditions');

   % save handles for contrast#1
   contrast1_hdls = [c_h1,c_h2,c_h3,c_h4,c_h5];  	
   setappdata(h0,'Contrast_hlist',contrast1_hdls);

   contrast_template = copyobj_legacy(contrast1_hdls,h0);
   for i=1:length(contrast_template),
      set(contrast_template(i),'visible','off','Tag', sprintf('Template%d',i));
   end;

   setappdata(h0,'OldContrasts',old_contrasts);
   setappdata(h0,'CurrContrasts',old_contrasts);
   setappdata(h0,'ContrastTemplate',contrast_template);
   setappdata(h0,'ContrastHeight',.105);
   setappdata(h0,'TopContrastIdx',1);

   setappdata(h0,'ContrastFile','');
   setappdata(h0,'PlotAxes',ax_hdl);
   setappdata(h0,'ViewOnly',view_only);

   if isempty(conditions)
      LoadConditions;
   else
      ShowConditions;
   end;

   setappdata(h0,'Conditions',conditions);

   if (view_only),
      HideMenuEntries;
   end;
   
   SetupContrastRows;
   SetupSlider;
   CreateAddRow;
   DisplayContrasts;
   UpdateSlider;

   fig_hdl = h0;

   return;						% init


%----------------------------------------------------------------------------
function SetupContrastRows()

   contrast_template = getappdata(gcf,'ContrastTemplate');
   contrast_hdls = getappdata(gcf,'Contrast_hlist');
   contrast_h = getappdata(gcf,'ContrastHeight');
   a_hdls = getappdata(gcf,'AddRowHdls');

   button_pos = get(findobj(gcf,'Tag','ContrastFrame'),'Position');
   top_pos = get(contrast_hdls(1,1),'Position');

   rows = floor(( top_pos(2) - button_pos(2) ) / contrast_h);
   v_pos = top_pos(2) - [0:rows-1]*contrast_h;

   edit_name_cbf = 'fmri_input_contrast_ui(''UPDATE_CONTRAST_NAME'');';
   delete_cbf = 'fmri_input_contrast_ui(''DELETE_CONTRAST'');';
   edit_value_cbf = 'fmri_input_contrast_ui(''UPDATE_CONTRAST_VALUE'');';
   plot_cbf = 'fmri_input_contrast_ui(''PLOT_CONTRAST'');';

   nr = size(contrast_hdls,1);
   if (rows < nr)			% too many rows
      for i=rows+1:nr,
          delete(contrast_hdls(i,:)); 
      end;
      contrast_hdls = contrast_hdls(1:rows,:);
   else					% add new rows
      for i=nr+1:rows,
         new_c_hdls = copyobj_legacy(contrast_template,gcf);
         contrast_hdls = [contrast_hdls; new_c_hdls'];
      end;
   end;

   v = 'on';
   for i=1:rows,

      new_c_hdls = contrast_hdls(i,:);

      pos = get(contrast_hdls(1,1),'Position');
      pos(2) = v_pos(i);
      set(new_c_hdls(1),'String','?','Position',pos,'Visible',v, ...
			'UserData',i);

      pos = get(contrast_hdls(1,2),'Position');
      pos(2) = v_pos(i);
      set(new_c_hdls(2),'String','', 'Position',pos, 'Visible',v, ...
                        'UserData',i,'Callback',edit_name_cbf);

      pos = get(contrast_hdls(1,3),'Position');
      pos(2) = v_pos(i);
      set(new_c_hdls(3),'String','Delete','Position',pos,'Visible',v, ...
                        'UserData',i,'Callback',delete_cbf);

      pos = get(contrast_hdls(1,4),'Position');
      pos(2) = v_pos(i)-.05;
      set(new_c_hdls(4),'String','', 'Position',pos, 'Visible',v, ...
                        'UserData',i,'Callback',edit_value_cbf);

      pos = get(contrast_hdls(1,5),'Position');
      pos(2) = v_pos(i)-.05;
      set(new_c_hdls(5),'String','Plot','Position',pos,'Visible',v, ...
                        'UserData',i,'Callback',plot_cbf);

   end;

   %  set up for the Add row
   for i=1:length(a_hdls),
      new_pos = get(contrast_hdls(1,i),'Position');
      set(a_hdls(i),'Position',new_pos);
   end;

   setappdata(gcf,'Contrast_hlist',contrast_hdls);
   setappdata(gcf,'NumRows',rows);

   return;					% SetupContrastRows


%----------------------------------------------------------------------------
function DisplayContrasts()

   curr_contrast = getappdata(gcf,'CurrContrasts');
   top_contrast_idx = getappdata(gcf,'TopContrastIdx');
   contrast_hdls = getappdata(gcf,'Contrast_hlist');
   rows = getappdata(gcf,'NumRows');
   view_only = getappdata(gcf,'ViewOnly');

   num_contrast = length(curr_contrast);

   last_row = 0;
   contrast_idx = top_contrast_idx;
   for i=1:rows
      c_hdls = contrast_hdls(i,:);
      if (contrast_idx <= num_contrast),
         contrast_name = curr_contrast(contrast_idx).name;
         contrast_values = curr_contrast(contrast_idx).value;
         contrast_values_str = Number2String(contrast_values);

         set(c_hdls(1),'String',sprintf('%d.',contrast_idx),'Visible','on');
         set(c_hdls(2),'String',sprintf('%s',contrast_name),'Visible','on');
         if (view_only)
             set(c_hdls(3),'String','Delete','Visible','off');
         else
             set(c_hdls(3),'String','Delete','Visible','on');
         end;
         set(c_hdls(4),'String',contrast_values_str,'Visible','on');
         set(c_hdls(5),'String','Plot','Visible','on');


         contrast_idx = contrast_idx + 1;
         last_row = i;
      else
         set(c_hdls(1),'String','','Visible','off');
         set(c_hdls(2),'String','','Visible','off');
         set(c_hdls(3),'String','Delete','Visible','off');
         set(c_hdls(4),'String','','Visible','off');
         set(c_hdls(5),'String','Plot','Visible','off');
      end;
   end;

   %  display or hide the add row
   %
   if (last_row < rows) & (view_only ~= 1)
      row_idx = last_row+1;
      c_hdls = contrast_hdls(row_idx,:);
      pos = get(c_hdls(1),'Position');
      ShowAddRow(contrast_idx,pos(2),row_idx);
   else
      HideAddRow;
   end;

   %  display or hide the slider
   %
   if (top_contrast_idx ~= 1) | (last_row == rows)
     ShowSlider;
   else
     HideSlider;
   end;

   return;						% DisplayContrasts


%----------------------------------------------------------------------------
function CreateAddRow()

   contrast_template = getappdata(gcf,'ContrastTemplate');

   a_hdls = copyobj_legacy(contrast_template,gcf);

   set(a_hdls(1),'String','','Foreground',[0 0 0],'Visible','off', ...
                 'UserData',1);

   set(a_hdls(2),'String','< Contrast Name >','Enable','on', ...
		 'HorizontalAlignment','left', ...
                 'Foreground',[0 0 0], ...
                 'Background',[1 1 1],'Visible','off');

   set(a_hdls(3),'String','Add','Enable','on', 'Visible','off', ...
		     'Callback','fmri_input_contrast_ui(''ADD_CONTRAST'');');

   set(a_hdls(4),'String','< Contrast Values >','Enable','on', ...
		 'HorizontalAlignment','left', ...
                 'Foreground',[0 0 0], ...
                 'Background',[1 1 1],'Visible','off');

   set(a_hdls(5),'String','Plot','Enable','off','Visible','off','Callback','');

   setappdata(gcf,'AddRowHdls',a_hdls);

   return;						% CreateAddRow


%----------------------------------------------------------------------------
function ShowAddRow(contrast_idx,pos,row_idx)

   a_hdls = getappdata(gcf,'AddRowHdls');

   v_pos = [pos pos pos pos-.05 pos-.05];

   for j=1:length(a_hdls),
      new_pos = get(a_hdls(j),'Position'); 
      new_pos(2) = v_pos(j);

      set(a_hdls(j),'Position',new_pos);
      set(a_hdls(j),'Visible','on');
   end;

   set(a_hdls(2),'string','<Contrast Name>');
   set(a_hdls(4),'string','<Contrast Value>');

   set(a_hdls(1),'String',sprintf('%d.',contrast_idx),'UserData',row_idx);
   set(a_hdls(3),'UserData',row_idx);

   return;						% ShowAddRow


%----------------------------------------------------------------------------
function HideAddRow()

   a_hdls = getappdata(gcf,'AddRowHdls');
   for j=1:length(a_hdls),
      set(a_hdls(j),'Visible','off');
   end;

   return;						% HideAddRow


%----------------------------------------------------------------------------
function UpdateContrastName(contrast_idx)

   view_only = getappdata(gcf,'ViewOnly');

   curr_contrast = getappdata(gcf,'CurrContrasts');
   contrast_hdls = getappdata(gcf,'Contrast_hlist');

   row_idx = get(gcbo,'UserData');
   contrast_idx = str2num(get(contrast_hdls(row_idx,1),'String'));

   if (view_only),		% don't allow changing contrast name 
      set(gcbo,'String',curr_contrast(contrast_idx).name); 
      msg = 'ERROR: Contrast name cannot be changed.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   curr_contrast(contrast_idx).name = deblank(get(gcbo,'String'));

   setappdata(gcf,'CurrContrasts',curr_contrast);

   return;						% UpdateContrastName

%----------------------------------------------------------------------------
function UpdateContrastValue(contrast_idx)

   view_only = getappdata(gcf,'ViewOnly');

   curr_contrast = getappdata(gcf,'CurrContrasts');
   contrast_hdls = getappdata(gcf,'Contrast_hlist');
   conditions = getappdata(gcf,'Conditions');

   row_idx = get(gcbo,'UserData');
   contrast_idx = str2num(get(contrast_hdls(row_idx,1),'String'));

   if (view_only),		% don't allow changing contrast name 
      contrast_values = curr_contrast(contrast_idx).value;
      contrast_values_str = Number2String(contrast_values);
      set(gcbo,'String',contrast_values_str);

      msg = 'ERROR: Contrast values cannot be changed.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
   end;

   contrast_values = str2num(get(gcbo,'String'));

   if isempty(contrast_values)
      msg = 'ERROR: Invalid contrast values.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   if length(conditions) ~= length(contrast_values),
      msg = 'ERROR: The number of contrast values does not match the number of conditions.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;


   curr_contrast(contrast_idx).value = contrast_values;

   % verify the contrasts are linear independent
   %
   num_contrasts = length(curr_contrast);
   contrast_mat = []; 
   for i=1:num_contrasts;
     if ~isempty(curr_contrast(i).value) 
        contrast_mat = [contrast_mat; curr_contrast(i).value];
     end;
   end;

   if (rank(contrast_mat) ~= size(contrast_mat,1))
      msg = 'ERROR:  The specified contrast is not linear independent to the others.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   setappdata(gcf,'CurrContrasts',curr_contrast);

   PlotContrast;

   return;						% UpdateContrastValue


%----------------------------------------------------------------------------
function DeleteContrast()

   curr_contrast = getappdata(gcf,'CurrContrasts');
   contrast_hdls = getappdata(gcf,'Contrast_hlist');

   row_idx = get(gcbo,'UserData');
   contrast_idx = str2num(get(contrast_hdls(row_idx,1),'String'));

   mask = ones(1,length(curr_contrast));  mask(contrast_idx) = 0;
   idx = find(mask == 1);
   curr_contrast = curr_contrast(idx);

   setappdata(gcf,'CurrContrasts',curr_contrast);

   DisplayContrasts;
   UpdateSlider;

   return;						% DeleteContrast


%----------------------------------------------------------------------------
function AddContrast()

   conditions = getappdata(gcf,'Conditions');
   if isempty(conditions),
      msg = sprintf('Cannot add contrasts without loading conditions first.');
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   curr_contrast = getappdata(gcf,'CurrContrasts');
   old_contrast = curr_contrast;		% save, in case roll back

   rows = getappdata(gcf,'NumRows');
   a_hdls = getappdata(gcf,'AddRowHdls');

   contrast_idx = str2num(get(a_hdls(1),'String'));
   contrast_name = get(a_hdls(2),'String');
   contrast_value = get(a_hdls(4),'String');

   num_contrast = length(curr_contrast)+1;

%   curr_contrast(num_contrast).name = '';
%   curr_contrast(num_contrast).value = [];

   curr_contrast(num_contrast).name = contrast_name;
   curr_contrast(num_contrast).value = contrast_value;

   setappdata(gcf,'CurrContrasts',curr_contrast);

   UpdateContrastName2;
   err = UpdateContrastValue2;

   if err
      setappdata(gcf,'CurrContrasts',old_contrast);	% roll back
      return;
   end

   new_contrast_row = get(a_hdls(1),'UserData');

   if (new_contrast_row == rows),  	% the new contrast row is the last row
      top_contrast_idx = getappdata(gcf,'TopContrastIdx');
      setappdata(gcf,'TopContrastIdx',top_contrast_idx+1);
   end;

   DisplayContrasts;

   contrast_hdls = getappdata(gcf,'Contrast_hlist');
   if (new_contrast_row == rows),  	% the new contrast row is the last row
      set(gcf,'CurrentObject',contrast_hdls(rows-1,2));
   else
      set(gcf,'CurrentObject',contrast_hdls(new_contrast_row,2));
   end;

   UpdateSlider;

   return;						% AddContrasts


%----------------------------------------------------------------------------
function MoveSlider()

   slider_hdl = findobj(gcf,'Tag','ContrastSlider');
   curr_value = round(get(slider_hdl,'Value'));
   total_rows = round(get(slider_hdl,'Max'));

   top_contrast_idx = total_rows - curr_value + 1;

   setappdata(gcf,'TopContrastIdx',top_contrast_idx);

   DisplayContrasts;

   return;						% MoveSlider


%----------------------------------------------------------------------------
function SetupSlider()

   contrast_hdls = getappdata(gcf,'Contrast_hlist');
   top_pos = get(contrast_hdls(1),'Position');
   bottom_pos = get(contrast_hdls(end),'Position');

   slider_hdl = findobj(gcf,'Tag','ContrastSlider');
   pos = get(slider_hdl,'Position');
   pos(2) = bottom_pos(2);
   pos(4) = top_pos(2)+top_pos(4) - pos(2);
   set(slider_hdl,'Position', pos);

   return;						% SetupSlider


%----------------------------------------------------------------------------
function UpdateSlider()

   top_contrast_idx = getappdata(gcf,'TopContrastIdx');
   rows = getappdata(gcf,'NumRows');

   curr_contrast = getappdata(gcf,'CurrContrasts');
   num_contrast = length(curr_contrast);

   total_rows = num_contrast+1;
   slider_hdl = findobj(gcf,'Tag','ContrastSlider');

   if (num_contrast ~= 0)		% don't need to update when no contrast
      set(slider_hdl,'Min',1,'Max',total_rows, ...
                  'Value',total_rows-top_contrast_idx+1, ...
                  'Sliderstep',[1/(total_rows-1)-0.00001 1/(total_rows-1)]); 
   end;
   
   return;						% UpdateSlider


%----------------------------------------------------------------------------
function ShowSlider()

   slider_hdl = findobj(gcf,'Tag','ContrastSlider');
   set(slider_hdl,'visible','on'); 

   return;						% ShowSlider


%----------------------------------------------------------------------------
function HideSlider()

   slider_hdl = findobj(gcf,'Tag','ContrastSlider');
   set(slider_hdl,'visible','off'); 

   return;						% HideSlider


%----------------------------------------------------------------------------
function PlotContrast()

   ax_hdl = getappdata(gcf,'PlotAxes');
   
   curr_contrast = getappdata(gcf,'CurrContrasts'); 
   contrast_hdls = getappdata(gcf,'Contrast_hlist');
         
   row_idx = get(gcbo,'UserData');
   contrast_idx = str2num(get(contrast_hdls(row_idx,1),'String'));

   contrast_name = curr_contrast(contrast_idx).name;
   contrast_values = curr_contrast(contrast_idx).value;

   if isempty(contrast_values)
	return;
   end;

   axes(ax_hdl);

   min_x = 0.4;
   max_x = length(contrast_values)+0.6;
   min_y = min(contrast_values) - 0.2;
   max_y = max(contrast_values) + 0.2;

   bar(contrast_values);

   set(ax_hdl,'xgrid','on', 'ygrid','on',...
	      'XTick',[1:length(contrast_values)], ...
	      'XLim', [min_x max_x], 'YLim', [min_y max_y]);
   title(contrast_name);

   return;						% PlotContrast


%----------------------------------------------------------------------------
function ShowConditions()

   conditions = getappdata(gcf,'Conditions');
   num_conds = length(conditions);

   h = findobj(gcf,'Tag','ConditionListBox');
  
   cond_str = cell(1,num_conds);
   for i=1:num_conds,
      cond_str{i} = sprintf('%3d. %s',i,conditions{i});
   end;
   set(h,'String',cond_str);

   return;						% ShowConditions

%----------------------------------------------------------------------------
function status = ChkContrastModified()
%  status = 0  for cancel
%  status = 1  for ok
%

   status = 1;

   curr_contrasts = getappdata(gcf,'CurrContrasts');
   old_contrasts = getappdata(gcf,'OldContrasts');

   if (isequal(curr_contrasts,old_contrasts) == 0),    
      dlg_title = 'Session Information has been changed';
      msg = 'WARNING: The contrasts have been changed.  Do you want to save it?';
      response = questdlg(msg,dlg_title,'Yes','No','Cancel','Yes');

      switch response,
         case 'Yes'
 	      status = SaveContrasts(0);		
         case 'Cancel'
 	      status = 0;
      end; 
   end;

   return;						% ChkContrastModified


%----------------------------------------------------------------------------
function ClearContrasts()

   ax_hdl = getappdata(gcf,'PlotAxes');
   axes(ax_hdl);
   cla;

   setappdata(gcf,'OldContrasts',[]);
   setappdata(gcf,'CurrContrasts',[]);
   setappdata(gcf,'TopContrastIdx',1);

   DisplayContrasts;
   UpdateSlider;


   return;						% ClearContrasts

   
%----------------------------------------------------------------------------
function LoadContrasts()
   
   if ~isempty(getappdata(gcf,'OldContrasts'))
      if (ChkContrastModified == 0)
         return;                        % error
      end;
   end;
   
   [filename, pathname] = rri_selectfile( 'PLScontrast*.mat','Load a contrast file');
        
   if isequal(filename,0) | isequal(pathname,0)
      return;
   end;
   
   contrast_file = [pathname, filename];

   try
      contrast_info = load(contrast_file);
   catch
      msg = 'ERROR: Cannot load the contrasts.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   setappdata(gcf,'OldContrasts',contrast_info.pls_contrasts);
   setappdata(gcf,'CurrContrasts',contrast_info.pls_contrasts);
   setappdata(gcf,'Conditions',contrast_info.conditions);
   setappdata(gcf,'ContrastFile',contrast_file);
   setappdata(gcf,'TopContrastIdx',1);

   set(gcf,'Name',['Contrast File: ' contrast_file]);

   return;						% LoadContrasts
   

%----------------------------------------------------------------------------
function LoadConditions()
   

   if (ChkContrastModified == 0)
      return;                        % error
   end;
   
   [filename, pathname] = rri_selectfile( '*sessiondata.mat', ...
                                'Load conditions from a PLS session file');
        
   if isequal(filename,0) | isequal(pathname,0)
      return;
   end;
   
   session_file = [pathname, filename];

   try
      pls_session = load(session_file);
      conditions = pls_session.session_info.condition;
   catch
      msg = 'ERROR: Cannot load the conditions from the session file.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   setappdata(gcf,'Conditions',conditions);

   set(gcf,'Name','New Contrasts');

   ShowConditions;
   ClearContrasts;

   return;						% LoadConditions
   


%----------------------------------------------------------------------------
function status = SaveContrasts(save_as_flag)
%  save_as_flag = 0,  save to the loaded file
%  save_as_flag = 1,  save to a new file
%
   if ~exist('save_as_flag','var')
     save_as_flag = 0;
   end;


   pls_contrasts = getappdata(gcf,'CurrContrasts');
   conditions = getappdata(gcf,'Conditions');
   contrast_file = getappdata(gcf,'ContrastFile');

   if isempty(pls_contrasts),
      msg = 'ERROR: No contrast available to be saved.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   num_conds = length(conditions);
   num_contrasts = length(pls_contrasts);
   for i=1:num_contrasts,
      if (isempty(pls_contrasts(i).name))
         msg = 'ERROR: All contrasts must have name specified.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
	 return;
      end;
      if (isempty(pls_contrasts(i).value))
         msg = 'ERROR: All contrasts must have values specified.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
	 return;
      end;
   end;

   contrast_mat = []; 
   for i=1:num_contrasts;
	if ~isempty(pls_contrasts(i).value) 
           contrast_mat = [contrast_mat; pls_contrasts(i).value];
	end;
   end;

   if (rank(contrast_mat) ~= size(contrast_mat,1))
      msg = 'ERROR:  Contrasts are not lineaer independent.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
	
   end;

   if (save_as_flag == 1) | isempty(contrast_file)
      [filename, pathname] = ...
           rri_selectfile('PLScontrast*.mat','Save the Contrasts ');
      if isequal(filename,0)
         status = 0;
         return;
      end;
      contrast_file = fullfile(pathname,filename);
   end;

   try
      save (contrast_file, 'pls_contrasts', 'conditions');
   catch
      msg = sprintf('Cannot save contrasts to %s',contrast_file),
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      status = 0;
      return;
   end;

   [fpath, fname, fext] = fileparts(contrast_file);
   msg = sprintf('Contrasts have been saved into ''%s'' ',[fname, fext]);
   set(findobj(gcf,'Tag','MessageLine'),'String',msg);

   setappdata(gcf,'ContrastFile',contrast_file);
   setappdata(gcf,'OldContrasts',pls_contrasts);

   set(gcf,'Name',['Contrast File: ' contrast_file]);

   status = 1;

   return;                                              % SaveContrasts


%----------------------------------------------------------------------------
function status = CloseContrastInput()

   status = ChkContrastModified; 

   return;                                              % CloseContrastInput


%----------------------------------------------------------------------------
function status = DeleteFigure()

    link_figure = getappdata(gcbf,'LinkFigureInfo');

    try 
       rmappdata(link_figure.hdl,link_figure.name);
    end;

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       fmri_input_contrast_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'fmri_input_contrast_pos');
    catch
    end

    return;                                              % DeleteFigure


%----------------------------------------------------------------------------
function num_str = Number2String(numbers)
 
   if isempty(numbers),
      num_str = '';
      return;
   end;

   len = length(numbers);
   num = numbers(:);		% make sure it is a column vector;

   tmp_str = strjust(num2str(num),'left');
   num_str = deblank(tmp_str(1,:));
   for i=2:len,
      num_str = [num_str ' ' deblank(tmp_str(i,:))];
   end;

   return;						% Number2String


%----------------------------------------------------------------------------
function HideMenuEntries()

   set(findobj(gcf,'Tag','LoadContrasts'),'Visible','off');
   set(findobj(gcf,'Tag','SaveContrasts'),'Visible','off');
   set(findobj(gcf,'Tag','SaveAsContrasts'),'Visible','off');

   set(findobj(gcf,'Tag','EditMenu'),'Visible','off');
   set(findobj(gcf,'Tag','ConditionMenu'),'Visible','off');

   return;						% HideMenuEntries


%----------------------------------------------------------------------------
function UpdateContrastName2(contrast_idx)

   curr_contrast = getappdata(gcf,'CurrContrasts');
%   contrast_hdls = getappdata(gcf,'Contrast_hlist');
   a_hdls = getappdata(gcf,'AddRowHdls');

   row_idx = get(a_hdls(2),'UserData');
   contrast_idx = str2num(get(a_hdls(1),'String'));
   curr_contrast(contrast_idx).name = deblank(get(a_hdls(2),'String'));

   setappdata(gcf,'CurrContrasts',curr_contrast);

   return;						% UpdateContrastName


%----------------------------------------------------------------------------
function err = UpdateContrastValue2(contrast_idx)

   err = 0;
   curr_contrast = getappdata(gcf,'CurrContrasts');
   a_hdls = getappdata(gcf,'AddRowHdls');
   conditions = getappdata(gcf,'Conditions');

   row_idx = get(a_hdls(4),'UserData');
   contrast_idx = str2num(get(a_hdls(1),'String'));
   contrast_values = str2num(get(a_hdls(4),'String'));

   if isempty(contrast_values)
      msg = 'ERROR: Invalid contrast values.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      err = 1;
      return;
   end;

   if length(conditions) ~= length(contrast_values),
      msg = 'ERROR: The number of contrast values does not match the number of conditions.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      err = 1;
      return;
   end;


   curr_contrast(contrast_idx).value = contrast_values;

   % verify the contrasts are linear independent
   %
   num_contrasts = length(curr_contrast);
   contrast_mat = []; 
   for i=1:num_contrasts;
     if ~isempty(curr_contrast(i).value) 
        contrast_mat = [contrast_mat; curr_contrast(i).value];
     end;
   end;

   if (rank(contrast_mat) ~= size(contrast_mat,1))
      msg = 'ERROR:  The specified contrast is not linear independent to the others.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      err = 1;
      return;
   end;

   setappdata(gcf,'CurrContrasts',curr_contrast);

   err = PlotContrast2;

   return;						% UpdateContrastValue


%----------------------------------------------------------------------------
function err = PlotContrast2()

   err = 0;
   ax_hdl = getappdata(gcf,'PlotAxes');
   
   curr_contrast = getappdata(gcf,'CurrContrasts'); 
   a_hdls = getappdata(gcf,'AddRowHdls');
         
   row_idx = get(gcbo,'UserData');
   contrast_idx = str2num(get(a_hdls(1),'String'));

   contrast_name = curr_contrast(contrast_idx).name;
   contrast_values = curr_contrast(contrast_idx).value;

   if isempty(contrast_values)
        err = 1;
	return;
   end;

   axes(ax_hdl);

   min_x = 0.4;
   max_x = length(contrast_values)+0.6;
   min_y = min(contrast_values) - 0.2;
   max_y = max(contrast_values) + 0.2;

   bar(contrast_values);

   set(ax_hdl,'xgrid','on', 'ygrid','on',...
	      'XTick',[1:length(contrast_values)], ...
	      'XLim', [min_x max_x], 'YLim', [min_y max_y]);
   title(contrast_name);

   return;						% PlotContrast

