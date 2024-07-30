%
% nov 25,2003 jimmy: response_fn should use common_coords to detect brain
%	voxel (common_coords in this file), and use org. datamat coords to 
%	get the voxel location in that datamat (st_coords in this file).
%
% apr 13,2005 jimmy: above change does not apply to bfm_plot_rf_task, because
%	st_datamat here only contains common_coords. Also see 
%	load_voxel_intensity to see how st_datamat get only common_coords. 
%
%------------------------------------------------------------------------
function fig = bfm_plot_rf_task(action,varargin)
%
% bfm_plot_rf_task(action,action_arg1,...)

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

      PLSresultFile = varargin{1};
      init(PLSresultFile);
      gen_condition_chk_box(1);
      SetObjPosition;

      return;
  elseif strcmp(action,'LINK')			    % call from other figure

      PLSresultFile = varargin{1};
      fig = init(PLSresultFile);
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

      if ~getappdata(gcbf,'actualHRF')	%getappdata(gcbf,'isbehav')
         plot_datamatcorrs;
      else
         plot_response_fn;
      end

  elseif strcmp(action,'change_group')
      change_group;

  elseif strcmp(action,'NewCoord')
      new_coord = varargin{1};
      new_xyz = varargin{2};
      setappdata(gcf,'Coord',new_coord);
      setappdata(gcf,'XYZ',new_xyz);
      setappdata(gcf, 'axis_scale', []);

      if ~getappdata(gcbf,'actualHRF')	%getappdata(gcbf,'isbehav')
         plot_datamatcorrs;
      else
         plot_response_fn;
      end

  elseif strcmp(action,'PlotBnPress')
      old_pointer = get(gcf,'Pointer');
      set(gcf,'pointer','watch');
      coord = getappdata(gcf,'Coord');
      plot_response_fn;
%      set(gcf,'pointer','arrow');
      set(gcf,'Pointer',old_pointer);
  elseif strcmp(action,'SliderMotion')
      condition_update;
  elseif strcmp(action,'ResizeFigure')
      resize_fig;
  elseif strcmp(action,'DeleteFigure')
      delete_fig;
  elseif strcmp(action,'MENU_ExportData')
      save_response_fn;
  elseif strcmp(action,'MENU_ExportBehavData')
      save_response_fn2;
  elseif strcmp(action,'MENU_ExportDataBehav')
      save_response_behav;
  elseif strcmp(action,'zoom')
         zoom_on_state = get(gcbo,'Userdata');
         if (zoom_on_state == 1)                   % zoom on
            zoom on;
            set(gcbo,'Userdata',0,'Label','&Zoom off');
            set(gcf,'pointer','crosshair');
         else                                      % zoom off
            zoom off;
            set(gcbo,'Userdata',1,'Label','&Zoom on');
            set(gcf,'pointer','arrow');
         end
  elseif strcmp(action,'residualized')
      main_fig = getappdata(gcf,'CallBackFig');
      lv = getappdata(main_fig,'CurrLVIdx');

      if 0 % lv < 2
         set(findobj(gcf,'tag','residualized'),'value',0);
         msg = 'You cannot select this checkbox if LV is less than 2.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      else
         plot_response_fn;
      end
  end;

  return;


%--------------------------------------------------------------------------
%
function fig = init(PLSresultFile)

   CallBackFig = gcbf;
   cond_selection = getappdata(gcf,'cond_selection');

   result_file = get(findobj(gcf,'tag','ResultFile'),'UserData');

   load( result_file );

   if exist('result','var')
      if isfield(result,'bscan')
         bscan = result.bscan;
      end
   end

if 0
   try 
      warning off;
      load( result_file, 'bscan' );
      warning on;
   catch
   end;
end

   if exist('bscan','var') & ~isempty(bscan) & ~getappdata(gcbf,'actualHRF')
      selected_conditions = find(cond_selection);
      selected_conditions = selected_conditions(bscan);
      cond_selection = zeros(1,length(cond_selection));
      cond_selection(selected_conditions) = 1;
   end

   save_setting_status = 'on';
   bfm_plot_rf_task_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(bfm_plot_rf_task_pos) & strcmp(save_setting_status,'on')

      pos = bfm_plot_rf_task_pos;

   else

      w = 0.8;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   hh = figure('Units','normal', ...
	   'Name','Voxel Intensity Plot', ...	
	   'Menubar', 'none', ...
	   'NumberTitle','off', ...
	   'Color', [0.8 0.8 0.8], ...
 	   'DoubleBuffer','on', ...
	   'DeleteFcn', 'bfm_plot_rf_task(''DeleteFigure'');', ...
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
           'CallBack', 'bfm_plot_rf_task(''PlotBnPress'');', ...
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

   %  display 'Datamat: '
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

   %  create Datamat popup menu
   %
   y = 0.72;

   pos = [x y w h];

   cb_fn = [ 'bfm_plot_rf_task(''change_group'');'];
   popup_h = uicontrol('Parent',hh, ...
   	   'units','normal', ...
	   'FontUnits', 'normal', ...
	   'FontSize', fnt, ...
           'Style', 'popupmenu', ...
	   'Position', pos, ...
           'HorizontalAlignment', 'left',...
	   'String', ' ', ...
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
   w = 0.1;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontUnits', 'normal', ...
          'FontSize', fnt, ...
          'Style', 'push', ...
	  'Position', pos, ...
          'String', 'Plot', ...
   	  'Enable', 'off', ...
	  'visible', 'off', ...
	  'Tag', 'PlotButton', ...
          'CallBack', 'bfm_plot_rf_task(''PlotBnPress'');');

   x = 0.1;
   y = 0.08;
   w = 0.06;

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
          'CallBack', 'bfm_plot_rf_task(''residualized'');', ...
	  'Tag', 'residualized');

   try
      load(get(findobj(gcbf,'Tag','ResultFile'),'UserData'),'method');
   catch
   end

   holdoffresidual = 1;

   if holdoffresidual
      set(h0, 'visible', 'off');
   elseif isempty(findstr(SessionProfiles{1}{1}, 'sessiondata.mat')) | ...
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


   %  file menu
   %
   rri_file_menu(hh);

   %  zoom
   %
   h2 = uimenu('parent',hh, ...
        'userdata', 1, ...
        'callback','bfm_plot_rf_task(''zoom'');', ...
        'label','&Zoom on');

  h_plot = uimenu('Parent',hh, ...
	     'Label','&Plot', ...
             'Enable','on',...
		'visible', 'off', ...
	     'Tag','PlotMenu');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot individual datamat', ...
	     'Tag','PlotIndividualData', ...
	     'Callback','bfm_plot_rf_task(''MENU_PlotIndividualData'');');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot group data', ...
	     'Tag','PlotGroupData', ...
		'visible', 'off', ...
	     'Callback','bfm_plot_rf_task(''MENU_PlotGroupData'');');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot all data', ...
	     'Tag','PlotAllData', ...
	     'Callback','bfm_plot_rf_task(''MENU_PlotAllData'');');

  h_option = uimenu('Parent',hh, ...
	     'Label','&Data', ...
	     'Tag','DataMenu', ...
             'Enable','on',...
	     'Visible','off');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Export data', ...
	     'Tag','ExportData', ...
	     'Callback','bfm_plot_rf_task(''MENU_ExportData'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Export data for behav analysis', ...
	     'Tag','ExportBehavData', ...
		'visible', 'off', ...
	     'Callback','bfm_plot_rf_task(''MENU_ExportBehavData'');');

  h_option = uimenu('Parent',hh, ...
	     'Label','&Data', ...
	     'Tag','DataMenuBehav', ...
             'Enable','on',...
	     'Visible','off');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Export data', ...
	     'Tag','ExportDataBehav', ...
	     'Callback','bfm_plot_rf_task(''MENU_ExportDataBehav'');');

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
   setappdata(CallBackFig,'VoxelIntensityFig',hh);
   setappdata(hh,'VoxelIntensityFig',hh);

   setappdata(hh,'cond_selection',cond_selection);

  % construct the popup label list
  %
  % get_st_datamat_filename(PLSresultFile);
  % make_datamat_popup(1);

  if (nargout >= 1),
     fig = hh;
  end;

  setappdata(gcf, 'sa', getappdata(gcbf, 'sa'));
  setappdata(gcf, 'isbehav', getappdata(gcbf,'isbehav'));
  setappdata(gcf, 'actualHRF', getappdata(gcbf,'actualHRF'));

  if ~getappdata(gcbf,'actualHRF')	%getappdata(gcbf,'isbehav')
     set(gcf, 'name', 'Datamat Correlations');
     load_datamatcorrs(PLSresultFile);
  else
     load_voxel_intensity(PLSresultFile);
  end

  return;


%--------------------------------------------------------------------------
%
function gen_condition_chk_box(selected_idx)

  num_cond = getappdata(gcf,'num_cond');
  cname = getappdata(gcf,'cond_name');

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

     %  create the condition check box
     %
     h1 = uicontrol('Parent',gcf, ...
   	   'Units','normal', ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
	   'Value', 1, ...
           'Style', 'text', ...
	   'String', sprintf(' (%d)  %s', i,cname{i}), ...
           'HorizontalAlignment', 'left',...
           'SelectionHighlight', 'off',...
	   'FontSize', 10, ...
	   'Tag', sprintf('Condition%d',i));

%           'Style', 'check', ...
%	   'Callback',cbf);

     h_list = [h_list h1];

  end;

  set(h0,'UserData',h_list);

  %  set up the scroll bar for the conditions
  %
  h1 = uicontrol('Parent',gcf, ...
           'Style', 'slider', ...
   	   'Units','normal', ...
	   'Tag', 'CondSlider', ...
	   'Callback','bfm_plot_rf_task(''SliderMotion'');');

  SetObjPosition('ConditionChkBoxes');

  setappdata(gcf,'SelectedCondition',ones(1,num_cond));

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

     bfm_plot_rf_task_pos = get(gcbf,'position');

     save(pls_profile, '-append', 'bfm_plot_rf_task_pos');
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

   hh = getappdata(gcf,'VoxelIntensityFig');
   obj = getappdata(hh,'ObjPosition');

   % set the positions for all objects
   %
   if ~exist('ObjName','var') | isempty(ObjName) 
      ObjName = 'STDatamat';
   end;

   if strcmp(ObjName,'STDatamat') | strcmp(ObjName,'ALL'),
      for i=1:length(obj),
         obj_pos = obj(i).pos;
         obj_pos(2) = 1 - obj_pos(2);
         set(findobj(hh,'Tag',obj(i).name),'Position',obj_pos);
      end;
   end;

   %  set positions for the condition check box
   %
   if strcmp(ObjName,'ConditionChkBoxes')  | strcmp(ObjName,'ALL'),

      % find the position of the PLOT Button
      plot_pos = get(findobj(hh,'Tag', 'PlotButton'),'Position');

      lowest_v_pos = plot_pos(2) + plot_pos(4) * 1.5;

      chk_box_hlist = get(findobj(hh,'Tag','ConditionLabel'),'UserData');
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
      h = findobj(hh,'Tag', 'CondSlider');
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

   st_filenames = getappdata(gcf,'STFiles')

   switch (data_option)

     case {2}					% plot individual data
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

     case {1}					% plot group data
        num_group = st_filenames{end}.group;
        popup_list = cell(1,num_group);
	for i=1:num_group,
           popup_list{i} = sprintf('[ Group #%d ]',i);
	end;
        alignment = 'left';

     case {3}					% plot all data
        popup_list{1} = '< All Data >';
        alignment = 'center';

   end;

   set(popup_h,'String',popup_list,'Userdata',data_option, ...
               'HorizontalAlignment', alignment,'Value',1);

   msg = 'Click a voxel to see the plot';
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
function get_st_datamat_filename(DatamatFileList)
%
%   INPUT:
%       sessionFileList - vector of cell structure, each element contains
%                         the full path of a session file.
%

  num_groups = length(DatamatFileList);

  for i=1:num_groups,
     fn = DatamatFileList{i};
     load( fn, 'session_info', 'selected_conditions' );

     [pname, fname] = fileparts(fn);
     st_filename{i}.name = fname;
     st_filename{i}.fullname = fn;
     st_filename{i}.group = i;
     st_filename{i}.profile = session_info;
     st_filename{i}.selected_conditions = selected_conditions;
  end;

  setappdata(gcf,'STFiles',st_filename);

  return;                                       % get_st_datamat_filename


%--------------------------------------------------------------------------
%
function  [raw_datamat,coords,num_subj,subj_name,behavname] = ...
						load_plotted_datamat

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');


   selected_files = get_selected_filename;

   if (length(selected_files) == 1)
       warning off;
       load(selected_files{1},'raw_datamat','coords','session_info', ...
					'behavdata','behavname');
       warning on;

       if ~exist('behavname','var')
          behavname = {};

          if exist('behavdata','var')
             for i=1:size(behavdata, 2)
                behavname = [behavname, {['behav', num2str(i)]}];
             end
          end
       end

       num_subj = session_info.num_subjects;
       subj_name = session_info.subj_name;
   else					%  merge files together
%       [st_datamat,st_coords,st_win_size,st_evt_list] =  ...
%                                   merge_st_datamat(selected_files);
       [tmp,datmat,coords,dims,num_cond_lst,num_subj_lst,...
		voxel_size,origin] = pet_get_common(selected_files);
   end;

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
      case {1}, 		% individual file
	 selected_files{1} = st_filename{selected_idx}.fullname;

      case {3},					% all data
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
   %  
   load(selected_files{1},'st_dims','st_win_size'); 
   total_num_evt = 0;
   m = zeros(st_dims);
   for i=1:num_files,
      load(selected_files{i},'st_coords','st_evt_list');
      total_num_evt = total_num_evt + length(st_evt_list); 
      m(st_coords) = m(st_coords) + 1; 
   end;
   coords = find(m == num_files); 


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

      coord_idx = find(m(st_coords) == num_files);
      nr = length(st_evt_list);
      nc = length(st_coords);
      last_row = nr + first_row - 1;

      tmp_datamat = reshape(st_datamat,[nr,win_size,nc]); 
      tmp_datamat = reshape(tmp_datamat(:,:,coord_idx),[nr,num_cols]);

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

   h = findobj(gcf,'Tag','STDatamatPopup');
   popup_string = get(h,'String');
   selected_idx = get(h,'Value');
   selected_data = popup_string{selected_idx};


   %  change datamat if necessary
   %
   last_datamat = getappdata(gcf,'PlottedDatamat');
   last_resid = getappdata(gcf,'last_resid');
   setappdata(gcf,'last_resid',0);
   is_resid = get(findobj(gcf,'tag','residualized'),'value');

   if strcmp(last_datamat,selected_data) == 0 | ~isequal(last_resid,is_resid)

      datamat_lst = getappdata(gcf,'datamat_lst');
      num_subj_lst = getappdata(gcf,'num_subj_lst');
      subj_name_lst = getappdata(gcf,'subj_name_lst');

      st_datamat = datamat_lst{selected_idx};
      num_subj = num_subj_lst(selected_idx);
      subj_name = subj_name_lst{selected_idx};

      setappdata(gcf,'PlottedDatamat',selected_data);
      setappdata(gcf,'STDatamat', st_datamat);
      setappdata(gcf,'num_subj', num_subj);
      setappdata(gcf,'subj_name', subj_name);

      set(findobj(gcf,'Tag','MessageLine'),'String','');
   else
      st_datamat = getappdata(gcf,'STDatamat'); 
      num_subj = getappdata(gcf,'num_subj');
      subj_name = getappdata(gcf,'subj_name');
   end;


   neighbor_numbers = 1;

   axes_margin = [.37 .05 .15 .1];

   % set up axes, and the values of 'AxesMargin', 'AxesHlds' and 'AxesPos'
   %
   setappdata(gcf,'AxesMargin',axes_margin);
   set_cond_axes(1,1,axes_margin);     % set up axes

   %  extract the currect ploting data
   %
   cur_coord = getappdata(gcf,'Coord');
   if isempty(cur_coord)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       set(gca,'visible','off');
       return;
   end;

   %  find out the coord_idx
   %
   st_coords = getappdata(gcf,'STCoords');
   common_coords = getappdata(gcf,'common_coords');

   coord_idx = find(common_coords == cur_coord);
   if isempty(coord_idx)
       msg = 'ERROR: The selected point is outside the brain region.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       set(gca,'visible','off');
       return;
   end;

   %  in blocked fmri, st_datamat only contain common_coords (because 
   %  the each group needs to be averaged). So, the following statement
   %    < because each block needs to be averaged? >
   %  is commneted. Also see load_voxel_intensity to see how st_datamat
   %  get only common_coords. 13-Apr-2005
   %
%   coord_idx = find(st_coords == cur_coord);

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
         all_voxel(common_coords) = (BSRatio > BSThreshold) | (BSRatio < BSThreshold2);
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
   [ncoord ncoord_idx] = intersect(common_coords, neighbor_coord);

   neighbor_numbers = length(ncoord_idx);
   h = findobj(gcf,'Tag','neighbornumberEdit');
   set(h,'String',num2str(neighbor_numbers));

   st_data = st_datamat;
   selected_condition = getappdata(gcf,'SelectedCondition');

   % generate the plots
   %
   cond_idx = find(selected_condition == 1);

   setappdata(gcf,'ST_data',st_data);
   setappdata(gcf,'PlotCondIdx',cond_idx);

   if isempty(getappdata(gcf,'CombinePlots'))
      setappdata(gcf,'CombinePlots',0);
   end;

   if isempty(getappdata(gcf,'ShowAverage'))
      setappdata(gcf,'ShowAverage',0);
   end;

   %  the following code is to get an intensity array for the voxel and plot it
   %
   subjects = [subj_name, {'mean'}];

   for k = cond_idx			% cond
      for n = 1:num_subj		% subj
         j = n+(k-1)*num_subj;		% row number in datamat
         intensity(k,n) = mean(st_data(j, ncoord_idx), 2);
         intensity_hdl(k,n) = 0;	% initialization
      end
      intensity_avg_hdl(k) = 0;
   end

   intensity_avg = mean(intensity,2);

   setappdata(gcf,'intensity',intensity);
   setappdata(gcf,'intensity_avg',intensity_avg);

   color_code =[ 'bo';'rx';'g+';'m*';'bs';'rd';'g^';'m<';'bp';'r>'; ...
                 'gh';'mv';'ro';'gx';'m+';'b*';'rs';'gd';'m^';'b<'];

   % need more color
   %
   if num_subj+1 > size(color_code,1)

      tmp = [];

      for i=1:ceil((num_subj+1)/size(color_code,1))
         tmp = [tmp; color_code];
      end

      color_code = tmp;

   end

   cla; grid off; hold on;
   for k = cond_idx

      for n = 1:num_subj
         intensity_hdl(k,n) = plot(k,intensity(k,n), ...
			color_code(n,:));
      end

      intensity_avg_hdl(k) = bar(k,intensity_avg(k));
      set(intensity_avg_hdl(k),'facecolor','none')
      % set(intensity_avg_hdl(k), 'linewidth', 2);

   end

   % normalize with intensity(:), not st_data(:)
   %
   min_y = min(intensity(:)); max_y = max(intensity(:));
   margin_y = abs((max_y - min_y) / 100);

   axis_scale = getappdata(gcf, 'axis_scale');

   if isempty(axis_scale)
      axis_scale = [0 length(cond_idx)+1 min_y-margin_y max_y+margin_y];
   else
      if (min_y-margin_y)<axis_scale(3)
         axis_scale(3) = min_y-margin_y;
      end;

      if (max_y+margin_y)>axis_scale(4)
         axis_scale(4) = max_y+margin_y;
      end;
   end

   setappdata(gcf, 'axis_scale', axis_scale);
   axis(axis_scale);

   set(gca, 'xtick', cond_idx);

   xlabel('Conditions');
   ylabel('Intensities');

   xyz = getappdata(gcf,'XYZ');
   title(['Intensity for subjects and mean at voxel:  [',num2str(xyz),']']);

   hold off;

   l_hdl = [];

   if ~isempty(subjects),

      intensity_legend = [intensity_hdl(1,:), intensity_avg_hdl(1)];

      % remove the old legend to avoid the bug in the MATLAB5
      old_legend = getappdata(gcf,'LegendHdl');
      if ~isempty(old_legend),
        try
          delete(old_legend{1});
        catch
        end;
      end;

      % create a new legend, and save the handles
      [l_hdl, o_hdl] = legend(intensity_legend, subjects, 'Location','northeast');
      legend_txt(o_hdl);
      set(l_hdl,'color',[0.9 1 0.9]);
      setappdata(gcf,'LegendHdl',[{l_hdl} {o_hdl}]);

   else

      setappdata(gcf,'LegendHdl',[]);

   end;

   setappdata(gcf, 'ncoord_idx', ncoord_idx);
   setappdata(gcf, 'ncoord', ncoord);
   set(findobj(gcf,'Tag','DataMenu'),'visible','on');

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

   st_coords = getappdata(gcf,'STCoords');
   common_coords = getappdata(gcf,'common_coords');

   xyz = getappdata(gcf,'XYZ');

   %  extract the currect ploting data
   %
   cur_coord = getappdata(gcf,'Coord');
   if isempty(cur_coord)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;

   coord_idx = find(common_coords == cur_coord);
   if isempty(coord_idx)
       msg = 'ERROR: The selected point is outside the brain region.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;
%   coord_idx = find(st_coords == cur_coord);
   ncoord_idx = getappdata(gcf, 'ncoord_idx');
   neighbor_numbers = length(ncoord_idx);

   CallBackFig = getappdata(gcf,'CallBackFig');
   LV = getappdata(CallBackFig,'CurrLVIdx');
   dims = getappdata(CallBackFig,'STDims');
   ncoord = getappdata(gcf, 'ncoord');
   xyz = rri_coord2xyz(ncoord,dims);

   %  get selected file names 
   %
   st_files = getappdata(gcf,'DatamatFile');
   h = findobj(gcf,'Tag','STDatamatPopup');
   selected_idx = get(h,'Value');
   selected_files = st_files{selected_idx};

   num_cond = getappdata(gcf,'num_cond');
   num_subj_lst = getappdata(gcf,'num_subj_lst');
   num_subj = num_subj_lst(selected_idx);

   st_evt_list = [];

   for i=1:num_cond
      st_evt_list = [st_evt_list i*ones(1, num_subj)];
   end

   residualized = get(findobj(gcf,'tag','residualized'),'value');

   %  extract the data of the selected voxel
   %
   data = getappdata(gcf,'intensity');
   data_mean = getappdata(gcf,'intensity_avg');
   data = data';
   data = data(:);

   [filename, pathname] = ...
	rri_selectfile('*_BfMRI_rf_plot.mat','Save the Response Functions');

   if ischar(filename) & ~all(ismember('_bfmri_rf_plot',lower(filename)))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_BfMRI_rf_plot.mat'];
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
     save (rf_plot_file, 'selected_files', 'data', 'data_mean', 'st_evt_list', 'xyz', 'neighbor_size', 'neighbor_numbers', 'residualized', 'LV' );
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

   st_coords = getappdata(gcf,'STCoords');
   common_coords = getappdata(gcf,'common_coords');

   xyz = getappdata(gcf,'XYZ');

   %  extract the currect ploting data
   %
   cur_coord = getappdata(gcf,'Coord');
   if isempty(cur_coord)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;

   coord_idx = find(common_coords == cur_coord);
   if isempty(coord_idx)
       msg = 'ERROR: The selected point is outside the brain region.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;
%   coord_idx = find(st_coords == cur_coord);

   %  get selected file names 
   %
   st_files = getappdata(gcf,'DatamatFile');
   h = findobj(gcf,'Tag','STDatamatPopup');
   selected_idx = get(h,'Value');
   selected_files = st_files{selected_idx};

   num_cond = getappdata(gcf,'num_cond');
   num_subj_lst = getappdata(gcf,'num_subj_lst');
   num_subj = num_subj_lst(selected_idx);

   mask = 1:num_subj*num_cond;
   mask = reshape(mask, [num_subj, num_cond]);

   %  extract the data of the selected voxel
   %
   st_data = getappdata(gcf,'STDatamat');
   data = st_data(:,coord_idx);

   %  save behavdata
   %
   for i = 1:size(mask,1)
      behavdata.subject{i} = [data(mask(i,:))]';
   end;

   pattern = ...
      ['<ONLY INPUT PREFIX>*_BfMRI_grp',num2str(selected_idx),'_subj1_behavdata1.txt'];

   [filename, pathname] = rri_selectfile(pattern,'Save Behav Data');

   if isequal(filename,0)
	return;
   end;

   [tmp filename] = fileparts(filename);

   for i = 1:size(mask,1)
      rf_plot_file = fullfile(pathname, ...
	sprintf('%s_BfMRI_grp%d_subj%d_behavdata1.txt',filename,selected_idx,i));
      behavdata = double(data(mask(i,:)));
      save (rf_plot_file, '-ascii', 'behavdata');
   end

   return;                                      % save_response_fn2


%--------------------------------------------------------------------------
%
function  save_response_behav()

   xyz = getappdata(gcf,'XYZ');

   %  extract the currect ploting data
   %
   cur_coord = getappdata(gcf,'Coord');
   if isempty(cur_coord)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;

   %  find out the coord_idx
   %
   st_coords = getappdata(gcf,'STCoords');
   common_coords = getappdata(gcf,'common_coords');

   coord_idx = find(common_coords == cur_coord);
   if isempty(coord_idx)
       msg = 'ERROR: The selected point is outside the brain region.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;
   coord_idx = find(st_coords == cur_coord);

   st_data = getappdata(gcf,'datamatcorrs');
   data = st_data(:,coord_idx);

   [filename, pathname] = ...
	rri_selectfile('*_BfMRI_datamatcorr_plot.mat','Save the Response Functions');

   if ischar(filename) & ~all(ismember('_bfmri_datamatcorr_plot',lower(filename)))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_BfMRI_datamatcorr_plot.mat'];
   end

   if isequal(filename,0)
	return;
   end;
   rf_plot_file = fullfile(pathname,filename);

   try
     save (rf_plot_file, 'data', 'xyz' );
   catch
     msg = sprintf('Cannot save the response function data to %s',rf_plot_file);
     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
     status = 0;
     return;
   end;

   return;                                      % save_response_behav


%--------------------------------------------------------------------------
%
function   set_cond_axes(num_rows,num_cols,axes_margin)
%
%   Define the axes for the response functions of different conditions
%
%   axes_margin: [left right bottom top], which specified in terms of 
%                  normal unit respect to the figure;
% 

  show_avg = getappdata(gcf,'ShowAverage');
  if ~isempty(show_avg) & (show_avg == 1),
     num_cols = num_cols + 1;
  end;

  %  clear up the old handles
  %
  old_hdls = getappdata(gcf,'AxesHdls');
  if ~isempty(old_hdls)
     for i=1:length(old_hdls(:))
	 if ishandle(old_hdls{i}), delete(old_hdls{i}); end
     end; 
  end;

  old_hdls = getappdata(gcf,'AxesCombineHdls');
  if ~isempty(old_hdls)
     for i=1:length(old_hdls(:))
	 if ishandle(old_hdls{i}), delete(old_hdls{i}); end
     end; 
  end;

  f_pos = get(gcf,'Position');
  axes_boundary(1) = axes_margin(1);
  axes_boundary(2) = 1 - axes_margin(2);
  axes_boundary(3) = axes_margin(3);
  axes_boundary(4) = 1 - axes_margin(4);

  %  plot data in each axis
  %
  ax_hdls = cell(num_rows,num_cols);
  ax_pos = cell(num_rows,num_cols);
  ax_combine_hdls = cell(num_rows,1);
  ax_combine_pos = cell(num_rows,1);

  plot_width  = (axes_boundary(2) - axes_boundary(1)) / num_cols;
  plot_height = (axes_boundary(4) - axes_boundary(3)) / num_rows;
  axes_min_x = axes_boundary(1);
  axes_min_y = axes_boundary(3);

  for row=1:num_rows, 

    axes_y = axes_min_y + plot_height*(num_rows-row); 

    % for separate plots within each condition 
    %
    for col=1:num_cols,

      %  determine the position of the figure
      %
      axes_x = axes_min_x + plot_width*(col-1); 
      
      if (col == num_cols & ~isempty(show_avg) & show_avg == 1)
         axes_pos = [axes_x+0.02 axes_y plot_width-0.01 plot_height-0.03];
      else 
         axes_pos = [axes_x      axes_y plot_width-0.01 plot_height-0.03];
      end;
    
      ax = axes('units','normal','Position',axes_pos);
      set(ax,'units',get(gcf,'defaultaxesunits'));
      set(ax,'visible','off');
   
      ax_hdls{row,col} = ax;  
      ax_pos{row,col} = axes_pos;
    end,

    % for combine plots within each condition 
    %
    combine_axes_x = axes_min_x;
    combine_axes_y = axes_y;
    if (~isempty(show_avg) & show_avg == 1)
       combine_axes_w = plot_width*(num_cols-1)-0.01;
    else
       combine_axes_w = plot_width*num_cols-0.01;
    end;
    combine_axes_h = plot_height-0.03;
    
    axes_pos = [combine_axes_x combine_axes_y combine_axes_w combine_axes_h];
    ax = axes('units','normal','Position',axes_pos, ...
        'box', 'on', ...
        'tickdir', 'out', ...
        'ticklength', [0.005 0.005]);

    set(ax,'units',get(gcf,'defaultaxesunits'));
%    set(ax,'visible','off');
   
    ax_combine_hdls{row} = ax;  
    ax_combine_pos{row} = axes_pos;

  end;
  
  setappdata(gcf,'AxesHdls',ax_hdls);
  setappdata(gcf,'AxesPos',ax_pos);
  setappdata(gcf,'AxesCombineHdls',ax_combine_hdls);
  setappdata(gcf,'AxesCombinePos',ax_combine_pos);

  return; 					% set_cond_axes


%--------------------------------------------------------------------------
%
function  plot_datamatcorrs

   axes_margin = [.37 .05 .15 .1];

   % set up axes, and the values of 'AxesMargin', 'AxesHlds' and 'AxesPos'
   %
   setappdata(gcf,'AxesMargin',axes_margin);
   set_cond_axes(1,1,axes_margin);     % set up axes

   %  extract the currect ploting data
   %
   cur_coord = getappdata(gcf,'Coord');
   if isempty(cur_coord)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       set(gca,'visible','off');
       return;
   end;

   %  find out the coord_idx
   %
   st_coords = getappdata(gcf,'STCoords');
   common_coords = getappdata(gcf,'common_coords');

   coord_idx = find(common_coords == cur_coord);
   if isempty(coord_idx)
       msg = 'ERROR: The selected point is outside the brain region.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       set(gca,'visible','off');
       return;
   end;
   coord_idx = find(st_coords == cur_coord);

   num_cond = getappdata(gcf,'num_cond');
   st_data = getappdata(gcf,'datamatcorrs');
   num_behav = getappdata(gcf,'num_behav');

   % generate the plots
   %
   cond_idx = [1:num_cond];

   setappdata(gcf,'ST_data',st_data);
   setappdata(gcf,'PlotCondIdx',cond_idx);

   if isempty(getappdata(gcf,'CombinePlots'))
      setappdata(gcf,'CombinePlots',0);
   end;

   if isempty(getappdata(gcf,'ShowAverage'))
      setappdata(gcf,'ShowAverage',0);
   end;

   behavname = getappdata(gcf,'behavname');

   for k = cond_idx			% cond
      for n = 1:num_behav		% behav
         j = n+(k-1)*num_behav;		% row number in datamat
         intensity(j) = st_data(j, coord_idx);
      end
   end

   mask = [];

   for i=1:num_behav
      for j=1:num_cond
         mask = [mask (j-1)*num_behav+i];
      end
   end

   cla;grid on;box on;hold on;

   load('rri_color_code');

   for i=1:num_behav
      for j=1:num_cond
         k = (i-1)*num_cond + j;
         bar_hdl = bar(k, intensity(mask(k)));
         set(bar_hdl,'facecolor',color_code(j,:));
      end
   end

   min_x = 0.5;		max_x = num_cond * num_behav + 0.5;
   min_y =-1;		max_y = 1;
   margin_x = abs((max_x - min_x) / 20);
   margin_y = abs((max_y - min_y) / 20);

   axis([min_x-margin_x,max_x+margin_x,min_y-margin_y,max_y+margin_y]);

   set(gca,'xtick',[1:num_cond:num_cond*num_behav]);

   cond_name = getappdata(gcf,'cond_name');

   set(gca,'xticklabel',behavname);

   ylabel('Correlation');

   xyz = getappdata(gcf,'XYZ');
   title(['Datamat correlations at voxel:  [',num2str(xyz),']']);

   hold off;

   l_hdl = [];

   if ~isempty(cond_name),

      % remove the old legend to avoid the bug in the MATLAB5
      old_legend = getappdata(gcf,'LegendHdl');
      if ~isempty(old_legend),
        try
          delete(old_legend{1});
        catch
        end;
      end;

      % create a new legend, and save the handles
      [l_hdl, o_hdl] = legend(cond_name, 'Location', 'northeast');
      legend_txt(o_hdl);
      set(l_hdl,'color',[0.9 1 0.9]);
      setappdata(gcf,'LegendHdl',[{l_hdl} {o_hdl}]);

   else

      setappdata(gcf,'LegendHdl',[]);

   end;

   set(findobj(gcf,'Tag','DataMenuBehav'),'visible','on');

   return;						% plot_datamatcorrs


%--------------------------------------------------------------------------
%
function load_datamatcorrs(PLSresultFile)

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

if 0
   warning off;
   load(PLSresultFile, 'datamatcorrs_lst', 'num_subj_lst', 'behavname', ...
	'num_conditions', 'st_coords', 'cond_name', 'subj_name', 'bscan');
   warning on;
end

   load(PLSresultFile);

   if exist('result','var')
      if isfield(result,'datamatcorrs_lst')
         datamatcorrs_lst = result.datamatcorrs_lst;
      end

      if isfield(result,'bscan')
         bscan = result.bscan;
      end

      num_subj_lst = result.num_subj_lst;
      num_conditions = result.num_conditions;
   end


   common_coords = st_coords;

   if ~exist('datamatcorrs_lst', 'var')
uiwait(msgbox('Need use new version to run PLS analysis again in order to get the correlation file'));
      return;
   end


     cond_selection = getappdata(gcf,'cond_selection');

     if exist('cond_selection','var') & ~isempty(cond_selection)
         num_conditions = sum(cond_selection);
     end

     if exist('bscan','var') & ~isempty(bscan)
         cond_name = cond_name(bscan);
     end


    %  apply origin_pattern here
    %
    mainfig = getappdata(gcf,'CallBackFig');
    origin_pattern = getappdata(mainfig,'origin_pattern');

    if ~isempty(origin_pattern)
       dims = getappdata(mainfig,'STDims');
       new_coord = zeros(dims);
       new_coord(st_coords) = 1;
       new_coord = find(new_coord(origin_pattern));

       for i=1:length(datamatcorrs_lst)
          datamat = datamatcorrs_lst{i};
          datamat = rri_xy_orient_data(datamat',st_coords,new_coord,...
					dims,origin_pattern);
          datamatcorrs_lst{i} = datamat';
       end

       st_coords = new_coord;
       common_coords = new_coord;
    end



   setappdata(gcf,'datamatcorrs_lst',datamatcorrs_lst);
   setappdata(gcf,'STCoords',st_coords);
   setappdata(gcf,'common_coords',common_coords);
   setappdata(gcf,'num_subj_lst',num_subj_lst);
   setappdata(gcf,'num_cond',num_conditions);
   setappdata(gcf,'behavname',behavname);
   setappdata(gcf,'subj_name',subj_name);
   setappdata(gcf,'cond_name',cond_name);
   setappdata(gcf,'num_behav',length(behavname));

   setappdata(gcf,'datamatcorrs', datamatcorrs_lst{1});
   setappdata(gcf,'num_behav_subj',num_subj_lst(1));

   num_group = length(num_subj_lst);
   popup_list = cell(1,num_group);
   for i=1:num_group
      popup_list{i} = sprintf('[ Group #%d ]',i);
   end;

   popup_h = findobj(gcf,'Tag','STDatamatPopup');
   set(popup_h,'String',popup_list, ...
               'HorizontalAlignment', 'left','Value',1);

   set(gcf,'Pointer',old_pointer);

   return;


%--------------------------------------------------------------------------
%
function change_group

   popup_h = findobj(gcf,'Tag','STDatamatPopup');

   grp_idx = get(popup_h,'value');

   if ~getappdata(gcf,'actualHRF')	%getappdata(gcf,'isbehav')

      datamatcorrs_lst = getappdata(gcf,'datamatcorrs_lst');
      num_subj_lst = getappdata(gcf,'num_subj_lst');

      setappdata(gcf,'datamatcorrs', datamatcorrs_lst{grp_idx});
      setappdata(gcf,'num_behav_subj',num_subj_lst(grp_idx));

      plot_datamatcorrs;

   else

      datamat_lst = getappdata(gcf,'datamat_lst');
      subj_name_lst = getappdata(gcf,'subj_name_lst');
      num_subj_lst = getappdata(gcf,'num_subj_lst');

      setappdata(gcf,'STDatamat', datamat_lst{grp_idx});
      setappdata(gcf,'subj_name', subj_name_lst{grp_idx});
      setappdata(gcf,'num_subj', num_subj_lst(grp_idx));

      plot_response_fn;

   end

   return;


%--------------------------------------------------------------------------
%
function load_voxel_intensity(PLSresultFile)

   cond_selection = getappdata(gcf,'cond_selection');

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

if 0
   warning off;
%   load(PLSresultFile, 'datamatcorrs_lst', 'num_subj_lst', 'behavname', ...
%	'num_conditions', 'st_coords', 'cond_name', 'subj_name');
   load(PLSresultFile, 'SessionProfiles', 'subj_group', 'num_conditions', ...
	'st_coords', 'cond_name', 'subj_name');
   warning on;
end

   load(PLSresultFile);

   if exist('result','var')
      subj_group = result.num_subj_lst;
      num_conditions = result.num_conditions;
   end


   rri_changepath('bfmriresult');

   common_coords = st_coords;

   if ~exist('subj_group', 'var')
uiwait(msgbox('Need use new version to run PLS analysis again in order to get the correlation file'));
      return;
   end

   num_group = length(SessionProfiles);
   DatamatFile = cell(size(SessionProfiles));
   datamat_lst = {};
   subj_name_lst = {};
   num_subj_lst = [];

   cnt2 = 0;
   org_subj_name = subj_name;

   for i = 1:num_group

      grp_datamat = [];
      subj_name = {};
      num_subj = length(SessionProfiles{i});	% session group (actually subj.)

      for n = 1:num_subj

         cnt2 = cnt2+1;

         load(SessionProfiles{i}{n});
         rri_changepath('bfmrisession');

         num_conditions = session_info.num_conditions;

%         if findstr('BfMRIsession.mat', SessionProfiles{i}{n})
%            DatamatFile{i}{n} = sprintf('%s_BfMRIdatamat.mat', session_info.datamat_prefix);
%         else
%            DatamatFile{i}{n} = sprintf('%s_fMRIdatamat.mat', session_info.datamat_prefix);
%         end

         if isempty(cond_selection)
            cond_selection = ones(1, num_conditions);
         else
            num_conditions = sum(cond_selection);
         end

%         DatamatFile{i}{n} = strrep(SessionProfiles{i}{n}, 'session', 'datamat');


         if exist('result','var')
            DatamatFile{i}{n} = SessionProfiles{i}{n};
         else
            DatamatFile{i}{n} = fullfile(session_info.pls_data_path, ...
		[session_info.datamat_prefix, '_BfMRIdatamat.mat']);
         end

         load(DatamatFile{i}{n});


         [tmp, idx] = intersect(st_coords, common_coords);
         st_datamat = st_datamat(:,idx);

%         task_idx = cell(1, num_conditions);
         mean_datamat = zeros(num_conditions, size(st_datamat,2));

         %  compute the mean data of each condition for this session group 
         %
         cnt = 1;

         for k = find(cond_selection)
            mean_datamat(cnt,:) = mean(st_datamat(find(st_evt_list == k),:), 1);
            cnt = cnt + 1;
         end

         grp_datamat = [grp_datamat; mean_datamat];
%         subj_name = [subj_name, {['Subj', num2str(n)]}];
         subj_name = [subj_name, org_subj_name(cnt2)];

      end

      %  convert to 'subj in cond' form
      %
      mask = [1 : (num_conditions * num_subj)];
      mask = reshape(mask, [num_conditions, num_subj]);
      mask = mask';
      mask = mask(:);

      num_subj_lst = [num_subj_lst num_subj];



       coords = st_coords(idx);

       %  apply origin_pattern here
       %
       mainfig = getappdata(gcf,'CallBackFig');
       origin_pattern = getappdata(mainfig,'origin_pattern');

       if ~isempty(origin_pattern)
          dims = getappdata(mainfig,'STDims');
          new_coord = zeros(dims);
          new_coord(coords) = 1;
          new_coord = find(new_coord(origin_pattern));

          grp_datamat = ...
		rri_xy_orient_data(grp_datamat',coords,new_coord, ...
			dims,origin_pattern);
          grp_datamat = grp_datamat';

       end



      datamat_lst{i} = grp_datamat(mask, :);
      subj_name_lst{i} = subj_name;

   end



   if ~isempty(origin_pattern)
      st_coords = change_coords(st_coords, dims, origin_pattern);
      common_coords = change_coords(common_coords, dims, origin_pattern);
   end



   setappdata(gcf,'DatamatFile',DatamatFile);
   setappdata(gcf,'datamat_lst',datamat_lst);
   setappdata(gcf,'STCoords',st_coords);
   setappdata(gcf,'num_subj_lst',num_subj_lst);
   setappdata(gcf,'subj_name_lst',subj_name_lst);
   setappdata(gcf,'num_cond',num_conditions);
   setappdata(gcf,'cond_name',cond_name);

   setappdata(gcf,'STDatamat', datamat_lst{1});
   setappdata(gcf,'subj_name',subj_name_lst{1});
   setappdata(gcf,'num_subj',num_subj_lst(1));

   setappdata(gcf,'common_coords',common_coords);

   popup_list = cell(1,num_group);
   for i=1:num_group
      popup_list{i} = sprintf('[ Group #%d ]',i);
   end;

   popup_h = findobj(gcf,'Tag','STDatamatPopup');
   set(popup_h,'String',popup_list, ...
               'HorizontalAlignment', 'left','Value',1);

   set(gcf,'Pointer',old_pointer);

   return;


%--------------------------------------------------------------------------
%
function new_coords = change_coords(old_coords, dims, pattern)

   img = zeros(dims);
   img(old_coords) = 1;
   img = img(pattern);
   new_coords = find(img);   

   return;


%--------------------------------------------------------------------------
%
function  plot_response_fn_resid()

   h = findobj(gcf,'Tag','STDatamatPopup');
   selected_idx = get(h,'Value');


   st_datamat = getappdata(gcf,'STDatamat_resid');

   %  Entire datamat must be saved, although a portion might be selected
   %
   if isempty(st_datamat)

      set(findobj(gcf,'Tag','MessageLine'),'String','Loading data ... ');

      datamat_lst = getappdata(gcf,'datamat_lst');
      st_datamat = [];

      for i=1:length(datamat_lst)
         st_datamat = [st_datamat; datamat_lst{i}];
      end;

      setappdata(gcf,'STDatamat_resid',st_datamat);

      set(findobj(gcf,'Tag','MessageLine'),'String','');
   end

   num_subj_lst = getappdata(gcf,'num_subj_lst');
   subj_name_lst = getappdata(gcf,'subj_name_lst');

   num_subj = num_subj_lst(selected_idx);
   subj_name = subj_name_lst{selected_idx};


   neighbor_numbers = 1;

   axes_margin = [.37 .05 .15 .1];

   % set up axes, and the values of 'AxesMargin', 'AxesHlds' and 'AxesPos'
   %
   setappdata(gcf,'AxesMargin',axes_margin);
   set_cond_axes(1,1,axes_margin);     % set up axes

   %  extract the currect ploting data
   %
   cur_coord = getappdata(gcf,'Coord');
   if isempty(cur_coord)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       set(gca,'visible','off');
       return;
   end;

   %  find out the coord_idx
   %
   st_coords = getappdata(gcf,'STCoords');
   common_coords = getappdata(gcf,'common_coords');

   coord_idx = find(common_coords == cur_coord);
   if isempty(coord_idx)
       msg = 'ERROR: The selected point is outside the brain region.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       set(gca,'visible','off');
       return;
   end;

   %  in blocked fmri, st_datamat only contain common_coords (because 
   %  the each group needs to be averaged). So, the following statement
   %    < because each block needs to be averaged? >
   %  is commneted. Also see load_voxel_intensity to see how st_datamat
   %  get only common_coords. 13-Apr-2005
   %
%   coord_idx = find(st_coords == cur_coord);

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
         all_voxel(common_coords) = (BSRatio > BSThreshold) | (BSRatio < BSThreshold2);
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
   [ncoord ncoord_idx] = intersect(common_coords, neighbor_coord);

   neighbor_numbers = length(ncoord_idx);
   h = findobj(gcf,'Tag','neighbornumberEdit');
   set(h,'String',num2str(neighbor_numbers));

   st_data = mean(st_datamat(:, ncoord_idx), 2);



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
      tmp = rri_expandvec(dlv(1:num_cond,:), num_subj_lst(g));
      designlv_expanded = [designlv_expanded; tmp];
      dlv(1:num_cond,:) = [];
   end

   newdata = st_data;

   for i = 1:lv-1
      newdata = residualize(designlv_expanded(:,i), newdata);
   end

   datamat_lst = getappdata(gcf,'datamat_lst');
   grp_lst = [];

   for i = 1:length(datamat_lst)
      grp_lst = [grp_lst size(datamat_lst{i},1)];
   end

   grp_lst = [0 cumsum(grp_lst)];
   st_data = newdata(grp_lst(selected_idx)+1:grp_lst(selected_idx+1),:);
   setappdata(gcf,'STDatamat', st_data);



   selected_condition = getappdata(gcf,'SelectedCondition');

   % generate the plots
   %
   cond_idx = find(selected_condition == 1);

   setappdata(gcf,'ST_data',st_data);
   setappdata(gcf,'PlotCondIdx',cond_idx);

   if isempty(getappdata(gcf,'CombinePlots'))
      setappdata(gcf,'CombinePlots',0);
   end;

   if isempty(getappdata(gcf,'ShowAverage'))
      setappdata(gcf,'ShowAverage',0);
   end;

   %  the following code is to get an intensity array for the voxel and plot it
   %
   subjects = [subj_name, {'mean'}];

   for k = cond_idx			% cond
      for n = 1:num_subj		% subj
         j = n+(k-1)*num_subj;		% row number in datamat
         intensity(k,n) = st_data(j);
         intensity_hdl(k,n) = 0;	% initialization
      end
      intensity_avg_hdl(k) = 0;
   end

   intensity_avg = mean(intensity,2);

   setappdata(gcf,'intensity',intensity);
   setappdata(gcf,'intensity_avg',intensity_avg);

   color_code =[ 'bo';'rx';'g+';'m*';'bs';'rd';'g^';'m<';'bp';'r>'; ...
                 'gh';'mv';'ro';'gx';'m+';'b*';'rs';'gd';'m^';'b<'];

   % need more color
   %
   if num_subj+1 > size(color_code,1)

      tmp = [];

      for i=1:ceil((num_subj+1)/size(color_code,1))
         tmp = [tmp; color_code];
      end

      color_code = tmp;

   end

   cla; grid off; hold on;
   for k = cond_idx

      for n = 1:num_subj
         intensity_hdl(k,n) = plot(k,intensity(k,n), ...
			color_code(n,:));
      end

      intensity_avg_hdl(k) = bar(k,intensity_avg(k));
      set(intensity_avg_hdl(k),'facecolor','none')
      % set(intensity_avg_hdl(k), 'linewidth', 2);

   end

   % normalize with intensity(:), not st_data(:)
   %
   min_y = min(intensity(:)); max_y = max(intensity(:));
   margin_y = abs((max_y - min_y) / 100);

   axis_scale = getappdata(gcf, 'axis_scale');

   if isempty(axis_scale)
      axis_scale = [0 length(cond_idx)+1 min_y-margin_y max_y+margin_y];
   else
      if (min_y-margin_y)<axis_scale(3)
         axis_scale(3) = min_y-margin_y;
      end;

      if (max_y+margin_y)>axis_scale(4)
         axis_scale(4) = max_y+margin_y;
      end;
   end

   setappdata(gcf, 'axis_scale', axis_scale);
   axis(axis_scale);

   set(gca, 'xtick', cond_idx);

   xlabel('Conditions');
   ylabel('Intensities');

   xyz = getappdata(gcf,'XYZ');
   title(['Intensity for subjects and mean at voxel:  [',num2str(xyz),']']);

   hold off;

   l_hdl = [];

   if ~isempty(subjects),

      intensity_legend = [intensity_hdl(1,:), intensity_avg_hdl(1)];

      % remove the old legend to avoid the bug in the MATLAB5
      old_legend = getappdata(gcf,'LegendHdl');
      if ~isempty(old_legend),
        try
          delete(old_legend{1});
        catch
        end;
      end;

      % create a new legend, and save the handles
      [l_hdl, o_hdl] = legend(intensity_legend, subjects, 'Location', 'northeast');
      legend_txt(o_hdl);
      set(l_hdl,'color',[0.9 1 0.9]);
      setappdata(gcf,'LegendHdl',[{l_hdl} {o_hdl}]);

   else

      setappdata(gcf,'LegendHdl',[]);

   end;

   setappdata(gcf, 'ncoord_idx', ncoord_idx);
   setappdata(gcf, 'ncoord', ncoord);
   set(findobj(gcf,'Tag','DataMenu'),'visible','on');

   return;					% plot_response_fn_resid

