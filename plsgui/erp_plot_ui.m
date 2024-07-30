%ERP_PLOT_UI Plot ERP waveforms
%
%  USAGE: erp_plot_ui({datamat_file,view_option})
%
%   ERP_PLOT_UI({datamat_file}) will plot grand mean of datamat_file.
%

%   Called by ERP_CREATE_DATAMAT, ERP_MODIFY_DATAMAT, ERP_RESULT_UI
%		ERP_SHOWPLOT_UI, ERP_PLOT_UI
%
%   I (datamat_file) - Matlab data file that contains a structure array
%			with the datamat information for the study
%			or the result file
%
%   I (view_option) -	1: subject amplitude
%			2: average amplitude 
%			3: salience
%			4: group subj
%			5: behavior corr
%
%   Created on 25-NOV-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fig = erp_plot_ui(varargin)

   if nargin == 0 | ~ischar(varargin{1})	% input is not action

      datamat_file = varargin{1}{1};
      view_option = varargin{1}{2};
      if size(varargin{1},2) == 3
         fig = varargin{1}{3};
      else
         fig = [];
      end

      msg = 'Loading ERP data ...  Please wait !';
      h = rri_wait_box(msg,[0.6 0.1]);

      fig = init(datamat_file, view_option, fig);

      delete(h);

      return;

   end

   action = varargin{1};

   if strcmp(action,'zoom')			% zoom menu clicked
      zoom_on_state = get(gcbo,'Userdata');
      if (zoom_on_state == 1)			% zoom on
         zoom on;

         vernum = get_matlab_version;
         if vernum >= 7004
            hzoom = zoom;
            set(hzoom,'rightclick','InverseZoom');
         end

         set(gcbo,'Userdata',0,'Label','&Zoom off');
         set(gcf,'pointer','crosshair');
      else					% zoom off
         zoom off;
         set(gcf,'buttondown','erp_plot_ui(''fig_bt_dn'');');
         set(gcbo,'Userdata',1,'Label','&Zoom on');
         set(gcf,'pointer','arrow');
      end
   elseif strcmp(action,'legend')		% legend menu clicked
      legend_on_state = get(gcbo,'Userdata');
      if (legend_on_state == 1)			% legend on
         old_pointer = get(gcf,'pointer');
         set(gcf,'pointer','watch');
         display_legend('on');
         set(gcbo,'Userdata',0,'Label','&Legend off');
         set(gcf,'pointer',old_pointer);
      else					% legend off
         display_legend('off');
         set(gcbo,'Userdata',1,'Label','&Legend on');
      end
   elseif strcmp(action,'choose_font_size')
      choose_font_size;
   elseif strcmp(action,'move_slider')
      move_slider;
   elseif strcmp(action, 'toggle_avg')
      toggle_avg;
   elseif strcmp(action, 'toggle_salience')
      datamat_file = getappdata(gcf,'datamat_file');
      close(gcf);
      erp_plot_ui({datamat_file,3});
   elseif strcmp(action, 'toggle_subj')
      toggle_subj;
   elseif strcmp(action, 'toggle_corr')
      toggle_corr;
   elseif strcmp(action, 'toggle_detail')
      toggle_detail;
   elseif strcmp(action, 'toggle_eigen')
      toggle_eigen;
   elseif strcmp(action, 'toggle_score')
      toggle_score;
   elseif strcmp(action, 'toggle_tbrain')
      toggle_tbrain;
   elseif strcmp(action, 'toggle_brain')
      toggle_brain;
   elseif strcmp(action, 'toggle_canonical')
      toggle_canonical;
   elseif strcmp(action, 'toggle_canonicalcorr')
      toggle_canonicalcorr;
   elseif strcmp(action, 'toggle_contrast')
      toggle_contrast;
   elseif strcmp(action,'toggle_chan_name')
      toggle_chan_name;
   elseif strcmp(action,'toggle_chan_axes')
      toggle_chan_axes;
   elseif strcmp(action,'toggle_chan_tick')
      toggle_chan_tick;
   elseif strcmp(action,'display_chan_name')
      display_chan_name(varargin{2});
   elseif strcmp(action,'display_chan_axes')
      display_chan_axes(varargin{2});
   elseif strcmp(action,'display_chan_tick')
      display_chan_tick(varargin{2});
   elseif strcmp(action,'option_menu')
      option_menu;
   elseif strcmp(action,'bs_option_menu')
      bs_option_menu;
   elseif strcmp(action,'cond_mean')
      cond_mean;
   elseif strcmp(action,'cond_diff')
      cond_diff;
   elseif strcmp(action,'select_wave')
      select_wave;
   elseif strcmp(action,'select_chan_name')
      select_chan_name;
   elseif strcmp(action,'select_rubber_chan')
      select_rubber_chan;
   elseif strcmp(action,'select_all_chan')
      select_all_chan;
   elseif strcmp(action,'reset_all_chan')
      reset_all_chan;
   elseif strcmp(action,'modify_datamat')
      modify_datamat;
   elseif strcmp(action,'export_data')
      export_data;
   elseif strcmp(action,'fig_bt_dn')
      fig_bt_dn;
   elseif strcmp(action,'delete_fig')
      delete_fig;
   elseif strcmp(action, 'toggle_vir')
      toggle_vir;

   end

   return;					% erp_plot_ui


%
%  initialize GUI
%
%-------------------------------------------------------------

function h0 = init(datamat_file, view_option, fig)

   % initial setting value
   %
   avg_amplitude = [];		% grand average of subjects along condition
   bs_amplitude = [];		% bootstrap wave matrix
   wave_selection = [];		% wave chosen to display from option menu
   avg_selection = [];		% grand average chosen to display
   bs_selection = [];		% bootstrap LVs chosen to display
   bs_ratio = [];		% bootstrap ratio data
   bs_field = [];		% bootstrap field contains bootstrap setting
				% value for all LVs
   mean_wave_list = {};		% new condition which is obtained by averaging others
   mean_wave_name = {};		% name for mean_wave_list
   cond_couple_lst = [];	% condition couple list chosn by user to do cond_diff
   org_wave_name = [];		% original condition name before cond_diff
   org_wave_amplitude = [];	% original wave amplitude before cond_diff
   org_selected_wave = [];	% original selected wave before cond_diff
   x_interval_selection = [];	% x tick value
   y_interval_selection = [];	% y tick value
   font_size_selection =[];	% font size
   eta = [];			% wave size
   chan_name_status = [];	% display channel name?
   chan_axes_status = [];	% display channel axes?
   chan_tick_status = [];	% display channel tick?
   rescale = [];
   s = [];
   old_setting = [];		% saved setting information

   setting1 = [];
   setting2 = [];
   setting3 = [];
   setting4 = [];
   setting5 = [];

   switch view_option		% what to plot?
      case {1}                          %  subj
         try
            warning off;
            load(datamat_file, 'setting1');
            warning on;
            setting = setting1;
         catch
            setting = [];
         end
         fig_name = ['ERP Amplitude: ' datamat_file];
	 fig_user = '';
      case {2}                          %  avg
         try
            warning off;
            load(datamat_file, 'setting2');
            warning on;
            setting = setting2;
         catch
            setting = [];
         end
         fig_name = ['Grand Average Amplitude: ' datamat_file];
	 fig_user = 'Grand Average of ERP Amplitude';
      case {3}                          %  salience
         try
            warning off;
            load(datamat_file, 'setting3');
            warning on;
            setting = setting3;
         catch
            setting = [];
         end
         fig_name = ['Electrodes Salience: ' datamat_file];
	 fig_user = '';
      case {4}                          %  grp
         try
            warning off;
            load(datamat_file, 'setting4');
            warning on;
            setting = setting4;
         catch
            setting = [];
         end
         fig_name = ['Group Subject Amplitude: ' datamat_file];
	 fig_user = 'Group Subject of ERP Amplitude';
      case {5}                          %  corr
         try
            warning off;
            load(datamat_file, 'setting5');
            warning on;
            setting = setting5;
         catch
            setting = [];
         end
         fig_name = ['Spatiotemporal Correlations: ' datamat_file];
	 fig_user = 'Spatiotemporal Correlations';
      otherwise                         %  error
         msg = 'ERROR: No this view option.';
         msgbox(msg,'ERROR','modal');
         return;
   end

   %  load setting value, should be:
   %  either got all value, or none value
   %
   if ~isempty(setting)		% there is setting saved; not new file
      wave_selection = setting.wave_selection;
      avg_selection = setting.avg_selection;
      bs_selection = setting.bs_selection;
      bs_field = setting.bs_field;

      %  new field added later, need verify
      %
      if isfield(setting,'mean_wave_list')
         mean_wave_list = setting.mean_wave_list;
      end

      if isfield(setting,'mean_wave_name')
         mean_wave_name = setting.mean_wave_name;
      end

      if isfield(setting,'cond_couple_lst')
         cond_couple_lst = setting.cond_couple_lst;
      end

      x_interval_selection = setting.x_interval_selection;
      y_interval_selection = setting.y_interval_selection;

      if isfield(setting,'rescale')
         rescale = setting.rescale;
      end

      font_size_selection = setting.font_size_selection;
      eta = setting.eta;
      chan_name_status = setting.chan_name_status;
      chan_axes_status = setting.chan_axes_status;
      chan_tick_status = setting.chan_tick_status;

      old_setting = setting;
   end

   if isempty(rescale)
      rescale = 1;
      setting.rescale = rescale;
   end

   if isempty(font_size_selection)
      font_size_selection = 4;
      setting.font_size_selection = font_size_selection;
   end

   if isempty(eta)
      eta = 0.07;
      setting.eta = eta;
   end

   if isempty(chan_name_status)
      chan_name_status = 1;
      setting.chan_name_status = chan_name_status;
   end

   if isempty(chan_axes_status)
      chan_axes_status = 1;
      setting.chan_axes_status = chan_axes_status;
   end

   if isempty(chan_tick_status)
      chan_tick_status = 1;
      setting.chan_tick_status = chan_tick_status;
   end

   if isempty(bs_field)
      setting.bs_field = bs_field;
   end

   %------------------------- figure ----------------------

   if isempty(fig)			% if fig does not exist

      save_setting_status = 'on';
      erp_plot_pos = [];

      try
         load('pls_profile');
      catch
      end

      if ~isempty(erp_plot_pos) & strcmp(save_setting_status,'on')

         pos = erp_plot_pos;

      else

         w = 0.95;
         h = 0.85;
         x = (1-w)/2;
         y = (1-h)/2;

         pos = [x y w h];

      end

      xp = 0.0227273;
      yp = 0.0294118;
      wp = 1-2*xp;
      hp = 1-2*yp;

      pos_p = [xp yp wp hp];

      h0 = figure('unit','normal', ...
	'paperunit','normal', ...
	'paperorient','land', ...
	'paperposition',pos_p, ...
	'papertype','usletter', ...
        'numberTitle','off', ...
        'menubar', 'none', ...
        'toolbar','none', ...
        'name', fig_name, ...
	'user', fig_user, ...
	'color',[1 1 1], ...
	'buttondown','erp_plot_ui(''fig_bt_dn'');', ...
        'deleteFcn','erp_plot_ui(''delete_fig'');', ...
        'position', pos);

      if exist('isdeployed','builtin') & isdeployed
         set(h0,'Renderer','painters');
      end

      if view_option == 2 | view_option == 4 | view_option == 5
         pos2 = pos;
         pos2(1) = pos2(1) + 0.02;
         pos2(2) = pos2(2) - 0.03;
%         set(h0,'name','Grand Average of ERP Amplitude', ...
%		'position', pos2);
         set(h0,'position', pos2);
      end

      %--------------------------- axes ----------------------

      x = 0;
      y = 0;
      w = 1;
      h = 1;

      pos = [x y w h];

      %  xlim & ylim are obtained thru testing, to make all channels
      %  fit in the figure while getting maximum result
      %
      ha = axes('parent',h0, ...
	'unit','normal', ...
	'color',[1 1 1], ...
	'fontsize', 11, ...
	'xlim',[0 1.1], ...
	'ylim',[-0.05 1.05], ...
	'ticklength',[0.002 1], ...
	'tickdir','out', ...
	'xtick', [], ...
	'ytick', [], ...
	'xaxislocation', 'top', ...
	'yaxislocation', 'left', ...
	'visible','off', ...
	'position', pos);

  % to avoid "The DrawMode property will be removed in a future release" warning in R2014b
  if verLessThan('matlab', '8.4.0') % R2014b
    set(ha,'drawmode', 'fast');
  else
    set(ha,'sortmethod', 'childorder');
  end

  %	'fontunit','normal', ...
  %	'fontname','courier', ...
  %	'fontsize',0.023, ...

      %--------------------------- menu ----------------------

      %  file
      %
      rri_file_menu(h0);

      %  edit
      %
      h_edit = uimenu('parent',h0, ...
           'visible','on', ...
           'label','&Edit');
      h2 = uimenu('parent', h_edit, ...
           'callback','erp_plot_ui(''select_rubber_chan'');', ...
           'label','&Select Electrodes with Rubberband');
      h2 = uimenu('parent', h_edit, ...
           'callback','erp_plot_ui(''select_all_chan'');', ...
           'label','Select &All Electrodes');
      h2 = uimenu('parent', h_edit, ...
           'callback','erp_plot_ui(''reset_all_chan'');', ...
           'label','&De-Select All Electrodes');
      hm_modify = uimenu('parent', h_edit, ...
           'separator', 'on', ...
           'callback','erp_plot_ui(''modify_datamat'');', ...
           'label','&Modify Datamat');

      if view_option ~= 1
         set(hm_modify,'visible','off');
      end

      %  zoom
      %
      h2 = uimenu('parent',h0, ...
           'userdata', 1, ...
           'callback','erp_plot_ui(''zoom'');', ...
           'label','&Zoom on');

      %  tool submenu
      %
      h_tool = uimenu('parent',h0, ...
           'visible','on', ...
           'label','&Tool');
      h2 = uimenu('parent',h_tool, ...
           'callback','erp_plot_ui(''option_menu'');', ...
           'label','&Display Options');
      hm_bs_option = uimenu('parent',h_tool, ...
           'visible','off', ...
           'callback','erp_plot_ui(''bs_option_menu'');', ...
           'label','&BootStrap Options');
      h2 = uimenu('parent',h_tool, ...
           'separator', 'on', ...
           'callback','erp_plot_ui(''export_data'');', ...
           'label','&Export Data');

      if view_option == 2

         h2 = uimenu('parent',h_tool, ...
           'separator', 'on', ...
           'callback', 'erp_plot_ui(''cond_mean'');', ...
           'label','Display Condition &Average');

         h2 = uimenu('parent',h_tool, ...
           'callback', 'erp_plot_ui(''cond_diff'');', ...
           'label','Display &Condition Difference');

      end

      %  view submenu
      %
      h_view = uimenu('parent',h0, ...
           'visible','on', ...
           'label','&View');

      hm_subj = uimenu('parent',h_view, ...		% subj
           'userdata', 0, ...
           'callback','erp_plot_ui(''toggle_subj'');', ...
           'visible', 'off', ...
           'label','Subject Amplitude');

      hm_avg = uimenu('parent',h_view, ...		% avg
           'userdata', 0, ...
           'callback','erp_plot_ui(''toggle_avg'');', ...
           'visible', 'off', ...
           'label','Average Amplitude');

      hm_corr = uimenu('parent',h_view, ...		% corr
           'userdata', 0, ...
           'callback','erp_plot_ui(''toggle_corr'');', ...
           'visible', 'off', ...
           'label','Spatiotemporal Correlation');

      hm_salience = uimenu('parent',h_view, ...		% salience
           'userdata', 0, ...
           'callback','erp_plot_ui(''toggle_salience'');', ...
           'visible', 'off', ...
           'label','Electrode Salience');

      hm_detail = uimenu('parent',h_view, ...
           'userdata', 0, ...
           'callback','erp_plot_ui(''toggle_detail'');', ...
           'label','Plot Detail');

      hm_eigen = [];
      hm_score = [];
      hm_tbrain = [];
      hm_brain = [];
      hm_canonical = [];
      hm_canonicalcorr = [];
      hm_vir = [];
      hm_contrast = [];

      if view_option == 3

         set(hm_subj, 'visible', 'on');
         set(hm_avg, 'visible', 'on');
%         set(hm_corr, 'visible', 'on');

         hm_eigen = uimenu('parent',h_view, ...
           'separator', 'on', ...
           'userdata', 0, ...
           'callback', 'erp_plot_ui(''toggle_eigen'');', ...
           'label','Plot Singular &Values');

         hm_score = uimenu('parent',h_view, ...
           'userdata', 0, ...
           'callback', 'erp_plot_ui(''toggle_score'');', ...
           'label','Plot &Design Scores');

         hm_tbrain = uimenu('parent',h_view, ...
           'userdata', 0, ...
           'callback', 'erp_plot_ui(''toggle_tbrain'');', ...
           'visible', 'off', ...
           'label','Task PLS Scalp Scores with CI');

         hm_brain = uimenu('parent',h_view, ...
           'userdata', 0, ...
           'callback', 'erp_plot_ui(''toggle_brain'');', ...
           'label','Plot &Scalp Scores');

         hm_canonical = uimenu('parent',h_view, ...
           'userdata', 0, ...
           'callback', 'erp_plot_ui(''toggle_canonical'');', ...
           'label','Plot Temporal Scores');

         hm_canonicalcorr = uimenu('parent',h_view, ...
           'userdata', 0, ...
           'callback', 'erp_plot_ui(''toggle_canonicalcorr'');', ...
           'label','Plot Temporal Correlations');

         hm_contrast = uimenu('parent',h_view, ...
	   'userdata', 0, ...
	   'callback', 'erp_plot_ui(''toggle_contrast'');', ...
	   'label','Contrasts Information');

         hm_vir = uimenu('parent',h_view, ...
           'userdata', 0, ...
           'callback', 'erp_plot_ui(''toggle_vir'');', ...
           'label','Subject Amplitude for Given Timepoints');

      end

      hm_chan_name = uimenu('parent',h_view, ...
           'separator', 'on', ...
           'userdata', chan_name_status, ...
           'callback','erp_plot_ui(''toggle_chan_name'');', ...
           'label','Channel &Name');

      if chan_name_status
         set(hm_chan_name, 'check', 'on');
      else
         set(hm_chan_name, 'check', 'off');
      end

      hm_chan_axes = uimenu('parent',h_view, ...
           'userdata', chan_axes_status, ...
           'callback','erp_plot_ui(''toggle_chan_axes'');', ...
           'label','Channel &Axes');

      if chan_axes_status
         set(hm_chan_axes, 'check', 'on');
      else
         set(hm_chan_axes, 'check', 'off');
      end

      hm_chan_tick = uimenu('parent',h_view, ...
           'userdata', chan_tick_status, ...
           'callback','erp_plot_ui(''toggle_chan_tick'');', ...
           'label','Channel &Tickmark');

      if chan_tick_status
         set(hm_chan_tick, 'check', 'on');
      else
         set(hm_chan_tick, 'check', 'off');
      end

      %  legend
      %
      h_legend = uimenu('parent',h0, ...
           'label', '&Legend');
      hm_legend = uimenu('parent',h_legend, ...
           'userdata', 1, ...
           'callback','erp_plot_ui(''legend'');', ...
           'label','&Legend on');

      %  Help submenu
      %
      h_help = uimenu('parent',h0, ...
           'label', '&Help');

%           'callback','rri_helpfile_ui(''erp_result_hlp.txt'',''How to use ERP RESULT'');', ...
      h2 = uimenu('parent',h_help, ...
           'callback','web([''file:///'', which(''UserGuide.htm''), ''#_Toc128820742'']);', ...
	   'visible', 'on', ...
           'label', '&How to use this window?');

      h2 = uimenu('Parent',h_help, ...
           'Label', '&What''s new', ...
	   'Callback','rri_helpfile_ui(''whatsnew.txt'',''What''''s new'');', ...
           'Tag', 'New');
      h2 = uimenu('parent',h_help, ...
           'callBack', 'plsgui_version', ...
           'label', '&About this program');

   else				% if need to use the existing fig
      h0 = fig;
      ha = getappdata(h0,'ha');
      cla
      hm_bs_option = getappdata(h0,'hm_bs_option');
      hm_subj = getappdata(h0,'hm_subj');
      hm_avg = getappdata(h0,'hm_avg');
      hm_corr = getappdata(h0,'hm_corr');
      hm_detail = getappdata(h0,'hm_detail');
      hm_vir = getappdata(h0,'hm_vir');
      hm_eigen = getappdata(h0,'hm_eigen');
      hm_score = getappdata(h0,'hm_score');
      hm_tbrain = getappdata(h0,'hm_tbrain');
      hm_brain = getappdata(h0,'hm_brain');
      hm_canonical = getappdata(h0,'hm_canonical');
      hm_canonicalcorr = getappdata(h0,'hm_canonicalcorr');
      hm_contrast = getappdata(h0,'hm_contrast');
      hm_chan_name = getappdata(h0,'hm_chan_name');
      hm_chan_axes = getappdata(h0,'hm_chan_axes');
      hm_chan_tick = getappdata(h0,'hm_chan_tick');
      hm_legend = getappdata(h0,'hm_legend');
   end				% if empty(fig)

   setappdata(h0,'ha',ha);			% axes
   setappdata(h0,'hm_bs_option',hm_bs_option);	% bootstrap opton
   setappdata(h0,'hm_subj',hm_subj);		% open group subject window
   setappdata(h0,'hm_avg',hm_avg);		% open grand average window
   setappdata(h0,'hm_corr',hm_corr);		% open behavior corr window
   setappdata(h0,'hm_detail',hm_detail);	% open detail plot window
   setappdata(h0,'hm_vir',hm_vir);		% open vir plot window
   setappdata(h0,'hm_eigen',hm_eigen);		% open eigen value window
   setappdata(h0,'hm_score',hm_score);		% open score window
   setappdata(h0,'hm_tbrain',hm_tbrain);	% open tbrain window
   setappdata(h0,'hm_brain',hm_brain);		% open brain window
   setappdata(h0,'hm_canonical',hm_canonical);	% open canonical scores window
   setappdata(h0,'hm_canonicalcorr',hm_canonicalcorr);	% open canonical corr window
   setappdata(h0,'hm_contrast',hm_contrast);	% open contrast window
   setappdata(h0,'hm_chan_name',hm_chan_name);	% channel name
   setappdata(h0,'hm_chan_axes',hm_chan_axes);	% channel axes
   setappdata(h0,'hm_chan_tick',hm_chan_tick);	% channel tickmark
   setappdata(h0,'hm_legend',hm_legend);	% legend

   % ---------  start to pre-process ERP data below  -------------

   avg_name = [];
   wave_name = [];
   wave_order = [];
   bs_name = [];
   selected_bs = [];
   selected_wave = [];		% based on selected_conditions & selected_subj
   selected_wave_info = [];	% [Condition#, subject#]

   selected_subjects = [];	% init
   selected_conditions = [];
   session_info = [];

   try
      load(datamat_file);

      if exist('datafile','var')
         rri_changepath('erpdata');
         load(datafile);
      end

      if ~exist('system','var')
         system.class = 1;
         system.type = 1;
      end
   catch
      msg = ['ERROR: Could not open file ' datamat_file];
      msgbox(msg,'ERROR','modal');
      return;
   end

   if exist('result','var')
      salience = result.u;
      s = result.s;

      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end

      if isfield(result,'perm_result')
         perm_result = result.perm_result;
      else
         perm_result = [];
      end

      if isfield(result,'lvcorrs')
         lvcorrs = result.lvcorrs;
      end

      if isfield(result,'datamatcorrs_lst')
         datamatcorrs_lst = result.datamatcorrs_lst;
      end

      if isfield(result,'stacked_designdata')
         design = result.stacked_designdata;
      end

      brainlv = result.u;
      s = result.s;

      if ismember(method, [1 2])
         isbehav = 0;
      end

      if ismember(method, [3 5])
         isbehav = 1;
      end

      if ismember(method, [4 6])
         isbehav = 2;
         ismultiblock = 1;
      end
   end

   if ~exist('cond_selection','var') & exist('common_conditions','var')
      cond_selection = ones(1, sum(common_conditions));
   end

   if (~exist('bscan','var') | isempty(bscan) ) & exist('common_conditions','var')
      bscan = 1:sum(common_conditions);
   elseif (~exist('bscan','var') | isempty(bscan) )
      bscan = 1:sum(selected_conditions);
   end

   num_group = [];

   switch view_option		% what to plot
      case {1}				% subj

         rri_changepath('erpdatamat');

         if ~isfield(session_info,'system')
            system.class = 1;
            system.type = 1;
         else
            system = session_info.system;
         end

         chan_mask = session_info.chan_order;

         avg_name = session_info.condition;

         %  timepoint_start means the position of start_point
         %  respect to the position of prestim.
         %  while start_timepoint means the position of start_point
         %  respect to 0
         %
         timepoint_start = round((time_info.start_time - time_info.prestim) / time_info.digit_interval +1);
         timepoint_end = round((time_info.end_time - time_info.prestim) / time_info.digit_interval +1);

         %  Chop out the un_selected timepoints
         %
         datamat = datamat(timepoint_start:timepoint_end, :, :, :);
         
         wave_amplitude = reshape(datamat, ...
		[round(time_info.timepoint), ...
		 session_info.num_channels, ...
		 session_info.num_subjects * session_info.num_conditions]);

         %  Grand average for the selected subjects only
         %
         datamat = datamat(:,:,find(selected_subjects),:);
         datamat = mean(datamat, 3);

         avg_amplitude = reshape(datamat, ...
		[round(time_info.timepoint), ...
		 session_info.num_channels, ...
		 session_info.num_conditions]);

         a = 2;				% total increase in order (exclude 'none')
         p = 1;				% selected cond increase in order
         for i=find(selected_conditions)
            q = 1;			% selected subj increase in order
            for j=find(selected_subjects)
               idx = (i-1)*session_info.num_subjects + j;
               selected_wave = [selected_wave idx];
               selected_wave_info(idx, 1) = i;
               selected_wave_info(idx, 2) = j;
               name_str = [session_info.subj_name{j},' in "',avg_name{i}, '"'];
               wave_name{idx} = name_str;
               wave_order(a-1,:) = [a, q, p];
               q = q + 1;
               a = a + 1;
            end
            p = p + 1;
         end

         rescale = 0;
         setting.rescale = rescale;

      case {2}				% average

         rri_changepath('erpresult');

         chan_mask = chan_order(find(common_channels));

         time_info = common_time_info;

         ti = round(time_info.timepoint);
         ch = sum(common_channels);
         lv = size(salience,2);

         newdata_lst = erp_get_common(datamat_files, 1, 1, cond_selection);
         num_group = length(newdata_lst);
         num_cond = sum(common_conditions);

         org_wave_amplitude = erp_datamat2datacub(newdata_lst, ...
		common_channels, common_conditions, mean_wave_list);

         tmp = [ones(1,sum(common_conditions))]' * [1:num_group];
         wave_order = [[1:num_group*num_cond]'+1 tmp(:) [repmat([1:sum(common_conditions)], [1 num_group])]'];

         [dim1 dim2 dim3] = size(org_wave_amplitude);

         wave_amplitude = org_wave_amplitude;
         if ~isempty(cond_couple_lst)
            for i = 1:size(cond_couple_lst,1)
               wave_amplitude(:,:,dim3+i) = ...
		   org_wave_amplitude(:,:,cond_couple_lst(i,1)) - ...
		   org_wave_amplitude(:,:,cond_couple_lst(i,2));
            end
         end

         selected_channels = ones(1,sum(common_channels));
         org_selected_wave = 1:num_cond*num_group;

         selected_wave = [org_selected_wave ...
		length(org_selected_wave)+[1:length(mean_wave_name)] ...
		length(org_selected_wave)+length(mean_wave_name)+[1:size(cond_couple_lst,1)]];
		%  append

         selected_bs = 1:lv;

         %  display bootstrap result if there is one
         %
         if exist('boot_result','var') & ~isempty(boot_result)

            %  get bootstrap ratio from boot_result
            %
            bs_ratio = boot_result.compare;
            bsr = bs_ratio;

            %  initialize bootstrap field
            %
            if isempty(bs_field)
               bs_field = erp_bs_option_ui('set_bs_fields',bsr);
               setting.bs_field = bs_field;
            end

            %  set amplitude to 1 if above threshold, 0 otherwise
            %
            for i = 1:lv
               too_large = find(bsr > (bs_field{i}.max_ratio));
               bsr(too_large) = bs_field{i}.max_ratio;

               too_small = find(bsr < (bs_field{i}.min_ratio));
               bsr(too_small) = bs_field{i}.min_ratio;

               if ~isfield(bs_field{i}, 'thresh2')
                  bs_field{i}.thresh2 = -bs_field{i}.thresh;
               end

               bs_amplitude(:,i) = [bsr(:,i)<bs_field{i}.thresh2] | [bsr(:,i)>bs_field{i}.thresh];
            end

            %  selected_channels & selected_wave will be the same
            %
            bs_amplitude = reshape(bs_amplitude, [ti, ch, lv]);

            %  enable bootstrap option menu
            %
            set(hm_bs_option, 'visible', 'on');

         end    % exist('boot_result')

         %  condition name
         %
         org_wave_name = cond_name(find(common_conditions));
         org_wave_name = repmat(org_wave_name, [1, num_group]);

         g = 1;
         for i = 1:length(org_wave_name)
            org_wave_name{i} = [org_wave_name{i}, ' in group ', num2str(g)];
            if mod(i, num_cond) == 0
               g = g + 1;
            end
         end

         wave_name = [org_wave_name, mean_wave_name];

         %  couple name
         %
         couple_name = cell(1,size(cond_couple_lst,1));

         for i = 1:size(cond_couple_lst,1)
            couple_name{i} = ...
		[wave_name{cond_couple_lst(i,1)} ' - ' wave_name{cond_couple_lst(i,2)}];
%		['cond' num2str(cond_couple_lst(i,1)) ' - cond' num2str(cond_couple_lst(i,2))];
         end

         wave_name = [wave_name, couple_name];

         bs_name = [];
         for i = 1:lv
            bs_name = [bs_name, {['LV',num2str(i)]}];
         end

         rescale = 0;
         setting.rescale = rescale;

      case {3}				% salience

         rri_changepath('erpresult');

%         load(datamat_file, 'isbehav');

         if isbehav == 2
            set(hm_score,'visible','on');
            set(hm_brain,'visible','on');
            set(hm_corr, 'visible', 'on');
            set(hm_canonical, 'visible', 'on');
            set(hm_canonicalcorr, 'visible', 'on');
         elseif isbehav
            set(hm_score,'visible','off');
            set(hm_brain,'visible','on');
            set(hm_corr, 'visible', 'on');
            set(hm_canonical, 'visible', 'off');
            set(hm_canonicalcorr, 'visible', 'on');
         else
            set(hm_score,'visible','on');
            set(hm_brain,'visible','off');
            set(hm_corr, 'visible', 'off');
            set(hm_canonical, 'visible', 'on');
            set(hm_canonicalcorr, 'visible', 'off');
         end

         if ~exist('design','var')
            set(hm_contrast,'visible','off');
         else
            set(hm_contrast,'visible','on');
         end

         chan_mask = chan_order(find(common_channels));

         time_info = common_time_info;

         ti = round(time_info.timepoint);
         ch = sum(common_channels);
         lv = size(salience,2);

         wave_amplitude = reshape(salience, [ti, ch, lv]);
         selected_channels = ones(1,ch);
         selected_wave = 1:lv;
         selected_bs = 1:lv;

         %  display bootstrap result if there is one
         %
         if exist('boot_result','var') & ~isempty(boot_result)

            %  get bootstrap ratio from boot_result
            %
            bs_ratio = boot_result.compare;
            bsr = bs_ratio;

            %  initialize bootstrap field
            %
            if isempty(bs_field)
               bs_field = erp_bs_option_ui('set_bs_fields',bsr);
               setting.bs_field = bs_field;
            end

            %  set amplitude to 1 if above threshold, 0 otherwise
            %
            for i = 1:lv
               too_large = find(bsr > (bs_field{i}.max_ratio));
               bsr(too_large) = bs_field{i}.max_ratio;

               too_small = find(bsr < (bs_field{i}.min_ratio));
               bsr(too_small) = bs_field{i}.min_ratio;

               if ~isfield(bs_field{i}, 'thresh2')
                  bs_field{i}.thresh2 = -bs_field{i}.thresh;
               end

               bs_amplitude(:,i) = [bsr(:,i)<bs_field{i}.thresh2] | [bsr(:,i)>bs_field{i}.thresh];
            end

            %  selected_channels & selected_wave will be the same
            %
            bs_amplitude = reshape(bs_amplitude, [ti, ch, lv]);

            %  enable bootstrap option menu
            %
            set(hm_bs_option, 'visible', 'on');

            if exist('method','var') & ( method == 1 | method == 2 | method == 4 )
               set(hm_tbrain, 'visible', 'on');
            end

         else
            set(hm_tbrain, 'visible', 'off');
         end	% exist('boot_result')

         %  create latent variable name
         %
         wave_name = [];
         bs_name = [];
         for i = 1:lv
            wave_name = [wave_name, {['LV',num2str(i)]}];
            bs_name = [bs_name, {['LV',num2str(i)]}];
         end

      case {4}				% grp

         rri_changepath('erpresult');

         chan_mask = chan_order(find(common_channels));

         time_info = common_time_info;

         ti = round(time_info.timepoint);
         ch = sum(common_channels);
         lv = size(salience,2);

         newdata_lst = erp_get_common(datamat_files, 1, 1, cond_selection);
         num_group = length(newdata_lst);
         num_cond = sum(common_conditions);

         org_wave_name = cond_name(find(common_conditions));
         org_wave_name = repmat(org_wave_name, [1, num_group]);

         grp_id = [];
         g = 1;
         for i = 1:length(org_wave_name)
            org_wave_name{i} = [org_wave_name{i}, ' in group ', num2str(g)];
            grp_id(i) = g;
            if mod(i, num_cond) == 0
               g = g + 1;
            end
         end

         a = 2;				% total increase in order (exclude 'none')
         p = 1;				% selected cond increase in order
         tmp_subj_tot = 0;
         for i = 1:length(org_wave_name)
            q = 1;			% selected subj increase in order
            for j = 1:num_subj_lst(grp_id(i))
               idx = tmp_subj_tot + j;
               selected_wave = [selected_wave idx];
               selected_wave_info(idx, 1) = i;
               selected_wave_info(idx, 2) = j;
               name_str = [subj_name_lst{grp_id(i)}{j},' in "',org_wave_name{i}, '"'];
               wave_name{idx} = name_str;
               wave_order(a-1,:) = [a, q, p, grp_id(i)];
               q = q + 1;
               a = a + 1;
            end
            p = p + 1;
            tmp_subj_tot = tmp_subj_tot + num_subj_lst(grp_id(i));
         end

         [avg_amplitude, wave_amplitude] = ...
		erp_datamat2datacub(newdata_lst, ...
		common_channels, common_conditions, {});
         avg_amplitude = [];

         [dim1 dim2 dim3] = size(wave_amplitude);

         selected_channels = ones(1,sum(common_channels));
         % selected_wave = 1:dim3;

         rescale = 0;
         setting.rescale = rescale;

      case {5}

         rri_changepath('erpresult');

         chan_mask = chan_order(find(common_channels));

         time_info = common_time_info;

         ti = round(time_info.timepoint);
         ch = sum(common_channels);
         lv = size(salience,2);

%         newdata_lst = erp_get_common(datamat_files, 1, 1);	% datamatcorrs_lst
         num_group = length(datamatcorrs_lst);		% length(newdata_lst);
         num_cond = length(bscan);	% sum(common_conditions);
         num_behav = length(behavname);	%sum(common_behav);
         behavname_lst = behavname;	%(find(common_behav));

         selected_common = find(common_conditions);
         selected_common = selected_common(bscan);
         conditions_common = zeros(1,length(common_conditions));
         conditions_common(selected_common) = 1;

         org_wave_name = cond_name(find(conditions_common));
         org_wave_name = repmat(org_wave_name, [1, num_group]);

         grp_id = [];
         g = 1;
         for i = 1:length(org_wave_name)
            org_wave_name{i} = [org_wave_name{i}, ' in group ', num2str(g)];
            grp_id(i) = g;
            if mod(i, num_cond) == 0
               g = g + 1;
            end
         end

         a = 2;				% total increase in order (exclude 'none')
         p = 1;				% selected cond increase in order
         tmp_subj_tot = 0;
         for i = 1:length(org_wave_name)
            q = 1;			% selected subj increase in order
            for j = 1:num_behav    % num_subj_lst(grp_id(i))
               idx = tmp_subj_tot + j;
               selected_wave = [selected_wave idx];
               selected_wave_info(idx, 1) = i;
               selected_wave_info(idx, 2) = j;
%               name_str = [subj_name_lst{grp_id(i)}{j},' in "',org_wave_name{i}, '"'];
               name_str = [behavname_lst{j},' in "',org_wave_name{i}, '"'];
               wave_name{idx} = name_str;
               wave_order(a-1,:) = [a, q, p, grp_id(i)];
               q = q + 1;
               a = a + 1;
            end
            p = p + 1;
            tmp_subj_tot = tmp_subj_tot + num_behav;	% num_subj_lst(grp_id(i));
         end

%         [avg_amplitude, wave_amplitude] = ...
%		erp_datamat2datacub(newdata_lst, ...
%		common_channels, common_conditions, {});
         avg_amplitude = [];
         wave_amplitude = [];

         for i = 1:num_group
            wave_amplitude = [wave_amplitude; datamatcorrs_lst{i}];
         end

         wave_amplitude = reshape(wave_amplitude', [ti ch size(wave_amplitude,1)]);

         [dim1 dim2 dim3] = size(wave_amplitude);

         selected_channels = ones(1,sum(common_channels));
         % selected_wave = 1:dim3;

         selected_bs = 1:lv;

         %  display bootstrap result if there is one
         %
         if exist('boot_result','var') & ~isempty(boot_result)

            %  get bootstrap ratio from boot_result
            %
            bs_ratio = boot_result.compare;
            bsr = bs_ratio;

            %  initialize bootstrap field
            %
            if isempty(bs_field)
               bs_field = erp_bs_option_ui('set_bs_fields',bsr);
               setting.bs_field = bs_field;
            end

            %  set amplitude to 1 if above threshold, 0 otherwise
            %
            for i = 1:lv
               too_large = find(bsr > (bs_field{i}.max_ratio));
               bsr(too_large) = bs_field{i}.max_ratio;

               too_small = find(bsr < (bs_field{i}.min_ratio));
               bsr(too_small) = bs_field{i}.min_ratio;

               if ~isfield(bs_field{i}, 'thresh2')
                  bs_field{i}.thresh2 = -bs_field{i}.thresh;
               end

               bs_amplitude(:,i) = [bsr(:,i)<bs_field{i}.thresh2] | [bsr(:,i)>bs_field{i}.thresh];
            end

            %  selected_channels & selected_wave will be the same
            %
            bs_amplitude = reshape(bs_amplitude, [ti, ch, lv]);

            %  enable bootstrap option menu
            %
            set(hm_bs_option, 'visible', 'on');

         end	% exist('boot_result')

         bs_name = [];
         for i = 1:lv
            bs_name = [bs_name, {['LV',num2str(i)]}];
         end

         rescale = 0;
         setting.rescale = rescale;

      otherwise
         msg = 'ERROR: No this view option.';
         msgbox(msg,'ERROR','modal');
         return;
   end						% switch view_option

   if isempty(wave_amplitude) | isempty(wave_name)
      return;
   end

   if isempty(wave_selection)
      wave_selection = 1;
      setting.wave_selection = wave_selection;
   end

   if isempty(avg_selection)
      avg_selection = 0;
      setting.avg_selection = avg_selection;
   end

   if isempty(bs_selection)
      bs_selection = 1;
      setting.bs_selection = bs_selection;
   end

   color_code = ['b- ';'r- ';'m- ';'g- ';'c- ';'k- '];
%   load('rri_color_code');
   bs_color_code =[
       'bo';'rd';'m<';'g>';'bs';'rv';'m^';'gp';'bh';'rx';'m+';'g*';
       'ro';'gd';'m<';'b>';'rs';'gv';'m^';'bp';'rh';'gx';'m+';'b*';
       'go';'md';'b<';'r>';'gs';'mv';'b^';'rp';'gh';'mx';'b+';'r*';
       'mo';'bd';'r<';'g>';'ms';'bv';'r^';'gp';'mh';'bx';'r+';'g*'];

   if isempty(x_interval_selection)
      x_interval_selection = 1;
      setting.x_interval_selection = x_interval_selection;
   end

   if isempty(y_interval_selection)
      y_interval_selection = 1;
      setting.y_interval_selection = y_interval_selection;
   end

   if ~isequal(setting, old_setting)		% changed was made
      try
         switch view_option
            case {1}                               %  subj
               setting1 = setting;
               save(datamat_file, '-append', 'setting1');
            case {2}                               %  avg
               setting2 = setting;
               save(datamat_file, '-append', 'setting2');
            case {3}                               %  salience
               setting3 = setting;
               save(datamat_file, '-append', 'setting3');
            case {4}                               %  grp
               setting4 = setting;
               save(datamat_file, '-append', 'setting4');
            case {5}                               %  corr
               setting5 = setting;
               save(datamat_file, '-append', 'setting5');
         end
      catch
         msg = 'Cannot save setting information';
         msgbox(msg,'ERROR','modal');
         return;
      end;
   end

   % initialize setting
   %
   setappdata(h0,'setting',setting);
   setappdata(h0,'view_option',view_option);
   setappdata(h0,'datamat_file',datamat_file);
   setappdata(h0,'eta',eta);
   setappdata(h0,'org_wave_amplitude',org_wave_amplitude);
   setappdata(h0,'wave_amplitude',wave_amplitude);
   setappdata(h0,'brain_amplitude',wave_amplitude);
   setappdata(h0,'bs_amplitude',bs_amplitude);
   setappdata(h0,'bs_name',bs_name);
   setappdata(h0,'mean_wave_list',mean_wave_list);
   setappdata(h0,'mean_wave_name',mean_wave_name);
   setappdata(h0,'cond_couple_lst',cond_couple_lst);
   setappdata(h0,'org_wave_name',org_wave_name);
   setappdata(h0,'wave_name',wave_name);
   setappdata(h0,'wave_order',wave_order);
   setappdata(h0,'wave_selection',wave_selection);
   setappdata(h0,'avg_selection',avg_selection);
   setappdata(h0,'bs_selection',bs_selection);
   setappdata(h0,'bs_ratio',bs_ratio);
   setappdata(h0,'bs_field',bs_field);
   setappdata(h0,'color_code',color_code);
   setappdata(h0,'bs_color_code',bs_color_code);
   setappdata(h0,'x_interval_selection',x_interval_selection);
   setappdata(h0,'y_interval_selection',y_interval_selection);
   setappdata(h0,'rescale',rescale);
   setappdata(h0,'s',s);
   setappdata(h0,'font_size_selection',font_size_selection);
   setappdata(h0,'init_option',[]);
   setappdata(h0,'avg_amplitude',avg_amplitude);
   setappdata(h0,'avg_name',avg_name);
   setappdata(h0,'time_info',time_info);
   setappdata(h0,'session_info',session_info);
   setappdata(h0,'selected_channels',selected_channels);
   setappdata(h0,'selected_conditions',selected_conditions);
   setappdata(h0,'selected_subjects',selected_subjects);
   setappdata(h0,'selected_bs',selected_bs);
   setappdata(h0,'org_selected_wave',org_selected_wave);
   setappdata(h0,'selected_wave',selected_wave);
   setappdata(h0,'selected_wave_info',selected_wave_info);
   setappdata(h0,'chan_mask',chan_mask);
   setappdata(h0,'system',system);
   setappdata(h0,'num_group',num_group);

   old_pointer = get(h0,'pointer');
   set(h0,'pointer','watch');
   erp_showplot_ui(h0);
   set(h0,'pointer',old_pointer);

   return;					%  init


%
%
%------------------------------------------------

function choose_font_size

   h0 = getappdata(gcbf,'main_fig');
   h01 = getappdata(gcbf,'option_fig');
   font_size_hdl = getappdata(h01,'font_size_hdl');
   view_option = getappdata(h0,'view_option');
   datamat_file = getappdata(h0,'datamat_file');
   setting = getappdata(h0,'setting');

   font_size_selection = get(font_size_hdl,'value');
   setting.font_size_selection = font_size_selection;
   setappdata(h0,'font_size_selection',font_size_selection);

   setappdata(h0,'setting',setting);
   try
      switch view_option
         case {1}                               %  subj
            setting1 = setting;
            save(datamat_file, '-append', 'setting1');
         case {2}                               %  avg
            setting2 = setting;
            save(datamat_file, '-append', 'setting2');
         case {3}                               %  salience
            setting3 = setting;
            save(datamat_file, '-append', 'setting3');
         case {4}                               %  grp
            setting4 = setting;
            save(datamat_file, '-append', 'setting4');
         case {5}                               %  corr
            setting5 = setting;
            save(datamat_file, '-append', 'setting5');
      end
   catch
      msg = 'Cannot save setting information';
      set(findobj(h01,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   erp_showplot_ui(h0);

   return;                                      % choose_font_size


%
%
%------------------------------------------------

function move_slider

   h0 = getappdata(gcbf,'main_fig');
   h01 = getappdata(gcbf,'option_fig');
   hc_wavesize = getappdata(h01,'hc_wavesize');
   view_option = getappdata(h0,'view_option');
   datamat_file = getappdata(h0,'datamat_file');
   setting = getappdata(h0,'setting');

   eta = get(hc_wavesize,'value');
   setting.eta = eta;
   setappdata(h0,'eta',eta);

   setappdata(h0,'setting',setting);
   try
      switch view_option
         case {1}                               %  subj
            setting1 = setting;
            save(datamat_file, '-append', 'setting1');
         case {2}                               %  avg
            setting2 = setting;
            save(datamat_file, '-append', 'setting2');
         case {3}                               %  salience
            setting3 = setting;
            save(datamat_file, '-append', 'setting3');
         case {4}                               %  grp
            setting4 = setting;
            save(datamat_file, '-append', 'setting4');
         case {5}                               %  corr
            setting5 = setting;
            save(datamat_file, '-append', 'setting5');
      end
   catch
      msg = 'Cannot save setting information';
      set(findobj(h01,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   erp_showplot_ui(h0);

   return;					% move_slider


%
%
%------------------------------------------------

function toggle_avg

   hm_avg = getappdata(gcf,'hm_avg');
   avg_status = get(hm_avg,'userdata');

   if ~avg_status				% was not checked
      set(hm_avg, 'userdata',1, 'check','on');

      view_avg;

   else
      set(hm_avg, 'userdata',0, 'check','off');

      try
         avg_fig_name = get(getappdata(gcf,'avg_fig'),'user');
         if ~isempty(avg_fig_name) ...
		& strcmp(avg_fig_name,'Grand Average of ERP Amplitude')
            close(getappdata(gcf,'avg_fig'));
         end
      catch
      end

   end

   return;					% toggle_avg


%
%
%------------------------------------------------

function toggle_subj

   hm_subj = getappdata(gcf,'hm_subj');
   subj_status = get(hm_subj,'userdata');

   if ~subj_status				% was not checked
      set(hm_subj, 'userdata',1, 'check','on');

      view_subj;

   else
      set(hm_subj, 'userdata',0, 'check','off');

      try
         subj_fig_name = get(getappdata(gcf,'subj_fig'),'user');
         if ~isempty(subj_fig_name) ...
		& strcmp(subj_fig_name,'Group Subject of ERP Amplitude')
            close(getappdata(gcf,'subj_fig'));
         end
      catch
      end

   end

   return;					% toggle_subj


%
%
%------------------------------------------------

function toggle_corr

   result_file = getappdata(gcf,'datamat_file');
   load(result_file);

   if exist('result','var')
      datamatcorrs_lst = result.datamatcorrs_lst;
   end

   hm_corr = getappdata(gcf,'hm_corr');
   corr_status = get(hm_corr,'userdata');

   if ~corr_status				% was not checked
      set(hm_corr, 'userdata',1, 'check','on');

      view_corr;

   else
      set(hm_corr, 'userdata',0, 'check','off');

      try
         corr_fig_name = get(getappdata(gcf,'corr_fig'),'user');
         if ~isempty(corr_fig_name) ...
		& strcmp(corr_fig_name,'Spatiotemporal Correlations')
            close(getappdata(gcf,'corr_fig'));
         end
      catch
      end

   end

   return;					% toggle_corr


%
%
%------------------------------------------------

function toggle_detail

   hm_detail = getappdata(gcf,'hm_detail');
   detail_status = get(hm_detail,'userdata');

   if ~detail_status				% was not checked
      set(hm_detail, 'userdata',1, 'check','on');

      view_detail;

   else
      set(hm_detail, 'userdata',0, 'check','off');

      try
         detail_fig_name = get(getappdata(gcf,'detail_fig'),'user');
         if ~isempty(detail_fig_name) & strcmp(detail_fig_name,'Detail Plot')
            close(getappdata(gcf,'detail_fig'));
         end
      catch
      end

   end

   return;					% toggle_detail


%
%
%------------------------------------------------

function toggle_eigen

   hm_eigen = getappdata(gcf,'hm_eigen');
   eigen_status = get(hm_eigen,'userdata');

   if ~eigen_status				% was not checked
      set(hm_eigen, 'userdata',1, 'check','on');

      view_eigen;

   else
      set(hm_eigen, 'userdata',0, 'check','off');

      try
         eigen_fig_name = get(getappdata(gcf,'eigen_fig'),'user');
         if ~isempty(eigen_fig_name) ...
		& strcmp(eigen_fig_name,'PLS Singular Value Plot')
            close(getappdata(gcf,'eigen_fig'));
         end
      catch
      end

   end

   return;					% toggle_eigen


%
%
%------------------------------------------------

function toggle_score

   hm_score = getappdata(gcf,'hm_score');
   score_status = get(hm_score,'userdata');

   if ~score_status				% was not checked
      set(hm_score, 'userdata',1, 'check','on');

      view_score;

   else
      set(hm_score, 'userdata',0, 'check','off');

      try
         score_fig_name = get(getappdata(gcf,'score_fig'),'user');
         if ~isempty(score_fig_name) ...
		& strcmp(score_fig_name,'PLS Scores Plot')
            close(getappdata(gcf,'score_fig'));
         end
      catch
      end

   end

   return;					% toggle_score


%
%
%------------------------------------------------

function toggle_canonical

   hm_canonical = getappdata(gcf,'hm_canonical');
   canonical_status = get(hm_canonical,'userdata');

   if ~canonical_status				% was not checked
      set(hm_canonical, 'userdata',1, 'check','on');

      view_canonical;
   else
      set(hm_canonical, 'userdata',0, 'check','off');

      try
         canonical_fig_name = get(getappdata(gcf,'canonical_fig'),'user');
         if ~isempty(canonical_fig_name) ...
		& strcmp(canonical_fig_name,'Temporal scores plot')
            close(getappdata(gcf,'canonical_fig'));
         end
      catch
      end
   end

   return;					% toggle_canonical


%
%
%------------------------------------------------

function toggle_canonicalcorr

   hm_canonicalcorr = getappdata(gcf,'hm_canonicalcorr');
   canonicalcorr_status = get(hm_canonicalcorr,'userdata');

   if ~canonicalcorr_status				% was not checked
      set(hm_canonicalcorr, 'userdata',1, 'check','on');

      view_canonicalcorr;
   else
      set(hm_canonicalcorr, 'userdata',0, 'check','off');

      try
         canonicalcorr_fig_name = get(getappdata(gcf,'canonicalcorr_fig'),'user');
         if ~isempty(canonicalcorr_fig_name) ...
		& strcmp(canonicalcorr_fig_name,'Temporal correlations plot')
            close(getappdata(gcf,'canonicalcorr_fig'));
         end
      catch
      end
   end

   return;					% toggle_canonicalcorr


%
%
%------------------------------------------------

function toggle_contrast

   hm_contrast = getappdata(gcf,'hm_contrast');
   contrast_status = get(hm_contrast,'userdata');

   if ~contrast_status				% was not checked
      set(hm_contrast, 'userdata',1, 'check','on');

      view_contrast;
   else
      set(hm_contrast, 'userdata',0, 'check','off');

      try
         contrast_fig_name = get(getappdata(gcf,'contrast_fig'),'tag');
         if ~isempty(contrast_fig_name) ...
		& strcmp(contrast_fig_name,'InputContrast')
            close(getappdata(gcf,'contrast_fig'));
         end
      catch
      end
   end

   return;					% toggle_contrast


%
%
%------------------------------------------------

function toggle_brain

   hm_brain = getappdata(gcf,'hm_brain');
   brain_status = get(hm_brain,'userdata');

   if ~brain_status				% was not checked
      set(hm_brain, 'userdata',1, 'check','on');

      view_brain;

   else
      set(hm_brain, 'userdata',0, 'check','off');

      try
         brain_fig_name = get(getappdata(gcf,'brain_fig'),'user');
         if ~isempty(brain_fig_name) ...
		& strcmp(brain_fig_name,'Scalp scores plot for behavior analysis')
            close(getappdata(gcf,'brain_fig'));
         end
      catch
      end

   end

   return;					% toggle_brain


%
%
%------------------------------------------------

function toggle_chan_name

   hm_chan_name = getappdata(gcf,'hm_chan_name');
   view_option = getappdata(gcf,'view_option');
   datamat_file = getappdata(gcf,'datamat_file');
   setting = getappdata(gcf,'setting');
   chan_name_status = get(hm_chan_name,'userdata');

   if ~chan_name_status				% was not checked
      set(hm_chan_name, 'userdata',1, 'check','on');
      erp_plot_ui('display_chan_name','on');
   else
      set(hm_chan_name, 'userdata',0, 'check','off');
      erp_plot_ui('display_chan_name','off');
   end

   chan_name_status = get(hm_chan_name,'userdata');
   setting.chan_name_status = chan_name_status;

   setappdata(gcf,'setting',setting);
   try
      switch view_option
         case {1}                               %  subj
            setting1 = setting;
            save(datamat_file, '-append', 'setting1');
         case {2}                               %  avg
            setting2 = setting;
            save(datamat_file, '-append', 'setting2');
         case {3}                               %  salience
            setting3 = setting;
            save(datamat_file, '-append', 'setting3');
         case {4}                               %  grp
            setting4 = setting;
            save(datamat_file, '-append', 'setting4');
         case {5}                               %  corr
            setting5 = setting;
            save(datamat_file, '-append', 'setting5');
      end
   catch
      msg = 'Cannot save setting information';
      msgbox(msg,'ERROR','modal');
      return;
   end;

   return;					% toggle_chan_name


%
%
%------------------------------------------------

function toggle_chan_axes

   hm_chan_axes = getappdata(gcf,'hm_chan_axes');
   hm_chan_tick = getappdata(gcf,'hm_chan_tick');
   view_option = getappdata(gcf,'view_option');
   datamat_file = getappdata(gcf,'datamat_file');
   setting = getappdata(gcf,'setting');
   chan_axes_status = get(hm_chan_axes,'userdata');

   if ~chan_axes_status                         % was not checked
      set(hm_chan_axes, 'userdata',1, 'check','on');
      erp_plot_ui('display_chan_axes','on');
   else
      set(hm_chan_axes, 'userdata',0, 'check','off');
      erp_plot_ui('display_chan_axes','off');

      set(hm_chan_tick, 'userdata',0, 'check','off');
      erp_plot_ui('display_chan_tick','off');
   end

   chan_axes_status = get(hm_chan_axes,'userdata');
   chan_tick_status = get(hm_chan_tick,'userdata');
   setting.chan_axes_status = chan_axes_status;
   setting.chan_tick_status = chan_tick_status;

   setappdata(gcf,'setting',setting);
   try
      switch view_option
         case {1}                               %  subj
            setting1 = setting;
            save(datamat_file, '-append', 'setting1');
         case {2}                               %  avg
            setting2 = setting;
            save(datamat_file, '-append', 'setting2');
         case {3}                               %  salience
            setting3 = setting;
            save(datamat_file, '-append', 'setting3');
         case {4}                               %  grp
            setting4 = setting;
            save(datamat_file, '-append', 'setting4');
         case {5}                               %  corr
            setting5 = setting;
            save(datamat_file, '-append', 'setting5');
      end
   catch
      msg = 'Cannot save setting information';
      msgbox(msg,'ERROR','modal');
      return;
   end;

   return;                                      % toggle_chan_axes


%
%
%------------------------------------------------

function toggle_chan_tick

   hm_chan_tick = getappdata(gcf,'hm_chan_tick');
   hm_chan_axes = getappdata(gcf,'hm_chan_axes');
   view_option = getappdata(gcf,'view_option');
   datamat_file = getappdata(gcf,'datamat_file');
   setting = getappdata(gcf,'setting');
   chan_tick_status = get(hm_chan_tick,'userdata');
   chan_axes_status = get(hm_chan_axes,'userdata');

   %  if tick was not checked and axes was checked
   %  put check on tick menu
   if ~chan_tick_status & chan_axes_status
      set(hm_chan_tick, 'userdata',1, 'check','on');
      erp_plot_ui('display_chan_tick','on');
   else						% take check out
      set(hm_chan_tick, 'userdata',0, 'check','off');
      erp_plot_ui('display_chan_tick','off');
   end

   chan_tick_status = get(hm_chan_tick,'userdata');
   chan_axes_status = get(hm_chan_axes,'userdata');
   setting.chan_axes_status = chan_axes_status;
   setting.chan_tick_status = chan_tick_status;

   setappdata(gcf,'setting',setting);
   try
      switch view_option
         case {1}                               %  subj
            setting1 = setting;
            save(datamat_file, '-append', 'setting1');
         case {2}                               %  avg
            setting2 = setting;
            save(datamat_file, '-append', 'setting2');
         case {3}                               %  salience
            setting3 = setting;
            save(datamat_file, '-append', 'setting3');
         case {4}                               %  grp
            setting4 = setting;
            save(datamat_file, '-append', 'setting4');
         case {5}                               %  corr
            setting5 = setting;
            save(datamat_file, '-append', 'setting5');
      end
   catch
      msg = 'Cannot save setting information';
      msgbox(msg,'ERROR','modal');
      return;
   end;

   return;                                      % toggle_chan_tick


%
%
%-----------------------------------------------------------

function select_wave()

   % don't do anything if we're supposed to be zooming
   tmp = zoom(gcf,'getmode');
   if (isequal(tmp,'in') | isequal(tmp,'on')), return; end

   view_option = getappdata(gcf,'view_option');
   wave_hdl = getappdata(gcf,'wave_hdl');
   selected_wave_idx = getappdata(gcf,'selected_wave_idx');
   selected_chan_idx = getappdata(gcf,'selected_chan_idx');

   for i=selected_chan_idx			% deselect other wave
      for j=selected_wave_idx
         set(wave_hdl(i,j),'selected','off');
      end
   end

   set(gco,'selected','on');			% select only this wave

   wave_info = get(gcbo,'user');		% [wave#, channel#]
   j = wave_info(1);
   i = wave_info(2);

   chan_name_hdl = getappdata(gcf,'chan_name_hdl');
   chan_name = get(chan_name_hdl(i), 'string');
   selected_wave_name = getappdata(gcf,'selected_wave_name');
   init_option = getappdata(gcf,'init_option');
   wave_name = selected_wave_name(j,:);

   txtbox_hdl = rri_txtbox(gca, 'Channel Name', chan_name, ...
				'Wave Name', wave_name);
   setappdata(gcf, 'txtbox_hdl', txtbox_hdl);

   return;					% select_wave


%
%
%-----------------------------------------------------------

function fig_bt_dn()

   wave_hdl = getappdata(gcf,'wave_hdl');
   selected_wave_idx = getappdata(gcf,'selected_wave_idx');
   selected_chan_idx = getappdata(gcf,'selected_chan_idx');

   for i=selected_chan_idx
      for j=selected_wave_idx
         set(wave_hdl(i,j),'selected','off');		% remove selection
      end
   end

   try
      txtbox_hdl = getappdata(gcf,'txtbox_hdl');
      delete(txtbox_hdl);				% clear rri_txtbox
   catch
   end

   return;						% fig_bt_dn


%
%
%-----------------------------------------------------------

function select_chan_name()

   % don't do anything during zooming
   %
   tmp = zoom(gcf,'getmode');
   if (isequal(tmp,'in') | isequal(tmp,'on')), return; end

   current_weight = get(gco,'fontweight');

   if strcmp(current_weight, 'normal')
      set(gco,'fontweight','bold');
   else
      set(gco,'fontweight','normal');
   end

   return;					% select_chan_name


%
%
%----------------------------------------------------------

function select_rubber_chan()

   set(gcf,'pointer','crosshair');
   [ll ur] = rri_rubberband;

   chan_name_hdl = getappdata(gcf,'chan_name_hdl');
   selected_chan_idx = getappdata(gcf,'selected_chan_idx');

   for i=selected_chan_idx

      extent = get(chan_name_hdl(i),'extent');
      x=extent(1); y=extent(2); w=extent(3); h=extent(4);

      if x>=ll(1) & y>=ll(2) & x+w<=ur(1) & y+h<=ur(2)
         set(chan_name_hdl(i),'fontweight','bold');
      end

   end

   set(gcf,'pointer','arrow');

   return;


%
%
%----------------------------------------------------------

function select_all_chan()

   chan_name_hdl = getappdata(gcf,'chan_name_hdl');
   selected_chan_idx = getappdata(gcf,'selected_chan_idx');

   for i=selected_chan_idx
      set(chan_name_hdl(i),'fontweight','bold');  % select all chan_name
   end

   return;					% select_all_chan


%
%
%----------------------------------------------------------

function reset_all_chan()

   chan_name_hdl = getappdata(gcf,'chan_name_hdl');
   selected_chan_idx = getappdata(gcf,'selected_chan_idx');

   for i=selected_chan_idx
      set(chan_name_hdl(i),'fontweight','normal');  % clear all chan_name
   end

   return;					% reset_all_chan


%  Called by ERP_PLOT_UI, ERP_SHOWPLOT_UI
%
%------------------------------------------------

function display_chan_name(state)

   chan_name_hdl = getappdata(gcf,'chan_name_hdl');
   selected_chan_idx = getappdata(gcf,'selected_chan_idx');

   if isempty(chan_name_hdl)
     return;
   end

   for i=selected_chan_idx
      set(chan_name_hdl(i), 'visible', state);
   end

   return;                                      % display_chan_name


%  Called by ERP_PLOT_UI, ERP_SHOWPLOT_UI
%
%------------------------------------------------

function display_chan_axes(state)

   axis_hdl = getappdata(gcf,'axis_hdl');
   selected_chan_idx = getappdata(gcf,'selected_chan_idx');

   if isempty(axis_hdl)
     return;
   end

   for i=selected_chan_idx
      set(axis_hdl(:,i), 'visible', state);
   end

   return;                                      % display_chan_axes


%  Called by ERP_PLOT_UI, ERP_SHOWPLOT_UI
%
%------------------------------------------------

function display_chan_tick(state)

   xtick_hdl = getappdata(gcf,'xtick_hdl');
   ytick_hdl = getappdata(gcf,'ytick_hdl');
   selected_chan_idx = getappdata(gcf,'selected_chan_idx');

   if isempty(xtick_hdl) | isempty(ytick_hdl)
     return;
   end

   for i=selected_chan_idx
      set(xtick_hdl(:,i), 'visible', state);
   end

   for i=selected_chan_idx
      set(ytick_hdl(:,i), 'visible', state);
   end

   return;                                      % display_chan_tick


%  Called by ERP_PLOT_UI, ERP_SHOWPLOT_UI
%
%------------------------------------------------

function display_legend(state)

   legend_hdl = getappdata(gcf,'legend_hdl');

   if ~isempty(legend_hdl)		% legend was already created

      set(legend_hdl{1}, 'visible', state);
      num_obj = length(legend_hdl{2});

      for i=1:num_obj
         set(legend_hdl{2}(i),'visible',state);
      end

      return;

   end

   avg_wave_hdl = getappdata(gcf,'avg_wave_hdl');
   wave_hdl = getappdata(gcf,'wave_hdl');
   bs_wave_hdl = getappdata(gcf,'bs_wave_hdl');
   selected_avg_idx = getappdata(gcf,'selected_avg_idx');
   selected_wave_idx = getappdata(gcf,'selected_wave_idx');
   selected_bs_idx = getappdata(gcf,'selected_bs_idx');
   selected_avg_name = getappdata(gcf,'selected_avg_name');
   selected_wave_name = getappdata(gcf,'selected_wave_name');
   selected_bs_name = getappdata(gcf,'selected_bs_name');
   selected_chan_idx = getappdata(gcf,'selected_chan_idx');
   first_chan = selected_chan_idx(1);		% first selected channel

   %  create a new legend, and save the handles
   %
   if ~isempty(avg_wave_hdl) & ~isempty(wave_hdl) % display both
      [l_hdl, o_hdl] = legend([avg_wave_hdl(first_chan,selected_avg_idx), ...
         wave_hdl(first_chan,selected_wave_idx)], ...
         char([{selected_avg_name}; {selected_wave_name}]), 'Location', 'northeast');
      legend_txt(o_hdl);
   elseif isempty(avg_wave_hdl) & ~isempty(wave_hdl) % display subj
      if ~isempty(bs_wave_hdl)			% also display bootstrap

         %  first check is bs_wave_hdl a handle
         %
         for i = 1:size(bs_wave_hdl,1)
            if ishandle(bs_wave_hdl(i,selected_bs_idx))
               first_chan = i;
               i = size(bs_wave_hdl,1);
            end
         end

         [l_hdl, o_hdl] = legend([wave_hdl(first_chan,selected_wave_idx), ...
            bs_wave_hdl(first_chan,selected_bs_idx)], ...
            char([{selected_wave_name}; {selected_bs_name}]), 'Location', 'northeast');
         legend_txt(o_hdl);
      else
         [l_hdl, o_hdl] = legend(wave_hdl(first_chan,selected_wave_idx), ...
            selected_wave_name, 'Location', 'northeast');
         legend_txt(o_hdl);
      end
   elseif ~isempty(avg_wave_hdl) & isempty(wave_hdl) % display avg
      [l_hdl, o_hdl] = legend(avg_wave_hdl(first_chan,selected_avg_idx), ...
         selected_avg_name, 'Location', 'northeast');
      legend_txt(o_hdl);
   end

   set(l_hdl,'color',[0.9 1 0.9]);
   setappdata(gcf,'legend_hdl',[{l_hdl} {o_hdl}]);

   return;                                      % display_legend


%
%
%--------------------------------------------------

function modify_datamat

   h0 = gcf;
   modify_fig_name = [];

   try
      modify_fig_name = get(getappdata(h0,'modify_fig'),'name');
   catch
   end

   if ~isempty(modify_fig_name) & strcmp(modify_fig_name,'Modify Datamat')
      msg = 'ERROR: Modify Datamat window has already been opened.';
      msgbox(msg,'ERROR','modal');
      return;
   end

   % Remove chosen channels from selected_channels list
   %
   chan_name_hdl = getappdata(gcf,'chan_name_hdl');
   selected_channels = getappdata(gcf,'selected_channels');
   selected_chan_idx = getappdata(gcf,'selected_chan_idx');

   for i=selected_chan_idx			% collect selected list

      if strcmp(get(chan_name_hdl(i),'fontweight'), 'bold')
         selected_channels(i) = 0;
      end

   end

   % Remove chosen waves from selected_subjects list
   %
   wave_hdl = getappdata(gcf,'wave_hdl');
   selected_subjects = getappdata(gcf,'selected_subjects');

   for i=1:size(wave_hdl,1)
      for j=1:size(wave_hdl,2)
         if strcmp(get(wave_hdl(i,j),'selected'), 'on')
            wave_info = get(wave_hdl(i,j),'user');
            subj_num = wave_info(4);
            selected_subjects(subj_num) = 0;
         end
      end
   end

   modifier.selected_channels = selected_channels;
   modifier.selected_subjects = selected_subjects;
   datamat_file = getappdata(gcf, 'datamat_file');

   h01 = erp_modify_datamat(modifier, datamat_file, h0);
   if ~isempty(h01)
      setappdata(h0,'modify_fig',h01);
   end

   return;					% modify_datamat


% If Grand Average Window was not open, open now
%
%--------------------------------------------------

function view_avg

   h0 = gcf;
   datamat_file = getappdata(h0,'datamat_file');
   h01 = erp_plot_ui({datamat_file,2});
   if ~isempty(h01)
      setappdata(h0,'avg_fig',h01);
      setappdata(h01,'main_fig',h0);
   end

   return					% view_avg


% If Group Subject Window was not open, open now
%
%--------------------------------------------------

function view_subj

   h0 = gcf;
   datamat_file = getappdata(h0,'datamat_file');
   h01 = erp_plot_ui({datamat_file,4});
   if ~isempty(h01)
      setappdata(h0,'subj_fig',h01);
      setappdata(h01,'main_fig',h0);
   end

   return					% view_subj


% If Behavior Corr Window was not open, open now
%
%--------------------------------------------------

function view_corr

   h0 = gcf;
   datamat_file = getappdata(h0,'datamat_file');
   h01 = erp_plot_ui({datamat_file,5});
   if ~isempty(h01)
      setappdata(h0,'corr_fig',h01);
      setappdata(h01,'main_fig',h0);
   end

   return					% view_corr


%  If Detail Plot was not open, open now
%
%--------------------------------------------------

function view_detail

   h0 = gcf;
   h01 = erp_detailplot_ui;
   if ~isempty(h01)
      setappdata(h0,'detail_fig',h01);
      setappdata(h01,'main_fig',h0);
   end

   return                                       % view_detail


%  If Eigen Plot was not open, open now
%
%--------------------------------------------------

function view_eigen

   h0 = gcf;
   perm_splithalf = '';
   file_name = getappdata(h0,'datamat_file');
   load(file_name);

   if exist('result','var')
      s = result.s;

      if isfield(result,'perm_result')
         perm_result = result.perm_result;
      else
         perm_result = '';
      end

      if isfield(result,'perm_splithalf')
         perm_splithalf = result.perm_splithalf;
      else
         perm_splithalf = '';
      end

   end

   c = getappdata(gcf,'hm_contrast');
   h01 = rri_plot_eigen_ui({s, perm_result, perm_splithalf, strcmpi(get(c,'Visible'),'on')});

   if ~isempty(h01)
      setappdata(h0,'eigen_fig',h01);
      setappdata(h01,'main_fig',h0);
   end

   return                                       % view_eigen


%  If Score Plot was not open, open now
%
%--------------------------------------------------

function view_score

   h0 = gcf;
   file_name = getappdata(h0,'datamat_file');

%   load(file_name, 'isbehav');
%   h01 = erp_plot_scores_ui({file_name, ~isbehav});
   h01 = erp_plot_scores_ui({file_name, 1});

   if ~isempty(h01)
      setappdata(h0,'score_fig',h01);
      setappdata(h01,'main_fig',h0);
   end

   return                                       % view_score


%
%
%------------------------------------------------

function view_canonical

   h0 = gcf;
   file_name = getappdata(h0,'datamat_file');
   h01 = erp_plot_canonical_scores('STARTUP', file_name);
   if ~isempty(h01)
      setappdata(h0,'canonical_fig',h01);
      setappdata(h01,'main_fig',h0);
   end

   return;					% view_canonical


%
%
%------------------------------------------------

function view_canonicalcorr

   h0 = gcf;
   file_name = getappdata(h0,'datamat_file');
   h01 = erp_plot_canonical_corr('STARTUP', file_name);
   if ~isempty(h01)
      setappdata(h0,'canonicalcorr_fig',h01);
      setappdata(h01,'main_fig',h0);
   end

   return;					% view_canonicalcorr


%
%
%------------------------------------------------

function view_contrast

   h0 = gcf;
   file_name = getappdata(h0,'datamat_file');

%   load(file_name, 'cond_name', 'common_conditions', 'design', 'num_cond_lst');
   load(file_name);
   cond_name = cond_name(find(common_conditions));
   num_groups = length(num_cond_lst);
   pls_session = datamat_files{1};

   if exist('method','var') & method == 6
      nonrotatemultiblock = 'nonrotatemultiblock';
      bscan = result.bscan;
   else
      nonrotatemultiblock = [];
      bscan = [];
   end

   if ~exist('behavname','var')
      behavname = '';
   end

   if exist('result','var')
      ContrastMatrix = result.stacked_designdata;
   else
      ContrastMatrix = design;
   end

   h01 = rri_input_contrast_ui({'ERP'},pls_session,cond_selection,num_groups,nonrotatemultiblock,1,behavname,ContrastMatrix,bscan);

%   if num_cond_lst(1) == size(design, 1)
%      num_groups = 1;
%   end

if 0
   if num_groups * length(cond_name) ~= size(design, 1)
      design = repmat(design, [num_groups 1]);
   end

   h01 = rri_input_contrast_ui({'ERP'}, cond_name, [], num_groups, design, 1);
end

   if ~isempty(h01)
      setappdata(h0,'contrast_fig',h01);
      setappdata(h01,'main_fig',h0);
   end

   return;					% view_contrast


%  If Option Menu was not open, open now
%
%-----------------------------------------------------------

function option_menu

   h0 = gcf;
   option_fig_name = [];

   try
      option_fig_name = get(getappdata(h0,'option_fig'),'name');
   catch
   end

   if ~isempty(option_fig_name) & strcmp(option_fig_name,'Display Options')
      msg = 'ERROR: Option window has already been opened.';
      msgbox(msg,'ERROR','modal');
   else
      h01 = erp_plot_option_ui(h0);
      if ~isempty(h01)
         setappdata(h0,'option_fig',h01);
         setappdata(h01,'main_fig',h0);
      end
   end

   return;					% option_menu


%  If BS Option Menu was not open, open now
%
%-----------------------------------------------------------

function bs_option_menu

   h0 = gcf;
   bs_option_fig_name = [];

   try
      bs_option_fig_name = get(getappdata(h0,'bs_option_fig'),'name');
   catch
   end

   if ~isempty(bs_option_fig_name) & ...
	strcmp(bs_option_fig_name,'BootStrap Options')
      msg = 'ERROR: BootStrap Option window has already been opened.';
      msgbox(msg,'ERROR','modal');
   else
      h01 = erp_bs_option_ui(h0);
      if ~isempty(h01)
         setappdata(h0,'bs_option_fig',h01);
         setappdata(h01,'main_fig',h0);
      end
   end

   return;					% bs_option_menu


%  If Condition Averaging window was not open, open now
%
%-----------------------------------------------------------

function cond_mean

   h0 = gcf;

   datamat_file = getappdata(h0,'datamat_file');  % get filename for setting
   setting = getappdata(h0,'setting');
   old_setting = getappdata(h0, 'setting');

   mean_wave_list = getappdata(h0,'mean_wave_list');
   mean_wave_name = getappdata(h0,'mean_wave_name');
   org_wave_name = getappdata(h0,'org_wave_name');
   cond_couple_lst = getappdata(h0,'cond_couple_lst');

   [mean_wave_list, mean_wave_name, cond_couple_lst] = ...
	erp_cond_mean_ui(mean_wave_list, mean_wave_name, org_wave_name, cond_couple_lst);

   setting.mean_wave_list = mean_wave_list;
   setting.mean_wave_name = mean_wave_name;
   setting.cond_couple_lst = cond_couple_lst;

   if isequal(setting, old_setting)		%  nothing was changed
      return;
   end

   try
      setting2 = setting;
      save(datamat_file, '-append', 'setting2');
   catch
      msg = 'Cannot save setting information';
%      set(findobj(h01,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      msgbox(msg,'ERROR','modal');
      return;
   end;

   load(datamat_file, 'datamat_files', 'common_channels', 'common_conditions', 'cond_selection');
   rri_changepath('erpresult');

   if ~exist('cond_selection','var') & exist('common_conditions','var')
      cond_selection = ones(1, sum(common_conditions));
   end

   newdata_lst = erp_get_common(datamat_files, 1, 1, cond_selection);

   org_wave_amplitude = erp_datamat2datacub(newdata_lst, ...
	common_channels, common_conditions, mean_wave_list);

   [dim1 dim2 dim3] = size(org_wave_amplitude);

   wave_amplitude = org_wave_amplitude;

   %  put cond diff list (if there is one) after cond mean list
   %
   if ~isempty(cond_couple_lst)
      for i = 1:size(cond_couple_lst,1)
         wave_amplitude(:,:,dim3+i) = ...
		org_wave_amplitude(:,:,cond_couple_lst(i,1)) - ...
		org_wave_amplitude(:,:,cond_couple_lst(i,2));
      end
   end

   org_selected_wave = getappdata(h0,'org_selected_wave');

   selected_wave = [org_selected_wave ...
	length(org_selected_wave)+[1:length(mean_wave_name)] ...
	length(org_selected_wave)+length(mean_wave_name)+[1:size(cond_couple_lst,1)]];

   ws = getappdata(h0,'wave_selection');
   m = length(org_selected_wave);
   wave_selection = [ws(find(ws<=m)), m+[1:length(mean_wave_name)]];

   wave_name = [org_wave_name, mean_wave_name];

   %  couple name
   %
   couple_name = cell(1,size(cond_couple_lst,1));

   for i = 1:size(cond_couple_lst,1)
      couple_name{i} = ...
	[wave_name{cond_couple_lst(i,1)} ' - ' wave_name{cond_couple_lst(i,2)}];
%	['cond' num2str(cond_couple_lst(i,1)) ' - cond' num2str(cond_couple_lst(i,2))];
   end

   wave_name = [wave_name, couple_name];

   setappdata(h0,'org_wave_amplitude',org_wave_amplitude);
   setappdata(h0,'brain_amplitude',wave_amplitude);
   setappdata(h0,'wave_amplitude',wave_amplitude);
   setappdata(h0,'mean_wave_list',mean_wave_list);
   setappdata(h0,'mean_wave_name',mean_wave_name);
   setappdata(h0,'cond_couple_lst',cond_couple_lst);
   setappdata(h0,'wave_name',wave_name);
   setappdata(h0,'selected_wave',selected_wave);
   setappdata(h0,'wave_selection',wave_selection);

   setappdata(h0,'setting',setting);
   setappdata(h0,'init_option',[]);

   old_pointer = get(h0,'pointer');
   set(h0,'pointer','watch');

   erp_showplot_ui(h0);

   set(h0,'pointer',old_pointer);

   return;					% cond_mean


%  If Choose Condition Difference Couple window was not open, open now
%
%-----------------------------------------------------------

function cond_diff

   h0 = gcf;
   cond_diff_name = [];

   try
      cond_diff_name = get(getappdata(h0,'cond_diff_fig'),'name');
   catch
   end

   if ~isempty(cond_diff_name) & ...
	strcmp(cond_diff_name,'Choose Condition Difference Couple')
      msg = 'ERROR: Choose Condition Difference Couple window has already been opened.';
      msgbox(msg,'ERROR','modal');
   else
      h01 = erp_input_diff_ui(h0);
      if ~isempty(h01)
         setappdata(h0,'cond_diff_fig',h01);
         setappdata(h01,'main_fig',h0);
      end
   end

   return;					% cond_diff


%  If Brain Scores Plot was not open, open now
%
%--------------------------------------------------

function view_brain

   h0 = gcf;
   brain_fig_name = [];

   try
      brain_fig_name = get(getappdata(h0,'brain_fig'),'name');
   catch
   end

   if ~isempty(brain_fig_name) & strcmp(brain_fig_name,'Scalp scores plot for behavior analysis')
      msg = 'ERROR: Scalp Scores Plot window has already been opened.';
      msgbox(msg,'ERROR','modal');
   else
      file_name = getappdata(gcf,'datamat_file');

      h01 = erp_plot_brain_scores('STARTUP', file_name);
      if ~isempty(h01)
         setappdata(h0,'brain_fig',h01);
         setappdata(h01,'main_fig',h0);
      end
   end

   return                                       % view_brain


% close option figure if it opened
%
%-----------------------------------------------------------

function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      erp_plot_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'erp_plot_pos');
   catch
   end

   %  example of how to use 'gcbf'
   %
   h0 = gcbf;
   main_fig = getappdata(h0,'main_fig');
   option_fig = getappdata(h0,'option_fig');
   modify_fig = getappdata(h0,'modify_fig');
   detail_fig = getappdata(h0,'detail_fig');
   vir_fig = getappdata(h0,'vir_fig');
   eigen_fig = getappdata(h0,'eigen_fig');
   score_fig = getappdata(h0,'score_fig');
   canonical_fig = getappdata(h0,'canonical_fig');
   canonicalcorr_fig = getappdata(h0,'canonicalcorr_fig');
   contrast_fig = getappdata(h0,'contrast_fig');
   tbrain_fig = getappdata(h0,'tbrain_fig');
   brain_fig = getappdata(h0,'brain_fig');
   avg_fig = getappdata(h0,'avg_fig');
   subj_fig = getappdata(h0,'subj_fig');   
   corr_fig = getappdata(h0,'corr_fig');
   view_option = getappdata(h0,'view_option');

   try
      delete(option_fig);
   catch
   end

   try
      delete(modify_fig);
   catch
   end

   try
      delete(detail_fig);
   catch
   end

   try
      delete(vir_fig);
   catch
   end

   try
      delete(eigen_fig);
   catch
   end

   try
      delete(score_fig);
   catch
   end

   try
      delete(canonical_fig);
   catch
   end

   try
      delete(canonicalcorr_fig);
   catch
   end

   try
      delete(contrast_fig);
   catch
   end

   try
      delete(tbrain_fig);
   catch
   end

   try
      delete(brain_fig);
   catch
   end

   try
      delete(avg_fig);
   catch
   end

   try
      delete(subj_fig);
   catch
   end

   try
      delete(corr_fig);
   catch
   end

   if view_option == 2 & ishandle(main_fig)
      main_fig = getappdata(gcbf,'main_fig');
      hm_avg = getappdata(main_fig,'hm_avg');
      set(hm_avg, 'userdata',0, 'check','off');
   elseif view_option == 4 & ishandle(main_fig)
      main_fig = getappdata(gcbf,'main_fig');
      hm_subj = getappdata(main_fig,'hm_subj');
      set(hm_subj, 'userdata',0, 'check','off');
   elseif view_option == 5 & ishandle(main_fig)
      main_fig = getappdata(gcbf,'main_fig');
      hm_corr = getappdata(main_fig,'hm_corr');
      set(hm_corr, 'userdata',0, 'check','off');
   else
      plsgui(3);
   end

   return;					% delete_fig


%
%
%------------------------------------------------

function toggle_tbrain

   hm_tbrain = getappdata(gcf,'hm_tbrain');
   tbrain_status = get(hm_tbrain,'userdata');

   if ~tbrain_status				% was not checked
      set(hm_tbrain, 'userdata',1, 'check','on');

      view_tbrain;

   else
      set(hm_tbrain, 'userdata',0, 'check','off');

      try
         tbrain_fig_name = get(getappdata(gcf,'tbrain_fig'),'user');
         if ~isempty(tbrain_fig_name) ...
		& strcmp(tbrain_fig_name,'Scalp scores plot for Task PLS')
            close(getappdata(gcf,'tbrain_fig'));
         end
      catch
      end

   end

   return;					% toggle_tbrain


%  If TBrain Scores Plot was not open, open now
%
%--------------------------------------------------

function view_tbrain

   h0 = gcf;
   tbrain_fig_name = [];

   try
      tbrain_fig_name = get(getappdata(h0,'tbrain_fig'),'name');
   catch
   end

   if ~isempty(tbrain_fig_name) & strcmp(tbrain_fig_name,'Scalp scores plot for Task PLS')
      msg = 'ERROR: Scalp Scores Plot for Task PLS window has already been opened.';
      msgbox(msg,'ERROR','modal');
   else
      file_name = getappdata(gcf,'datamat_file');

      h01 = erp_plot_taskpls_bs('STARTUP', file_name);
      if ~isempty(h01) & ishandle(h01)
         setappdata(h0,'tbrain_fig',h01);
         setappdata(h01,'main_fig',h0);
      end
   end

   return                                       % view_tbrain


%--------------------------------------------------

function export_data

   [filename, pathname] = rri_selectfile('*.mat','Filename for data in this window');

   erp_file = fullfile(pathname, filename);

   if isequal(filename,0)
      return;
   end;

   data.wave_name = getappdata(gcf, 'wave_name');
   data.bs_name = getappdata(gcf, 'bs_name');
   data.wave_amplitude = getappdata(gcf, 'wave_amplitude');
   data.bs_amplitude = getappdata(gcf, 'bs_amplitude');
   data.chan_name = getappdata(gcf, 'chan_nam');
   data.time_info = getappdata(gcf, 'time_info');

   save(erp_file, 'data');

   return;					% export_data


%  equivalent of the Voxel Intensity Response in BfMRI
%
%------------------------------------------------

function toggle_vir

   hm_vir = getappdata(gcf,'hm_vir');
   vir_status = get(hm_vir,'userdata');

   if ~vir_status				% was not checked
      set(hm_vir, 'userdata',1, 'check','on');

      view_vir;

   else
      set(hm_vir, 'userdata',0, 'check','off');

      try
         vir_fig_name = get(getappdata(gcf,'vir_fig'),'user');
         if ~isempty(vir_fig_name) & strcmp(vir_fig_name,'Subject Amplitude for Given Timepoints')
            close(getappdata(gcf,'vir_fig'));
         end
      catch
      end

   end

   return;					% toggle_vir


%  like erp_detailplot_ui.m
%
%--------------------------------------------------

function view_vir

   h0 = gcf;
   h01 = erp_virplot_ui;
   if ~isempty(h01)
      setappdata(h0,'vir_fig',h01);
      setappdata(h01,'main_fig',h0);
   end

   return                                       % view_vir

