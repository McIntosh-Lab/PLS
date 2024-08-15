function fig = fmri_plot_brain_scores(action,varargin)
%
% fmri_plot_brain_scores(action,action_arg1,...)

  if ~exist('action','var') | isempty(action) 		% no action argument
      return;
  end;

  fig = [];
  if strcmp(action,'STARTUP')			    
      sessionFileList = varargin{1};
      plsResultFile = varargin{2};
      init(sessionFileList,plsResultFile);
      SetupLVButtonRows;
      SetupSlider;
      DisplayLVButtons;

      return;

  elseif strcmp(action,'LINK')			    % call from other figure

      sessionFileList = varargin{1};
      plsResultFile = varargin{2};

      fig = init(sessionFileList,plsResultFile);
      SetupLVButtonRows;
      SetupSlider;
      DisplayLVButtons;

      return;

  elseif strcmp(action,'MENU_ExportData')
      save_response_fn;
  elseif strcmp(action,'MENU_ExportBehavData')
      save_response_fn2;
  end;

  %  clear the message line,
  %
%  h = findobj(gcf,'Tag','MessageLine');
 % set(h,'String','');


  switch (upper(action))
     case {'LOAD_STDATAMAT'}
         plot_brain_scores;
     case {'MOVE_SLIDER'},
         MoveSlider;
     case {'SET_TOP_LV_BUTTON'},
         lv_idx = varargin{2};
         SetTopLVButton(lv_idx);
     case {'SELECT_LV'},
	 SelectLV;
         active_plot = getappdata(gcf,'PLS_PLOT_BS_ACTIVE');
         if ~isempty(active_plot) & (active_plot == 1)
            plot_brain_scores;
         end;
     case {'DELETE_FIGURE'}
         delete_fig;
     case {'PLOT_BRAINSCORES'}
         plot_brain_scores;
     case {'MENU_PLOTINDIVIDUALDATA'}
         make_datamat_popup(1);
     case {'MENU_PLOTGROUPDATA'}
         make_datamat_popup(2);
     case {'MENU_PLOTALLDATA'}
         make_datamat_popup(3);
     case {'MENU_COMBINEPLOTS'}
         set_combine_plot;
  end

  return;


%--------------------------------------------------------------------------
%
function fig = init(sessionFileList,plsResultFile)

   cond_selection = getappdata(gcf,'cond_selection');

   save_setting_status = 'on';
   fmri_plot_brain_scores_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_plot_brain_scores_pos) & strcmp(save_setting_status,'on')

      pos = fmri_plot_brain_scores_pos;

   else

      w = 0.8;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   hh = figure('Units','normal', ...
	   'Name','Temporal Brain Scores Plot', ...	
	   'NumberTitle','off', ...
	   'Color', [0.8 0.8 0.8], ...
 	   'DoubleBuffer','on', ...
	   'Menubar', 'none', ...
	   'DeleteFcn', 'fmri_plot_brain_scores(''Delete_Figure'');', ...
	   'Position',pos, ...
	   'Tag','PlotBrainScoreFig');


   %  display 'ST datamat: '
   %

   x = 0.05;
   y = 0.9;
   w = 0.15;
   h = 0.06;

   pos = [x y w h];

   fnt = 0.4;

   h0 = uicontrol('Parent',hh, ...
           'units','normal', ...
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

   cb_fn = [ 'fmri_plot_brain_scores(''Load_STDatamat'');'];
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
	   'Tag', 'LVFrame');

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
	   'String', 'Display LVs', ...
	   'Tag', 'DisplayLVLabel');

   y = 0.7;

   pos = [x y w h];

   lv_h = uicontrol('Parent',hh, ...
           'Units','normal', ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'radiobutton', ...
	   'Position', pos, ...	
           'HorizontalAlignment', 'left',...
	   'FontSize', 10, ...
	   'String', 'LV #1', ...
	   'Visible', 'on', ...
   	   'Callback','fmri_plot_brain_scores(''SELECT_LV'');', ...
	   'Tag', 'LVRadioButton');

   x = x+w+0.01;
   w = 0.02;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...		% LV Button Slider
     	   'Style','slider', ...
   	   'Units','normal', ...
           'Min', 0, ...
           'Max', 1, ...
	   'Visible', 'on', ...
   	   'Position',pos, ...
   	   'Callback','fmri_plot_brain_scores(''MOVE_SLIDER'');', ...
   	   'Tag','LVButtonSlider');

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
          'CallBack', 'fmri_plot_brain_scores(''PLOT_BRAINSCORES'');');

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

  %  menu
  rri_file_menu(hh);

  h_plot = uimenu('Parent',hh, ...
             'Label','&Plot', ...
             'Enable','on',...
             'Tag','PlotMenu');

  h0 = uimenu('Parent',h_plot, ...
             'Label','Plot individual ST datamat', ...
             'Tag','PlotIndividualData', ...
             'Callback','fmri_plot_brain_scores(''MENU_PlotIndividualData'');');
  h0 = uimenu('Parent',h_plot, ...
             'Label','Plot group data', ...
             'Tag','PlotGroupData', ...
             'Callback','fmri_plot_brain_scores(''MENU_PlotGroupData'');');
  h0 = uimenu('Parent',h_plot, ...
             'Label','Plot all data', ...
             'Tag','PlotAllData', ...
             'Callback','fmri_plot_brain_scores(''MENU_PlotAllData'');');

  h_option = uimenu('Parent',hh, ...
             'Label','&Option', ...
             'Tag','OptionMenu', ...
             'Enable','on',...
             'Visible','on');

  h_data = uimenu('Parent',hh, ...
	     'Label','&Data', ...
	     'Tag','DataMenu', ...
	     'Visible','on');

  h0 = uimenu('Parent',h_data, ...
	     'Label','Export data', ...
	     'Tag','ExportData', ...
	     'Callback','fmri_plot_brain_scores(''MENU_ExportData'');');
  h0 = uimenu('Parent',h_data, ...
	     'Label','Export data to text file', ...
	     'Tag','ExportBehavData', ...
		'visible', 'off', ...
	     'Callback','fmri_plot_brain_scores(''MENU_ExportBehavData'');');

  % construct the popup label list
  %
  get_st_datamat_filename(sessionFileList);
  make_datamat_popup(1);

  lv_template = copyobj_legacy(lv_h,hh);
  set(lv_template,'Tag','LVTemplate','Visible','off');

  setappdata(hh,'cond_selection',cond_selection);

  % load the brain scores, conditions, evt_list
  %
  [brainlv,pls_coords,dims,conditions,subj_group] = load_pls_brainlv(plsResultFile);


  if iscell(subj_group)
     h0 = uimenu('Parent',h_option, ...
	     'Label','Hide Average Plot', ...
	     'Tag','ToggleShowAvgMenu', ...
	     'Callback','ssb_fmri_plot_cond_stim_ui(''TOGGLE_SHOW_AVERAGE'');');
     h0 = uimenu('Parent',h_option, ...
             'Label','Combine plots within conditions', ...
             'Tag','CombinePlots', ...
             'Userdata', 0, ...
             'Callback','fmri_plot_brain_scores(''MENU_CombinePlots'');');
     h0 = uimenu('Parent',h_option, ...
	     'Label','Change plot dimension', ...
	     'Separator','on',...
	     'Tag','ChgPlotDims', ...
	     'Callback','ssb_fmri_plot_cond_stim_ui(''CHANGE_PLOT_DIMS'');');
  else
     h0 = uimenu('Parent',h_option, ...
	     'Label','Hide Average Plot', ...
	     'Tag','ToggleShowAvgMenu', ...
	     'Callback','fmri_plot_cond_stim_ui(''TOGGLE_SHOW_AVERAGE'');');
     h0 = uimenu('Parent',h_option, ...
             'Label','Combine plots within conditions', ...
             'Tag','CombinePlots', ...
             'Userdata', 0, ...
             'Callback','fmri_plot_brain_scores(''MENU_CombinePlots'');');
     h0 = uimenu('Parent',h_option, ...
	     'Label','Change plot dimension', ...
	     'Separator','on',...
	     'Tag','ChgPlotDims', ...
	     'Callback','fmri_plot_cond_stim_ui(''CHANGE_PLOT_DIMS'');');
  end


  num_lv = size(brainlv,2);
  curr_lv_state = zeros(1,num_lv); 
  curr_lv_state(1) = 1;

  setappdata(hh,'BrainLV',brainlv);
  setappdata(hh,'PLSCoords',pls_coords);
  setappdata(hh,'Dims',dims);
  setappdata(hh,'Conditions',conditions);
  setappdata(hh,'CurrLVState',curr_lv_state);
  setappdata(hh,'subj_group',subj_group);

  % for GUI
  setappdata(hh,'LVButtonHeight',0.06);
  setappdata(hh,'LV_hlist',[lv_h]);
  setappdata(hh,'LVButtonTemplate',lv_template);
  setappdata(hh,'TopLVButton',1);

  setappdata(hh,'PLS_BS_PLOTTED_DATA',[]);
  setappdata(hh,'PLS_BS_PLOTTED_CONDITON',[]);

  if (nargout >= 1),
     fig = hh;
  end;

  return;					% init


% --------------------------------------------------------------------
function  SetupLVButtonRows()

   lv_hdls = getappdata(gcf,'LV_hlist');
   lv_template = getappdata(gcf,'LVButtonTemplate');

   row_height = getappdata(gcf,'LVButtonHeight');
   frame_pos = get(findobj(gcf,'Tag','LVFrame'),'Position');
   first_button_pos = get(findobj(gcf,'Tag','LVRadioButton'),'Position');

   top_frame_pos = frame_pos(2) + frame_pos(4);
   margin = top_frame_pos - (first_button_pos(2) + first_button_pos(4));
   rows = floor((frame_pos(4) - margin*1.5) / row_height);

   v_pos = (top_frame_pos - margin) - [1:rows]*row_height;

   nr = size(lv_hdls,1);
   if (rows < nr)				% too many rows
      for i=rows+1:nr,
         delete(lv_hdls(i));
      end;
      lv_hdls = lv_hdls(1:rows);
   else						% add more rows
      for i=nr+1:rows,
        new_s_hdls = copyobj_legacy(lv_template,gcf);
        lv_hdls = [lv_hdls; new_s_hdls'];
      end;
   end;

   v = 'on';
   for i=1:rows,
      new_s_hdls = lv_hdls(i);
      pos = get(new_s_hdls(1),'Position'); pos(2) = v_pos(i);
      set(new_s_hdls,'String','','Position',pos,'Visible',v,'UserData',i);
   end;

   %  setup slider position
   %
   h = findobj(gcf,'Tag','LVButtonSlider');
   s_pos = get(h,'Position');
   s_pos(2) = v_pos(end);
   s_pos(4) = v_pos(1) - v_pos(end) + row_height;
   set(h,'Position',s_pos);
 

   setappdata(gcf,'LV_hlist',lv_hdls);
   setappdata(gcf,'NumLVRows',rows);

   return;						% SetupLVButtonRows


% --------------------------------------------------------------------
function  DisplayLVButtons()

   curr_lv_state = getappdata(gcf,'CurrLVState');
   top_lv_button = getappdata(gcf,'TopLVButton');
   lv_hdls = getappdata(gcf,'LV_hlist');
   rows = getappdata(gcf,'NumLVRows');

   num_lvs = length(curr_lv_state);

   lv_idx = top_lv_button;
   for i=1:rows,
       l_hdl = lv_hdls(i);
       if (lv_idx <= num_lvs),
          set(lv_hdls(i),'String',sprintf('LV #%d',lv_idx), ...
			 'Value',curr_lv_state(lv_idx), ...
	                 'Visible','on', ...
                         'Userdata',i);
          lv_idx = lv_idx + 1;
       else
          set(lv_hdls(i),'String','','Visible','off');
       end
   end;

   if (top_lv_button ~= 1) | (num_lvs > rows)
      set(findobj(gcf,'Tag','LVButtonSlider'),'Visible','on');
   else
      set(findobj(gcf,'Tag','LVButtonSlider'),'Visible','off');
   end;

   return;						% DisplayLVButtons


%----------------------------------------------------------------------------
function MoveSlider()

   slider_hdl = findobj(gcf,'Tag','LVButtonSlider');
   curr_value = round(get(slider_hdl,'Value'));
   total_rows = round(get(slider_hdl,'Max'));

   top_lv_button = total_rows - curr_value + 1;

   setappdata(gcf,'TopLVButton',top_lv_button);

   DisplayLVButtons;

   return;                                              % MoveSlider



%----------------------------------------------------------------------------
function SetTopLVButton(top_lv_button)

   slider_hdl = findobj(gcf,'Tag','LVButtonSlider');
   total_rows = round(get(slider_hdl,'Max'));

   slider_value = total_rows - top_lv_button + 1;
   set(slider_hdl,'Value',slider_value);

   setappdata(gcf,'TopLVButton',top_lv_button);

   DisplayLVButtons;

   return;                                              % SetTopLVButton


%----------------------------------------------------------------------------
function SetupSlider()


   top_lv_button = getappdata(gcf,'TopLVButton');
   rows = getappdata(gcf,'NumLVRows');

   curr_lv_state = getappdata(gcf,'CurrLVState');
   num_lvs = length(curr_lv_state);

   total_rows = num_lvs;
   slider_hdl = findobj(gcf,'Tag','LVButtonSlider');

   if (total_rows > 1)           % don't need to update when no condition
      set(slider_hdl,'Min',1,'Max',total_rows, ...
                  'Value',total_rows-top_lv_button+1, ...
                  'Sliderstep',[1/(total_rows-1)-0.00001 1/(total_rows-1)]);
   end;

   return;                                              % UpdateSlider


%---------------------------------------------------------------------------
function SelectLV(selected_lv)

   lv_state = getappdata(gcf,'CurrLVState');
   LV_hlist = getappdata(gcf,'LV_hlist');
   top_lv = getappdata(gcf,'TopLVButton');
   rows = getappdata(gcf,'NumLVRows');
   bottom_lv = top_lv + rows - 1;


   %  remove the previous selection
   %
   prev_selected_lv = find(lv_state == 1);
   if (prev_selected_lv >= top_lv & prev_selected_lv <= bottom_lv),
      row_idx = prev_selected_lv - top_lv + 1;
      set(LV_hlist(row_idx),'Value',0);
   end;

   UpdateLVButtonList = 0;
   if ~exist('selected_lv','var')	 % select LV interactively
      curr_row = get(gcbo,'Userdata');
      curr_lv = top_lv + curr_row -1;
      set(LV_hlist(curr_row),'Value',1);
   else					 % select LV by specifying the index
      curr_lv = selected_lv;
      if (selected_lv >= top_lv & selected_lv <= bottom_lv),
         row_idx = selected_lv - top_lv + 1;
         set(LV_hlist(row_idx),'Value',1);
      else
         UpdateLVButtonList = 1;
      end;
   end;

   lv_state = zeros(1,length(lv_state));
   lv_state(curr_lv) = 1;

   setappdata(gcf,'CurrLVState',lv_state);

   if (UpdateLVButtonList)
      SetTopLVButton(curr_lv);
   end;

   return;                                              % SelectLV


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

     fmri_plot_brain_scores_pos = get(gcbf,'position');

     save(pls_profile, '-append', 'fmri_plot_brain_scores_pos');
  catch
  end

  return; 					% delete_fig


%--------------------------------------------------------------------------
function set_combine_plot()

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

  return; 					% set_combine_plot

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

  fn = sessionFileList{1}{1};

  cnt = 0;
  num_groups = length(sessionFileList);
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
function  [st_datamat,st_coords,st_win_size,st_evt_list] =  ...
                                         load_plotted_datamat(selected_idx)

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   st_filename = getappdata(gcf,'STFiles');

   h = findobj(gcf,'Tag','STDatamatPopup');
   selected_idx = get(h,'Value');
   data_option = get(h,'Userdata');

   switch (data_option)
      case {1}, 
         selected_files{1} = st_filename{selected_idx}.fullname;
      case {2},
         cnt = 0;
         for i=1:length(st_filename),
            if (st_filename{i}.group == selected_idx)
               cnt = cnt+1;
               selected_files{cnt} = st_filename{i}.fullname;
            end;
         end;
      case {3},
         cnt = 0;
         for i=1:length(st_filename),
            selected_files{i} = st_filename{i}.fullname;
         end;
   end; 

   %  merge files together
   [st_datamat,st_coords,st_win_size,st_evt_list] =  ...
                                   merge_st_datamat(selected_files);

   cond_selection = getappdata(gcf,'cond_selection');

   [mask, st_evt_list, evt_length] = ...
	fmri_mask_evt_list(st_evt_list, cond_selection);

   st_datamat = st_datamat(mask,:);

   nr = length(st_evt_list);
   nc = length(st_coords);
   st_datamat = reshape(st_datamat,[nr,st_win_size,nc]);

   pls_coords = getappdata(gcf,'PLSCoords');
   dims = getappdata(gcf,'Dims');
   m = zeros(dims);
   m(pls_coords) = 1;

   coord_idx = find (m(st_coords) == 1);
   nc = length(coord_idx);
   st_coords = st_coords(coord_idx);
   st_datamat = st_datamat(:,:,coord_idx);

   set(gcf,'Pointer',old_pointer);

   if ~isequal(st_coords(:),pls_coords(:)),
      st_datamat = [];
      msg = 'ERROR: Incompatible coords for the st_datamat and the PLS result';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   return;                                       % load_plotted_datamat


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


%---------------------------------------------------------------------------
function [brainlv,pls_coords,dims,conditions,subj_group] = load_pls_brainlv(fname)

   brainlv = [];
   pls_coords = [];
   dims = [];
   conditions = [];

   % the following part will not get called during plsgui
   %
   if ~exist('fname','var') | isempty(fname),
     f_pattern = '*_fMRIresult.mat';
     [PLSresultFile,PLSresultFilePath] = rri_selectfile(f_pattern,'Load PLS scores');

     if isequal(PLSresultFile,0), 
        return;
     end;

     fname = [PLSresultFilePath,PLSresultFile];
   end;

if 0
   try 
      load( fname,'brainlv','st_coords','st_dims','SessionProfiles','subj_group' );
   catch
      msg = sprintf('Cannot load the PLS result from file: %s',PLSresultFile);
      disp(['ERROR: ' msg]);
      return;
   end;
end

   load(fname);

   if exist('result','var')
      brainlv = result.u;
      subj_group = result.num_subj_lst;
   end


   rri_changepath('fmriresult');
    
   pls_coords = st_coords;
   dims = st_dims;

   load(SessionProfiles{1}{1});	    % load the condition from session profile
   conditions = session_info.condition;

   cond_selection = getappdata(gcf,'cond_selection');

   if ~isempty(cond_selection)
      conditions = conditions(find(cond_selection));
   end

   return;					% load_pls_brainlv 


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
function  status = get_brain_scores()

   status = 0;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   h = findobj(gcf,'Tag','STDatamatPopup');
   popup_string = get(h,'String');
   selected_idx = get(h,'Value');
   selected_data = popup_string{selected_idx};

   last_datamat = getappdata(gcf,'PlottedDatamat');

   if (strcmp(last_datamat,selected_data) == 0)

       set(findobj(gcf,'Tag','MessageLine'),'String','Loading data ... ');

       [st_datamat, st_coords, st_win_size, st_evt_list] = ...
                                    load_plotted_datamat(selected_idx);
       if isempty(st_datamat)
           set(gcf,'Pointer',old_pointer);
           return;
       end;

       setappdata(gcf,'PlottedDatamat',selected_data);
       setappdata(gcf,'STDatamat',st_datamat);
       setappdata(gcf,'STWinSize',st_win_size);
       setappdata(gcf,'STEvtList',st_evt_list);

       set(findobj(gcf,'Tag','MessageLine'),'String','');
   else
       set(gcf,'Pointer',old_pointer);
       status = 1;
       return;
   end;


   brainlv = getappdata(gcf,'BrainLV');
   curr_lv_state = getappdata(gcf,'CurrLVState');
   pls_coords = getappdata(gcf,'PLSCoords');

   num_lvs = length(curr_lv_state);
   num_voxels = length(pls_coords);
   num_evts = length(st_evt_list);
   
   blv = reshape(brainlv,[st_win_size,num_voxels,num_lvs]);
   bs = zeros(st_win_size,num_evts,num_lvs);

   for i=1:st_win_size,
      if ndims(blv)==2
         bs(i,:,:) = squeeze(st_datamat(:,i,:)) * blv(i,:)'; 
      else
         bs(i,:,:) = squeeze(st_datamat(:,i,:)) * squeeze(blv(i,:,:)); 
      end
   end;

   setappdata(gcf,'CurrBrainScores',bs);

   status = 1;

   set(gcf,'Pointer',old_pointer);

   return;                                              % get_brain_scores


%--------------------------------------------------------------------------
%
function plot_brain_scores()

   if (get_brain_scores ~= 1);
      return;
   end;

   st_evt_list = getappdata(gcf,'STEvtList');

   conditions = getappdata(gcf,'Conditions');
   curr_lv_state = getappdata(gcf,'CurrLVState');
   select_lv = find(curr_lv_state == 1);

   h = findobj(gcf,'Tag','PlotButton');
   if strcmp(lower(get(h,'Enable')),'off'),  return; end;

   bs = getappdata(gcf,'CurrBrainScores');
   plotted_data = squeeze(bs(:,:,select_lv))';

   num_conditions = length(getappdata(gcf,'Conditions'));
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
   plot_cond_idx = [1:num_conditions];

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

   f_pos = get(gcf,'Position');
   axes_margin = [.37 .13 .15 .1];

   ssb_fmri_plot_cond_stim_ui('STARTUP', plotted_data, condition,  ...
           	                    axes_margin, plot_dims, plot_cond_idx);

   setappdata(gcf,'PLS_PLOT_BS_ACTIVE',1);
%   save('PLS_plotted_bs','plotted_data','condition');
   setappdata(gcf,'PLS_BS_PLOTTED_DATA',plotted_data);
   setappdata(gcf,'PLS_BS_PLOTTED_CONDITON',condition);
%   set(findobj(gcf,'Tag','PlotMenu'),'Enable','on');
%   set(findobj(gcf,'Tag','OptionMenu'),'Enable','on');

   return;


%--------------------------------------------------------------------------
%
function  save_response_fn()

   if (get_brain_scores ~= 1);
      return;
   end;

   subj_group = getappdata(gcf,'subj_group');
   st_evt_list = getappdata(gcf,'STEvtList');
   curr_lv_state = getappdata(gcf,'CurrLVState');
   select_lv = find(curr_lv_state == 1);
   bs = getappdata(gcf,'CurrBrainScores');
   bs_data = squeeze(bs(:,:,select_lv))';
   selected_files = get_selected_filename;



   [a1 b1]=sort(st_evt_list);
   c1 = length(unique(st_evt_list));


if ~iscell(subj_group)
   b2 = reshape(b1, [length(st_evt_list)/c1, c1]);
   b2 = b2';
   b2 = b2(:)';
   st_evt_list = st_evt_list(b2);
   bs_data = bs_data(b2, :);
end


   bs_data_mean = ones(c1, size(bs_data,2));

   for i = 1:c1
      bs_data_mean(i,:) = mean(bs_data(find(st_evt_list==i),:),1);
   end


   fn = getappdata(gcf,'STFiles');
   fn = fn{1}.name;

   if findstr('BfMRIdatamat.mat', fn)
      [filename, pathname] = ...
	rri_selectfile('*_BfMRI_bs_plot.mat','Save the Response Functions');

      if ischar(filename) & ~all(ismember('_bfmri_bs_plot',lower(filename)))
         [tmp filename] = fileparts(filename);
         filename = [filename, '_BfMRI_bs_plot.mat'];
      end
   else
      [filename, pathname] = ...
	rri_selectfile('*_fMRI_bs_plot.mat','Save the Response Functions');

      if ischar(filename) & ~all(ismember('_fmri_bs_plot',lower(filename)))
         [tmp filename] = fileparts(filename);
         filename = [filename, '_fMRI_bs_plot.mat'];
      end
   end

   if isequal(filename,0)
	return;
   end;
   rf_plot_file = fullfile(pathname,filename);

   try
     save (rf_plot_file, 'selected_files', 'bs_data', 'bs_data_mean', 'st_evt_list', 'select_lv');
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

   if (get_brain_scores ~= 1);
      return;
   end;

   curr_lv_state = getappdata(gcf,'CurrLVState');
   select_lv = find(curr_lv_state == 1);
   bs = getappdata(gcf,'CurrBrainScores');
   st_data = squeeze(bs(:,:,select_lv))';
   [nr nc] = size(st_data);

%  data_option = 1  - plot individual ST datamat
%  data_option = 2  - plot group data
%  data_option = 3  - plot all data

   popup_h = findobj(gcf,'Tag','STDatamatPopup');
   selected_idx = get(popup_h,'value');
   data_option = get(popup_h,'Userdata');

   st_filenames = getappdata(gcf,'STFiles');

   num_cond = sum(getappdata(gcf,'cond_selection'));
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

