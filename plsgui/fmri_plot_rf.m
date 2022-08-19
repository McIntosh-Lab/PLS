function fig = fmri_plot_rf(action,varargin)
%
% fmri_plot_rf(action,action_arg1,...)

%  Application Data
%
%	STDatamat
%	SelectedCondition
%	ObjPositin
%	PlottedDatamat
%	AxesBoundary
%

  if ~exist('action','var') | isempty(action) 		% no action argument
      return;
  end;

  fig = [];
  if strcmp(action,'STARTUP')			    

      sessionFileList = varargin{1};
      init(sessionFileList);
      gen_condition_chk_box(1);
      SetObjPosition;

      return;
  elseif strcmp(action,'LINK')			    % call from other figure

      sessionFileList = varargin{1};
      fig = init(sessionFileList);
      gen_condition_chk_box(1);
      SetObjPosition;

      figure(gcbf);

      return;
  end;

  %  clear the message line,
  %
%  h = findobj(gcf,'Tag','MessageLine');
 % set(h,'String','');

  if strcmp(action,'LoadSTDatamat')
      selected_datamat = get(findobj(gcbf,'Tag','STDatamatPopup'),'Value');
      gen_condition_chk_box(selected_datamat);
      plot_response_fn;
  elseif strcmp(action,'NewCoord')
      new_coord = varargin{1};
      new_xyz = varargin{2};
      new_lag = varargin{3};
      setappdata(gcf,'Coord',new_coord);
      setappdata(gcf,'XYZ',new_xyz);
      setappdata(gcf,'lag',new_lag);
      plot_response_fn;
  elseif strcmp(action,'PlotBnPress')
      set(gcf,'pointer','watch');
      coord = getappdata(gcf,'Coord');
      plot_response_fn;
      set(gcf,'pointer','arrow');
  elseif strcmp(action,'SliderMotion')
      condition_update;
  elseif strcmp(action,'ResizeFigure')
      resize_fig;
  elseif strcmp(action,'DeleteFigure')
      delete_fig;
  elseif strcmp(action,'MENU_PlotIndividualData')
      make_datamat_popup(1);
  elseif strcmp(action,'MENU_PlotGroupData')
      make_datamat_popup(2);
  elseif strcmp(action,'MENU_PlotAllData')
      make_datamat_popup(3);
  elseif strcmp(action,'MENU_NumPtsPlotted')
      st_win_size = getappdata(gcf,'STWinSize');
      win_size_str = num2str(st_win_size);
      input_num_pts = inputdlg({'Number of points to be plotted'}, ...
			   'Input',1,{win_size_str});
      if ~isempty(input_num_pts)
         num_pts = str2num(input_num_pts{1});
         if ~isempty(num_pts)
            if (num_pts < 1) | (num_pts > st_win_size),
                msg = 'ERROR: Invalid input number of points';
                set(findobj(gcf,'Tag','MessageLine'),'String',msg);
            else
                setappdata(gcf,'NumPtsPlotted',num_pts);
            end
         end
      end;
  elseif strcmp(action,'MENU_CombinePlots')
      curr_state = get(gcbo,'Userdata');
      if (curr_state == 1),		% currently combining plots
         new_state = 0;
         set(gcbo,'Label','Combine plots within conditions');
      else
         new_state = 1;
         set(gcbo,'Label','Separate plots within conditions');
      end;
      set(gcbo,'Userdata',new_state);

      set(findobj(gcf,'tag','Stable'),'Userdata',0,'Label','&Stable off');

      fmri_plot_cond_stim_ui('COMBINE_PLOTS',new_state);
  elseif strcmp(action,'MENU_NormalizePlots')
      curr_state = get(gcbo,'Userdata');
      if (curr_state == 1),		% current plot is normalized plot
         new_state = 0;
         set(gcbo,'Label','Enable Data Normalization');
      else
         new_state = 1;
         set(gcbo,'Label','Disable Data Normalization');
      end;
      set(gcbo,'Userdata',new_state);
      plot_response_fn;
  elseif strcmp(action,'MENU_ExportData')
      save_response_fn;
  elseif strcmp(action,'MENU_ExportBehavData')
      save_response_fn2;
  elseif strcmp(action,'toggle_stable')
     stable_state = get(gcbo,'Userdata');
     if (stable_state == 1)
        bs1 = getappdata(gcf,'bs1');
        bs2 = getappdata(gcf,'bs2');
        bs3 = getappdata(gcf,'bs3');
        bs4 = getappdata(gcf,'bs4');

        for h = bs1
           if ishandle(h), set(h,'visible','on'); end
        end

        for h = bs2
           if ishandle(h), set(h,'visible','on'); end
        end

        for h = bs3
           if ishandle(h), set(h,'visible','on'); end
        end

        for h = bs4
           if ishandle(h), set(h,'visible','on'); end
        end

        set(gcbo,'Userdata',0,'Label','&Stable off');
     else
        bs1 = getappdata(gcf,'bs1');
        bs2 = getappdata(gcf,'bs2');
        bs3 = getappdata(gcf,'bs3');
        bs4 = getappdata(gcf,'bs4');

        for h = bs1
           if ishandle(h), set(h,'visible','of'); end
        end

        for h = bs2
           if ishandle(h), set(h,'visible','of'); end
        end

        for h = bs3
           if ishandle(h), set(h,'visible','of'); end
        end

        for h = bs4
           if ishandle(h), set(h,'visible','of'); end
        end

        set(gcbo,'Userdata',1,'Label','&Stable on');
     end;
  elseif strcmp(action,'residualized')
      main_fig = getappdata(gcf,'CallBackFig');
      lv = getappdata(main_fig,'CurrLVIdx');

      if 0 % lv < 2
         set(findobj(gcf,'tag','residualized'),'value',0);
         msg = 'You cannot select this checkbox if LV is less than 2.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      end
  end;

  return;


%--------------------------------------------------------------------------
%
function fig = init(sessionFileList)

   cond_selection = getappdata(gcf,'cond_selection');
   CallBackFig = gcbf;

   save_setting_status = 'on';
   fmri_plot_rf_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_plot_rf_pos) & strcmp(save_setting_status,'on')

      pos = fmri_plot_rf_pos;

   else

      w = 0.8;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   hh = figure('Units','normal', ...
	   'Name','Response Function Plot', ...	
	   'NumberTitle','off', ...
	   'Color', [0.8 0.8 0.8], ...
 	   'DoubleBuffer','on', ...
	   'Menubar', 'none', ...
	   'DeleteFcn', 'fmri_plot_rf(''DeleteFigure'');', ...
	   'Position',pos, ...
	   'Tag','PlotRFFig');

   %  display 'Neighborhood Size: '
   %
   x = 0.05;
   y = 0.9;
   w = 0.22;
   h = 0.05;

   pos = [x y w h];

   fnt = 0.5;

   h0 = uicontrol('Parent',hh, ...
   	   'Units','normal', ...
	   'FontUnits', 'normal', ...
	   'FontSize', fnt, ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'text', ...
	   'Position', pos, ...	
           'HorizontalAlignment', 'left',...
           'String', 'Neighborhood Size: ', ...
	   'Tag', 'neighborhoodLabel');

   %  edit 'Neighborhood Size: '
   %
   y = 0.85;
   w = 0.04;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
   	   'Units','normal', ...
	   'FontUnits', 'normal', ...
	   'FontSize', fnt, ...
	   'BackgroundColor', [1 1 1], ...
 	   'Style', 'edit', ...
	   'Position', pos, ...	
           'HorizontalAlignment', 'left',...
           'String', '0', ...
	   'tooltipstring', 'Use average intensity of its neighborhood voxels for intensity of this voxel. Neighborhood size is number of voxels from this voxel.', ...
           'CallBack', 'fmri_plot_rf(''PlotBnPress'');', ...
	   'Tag', 'neighborhoodEdit');

   x = x + w + 0.01;
   w = 0.12;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
   	   'Units','normal', ...
	   'FontUnits', 'normal', ...
	   'FontSize', fnt, ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'text', ...
	   'Position', pos, ...	
           'HorizontalAlignment', 'right',...
           'String', 'has neighbor #:', ...
	   'Tag', 'neighbornumberLabel');

   x = x + w + 0.01;
   w = 0.04;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
   	   'Units','normal', ...
	   'FontUnits', 'normal', ...
	   'FontSize', fnt, ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'text', ...
	   'Position', pos, ...	
           'HorizontalAlignment', 'right',...
           'String', '1', ...
	   'Tag', 'neighbornumberEdit');

   %  display 'ST datamat: '
   %
   x = 0.05;
   y = 0.77;
   w = 0.22;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
   	   'Units','normal', ...
	   'FontUnits', 'normal', ...
	   'FontSize', fnt, ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'text', ...
	   'Position', pos, ...	
           'HorizontalAlignment', 'left',...
	   'String', 'Datamat:', ...
	   'Tag', 'STDatamatLabel');

   %  create ST datamat popup menu
   %
   y = 0.72;

   pos = [x y w h];

   cb_fn = [ 'fmri_plot_rf(''LoadSTDatamat'');'];
   popup_h = uicontrol('Parent',hh, ...
   	   'units','normal', ...
	   'FontUnits', 'normal', ...
	   'FontSize', fnt, ...
           'Style', 'popupmenu', ...
	   'Position', pos, ...
           'HorizontalAlignment', 'left',...
	   'String', '', ...
	   'Value', 1, ...
	   'Tag', 'STDatamatPopup', ...
	   'Callback',cb_fn);

   y = 0.18;
   h = 0.5;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
           'Units','normal', ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'frame', ...
	   'Position', pos, ...	
           'HorizontalAlignment', 'left',...
	   'Tag', 'CondFrame');

   x = 0.09;
   y = 0.64;
   w = 0.14;
   h = 0.05;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
           'Units','normal', ...
	   'FontUnits', 'normal', ...
	   'FontSize', fnt, ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'text', ...
	   'Position', pos, ...	
           'HorizontalAlignment', 'center',...
	   'String', 'Conditions', ...
	   'Tag', 'ConditionLabel');

   x = 0.05;
   y = 0.08;
   w = 0.06;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontUnits', 'normal', ...
          'FontSize', fnt, ...
          'Style', 'push', ...
	  'Position', pos, ...
          'String', 'Plot', ...
   	  'Enable', 'on', ...
	  'Tag', 'PlotButton', ...
          'CallBack', 'fmri_plot_rf(''PlotBnPress'');');

   x = x+w+.01;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontUnits', 'normal', ...
          'FontSize', fnt, ...
          'Style', 'push', ...
	  'Position', pos, ...
          'String', 'Close', ...
          'CallBack', 'close(gcf)', ...
	  'Tag', 'CloseButton');

   x = x+w+.01;
   w = 0.12;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontUnits', 'normal', ...
          'FontSize', fnt, ...
          'Style', 'check', ...
	  'Position', pos, ...
	  'BackgroundColor', [0.8 0.8 0.8], ...
          'String', 'Residualized', ...
          'CallBack', 'fmri_plot_rf(''residualized'');', ...
	  'Tag', 'residualized');

   try
      load(get(findobj(gcbf,'Tag','ResultFile'),'UserData'),'method');
   catch
   end

   holdoffresidual = 1;

   if holdoffresidual
      set(h0, 'visible', 'off');
   elseif isempty(findstr(sessionFileList{1}{1}, 'sessiondata.mat')) | ...
	~exist('method','var')
      set(h0, 'visible', 'off');
   elseif isequal(method,2) | isequal(method,5) | isequal(method,6)
      set(h0, 'visible', 'off');
   elseif isequal(method,3) | isequal(method,4)
      set(h0, 'visible', 'off');
   end

   x = 0.01;
   y = 0;
   w = 1;
   h = 0.05;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...		% Message Line
   	'Style','text', ...
   	'Units','normal', ...
        'FontUnits', 'normal', ...
        'FontSize', fnt, ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ForegroundColor',[0.8 0.0 0.0], ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Tag','MessageLine');

  rri_file_menu(hh);

  h_plot = uimenu('Parent',hh, ...
	     'Label','&Plot', ...
             'Enable','on',...
	     'Tag','PlotMenu');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot individual ST datamat', ...
	     'Tag','PlotIndividualData', ...
	     'Callback','fmri_plot_rf(''MENU_PlotIndividualData'');');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot group data', ...
	     'Tag','PlotGroupData', ...
	     'Callback','fmri_plot_rf(''MENU_PlotGroupData'');');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot all data', ...
	     'Tag','PlotAllData', ...
	     'Callback','fmri_plot_rf(''MENU_PlotAllData'');');

  h_option = uimenu('Parent',hh, ...
	     'Label','&Option', ...
	     'Tag','OptionMenu', ...
             'Enable','off',...
	     'Visible','on');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Hide Average Plot', ...
	     'Tag','ToggleShowAvgMenu', ...
	     'Callback','set(findobj(gcf,''tag'',''Stable''),''Userdata'',0,''Label'',''&Stable off''); fmri_plot_cond_stim_ui(''TOGGLE_SHOW_AVERAGE'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Combine plots within conditions', ...
	     'Tag','CombinePlots', ...
	     'Userdata', 0, ...
	     'Callback','fmri_plot_rf(''MENU_CombinePlots'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Enable Data Normalization', ...
	     'Tag','NormalizePlots', ...
	     'Userdata', 0, ...
	     'Callback','fmri_plot_rf(''MENU_NormalizePlots'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Change plot dimension', ...
	     'Separator','on',...
	     'Tag','ChgPlotDims', ...
	     'Callback','set(findobj(gcf,''tag'',''Stable''),''Userdata'',0,''Label'',''&Stable off''); fmri_plot_cond_stim_ui(''CHANGE_PLOT_DIMS'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Number of points to be plotted', ...
	     'Tag','NumPtsPlotted', ...
	     'Callback','fmri_plot_rf(''MENU_NumPtsPlotted'');');

  h_option = uimenu('Parent',hh, ...
	     'Label','&Data', ...
	     'Tag','DataMenu', ...
             'Enable','off',...
	     'Visible','on');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Export data', ...
	     'Tag','ExportData', ...
	     'Callback','fmri_plot_rf(''MENU_ExportData'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Export data for behav analysis', ...
	     'Tag','ExportBehavData', ...
		'visible', 'off', ...
	     'Callback','fmri_plot_rf(''MENU_ExportBehavData'');');

  h_bs = uimenu('Parent',hh, ...
		'Label','&Stable Off', ...
		'user', 0, ...
		'enable','off', ...
		'Tag','Stable', ...
		'callback','fmri_plot_rf(''toggle_stable'');');

   %  set up object location records
   %
   x = 0.05;
   y = 0.77;
   w = 0.15;
   h = 0.05;
   obj(1).name = 'STDatamatLabel';	obj(1).pos = [x 1-y w h];

   y = 0.72;
   w = 0.22;
   obj(2).name = 'STDatamatPopup';	obj(2).pos = [x 1-y w h];

   x = 0.09;
   y = 0.64;
   w = 0.14;
   h = 0.05;
   obj(3).name = 'ConditionLabel';	obj(3).pos = [x 1-y w h];

   y = 0.58;
   obj(4).name = 'Condition1';		obj(4).pos = [x 1-y w h];

   setappdata(hh,'ObjPosition',obj);
   setappdata(hh,'CallBackFig',CallBackFig');
   setappdata(hh,'cond_selection',cond_selection);

   bsr = getappdata(gcbf, 'BSRatio');
   bs_thresh = getappdata(gcbf, 'BSThreshold');
   bs_thresh2 = getappdata(gcbf, 'BSThreshold2');

   setappdata(hh, 'org_bsr', bsr);
   setappdata(hh, 'bs_thresh', bs_thresh);
   setappdata(hh, 'bs_thresh2', bs_thresh2);

   st_coords = getappdata(gcbf, 'BLVCoords');

   if isempty(st_coords)
      st_coords = getappdata(gcbf, 'BSRatioCoords');
   end

   setappdata(hh, 'STCoords', st_coords);

   setappdata(gcf, 'sa', getappdata(gcbf, 'sa'));

  % construct the popup label list
  %
  get_st_datamat_filename(sessionFileList);
  make_datamat_popup(1);

  if (nargout >= 1),
     fig = hh;
  end;

  return;


%--------------------------------------------------------------------------
%
function gen_condition_chk_box(selected_idx)

  cond_selection = getappdata(gcf,'cond_selection');
  st_files = getappdata(gcf,'STFiles');
  sessionFile = st_files{selected_idx}.profile;

  load(sessionFile);

  cname = session_info.condition;

  if isempty(cond_selection)
     num_cond = session_info.num_conditions;
     cond_selection = ones(1,num_cond);
     setappdata(gcf,'cond_selection',cond_selection);
  else
     num_cond = sum(cond_selection);
     cname = cname(find(cond_selection));
  end

  %  display 'Conditions: '
  %
  h0 = findobj(gcf,'Tag','ConditionLabel');
  if ~isempty(h0)			% no condition has been defined yet
     cond_h = get(h0,'UserData');
     for i=1:length(cond_h);
        delete(cond_h(i));		% remove the old conditions
     end;   
  end;
	   
  %  create check box for the conditions
  %
  h_list = [];

  for i=1:num_cond,

     %  callback function to update the condition selection
     %
     cbf = ['selected_cond = getappdata(gcf,''SelectedCondition''); ' ...
     	'selected_cond(',num2str(i),')=~selected_cond(',num2str(i),'); ' ...
	'setappdata(gcf,''SelectedCondition'',selected_cond); ', ...
	'if (sum(selected_cond) == 0), ' ... 
        '    set(findobj(gcf,''Tag'',''PlotButton''),''Enable'',''off''); '...
        'else, ' ...
        '    set(findobj(gcf,''Tag'',''PlotButton''),''Enable'',''on''); '...
        'end; ']; 

     %  create the condition check box
     %
     h1 = uicontrol('Parent',gcf, ...
   	   'Units','normal', ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
	   'Value', 1, ...
           'Style', 'check', ...
	   'String', sprintf(' (%d)  %s', i,cname{i}), ...
           'HorizontalAlignment', 'left',...
           'SelectionHighlight', 'off',...
	   'FontSize', 10, ...
	   'Tag', sprintf('Condition%d',i), ...
	   'Callback',cbf);

     h_list = [h_list h1];

  end;

  set(h0,'UserData',h_list);

  %  set up the scroll bar for the conditions
  %
  h1 = uicontrol('Parent',gcf, ...
           'Style', 'slider', ...
   	   'Units','normal', ...
	   'Tag', 'CondSlider', ...
	   'Callback','fmri_plot_rf(''SliderMotion'');');

  SetObjPosition('ConditionChkBoxes');

  setappdata(gcf,'SelectedCondition',ones(1,num_cond));
  setappdata(gcf,'Conditions',cname);

  return;


%--------------------------------------------------------------------------
%
function h = delete_fig()

  link_figure = getappdata(gcbf,'LinkFigureInfo');

  try 
     rmappdata(link_figure.hdl,link_figure.name);
  end;

  try
     load('pls_profile');
     pls_profile = which('pls_profile.mat');

     fmri_plot_rf_pos = get(gcbf,'position');

     save(pls_profile, '-append', 'fmri_plot_rf_pos');
  catch
  end

  return; 					% delete_fig


%--------------------------------------------------------------------------
%
function obj_pos = GetObjPosition(ObjName)

   obj = getappdata(gcf,'ObjPosition');

   i = 1;
   while i <= length(obj);
      if strcmp(ObjName,obj(i).name)
         obj_pos = obj(i).pos;
	 return;
      end;
      i = i+1;
   end;
  
   return; 					% get_obj_pos


%--------------------------------------------------------------------------
%
function SetObjPosition(ObjName)

   obj = getappdata(gcf,'ObjPosition');

   % set the positions for all objects
   %
   if ~exist('ObjName','var') | isempty(ObjName) 
      ObjName = 'STDatamat';
   end;

   if strcmp(ObjName,'STDatamat') | strcmp(ObjName,'ALL'),
      for i=1:length(obj),
         obj_pos = obj(i).pos;
         obj_pos(2) = 1 - obj_pos(2);
         set(findobj(gcf,'Tag',obj(i).name),'Position',obj_pos);
      end;
   end;

   %  set positions for the condition check box
   %
   if strcmp(ObjName,'ConditionChkBoxes')  | strcmp(ObjName,'ALL'),

      % find the position of the PLOT Button
      plot_pos = get(findobj(gcf,'Tag', 'PlotButton'),'Position');
      lowest_v_pos = plot_pos(2) + plot_pos(4) * 1.5;

      chk_box_hlist = get(findobj(gcf,'Tag','ConditionLabel'),'UserData');
      num_cond = length(chk_box_hlist);

      cond1_pos = GetObjPosition('Condition1');
      cond1_pos(2) = 1 - cond1_pos(2);

      cond_h = 0.06;
      rows = floor((cond1_pos(2) - lowest_v_pos) / cond_h);
      pages = ceil(num_cond / rows);

      v_pos = cond1_pos(2)-mod([1:num_cond]-1,rows)*cond_h;

      for i=1:num_cond,
         obj_pos = [cond1_pos(1) v_pos(i) cond1_pos(3) cond1_pos(4)];
         if (i <= rows), 
             visibility = 'on'; 
         else
             visibility = 'off'; 
         end;
         set(chk_box_hlist(i),'Position',obj_pos,'Visible',visibility);
      end;

      %  set the slider position
      %
      h = findobj(gcf,'Tag', 'CondSlider');
      if (pages <= 1)
	 set(h,'Visible','off');
      else
         s_pos = [cond1_pos(1)+cond1_pos(3)+0.01 v_pos(rows) 0.02 cond_h*rows];
         set(h,'Min',1,'Max',pages, ...
               'Position',s_pos, ...
               'Value',pages, ...
               'Sliderstep',[1/(pages-1)-0.00001 1/(pages-1)] );
	 set(h,'Visible','on');
	 set(h,'UserData',rows);
      end;

   end;

   return; 					% get_obj_pos


%--------------------------------------------------------------------------
function make_datamat_popup(data_option)
%  data_option = 1  - plot individual ST datamat
%  data_option = 2  - plot group data
%  data_option = 3  - plot all data

   popup_h = findobj(gcf,'Tag','STDatamatPopup');
   curr_option = get(popup_h,'Userdata');
   if ~isempty(curr_option) & (curr_option == data_option)
      return;				% no change, do nothing
   end;

   st_filenames = getappdata(gcf,'STFiles');

   switch (data_option)

     case {1}					% plot individual data
        num_st_datamat = length(st_filenames);
        popup_list = cell(1,num_st_datamat);
        for i=1:num_st_datamat,
           %  get rid of ".mat" extension if there is any 
           if strcmp(st_filenames{i}.name(end-3:end),'.mat')==1
              popup_list{i} = sprintf('[%d] %s', ...
                        st_filenames{i}.group, st_filenames{i}.name(1:end-4));
           else
              popup_list{i} = sprintf('[%d] %s', ...
                        st_filenames{i}.group, st_filenames{i}.name);
           end;
        end;
        alignment = 'left';

     case {2}					% plot group data
        num_group = st_filenames{end}.group;
        popup_list = cell(1,num_group);
	for i=1:num_group,
           popup_list{i} = sprintf('[ Group #%d ]',i);
	end;
        alignment = 'center';

     case {3}					% plot all data
        popup_list{1} = '< All Data >';
        alignment = 'center';

   end;

   set(popup_h,'String',popup_list,'Userdata',data_option, ...
               'HorizontalAlignment', alignment,'Value',1);

   msg = 'Press "Plot" Button or select datamat to see the response function';
   set(findobj(gcf,'Tag','MessageLine'),'String',msg);

   return; 					% make_datamat_popup


%--------------------------------------------------------------------------
function condition_update(sessionFileList,with_path)
%
   h = findobj(gcf,'Tag', 'CondSlider');
   rows = get(h,'UserData');
   max_page = get(h,'Max');
   slider_value = round(get(h,'Value'));
   page = max_page - slider_value +1;
   set(h,'Value',slider_value);

   chk_box_hlist = get(findobj(gcf,'Tag','ConditionLabel'),'UserData');
   num_cond = length(chk_box_hlist);

   visible_list = zeros(1,num_cond);
   visible_list((page-1)*rows+1:page*rows) = 1;

   for i=1:num_cond,
      if(visible_list(i) == 0)
          set(chk_box_hlist(i),'Visible','off');
      else
          set(chk_box_hlist(i),'Visible','on');
      end;
   end;
   
   return;
%


%--------------------------------------------------------------------------
function get_st_datamat_filename(sessionFileList)
%
%   INPUT:
%       sessionFileList - vector of cell structure, each element contains
%                         the full path of a session file.
%

  cnt = 0;
  num_groups = length(sessionFileList);
  fn = sessionFileList{1}{1};

  for i=1:num_groups,
     num_files = length(sessionFileList{i});
     for j=1:num_files,
        cnt = cnt + 1;
        load( sessionFileList{i}{j} );
        rri_changepath('fmrisession');

        if ~isempty(findstr('_BfMRIsessiondata.mat', fn))
           fname = sprintf('%s_BfMRIsessiondata.mat',session_info.datamat_prefix);
        elseif ~isempty(findstr('_fMRIsessiondata.mat', fn))
           fname = sprintf('%s_fMRIsessiondata.mat',session_info.datamat_prefix);
        elseif ~isempty(findstr('BfMRIsession.mat', fn))
           fname = sprintf('%s_BfMRIdatamat.mat',session_info.datamat_prefix);
        else
           fname = sprintf('%s_fMRIdatamat.mat',session_info.datamat_prefix);
        end

        st_filename{cnt}.name = fname;
        st_filename{cnt}.fullname = fullfile(session_info.pls_data_path,fname);
        st_filename{cnt}.group = i;
        st_filename{cnt}.profile = sessionFileList{i}{j};
     end;
  end;

  setappdata(gcf,'STFiles',st_filename);

  return;                                       % get_st_datamat_filename


%--------------------------------------------------------------------------
%
function  [st_datamat, org_coords,st_win_size,st_evt_list] =  ...
                                         load_plotted_datamat,

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   selected_files = get_selected_filename;

   if (length(selected_files) == 1), 		
       load(selected_files{1});

       common_coords = getappdata(gcf,'STCoords');
       [tmp, coord_idx] = intersect(st_coords, common_coords);

       nr = length(st_evt_list);
       nc = length(st_coords);
       win_size = st_win_size;
       num_voxels = length(st_coords);
       num_cols = win_size * num_voxels;
       tmp_datamat = reshape(st_datamat,[nr,win_size,nc]); 
       tmp_datamat = tmp_datamat(:,:,coord_idx);
       num_voxels = length(common_coords);
       num_cols = win_size * num_voxels;
       st_datamat = reshape(tmp_datamat,[nr,num_cols]);
       st_coords = common_coords;
   else					%  merge files together
       [st_datamat,st_coords,st_win_size,st_evt_list] =  ...
                                   merge_st_datamat(selected_files);
   end;

   org_coords = st_coords;

   cond_selection = getappdata(gcf,'cond_selection');

   [mask, st_evt_list, evt_length] = ...
	fmri_mask_evt_list(st_evt_list, cond_selection);

   st_datamat = st_datamat(mask,:);

   set(gcf,'Pointer',old_pointer);

   return;                                       % load_plotted_datamat


%--------------------------------------------------------------------------
%
function  [selected_files] = get_selected_filename(select_all_flg),

   st_filename = getappdata(gcf,'STFiles');

   if exist('select_all_flg','var') & (select_all_flg == 1)
      data_option = 3;
   else
      h = findobj(gcf,'Tag','STDatamatPopup');
      selected_idx = get(h,'Value');
      data_option = get(h,'Userdata');
   end;

   switch (data_option)
      case {1}, 				% individual file
	 selected_files{1} = st_filename{selected_idx}.fullname;
      case {2},					% group data
         cnt = 0;
         for i=1:length(st_filename),
            if (st_filename{i}.group == selected_idx)
               cnt = cnt+1;
               selected_files{cnt} = st_filename{i}.fullname;
            end;
         end;
      case {3},					% all data
         cnt = 0;
         for i=1:length(st_filename),
            selected_files{i} = st_filename{i}.fullname;
         end;
   end; 

   return;					%  get selected filenames


%--------------------------------------------------------------------------
%
function  [grp_st_datamat,coords,win_size,evt_list] =  ...
                                   merge_st_datamat(selected_files),

   num_files = length(selected_files);

   %  compute the common coords first and the total number of events
   %  (don't need to compute the common coords, because it has been
   %   computed during run PLS)
   %
   load(selected_files{1},'st_dims','st_win_size'); 
   total_num_evt = 0;
%   m = zeros(st_dims);
   for i=1:num_files,
      load(selected_files{i},'st_coords','st_evt_list');
      total_num_evt = total_num_evt + length(st_evt_list); 
%      m(st_coords) = m(st_coords) + 1; 
   end;
%   coords = find(m == num_files); 
   coords = getappdata(gcf,'STCoords');

   %  ready to merge the st_datamat together now ...
   %
   win_size = st_win_size;
   num_voxels = length(coords);
   num_cols = win_size * num_voxels;
   grp_st_datamat = zeros(total_num_evt,num_cols);
   evt_list = [];
   first_row = 1;
   for i=1:num_files,

      load(selected_files{i});

%      coord_idx = find(m(st_coords) == num_files);
      [tmp, coord_idx] = intersect(st_coords, coords);

      nr = length(st_evt_list);
      nc = length(st_coords);
      last_row = nr + first_row - 1;

      num_voxels = length(st_coords);
      num_cols = win_size * num_voxels;

      tmp_datamat = reshape(st_datamat,[nr,win_size,nc]); 
      tmp_datamat = tmp_datamat(:,:,coord_idx);
      num_voxels = length(coords);
      num_cols = win_size * num_voxels;
      tmp_datamat = reshape(tmp_datamat,[nr,num_cols]);

      grp_st_datamat(first_row:last_row,:) = tmp_datamat;
      evt_list = [evt_list st_evt_list];

      first_row = last_row + 1;

      clear st_datamat tmp_datamat;
   end; 

   return;                               	% merge_st_datamat


%--------------------------------------------------------------------------
%
function  plot_response_fn()

   if get(findobj(gcf,'tag','residualized'),'value')
      setappdata(gcf,'last_resid',1);
      plot_response_fn_resid;
      return;
   end

   neighbor_numbers = 1;

   emp_st_data = 0;
   set(findobj(gcf,'tag','Stable'),'Userdata',0,'Label','&Stable off');

   st_files = getappdata(gcf,'STFiles');
   conditions = getappdata(gcf,'Conditions');

   h = findobj(gcf,'Tag','PlotButton');
   if strcmp(lower(get(h,'Enable')),'off'),  return; end;

   h = findobj(gcf,'Tag','STDatamatPopup');
   popup_string = get(h,'String');
   selected_idx = get(h,'Value');
   selected_data = popup_string{selected_idx};

   %  load the datamat if not loaded yet
   %
   last_datamat = getappdata(gcf,'PlottedDatamat');
   last_resid = getappdata(gcf,'last_resid');
   setappdata(gcf,'last_resid',0);
   is_resid = get(findobj(gcf,'tag','residualized'),'value');

   if strcmp(last_datamat,selected_data) == 0 | ~isequal(last_resid,is_resid)

       set(findobj(gcf,'Tag','MessageLine'),'String','Loading data ... ');

       [st_datamat, org_coords, st_win_size, st_evt_list] = ...
					load_plotted_datamat;

       setappdata(gcf,'PlottedDatamat',selected_data);
       setappdata(gcf,'STDatamat',st_datamat);
       setappdata(gcf,'org_coords',org_coords);
       setappdata(gcf,'STWinSize',st_win_size);
       setappdata(gcf,'STEvtList',st_evt_list);

       set(findobj(gcf,'Tag','MessageLine'),'String','');
   else
       st_win_size = getappdata(gcf,'STWinSize');
       st_evt_list = getappdata(gcf,'STEvtList');
       org_coords = getappdata(gcf,'org_coords');
   end;

   st_coords = getappdata(gcf,'STCoords');	% common_coord from result file

   num_pts_plotted = getappdata(gcf,'NumPtsPlotted');
   if isempty(num_pts_plotted)
      num_pts_plotted = st_win_size;
      setappdata(gcf,'NumPtsPlotted',num_pts_plotted);
   elseif (num_pts_plotted > st_win_size),
      num_pts_plotted = st_win_size;
   end;

%   xyz = getappdata(gcf,'XYZ');
%   lag = getappdata(gcf,'lag');
   
   %  extract the currect ploting data
   %
   cur_coord = getappdata(gcf,'Coord');
   if isempty(cur_coord)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%       return;
       emp_st_data = 1;
   end;

   coord_idx = find(st_coords == cur_coord);	% idx of cur_coord in common

   if isempty(coord_idx)
       msg = 'ERROR: The selected point is outside the brain region.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%       return;
       emp_st_data = 1;
   end;


   %  Get Neighborhood Size
   h = findobj(gcf,'Tag','neighborhoodEdit');
   neighbor_size = round(str2num(get(h,'String')));

   if isempty(neighbor_size) | ~isnumeric(neighbor_size)
      neighbor_size = 0;
   end

   %  Do neighborhood mean only if there is any neighborhood
   %
   if neighbor_size > 0

      CallBackFig = getappdata(gcf,'CallBackFig');
      CurrLVIdx = getappdata(CallBackFig,'CurrLVIdx');
      dims = getappdata(CallBackFig,'STDims');

      %  Get neighborhood XYZs
      %
      xyz = rri_coord2xyz(cur_coord, dims);

      x1 = xyz(1) - neighbor_size;
      if x1 < 1, x1 = 1; end;

      x2 = xyz(1) + neighbor_size;
      if x2 > dims(1), x2 = dims(1); end;

      y1 = xyz(2) - neighbor_size;
      if y1 < 1, y1 = 1; end;

      y2 = xyz(2) + neighbor_size;
      if y2 > dims(2), y2 = dims(2); end;

      z1 = xyz(3) - neighbor_size;
      if z1 < 1, z1 = 1; end;

      z2 = xyz(3) + neighbor_size;
      if z2 > dims(4), z2 = dims(4); end;

      %  Get neighborhood coords relative to whole volume
      %
      neighbor_coord = [];

      for k = z1:z2
         for j=y1:y2
            for i=x1:x2
               neighbor_coord = [neighbor_coord, rri_xyz2coord([i j k], dims)];
            end
         end
      end

      %  If "Cluster Mask" is checked, cluster masked voxels will be used
      %  as a criteria to select surrounding voxels
      %
      isbsr = getappdata(CallBackFig,'ViewBootstrapRatio');

      if isbsr
         cluster_info = getappdata(CallBackFig, 'cluster_bsr');
      else
         cluster_info = getappdata(CallBackFig, 'cluster_blv');
      end

      %  Get cluster voxels coords relative to whole volume
      %
      if length(cluster_info) < CurrLVIdx
         cluster_info = [];
      else
         cluster_info = cluster_info{CurrLVIdx};
         cluster_info = cluster_info.data{1}.idx;
      end

      %  If "Bootstrap" is computed, voxels that meet the bootstrap ratio
      %  threshold will be used as a criteria to select surrounding voxels
      %
      BSThreshold = getappdata(CallBackFig,'BSThreshold');
      BSThreshold2 = getappdata(CallBackFig,'BSThreshold2');

      if ~isempty(BSThreshold)
         BSRatio = getappdata(CallBackFig,'BSRatio');
         BSRatio = BSRatio(:,CurrLVIdx);

         all_voxel = zeros(1,prod(dims));
         bsr_gt_thresh = (BSRatio > BSThreshold) | (BSRatio < BSThreshold2);
         bsr_gt_thresh = reshape(bsr_gt_thresh, [st_win_size, round(length(bsr_gt_thresh)/st_win_size)]);
%         all_voxel(st_coords) = bsr_gt_thresh(lag+1,:);
         all_voxel(st_coords) = sum(bsr_gt_thresh, 1);

         bsridx = find(all_voxel);
      else
         bsridx = [];
      end

      %  Only including surrounding voxels that meet the bootstrap ratio
      %  threshold, or are part of cluster masked voxels
      %
      bsr_cluster_coords = unique([cluster_info bsridx cur_coord]);

      %  Intersect of neighborhood coord "neighbor_coord" and 
      %  "bsr_cluster_coords"
      %
      neighbor_coord = intersect(neighbor_coord, bsr_cluster_coords);

   else

      neighbor_coord = cur_coord;

   end;		% if neighbor_size > 0

   %  find out neighborhood indices in st_datamat
   %
   [ncoord ncoord_idx] = intersect(st_coords, neighbor_coord);

   neighbor_numbers = length(ncoord_idx);
   h = findobj(gcf,'Tag','neighbornumberEdit');
   set(h,'String',num2str(neighbor_numbers));

   st_datamat = getappdata(gcf,'STDatamat');	% indexed by common_coord

   [nr,nc] = size(st_datamat);
   cols = nc / st_win_size;

   if emp_st_data
      st_data = [];
   else
      st_data = reshape(st_datamat,[nr,st_win_size,cols]);
      st_data = mean(st_data(:,[1:num_pts_plotted],ncoord_idx),3);
   
      h = findobj(gcf,'Tag','NormalizePlots');
      normalize_flg = get(h,'UserData');
      if (normalize_flg == 1),
         max_st_data = max(st_data,[],2);
         min_st_data = min(st_data,[],2);

         max_mtx = max_st_data(:,ones(1,num_pts_plotted));
         min_mtx = min_st_data(:,ones(1,num_pts_plotted));
         scale_factor = max_mtx - min_mtx;
         st_data = (st_data - min_mtx) ./ scale_factor;
      end;
   end

   main_fig = getappdata(gcf,'CallBackFig');
   num_subj_lst = getappdata(main_fig,'subj_group');
   num_cond = sum(getappdata(main_fig,'cond_selection'));

   h = findobj(gcf,'Tag','STDatamatPopup');
   selected_idx = get(h,'Value');
   data_option = get(h,'Userdata');

   switch (data_option)
      case {1},					% individual file
         st_evt_list = 1:num_cond;
      case {2},					% group data
         st_evt_list = 1:num_cond;
         st_evt_list = repmat(st_evt_list, [1 num_subj_lst(selected_idx)]);
      case {3},					% all data
         st_evt_list = 1:num_cond;
         st_evt_list = repmat(st_evt_list, [1 sum(num_subj_lst)]);
   end;

   bsr = getappdata(gcf,'org_bsr');
   bs_thresh = getappdata(gcf,'bs_thresh');
   bs_thresh2 = getappdata(gcf,'bs_thresh2');

   if ~isempty(bsr)
      [r c] = size(bsr);
      bsr = reshape(bsr, [st_win_size, r/st_win_size, c]);
      bsr = squeeze(bsr([1:num_pts_plotted],coord_idx,:));
      set(findobj(gcf,'tag','Stable'), 'enable', 'on');
   end 


   selected_condition = getappdata(gcf,'SelectedCondition');
   num_conditions = length(selected_condition);
   condition = cell(1,num_conditions);  

   max_num_stim = 0;
   for i=1:num_conditions,
      condition{i}.st_row_idx  = find(st_evt_list == i);
      condition{i}.num_stim = length(condition{i}.st_row_idx);
      condition{i}.name = conditions{i};
      if (max_num_stim < condition{i}.num_stim)
          max_num_stim = condition{i}.num_stim;
      end;
   end;


   % generate the plots
   %
   plot_cond_idx = find(selected_condition == 1);

   plot_dims = getappdata(gcf,'PlotDims');
   if isempty(plot_dims) 
       if (num_conditions < 5)
         num_rows = num_conditions;
       else
         num_rows = 5;
       end;
       if (max_num_stim < 4),
         num_cols = max_num_stim;
       else
         num_cols = 4;
       end;
       plot_dims = [num_rows num_cols];
   end;

   axes_margin = [.37 .13 .15 .1];

   fmri_plot_cond_stim_ui('STARTUP', st_data, condition,  ...
		axes_margin, plot_dims, plot_cond_idx, bsr, bs_thresh, bs_thresh2);

   setappdata(gcf,'STEvtList',st_evt_list);
   setappdata(gcf,'PLS_PLOT_COND_STIM_ACTIVE',1);
   setappdata(gcf, 'ncoord_idx', ncoord_idx);
   setappdata(gcf, 'ncoord', ncoord);
   set(findobj(gcf,'Tag','PlotMenu'),'Enable','on');
   set(findobj(gcf,'Tag','OptionMenu'),'Enable','on');
   set(findobj(gcf,'Tag','DataMenu'),'Enable','on');

   return;					% plot_response_fn


%--------------------------------------------------------------------------
%
function  save_response_fn()

   neighbor_numbers = 1;

   %  Get Neighborhood Size
   h = findobj(gcf,'Tag','neighborhoodEdit');
   neighbor_size = round(str2num(get(h,'String')));

   if isempty(neighbor_size) | ~isnumeric(neighbor_size)
      neighbor_size = 0;
   end

   st_win_size = getappdata(gcf,'STWinSize');
   st_evt_list = getappdata(gcf,'STEvtList');
   st_coords = getappdata(gcf,'STCoords');
   org_coords = getappdata(gcf,'org_coords');

   xyz = getappdata(gcf,'XYZ');
%   lag = getappdata(gcf,'lag');

   %  extract the currect ploting data
   %
   cur_coord = getappdata(gcf,'Coord');
   if isempty(cur_coord)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;

   coord_idx = find(st_coords == cur_coord);
   if isempty(coord_idx)
       msg = 'ERROR: The selected point is outside the brain region.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;
%   coord_idx = find(org_coords == cur_coord);
   ncoord_idx = getappdata(gcf, 'ncoord_idx');
   neighbor_numbers = length(ncoord_idx);

   CallBackFig = getappdata(gcf,'CallBackFig');
   LV = getappdata(CallBackFig,'CurrLVIdx');
   dims = getappdata(CallBackFig,'STDims');
   ncoord = getappdata(gcf, 'ncoord');
   xyz = rri_coord2xyz(ncoord,dims);

   %  get all the file names 
   %
   selected_files = get_selected_filename;

if 0
   %  extract the time course data of the selected voxel
   %
   st_datamat = getappdata(gcf,'STDatamat'); 

   [nr,nc] = size(st_datamat);
   cols = nc / st_win_size;
   st_data = reshape(st_datamat,[nr,st_win_size,cols]);
%   st_data = squeeze(st_data(:,(lag+1),coord_idx));
%   st_data = squeeze(st_data(:,[1:st_win_size],coord_idx));
else
   st_data = getappdata(gcf,'ST_data');
   residualized = get(findobj(gcf,'tag','residualized'),'value');
   normalized = get(findobj(gcf,'tag','NormalizePlots'),'UserData');
end

%   standard_deviation = std(st_data(:,[1:st_win_size],ncoord_idx),0,3);
 %  st_data = mean(st_data(:,[1:st_win_size],ncoord_idx),3);


   [a1 b1]=sort(st_evt_list);
   c1 = length(unique(st_evt_list));

if 0
   %  was designed for [1 1 2 2 3 3] situation
   %  not necessary, since we have st_evt_list
   %
   b2 = reshape(b1, [length(st_evt_list)/c1, c1]);
   b2 = b2';
   b2 = b2(:)';
   st_evt_list = st_evt_list(b2);
   st_data = st_data(b2, :);
%   standard_deviation = standard_deviation(b2, :);
end


   st_data_mean = ones(c1, size(st_data,2));

   for i = 1:c1
      st_data_mean(i,:) = mean(st_data(find(st_evt_list==i),:),1);
   end

   fn = getappdata(gcf,'STFiles');
   fn = fn{1}.name;

   if findstr('BfMRIsession.mat', fn)
      [filename, pathname] = ...
	rri_selectfile('*_BfMRI_rf_plot.mat','Save the Response Functions');

      if ischar(filename) & ~all(ismember('_bfmri_rf_plot',lower(filename)))
         [tmp filename] = fileparts(filename);
         filename = [filename, '_BfMRI_rf_plot.mat'];
      end
   else
      [filename, pathname] = ...
	rri_selectfile('*_fMRI_rf_plot.mat','Save the Response Functions');

      if ischar(filename) & ~all(ismember('_fmri_rf_plot',lower(filename)))
         [tmp filename] = fileparts(filename);
         filename = [filename, '_fMRI_rf_plot.mat'];
      end
   end

   if isequal(filename,0)
	return;
   end;
   rf_plot_file = fullfile(pathname,filename);

   xyz_str = 'xyz';
 
   sa = getappdata(gcf, 'sa');
   
   if ~isempty(sa) & sa == 1
      yzx = xyz;
      xyz_str = 'yzx';
   elseif ~isempty(sa) & sa == 0
      xzy = xyz;
      xyz_str = 'xzy';
   end

   try
     save (rf_plot_file, 'selected_files', 'st_data', 'st_data_mean', 'st_evt_list', 'xyz', 'neighbor_size', 'neighbor_numbers', 'normalized', 'residualized', 'LV' );
   catch
     msg = sprintf('Cannot save the response function data to %s',rf_plot_file);
     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
     status = 0;
     return;
   end;

   return;                                      % save_response_fn


%--------------------------------------------------------------------------
%
function  save_response_fn2()

%  data_option = 1  - plot individual ST datamat
%  data_option = 2  - plot group data
%  data_option = 3  - plot all data

   lag = getappdata(gcf,'lag');

   popup_h = findobj(gcf,'Tag','STDatamatPopup');
   selected_idx = get(popup_h,'value');
   data_option = get(popup_h,'Userdata');

   st_filenames = getappdata(gcf,'STFiles');

   st_data = getappdata(gcf,'ST_data');
%   st_data = mean(st_data, 2);		% export mean data for behav measure
   [nr nc] = size(st_data);

   num_cond = length(getappdata(gcf,'SelectedCondition'));
   evt_list = getappdata(gcf,'STEvtList');

   switch (data_option)

      case {1}					% plot individual data

         all_evt_length = {};			% evt length of all datamat

         %  find all_evt_length
         %
         for i = 1:length(st_filenames)
            filename = st_filenames{i}.fullname;
            group = st_filenames{i}.group;
            if group > length(all_evt_length)
               all_evt_length {group} = [];
               old_evt_length = [];
            else
               old_evt_length = all_evt_length{group};
            end

            load(filename, 'st_evt_list');
%            old_evt_length = [old_evt_length, length(st_evt_list)];
            cond_selection = getappdata(gcf,'cond_selection');
            [tmp1 tmp2 evt_length] = ...
		fmri_mask_evt_list(st_evt_list, cond_selection);
            old_evt_length = [old_evt_length, evt_length];
            all_evt_length{group} = old_evt_length;
         end

         group = st_filenames{selected_idx}.group;

         %  calc subj position
         %
         pre_group = 0;

         for i = 1:group - 1
            pre_group = pre_group + length(all_evt_length{i});
         end

         subj = selected_idx - pre_group;

         pattern = ...
            ['<ONLY INPUT PREFIX>*_fMRI_grp',num2str(group),'_subj', ...
		num2str(group),'_behavdata1.txt'];

         [fn, pn] = rri_selectfile(pattern,'Save Behav Data');

         if isequal(fn,0)
            return;
         end;

         [tmp fn] = fileparts(fn);

         first = 1;

         i = group;					% we know grp#
            j = subj;					% we know subj#

               behavdata = zeros(num_cond, nc);

               evt_length = all_evt_length{i}(j);
               last = first + evt_length - 1;
               subj_st_data = st_data(first:last,:);

               run = evt_length / num_cond;		% run# in subj

               if run ~= 1				% avg across run
                  head = 1;
                  for k = 1:num_cond
                     tail = head + run - 1;
                     behavdata(k,:) = mean(subj_st_data(head:tail,:), 1);
                     head = head + run;
                  end
               else
                  behavdata = subj_st_data;
               end

               first = first + evt_length;

%               behavdata = behavdata(:,lag+1);

               %  write behav data to file
               %
               rf_plot_file = fullfile(pn, ...
                  sprintf('%s_fMRI_grp%d_subj%d_behavdata1.txt',fn,i,j));
               behavdata = double(behavdata);
               save (rf_plot_file, '-ascii', 'behavdata');

      case {2}					% plot group data

         pattern = ...
            ['<ONLY INPUT PREFIX>*_fMRI_grp',num2str(selected_idx),'_subj1_behavdata2.txt'];

         [fn, pn] = rri_selectfile(pattern,'Save Behav Data');

         if isequal(fn,0)
            return;
         end;

         [tmp fn] = fileparts(fn);

         all_evt_length = {};			% evt length of all datamat

         %  find all_evt_length
         %
         for i = 1:length(st_filenames)
            filename = st_filenames{i}.fullname;
            group = st_filenames{i}.group;
            if group > length(all_evt_length)
               all_evt_length {group} = [];
               old_evt_length = [];
            else
               old_evt_length = all_evt_length{group};
            end

            load(filename, 'st_evt_list');
%            old_evt_length = [old_evt_length, length(st_evt_list)];
            cond_selection = getappdata(gcf,'cond_selection');
            [tmp1 tmp2 evt_length] = ...
		fmri_mask_evt_list(st_evt_list, cond_selection);
            old_evt_length = [old_evt_length, evt_length];
            all_evt_length{group} = old_evt_length;
         end

         %  find st_data for the subj
         %
         first = 1;

         i = selected_idx;				% we know grp#
            for j = 1:length(all_evt_length{i})		% all subj

               behavdata = zeros(num_cond, nc);

               evt_length = all_evt_length{i}(j);
               last = first + evt_length - 1;
               subj_st_data = st_data(first:last,:);

               run = evt_length / num_cond;		% run# in subj

               if run ~= 1				% avg across run
                  head = 1;
                  for k = 1:num_cond
                     tail = head + run - 1;
                     behavdata(k,:) = mean(subj_st_data(head:tail,:), 1);
                     head = head + run;
                  end
               else
                  behavdata = subj_st_data;
               end

               first = first + evt_length;

%               behavdata = behavdata(:,lag+1);

               %  write behav data to file
               %
               rf_plot_file = fullfile(pn, ...
                  sprintf('%s_fMRI_grp%d_subj%d_behavdata2.txt',fn,i,j));
               behavdata = double(behavdata);
               save (rf_plot_file, '-ascii', 'behavdata');
         
            end

      case {3}					% plot all data

         pattern = ...
            ['<ONLY INPUT PREFIX>*_fMRI_grp1_subj1_behavdata3.txt'];

         [fn, pn] = rri_selectfile(pattern,'Save Behav Data');

         if isequal(fn,0)
            return;
         end;

         [tmp fn] = fileparts(fn);

         all_evt_length = {};			% evt length of all datamat

         %  find all_evt_length
         %
         for i = 1:length(st_filenames)
            filename = st_filenames{i}.fullname;
            group = st_filenames{i}.group;
            if group > length(all_evt_length)
               all_evt_length {group} = [];
               old_evt_length = [];
            else
               old_evt_length = all_evt_length{group};
            end

            load(filename, 'st_evt_list');
%            old_evt_length = [old_evt_length, length(st_evt_list)];
            cond_selection = getappdata(gcf,'cond_selection');
            [tmp1 tmp2 evt_length] = ...
		fmri_mask_evt_list(st_evt_list, cond_selection);
            old_evt_length = [old_evt_length, evt_length];
            all_evt_length{group} = old_evt_length;
         end

         %  find st_data for the subj
         %
         first = 1;

         for i = 1:length(all_evt_length)		% all grp
            for j = 1:length(all_evt_length{i})		% all subj

               behavdata = zeros(num_cond, nc);

               evt_length = all_evt_length{i}(j);
               last = first + evt_length - 1;
               subj_st_data = st_data(first:last,:);

               run = evt_length / num_cond;		% run# in subj

               if run ~= 1				% avg across run
                  head = 1;
                  for k = 1:num_cond
                     tail = head + run - 1;
                     behavdata(k,:) = mean(subj_st_data(head:tail,:), 1);
                     head = head + run;
                  end
               else
                  behavdata = subj_st_data;
               end

               first = first + evt_length;

%               behavdata = behavdata(:,lag+1);

               %  write behav data to file
               %
               rf_plot_file = fullfile(pn, ...
                  sprintf('%s_fMRI_grp%d_subj%d_behavdata3.txt',fn,i,j));
               behavdata = double(behavdata);
               save (rf_plot_file, '-ascii', 'behavdata');
         
            end
         end

   end;

   return;                                      % save_response_fn2


%--------------------------------------------------------------------------
%
function  plot_response_fn_resid()

   neighbor_numbers = 1;

   emp_st_data = 0;
   set(findobj(gcf,'tag','Stable'),'Userdata',0,'Label','&Stable off');



   st_datamat = getappdata(gcf,'STDatamat_resid');

   %  Entire datamat must be saved, although a portion might be selected
   %
   if isempty(st_datamat)

      set(findobj(gcf,'Tag','MessageLine'),'String','Loading data ... ');

      st_filename = getappdata(gcf,'STFiles');

      for i=1:length(st_filename),
         selected_files{i} = st_filename{i}.fullname;
      end;

      [st_datamat,st_coords,st_win_size,st_evt_list] = ...
				merge_st_datamat(selected_files);

      cond_selection = getappdata(gcf,'cond_selection');
      mask = fmri_mask_evt_list(st_evt_list, cond_selection);
      st_datamat = st_datamat(mask,:);
      setappdata(gcf,'STDatamat_resid',st_datamat);

      set(findobj(gcf,'Tag','MessageLine'),'String','');
   end



   st_win_size = getappdata(gcf,'STWinSize');
   st_coords = getappdata(gcf,'STCoords');	% common_coord from result file

   num_pts_plotted = getappdata(gcf,'NumPtsPlotted');
   if isempty(num_pts_plotted)
      num_pts_plotted = st_win_size;
      setappdata(gcf,'NumPtsPlotted',num_pts_plotted);
   elseif (num_pts_plotted > st_win_size),
      num_pts_plotted = st_win_size;
   end;

%   xyz = getappdata(gcf,'XYZ');
%   lag = getappdata(gcf,'lag');

   %  extract the currect ploting data
   %
   cur_coord = getappdata(gcf,'Coord');
   if isempty(cur_coord)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%       return;
       emp_st_data = 1;
   end;

   coord_idx = find(st_coords == cur_coord);	% idx of cur_coord in common

   if isempty(coord_idx)
       msg = 'ERROR: The selected point is outside the brain region.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%       return;
       emp_st_data = 1;
   end;

   %  Get Neighborhood Size
   h = findobj(gcf,'Tag','neighborhoodEdit');
   neighbor_size = round(str2num(get(h,'String')));

   if isempty(neighbor_size) | ~isnumeric(neighbor_size)
      neighbor_size = 0;
   end

   %  Do neighborhood mean only if there is any neighborhood
   %
   if neighbor_size > 0

      CallBackFig = getappdata(gcf,'CallBackFig');
      CurrLVIdx = getappdata(CallBackFig,'CurrLVIdx');
      dims = getappdata(CallBackFig,'STDims');

      %  Get neighborhood XYZs
      %
      xyz = rri_coord2xyz(cur_coord, dims);

      x1 = xyz(1) - neighbor_size;
      if x1 < 1, x1 = 1; end;

      x2 = xyz(1) + neighbor_size;
      if x2 > dims(1), x2 = dims(1); end;

      y1 = xyz(2) - neighbor_size;
      if y1 < 1, y1 = 1; end;

      y2 = xyz(2) + neighbor_size;
      if y2 > dims(2), y2 = dims(2); end;

      z1 = xyz(3) - neighbor_size;
      if z1 < 1, z1 = 1; end;

      z2 = xyz(3) + neighbor_size;
      if z2 > dims(4), z2 = dims(4); end;

      %  Get neighborhood coords relative to whole volume
      %
      neighbor_coord = [];

      for k = z1:z2
         for j=y1:y2
            for i=x1:x2
               neighbor_coord = [neighbor_coord, rri_xyz2coord([i j k], dims)];
            end
         end
      end

      %  If "Cluster Mask" is checked, cluster masked voxels will be used
      %  as a criteria to select surrounding voxels
      %
      isbsr = getappdata(CallBackFig,'ViewBootstrapRatio');

      if isbsr
         cluster_info = getappdata(CallBackFig, 'cluster_bsr');
      else
         cluster_info = getappdata(CallBackFig, 'cluster_blv');
      end

      %  Get cluster voxels coords relative to whole volume
      %
      if length(cluster_info) < CurrLVIdx
         cluster_info = [];
      else
         cluster_info = cluster_info{CurrLVIdx};
         cluster_info = cluster_info.data{1}.idx;
      end

      %  If "Bootstrap" is computed, voxels that meet the bootstrap ratio
      %  threshold will be used as a criteria to select surrounding voxels
      %
      BSThreshold = getappdata(CallBackFig,'BSThreshold');
      BSThreshold2 = getappdata(CallBackFig,'BSThreshold2');

      if ~isempty(BSThreshold)
         BSRatio = getappdata(CallBackFig,'BSRatio');
         BSRatio = BSRatio(:,CurrLVIdx);

         all_voxel = zeros(1,prod(dims));
         bsr_gt_thresh = (BSRatio > BSThreshold) | (BSRatio < BSThreshold2);
         bsr_gt_thresh = reshape(bsr_gt_thresh, [st_win_size, round(length(bsr_gt_thresh)/st_win_size)]);
%         all_voxel(st_coords) = bsr_gt_thresh(lag+1,:);
         all_voxel(st_coords) = sum(bsr_gt_thresh, 1);

         bsridx = find(all_voxel);
      else
         bsridx = [];
      end

      %  Only including surrounding voxels that meet the bootstrap ratio
      %  threshold, or are part of cluster masked voxels
      %
      bsr_cluster_coords = unique([cluster_info bsridx cur_coord]);

      %  Intersect of neighborhood coord "neighbor_coord" and 
      %  "bsr_cluster_coords"
      %
      neighbor_coord = intersect(neighbor_coord, bsr_cluster_coords);

   else

      neighbor_coord = cur_coord;

   end;		% if neighbor_size > 0

   %  find out neighborhood indices in st_datamat
   %
   [ncoord ncoord_idx] = intersect(st_coords, neighbor_coord);

   neighbor_numbers = length(ncoord_idx);
   h = findobj(gcf,'Tag','neighbornumberEdit');
   set(h,'String',num2str(neighbor_numbers));

%   st_datamat = getappdata(gcf,'STDatamat');	% indexed by common_coord

   [nr,nc] = size(st_datamat);
   cols = nc / st_win_size;

   if emp_st_data
      st_data = [];
   else
      st_data = reshape(st_datamat,[nr,st_win_size,cols]);
      st_data = mean(st_data(:,[1:num_pts_plotted],ncoord_idx),3);
   end



   %  Calculate residual
   %
   main_fig = getappdata(gcf,'CallBackFig');
   PLSresultFile = get(findobj(main_fig,'Tag','ResultFile'),'UserData');
   load(PLSresultFile,'result');
   dlv = result.v;
   lv = getappdata(main_fig,'CurrLVIdx');
   num_subj_lst = getappdata(main_fig,'subj_group');
   num_cond = sum(getappdata(main_fig,'cond_selection'));

   designlv_expanded = [];

   for g = 1:length(num_subj_lst)
%      tmp = rri_expandvec(dlv(1:num_cond,:), num_subj_lst(g));
      tmp = repmat(dlv(1:num_cond,:), [num_subj_lst(g) 1]);
      designlv_expanded = [designlv_expanded; tmp];
      dlv(1:num_cond,:) = [];
   end

   newdata = st_data;

   for i = 1:lv-1
      newdata = residualize(designlv_expanded(:,i), newdata);
   end

   st_files = getappdata(gcf,'STFiles');
   conditions = getappdata(gcf,'Conditions');

   h = findobj(gcf,'Tag','PlotButton');
   if strcmp(lower(get(h,'Enable')),'off'),  return; end;

   h = findobj(gcf,'Tag','STDatamatPopup');
   selected_idx = get(h,'Value');
   data_option = get(h,'Userdata');

   switch (data_option)
      case {1},					% individual file
         first = (selected_idx - 1) * num_cond + 1;
         last = first + num_cond - 1;
         st_data = newdata(first:last,:);
         st_evt_list = 1:num_cond;
      case {2},					% group data
         cum_subj_lst = [0 cumsum(num_subj_lst)];

         first = cum_subj_lst(selected_idx) * num_cond + 1;
         last = first + num_subj_lst(selected_idx) * num_cond - 1;
         st_data = newdata(first:last,:);
         st_evt_list = 1:num_cond;
         st_evt_list = repmat(st_evt_list, [1 num_subj_lst(selected_idx)]);
      case {3},					% all data
         st_data = newdata;
         st_evt_list = 1:num_cond;
         st_evt_list = repmat(st_evt_list, [1 sum(num_subj_lst)]);
   end;

   if emp_st_data
      st_data = [];
   else
      h = findobj(gcf,'Tag','NormalizePlots');
      normalize_flg = get(h,'UserData');
      if (normalize_flg == 1),
         max_st_data = max(st_data,[],2);
         min_st_data = min(st_data,[],2);

         max_mtx = max_st_data(:,ones(1,num_pts_plotted));
         min_mtx = min_st_data(:,ones(1,num_pts_plotted));
         scale_factor = max_mtx - min_mtx;
         st_data = (st_data - min_mtx) ./ scale_factor;
      end;
   end



   bsr = getappdata(gcf,'org_bsr');
   bs_thresh = getappdata(gcf,'bs_thresh');
   bs_thresh2 = getappdata(gcf,'bs_thresh2');

   if ~isempty(bsr)
      [r c] = size(bsr);
      bsr = reshape(bsr, [st_win_size, r/st_win_size, c]);
      bsr = squeeze(bsr([1:num_pts_plotted],coord_idx,:));
      set(findobj(gcf,'tag','Stable'), 'enable', 'on');
   end 


   selected_condition = getappdata(gcf,'SelectedCondition');
   num_conditions = length(selected_condition);
   condition = cell(1,num_conditions);  

   max_num_stim = 0;
   for i=1:num_conditions,
      condition{i}.st_row_idx  = find(st_evt_list == i);
      condition{i}.num_stim = length(condition{i}.st_row_idx);
      condition{i}.name = conditions{i};
      if (max_num_stim < condition{i}.num_stim)
          max_num_stim = condition{i}.num_stim;
      end;
   end;


   % generate the plots
   %
   plot_cond_idx = find(selected_condition == 1);

   plot_dims = getappdata(gcf,'PlotDims');
   if isempty(plot_dims) 
       if (num_conditions < 5)
         num_rows = num_conditions;
       else
         num_rows = 5;
       end;
       if (max_num_stim < 4),
         num_cols = max_num_stim;
       else
         num_cols = 4;
       end;
       plot_dims = [num_rows num_cols];
   end;

   axes_margin = [.37 .13 .15 .1];

   fmri_plot_cond_stim_ui('STARTUP', st_data, condition,  ...
		axes_margin, plot_dims, plot_cond_idx, bsr, bs_thresh, bs_thresh2);

   setappdata(gcf,'STEvtList',st_evt_list);
   setappdata(gcf,'PLS_PLOT_COND_STIM_ACTIVE',1);
   setappdata(gcf, 'ncoord_idx', ncoord_idx);
   setappdata(gcf, 'ncoord', ncoord);
   set(findobj(gcf,'Tag','PlotMenu'),'Enable','on');
   set(findobj(gcf,'Tag','OptionMenu'),'Enable','on');
   set(findobj(gcf,'Tag','DataMenu'),'Enable','on');

   return;					% plot_response_fn_resid

