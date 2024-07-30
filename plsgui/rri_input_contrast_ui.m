function designdata = rri_input_contrast_ui(varargin)

   if nargin == 0 
      old_contrasts = {};
   end;

   if nargin == 0 | ~ischar(varargin{1})
      prefix='PLS';
      pls_session='';
      cond_selection=[];
      num_groups = 0;
      nonrotatemultiblock = [];
      old_contrasts = {};
      conditions = [];
      view_only = 0;
      behavname = {};
      designdata = [];
      bscan = [];

      if (nargin >= 1) 
         prefix = varargin{1}{1};
      end;

      if (nargin >= 2) 
         pls_session = varargin{2};
      end;

      if (nargin >= 3) 
         cond_selection = varargin{3};
      end;

      if (nargin >= 4) 
         num_groups = varargin{4};
      end;

      if (nargin >= 5) 
         nonrotatemultiblock = varargin{5};
      end;

      if (nargin >= 6) 
         view_only = varargin{6};
      end;

      if (nargin >= 7) 
         behavname = varargin{7};
      end;

      if (nargin >= 8) 
         designdata = varargin{8};
      end;

      if (nargin >= 9) 
         bscan = varargin{9};
      end;

      if view_only & ~isempty(nonrotatemultiblock)
         num_cond = sum(cond_selection);
         Ti = ones(1, num_cond);
         num_bm = length(behavname);
         Bi = zeros(num_bm, num_cond);
         Bi(:,bscan) = 1;
         TBi = [Ti(:) ; Bi(:)];
         TBi = repmat(TBi, [1 num_groups]);
         TBi = TBi(:);
         tmp = zeros(length(TBi), size(designdata,2));
         tmp(find(TBi),:) = designdata;
         designdata = tmp;
      end

      designdata = init(old_contrasts,conditions,view_only,prefix,pls_session,...
		cond_selection,num_groups,nonrotatemultiblock,behavname,designdata);

      view_only = getappdata(gcf,'ViewOnly');

      if ~view_only
         uiwait;
         designdata = getappdata(gcf,'designdata');
         close(gcf);
      end

      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   switch (action)
     case {'MENU_LOAD_TEXT'},
        prefix=getappdata(gcf,'prefix');
	LoadText(prefix);
        DisplayContrasts;
        UpdateSlider;
        ShowGroups;
        ShowConditions;
     case {'MENU_SAVE_TEXT'},
        DisplayContrasts;			% refresh the contrasts first
        prefix=getappdata(gcf,'prefix');
	SaveText(prefix,0);
     case {'MENU_SAVE_AS_TEXT'},
        prefix=getappdata(gcf,'prefix');
	SaveText(prefix,1);
     case {'MENU_HELMERT_MATRIX'},
        HelmertMatrix;
        DisplayContrasts;
        UpdateSlider;
        ShowGroups;
        ShowConditions;
     case {'MENU_CLOSE_CONTRASTS'},
        if (CloseContrastInput == 1)
            [designdata status] = SaveText2;

            if(status)
               setappdata(gcf,'designdata',designdata);
               uiresume;
            end
        end;
     case {'DELETE_FIGURE'},
        DeleteFigure;
     case {'MENU_CLEAR_CONTRASTS'},
	ClearContrasts;
     case {'MENU_CANCEL_CONTRASTS'},
        designdata = getappdata(gcf,'designdata0');
        setappdata(gcf,'designdata',designdata);
        uiresume;
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
     case {'CHANGE_GROUP'},
	ChangeGroup;
     otherwise
        disp(sprintf('ERROR: Unknown action "%s".',action));
   end;
   
   return;


%----------------------------------------------------------------------------
function fig_hdl = init(old_contrasts,conditions,view_only,prefix,pls_session,...
			cond_selection,num_groups,nonrotatemultiblock,behavname,designdata)

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

      w = 0.8;
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
   	'DeleteFcn','rri_input_contrast_ui(''DELETE_FIGURE'');', ...
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
   	'String','Contrasts for Group 1: ', ...
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
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','edit string', ...
   	'Tag','ContrastNameEdit');
%	'TooltipString','Enter the name of the contrast', ...
%   	'Style','edit', ...
%   	'BackgroundColor',[1 1 1], ...

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
   	'Callback','rri_input_contrast_ui(''MOVE_SLIDER'');', ...
   	'Tag','ContrastSlider');

   %-------------------------- group list -----------------------------

   x = 0.54;
   y = 0.68;
   w = 0.42;
   h = 0.27;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               	% Group Frame
        'Style','frame', ...
        'Units','normal', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
        'Position',pos, ...
        'Tag','GroupFrame');
   	
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
   	'String','Groups: ', ...
   	'Tag','GroupTitleLabel');

   x = x+.03;
   y = .73;
   w = .34;
   h = .15;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               % group list box
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',.15, ...              
        'HorizontalAlignment','left', ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String','', ...
        'Callback','rri_input_contrast_ui(''CHANGE_GROUP'');', ...
        'Tag','GroupListBox');

   %-------------------------- condition list -----------------------------

   x = 0.54;
   y = 0.38;
   w = 0.42;
   h = 0.27;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               	% Condition Frame
        'Style','frame', ...
        'Units','normal', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
        'Position',pos, ...
        'Tag','ConditionFrame');
   	
   x = x+.01;
   y = 0.58;
   w = 0.3;
   h = 0.05;

   pos = [x y w h];

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
   y = .43;
   w = .34;
   h = .15;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               % condition list box
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',.15, ...
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
   y = .2;
   w = 1 - x*2;
   h = .12;

   pos = [x y w h];

   ax_hdl = axes('Parent',h0, ...
	 'units', 'normal', ...
	 'Position', pos, ...
	 'box','on', ...
	 'XTick',[], 'YTick', []);

   x = .2;
   y = .1;
   w = .1;
   h = .05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'ListboxTop',0, ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'Position',pos, ...
   	'String','OK', ...
        'Callback','rri_input_contrast_ui(''MENU_CLOSE_CONTRASTS'');', ...
   	'Tag','OKButton');

   x = (x+0.8)/2 - w/2;

   pos = [x y w h];


if view_only

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'ListboxTop',0, ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'Position',pos, ...
   	'String','Close', ...
        'Callback','close(gcf);');

   set(findobj(gcf,'Tag','OKButton'),'visible','off');

else

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'ListboxTop',0, ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'Position',pos, ...
   	'String','Clear', ...
        'Callback','rri_input_contrast_ui(''MENU_CLEAR_CONTRASTS'');', ...
   	'Tag','ClearButton');

   x = 1 - w - 0.2;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'ListboxTop',0, ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'Position',pos, ...
   	'String','Cancel', ...
        'Callback','rri_input_contrast_ui(''MENU_CANCEL_CONTRASTS'');', ...
   	'Tag','CancelButton');
end   
	
   %---------------------------- figure menu ------------------------------

if ~view_only
   h_file = uimenu('Parent',h0, ...
        'Label', '&File', ...
        'Tag', 'FileMenu');
   m1 = uimenu(h_file, ...
        'Label', '&Load', ...
        'Callback','rri_input_contrast_ui(''MENU_LOAD_TEXT'');', ...
        'Tag', 'LoadText');
   m1 = uimenu(h_file, ...
        'Label', '&Save', ...
        'Callback','rri_input_contrast_ui(''MENU_SAVE_TEXT'');', ...
        'Tag', 'SaveText');
   m1 = uimenu(h_file, ...
        'Label', 'S&ave as', ...
        'Callback','rri_input_contrast_ui(''MENU_SAVE_AS_TEXT'');', ...
        'Tag', 'SaveAsText');

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
           'Tag', 'Help');
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','rri_helpfile_ui(''rri_input_contrast_hlp.txt'',''How to use it'');', ...
	   'visible', 'off', ...
           'Tag', 'How');
   Hm_new = uimenu('Parent',Hm_topHelp, ...
           'Label', '&What''s new', ...
	   'Callback','rri_helpfile_ui(''whatsnew.txt'',''What''''s new'');', ...
           'Tag', 'New');
   Hm_about = uimenu('Parent',Hm_topHelp, ...
           'Label', '&About this program', ...
           'Tag', 'About', ...
           'CallBack', 'plsgui_version');
end

   pause(0.01)

   % save handles for contrast#1
   contrast1_hdls = [c_h1,c_h2,c_h3,c_h4,c_h5];  	
   setappdata(h0,'Contrast_hlist',contrast1_hdls);

   contrast_template = copyobj_legacy(contrast1_hdls,h0);
   for i=1:length(contrast_template),
      set(contrast_template(i),'visible','off','Tag', sprintf('Template%d',i));
   end;

   setappdata(h0,'prefix',prefix);
   setappdata(h0,'OldContrasts',old_contrasts);
   setappdata(h0,'CurrContrasts',old_contrasts);
   setappdata(h0,'ContrastTemplate',contrast_template);
   setappdata(h0,'ContrastHeight',.105);
   setappdata(h0,'TopContrastIdx',1);

   setappdata(h0,'ContrastFile','');
   setappdata(h0,'PlotAxes',ax_hdl);
   setappdata(h0,'ViewOnly',view_only);
   setappdata(h0,'num_groups',num_groups);

   SetupContrastRows;
   SetupSlider;
   CreateAddRow;
   DisplayContrasts;
   UpdateSlider;

   LoadConditions(prefix,pls_session,cond_selection,behavname,nonrotatemultiblock);

   if (view_only),
      HideMenuEntries;
   end;

   fig_hdl = h0;

   if ~isempty(designdata)
      LoadText2(designdata);
      DisplayContrasts;
      UpdateSlider;
      ShowGroups;
      ShowConditions;
   end

   setappdata(h0,'designdata',designdata);
   setappdata(h0,'designdata0',designdata);

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

   edit_name_cbf = 'rri_input_contrast_ui(''UPDATE_CONTRAST_NAME'');';
   delete_cbf = 'rri_input_contrast_ui(''DELETE_CONTRAST'');';
   edit_value_cbf = 'rri_input_contrast_ui(''UPDATE_CONTRAST_VALUE'');';
   plot_cbf = 'rri_input_contrast_ui(''PLOT_CONTRAST'');';

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

   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   if ~isempty(CurrContrast) & length(CurrContrast) >= g
      curr_contrast = CurrContrast{g};
   else
      curr_contrast = [];
   end

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

%   set(a_hdls(2),'String','< Contrast Name >','Enable','on', ...
   set(a_hdls(2),'String','','Enable','on', ...
		 'HorizontalAlignment','left', ...
                 'Foreground',[0 0 0], ...
                 'Background',[0.7 0.7 0.7],'Visible','off');
%                 'Background',[1 1 1],'Visible','off');

   set(a_hdls(3),'String','Add','Enable','on', 'Visible','off', ...
		     'Callback','rri_input_contrast_ui(''ADD_CONTRAST'');');

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

%   set(a_hdls(2),'string','<Contrast Name>');
   set(a_hdls(4),'string','<Contrast Value>');

   set(a_hdls(1),'String',sprintf('%d.',contrast_idx),'UserData',row_idx);
   set(a_hdls(2),'string',['Contrast ', num2str(contrast_idx)]);
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

   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   if ~isempty(CurrContrast) & length(CurrContrast) >= g
      curr_contrast = CurrContrast{g};
   else
      curr_contrast = [];
   end

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

   CurrContrast{g} = curr_contrast;
   setappdata(gcf,'CurrContrasts',CurrContrast);

   return;						% UpdateContrastName

%----------------------------------------------------------------------------
function UpdateContrastValue(contrast_idx)

   view_only = getappdata(gcf,'ViewOnly');

   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   if ~isempty(CurrContrast) & length(CurrContrast) >= g
      curr_contrast = CurrContrast{g};
   else
      curr_contrast = [];
   end

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

if 0	% verify before save
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
end

   CurrContrast{g} = curr_contrast;
   setappdata(gcf,'CurrContrasts',CurrContrast);

   PlotContrast;

   return;						% UpdateContrastValue


%----------------------------------------------------------------------------
function DeleteContrast()

   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   if ~isempty(CurrContrast) & length(CurrContrast) >= g
      curr_contrast = CurrContrast{g};
   else
      curr_contrast = [];
   end

   contrast_hdls = getappdata(gcf,'Contrast_hlist');

   row_idx = get(gcbo,'UserData');
   contrast_idx = str2num(get(contrast_hdls(row_idx,1),'String'));

   mask = ones(1,length(curr_contrast));  mask(contrast_idx) = 0;
   idx = find(mask == 1);
   curr_contrast = curr_contrast(idx);

   CurrContrast{g} = curr_contrast;
   setappdata(gcf,'CurrContrasts',CurrContrast);

   DisplayContrasts;
   UpdateSlider;

   return;						% DeleteContrast


%----------------------------------------------------------------------------
function AddContrast()

   conditions = getappdata(gcbf,'Conditions');

   if isempty(conditions),
      msg = sprintf('Cannot add contrasts without loading conditions first.');
      set(findobj(gcbf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   if ~isempty(CurrContrast) & length(CurrContrast) >= g
      curr_contrast = CurrContrast{g};
   else
      curr_contrast = [];
   end

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

   CurrContrast{g} = curr_contrast;
   setappdata(gcf,'CurrContrasts',CurrContrast);

   UpdateContrastName2;
   err = UpdateContrastValue2;

   if err
      CurrContrast{g} = old_contrast;
      setappdata(gcf,'CurrContrasts',CurrContrast);	% roll back
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

   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   if ~isempty(CurrContrast) & length(CurrContrast) >= g
      curr_contrast = CurrContrast{g};
   else
      curr_contrast = [];
   end

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
   
   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   if ~isempty(CurrContrast) & length(CurrContrast) >= g
      curr_contrast = CurrContrast{g};
   else
      curr_contrast = [];
   end

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
function ShowGroups()

   num_groups = getappdata(gcf,'num_groups');

   h = findobj(gcf,'Tag','GroupListBox');
  
   group_str = cell(1,num_groups);
   for i=1:num_groups,
      group_str{i} = sprintf('%3d. %s %d', i, 'Group', i);
   end;
   set(h,'String',group_str);

   return;						% ShowGroups


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

   if ~isequal(curr_contrasts,old_contrasts) & ~isempty(getappdata(gcf,'ContrastFile'))
      dlg_title = 'Session Information has been changed';
      msg = 'WARNING: The contrasts have been changed.  Do you want to save it?';
      response = questdlg(msg,dlg_title,'Yes','No','Cancel','Yes');

      switch response,
         case 'Yes'
              prefix=getappdata(gcf,'prefix');
 	      status = SaveText(prefix,0);		
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

   setappdata(gcf,'ContrastFile','');
   set(gcf,'Name','New Contrasts');

   DisplayContrasts;
   UpdateSlider;

   return;						% ClearContrasts


%----------------------------------------------------------------------------
function LoadConditions(prefix,pls_session,cond_selection,behavname,nonrotatemultiblock)

   if (ChkContrastModified == 0)
      return;                        % error
   end;

   if ~isempty(pls_session) & iscell(pls_session)
      conditions = pls_session;
   else
      if isempty(pls_session)   
         [filename, pathname] = rri_selectfile( ['*_',prefix,'sessiondata.mat'], ...
                                'Load conditions from a session file');
        
         if isequal(filename,0) | isequal(pathname,0)
            return;
         end;
   
         pls_session = [pathname, filename];
      end

      try
         pls_session = load(pls_session);
         conditions = pls_session.session_info.condition;
      catch
         msg = 'ERROR: Cannot load the conditions from the session file.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end;
   end

   if ~isempty(cond_selection)
      conditions = conditions(find(cond_selection));
   end

   if ~isempty(nonrotatemultiblock)
      for i=1:length(conditions)
         for j=1:length(behavname)
            new_conditions{(i-1)*length(behavname)+j} = [behavname{j} ' in ' conditions{i}];
         end
      end

      conditions = [conditions new_conditions];
   elseif ~isempty(behavname)
      for i=1:length(conditions)
         for j=1:length(behavname)
            new_conditions{(i-1)*length(behavname)+j} = [behavname{j} ' in ' conditions{i}];
         end
      end

      conditions = new_conditions;
   end

   setappdata(gcf,'Conditions',conditions);
   set(gcf,'Name','New Contrasts');

   ShowGroups;
   ShowConditions;
   ClearContrasts;

   return;						% LoadConditions   


%----------------------------------------------------------------------------
function status = SaveContrasts(prefix,save_as_flag)
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

   %  check if the contrast matrix is rank deficient
   %
   if (rank(contrast_mat) ~= size(contrast_mat,1))
      msg = 'Your Contrast matrix is rank deficient. Please check your contrasts and run the program again';
  %%    uiwait(msgbox(msg,'Warning: Contrasts are not linear independent','modal'));
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%      return;	
   end;

   %  check if the contrast matrix is orthogonal
   %
%   if abs(sum(sum(contrast_mat*contrast_mat'-diag(diag(contrast_mat*contrast_mat'))))) > 1e-6
   check_orth = abs(triu(contrast_mat*contrast_mat') - tril(contrast_mat*contrast_mat'));
   if max(check_orth(:)) > 1e-6
      msg = 'Effects expressed by each contrast are not independent. Check variable lvintercorrs in result file to see overlap of effects between LVs';
  %%   uiwait(msgbox(msg,'Warning: Contrasts are not orthogonal','modal'));
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%      return;	
   end

   if (save_as_flag == 1) | isempty(contrast_file)
      [filename, pathname] = ...
           rri_selectfile( ['*_',prefix,'contrast.mat'], ...
		'Save the Contrasts ');

      if ischar(filename) & (length(filename)<9 | isempty(findstr(lower(filename),'contrast')))
         [tmp filename] = fileparts(filename);
         filename = [filename, '_', prefix, 'contrast.mat'];
      end

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

    h0 = getappdata(gcbf,'main_fig');
    if isempty(h0), return; end;

    hm_contrast = getappdata(h0,'hm_contrast');
    set(hm_contrast, 'userdata',0, 'check','off');

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

   set(findobj(gcf,'Tag','LoadText'),'Visible','off');
   set(findobj(gcf,'Tag','SaveText'),'Visible','off');
   set(findobj(gcf,'Tag','SaveAsText'),'Visible','off');
   set(findobj(gcf,'Tag','HelmertMatrix'),'Visible','off');
   set(findobj(gcf,'Tag','CloseContrasts'),'Separator','off');

   set(findobj(gcf,'Tag','EditMenu'),'Visible','off');
   set(findobj(gcf,'Tag','ConditionMenu'),'Visible','off');

   return;						% HideMenuEntries


%----------------------------------------------------------------------------
function UpdateContrastName2(contrast_idx)

   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   if ~isempty(CurrContrast) & length(CurrContrast) >= g
      curr_contrast = CurrContrast{g};
   else
      curr_contrast = [];
   end

%   contrast_hdls = getappdata(gcf,'Contrast_hlist');
   a_hdls = getappdata(gcf,'AddRowHdls');

   row_idx = get(a_hdls(2),'UserData');
   contrast_idx = str2num(get(a_hdls(1),'String'));
   curr_contrast(contrast_idx).name = deblank(get(a_hdls(2),'String'));

   CurrContrast{g} = curr_contrast;
   setappdata(gcf,'CurrContrasts',CurrContrast);

   return;						% UpdateContrastName


%----------------------------------------------------------------------------
function err = UpdateContrastValue2(contrast_idx)

   err = 0;

   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   if ~isempty(CurrContrast) & length(CurrContrast) >= g
      curr_contrast = CurrContrast{g};
   else
      curr_contrast = [];
   end

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

if 0	% verify before save
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
end

   CurrContrast{g} = curr_contrast;
   setappdata(gcf,'CurrContrasts',CurrContrast);

   err = PlotContrast2;

   return;						% UpdateContrastValue


%----------------------------------------------------------------------------
function err = PlotContrast2()

   err = 0;
   ax_hdl = getappdata(gcf,'PlotAxes');
   
   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   if ~isempty(CurrContrast) & length(CurrContrast) >= g
      curr_contrast = CurrContrast{g};
   else
      curr_contrast = [];
   end

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


%----------------------------------------------------------------------------
function LoadText(prefix)
   
   if ~isempty(getappdata(gcf,'OldContrasts'))
      if (ChkContrastModified == 0)
         return;                        % error
      end;
   end;

   [filename, pathname] = rri_selectfile( ['*_',prefix,'contrast.txt'], ...   
					'Load contrast from text file');
        
   if isequal(filename,0) | isequal(pathname,0)
      return;
   end;
   
   contrast_file = [pathname, filename];

   try
      designdata = load(contrast_file);
   catch
      msg = 'ERROR: Cannot load the contrast file.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   conditions = getappdata(gcf,'Conditions');
   num_cond = length(conditions);
   num_groups = getappdata(gcf,'num_groups');

   if (num_groups * num_cond) ~= size(designdata,1)
      msg = 'ERROR: rows of contrast file not equal to [num_of_group * number_of_condition]';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   old_contrast = cell(1,num_groups);

   for g = 1:num_groups
      span = [((g-1)*num_cond+1) : g*num_cond];
      contrast_text = designdata(span, :);

      for i = 1:size(contrast_text,2)
         contrast_info.pls_contrasts(i).name = ['Contrast ', num2str(i)];
         contrast_info.pls_contrasts(i).value = contrast_text(:,i)';
      end

      old_contrast{g} = contrast_info.pls_contrasts;
   end

   setappdata(gcf,'OldContrasts',old_contrast);
   setappdata(gcf,'CurrContrasts',old_contrast);
%   setappdata(gcf,'Conditions',contrast_info.conditions);
   setappdata(gcf,'ContrastFile',contrast_file);
   setappdata(gcf,'TopContrastIdx',1);

   set(gcf,'Name',['Contrast File: ' contrast_file]);

   return;						% LoadText


%----------------------------------------------------------------------------
function LoadText2(designdata)
   
   conditions = getappdata(gcf,'Conditions');
   num_cond = length(conditions);
   num_groups = getappdata(gcf,'num_groups');

   if (num_groups * num_cond) ~= size(designdata,1)
      msg = 'ERROR: rows of contrast file not equal to [num_of_group * number_of_condition]';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   old_contrast = cell(1,num_groups);

   for g = 1:num_groups
      span = [((g-1)*num_cond+1) : g*num_cond];
      contrast_text = designdata(span, :);

      for i = 1:size(contrast_text,2)
         contrast_info.pls_contrasts(i).name = ['Contrast ', num2str(i)];
         contrast_info.pls_contrasts(i).value = contrast_text(:,i)';
      end

      old_contrast{g} = contrast_info.pls_contrasts;
   end

   setappdata(gcf,'OldContrasts',old_contrast);
   setappdata(gcf,'CurrContrasts',old_contrast);
%   setappdata(gcf,'Conditions',contrast_info.conditions);
%   setappdata(gcf,'ContrastFile',contrast_file);
   setappdata(gcf,'TopContrastIdx',1);

   return;						% LoadText2


%----------------------------------------------------------------------------
function status = SaveText(prefix,save_as_flag)
%  save_as_flag = 0,  save to the loaded file
%  save_as_flag = 1,  save to a new file
%

   status = 0;

   if ~exist('save_as_flag','var')
     save_as_flag = 0;
   end;

   pls_contrasts = getappdata(gcf,'CurrContrasts');
   contrast_file = getappdata(gcf,'ContrastFile');

   if isempty(pls_contrasts),
      msg = 'ERROR: No contrast available to be saved.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   conditions = getappdata(gcf,'Conditions');
   num_cond = length(conditions);
   num_groups = getappdata(gcf,'num_groups');

   if length(pls_contrasts) ~= num_groups
      msg = 'ERROR: All groups must have contrasts specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   g_contrast_mat = []; 

   for g = 1:num_groups

      if (g > 1) & (length(pls_contrasts{g}) ~= length(pls_contrasts{g-1}))
         msg = 'ERROR: All groups must have same numbers of contrasts.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end

      num_contrasts = length(pls_contrasts{g});
      contrast_mat = []; 

      for i=1:num_contrasts,
         if (isempty(pls_contrasts{g}(i).value))
            msg = 'ERROR: All contrasts must have values specified.';
            set(findobj(gcf,'Tag','MessageLine'),'String',msg);
	    return;
         end;

         if ~isempty(pls_contrasts{g}(i).value) 
            contrast_mat = [contrast_mat; pls_contrasts{g}(i).value];
	 end;
      end;

      g_contrast_mat = [g_contrast_mat contrast_mat];
   end

   %  check if the contrast matrix is rank deficient
   %
   if (rank(g_contrast_mat) ~= size(g_contrast_mat,1))
      msg = 'Your Contrast matrix is rank deficient. Please check your contrasts and run the program again';
  %%    uiwait(msgbox(msg,'Warning: Contrasts are not linear independent','modal'));
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%      return;	
   end;

   %  check if the contrast matrix is orthogonal
   %
%   if abs(sum(sum(g_contrast_mat*g_contrast_mat'-diag(diag(g_contrast_mat*g_contrast_mat'))))) > 1e-6
   check_orth = abs(triu(g_contrast_mat*g_contrast_mat') - tril(g_contrast_mat*g_contrast_mat'));
   if max(check_orth(:)) > 1e-6
      msg = 'Effects expressed by each contrast are not independent. Check variable lvintercorrs in result file to see overlap of effects between LVs';
  %%    uiwait(msgbox(msg,'Warning: Contrasts are not orthogonal','modal'));
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%      return;	
   end

   if (save_as_flag == 1) | isempty(contrast_file)
      [filename, pathname] = ...
           rri_selectfile( ['*_',prefix,'contrast.txt'], ...
		'Save contrasts to text file');

      if ischar(filename) & (length(filename)<9 | isempty(findstr(lower(filename),'contrast.txt')))
         [tmp filename] = fileparts(filename);
         filename = [filename, '_', prefix, 'contrast.txt'];
      end

      if isequal(filename,0)
         return;
      end;

      contrast_file = fullfile(pathname,filename);
   end;

   contrast_text = double(g_contrast_mat');

   try
      save(contrast_file, '-ascii', 'contrast_text');
   catch
      msg = sprintf('Cannot save contrasts to %s',contrast_file),
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   [fpath, fname, fext] = fileparts(contrast_file);
   msg = sprintf('Contrasts have been saved into ''%s'' ',[fname, fext]);
   set(findobj(gcf,'Tag','MessageLine'),'String',msg);

   setappdata(gcf,'ContrastFile',contrast_file);
   setappdata(gcf,'OldContrasts',pls_contrasts);

   set(gcf,'Name',['Contrast File: ' contrast_file]);

   status = 1;

   return;                                              % SaveText


%----------------------------------------------------------------------------
function [designdata, status] = SaveText2()

   designdata = [];
   status = 1;

   pls_contrasts = getappdata(gcf,'CurrContrasts');

   if isempty(pls_contrasts),
      msg = 'ERROR: No contrast available to be saved.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      status = 0;
      return;
   end;

   conditions = getappdata(gcf,'Conditions');
   num_cond = length(conditions);
   num_groups = getappdata(gcf,'num_groups');

   if length(pls_contrasts) ~= num_groups
      msg = 'ERROR: All groups must have contrasts specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      status = 0;
      return;
   end;

   g_contrast_mat = []; 

   for g = 1:num_groups

      if (g > 1) & (length(pls_contrasts{g}) ~= length(pls_contrasts{g-1}))
         msg = 'ERROR: All groups must have same numbers of contrasts.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         status = 0;
         return;
      end

      num_contrasts = length(pls_contrasts{g});
      contrast_mat = []; 

      for i=1:num_contrasts,
         if (isempty(pls_contrasts{g}(i).value))
            msg = 'ERROR: All contrasts must have values specified.';
            set(findobj(gcf,'Tag','MessageLine'),'String',msg);
            status = 0;
	    return;
         end;

         if ~isempty(pls_contrasts{g}(i).value) 
            contrast_mat = [contrast_mat; pls_contrasts{g}(i).value];
	 end;
      end;

      g_contrast_mat = [g_contrast_mat contrast_mat];
   end

   %  check if the contrast matrix is rank deficient
   %
   if (rank(g_contrast_mat) ~= size(g_contrast_mat,1))
      msg = 'Your Contrast matrix is rank deficient. Please check your contrasts and run the program again';
  %%    uiwait(msgbox(msg,'Warning: Contrasts are not linear independent','modal'));
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%      return;	
   end;

   %  check if the contrast matrix is orthogonal
   %
%   if abs(sum(sum(g_contrast_mat*g_contrast_mat'-diag(diag(g_contrast_mat*g_contrast_mat'))))) > 1e-6
   check_orth = abs(triu(g_contrast_mat*g_contrast_mat') - tril(g_contrast_mat*g_contrast_mat'));
   if max(check_orth(:)) > 1e-6
      msg = 'Effects expressed by each contrast are not independent. Check variable lvintercorrs in result file to see overlap of effects between LVs';
  %%    uiwait(msgbox(msg,'Warning: Contrasts are not orthogonal','modal'));
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%      return;	
   end

   setappdata(gcf,'OldContrasts',pls_contrasts);
   designdata = g_contrast_mat';

   return;                                              % SaveText2


%----------------------------------------------------------------------------
function HelmertMatrix
   
%   if ~isempty(getappdata(gcf,'OldContrasts'))
%      if (ChkContrastModified == 0)
%         return;                        % error
%      end;
%   end;

   conditions = getappdata(gcf,'Conditions');
   g = get(findobj(gcf,'Tag','GroupListBox'),'value');
   CurrContrast = getappdata(gcf,'CurrContrasts');

   contrast_text = rri_helmert_matrix(length(conditions));
%   contrast_text = fliplr(rri_helmert_matrix(length(conditions)));
%   contrast_text = flipud(rri_helmert_matrix(length(conditions)));

   for i = 1:size(contrast_text,2)
      contrast_info.pls_contrasts(i).name = ['Contrast ', num2str(i)];
      contrast_info.pls_contrasts(i).value = contrast_text(:,i)';
   end

   CurrContrast{g} = contrast_info.pls_contrasts;

%   setappdata(gcf,'OldContrasts',contrast_info.pls_contrasts);
   setappdata(gcf,'CurrContrasts',CurrContrast);
%   setappdata(gcf,'Conditions',contrast_info.conditions);

%   setappdata(gcf,'ContrastFile','');
%   setappdata(gcf,'TopContrastIdx',1);

%   set(gcf,'Name','New Contrasts');

   return;						% HelmertMatrix


%----------------------------------------------------------------------------
function ChangeGroup

   g = get(findobj(gcf,'Tag','GroupListBox'),'value');

   set(findobj(gcf,'Tag','ContrastTitleLabel'), ...
	'String',['Contrasts for Group ', num2str(g), ': ']);

   DisplayContrasts;
   UpdateSlider;

   return;						% ChangeGroup

