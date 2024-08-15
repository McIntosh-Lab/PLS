%ERP_PLOT_BRAIN_SCORES Plot Brain Scores versus Behavior Data
%
%  USAGE: brainscore_fig = erp_plot_brain_scores('STARTUP', resultfile)
%
%--------------------------------------------------------------------

function fig = erp_plot_brain_scores(action,varargin)
%
%  erp_plot_brain_scores(action,action_arg1,...)

   if ~exist('action','var') | isempty(action) 		% no action argument
      return;
   end;

   fig = [];

   if strcmp(action,'STARTUP')			    

      plsResultFile = varargin{1};

      [tmp tit_fn] = rri_fileparts(get(gcf,'name'));
      fig = init(plsResultFile, tit_fn);

      SetupLVButtonRows;
      SetupSlider;
      DisplayLVButtons;

      return;

   end

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

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
         active_plot = getappdata(gcf,'ERP_PLOT_BS_ACTIVE');
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
     case {'TOGGLE_BRAIN'},
         ToggleBrain;
     case {'TOGGLE_ERROR'},
         ToggleError;
     case {'TOGGLE_DETAIL'},
         ToggleDetail;
     case {'TOGGLE_DLV'},
         ToggleDLV;
     case {'TOGGLE_ALLERR'},
         ToggleAllerr;
   end

   return;


%--------------------------------------------------------------------------
%
function fig = init(plsResultFile, tit_fn)

   tit = ['Scalp scores plot for behavior analysis  [', tit_fn, ']'];


   save_setting_status = 'on';
   erp_plot_brain_scores_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(erp_plot_brain_scores_pos) & strcmp(save_setting_status,'on')

      pos = erp_plot_brain_scores_pos;

   else

      w = 0.8;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   hh = figure('Units','normal', ...
	   'user','Scalp scores plot for behavior analysis', ...
	   'name',tit, ...
	   'NumberTitle','off', ...
	   'Color', [0.8 0.8 0.8], ...
 	   'DoubleBuffer','on', ...
	   'Menubar', 'none', ...
	   'DeleteFcn', 'erp_plot_brain_scores(''Delete_Figure'');', ...
	   'Position',pos, ...
	   'Tag','PlotBrainScoreFig');


   %  display datamat
   %

   x = 0.05;
   y = 0.9;
%   w = 0.15;
   w = 0.12;
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
%   w = 0.22;

   pos = [x y w h];

   cb_fn = [ 'erp_plot_brain_scores(''Load_STDatamat'');'];
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

%   x = 0.09;
   x = 0.06;
   y = 0.76;
%   w = 0.14;
   w = 0.1;
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
   w = 0.08;

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
   	   'Callback','erp_plot_brain_scores(''SELECT_LV'');', ...
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
   	   'Callback','erp_plot_brain_scores(''MOVE_SLIDER'');', ...
   	   'Tag','LVButtonSlider');

   x = 0.05  +0.01;
   y = 0.08;
   w = 0.1;

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

   %  file
   %
   rri_file_menu(hh);

  %  plot
  %
  h_plot = uimenu('Parent',hh, ...
             'Label','&Plot', ...
             'Enable','on',...
             'Tag','PlotMenu');
  h0 = uimenu('Parent',h_plot, ...
             'Label','Show &Scalp Scores Overview', ...
             'callback','erp_plot_brain_scores(''TOGGLE_DETAIL'');', ...
             'Tag','DetailMenu');
  h0 = uimenu('Parent',h_plot, ...
             'Label','Show &Correlation Overview', ...
             'callback','erp_plot_brain_scores(''TOGGLE_ALLERR'');', ...
             'Tag','AllerrMenu');
  h0 = uimenu('Parent',h_plot, ...
             'Label','Show Behavior &LV Overview', ...
             'callback','erp_plot_brain_scores(''TOGGLE_DLV'');', ...
             'Tag','DLVMenu');
  h0 = uimenu('Parent',h_plot, ...
	     'sepa','on', ...
             'Label','Hide Scalp Scores Plot', ...
             'callback','erp_plot_brain_scores(''TOGGLE_BRAIN'');', ...
             'Tag','BrainMenu');
  h0 = uimenu('Parent',h_plot, ...
             'Label','Show Correlation Plot', ...
             'callback','erp_plot_brain_scores(''TOGGLE_ERROR'');', ...
             'Tag','ErrorMenu');

  %  option
  %
  h_option = uimenu('Parent',hh, ...
             'Label','&Option', ...
             'Tag','OptionMenu', ...
             'Enable','on',...
             'Visible','on');
  h0 = uimenu('parent',h_option, ...
	     'label','&Show Legend', ...
	'visible','off', ...
	     'userdata',0, ...		% hide legend
	     'callBack', 'pet_plot_cond_stim_ui(''TOGGLELEGEND'');', ...
	     'tag','LegendMenu');
%	     'sepa','on', ...
  h0 = uimenu('Parent',h_option, ...
	     'Label','Change plot dimension', ...
	     'Tag','ChgPlotDims', ...
	     'Callback','pet_plot_cond_stim_ui(''CHANGE_PLOT_DIMS'');');


  lv_template = copyobj_legacy(lv_h,hh);
  set(lv_template,'Tag','LVTemplate','Visible','off');

  setappdata(hh,'result_file',plsResultFile);

  % load the brain scores, conditions, evt_list
  %
  [brainscores,behavlv,s,conditions,selected_conditions, ...
	num_cond_lst,num_subj_lst,lvcorrs,boot_result,perm_result, ...
	session_info,datamat_files]=load_pls_brainscores(plsResultFile);

  % construct the popup label list
  %
  get_datamat_filename(datamat_files, selected_conditions);
  make_datamat_popup(1);


  num_lv = size(brainscores,2);
  curr_lv_state = zeros(1,num_lv); 
  curr_lv_state(1) = 1;

  setappdata(hh,'tit_fn',tit_fn);
  setappdata(hh,'s',s);
  setappdata(hh,'num_cond_lst',num_cond_lst);
  setappdata(hh,'num_subj_lst',num_subj_lst);
  setappdata(hh,'perm_result',perm_result);
  setappdata(hh,'boot_result',boot_result);
  setappdata(hh,'lvcorrs',lvcorrs);
  setappdata(hh,'brainscores',brainscores);
  setappdata(hh,'behavlv',behavlv);
  setappdata(hh,'selected_conditions',selected_conditions);
  setappdata(hh,'Conditions',conditions);
  setappdata(hh,'CurrLVState',curr_lv_state);

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

  setappdata(gcf,'PlotBrainState',1);
  setappdata(gcf,'PlotErrorState',0);
  setappdata(gcf,'PlotDetailState',0);
  setappdata(gcf,'PlotAllerrState',0);
  setappdata(gcf,'PlotDLVState',0);

  plot_brain_scores;

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

  pet_detail_hdl = getappdata(gcbf,'pet_detail_hdl');
  if exist('pet_detail_hdl','var') & ishandle(pet_detail_hdl)
     try
        delete(pet_detail_hdl);
     catch
     end
  end

  pet_allerr_hdl = getappdata(gcbf,'pet_allerr_hdl');
  if exist('pet_allerr_hdl','var') & ishandle(pet_allerr_hdl)
     try
        delete(pet_allerr_hdl);
     catch
     end
  end

  pet_dlv_hdl = getappdata(gcbf,'pet_dlv_hdl');
  if exist('pet_dlv_hdl','var') & ishandle(pet_dlv_hdl)
     try
        delete(pet_dlv_hdl);
     catch
     end
  end

  try
     load('pls_profile');
     pls_profile = which('pls_profile.mat');

     erp_plot_brain_scores_pos = get(gcbf,'position');

     save(pls_profile, '-append', 'erp_plot_brain_scores_pos');
  catch
  end

  h0 = getappdata(gcbf,'main_fig');
  if isempty(h0), return; end;

  hm_brain = getappdata(h0,'hm_brain');
  set(hm_brain, 'userdata',0, 'check','off');


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
  pet_plot_cond_stim_ui('COMBINE_PLOTS',new_state);

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

   datamat_filenames = getappdata(gcf,'datamat_filename');

   switch (data_option)

     case {1}					% plot individual data
        num_datamat = length(datamat_filenames);
        popup_list = cell(1,num_datamat);
        for i=1:num_datamat,
           %  get rid of ".mat" extension if there is any 
           if strcmp(datamat_filenames{i}.name(end-3:end),'.mat')==1
              popup_list{i} = sprintf('[%d] %s', ...
                        datamat_filenames{i}.group, datamat_filenames{i}.name(1:end-4));
           else
              popup_list{i} = sprintf('[%d] %s', ...
                        datamat_filenames{i}.group, datamat_filenames{i}.name);
           end;
        end;
        alignment = 'left';

     case {2}					% plot group data
        num_group = datamat_filenames{end}.group;
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
function get_datamat_filename(datamat_files, selected_conditions)
%
%

  result_file = getappdata(gcf,'result_file');
  num_groups = length(datamat_files);
  behav = [];
  behavcol = 99999;

  warning off;
  try
     load(result_file,'behavname','behavdata_lst');
  catch
  end
  warning on;

  if exist('behavdata_lst','var')
     oldbehav = 0;
%     behav = behavdata;
     behav = [];

     for i=1:num_groups
        behavdata = behavdata_lst{i};
        behav = [behav; behavdata];
     end
  else
     oldbehav = 1;
     behav = [];
  end

  for i=1:num_groups
     [tmp, fn] = fileparts(datamat_files{i});

     datamat_filename{i}.name = fn;
     datamat_filename{i}.fullname = datamat_files{i};
     datamat_filename{i}.group = i;


     warning off;
     load(datamat_files{i},'session_info','selected_subjects','selected_behav');
     warning on;


     datamat_filename{i}.selected_subjects = selected_subjects;
     tmp = session_info.subj_name;
     datamat_filename{i}.subj_name = tmp(find(selected_subjects));


     if oldbehav

        behavdata = session_info.behavdata;

        behavmask = selected_subjects'*selected_conditions;
        behavmask = find(behavmask(:));

        behavdata = behavdata(behavmask,:);


        [r c] = size(behavdata);

        if ~isfield(session_info,'behavname')
            behavname = {};
            for i=1:c
               behavname = [behavname, {['behav', num2str(i)]}];
            end
            selected_behav = ones(1, c);
        else
            behavname = session_info.behavname;
            behavdata = behavdata(:,find(selected_behav));
            behavname = behavname(find(selected_behav));
%            c = size(behavname(:,find(selected_behav)), 2);
            c = size(behavname, 2);
        end

        if c < behavcol
           behavcol = c;
        end

        behavdata = behavdata(:,[1:behavcol]);
        if ~isempty(behav)
           behav = behav(:,[1:behavcol]);
        end

        behav = [behav; behavdata];
        behavname = behavname(1:behavcol);
     end
  end

  setappdata(gcf,'behavname',behavname);
  setappdata(gcf,'behavdata',behav);
  setappdata(gcf,'datamat_filename',datamat_filename);

  return;                                       % get_datamat_filename


%--------------------------------------------------------------------------
%
function  [st_datamat,st_coords,st_win_size,st_evt_list] =  ...
                                         load_plotted_datamat(selected_idx)

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   st_filename = getappdata(gcf,'datamat_filename');

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
function [scalpscores,behavlv,s,conditions,selected_conditions, ...
	num_cond_lst,num_subj_lst,lvcorrs,boot_result,perm_result, ...
	session_info,datamat_files]=load_pls_brainscores(fname)

   brainscores = [];
   conditions = [];

   % the following part will not get called during plsgui
   %
   if ~exist('fname','var') | isempty(fname),
     f_pattern = '*_ERPresult.mat';
     [PLSresultFile,PLSresultFilePath] = rri_selectfile(f_pattern,'Load PLS scores');

     if isequal(PLSresultFile,0), 
        return;
     end;

     fname = [PLSresultFilePath,PLSresultFile];
   end;

   load( fname );

   if exist('result','var')
      if ismember(method, [4 6])
         scalpscores = result.TBusc{2};
         behavlv = result.TBv{2};
      else
         scalpscores = result.usc;
         behavlv = result.v;
      end

      s = result.s;

      if isfield(result,'bscan')
         bscan = result.bscan;
      end

      if isfield(result,'lvcorrs')
         lvcorrs = result.lvcorrs;
      end

      if isfield(result,'perm_result')
         perm_result = result.perm_result;
      else
         perm_result = [];
      end

      if isfield(result,'boot_result')
         boot_result = result.boot_result;
      else
         boot_result = [];
      end
   end

if 0
   try 
      warning off;
      load( fname,'ismultiblock','scalpscores','behavlv','s','perm_result','boot_result', ...
	'num_cond_lst','num_subj_lst','lvcorrs','datamat_files','common_conditions', ...
	'behavname','behav_row_idx','bscan','cond_selection' );
      warning on;
   catch
      msg = sprintf('Cannot load the PLS result from file: %s',fname);
      disp(['ERROR: ' msg]);
      return;
   end;
end

   k = num_cond_lst(1);
   if exist('bscan','var') & ~isempty(bscan)
      kk = length(bscan);
      num_cond_lst = ones(size(num_cond_lst))*kk;
   else
      kk = k;
   end

   if 0 % exist('ismultiblock','var')
      num_groups = length(num_subj_lst);
      t = length(behavname);

      lvcorr = [];

      for g = 1:num_groups
         lvcorr = [lvcorr; lvcorrs((g-1)*k+(g-1)*kk*t+k+1:(g-1)*k+(g-1)*kk*t+k+kk*t,:)];
      end

      lvcorrs = lvcorr;      

      if exist('boot_result','var') & ~isempty(boot_result)
         orig_corr = [];
         ulcorr = [];
         llcorr = [];

         for g = 1:num_groups
            orig_corr = [orig_corr; boot_result.orig_corr((g-1)*k+(g-1)*kk*t+k+1:(g-1)*k+(g-1)*kk*t+k+kk*t,:)];
            ulcorr = [ulcorr; boot_result.ulcorr((g-1)*k+(g-1)*kk*t+k+1:(g-1)*k+(g-1)*kk*t+k+kk*t,:)];
            llcorr = [llcorr; boot_result.llcorr((g-1)*k+(g-1)*kk*t+k+1:(g-1)*k+(g-1)*kk*t+k+kk*t,:)];
         end

         boot_result.orig_corr = orig_corr;
         boot_result.ulcorr = ulcorr;
         boot_result.llcorr = llcorr;
      end
   end

   rri_changepath('erpresult');

   grp_rows = [];
   num_groups = length(datamat_files);
   selected_conditions1 = common_conditions;

   if exist('bscan','var') & ~isempty(bscan)
      selected_conditions = find(selected_conditions1);
      selected_conditions = selected_conditions(bscan);
      cond_selection = zeros(1,length(selected_conditions1));
      cond_selection(selected_conditions) = 1;
   end

   selected_conditions = cond_selection;

   for i=1:num_groups

      load(datamat_files{i}, 'selected_subjects', ...	% 'selected_conditions',
		'session_info');	% load the condition from session profile

      rri_changepath('erpdatamat');

      grp_rows = [grp_rows, sum(selected_subjects)*sum(selected_conditions)];

   end

%   conditions = session_info.condition(find(selected_conditions));
   conditions = session_info.condition;
   setappdata(gcf, 'grp_rows', grp_rows);

   return;					% load_pls_brainscores


%--------------------------------------------------------------------------
%
function  status = get_brain_scores

   status = 0;

   h = findobj(gcf,'Tag','STDatamatPopup');
   popup_string = get(h,'String');
   selected_idx = get(h,'Value');
   selected_data = popup_string{selected_idx};

   last_datamat = getappdata(gcf,'PlottedDatamat');

   % if (isempty(last_datamat) | strcmp(last_datamat,selected_data) == 0)
   if(1)
       setappdata(gcf,'PlottedDatamat',selected_data);
       set(findobj(gcf,'Tag','MessageLine'),'String','');
   else
       status = 2;
       return;
   end;

   datamat_file = getappdata(gcf,'datamat_filename');
   datamat_file = datamat_file{selected_idx}.fullname;

   load(datamat_file, 'selected_conditions', ...
		'session_info');	% load the condition from session profile

   rri_changepath('erpdatamat');

   setappdata(gcf,'session_info',session_info);
%   setappdata(gcf,'selected_conditions',selected_conditions);
   setappdata(gcf,'selected_idx',selected_idx);

   status = 1;

   return;                                              % get_brain_scores


%--------------------------------------------------------------------------
%
function  plot_brain_scores(choice)

   status = get_brain_scores;

   if (status ~= 1);
      return;
   end;

   lv = getappdata(gcf, 'CurrLVState');

   detail_state = getappdata(gcf,'PlotDetailState');
   allerr_state = getappdata(gcf,'PlotAllerrState');
   dlv_state = getappdata(gcf,'PlotDLVState');

   brainscores = getappdata(gcf, 'brainscores');
   behavdata = getappdata(gcf, 'behavdata');
   behavname = getappdata(gcf, 'behavname');
   selected_conditions = getappdata(gcf, 'selected_conditions');
   session_info = getappdata(gcf, 'session_info');
   grp_rows = getappdata(gcf,'grp_rows');
   selected_idx = getappdata(gcf,'selected_idx');
   datamat_filename = getappdata(gcf,'datamat_filename');
   selected_subjects = datamat_filename{selected_idx}.selected_subjects;

   [r c]=size(brainscores);
   numscans = sum(selected_conditions);
   numbehav = size(behavdata, 2);
%   numsubj = session_info.num_subjects;
   num_subj_lst = getappdata(gcf,'num_subj_lst');
   numsubj = num_subj_lst(selected_idx);
   numlvs = c;
   lv = find(lv);

   for behav=1:numbehav

      first = sum(grp_rows(1:selected_idx))-grp_rows(selected_idx)+1;
      last = first+numsubj-1;

      for scan=1:numscans

         p1 = polyfit(behavdata(first:last,behav), ...
		      brainscores(first:last,lv),  1);            
         linc_wave(:,behav,scan) = polyval(p1, behavdata(first:last,behav));
         brain_wave(:,1,scan) = brainscores(first:last,lv);
         behav_wave(:,behav,scan) = behavdata(first:last,behav);

         strong = corrcoef(behavdata(first:last,behav), ...
			   brainscores(first:last,lv)  );
         strong_r(1,behav,scan) = strong(1,2);

         first = first +numsubj;	%scans are stacked, so increment               
         last = last +numsubj;

      end
   end

   first = numscans*numbehav*(selected_idx-1)+1;
   last = first+numscans*numbehav-1;

   boot_result = getappdata(gcf,'boot_result');
   lvcorrs = getappdata(gcf,'lvcorrs');

   if isempty(boot_result)
%      set(findobj('tag','BrainMenu'),'visible','off');
%      set(findobj('tag','ErrorMenu'),'visible','off');
      plotted_data.orig_corr = lvcorrs(first:last,lv);
      plotted_data.ulcorr = [];
      plotted_data.llcorr = lvcorrs(first:last,lv);
   else
      plotted_data.orig_corr = boot_result.orig_corr(first:last,lv);
      plotted_data.ulcorr = boot_result.ulcorr(first:last,lv);
      plotted_data.llcorr = boot_result.llcorr(first:last,lv);
   end

   plotted_data.linc_wave = linc_wave;
   plotted_data.brain_wave = brain_wave;
   plotted_data.behav_wave = behav_wave;
   plotted_data.behavname = behavname;
   plotted_data.strong_r = strong_r;

   condition.cond_name = session_info.condition(find(selected_conditions));
   tmp = session_info.subj_name;
   condition.subj_name = tmp(find(selected_subjects));

   h = findobj(gcf,'Tag','PlotButton');
   if strcmp(lower(get(h,'Enable')),'off'),  return; end;

   % generate the plots
   %
   plot_cond_idx = [1:numscans];

   plot_dims = getappdata(gcf,'PlotDims');

   if isempty(plot_dims) 

       if (numscans < 1)
         num_rows = numscans;
       else
         num_rows = 1;
       end;
       if (numbehav < 1),
         num_cols = numbehav;
       else
         num_cols = 1;
       end;

       plot_dims = [num_rows num_cols];

   end;

   axes_margin = [.25 .05 .18 .05];

   pet_detail_hdl = [];
   pet_allerr_hdl = [];
   pet_dlv_hdl = [];
   h0 = gcf;

   pet_plot_cond_stim_ui('STARTUP', plotted_data, condition,  ...
		axes_margin, plot_dims, plot_cond_idx);

   if detail_state
      pet_detail_hdl = ...
		pet_plot_detail_stim_ui('STARTUP', plotted_data, condition,  ...
		axes_margin, plot_dims, plot_cond_idx, 'Scalp Scores');

      setappdata(pet_detail_hdl,'main_fig',h0);
      setappdata(h0,'pet_detail_hdl',pet_detail_hdl);

      pet_allerr_hdl = getappdata(h0,'pet_allerr_hdl');
      if ~isempty(pet_allerr_hdl) & ishandle(pet_allerr_hdl)
         setappdata(pet_detail_hdl,'pet_allerr_hdl',pet_allerr_hdl);
      end

      pet_dlv_hdl = getappdata(h0,'pet_dlv_hdl');
      if ~isempty(pet_dlv_hdl) & ishandle(pet_dlv_hdl)
         setappdata(pet_detail_hdl,'pet_dlv_hdl',pet_dlv_hdl);
      end
   end

   if allerr_state
      pet_allerr_hdl = pet_plot_allerr;

      setappdata(pet_allerr_hdl,'main_fig',h0);
      setappdata(h0,'pet_allerr_hdl',pet_allerr_hdl);

      pet_detail_hdl = getappdata(h0,'pet_detail_hdl');
      if ~isempty(pet_detail_hdl) & ishandle(pet_detail_hdl)
         setappdata(pet_allerr_hdl,'pet_detail_hdl',pet_detail_hdl);
      end

      pet_dlv_hdl = getappdata(h0,'pet_dlv_hdl');
      if ~isempty(pet_dlv_hdl) & ishandle(pet_dlv_hdl)
         setappdata(pet_allerr_hdl,'pet_dlv_hdl',pet_dlv_hdl);
      end
   end

   if dlv_state
      pet_dlv_hdl = pet_plot_behavlv;

      setappdata(pet_dlv_hdl,'main_fig',h0);
      setappdata(h0,'pet_dlv_hdl',pet_dlv_hdl);

      pet_detail_hdl = getappdata(h0,'pet_detail_hdl');
      if ~isempty(pet_detail_hdl) & ishandle(pet_detail_hdl)
         setappdata(pet_dlv_hdl,'pet_detail_hdl',pet_detail_hdl);
      end

      pet_allerr_hdl = getappdata(h0,'pet_allerr_hdl');
      if ~isempty(pet_allerr_hdl) & ishandle(pet_allerr_hdl)
         setappdata(pet_dlv_hdl,'pet_allerr_hdl',pet_allerr_hdl);
      end
   end

   if exist('choice','var') & strcmp(choice,'detail') & detail_state
      figure(pet_detail_hdl);
   elseif exist('choice','var') & strcmp(choice,'allerr') & allerr_state
      figure(pet_allerr_hdl);
   elseif exist('choice','var') & strcmp(choice,'dlv') & dlv_state
      figure(pet_dlv_hdl);
   else
      figure(h0);
   end

   setappdata(gcf,'ERP_PLOT_BS_ACTIVE',1);
   setappdata(gcf,'PLS_BS_PLOTTED_DATA',plotted_data);
   setappdata(gcf,'PLS_BS_PLOTTED_CONDITON',condition);
   setappdata(gcbf,'pet_detail_hdl',pet_detail_hdl);
   setappdata(gcbf,'pet_allerr_hdl',pet_allerr_hdl);
   setappdata(gcbf,'pet_dlv_hdl',pet_dlv_hdl);

   return;


%--------------------------------------------------------------------------
%
function  ToggleBrain

   brain_state = getappdata(gcf,'PlotBrainState');

   switch (brain_state)
      case {0}

         m_hdl = findobj(gcf,'Tag','BrainMenu');
         set(m_hdl,'Label','Hide Brain Scores Plot');
         setappdata(gcf,'PlotBrainState',1);

         m_hdl = findobj(gcf,'Tag','ErrorMenu');
         set(m_hdl,'Label','Show Correlation Plot');
         setappdata(gcf,'PlotErrorState',0);

         set(findobj('tag','ChgPlotDims'),'visible','on');

         m_hdl = findobj(gcf,'Tag','LegendMenu');
         set(m_hdl,'Label','&Show Legend','userdata',0,'visible','off');

      case {1}

         m_hdl = findobj(gcf,'Tag','BrainMenu');
         set(m_hdl,'Label','Show Scalp Scores Plot');
         setappdata(gcf,'PlotBrainState',0);

         m_hdl = findobj(gcf,'Tag','ErrorMenu');
         set(m_hdl,'Label','Hide Correlation Plot');
         setappdata(gcf,'PlotErrorState',1);

         set(findobj('tag','ChgPlotDims'),'visible','off');

         m_hdl = findobj(gcf,'Tag','LegendMenu');
         set(m_hdl,'Label','&Hide Legend','userdata',1,'visible','on');

   end

   plot_brain_scores;

   return;


%--------------------------------------------------------------------------
%
function  ToggleError

   error_state = getappdata(gcf,'PlotErrorState');

   switch (error_state)
      case {1}

         m_hdl = findobj(gcf,'Tag','BrainMenu');
         set(m_hdl,'Label','Hide Brain Scores Plot');
         setappdata(gcf,'PlotBrainState',1);

         m_hdl = findobj(gcf,'Tag','ErrorMenu');
         set(m_hdl,'Label','Show Correlation Plot');
         setappdata(gcf,'PlotErrorState',0);

         set(findobj('tag','ChgPlotDims'),'visible','on');

         m_hdl = findobj(gcf,'Tag','LegendMenu');
         set(m_hdl,'Label','&Show Legend','userdata',0,'visible','off');

      case {0}

         m_hdl = findobj(gcf,'Tag','BrainMenu');
         set(m_hdl,'Label','Show Scalp Scores Plot');
         setappdata(gcf,'PlotBrainState',0);

         m_hdl = findobj(gcf,'Tag','ErrorMenu');
         set(m_hdl,'Label','Hide Correlation Plot');
         setappdata(gcf,'PlotErrorState',1);

         set(findobj('tag','ChgPlotDims'),'visible','off');

         m_hdl = findobj(gcf,'Tag','LegendMenu');
         set(m_hdl,'Label','&Hide Legend','userdata',1,'visible','on');

   end

   plot_brain_scores;

   return;


%--------------------------------------------------------------------------
%
function  ToggleDetail

   detail_state = getappdata(gcf,'PlotDetailState');

   switch (detail_state)
      case {1}

         m_hdl = findobj(gcf,'Tag','DetailMenu');
         set(m_hdl,'Label','Show Scalp Scores &Overview');
         setappdata(gcf,'PlotDetailState',0);

         pet_detail_hdl = getappdata(gcf,'pet_detail_hdl');
         if exist('pet_detail_hdl','var') & ishandle(pet_detail_hdl)
            try
               delete(pet_detail_hdl);
            catch
            end
         end

      case {0}

         m_hdl = findobj(gcf,'Tag','DetailMenu');
         set(m_hdl,'Label','Hide Scalp Scores &Overview');
         setappdata(gcf,'PlotDetailState',1);

         plot_brain_scores('detail');

   end

   return;


%----------------------------------------------------------------------------
%
function num_cond = light_get_common(datamat_files)

   common_conditions = [];
   num_files = length(datamat_files);

   for i=1:num_files

      load(datamat_files{i}, 'selected_conditions');

      %  initially, common_conditions is empty, init it with zero array
      %
      if isempty(common_conditions)
         common_conditions = zeros(1,length(selected_conditions));
      end

      common_conditions = common_conditions + selected_conditions;

   end

   %  find only the overlap parts of common conditions
   %
   idx = find(common_conditions == num_files);
   common_conditions = zeros(1,length(selected_conditions));
   common_conditions(idx) = 1;

   num_cond = sum(common_conditions);

   return;


%--------------------------------------------------------------------------
%
function  ToggleDLV

   dlv_state = getappdata(gcf,'PlotDLVState');

   switch (dlv_state)
      case {1}

         m_hdl = findobj(gcf,'Tag','DLVMenu');
         set(m_hdl,'Label','Show Behavior &LV Overview');
         setappdata(gcf,'PlotDLVState',0);

         pet_dlv_hdl = getappdata(gcf,'pet_dlv_hdl');
         if exist('pet_dlv_hdl','var') & ishandle(pet_dlv_hdl)
            try
               delete(pet_dlv_hdl);
            catch
            end
         end

      case {0}

         m_hdl = findobj(gcf,'Tag','DLVMenu');
         set(m_hdl,'Label','Hide Behavior &LV Overview');
         setappdata(gcf,'PlotDLVState',1);

         plot_brain_scores('dlv');

   end

   return;


%--------------------------------------------------------------------------
%
function  ToggleAllerr

   allerr_state = getappdata(gcf,'PlotAllerrState');

   switch (allerr_state)
      case {1}

         m_hdl = findobj(gcf,'Tag','AllerrMenu');
         set(m_hdl,'Label','Show &Correlation Overview');
         setappdata(gcf,'PlotAllerrState',0);

         pet_allerr_hdl = getappdata(gcf,'pet_allerr_hdl');
         if exist('pet_allerr_hdl','var') & ishandle(pet_allerr_hdl)
            try
               delete(pet_allerr_hdl);
            catch
            end
         end

      case {0}

         m_hdl = findobj(gcf,'Tag','AllerrMenu');
         set(m_hdl,'Label','Hide &Correlation Overview');
         setappdata(gcf,'PlotAllerrState',1);

         plot_brain_scores('allerr');

   end

   return;

