function fig = fmri_plot_corr(action,varargin)
%
% fmri_plot_corr(action,action_arg1,...)

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
  h = findobj(gcf,'Tag','MessageLine');
  set(h,'String','');

  if strcmp(action,'LoadSTDatamat')
      selected_datamat = get(findobj(gcbf,'Tag','STDatamatPopup'),'Value');
      gen_condition_chk_box(selected_datamat);
      plot_datamatcorrs;

  elseif strcmp(action,'change_group')
      change_group;

  elseif strcmp(action,'NewCoord')
      new_coord = varargin{1};
      new_xyz = varargin{2};
      new_lag = varargin{3};
      setappdata(gcf,'Coord',new_coord);
      setappdata(gcf,'XYZ',new_xyz);
      setappdata(gcf,'lag',new_lag);

      plot_datamatcorrs;

  elseif strcmp(action,'PlotBnPress')
      coord = getappdata(gcf,'Coord');
      plot_datamatcorrs;
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

      plot_datamatcorrs;

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
      plot_datamatcorrs;
  elseif strcmp(action,'MENU_ExportData')
      save_response_fn;
  end;

  return;


%--------------------------------------------------------------------------
%
function fig = init(PLSresultFile)

   cond_selection = getappdata(gcf,'cond_selection');

   result_file = get(findobj(gcf,'tag','ResultFile'),'UserData');

if 0
   try 
      warning off;
      load( result_file, 'bscan' );
      warning on;
   catch
   end;
end

   load( result_file );

   if exist('result','var')
      if isfield(result,'bscan')
         bscan = result.bscan;
      end
   end


   if exist('bscan','var') & ~isempty(bscan)
      selected_conditions = find(cond_selection);
      selected_conditions = selected_conditions(bscan);
      cond_selection = zeros(1,length(cond_selection));
      cond_selection(selected_conditions) = 1;
   end

   save_setting_status = 'on';
   fmri_plot_corr_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_plot_corr_pos) & strcmp(save_setting_status,'on')

      pos = fmri_plot_corr_pos;

   else

      w = 0.8;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   hh = figure('Units','normal', ...
	   'Name','Datamat Correlations', ...	
	   'NumberTitle','off', ...
	   'Color', [0.8 0.8 0.8], ...
 	   'DoubleBuffer','on', ...
	   'Menubar', 'none', ...
	   'DeleteFcn', 'fmri_plot_corr(''DeleteFigure'');', ...
	   'Position',pos, ...
	   'user','datamatcorrs', ...
	   'Tag','PlotRFFig');


   %  display 'ST datamat: '
   %

   x = 0.05;
   y = 0.9;
   w = 0.15;
   h = 0.06;

   pos = [x y w h];

   fnt = 0.4;

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
   y = 0.84;
   w = 0.22;

   pos = [x y w h];

   cb_fn = [ 'fmri_plot_corr(''change_group'');'];
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
   h = 0.62;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
           'Units','normal', ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'frame', ...
	   'Position', pos, ...	
           'HorizontalAlignment', 'left',...
	   'Tag', 'CondFrame');

   x = 0.09;
   y = 0.76;
   w = 0.14;
   h = 0.06;

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
   	  'Enable', 'on', ...
	  'Tag', 'PlotButton', ...
          'CallBack', 'fmri_plot_corr(''PlotBnPress'');');

   x = x+w+.02;

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
		'visible', 'off', ...
	     'Tag','PlotMenu');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot individual ST datamat', ...
	     'Tag','PlotIndividualData', ...
	     'Callback','fmri_plot_corr(''MENU_PlotIndividualData'');');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot group data', ...
	     'Tag','PlotGroupData', ...
	     'Callback','fmri_plot_corr(''MENU_PlotGroupData'');');
  h0 = uimenu('Parent',h_plot, ...
	     'Label','Plot all data', ...
	     'Tag','PlotAllData', ...
	     'Callback','fmri_plot_corr(''MENU_PlotAllData'');');

  h_option = uimenu('Parent',hh, ...
	     'Label','&Option', ...
	     'Tag','OptionMenu', ...
             'Enable','off',...
	     'Visible','on');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Hide Average Plot', ...
	     'Tag','ToggleShowAvgMenu', ...
		'visible', 'off', ...
	     'Callback','fmri_plot_cond_stim_ui(''TOGGLE_SHOW_AVERAGE'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Combine plots within conditions', ...
	     'Tag','CombinePlots', ...
	     'Userdata', 0, ...
	     'Callback','fmri_plot_corr(''MENU_CombinePlots'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Enable Data Normalization', ...
	     'Tag','NormalizePlots', ...
	     'Userdata', 0, ...
	     'Callback','fmri_plot_corr(''MENU_NormalizePlots'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Change plot dimension', ...
	     'Separator','on',...
	     'Tag','ChgPlotDims', ...
	     'Callback','fmri_plot_cond_stim_ui(''CHANGE_PLOT_DIMS'');');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Number of points to be plotted', ...
	     'Tag','NumPtsPlotted', ...
	     'Callback','fmri_plot_corr(''MENU_NumPtsPlotted'');');

  h_option = uimenu('Parent',hh, ...
	     'Label','&Data', ...
	     'Tag','DataMenu', ...
             'Enable','off',...
	     'Visible','on');
  h0 = uimenu('Parent',h_option, ...
	     'Label','Export data', ...
	     'Tag','ExportData', ...
	     'Callback','fmri_plot_corr(''MENU_ExportData'');');


   %  set up object location records
   %
   x = 0.05;
   y = 0.9;
   w = 0.15;
   h = 0.06;
   obj(1).name = 'STDatamatLabel';	obj(1).pos = [x 1-y w h];

   y = 0.84;
   w = 0.22;
   obj(2).name = 'STDatamatPopup';	obj(2).pos = [x 1-y w h];

   x = 0.09;
   y = 0.76;
   w = 0.14;
   h = 0.06;
   obj(3).name = 'ConditionLabel';	obj(3).pos = [x 1-y w h];

   y = 0.7;
   obj(4).name = 'Condition1';		obj(4).pos = [x 1-y w h];

   setappdata(hh,'ObjPosition',obj);
   setappdata(hh,'cond_selection',cond_selection);

   setappdata(gcf, 'sa', getappdata(gcbf, 'sa'));

  % construct the popup label list
  %
  % get_st_datamat_filename(PLSresultFile);
  % make_datamat_popup(1);

  if (nargout >= 1),
     fig = hh;
  end;

  load_datamatcorrs(PLSresultFile);

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
	   'Callback','fmri_plot_corr(''SliderMotion'');');

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

     fmri_plot_corr_pos = get(gcbf,'position');

     save(pls_profile, '-append', 'fmri_plot_corr_pos');
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

        if findstr('BfMRIsession.mat', fn)
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
function  [st_datamat,st_coords,st_win_size,st_evt_list] =  ...
                                         load_plotted_datamat,

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');


   selected_files = get_selected_filename;

   if (length(selected_files) == 1), 		
       load(selected_files{1});
   else					%  merge files together
       [st_datamat,st_coords,st_win_size,st_evt_list] =  ...
                                   merge_st_datamat(selected_files);
   end;

   cond_selection = getappdata(gcf,'cond_selection');

   [mask, st_evt_list, evt_length] = ...
	fmri_mask_evt_list(st_evt_list, cond_selection);

   st_datamat = st_datamat(mask,:);

   set(gcf,'Pointer',old_pointer);

   return;                                       % load_plotted_datamat


%--------------------------------------------------------------------------
%
function  [selected_files] = get_selected_filename(selecte_all_flg),

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
   if strcmp(last_datamat,selected_data) == 0 

       set(findobj(gcf,'Tag','MessageLine'),'String','Loading data ... ');

       [st_datamat, st_coords, st_win_size, st_evt_list] = ...
						load_plotted_datamat;
       setappdata(gcf,'PlottedDatamat',selected_data);
       setappdata(gcf,'STDatamat',st_datamat);
       setappdata(gcf,'STCoords',st_coords);
       setappdata(gcf,'STWinSize',st_win_size);
       setappdata(gcf,'STEvtList',st_evt_list);

       set(findobj(gcf,'Tag','MessageLine'),'String','');
   else
       st_win_size = getappdata(gcf,'STWinSize');
       st_evt_list = getappdata(gcf,'STEvtList');
       st_coords = getappdata(gcf,'STCoords');
   end;

   num_pts_plotted = getappdata(gcf,'NumPtsPlotted');
   if isempty(num_pts_plotted)
      num_pts_plotted = st_win_size;
      setappdata(gcf,'NumPtsPlotted',num_pts_plotted);
   elseif (num_pts_plotted > st_win_size),
      num_pts_plotted = st_win_size;
   end;

   
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


   st_datamat = getappdata(gcf,'STDatamat'); 

   [nr,nc] = size(st_datamat);
   cols = nc / st_win_size;
   st_data = reshape(st_datamat,[nr,st_win_size,cols]);
   st_data = squeeze(st_data(:,[1:num_pts_plotted],coord_idx));
   
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
           	                    axes_margin, plot_dims, plot_cond_idx);

   setappdata(gcf,'PLS_PLOT_COND_STIM_ACTIVE',1);
   set(findobj(gcf,'Tag','PlotMenu'),'Enable','off');
   set(findobj(gcf,'Tag','OptionMenu'),'Enable','on');
   set(findobj(gcf,'Tag','DataMenu'),'Enable','on');

   return;


%--------------------------------------------------------------------------
%
function  save_response_fn()

   st_win_size = getappdata(gcf,'STWinSize');
   st_evt_list = getappdata(gcf,'STEvtList');
   st_coords = getappdata(gcf,'STCoords');
   xyz = getappdata(gcf,'XYZ');
   lag = getappdata(gcf,'lag');

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

   %  get all the file names 
   %
%   selected_files = get_selected_filename(1);

   %  extract the time course data of the selected voxel
   %
%   st_datamat = getappdata(gcf,'STDatamat'); 

%   [nr,nc] = size(st_datamat);
%   cols = nc / st_win_size;
%   st_data = reshape(st_datamat,[nr,st_win_size,cols]);
%   st_data = squeeze(st_data(:,[1:st_win_size],coord_idx));

   st_data = getappdata(gcf,'ST_data');

%   st_data = st_data(:,lag+1);

%   fn = getappdata(gcf,'STFiles');
%   fn = fn{1}.name;

   [filename, pathname] = ...
	rri_selectfile('*_fMRI_datamatcorr_plot.mat','Save Datamat Correlation Response Function');

   if ischar(filename) & ~all(ismember('_fmri_datamatcorr_plot',lower(filename)))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_fMRI_datamatcorr_plot.mat'];
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
     save (rf_plot_file, 'st_data', xyz_str, 'lag' );
   catch
     msg = sprintf('Cannot save the response function data to %s',rf_plot_file);
     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
     status = 0;
     return;
   end;

   return;                                      % save_response_fn


%--------------------------------------------------------------------------
%
function load_datamatcorrs(PLSresultFile)

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

if 0
   warning off;
   load(PLSresultFile, 'datamatcorrs_lst', 'num_subj_lst', 'behavname', ...
	'num_conditions', 'st_coords', 'st_win_size', 'cond_name', ...
	'subj_name', 'bscan');
   warning on;
end

   load(PLSresultFile);

   if exist('result','var')
      num_conditions = result.num_conditions;
      num_subj_lst = result.num_subj_lst;

      if isfield(result,'bscan')
         bscan = result.bscan;
      end

      if isfield(result,'datamatcorrs_lst')
         datamatcorrs_lst = result.datamatcorrs_lst;
      end
   end


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

   setappdata(gcf,'datamatcorrs_lst',datamatcorrs_lst);
   setappdata(gcf,'STCoords',st_coords);
   setappdata(gcf,'STWinSize',st_win_size);
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

   return;                                       % get_st_datamat_filename


%--------------------------------------------------------------------------
%
function change_group

   popup_h = findobj(gcf,'Tag','STDatamatPopup');

   grp_idx = get(popup_h,'value');

   datamatcorrs_lst = getappdata(gcf,'datamatcorrs_lst');
   num_subj_lst = getappdata(gcf,'num_subj_lst');

   setappdata(gcf,'datamatcorrs', datamatcorrs_lst{grp_idx});
   setappdata(gcf,'num_behav_subj',num_subj_lst(grp_idx));

   plot_datamatcorrs;

   return;


%--------------------------------------------------------------------------
%
function  plot_datamatcorrs

   emp_st_data = 0;

   %  extract the currect ploting data
   %
   cur_coord = getappdata(gcf,'Coord');
   if isempty(cur_coord)
       msg = 'ERROR: No point has been seleted to plot.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%       return;
       emp_st_data = 1;
   end;

   conditions = getappdata(gcf,'Conditions');

   st_coords = getappdata(gcf,'STCoords');
   st_win_size = getappdata(gcf,'STWinSize');

   num_pts_plotted = getappdata(gcf,'NumPtsPlotted');
   if isempty(num_pts_plotted)
      num_pts_plotted = st_win_size;
      setappdata(gcf,'NumPtsPlotted',num_pts_plotted);
   elseif (num_pts_plotted > st_win_size),
      num_pts_plotted = st_win_size;
   end;

   coord_idx = find(st_coords == cur_coord);

   if isempty(coord_idx)
       msg = 'ERROR: The selected point is outside the brain region.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%       return;
       emp_st_data = 1;
   end;

   num_cond = getappdata(gcf,'num_cond');
   st_data = getappdata(gcf,'datamatcorrs');
   num_behav = getappdata(gcf,'num_behav');

   st_evt = ones(1,num_behav);
   st_evt_list = [];
   for i=1:num_cond
      st_evt_list = [st_evt_list, st_evt.*i];
   end

   % generate the plots
   %
   cond_idx = [1:num_cond];

   [nr,nc] = size(st_data);
   cols = nc / st_win_size;
   st_data = reshape(st_data,[nr,st_win_size,cols]);
   st_data = squeeze(st_data(:,[1:num_pts_plotted],coord_idx));
   
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

   if emp_st_data
      st_data = [];
   end

   selected_condition = getappdata(gcf,'SelectedCondition');
   num_conditions = length(selected_condition);
   condition = cell(1,num_conditions);  

   max_num_stim = 0;
   for i=1:num_cond,
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

   setappdata(gcf,'ShowAverage',0);

   axes_margin = [.37 .13 .15 .1];

   fmri_plot_cond_stim_ui('STARTUP', st_data, condition,  ...
           	                    axes_margin, plot_dims, plot_cond_idx);

   setappdata(gcf,'PLS_PLOT_COND_STIM_ACTIVE',1);
   set(findobj(gcf,'Tag','PlotMenu'),'Enable','off');
   set(findobj(gcf,'Tag','OptionMenu'),'Enable','on');
   set(findobj(gcf,'Tag','DataMenu'),'Enable','on');

   return;

