%ERP_PLOT_OPTION_UI Option window for plotting ERP waveforms
%
%  USAGE: option_fig = erp_plot_option_ui
%
%   ERP_PLOT_UI will display option window
%

%   Called by ERP_PLOT_UI
%
%   O (h01) - handle of option figure
%
%   Created on 26-NOV-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h01 = erp_plot_option_ui(varargin)

   if nargin == 0 | ~ischar(varargin{1})

      h01 = init(varargin{1});

      return;

   end

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = varargin{1};

   if strcmp(action,'select_all')
      select_all;
   elseif strcmp(action,'select_subj_in_cond')
      select_subj_in_cond;
   elseif strcmp(action,'select_cond_in_subj')
      select_cond_in_subj;
   elseif strcmp(action,'select_subj_in_cond_grp_corr')
      select_subj_in_cond_grp_corr;
   elseif strcmp(action,'select_subj_in_cond_grp')
      select_subj_in_cond_grp;
   elseif strcmp(action,'select_cond_in_subj_grp_corr')
      select_cond_in_subj_grp_corr;
   elseif strcmp(action,'select_cond_in_subj_grp')
      select_cond_in_subj_grp;
   elseif strcmp(action,'select_subj_in_cond_grp_corr_hdl')
      select_subj_in_cond_grp_corr_hdl;
   elseif strcmp(action,'select_subj_in_cond_grp_hdl')
      select_subj_in_cond_grp_hdl;
   elseif strcmp(action,'select_cond_in_subj_grp_corr_hdl')
      select_cond_in_subj_grp_corr_hdl;
   elseif strcmp(action,'select_cond_in_subj_grp_hdl')
      select_cond_in_subj_grp_hdl;
   elseif strcmp(action,'select_x_tick_interval')
      select_x_tick_interval;
   elseif strcmp(action,'select_y_tick_interval')
      select_y_tick_interval;
   elseif strcmp(action,'select_rescale')
      select_rescale;
   elseif strcmp(action,'click_ok')
      click_ok;
   elseif strcmp(action,'click_cancel')
      close(gcf);
   elseif strcmp(action,'delete_fig')
      delete_fig(varargin{2});
   end

   return;					% erp_plot_option_ui


%
%  initialize GUI
%
%-------------------------------------------------------------

function h01 = init(h0)

   view_option = getappdata(h0,'view_option');

   save_setting_status = 'on';
   erp_plot_option_pos = [];
   erp_plot_option1_pos = [];

   try
      load('pls_profile');
   catch
   end

   if view_option == 1
      if ~isempty(erp_plot_option1_pos) & strcmp(save_setting_status,'on')
         pos = erp_plot_option1_pos;
      else
         w = 0.6;
         h = 0.81;
         x = (1-w)/2;
         y = (1-h)/2;

         pos = [x y w h];
      end

      h01 = figure('units','normal', ...
         'numberTitle','off', ...
         'menubar', 'none', ...
         'toolBar','none', ...
         'name','Display Options', ...
         'deletefcn','erp_plot_option_ui(''delete_fig'',1);', ...
         'tag','option_fig', ...
         'position', pos);
   else
      if ~isempty(erp_plot_option_pos) & strcmp(save_setting_status,'on')
         pos = erp_plot_option_pos;
      else
         w = 0.6;
         h = 0.58;
         x = (1-w)/2;
         y = (1-h)/2;

         pos = [x y w h];
      end

      h01 = figure('units','normal', ...
         'numberTitle','off', ...
         'menubar', 'none', ...
         'toolBar','none', ...
         'name','Display Options', ...
         'deletefcn','erp_plot_option_ui(''delete_fig'',0);', ...
         'tag','option_fig', ...
         'position', pos);
   end

   % numbers of lines excluding 'MessageLine'

   top_margin = 0.05;
   left_margin = 0.05;
   num_line = 14;
   factor_line = (1-top_margin)/(num_line+1);

   if view_option == 1

      num_line = 20;
      factor_line = (1-top_margin)/(num_line+1);

      %----------------------- avg wave selection -----------------------

      x = 0;
      y = (num_line-0) * factor_line;
      w = 1;
      h = 1 * factor_line;

      pos = [x y w h];

      h1 = uicontrol('parent',h01, ...             % avg selection label
        'units','normal', ...
        'style','text', ...
        'fontunit','normal', ...
        'fontsize',0.55, ...
        'back',[0.8 0.8 0.8], ...
        'string','Select Grand Average to Display', ...
        'position',pos);

      x = left_margin;
      y = (num_line-4)*factor_line;
      w = 1 - 2*left_margin;
      h = 4 * factor_line;

      pos = [x y w h];

      avg_lst_hdl = uicontrol('parent',h01, ... % avg selection listbox
        'unit','normal', ...
        'style','listbox', ...
        'fontunit','normal', ...
        'fontsize',0.144, ...
        'max',2, ...
        'position',pos);

      num_line = 14;

   else
      avg_lst_hdl = [];
   end

   %----------------------- wave selection ---------------------------

   x = 0;
   y = (num_line-0) * factor_line;
   w = 1;
   h = 1 * factor_line;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% wave selection label
        'units','normal', ...
        'style','text', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
	'back',[0.8 0.8 0.8], ...
        'string','Select Wave to Display', ...
        'position',pos);

   x = left_margin;
   y = (num_line-4)*factor_line;
   w = 1 - 2*left_margin;
   h = 4 * factor_line;

   pos = [x y w h];

   wave_lst_hdl = uicontrol('parent',h01, ...	% wave selection listbox
	'unit','normal', ...
	'style','listbox', ...
	'fontunit','normal', ...
	'fontsize',0.144, ...
	'max',2, ...
	'position',pos);

   x = left_margin + 0.55;
   y = (num_line-6)*factor_line;
   w = 0.35;
   h = 1 * factor_line;

   pos = [x y w h];

   select_all_hdl = uicontrol('parent',h01, ...	% wave selection selectall
	'unit','normal', ...
	'style','push', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
	'string','Select All Waves', ...
	'callback', 'erp_plot_option_ui(''select_all'');', ...
	'position',pos);

   x = left_margin + 0.55;
   y = (num_line-8)*factor_line;
   w = 0.35;
   h = 1 * factor_line;

   pos = [x y w h];

   rescale_hdl = uicontrol('Parent',h01, ...		% rescale button
   	'units','normal', ...
	'style','check', ...
	'fontunit','normal', ...
   	'fontsize',0.55, ...
        'horizon','left', ...
        'back', [.8 .8 .8], ...
   	'string','Scale by Singular Value', ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_rescale'');', ...
	'visible', 'off', ...
        'position',pos);

   x = left_margin + 0.55;
   y = (num_line-8)*factor_line;
   w = 0.12;
   h = 1 * factor_line;

   pos = [x y w h];

   subj_in_cond_grp_corr = uicontrol('parent',h01, ...
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_subj_in_cond_grp_corr'');', ...
	'visible', 'off', ...
        'position',pos);

   subj_in_cond_grp = uicontrol('parent',h01, ...
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_subj_in_cond_grp'');', ...
	'visible', 'off', ...
        'position',pos);

   subj_in_cond_lbl = uicontrol('parent',h01, ...% select all subj in cond1
	'unit','normal', ...
	'style','text', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
        'back',[0.8 0.8 0.8], ...
	'horizon','left', ...
	'string','All Subj in:', ...
	'visible', 'off', ...
	'position',pos);

   x = x + w;
   w = 0.23;

   pos = [x y w h];

   subj_in_cond_hdl = uicontrol('parent',h01, ...
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_subj_in_cond'');', ...
	'visible', 'off', ...
        'position',pos);

   subj_in_cond_grp_corr_hdl = uicontrol('parent',h01, ...
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_subj_in_cond_grp_corr_hdl'');', ...
	'visible', 'off', ...
        'position',pos);

   subj_in_cond_grp_hdl = uicontrol('parent',h01, ...
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_subj_in_cond_grp_hdl'');', ...
	'visible', 'off', ...
        'position',pos);

   x = left_margin + 0.55;
   y = (num_line-10)*factor_line;
   w = 0.12;
   h = 1 * factor_line;

   pos = [x y w h];

   cond_in_subj_grp_corr = uicontrol('parent',h01, ...
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_cond_in_subj_grp_corr'');', ...
	'visible', 'off', ...
        'position',pos);

   cond_in_subj_grp = uicontrol('parent',h01, ...
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_cond_in_subj_grp'');', ...
	'visible', 'off', ...
        'position',pos);

   cond_in_subj_lbl = uicontrol('parent',h01, ...% select all cond in subj1
	'unit','normal', ...
	'style','text', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
        'back',[0.8 0.8 0.8], ...
	'horizon','left', ...
	'string','All Cond in:', ...
	'visible', 'off', ...
	'position',pos);

   x = x + w;
   w = 0.23;

   pos = [x y w h];

   cond_in_subj_hdl = uicontrol('parent',h01, ...
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_cond_in_subj'');', ...
	'visible', 'off', ...
        'position',pos);

   cond_in_subj_grp_corr_hdl = uicontrol('parent',h01, ...
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_cond_in_subj_grp_corr_hdl'');', ...
	'visible', 'off', ...
        'position',pos);

   cond_in_subj_grp_hdl = uicontrol('parent',h01, ...
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_cond_in_subj_grp_hdl'');', ...
	'visible', 'off', ...
        'position',pos);

   %-------------------- time interval selection ----------------------

   x = left_margin;
   y = (num_line-6) * factor_line;
   w = 0.3;
   h = 1 * factor_line;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% x-axis tick interval label
        'units','normal', ...
        'style','text', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [0.8 0.8 0.8], ...
	'string', 'Time Axis Tick Interval:', ...
        'position',pos);

   x = x + w;
   y = (num_line-6) * factor_line;
   w = 0.15;

   pos = [x y w h];

   x_tick_interval = uicontrol('parent',h01, ...	% x-axis select
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
	'string',[' '], ...
        'value', 1, ...
	'callback', 'erp_plot_option_ui(''select_x_tick_interval'');', ...
        'position',pos);

   %-------------------- y-axis interval selection -------------------

   x = left_margin;
   y = (num_line-8) * factor_line;
   w = 0.3;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% y-axis tick interval label
        'units','normal', ...
        'style','text', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [0.8 0.8 0.8], ...
        'string', 'Amplitude Tick Interval:', ...
        'position',pos);

   x = x + w;
   y = (num_line-8) * factor_line;
   w = 0.15;

   pos = [x y w h];

   y_tick_interval = uicontrol('parent',h01, ...  % y-axis select
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [1 1 1], ...
        'string',[' '], ...
        'value', 1, ...
        'callback', 'erp_plot_option_ui(''select_y_tick_interval'');', ...
        'position',pos);

   x = left_margin;
   y = (num_line-10) * factor_line;
   w = 0.3;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...              % font size label
        'units','normal', ...
        'style','text', ...
        'fontunit','normal', ...
        'fontsize', 0.55, ...
        'horizon','left', ...
        'back',[0.8 0.8 0.8], ...
        'string','Font Size:', ...
        'position',pos);

   x = x + w;
   y = (num_line-10) * factor_line;
   w = 0.15;

   pos = [x y w h];

   font_size_hdl = uicontrol('parent',h01, ...     % font size select
        'units','normal', ...
        'style','popupmenu', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back',[1 1 1], ...
	'string', ['6 ';'8 ';'10';'11';'12';'14';'16';'18'], ...
        'value', 1, ...
        'callback', 'erp_plot_ui(''choose_font_size'');', ...
        'position',pos);

   x = left_margin;
   y = (num_line-12) * factor_line;
   w = 0.17;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...              % wave size label
        'units','normal', ...
        'style','text', ...
        'fontunit','normal', ...
        'fontsize', 0.55, ...
        'horizon','left', ...
        'back',[0.8 0.8 0.8], ...
        'string','Wave Size:', ...
        'position',pos);

   x = x + w;
   w = 0.28;
   h = 0.8 * factor_line;

   pos = [x y w h];

   hc_wavesize = uicontrol('parent',h01, ...     % wave size slider
        'style','slider', ...
        'units','normal', ...
        'min',0.005, ...
        'max',0.3, ...
        'value',0.07, ...
        'sliderstep',[0.01,0.1], ...
        'callback', 'erp_plot_ui(''move_slider'');', ...
        'position',pos);

   %--------------------  selection button -------------------

   x = x + w + 0.1;
   y = (num_line-12) * factor_line;
   w = 0.15;
   h = 1 * factor_line;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% OK button
	'unit','normal', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
	'horizon','center', ...
	'string', 'OK', ...
	'callback', 'erp_plot_option_ui(''click_ok'');', ...
	'position',pos);

   x = x + w + 0.05;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% Cancel button
	'unit','normal', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
	'hor','center', ...
	'string', 'Cancel', ...
	'callback', 'erp_plot_option_ui(''click_cancel'');', ...
	'position',pos);

   x = 0.01;
   y = 0;
   w = 1;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% Message Line
   	'style','text', ...
   	'units','normal', ...
	'horizon','left', ...
	'fontunit','normal', ...
   	'fontsize',0.55, ...
   	'back',[0.8 0.8 0.8], ...
   	'fore',[0.8 0.0 0.0], ...
   	'String','', ...
   	'tag', 'MessageLine', ...
	'position',pos);

   wave_order = getappdata(h0,'wave_order');		% [idx,subj_idx,cond_idx]
   num_group = getappdata(h0,'num_group');

   if view_option == 1

      set(cond_in_subj_lbl, 'visible', 'on');
      set(cond_in_subj_hdl, 'visible', 'on');
      set(subj_in_cond_lbl, 'visible', 'on');
      set(subj_in_cond_hdl, 'visible', 'on');

      session_info = getappdata(h0,'session_info');
      subj_name = session_info.subj_name;		% cond_name = ave_name below
      selected_subjects = find(getappdata(h0,'selected_subjects'));
      subj_name = subj_name(selected_subjects);

      if ~isempty(subj_name)
         set(cond_in_subj_hdl, 'value', 1, ...
		'string', char([{'(none)'} subj_name]));
      end

   elseif view_option == 2

      set(cond_in_subj_lbl, 'visible', 'on');
      set(cond_in_subj_hdl, 'visible', 'on');
      set(subj_in_cond_lbl, 'visible', 'on', 'string', 'All Grps in:');
      set(subj_in_cond_hdl, 'visible', 'on');

      for i=1:num_group
         subj_name{i} = ['group ' num2str(i)];
      end

      if ~isempty(subj_name)
         set(cond_in_subj_hdl, 'value', 1, ...
		'string', char([{'(none)'} subj_name]));
      end

   elseif view_option == 3

      set(rescale_hdl, 'visible', 'on');

   elseif view_option == 4

      pos = get(h01, 'position');
      set(h01, 'position', [pos(1)-0.05 pos(2) pos(3)+0.1 pos(4)]);
      pos = get(cond_in_subj_grp, 'position');
      set(cond_in_subj_grp, 'visible', 'on', 'position', [pos(1) pos(2) 0.09 pos(4)]);
      pos = get(cond_in_subj_lbl, 'position');
      set(cond_in_subj_lbl, 'visible', 'on', 'position', [pos(1)+0.1 pos(2) 0.12 pos(4)]);
      pos = get(cond_in_subj_grp_hdl, 'position');
      set(cond_in_subj_grp_hdl, 'visible', 'on', 'position', [pos(1)+0.09 pos(2) 0.14 pos(4)]);
      pos = get(subj_in_cond_grp, 'position');
      set(subj_in_cond_grp, 'visible', 'on', 'position', [pos(1) pos(2) 0.09 pos(4)]);
      pos = get(subj_in_cond_lbl, 'position');
      set(subj_in_cond_lbl, 'visible', 'on', 'position', [pos(1)+0.1 pos(2) 0.12 pos(4)]);
      pos = get(subj_in_cond_grp_hdl, 'position');
      set(subj_in_cond_grp_hdl, 'visible', 'on', 'position', [pos(1)+0.09 pos(2) 0.14 pos(4)]);

      for i=1:num_group
         grp_name{i} = ['grp ' num2str(i)];
      end

      if ~isempty(grp_name)
         set(cond_in_subj_grp, 'value', 1, 'string', char(grp_name));
         set(subj_in_cond_grp, 'value', 1, 'string', char(grp_name));
      end

      result_file = getappdata(h0,'datamat_file');
      load(result_file, 'datamat_files','common_conditions');
      rri_changepath('erpresult');

%      grp = get(cond_in_subj_grp, 'value');
      grp = 1;

      load(datamat_files{grp}, 'session_info', 'selected_subjects');
      subj_name = session_info.subj_name(find(selected_subjects));

      if ~isempty(subj_name)
         set(cond_in_subj_grp_hdl, 'value', 1, ...
		'string', char([{'(none)'} subj_name]));
      end

   elseif view_option == 5

      pos = get(h01, 'position');
      set(h01, 'position', [pos(1)-0.05 pos(2) pos(3)+0.1 pos(4)]);
      pos = get(cond_in_subj_grp_corr, 'position');
      set(cond_in_subj_grp_corr, 'visible', 'on', 'position', [pos(1) pos(2) 0.09 pos(4)]);
      pos = get(cond_in_subj_lbl, 'position');
      set(cond_in_subj_lbl, 'visible', 'on', 'position', [pos(1)+0.1 pos(2) 0.12 pos(4)]);
      pos = get(cond_in_subj_grp_corr_hdl, 'position');
      set(cond_in_subj_grp_corr_hdl, 'visible', 'on', 'position', [pos(1)+0.09 pos(2) 0.14 pos(4)]);
      pos = get(subj_in_cond_grp_corr, 'position');
      set(subj_in_cond_grp_corr, 'visible', 'on', 'position', [pos(1) pos(2) 0.09 pos(4)]);
      pos = get(subj_in_cond_lbl, 'position');
      set(subj_in_cond_lbl, 'visible', 'on', 'position', [pos(1)+0.1 pos(2) 0.12 pos(4)], 'string', 'All Beh in:');
      pos = get(subj_in_cond_grp_corr_hdl, 'position');
      set(subj_in_cond_grp_corr_hdl, 'visible', 'on', 'position', [pos(1)+0.09 pos(2) 0.14 pos(4)]);

      for i=1:num_group
         grp_name{i} = ['grp ' num2str(i)];
      end

      if ~isempty(grp_name)
         set(cond_in_subj_grp_corr, 'value', 1, 'string', char(grp_name));
         set(subj_in_cond_grp_corr, 'value', 1, 'string', char(grp_name));
      end

      result_file = getappdata(h0,'datamat_file');

      load(result_file);

      if exist('result','var')
         if isfield(result,'bscan')
            bscan = result.bscan;
         end
      end

if 0
      warning off;
      load(result_file, 'datamat_files','common_conditions','behavname','bscan');
      warning on;
end

      if ~exist('bscan','var') | isempty(bscan)
         bscan = 1:sum(common_conditions);
      end
      
      rri_changepath('erpresult');

%      grp = get(cond_in_subj_grp, 'value');
      grp = 1;

      load(datamat_files{grp}, 'session_info', 'selected_subjects');
%      subj_name = session_info.subj_name(find(selected_subjects));

      if ~isempty(behavname)	% (subj_name)
         set(cond_in_subj_grp_corr_hdl, 'value', 1, ...
		'string', char([{'(none)'} behavname]));
      end

   end

   wave_name = getappdata(h0,'wave_name');		% wave_name string
   selected_wave = getappdata(h0,'selected_wave');  % based on
					% selected_cond & selected_subj
   wave_name = wave_name(selected_wave);
   wave_selection = getappdata(h0,'wave_selection') + 1;

   avg_name = getappdata(h0,'avg_name');		% avg_name string
   selected_avg = find(getappdata(h0,'selected_conditions'));
   avg_name = avg_name(selected_avg);			% = cond_name

   avg_selection = getappdata(h0,'avg_selection') + 1;

   if view_option == 1

      if ~isempty(avg_name)
         set(avg_lst_hdl, 'value', avg_selection, ...
		'string', char([{'(none)'} avg_name]));
         set(subj_in_cond_hdl, 'value', 1, ...
		'string', char([{'(none)'} avg_name]));
      end

   elseif view_option == 2

      result_file = getappdata(h0,'datamat_file');
      load(result_file, 'datamat_files', 'common_conditions');
      rri_changepath('erpresult');
      load(datamat_files{1}, 'session_info');

      set(subj_in_cond_hdl, 'value', 1, 'string', ...
		char([{'(none)'} session_info.condition(find(common_conditions))]));

   elseif view_option == 4

      avg_name = session_info.condition(find(common_conditions));
      set(subj_in_cond_grp_hdl, 'value', 1, ...
		'string', char([{'(none)'} avg_name]));

   elseif view_option == 5

      selected_common = find(common_conditions);
      selected_common = selected_common(bscan);
      conditions_common = zeros(1,length(common_conditions));
      conditions_common(selected_common) = 1;

      avg_name = session_info.condition(find(conditions_common));
      set(subj_in_cond_grp_corr_hdl, 'value', 1, ...
		'string', char([{'(none)'} avg_name]));

   end

   set(wave_lst_hdl, 'value', wave_selection, ...
		'string', char([{'(none)'} wave_name]));

   y_interval = getappdata(h0,'y_interval');
   y_interval_cell = {};

   for i=1:length(y_interval)
      y_interval_cell = [y_interval_cell, {sprintf('%g',y_interval(i))}];
   end

   y_interval = char(y_interval_cell);
   set(y_tick_interval, 'string', y_interval);

   x_interval = getappdata(h0,'x_interval');
   x_interval_cell = {};

   for i=1:length(x_interval)
      x_interval_cell = [x_interval_cell, {sprintf('%d ms',x_interval(i))}];
   end

   x_interval = char(x_interval_cell);
   set(x_tick_interval, 'string', x_interval);

   x_interval_selection = getappdata(h0,'x_interval_selection');
   set(x_tick_interval, 'value', x_interval_selection);

   y_interval_selection = getappdata(h0,'y_interval_selection');
   set(y_tick_interval, 'value', y_interval_selection);

   font_size_selection = getappdata(h0,'font_size_selection');
   set(font_size_hdl, 'value', font_size_selection);

   rescale = getappdata(h0,'rescale');
   set(rescale_hdl, 'value', rescale);

   eta = getappdata(h0,'eta');
   set(hc_wavesize, 'value', eta);

   setappdata(h01,'option_fig',h01);
   setappdata(h01,'wave_lst_hdl',wave_lst_hdl);
   setappdata(h01,'avg_lst_hdl',avg_lst_hdl);
   setappdata(h01,'x_tick_interval',x_tick_interval);
   setappdata(h01,'y_tick_interval',y_tick_interval);
   setappdata(h01,'rescale_hdl',rescale_hdl);
   setappdata(h01,'font_size_hdl', font_size_hdl);
   setappdata(h01,'hc_wavesize',hc_wavesize);

   %  the following variables will be assigned by the interactive
   %  action functions, but may be used before assignment. so,
   %  initial it
   %
   setappdata(h01,'wave_selection',getappdata(h0,'wave_selection'));
   setappdata(h01,'avg_selection',getappdata(h0,'avg_selection'));
   setappdata(h01,'x_interval_selection',getappdata(h0,'x_interval_selection'));
   setappdata(h01,'y_interval_selection',getappdata(h0,'y_interval_selection'));
   setappdata(h01,'rescale',getappdata(h0,'rescale'));

   %  the following variable is used to get
   %  "All Subjects in Condition X" and "AllConditions in SubjectX"
   %
   setappdata(h01,'wave_order',wave_order);

   setappdata(h01,'subj_in_cond_grp_corr',subj_in_cond_grp_corr);
   setappdata(h01,'cond_in_subj_grp_corr',cond_in_subj_grp_corr);
   setappdata(h01,'subj_in_cond_grp',subj_in_cond_grp);
   setappdata(h01,'cond_in_subj_grp',cond_in_subj_grp);
   setappdata(h01,'subj_in_cond_lbl',subj_in_cond_lbl);
   setappdata(h01,'cond_in_subj_lbl',cond_in_subj_lbl);

   setappdata(h01,'subj_in_cond_hdl',subj_in_cond_hdl);
   setappdata(h01,'cond_in_subj_hdl',cond_in_subj_hdl);
   setappdata(h01,'subj_in_cond_grp_corr_hdl',subj_in_cond_grp_corr_hdl);
   setappdata(h01,'cond_in_subj_grp_corr_hdl',cond_in_subj_grp_corr_hdl);
   setappdata(h01,'subj_in_cond_grp_hdl',subj_in_cond_grp_hdl);
   setappdata(h01,'cond_in_subj_grp_hdl',cond_in_subj_grp_hdl);

   return;					%  init


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_all: select all the waves
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_all

   wave_lst_hdl = getappdata(gcf, 'wave_lst_hdl');
   wave_selection = 1 : size(get(wave_lst_hdl, 'string'), 1);
   set(wave_lst_hdl, 'value', wave_selection);

   return						% select_all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_x_tick_interval: select Time axis tick interval
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_x_tick_interval()

   x_tick_interval = getappdata(gcf,'x_tick_interval');
   x_interval_selection = get(x_tick_interval,'value');
   setappdata(gcf, 'x_interval_selection', x_interval_selection);

   return;					% select_x_tick_interval


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_y_tick_interval: select Amplitude tick interval
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_y_tick_interval()

   y_tick_interval = getappdata(gcf,'y_tick_interval');
   y_interval_selection = get(y_tick_interval,'value');
   setappdata(gcf, 'y_interval_selection', y_interval_selection);

   return;					% select_y_tick_interval


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_rescale: select rescale checkbox
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_rescale()

   rescale_hdl = getappdata(gcf,'rescale_hdl');
   rescale = get(rescale_hdl,'value');
   setappdata(gcf, 'rescale', rescale);

   return;					% select_rescale


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   click_ok
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function click_ok

   h01 = gcbf;
   h0 = getappdata(h01,'main_fig');
   view_option = getappdata(h0,'view_option');
   datamat_file = getappdata(h0,'datamat_file');  % get filename for setting
   setting = getappdata(h0,'setting');

   % listbox value are taken now, no callback fcn for listbox
   %
   wave_selection = get(getappdata(h01,'wave_lst_hdl'),'value') - 1;
   if ~isempty(wave_selection)
      setappdata(h01,'wave_selection', wave_selection);
   end

   if view_option == 1
      avg_selection = get(getappdata(h01,'avg_lst_hdl'),'value') - 1;
      if ~isempty(avg_selection)
         setappdata(h01,'avg_selection', avg_selection);
      end
   end

   % collecting setting that may have been changed by callback fcn
   %
   setting.rescale = getappdata(h01,'rescale');
   setting.wave_selection = getappdata(h01,'wave_selection');
   setting.avg_selection = getappdata(h01,'avg_selection');
   setting.x_interval_selection = getappdata(h01,'x_interval_selection');
   setting.y_interval_selection = getappdata(h01,'y_interval_selection');

   if sum(setting.wave_selection)+sum(setting.avg_selection) == 0
      msg = 'ERROR: Please select at least one wave to display';
      msgbox(msg,'ERROR', 'modal');
      return
   end

   old_setting = getappdata(h0, 'setting');

   if isequal(setting,old_setting)		%  nothing was changed
      close(h01);
      return;
   end

   try
      switch view_option
         case {1}				%  subj
            setting1 = setting;
            save(datamat_file, '-append', 'setting1');
         case {2}				%  avg
            setting2 = setting;
            save(datamat_file, '-append', 'setting2');
         case {3}				%  salience
            setting3 = setting;
            save(datamat_file, '-append', 'setting3');
         case {4}				%  grp
            setting4 = setting;
            save(datamat_file, '-append', 'setting4');
         case {5}				%  grp
            setting5 = setting;
            save(datamat_file, '-append', 'setting5');
      end
   catch
      msg = 'Cannot save setting information';
      set(findobj(h01,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   setappdata(h0,'rescale',setting.rescale);
   setappdata(h0,'wave_selection',setting.wave_selection);
   setappdata(h0,'avg_selection',setting.avg_selection);
   setappdata(h0,'x_interval_selection',setting.x_interval_selection);
   setappdata(h0,'y_interval_selection',setting.y_interval_selection);

   setappdata(h0,'setting',setting);
   setappdata(h0, 'init_option',[]);

   close(h01);

   old_pointer0 = get(h0,'pointer');
   set(h0,'pointer','watch');

   erp_showplot_ui(h0);

   set(h0,'pointer',old_pointer0);

   return;					% click_ok


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   delete_fig
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function delete_fig(view_option)

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      if view_option == 1
         erp_plot_option1_pos = get(gcbf,'position');
         save(pls_profile, '-append', 'erp_plot_option1_pos');
      else
         erp_plot_option_pos = get(gcbf,'position');
         save(pls_profile, '-append', 'erp_plot_option_pos');
      end
   catch
   end

   return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_subj_in_cond
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_subj_in_cond

   subj_in_cond_hdl = getappdata(gcf,'subj_in_cond_hdl');
   wave_order = getappdata(gcf,'wave_order');
   wave_lst_hdl = getappdata(gcf,'wave_lst_hdl');
   avg_lst_hdl = getappdata(gcf,'avg_lst_hdl');
   subj_in_cond = get(subj_in_cond_hdl, 'value') - 1;

   if subj_in_cond ~= 0
      idx = wave_order(find(wave_order(:, 3) == subj_in_cond) ,1);
      set(wave_lst_hdl, 'value', idx);
      set(avg_lst_hdl, 'value', subj_in_cond + 1);
   end

   return;					% select_subj_in_cond


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_cond_in_subj
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_cond_in_subj

   cond_in_subj_hdl = getappdata(gcf,'cond_in_subj_hdl');
   wave_order = getappdata(gcf,'wave_order');
   wave_lst_hdl = getappdata(gcf,'wave_lst_hdl');
   avg_lst_hdl = getappdata(gcf,'avg_lst_hdl');
   cond_in_subj = get(cond_in_subj_hdl, 'value') - 1;

   if cond_in_subj ~= 0
      idx = wave_order(find(wave_order(:, 2) == cond_in_subj) ,1);
      set(wave_lst_hdl, 'value', idx);
      set(avg_lst_hdl, 'value', [1:size(get(avg_lst_hdl,'string'),1)]);
   end

   return;					% select_cond_in_subj


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_subj_in_cond_grp
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_subj_in_cond_grp

   wave_lst_hdl = getappdata(gcbf,'wave_lst_hdl');
   set(wave_lst_hdl, 'value', []);
   set(getappdata(gcbf, 'subj_in_cond_grp_hdl'), 'value', 1);
   set(getappdata(gcbf, 'cond_in_subj_grp_hdl'), 'value', 1);

   return;					% select_subj_in_cond_grp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_cond_in_subj_grp
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_cond_in_subj_grp

   grp = get(getappdata(gcbf, 'cond_in_subj_grp'),'value');

   h0 = getappdata(gcbf, 'main_fig');
   result_file = getappdata(h0,'datamat_file');
   load(result_file, 'datamat_files','common_conditions');
   rri_changepath('erpresult');

   load(datamat_files{grp}, 'session_info', 'selected_subjects');
   subj_name = session_info.subj_name(find(selected_subjects));

   if ~isempty(subj_name)
      set(getappdata(gcbf, 'subj_in_cond_grp_hdl'), 'value', 1);
      set(getappdata(gcbf, 'cond_in_subj_grp_hdl'), 'value', 1, ...
		'string', char([{'(none)'} subj_name]));
   end

   wave_lst_hdl = getappdata(gcbf,'wave_lst_hdl');
   set(wave_lst_hdl, 'value', []);

   return;					% select_cond_in_subj_grp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_subj_in_cond_grp_hdl
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_subj_in_cond_grp_hdl

   grp = get(getappdata(gcbf, 'subj_in_cond_grp'),'value');

   subj_in_cond_grp_hdl = getappdata(gcbf,'subj_in_cond_grp_hdl');
   wave_order = getappdata(gcbf,'wave_order');
   wave_lst_hdl = getappdata(gcbf,'wave_lst_hdl');
   num_cond = size(get(subj_in_cond_grp_hdl,'string'), 1) - 1;
   subj_in_cond = (grp - 1) * num_cond + get(subj_in_cond_grp_hdl, 'value') - 1;

   if subj_in_cond ~= 0
      wave_order2 = wave_order(find(wave_order(:, 4) == grp) ,:);
      idx = wave_order2(find(wave_order2(:, 3) == subj_in_cond) ,1);
      set(wave_lst_hdl, 'value', idx);
   end

   return;					% select_subj_in_cond_grp_hdl


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_cond_in_subj_grp_hdl
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_cond_in_subj_grp_hdl

   grp = get(getappdata(gcbf, 'cond_in_subj_grp'),'value');

   cond_in_subj_grp_hdl = getappdata(gcbf,'cond_in_subj_grp_hdl');
   wave_order = getappdata(gcbf,'wave_order');
   wave_lst_hdl = getappdata(gcbf,'wave_lst_hdl');
   cond_in_subj = get(cond_in_subj_grp_hdl, 'value') - 1;

   if cond_in_subj ~= 0
      wave_order2 = wave_order(find(wave_order(:, 4) == grp) ,:);
      idx = wave_order2(find(wave_order2(:, 2) == cond_in_subj) ,1);
      set(wave_lst_hdl, 'value', idx);
   end

   return;					% select_cond_in_subj_grp_hdl


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_subj_in_cond_grp_corr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_subj_in_cond_grp_corr

   wave_lst_hdl = getappdata(gcbf,'wave_lst_hdl');
   set(wave_lst_hdl, 'value', []);
   set(getappdata(gcbf, 'subj_in_cond_grp_corr_hdl'), 'value', 1);
   set(getappdata(gcbf, 'cond_in_subj_grp_corr_hdl'), 'value', 1);

   return;					% select_subj_in_cond_grp_corr


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_cond_in_subj_grp_corr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_cond_in_subj_grp_corr

   wave_lst_hdl = getappdata(gcbf,'wave_lst_hdl');
   set(wave_lst_hdl, 'value', []);
   set(getappdata(gcbf, 'subj_in_cond_grp_corr_hdl'), 'value', 1);
   set(getappdata(gcbf, 'cond_in_subj_grp_corr_hdl'), 'value', 1);

   return;					% select_cond_in_subj_grp_corr


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_subj_in_cond_grp_corr_hdl
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_subj_in_cond_grp_corr_hdl

   grp = get(getappdata(gcbf, 'subj_in_cond_grp_corr'),'value');

   subj_in_cond_grp_corr_hdl = getappdata(gcbf,'subj_in_cond_grp_corr_hdl');
   wave_order = getappdata(gcbf,'wave_order');
   wave_lst_hdl = getappdata(gcbf,'wave_lst_hdl');
   num_cond = size(get(subj_in_cond_grp_corr_hdl,'string'), 1) - 1;
   subj_in_cond = (grp - 1) * num_cond + get(subj_in_cond_grp_corr_hdl, 'value') - 1;

   if subj_in_cond ~= 0
      wave_order2 = wave_order(find(wave_order(:, 4) == grp) ,:);
      idx = wave_order2(find(wave_order2(:, 3) == subj_in_cond) ,1);
      set(wave_lst_hdl, 'value', idx);
   end

   return;					% select_subj_in_cond_grp_corr_hdl


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_cond_in_subj_grp_corr_hdl
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_cond_in_subj_grp_corr_hdl

   grp = get(getappdata(gcbf, 'cond_in_subj_grp_corr'),'value');

   cond_in_subj_grp_corr_hdl = getappdata(gcbf,'cond_in_subj_grp_corr_hdl');
   wave_order = getappdata(gcbf,'wave_order');
   wave_lst_hdl = getappdata(gcbf,'wave_lst_hdl');
   cond_in_subj = get(cond_in_subj_grp_corr_hdl, 'value') - 1;

   if cond_in_subj ~= 0
      wave_order2 = wave_order(find(wave_order(:, 4) == grp) ,:);
      idx = wave_order2(find(wave_order2(:, 2) == cond_in_subj) ,1);
      set(wave_lst_hdl, 'value', idx);
   end

   return;					% select_cond_in_subj_grp_corr_hdl

