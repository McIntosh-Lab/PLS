%------------------------------------------------------------------------
function fig = erp_plot_rf_task(action,varargin)

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
      main_fig = varargin{2};
      fig = init(PLSresultFile, main_fig);
      gen_condition_chk_box(1);
      SetObjPosition;

%      figure(gcbf);

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
      time_point = varargin{1};
      chan_id = varargin{2};
      chan_list = varargin{3};
      chan_name = varargin{4};
      wave_idx = varargin{5};

      time_info = getappdata(gcf,'time_info');
      data_point = round( (time_point - time_info.prestim) / ...
				time_info.digit_interval + 1 );

      setappdata(gcf,'data_point',data_point);
      setappdata(gcf,'chan_id',chan_id);
      setappdata(gcf,'chan_list',chan_list);
      setappdata(gcf,'chan_name',chan_name);
      setappdata(gcf,'wave_idx',wave_idx);

      setappdata(gcf, 'axis_scale', []);
      plot_response_fn;

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
function fig = init(PLSresultFile, CallBackFig)

   save_setting_status = 'on';
   erp_plot_rf_task_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(erp_plot_rf_task_pos) & strcmp(save_setting_status,'on')

      pos = erp_plot_rf_task_pos;

   else

      w = 0.8;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   hh = figure('Units','normal', ...
	   'Name','Response Plot', ...	
	   'Menubar', 'none', ...
	   'NumberTitle','off', ...
	   'Color', [0.8 0.8 0.8], ...
 	   'DoubleBuffer','on', ...
	   'DeleteFcn', 'erp_plot_rf_task(''DeleteFigure'');', ...
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
           'CallBack', 'erp_plot_rf_task(''PlotBnPress'');', ...
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

   cb_fn = [ 'erp_plot_rf_task(''change_group'');'];
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
          'CallBack', 'erp_plot_rf_task(''PlotBnPress'');');

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
          'CallBack', 'erp_plot_rf_task(''residualized'');', ...
	  'Tag', 'residualized');

   try
      load(PLSresultFile,'method','datamat_files');
   catch
   end

   holdoffresidual = 1;

   if holdoffresidual
      set(h0, 'visible', 'off');
   elseif ~exist('datamat_files','var') | ~exist('method','var') | ...
	isempty(findstr(datamat_files{1}, 'sessiondata.mat'))
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
        'callback','erp_plot_rf_task(''zoom'');', ...
        'label','&Zoom on');

  h_plot = uimenu('Parent',hh, ...
	     'Label','&Plot', ...
             'Enable','on',...
		'visible', 'off', ...
	     'Tag','PlotMenu');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot individual datamat', ...
	     'Tag','PlotIndividualData', ...
	     'Callback','erp_plot_rf_task(''MENU_PlotIndividualData'');');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot group data', ...
	     'Tag','PlotGroupData', ...
		'visible', 'off', ...
	     'Callback','erp_plot_rf_task(''MENU_PlotGroupData'');');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot all data', ...
	     'Tag','PlotAllData', ...
	     'Callback','erp_plot_rf_task(''MENU_PlotAllData'');');

  h_option = uimenu('Parent',hh, ...
	     'Label','&Data', ...
	     'Tag','DataMenu', ...
             'Enable','on',...
	     'Visible','off');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Export data', ...
	     'Tag','ExportData', ...
	     'Callback','erp_plot_rf_task(''MENU_ExportData'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Export data for behav analysis', ...
	     'Tag','ExportBehavData', ...
		'visible', 'off', ...
	     'Callback','erp_plot_rf_task(''MENU_ExportBehavData'');');

  h_option = uimenu('Parent',hh, ...
	     'Label','&Data', ...
	     'Tag','DataMenuBehav', ...
             'Enable','on',...
	     'Visible','off');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Export data', ...
	     'Tag','ExportDataBehav', ...
	     'Callback','erp_plot_rf_task(''MENU_ExportDataBehav'');');

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

  if (nargout >= 1),
     fig = hh;
  end;

  load_voxel_intensity(PLSresultFile);

  return;						% init


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
	   'Callback','erp_plot_rf_task(''SliderMotion'');');

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

     erp_plot_rf_task_pos = get(gcbf,'position');

     save(pls_profile, '-append', 'erp_plot_rf_task_pos');
  catch
  end

  vir_fig = getappdata(gcbf,'vir_fig');

  try
     delete(vir_fig);
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

   msg = 'Click a time point to see the plot';
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
function  save_response_fn()

   %  Get Neighborhood Size
   h = findobj(gcf,'Tag','neighborhoodEdit');
   neighbor_size = round(str2num(get(h,'String')));

   if isempty(neighbor_size) | ~isnumeric(neighbor_size)
      neighbor_size = 0;
   end

   %  extract the currect ploting data
   %
   data_point = getappdata(gcf,'data_point');

   if isempty(data_point)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;

   time_info = getappdata(gcf,'time_info');
   time_point = (data_point-1)*time_info.digit_interval + time_info.prestim;

   LV = getappdata(gcf,'wave_idx');
   chan_id = getappdata(gcf,'chan_id');
   chan_list = getappdata(gcf,'chan_list');
   chan_name = getappdata(gcf,'chan_name');
   start_timepoint = getappdata(gcf,'start_timepoint');

   %  based on start_time, not prestim
   %
   data_point = data_point - start_timepoint + 1;

   ncoord_idx = getappdata(gcf, 'ncoord_idx');
   neighbor_numbers = length(ncoord_idx);

   %  get selected file names 
   %
   st_files = getappdata(gcf,'DatamatFile');
   h = findobj(gcf,'Tag','STDatamatPopup');
   selected_idx = get(h,'Value');
   selected_files = st_files{selected_idx};

   %  extract the data of the selected voxel
   %
%   st_data = getappdata(gcf,'ST_data');
 %  data = mean(st_data(ncoord_idx, :, :), 1);
  % data_mean = squeeze(mean(data,2));
   %data = data(:);

   residualized = get(findobj(gcf,'tag','residualized'),'value');
   data = getappdata(gcf,'intensity');
   data_mean = getappdata(gcf,'intensity_avg');
   data = data';
   data = data(:);

   [filename, pathname] = ...
	rri_selectfile('*_ERP_rf_plot.mat','Save the Response Functions');

   if ischar(filename) & ~all(ismember('_erp_rf_plot',lower(filename)))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_ERP_rf_plot.mat'];
   end

   if isequal(filename,0)
	return;
   end;
   rf_plot_file = fullfile(pathname,filename);

   try
     save (rf_plot_file, 'selected_files', 'data', 'data_mean', 'LV', 'chan_name', 'chan_id', 'time_point', 'neighbor_size', 'neighbor_numbers', 'residualized' );
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
      ['<ONLY INPUT PREFIX>*_ERP_grp',num2str(selected_idx),'_subj1_behavdata1.txt'];

   [filename, pathname] = rri_selectfile(pattern,'Save Behav Data');

   if isequal(filename,0)
	return;
   end;

   [tmp filename] = fileparts(filename);

   for i = 1:size(mask,1)
      rf_plot_file = fullfile(pathname, ...
	sprintf('%s_ERP_grp%d_subj%d_behavdata1.txt',filename,selected_idx,i));
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
	rri_selectfile('*_ERP_datamatcorr_plot.mat','Save the Response Functions');

   if ischar(filename) & ~all(ismember('_erp_datamatcorr_plot',lower(filename)))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_ERP_datamatcorr_plot.mat'];
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

      setappdata(gcf,'STDatamat', datamat_lst{grp_idx});
      setappdata(gcf,'subj_name', subj_name_lst{grp_idx});
      setappdata(gcf,'num_subj', length(subj_name_lst{grp_idx}));

      plot_response_fn;

   end

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
function load_voxel_intensity(PLSresultFile)

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   warning off;
   load(PLSresultFile, 'datamat_files', 'common_conditions', 'cond_name', ...
	'subj_name_lst', 'common_time_info', 'common_channels');
   warning on;

   num_group = length(datamat_files);

   % get upper & lower limit of timepoints (from erp_datacub2datamat)
   %
   start_timepoint = floor((common_time_info.start_time - ...
	common_time_info.prestim) / common_time_info.digit_interval +1);
   end_timepoint = start_timepoint + common_time_info.timepoint -1;

   for i = 1:num_group
      load(datamat_files{i}, 'datafile', 'selected_subjects');
      load(datafile, 'datamat');
      datamat_lst{i} = datamat([start_timepoint:end_timepoint],find(common_channels),find(selected_subjects),find(common_conditions));
   end

   setappdata(gcf,'start_timepoint',start_timepoint);
   setappdata(gcf,'end_timepoint',end_timepoint);
   setappdata(gcf,'time_info',common_time_info);

   setappdata(gcf,'DatamatFile',datamat_files);
   setappdata(gcf,'datamat_lst',datamat_lst);
   setappdata(gcf,'subj_name_lst',subj_name_lst);
   setappdata(gcf,'num_cond',sum(common_conditions));
   setappdata(gcf,'cond_name',cond_name(find(common_conditions)));
   setappdata(gcf,'common_conditions',common_conditions);
   setappdata(gcf,'common_channels',common_channels);

   setappdata(gcf,'STDatamat', datamat_lst{1});
   setappdata(gcf,'subj_name',subj_name_lst{1});
   setappdata(gcf,'num_subj',length(subj_name_lst{1}));

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
      subj_name_lst = getappdata(gcf,'subj_name_lst');

      st_datamat = datamat_lst{selected_idx};
      num_subj = length(subj_name_lst{selected_idx});
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
   data_point = getappdata(gcf,'data_point');

   if isempty(data_point)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       set(gca,'visible','off');
       return;
   end;

   time_info = getappdata(gcf,'time_info');
   chan_id = getappdata(gcf,'chan_id');
   chan_list = getappdata(gcf,'chan_list');
   chan_name = getappdata(gcf,'chan_name');
   start_timepoint = getappdata(gcf,'start_timepoint');

   %  based on start_time, not prestim
   %
   data_point = data_point - start_timepoint + 1;

   %  Get Neighborhood Size
   %
   h = findobj(gcf,'Tag','neighborhoodEdit');
   neighbor_size = round(str2num(get(h,'String')));

   if isempty(neighbor_size) | ~isnumeric(neighbor_size)
      neighbor_size = 0;
   end

   CurrLVIdx = getappdata(gcf,'wave_idx');

   %  Do neighborhood mean only if there is any neighborhood
   %
   if neighbor_size > 0

      CallBackFig = getappdata(gcf,'CallBackFig');

      x1 = data_point - neighbor_size;
      if x1 < 1, x1 = 1; end;

      x2 = data_point + neighbor_size;
      if x2 > time_info.timepoint, x2 = time_info.timepoint; end;

      %  Get neighborhood coords relative to whole volume
      %
      neighbor_coord = [x1:x2];

      %  If "Bootstrap" is computed, voxels that meet the bootstrap ratio
      %  threshold will be used as a criteria to select surrounding voxels
      %
      bs_field = getappdata(CallBackFig,'bs_field');

      if ~isempty(bs_field)
         bs_field = bs_field{CurrLVIdx};
         BSThreshold = bs_field.thresh;
         BSThreshold2 = bs_field.thresh2;

         selected_channels = getappdata(CallBackFig,'selected_channels');
         bs_ratio = getappdata(CallBackFig,'bs_ratio');
         BSRatio = bs_ratio(:,CurrLVIdx);
         BSRatio = reshape(BSRatio, [time_info.timepoint sum(selected_channels)]);
         BSRatio = BSRatio(:,chan_list);

         all_voxel = (BSRatio > BSThreshold) | (BSRatio < BSThreshold2);
         bsridx = find(all_voxel);
      else
         bsridx = [];
      end

      %  Only including surrounding voxels that meet the bootstrap ratio
      %  threshold
      %
      bsr_cluster_coords = unique([[bsridx(:)]' data_point]);

      %  Intersect of neighborhood coord "neighbor_coord" and 
      %  "bsr_cluster_coords"
      %
      neighbor_coord = intersect(neighbor_coord, bsr_cluster_coords);

   else

      neighbor_coord = data_point;

   end;		% if neighbor_size > 0

   ncoord_idx = neighbor_coord;

   neighbor_numbers = length(neighbor_coord);
   h = findobj(gcf,'Tag','neighbornumberEdit');
   set(h,'String',num2str(neighbor_numbers));

   st_data = st_datamat;
   selected_condition = getappdata(gcf,'SelectedCondition');

   st_data = squeeze(st_data(:,chan_list,:,:));

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
         intensity(k,n) = mean(st_data(ncoord_idx, n, k), 1);
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
   ylabel('Amplitude (\muV)');

   data_point = getappdata(gcf,'data_point');
   xyz = (data_point-1)*time_info.digit_interval + time_info.prestim;
   title(['Subject / Mean at ',num2str(xyz), ' (ms) for Electrode ', num2str(chan_id), ' (', chan_name, ') ',  ' on LV', num2str(CurrLVIdx)]);

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
   set(findobj(gcf,'Tag','DataMenu'),'visible','on');

   return;					% plot_response_fn


%--------------------------------------------------------------------------
%
function  plot_response_fn_resid()

   h = findobj(gcf,'Tag','STDatamatPopup');
   selected_idx = get(h,'Value');


   st_datamat = getappdata(gcf,'STDatamat_resid');
   last_chan_list = getappdata(gcf,'last_chan_list');
   chan_list = getappdata(gcf,'chan_list');

   %  Entire datamat must be saved, although a portion might be selected
   %
   if isempty(st_datamat) | ~isequal(last_chan_list,chan_list)

      set(findobj(gcf,'Tag','MessageLine'),'String','Loading data ... ');

      datamat_lst = getappdata(gcf,'datamat_lst');
      st_datamat = [];

      for i=1:length(datamat_lst)
         datamat = datamat_lst{i}(:,chan_list,:,:);
         [dim1, dim2, dim3, dim4] = size(datamat);
         datamat = reshape(datamat, [dim1*dim2, dim3*dim4]);
         datamat = datamat';
         st_datamat = [st_datamat; datamat];
      end;

      setappdata(gcf,'STDatamat_resid',st_datamat);
      setappdata(gcf,'last_chan_list',chan_list);

      set(findobj(gcf,'Tag','MessageLine'),'String','');
   end

   subj_name_lst = getappdata(gcf,'subj_name_lst');

%   num_subj = length(subj_name_lst{selected_idx});
%   subj_name = subj_name_lst{selected_idx};


   neighbor_numbers = 1;

   axes_margin = [.37 .05 .15 .1];

   % set up axes, and the values of 'AxesMargin', 'AxesHlds' and 'AxesPos'
   %
   setappdata(gcf,'AxesMargin',axes_margin);
   set_cond_axes(1,1,axes_margin);     % set up axes

   %  extract the currect ploting data
   %
   data_point = getappdata(gcf,'data_point');

   if isempty(data_point)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       set(gca,'visible','off');
       return;
   end;

   time_info = getappdata(gcf,'time_info');
   chan_id = getappdata(gcf,'chan_id');
   chan_list = getappdata(gcf,'chan_list');
   chan_name = getappdata(gcf,'chan_name');
   start_timepoint = getappdata(gcf,'start_timepoint');

   %  based on start_time, not prestim
   %
   data_point = data_point - start_timepoint + 1;

   %  Get Neighborhood Size
   %
   h = findobj(gcf,'Tag','neighborhoodEdit');
   neighbor_size = round(str2num(get(h,'String')));

   if isempty(neighbor_size) | ~isnumeric(neighbor_size)
      neighbor_size = 0;
   end

   CurrLVIdx = getappdata(gcf,'wave_idx');

   %  Do neighborhood mean only if there is any neighborhood
   %
   if neighbor_size > 0

      CallBackFig = getappdata(gcf,'CallBackFig');

      x1 = data_point - neighbor_size;
      if x1 < 1, x1 = 1; end;

      x2 = data_point + neighbor_size;
      if x2 > time_info.timepoint, x2 = time_info.timepoint; end;

      %  Get neighborhood coords relative to whole volume
      %
      neighbor_coord = [x1:x2];

      %  If "Bootstrap" is computed, voxels that meet the bootstrap ratio
      %  threshold will be used as a criteria to select surrounding voxels
      %
      bs_field = getappdata(CallBackFig,'bs_field');

      if ~isempty(bs_field)
         bs_field = bs_field{CurrLVIdx};
         BSThreshold = bs_field.thresh;
         BSThreshold2 = bs_field.thresh2;

         selected_channels = getappdata(CallBackFig,'selected_channels');
         bs_ratio = getappdata(CallBackFig,'bs_ratio');
         BSRatio = bs_ratio(:,CurrLVIdx);
         BSRatio = reshape(BSRatio, [time_info.timepoint sum(selected_channels)]);
         BSRatio = BSRatio(:,chan_list);

         all_voxel = (BSRatio > BSThreshold) | (BSRatio < BSThreshold2);
         bsridx = find(all_voxel);
      else
         bsridx = [];
      end

      %  Only including surrounding voxels that meet the bootstrap ratio
      %  threshold
      %
      bsr_cluster_coords = unique([[bsridx(:)]' data_point]);

      %  Intersect of neighborhood coord "neighbor_coord" and 
      %  "bsr_cluster_coords"
      %
      neighbor_coord = intersect(neighbor_coord, bsr_cluster_coords);

   else

      neighbor_coord = data_point;

   end;		% if neighbor_size > 0

   ncoord_idx = neighbor_coord;

   neighbor_numbers = length(neighbor_coord);
   h = findobj(gcf,'Tag','neighbornumberEdit');
   set(h,'String',num2str(neighbor_numbers));

   st_data = mean(st_datamat(:, ncoord_idx), 2);



   %  Calculate residual
   %
   main_fig = getappdata(gcf,'CallBackFig');
   PLSresultFile = getappdata(main_fig, 'datamat_file');
   load(PLSresultFile,'result','num_cond_lst','num_subj_lst','subj_name_lst');
   dlv = result.v;
   lv = getappdata(gcf,'wave_idx');
%   num_subj_lst = getappdata(main_fig,'subj_group');
%   num_cond = sum(getappdata(main_fig,'cond_selection'));
   num_cond = num_cond_lst(1);
   num_subj = num_subj_lst(selected_idx);
   subj_name = subj_name_lst{selected_idx};

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
      grp_lst = [grp_lst num_subj_lst(i)*num_cond];
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
   ylabel('Amplitude (\muV)');

   data_point = getappdata(gcf,'data_point');
   xyz = (data_point-1)*time_info.digit_interval + time_info.prestim;
   title(['Subject / Mean at ',num2str(xyz), ' (ms) for Electrode ', num2str(chan_id), ' (', chan_name, ') ',  ' on LV', num2str(CurrLVIdx)]);

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
   set(findobj(gcf,'Tag','DataMenu'),'visible','on');

   return;					% plot_response_fn_resid

