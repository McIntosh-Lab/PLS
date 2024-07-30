function taskpls_fig = smallfc_plot_taskpls_bs(varargin)

   if nargin == 0
      h = findobj(gcbf,'Tag','ResultFile');
      result_file = get(h,'UserData');
      is_design_plot = 1;

      [tmp tit_fn] = rri_fileparts(get(gcf,'name'));
      taskpls_fig = init(result_file, is_design_plot, tit_fn);

      if ~isempty(taskpls_fig) & ishandle(taskpls_fig)
         old_pointer = get(gcf,'Pointer');
         set(gcf,'Pointer','watch');

         PlotBrainScores;

         set(gcf,'Pointer',old_pointer);
      end

      return;
   end

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = varargin{1};

   switch (action),
     case {'move_slider'}
         MoveSlider;
     case {'select_lv'}
         old_pointer = get(gcf,'Pointer');
         set(gcf,'Pointer','watch');

	 SelectLV;

         PlotBrainScores;

         set(gcf,'Pointer',old_pointer);
     case {'toggle_axis'}
         toggle_axis;
     case {'toggle_dlv'}
         toggle_dlv;
     case {'ToggleLegend'},
         ToggleLegend;
     case {'ToggleBrainDesignScores'},
         ToggleBrainDesignScores;
     case {'ToggleDesignScores'},
         ToggleDesignScores;
     case {'ToggleDesignLV'},
         ToggleDesignLV;
     case {'zoom'}
         zoom_on_state = get(gcbo,'Userdata');
         if (zoom_on_state == 1)                   % zoom on
            zoom on;
            set(gcbo,'Userdata',0,'Label','&Zoom off');
            set(gcf,'pointer','crosshair');
         else                                      % zoom off
            zoom off;
            set(gcf,'buttondown','smallfc_plot_taskpls_bs(''fig_bt_dn'');');
            set(gcbo,'Userdata',1,'Label','&Zoom on');
            set(gcf,'pointer','arrow');
         end
     case {'fig_bt_dn'}
         fig_bt_dn;
     case {'select_subj'}
  	 select_subj;
     case {'delete_fig'}
  	 delete_fig;
     otherwise
	 msgbox(sprintf('ERROR: Unknown action "%s"',action),'modal');
   end;

   return;					% smallfc_plot_taskpls_bs


%
%
%---------------------------------------------------------------------------

function h0 = init(result_file, is_design_plot, tit_fn)

   tit = ['PLS Brain Scores Plot  [', tit_fn, ']'];
   cond_selection = getappdata(gcf,'cond_selection');

   h0 = [];
   [brainscores, designscores, designlv, ...
	cond_name, subj_name_lst, ...
	num_cond_lst, num_subj_lst, s, perm_result, boot_result, datamat_files, num_grp, result_ver, method] = ...
		load_pls_scores(result_file, is_design_plot);

   if isempty(result_ver) | ( str2num(result_ver) < 5.0807091 )
       msgbox('Please run Task PLS again with this new program');
       return;
   end;

   if method==4 & ( str2num(result_ver) < 5.0908261 )
      msgbox('Please run Multiblock PLS again with this new program');
      return;
   end;

   if isempty(brainscores)
      return;
   end

   num_grp = length(num_cond_lst);
   num_lv = size(brainscores,2);

   grp_str = [];
   for i=1:num_grp
%      grp_str = [grp_str, {['Group ', num2str(i)]}];
      file_name = datamat_files{i};
      [tmp file_name] = fileparts(file_name);
      grp_str = [grp_str, {file_name}];

      subj_select_lst{i} = ones(1, num_subj_lst(i));
   end

   lv_str = [];
   for i=1:num_lv
      lv_str = [lv_str, {['LV ', num2str(i)]}];
   end

   % ----------------------- Figure --------------------------

   save_setting_status = 'on';
   smallfc_plot_taskpls_bs_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(smallfc_plot_taskpls_bs_pos) & strcmp(save_setting_status,'on')

      pos = smallfc_plot_taskpls_bs_pos;

   else

      w = 0.85;
      h = 0.75;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   xp = 0.0227273;
   yp = 0.0294118;
   wp = 1-2*xp;
   hp = 1-2*yp;

   pos_p = [xp yp wp hp];

   h0 = figure('units','normal', ...
        'paperunit','normal', ...
        'paperorient','land', ...
        'paperposition',pos_p, ...
        'papertype','usletter', ...
	'numberTitle','off', ...
	'menubar', 'none', ...
	'toolbar', 'none', ...
	'user','PLS Scores Plot', ...
	'name',tit, ...
	'color', [0.8 0.8 0.8], ...
	'deleteFcn', 'smallfc_plot_taskpls_bs(''delete_fig'');', ...
	'doubleBuffer','on', ...
	'position',pos);

   % ----------------------- Menu --------------------------

   %  file
   %
   rri_file_menu(h0);

   %  view
   %
   h_view = uimenu('parent',h0, ...
	'label','&View', ...
	'visible', 'off', ...
	'tag','ViewMenu');

   hm_axis = uimenu('parent',h_view, ...
	'userdata', 0, ...
	'callback', 'smallfc_plot_taskpls_bs(''toggle_axis'');', ...
		'visible', 'off', ...
	'label','&Plot Current Figure');

   hm_dlv = uimenu('parent',h_view, ...
	'userdata', 0, ...
	'callback', 'smallfc_plot_taskpls_bs(''toggle_dlv'');', ...
		'visible', 'off', ...
	'label','&Plot Design LV Figure');

%	'sepa','on', ...

   if(is_design_plot)
      h1 = uimenu('parent',h_view, ...
	'label','Hide &Brain vs Design Scores', ...
	'userdata',1, ...		% show brain vs design scores
	'callback', 'smallfc_plot_taskpls_bs(''ToggleBrainDesignScores'');', ...
	'tag','BrainDesignMenu');
      h1 = uimenu('parent',h_view, ...
	'label','Show &Design Scores', ...
	'userdata',0, ...		% show design scores
	'callBack', 'smallfc_plot_taskpls_bs(''ToggleDesignScores'');', ...
	'tag','DesignMenu');
      h1 = uimenu('parent',h_view, ...
	'label','Show Design &Latent Variables', ...
	'userdata',0, ...		% show design lv
	'callBack', 'smallfc_plot_taskpls_bs(''ToggleDesignLV'');', ...
	'tag','DesignLVMenu');
   else
      h1 = uimenu('parent',h_view, ...
	'sepa','on', ...
	'label','Hide &Brain vs Behavior Scores', ...
	'userdata',1, ...		% show brain vs behavior scores
	'callback', 'smallfc_plot_taskpls_bs(''ToggleBrainDesignScores'');', ...
	'tag','BrainBehavMenu');
      h1 = uimenu('parent',h_view, ...
	'label','Show Be&havior Scores', ...
	'userdata',0, ...		% show behavior scores
	'callBack', 'smallfc_plot_taskpls_bs(''ToggleDesignScores'');', ...
	'tag','BehavMenu');
      h1 = uimenu('parent',h_view, ...
	'label','Show Behavior &Latent Variables', ...
	'userdata',0, ...		% show behavior lv
	'callBack', 'smallfc_plot_taskpls_bs(''ToggleDesignLV'');', ...
	'tag','BehavLVMenu');
   end

   h1 = uimenu('parent',h_view, ...
	'sepa','on', ...
	'label','&Hide Legend', ...
	'userdata',1, ...		% show legend
	'callBack', 'smallfc_plot_taskpls_bs(''ToggleLegend'');', ...
	'tag','LegendMenu');

   %  zoom
   %
   h2 = uimenu('parent',h0, ...
	'visible', 'off', ...
        'userdata', 1, ...
        'callback','smallfc_plot_taskpls_bs(''zoom'');', ...
        'label','&Zoom on');

   pause(0.01);

   % ---------------------- Left Panel ------------------------

   x = 0.03;
   y = 0.16;
   w = 0.18;
   h = 0.78;
   pos = [x y w h];

   h1 = uicontrol('parent',h0, ...
	'units','normal', ...
	'back', [0.8 0.8 0.8], ...
	'style', 'frame', ...
	'fontunit', 'normal', ...
	'fontsize', 0.5, ...
	'Tag', 'LVFrame', ...
	'position', pos);

   x = 0.06;
   y = 0.9;
   w = 0.12;
   h = 0.05;
   pos = [x y w h];

   h1 = uicontrol('parent',h0, ...
	'units','normal', ...
	'back', [0.8 0.8 0.8], ...
	'style', 'text', ...
	'fontunit', 'normal', ...
	'fontsize', 0.5, ...
	'string', 'Display LVs', ...
	'Tag', 'DisplayLVLabel', ...
	'position', pos);

   x = 0.07;
   y = 0.85;
   w = 0.1;

   pos = [x y w h];

   lv_h = uicontrol('parent',h0, ...
	'unit','normal', ...
	'BackgroundColor', [0.8 0.8 0.8], ...
	'style', 'radio', ...
	'string', 'LV #1', ...
	'fontunit', 'normal', ...
	'fontsize', 0.5, ...
	'callback', 'smallfc_plot_taskpls_bs(''select_lv'');', ...
	'tag','LVRadioButton', ...
	'visible','off', ...
	'position', pos);

   x = x+w+.01;
   w = 0.02;

   pos = [x y w h];

   h1 = uicontrol('parent',h0, ...
	'units','normal', ...
	'style', 'slider', ...
	'min', 0, ...
	'max', 1, ...
	'callback', 'smallfc_plot_taskpls_bs(''move_slider'');', ...
	'tag','LVButtonSlider', ...
	'visible','off', ...
	'position', pos);

   x = 0.07;
   y = 0.08;
   w = 0.1;

   pos = [x y w h];

   h1 = uicontrol('parent',h0, ...
	'units','normal', ...
	'style', 'push', ...
	'fontunit', 'normal', ...
	'fontsize', 0.5, ...
	'string', 'Close', ...
	'callback', 'close(gcf)', ...
	'position', pos);

   % ----------------------- Axes --------------------------

   %  set up the axes for plotting
   %
%	   'FontUnits', 'normal', ...
%	   'FontSize', 0.07, ...
%    axes were not normalized because the Legend can't display properly
%
   %
   x = 0.28;
   y = 0.1;
   w = 0.69;
   h = 0.85;

   pos = [x y w h];

   main_axes = axes('units', 'normal', ...
        'box', 'on', ...
        'tickdir', 'out', ...
        'ticklength', [0.005 0.005], ...
	'fontsize', 10, ...
	'xtickmode', 'auto', ...
	'xticklabelmode', 'auto', ...
	'ytickmode', 'auto', ...
	'yticklabelmode', 'auto', ...
	'visible', 'off', ...
	'position',pos);

   h = 0.37;

   pos = [x y w h];

   bottom_axes = axes('units','normal', ...
        'box', 'on', ...
        'tickdir', 'out', ...
        'ticklength', [0.005 0.005], ...
	'fontsize', 10, ...
	'xtickmode', 'auto', ...
	'xticklabelmode', 'auto', ...
	'ytickmode', 'auto', ...
	'yticklabelmode', 'auto', ...
	'position',pos);

   y = 0.58;

   pos = [x y w h];

   top_axes = axes('units','normal', ...
        'box', 'on', ...
        'tickdir', 'out', ...
        'ticklength', [0.005 0.005], ...
	'fontsize', 10, ...
	'xtickmode', 'auto', ...
	'xticklabelmode', 'auto', ...
	'ytickmode', 'auto', ...
	'yticklabelmode', 'auto', ...
	'position',pos);

   x = 0.01;
   y = 0;
   w = .5;
   h = 0.04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% Message Line
	'Style','text', ...
	'Units','normal', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'ForegroundColor',[0.8 0.0 0.0], ...
	'FontUnits', 'normal', ...
	'FontSize', 0.6, ...
	'HorizontalAlignment','left', ...
	'Position',pos, ...
	'String','', ...
	'Tag','MessageLine');

   lv_template = copyobj_legacy(lv_h,gcf);
   set(lv_template,'Tag','LVTemplate','Visible','off');
   curr_lv_state = zeros(1,num_lv); 
   curr_lv_state(1) = 1;

   setappdata(gcf,'tit_fn',tit_fn);
   setappdata(gcf,'brainscores',brainscores);
   setappdata(gcf,'designscores',designscores);
   setappdata(gcf,'designlv',designlv);
   setappdata(gcf, 'conditions', cond_name);
   setappdata(gcf, 'subj_name_lst', subj_name_lst);
   setappdata(gcf, 'num_cond_lst', num_cond_lst);
   setappdata(gcf, 'num_subj_lst', num_subj_lst);
   setappdata(gcf,'s',s);
   setappdata(gcf,'perm_result',perm_result);
   setappdata(gcf,'boot_result',boot_result);
   setappdata(gcf, 'datamat_files', datamat_files);
   setappdata(gcf, 'is_design_plot', is_design_plot);

   setappdata(gcf, 'num_grp', num_grp);
   setappdata(gcf, 'num_lv', num_lv);
   setappdata(gcf, 'subj_select_lst', subj_select_lst);

   setappdata(gcf, 'hm_axis', hm_axis);
   setappdata(gcf, 'hm_dlv', hm_dlv);
   setappdata(gcf, 'main_axes', main_axes);
   setappdata(gcf, 'bottom_axes', bottom_axes);
   setappdata(gcf, 'top_axes', top_axes);

   setappdata(gcf,'PlotDesignState',1);
   setappdata(gcf,'PlotBrainDesignState',1)
   setappdata(gcf,'PlotDesignLVState',0);

   setappdata(gcf, 'cond_selection', cond_selection);

   % for GUI
   setappdata(gcf,'LVButtonHeight',0.05);
   setappdata(gcf,'LV_hlist',[lv_h]);
   setappdata(gcf,'LVButtonTemplate',lv_template);
   setappdata(gcf,'TopLVButton',1);
   setappdata(gcf,'CurrLVState',curr_lv_state);
   setappdata(gcf,'num_grp',num_grp);
   SetupLVButtonRows;
   DisplayLVButtons;

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

   curr_lv_state = getappdata(gcf,'CurrLVState');
   num_lvs = length(curr_lv_state);
   set(h,'Value',num_lvs, 'Max',num_lvs, 'Min',1); 

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


% --------------------------------------------------------------------

function PlotBrainDesignScores

   if (getappdata(gcf,'PlotBrainDesignState') == 0)
      return;
   end;

   s = getappdata(gcf,'s');
   cb = erp_per(s);
   perm_result = getappdata(gcf,'perm_result');
   subj_select_lst = getappdata(gcf, 'subj_select_lst');
   brainscores = getappdata(gcf, 'brainscores');
   designscores = getappdata(gcf, 'designscores');
   conditions = getappdata(gcf, 'conditions');
   num_cond_lst = getappdata(gcf, 'num_cond_lst');
   num_subj_lst = getappdata(gcf, 'num_subj_lst');

   if (getappdata(gcf,'PlotDesignState') == 1),
      ax_hdl = getappdata(gcf,'bottom_axes');
   else
      ax_hdl = getappdata(gcf,'main_axes');
   end;

   set(ax_hdl, ...
	'buttondown','smallfc_plot_taskpls_bs(''fig_bt_dn'');', ...
	'userdata', 'PlotBrainDesignScores');

   lv_state = getappdata(gcf,'CurrLVState');
   lv_idx = find(lv_state == 1);
   num_conds = num_cond_lst(1);
   num_grp = getappdata(gcf, 'num_grp');

   num_in_grp = [0 num_cond_lst.*num_subj_lst];

   color_code =[ 'bo';'rx';'g+';'m*';'bs';'rd';'g^';'m<';'bp';'r>'; ...
                  'gh';'mv';'ro';'gx';'m+';'b*';'rs';'gd';'m^';'b<'];

   % need more color
   %
   if num_conds > size(color_code,1)

      tmp = [];

      for i=1:ceil(num_conds/size(color_code,1))
         tmp = [tmp; color_code];
      end

      color_code = tmp;

   end

   min_x = min(designscores(:));	max_x = max(designscores(:));
   min_y = min(brainscores(:));		max_y = max(brainscores(:));
   margin_x = abs((max_x - min_x) / 20);
   margin_y = abs((max_y - min_y) / 20);

   axes(ax_hdl);
   cla; grid off; hold on;

 for grp_idx = 1:num_grp

   num_subjs = num_subj_lst(grp_idx);
   first = sum(num_in_grp(1:grp_idx)) + 1;
   last = sum(num_in_grp(1:(grp_idx+1)));
   tmp_d_scores = designscores(first:last,:);
   tmp_b_scores = brainscores(first:last,:);

   for n=1:num_subjs
      for k=1:num_conds
         j = sum(num_in_grp(1:grp_idx)) + (k-1) * num_subjs + n;
         score_hdl(grp_idx,n,k) = plot(designscores(j,lv_idx), ...
		brainscores(j,lv_idx), ...
		color_code(k,:), ...
		'buttondown','smallfc_plot_taskpls_bs(''select_subj'');', ...
		'userdata', [grp_idx, n]);

         if ~subj_select_lst{grp_idx}(n)
            set(score_hdl(grp_idx,n,k), 'visible', 'off');
         end
      end
   end
 end

   setappdata(gcf, 'score_hdl', score_hdl);

   set(ax_hdl, 'xtickmode','auto',  'xticklabelmode','auto');
   axis([min_x-margin_x,max_x+margin_x,min_y-margin_y,max_y+margin_y]);
   hold off;

   l_hdl = [];

   if ~isempty(conditions),

      % remove the old legend to avoid the bug in the MATLAB5
      old_legend = getappdata(gcf,'LegendHdl');
      if ~isempty(old_legend),
        try
          delete(old_legend{1});
        catch
        end;
      end;

      % create a new legend, and save the handles
      [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
      legend_txt(o_hdl);
      set(l_hdl,'color',[0.9 1 0.9]);
      setappdata(gcf,'LegendHdl',[{l_hdl} {o_hdl}]);

      legend_state = get(findobj(gcf,'Tag','LegendMenu'),'Userdata');
      if (legend_state == 1),
	 DisplayLegend('on');
      else
	 DisplayLegend('off');
      end;

   else

      setappdata(gcf,'LegendHdl',[]);

   end;

   if(getappdata(gcf, 'is_design_plot'))
      xlabel('Design Scores');
   else
      xlabel('Behavior Scores');
   end

   ylabel('Brain Scores');
   title('');

   try
      txtbox_hdl = getappdata(gcf,'txtbox_hdl');
      delete(txtbox_hdl);                           % clear rri_txtbox
   catch
   end

   if (getappdata(gcf,'PlotDesignState') == 1) | isempty(perm_result)
      return;
   else
      title(sprintf('LV %d:  %.2f%% crossblock,  p < %.3f', lv_idx, 100*cb(lv_idx), perm_result.sprob(lv_idx)));
   end

   return;					% PlotBrainDesignScores


%---------------------------------------------------------------------------

function PlotDesignScores

   if (getappdata(gcf,'PlotDesignState') == 0),
      return;
   end;

   s = getappdata(gcf,'s');
   cb = erp_per(s);
   perm_result = getappdata(gcf,'perm_result');
   designscores = getappdata(gcf,'designscores');
   conditions = getappdata(gcf,'conditions');
   num_cond_lst = getappdata(gcf, 'num_cond_lst');
   num_subj_lst = getappdata(gcf, 'num_subj_lst');

   if (getappdata(gcf,'PlotBrainDesignState') == 1),
      ax_hdl = getappdata(gcf,'top_axes');
   else
      ax_hdl = getappdata(gcf,'main_axes');
   end;

   axes(ax_hdl);
   cla;hold on;

   lv_state = getappdata(gcf,'CurrLVState');
   lv_idx = find(lv_state == 1);
   num_conds = num_cond_lst(1);

   num_in_grp = [0 num_cond_lst.*num_subj_lst];

   num_grp = getappdata(gcf,'num_grp');
   grp_d_scores = [];

   for grp_idx = 1:num_grp

      num_subjs = num_subj_lst(grp_idx);
      first = sum(num_in_grp(1:grp_idx)) + 1;
      last = sum(num_in_grp(1:(grp_idx+1)));
      tmp_d_scores = designscores(first:last,:);

      mask = [];

      for k = 1:num_conds
         mask = [mask,num_subj_lst(grp_idx)*(k-1)+1];
      end

      grp_d_scores = [grp_d_scores; tmp_d_scores(mask,:)];

   end

   min_x = 0.5;				max_x = size(grp_d_scores, 1)+0.5;
   min_y = min(grp_d_scores(:));	max_y = max(grp_d_scores(:));
   margin_x = abs((max_x - min_x) / 20);
   margin_y = abs((max_y - min_y) / 20);

   load('rri_color_code');

   for g=1:num_grp
      for k=1:num_conds
         bar_hdl = bar((g-1)*num_conds + k,grp_d_scores((g-1)*num_conds + k,lv_idx));
         set(bar_hdl,'facecolor',color_code(k,:));
      end
   end

   set(ax_hdl,'xtick',([1:num_grp] - 1)*num_conds + 0.5);
   set(ax_hdl,'xticklabel',1:num_grp);

   hold off;

   axis([min_x,max_x,min_y-margin_y,max_y+margin_y]);

   set(ax_hdl, 'userdata', 'PlotDesignScores');
   set(ax_hdl,'tickdir','out','ticklength', [0.005 0.005], ...
	'box','on');

   conditions = getappdata(gcf, 'conditions');

   if ~isempty(conditions),

      % remove the old legend to avoid the bug in the MATLAB5
      old_legend = getappdata(gcf,'LegendHdl2');
      if ~isempty(old_legend),
        try
          delete(old_legend{1});
        catch
        end;
      end;

      % create a new legend, and save the handles
      [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
      legend_txt(o_hdl);
      set(l_hdl,'color',[0.9 1 0.9]);
      setappdata(gcf,'LegendHdl2',[{l_hdl} {o_hdl}]);

      legend_state = get(findobj(gcf,'Tag','LegendMenu'),'Userdata');
      if (legend_state == 1),
	 DisplayLegend('on');
      else
	 DisplayLegend('off');
      end;

   else

      setappdata(gcf,'LegendHdl2',[]);

   end;

   xlabel('Groups');

   if(getappdata(gcf, 'is_design_plot'))
      ylabel('Design Scores');
   else
      ylabel('Behavior Scores');
   end

   title('');
   grid on;

   try
      txtbox_hdl = getappdata(gcf,'txtbox_hdl');
      delete(txtbox_hdl);                           % clear rri_txtbox
   catch
   end

   if isempty(perm_result)
      return;
   else
      title(sprintf('LV %d:  %.2f%% crossblock,  p < %.3f', lv_idx, 100*cb(lv_idx), perm_result.sprob(lv_idx)));
   end

   return;                                              % PlotDesignScores


%---------------------------------------------------------------------------

function PlotDesignLV

   if (getappdata(gcf,'PlotDesignLVState') == 0)
      return;
   end;

   s = getappdata(gcf,'s');
   cb = erp_per(s);
   perm_result = getappdata(gcf,'perm_result');
   designlv = getappdata(gcf,'designlv');

   num_cond_lst = getappdata(gcf, 'num_cond_lst');

   lv_state = getappdata(gcf,'CurrLVState');
   lv_idx = find(lv_state == 1);
   num_conds = num_cond_lst(1);

   min_x = 0.5;				max_x = size(designlv,1)+0.5;
   min_y = min(designlv(:));		max_y = max(designlv(:));
   margin_x = abs((max_x - min_x) / 20);
   margin_y = abs((max_y - min_y) / 20);

%   grp_range = sum(num_in_grp(1:grp_idx))+1:sum(num_in_grp(1:(grp_idx+1)));

if(1)
   ax_hdl = getappdata(gcf,'bottom_axes');
   axes(ax_hdl);
   set(ax_hdl,'visible','off');
end

   %  plot of the designlv
   %
   ax_hdl = getappdata(gcf,'top_axes');
   axes(ax_hdl);
   cla;hold on;

   %  the rows are stacked by groups. each group has several conditions.
   %  each condition could have several contrasts.
   %
%   num_rows = size(designlv,1);
%   num_rows = num_conds;

%   tick_step = round(num_rows / 20);

   load('rri_color_code');

   num_grp = getappdata(gcf,'num_grp');

   for g = 1:num_grp
   for k = 1:num_conds
      bar_hdl = bar((g-1)*num_conds + k, designlv((g-1)*num_conds + k,lv_idx));
      set(bar_hdl,'facecolor',color_code(k,:));
   end
   end

   hold off;

   axis([min_x,max_x,min_y-margin_y,max_y+margin_y]);

   set(ax_hdl, 'userdata', 'topPlotDesignLV');
   % set(ax_hdl,'xtick',[1:tick_step:num_rows]);
%   set(ax_hdl,'tickdir','out','ticklength', [0.005 0.005], ...
%	'box','on','xtick',[]);
   set(ax_hdl,'tickdir','out','ticklength', [0.005 0.005], ...
	'box','on');

%   min_value = min(designlv(:,lv_idx));
%   max_value = max(designlv(:,lv_idx));
%   offset = (max_value - min_value) / 20;
%   axis([0 size(designlv,1)+1 min_value-offset max_value+offset]);

   ylabel('Weights');

   if(getappdata(gcf, 'is_design_plot'))
      title('Weights of the contrasts for the Design LV');
   else
      title('Weights of the contrasts for the Behavior LV');
   end

   grid on;

   set(ax_hdl,'xtick',([1:num_grp] - 1)*num_conds + 0.5);
   set(ax_hdl,'xticklabel',1:num_grp);

   conditions = getappdata(gcf, 'conditions');

   if ~isempty(conditions),

      % remove the old legend to avoid the bug in the MATLAB5
      old_legend = getappdata(gcf,'LegendHdl3');
      if ~isempty(old_legend),
        try
          delete(old_legend{1});
        catch
        end;
      end;

      % create a new legend, and save the handles
      [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
      legend_txt(o_hdl);
      set(l_hdl,'color',[0.9 1 0.9]);
      setappdata(gcf,'LegendHdl3',[{l_hdl} {o_hdl}]);

      legend_state = get(findobj(gcf,'Tag','LegendMenu'),'Userdata');
      if (legend_state == 1),
	 DisplayLegend('on');
      else
	 DisplayLegend('off');
      end;

   else

      setappdata(gcf,'LegendHdl3',[]);

   end;

   xlabel('Groups');

if(0)

   %  plot of the designlv permuation result if any
   %
   ax_hdl = getappdata(gcf,'bottom_axes');
   axes(ax_hdl);
   cla; grid off;


%cla;
%xlabel('');
%ylabel('');
%title('');
set(ax_hdl,'visible','off');
return;


   if isempty(perm_result)
      title('--- No permutation test has been performed --- ');
      return;
   end;

   bar(perm_result.dprob(:,lv_idx)*100,'r');
   set(ax_hdl, 'userdata', 'bottomPlotDesignLV');
   % set(ax_hdl,'XTick',[1:tick_step:num_contrasts]);
   set(ax_hdl,'xtick',[]);
   axis([0 size(designlv,1)+1 0 105]);

   xlabel('Contrasts');
   ylabel('Probability (%)');

   if(getappdata(gcf, 'is_design_plot'))
      title(sprintf('Permuted design LV greater than observed, %d permutation tests, %d%% crossblock', perm_result.num_perm, cb(lv_idx)));
   else
      title(sprintf('Permuted behav LV greater than observed, %d permutation tests, %d%% crossblock', perm_result.num_perm, cb(lv_idx)));
   end
end

   try
      txtbox_hdl = getappdata(gcf,'txtbox_hdl');
      delete(txtbox_hdl);                           % clear rri_txtbox
   catch
   end

   return;                                              % PlotDesignLV


%---------------------------------------------------------------------------

function ToggleLegend

   h = findobj(gcf,'Tag','LegendMenu');

   legend_state = get(h,'Userdata');
   switch (legend_state)
     case {0},
	set(h,'Userdata',1,'Label','&Hide Legend');
        DisplayLegend('on');
     case {1},
	set(h,'Userdata',0,'Label','&Show Legend');
        DisplayLegend('off');
   end;

   return;                                              % ToggleLegend


%---------------------------------------------------------------------------

function DisplayLegend(on_off)

   l_hdls = getappdata(gcf,'LegendHdl');
   l_hdls2 = getappdata(gcf,'LegendHdl2');
   l_hdls3 = getappdata(gcf,'LegendHdl3');

   if ~isempty(l_hdls) & ishandle(l_hdls{1}),
      set(l_hdls{1},'Visible',on_off);
      num_obj = length(l_hdls{2});
      for i=1:num_obj,
         set(l_hdls{2}(i),'Visible',on_off);
      end;
   end

   if  ~isempty(l_hdls2) & ishandle(l_hdls2{1})
      set(l_hdls2{1},'Visible',on_off);
      num_obj = length(l_hdls2{2});
      for i=1:num_obj,
         set(l_hdls2{2}(i),'Visible',on_off);
      end;
   end

   if  ~isempty(l_hdls3) & ishandle(l_hdls3{1})
      set(l_hdls3{1},'Visible',on_off);
      num_obj = length(l_hdls3{2});
      for i=1:num_obj,
         set(l_hdls3{2}(i),'Visible',on_off);
      end;
   end

   return;                                              % DisplayLegend


%---------------------------------------------------------------------------

function ToggleBrainDesignScores

   brain_design_state = getappdata(gcf,'PlotBrainDesignState');
   is_design_plot = getappdata(gcf, 'is_design_plot');
   switch (brain_design_state)
     case {0},
        if is_design_plot
           m_hdl = findobj(gcf,'Tag','BrainDesignMenu');
   	   set(m_hdl,'Label','Hide &Brain vs Design Scores');
	else
           m_hdl = findobj(gcf,'Tag','BrainBehavMenu');
   	   set(m_hdl,'Label','Hide &Brain vs Behavior Scores');
	end

        setappdata(gcf,'PlotBrainDesignState',1);
	DisplayBrainDesignScores('on');
%   	set(findobj(gcf,'Tag','LegendMenu'),'Enable','on');
        setappdata(gcf,'PlotDesignLVState',0);

        if is_design_plot
           m_hdl = findobj(gcf,'Tag','DesignLVMenu');
           set(m_hdl,'Label','Show Design &Latent Variables');
        else
           m_hdl = findobj(gcf,'Tag','BehavLVMenu');
           set(m_hdl,'Label','Show Behavior &Latent Variables');
	end

     case {1},
        if is_design_plot
           m_hdl = findobj(gcf,'Tag','BrainDesignMenu');
    	   set(m_hdl,'Label','Show &Brain vs Design Scores');
        else
           m_hdl = findobj(gcf,'Tag','BrainDesignMenu');
    	   set(m_hdl,'Label','Show &Brain vs Behavior Scores');
	end

        setappdata(gcf,'PlotBrainDesignState',0);
	DisplayBrainDesignScores('off');
%   	set(findobj(gcf,'Tag','LegendMenu'),'Enable','off');

   end;

   return;					% ToggleBrainDesignScores


%---------------------------------------------------------------------------

function DisplayBrainDesignScores(on_off)

   design_state = getappdata(gcf,'PlotDesignState');

   switch (on_off)
     case {'on'},
        if (design_state == 1),		% need to display design scores
           h = getappdata(gcf,'main_axes');
           axes(h); cla; set(h,'Visible','off');

           set(getappdata(gcf,'top_axes'),'Visible','on');
           PlotDesignScores;

           set(getappdata(gcf,'bottom_axes'),'Visible','on');
           PlotBrainDesignScores;
        else
           h = getappdata(gcf,'top_axes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'bottom_axes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'main_axes'); 
           axes(h); cla; set(h,'Visible','on');
           PlotBrainDesignScores;
	end;

     case {'off'},
         old_legend = getappdata(gcf,'LegendHdl');
         if ~isempty(old_legend),
            try
               delete(old_legend{1});
            catch
            end;
         end;
%        DisplayLegend('off');
        if (design_state == 1) 
           h = getappdata(gcf,'top_axes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'bottom_axes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'main_axes');
           axes(h); cla; set(h,'Visible','on');
           PlotDesignScores;
        else
           h = getappdata(gcf,'main_axes'); 
           axes(h); cla; set(h,'Visible','off');
	end;

   end;  % switch

   return;					% DisplayBrainDesignScores


%---------------------------------------------------------------------------

function ToggleDesignScores

   design_state = getappdata(gcf,'PlotDesignState');
   is_design_plot = getappdata(gcf, 'is_design_plot');
   switch (design_state)
     case {0},
        if is_design_plot
           m_hdl = findobj(gcf,'Tag','DesignMenu');
           set(m_hdl,'Label','Hide &Design Scores');
           setappdata(gcf,'PlotDesignState',1);
	   DisplayDesignScores('on');

           setappdata(gcf,'PlotDesignLVState',0);
           m_hdl = findobj(gcf,'Tag','DesignLVMenu');
           set(m_hdl,'Label','Show Design &Latent Variables');
	else
           m_hdl = findobj(gcf,'Tag','BehavMenu');
           set(m_hdl,'Label','Hide &Behavior Scores');
           setappdata(gcf,'PlotDesignState',1);
	   DisplayDesignScores('on');

           setappdata(gcf,'PlotDesignLVState',0);
           m_hdl = findobj(gcf,'Tag','BehavLVMenu');
           set(m_hdl,'Label','Show Behavior &Latent Variables');
	end
     case {1},
        new_state = 0;
        if is_design_plot
           m_hdl = findobj(gcf,'Tag','DesignMenu');
           set(m_hdl,'Label','Show &Design Scores');
	else
           m_hdl = findobj(gcf,'Tag','BehavMenu');
           set(m_hdl,'Label','Show &Behavior Scores');
	end
        setappdata(gcf,'PlotDesignState',0);
	DisplayDesignScores('off');
   end;

   return;                                              % ToggleDesignScores


%---------------------------------------------------------------------------

function DisplayDesignScores(on_off)

   brain_design_state = getappdata(gcf,'PlotBrainDesignState');

   switch (on_off)
     case {'on'},
        if (brain_design_state == 1),	% need to display brain/design scores
           h = getappdata(gcf,'main_axes'); 
           axes(h); cla; set(h,'Visible','off');

           set(getappdata(gcf,'top_axes'),'Visible','on');
           PlotDesignScores;

           set(getappdata(gcf,'bottom_axes'),'Visible','on');
           PlotBrainDesignScores;
        else
           h = getappdata(gcf,'top_axes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'bottom_axes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'main_axes'); 
           axes(h); cla; set(h,'Visible','on');
           PlotDesignScores;
	end;
     case {'off'},
         old_legend = getappdata(gcf,'LegendHdl2');
         if ~isempty(old_legend),
            try
               delete(old_legend{1});
            catch
            end;
         end;
        if (brain_design_state == 1),	% need to display brain/design scores
           h = getappdata(gcf,'top_axes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'bottom_axes');
           axes(h); cla; set(h,'Visible','off');

           set(getappdata(gcf,'main_axes'),'Visible','on');
           PlotBrainDesignScores;
        else
           h = getappdata(gcf,'main_axes'); 
           axes(h); cla; set(h,'Visible','off');
	end;
   end;  % switch

   return;                                              % DisplayDesignScores


%---------------------------------------------------------------------------

function ToggleDesignLV

   designlv_state = getappdata(gcf,'PlotDesignLVState');
   is_design_plot = getappdata(gcf, 'is_design_plot');
   switch (designlv_state)
     case {0},
        if is_design_plot
           setappdata(gcf,'PlotBrainDesignState',0);
           m_hdl = findobj(gcf,'Tag','BrainDesignMenu');
           set(m_hdl,'Label','Show &Brain vs Design Scores');
           DisplayBrainDesignScores('off');

           setappdata(gcf,'PlotDesignState',0);
           m_hdl = findobj(gcf,'Tag','DesignMenu');
           set(m_hdl,'Label','Show &Design Scores');
           DisplayDesignScores('off');

           m_hdl = findobj(gcf,'Tag','DesignLVMenu');
           set(m_hdl,'Label','Hide Design &Latent Variables');
           setappdata(gcf,'PlotDesignLVState',1);
	   DisplayDesignLV('on');
 	else
           setappdata(gcf,'PlotBrainDesignState',0);
           m_hdl = findobj(gcf,'Tag','BrainBehavMenu');
           set(m_hdl,'Label','Show &Brain vs Behavior Scores');
           DisplayBrainDesignScores('off');

           setappdata(gcf,'PlotDesignState',0);
           m_hdl = findobj(gcf,'Tag','BehavMenu');
           set(m_hdl,'Label','Show &Behavior Scores');
           DisplayDesignScores('off');

           m_hdl = findobj(gcf,'Tag','BehavLVMenu');
           set(m_hdl,'Label','Hide Behavior &Latent Variables');
           setappdata(gcf,'PlotDesignLVState',1);
	   DisplayDesignLV('on');
	end

%	set(findobj(gcf,'Tag','LegendMenu'),'Enable','off');

     case {1},
        new_state = 0;
        if is_design_plot
           m_hdl = findobj(gcf,'Tag','DesignLVMenu');
           set(m_hdl,'Label','Show Design &Latent Variables');
           setappdata(gcf,'PlotDesignLVState',0);
	   DisplayDesignLV('off');

           setappdata(gcf,'PlotDesignState',1);
           m_hdl = findobj(gcf,'Tag','DesignMenu');
           set(m_hdl,'Label','Hide &Design Scores');
           DisplayDesignScores('on');

           setappdata(gcf,'PlotBrainDesignState',1);
           m_hdl = findobj(gcf,'Tag','BrainDesignMenu');
           set(m_hdl,'Label','Hide &Brain vs Design Scores');
           DisplayBrainDesignScores('on');
	else
           m_hdl = findobj(gcf,'Tag','BehavLVMenu');
           set(m_hdl,'Label','Show Behavior &Latent Variables');
           setappdata(gcf,'PlotDesignLVState',0);
	   DisplayDesignLV('off');

           setappdata(gcf,'PlotDesignState',1);
           m_hdl = findobj(gcf,'Tag','BehavMenu');
           set(m_hdl,'Label','Hide &Behavior Scores');
           DisplayDesignScores('on');

           setappdata(gcf,'PlotBrainDesignState',1);
           m_hdl = findobj(gcf,'Tag','BrainBehavMenu');
           set(m_hdl,'Label','Hide &Brain vs Behavior Scores');
           DisplayBrainDesignScores('on');
	end

   end;

   return;                                              % ToggleDesignLV


%---------------------------------------------------------------------------

function DisplayDesignLV(on_off)

   design_state = getappdata(gcf,'PlotDesignState');
   brain_design_state = getappdata(gcf,'PlotBrainDesignState');

   switch (on_off)
     case {'on'},
	   if (design_state == 1)
		ToggleDesignScores;
           end;

	   if (brain_design_state == 1)
		ToggleBrainDesignScores;
           end;

           h = getappdata(gcf,'main_axes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'top_axes');
           axes(h); cla; set(h,'Visible','on');

           h = getappdata(gcf,'bottom_axes');
           axes(h); cla; set(h,'Visible','on');

           PlotDesignLV;

     case {'off'},
         old_legend = getappdata(gcf,'LegendHdl3');
         if ~isempty(old_legend),
            try
               delete(old_legend{1});
            catch
            end;
         end;
           h = getappdata(gcf,'main_axes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'top_axes');
           axes(h); cla; set(h,'Visible','off');
%           PlotDesignScores;

           h = getappdata(gcf,'bottom_axes');
           axes(h); cla; set(h,'Visible','off');
	   PlotBrainDesignScores;

   end;  % switch

   return;                                         % DesignLV


%---------------------------------------------------------------------------

function [brainscores, designscores, designlv, ...
	cond_name, subj_name_lst, ...
	num_cond_lst, num_subj_lst, s, perm_result, boot_result, datamat_files, num_grp, result_ver, method] = ...
		load_pls_scores(result_file, is_design_plot)

   result_ver = [];

   brainscores = [];
   designscores = [];
   designlv = [];

   cond_name = [];
   subj_name_lst = [];
   num_cond_lst = [];
   num_subj_lst = [];
   s = [];
   perm_result = [];
   boot_result = [];
   datamat_files = [];
   num_grp = 1;

   if ~exist('result_file','var') | isempty(result_file),
     pattern = '*PETresult.mat';
     [result_file, path] = rri_selectfile(pattern,'Load PLS scores');

     if isequal(result_file, 0),
        return;
     end;

     result_file = [path, result_file];
   end;

   try
      warning off;

      if(is_design_plot)
%         load(result_file,'brainscores','designscores','designlv', ...
%			'b_scores','subj_name_lst', 'create_ver', ...
%			'num_cond_lst','num_subj_lst', 's', ...
%			'perm_result','boot_result','datamat_files','method' );

	 load(result_file);
	 brainscores = result.usc;
	 designscores = result.vsc;
	 designlv = result.v;
	 s = result.s;
	 perm_result = result.perm_result;
	 boot_result = result.boot_result;

      else
         load(result_file,'brainscores','behavscores','behavlv', ...
			'b_scores','subj_name_lst', 'create_ver', ...
			'num_cond_lst','num_subj_lst', 's', ...
			'perm_result','boot_result','datamat_files','method' );
         designscores = behavscores;
         designlv = behavlv;
      end

      warning on;
   catch
      msg = sprintf('Cannot load the PLS result from file: %s', result_file);
      msgbox(['ERROR: ' msg],'modal');
      return;
   end;

   if exist('create_ver','var')
      result_ver = create_ver;
   end

   rri_changepath('smallfcresult');

   load(datamat_files{1}, 'session_info');    % load the condition from datamat file

   cond_selection = [];
   warning off;
   try
      load(result_file, 'cond_selection', 'bscan');
   catch
   end
   warning on;

   if isempty(cond_selection)
      cond_selection = ones(1,session_info.num_conditions);
   end

%   if exist('bscan','var') & ~isempty(bscan)
 %     tmp = find(cond_selection);
  %    cond_selection = zeros(size(cond_selection));
   %   cond_selection(tmp(bscan)) = 1;
   %end

   num_cond_lst = ones(1,length(num_subj_lst))*sum(cond_selection);
   cond_name = session_info.condition(find(cond_selection));

   if exist('b_scores','var')
      brainscores = b_scores;
   end

   if isempty(num_subj_lst)
      num_grp = 1;
   else
      num_grp = length(num_subj_lst);
   end

   return;					% load_pls_scores


%---------------------------------------------------------------------------

function delete_fig(),

   link_info = getappdata(gcbf,'LinkFigureInfo');

   try
      rmappdata(link_info.hdl,link_info.name);
   end;

   try
     load('pls_profile');
     pls_profile = which('pls_profile.mat');

     smallfc_plot_taskpls_bs_pos = get(gcbf,'position');

     save(pls_profile, '-append', 'smallfc_plot_taskpls_bs_pos');
   catch
   end

   h0 = gcbf;
   axis_fig = getappdata(h0,'axis_fig');
   dlv_fig = getappdata(h0,'dlv_fig');

   try
      if ishandle(axis_fig)
         delete(axis_fig);
      end
      if ishandle(dlv_fig)
         delete(dlv_fig);
      end
   catch
   end

   return;					% delete_fig


%------------------------------------------------

function toggle_axis

   hm_axis = getappdata(gcf,'hm_axis');
   axis_status = get(hm_axis,'userdata');

   if ~axis_status				% was not checked
      set(hm_axis, 'userdata',1, 'check','on');

      view_axis;

   else
      set(hm_axis, 'userdata',0, 'check','off');

      try
         axis_fig_name = get(getappdata(gcf,'axis_fig'),'name');
         if ~isempty(axis_fig_name) & strcmp(axis_fig_name,'Current Axis')
            close(getappdata(gcf,'axis_fig'));
         end
      catch
      end

   end

   return;				% toggle_axis


%--------------------------------------------------

function view_axis

   h0 = gcf;
   axis_old = gca;

   if ~ischar(get(axis_old,'userdata')) | (...
	~strcmp(get(axis_old,'userdata'),'PlotBrainDesignScores') ...
	& ~strcmp(get(axis_old,'userdata'),'PlotDesignScores') ...
	& ~strcmp(get(axis_old,'userdata'),'topPlotDesignLV') ...
	& ~strcmp(get(axis_old,'userdata'),'bottomPlotDesignLV'))
      msgbox('Please click a plot in PLS Scores Plot.', 'modal');
      hm_axis = getappdata(h0,'hm_axis');
      set(hm_axis, 'userdata',0, 'check','off');
      return;
   end

   axis_fig_name = [];

   try
      axis_fig_name = get(getappdata(h0,'axis_fig'),'name');
   catch
   end

   if ~isempty(axis_fig_name) & strcmp(axis_fig_name,'Current Axis')
      msg = 'ERROR: Current Axis window has already been opened.';
      msgbox(msg,'ERROR','modal');
   else

      % It seems that Matlab has a lot of bugs in Legend function,
      % Slow, not working after copyobj, etc. ... 
      %
      if strcmp(get(axis_old,'userdata'),'PlotBrainDesignScores')
         old_legend = getappdata(gcf,'LegendHdl');
         if ~isempty(old_legend),
            try
               delete(old_legend{1});
            catch
            end;
         end;
      end;

      if strcmp(get(axis_old,'userdata'),'PlotDesignScores')
         old_legend = getappdata(gcf,'LegendHdl2');
         if ~isempty(old_legend),
            try
               delete(old_legend{1});
            catch
            end;
         end;
      end;

      if strcmp(get(axis_old,'userdata'),'PlotDesignLV')
         old_legend = getappdata(gcf,'LegendHdl3');
         if ~isempty(old_legend),
            try
               delete(old_legend{1});
            catch
            end;
         end;
      end;

      h01 = erp_new_axis_ui;
      set(h01,'name','Current Axis');
      axis_new = gca;

      conditions = getappdata(h0, 'conditions');

      %  redraw legend
      %
      if strcmp(get(axis_old,'userdata'),'PlotBrainDesignScores') ...
		& ~isempty(conditions)

         legend_state = get(findobj(h0,'Tag','LegendMenu'),'Userdata');

         axes(axis_old);
         [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
         legend_txt(o_hdl);
         set(l_hdl,'color',[0.9 1 0.9]);
         setappdata(h0, 'LegendHdl',[{l_hdl} {o_hdl}]);
         if (legend_state == 1),
            DisplayLegend('on');
         else
            DisplayLegend('off');
         end;

         figure(h01)
         axes(axis_new);
         [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
         legend_txt(o_hdl);
         set(l_hdl,'color',[0.9 1 0.9]);
         setappdata(h01, 'LegendHdl',[{l_hdl} {o_hdl}]);
         if (legend_state == 1),
	    DisplayLegend('on');
         else
            DisplayLegend('off');
         end;

      end

      if strcmp(get(axis_old,'userdata'),'PlotDesignScores') ...
		& ~isempty(conditions)

         legend_state = get(findobj(h0,'Tag','LegendMenu'),'Userdata');

         axes(axis_old);
         [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
         legend_txt(o_hdl);
         set(l_hdl,'color',[0.9 1 0.9]);
         setappdata(h0, 'LegendHdl2',[{l_hdl} {o_hdl}]);
         if (legend_state == 1),
            DisplayLegend('on');
         else
            DisplayLegend('off');
         end;

         figure(h01)
         axes(axis_new);
         [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
         legend_txt(o_hdl);
         set(l_hdl,'color',[0.9 1 0.9]);
         setappdata(h01, 'LegendHdl2',[{l_hdl} {o_hdl}]);
         if (legend_state == 1),
	    DisplayLegend('on');
         else
            DisplayLegend('off');
         end;

      end

      if strcmp(get(axis_old,'userdata'),'topPlotDesignLV') ...
		& ~isempty(conditions)

         legend_state = get(findobj(h0,'Tag','LegendMenu'),'Userdata');

         axes(axis_old);
         [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
         legend_txt(o_hdl);
         set(l_hdl,'color',[0.9 1 0.9]);
         setappdata(h0, 'LegendHdl3',[{l_hdl} {o_hdl}]);
         if (legend_state == 1),
            DisplayLegend('on');
         else
            DisplayLegend('off');
         end;

         figure(h01)
         axes(axis_new);
         [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
         legend_txt(o_hdl); 
         set(l_hdl,'color',[0.9 1 0.9]);
         setappdata(h01, 'LegendHdl3',[{l_hdl} {o_hdl}]);
         if (legend_state == 1),
	    DisplayLegend('on');
         else
            DisplayLegend('off');
         end;

      end

      if ~isempty(h01)
         setappdata(h0,'axis_fig',h01);
         setappdata(h01,'main_fig',h0);
      end
   end

   return;				% view_axis


%-----------------------------------------------------------

function fig_bt_dn()

   score_hdl = getappdata(gcf,'score_hdl');

   for i=1:length(score_hdl(:))
      set(score_hdl(i), 'selected', 'off');		% remove selection
   end

   try
      txtbox_hdl = getappdata(gcf,'txtbox_hdl');
      delete(txtbox_hdl);				% clear rri_txtbox
   catch
   end

   return;						% fig_bt_dn


%-----------------------------------------------------------

function select_subj()

   % don't do anything if we're supposed to be zooming
   tmp = zoom(gcf,'getmode');
   if (isequal(tmp,'in') | isequal(tmp,'on')), return; end

   userdata = get(gco, 'userdata');
   grp_idx = userdata(1);
   subj_idx = userdata(2);		% subj idx

   score_hdl = getappdata(gcf,'score_hdl');
   subj_name_lst = getappdata(gcf, 'subj_name_lst');
   num_cond_lst = getappdata(gcf, 'num_cond_lst');
   num_subj_lst = getappdata(gcf, 'num_subj_lst');

   num_conds = num_cond_lst(grp_idx);
   num_subjs = num_subj_lst(grp_idx);
   subj_name = subj_name_lst{grp_idx};

   % deselect other subj
   %
   for m=1:length(num_subj_lst)		%grp
   for n = 1:num_subj_lst(m)		%n=1:num_subjs
      for k=1:num_conds
         set(score_hdl(m,n,k),'selected','off');
      end
   end
   end

   for k=1:num_conds
      set(score_hdl(grp_idx,subj_idx,k),'selected','on');	% select only this subj
   end

   txtbox_hdl = rri_txtbox(gca, 'Subject Name', subj_name{subj_idx});
   setappdata(gcf, 'txtbox_hdl', txtbox_hdl);

   return;					% select_subj


%------------------------------------------------

function toggle_dlv

   hm_dlv = getappdata(gcf,'hm_dlv');
   dlv_status = get(hm_dlv,'userdata');

   if ~dlv_status				% was not checked
      set(hm_dlv, 'userdata',1, 'check','on');

      view_dlv;

   else
      set(hm_dlv, 'userdata',0, 'check','off');

      try
         dlv_fig_user = get(getappdata(gcf,'dlv_fig'),'user');
         if ~isempty(dlv_fig_user) & strcmp(dlv_fig_user,'LV Plot')
            close(getappdata(gcf,'dlv_fig'));
         end
      catch
      end

   end

   return;				% toggle_dlv


%--------------------------------------------------

function view_dlv

   h0 = gcf;

   dlv_fig_user = [];

   try
      dlv_fig_user = get(getappdata(h0,'dlv_fig'),'user');
   catch
   end

   lv_state = getappdata(gcbf,'CurrLVState');
   lv_idx = find(lv_state == 1);

   if ~isempty(dlv_fig_user) & strcmp(dlv_fig_user,'LV Plot')		% update lv_idx

      h01 = getappdata(h0,'dlv_fig');
      figure(h01);

%      msg = 'ERROR: Design LV Plot window has already been opened.';
%      msgbox(msg,'ERROR','modal');
   else

      h01 = erp_plot_dlv_ui;

   end

      tit_fn = getappdata(gcbf,'tit_fn');
      tit = ['Design LV Plot  [', tit_fn, ']'];
      set(h01,'name',tit);

      s = getappdata(gcbf,'s');
      cb = erp_per(s);
      perm_result = getappdata(gcbf,'perm_result');
      designlv = getappdata(gcbf,'designlv');

      num_cond_lst = getappdata(gcbf, 'num_cond_lst');
      num_subj_lst = getappdata(gcbf, 'num_subj_lst');
      num_grp = length(num_subj_lst);

      num_conds = num_cond_lst(1);

      min_x = 0.5;				max_x = size(designlv,1)+0.5;
      min_y = min(designlv(:));			max_y = max(designlv(:));
      margin_x = abs((max_x - min_x) / 20);
      margin_y = abs((max_y - min_y) / 20);

      %  plot of the designlv
      %
      cla;hold on;

      %  the rows are stacked by groups. each group has several conditions.
      %  each condition could have several contrasts.
      %

      load('rri_color_code');

      for g=1:num_grp
         for k=1:num_conds
            bar_hdl = bar((g-1)*num_conds+k, designlv((g-1)*num_conds+k,lv_idx));
            set(bar_hdl,'facecolor',color_code(k,:));
         end
      end

      hold off;

      axis([min_x,max_x,min_y-margin_y,max_y+margin_y]);

      set(gca,'tickdir','out','ticklength', [0.005 0.005], ...
		'box','on');
      ylabel('Design LV');

       if isempty(perm_result)
          title(sprintf('LV %d:  %.2f%% crossblock', lv_idx, 100*cb(lv_idx)));
       else
          title(sprintf('LV %d:  %.2f%% crossblock,  p < %.3f', lv_idx, 100*cb(lv_idx), perm_result.sprob(lv_idx)));
       end

%      if(getappdata(gcbf, 'is_design_plot'))
%         title('Weights of the contrasts for the Design LV');
%      else
%         title('Weights of the contrasts for the Behavior LV');
%      end

      grid on;

      set(gca,'xtick',[1:num_grp]*num_conds - num_conds + 0.5);
      set(gca,'xticklabel',1:num_grp);

      conditions = getappdata(gcbf, 'conditions');

      if ~isempty(conditions),

         % remove the old legend to avoid the bug in the MATLAB5
         old_legend = getappdata(gcbf,'LegendHdl3');
         if ~isempty(old_legend),
           try
             delete(old_legend{1});
           catch
           end;
         end;

         % create a new legend, and save the handles
         [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
         legend_txt(o_hdl);
         set(l_hdl,'color',[0.9 1 0.9]);
         setappdata(gcbf,'LegendHdl3',[{l_hdl} {o_hdl}]);

         legend_state = get(findobj(gcbf,'Tag','LegendMenu'),'Userdata');
         if (legend_state == 1),
	    DisplayLegend('on');
         else
  	    DisplayLegend('off');
         end;

      else

         setappdata(gcbf,'LegendHdl3',[]);

      end;

      xlabel('Groups');

      if ~isempty(h01)
         setappdata(h0,'dlv_fig',h01);
         setappdata(h01,'main_fig',h0);
      end
%   end

   return;				% view_dlv


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


%---------------------------------------------------------------------------

function PlotBrainScores

   num_cond_lst = getappdata(gcf, 'num_cond_lst');
   num_subj_lst = getappdata(gcf, 'num_subj_lst');
   num_conds = num_cond_lst(1);

%   brainscores = getappdata(gcf,'BrainScores');
   boot_result = getappdata(gcf,'boot_result');
   brainscores = boot_result.orig_usc;

   lv_state = getappdata(gcf,'CurrLVState');
   lv_idx = find(lv_state == 1);


   min_x = 0.5;				max_x = size(brainscores,1)+0.5;
   min_y = min(brainscores(:));		max_y = max(brainscores(:));
   margin_x = abs((max_x - min_x) / 20);
   margin_y = abs((max_y - min_y) / 20);

   ax_hdl = getappdata(gcf,'bottom_axes');
   axes(ax_hdl);
   set(ax_hdl,'visible','off');

   ax_hdl = getappdata(gcf,'top_axes');
   axes(ax_hdl);
   set(ax_hdl,'visible','off');

   ax_hdl = getappdata(gcf,'main_axes');
   axes(ax_hdl);
   set(ax_hdl,'visible','on');
   cla;hold on;

   load('rri_color_code');
   num_grp = getappdata(gcf,'num_grp');

   xmark = 0.5;
   accum = 0;
   range = [];

   for g = 1:num_grp
      num_subjs = num_subj_lst(g);

      for k = 1:num_conds
%         bar_hdl = bar(accum+(k-1)*num_subjs+[1:num_subjs], ...
%	   brainscores(accum+(k-1)*num_subjs+[1:num_subjs], lv_idx));

         bar_hdl = bar(accum+k, brainscores(accum+k, lv_idx));

         set(bar_hdl,'facecolor',color_code(k,:));
         range = [range accum+k];
      end

%      accum = accum + num_conds * num_subjs;

      accum = accum + num_conds;

      if g < num_grp
         xmark = [xmark accum + 0.5];
      end
   end

   conditions = getappdata(gcf, 'conditions');

   if ~isempty(conditions),

      % remove the old legend to avoid the bug in the MATLAB5
      old_legend = getappdata(gcf,'LegendHdl3');
      if ~isempty(old_legend),
        try
          delete(old_legend{1});
        catch
        end;
      end;

      % create a new legend, and save the handles
      [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast');
      legend_txt(o_hdl);
      set(l_hdl,'color',[0.9 1 0.9]);
      setappdata(gcf,'LegendHdl3',[{l_hdl} {o_hdl}]);

      legend_state = get(findobj(gcf,'Tag','LegendMenu'),'Userdata');
      if (legend_state == 1),
	 DisplayLegend('on');
      else
	 DisplayLegend('off');
      end;

   else

      setappdata(gcf,'LegendHdl3',[]);

   end;

   boot_result = getappdata(gcf,'boot_result');

      orig_usc = boot_result.orig_usc;
      ulusc = boot_result.ulusc;
      llusc = boot_result.llusc;

      min_y = min(llusc(:));		max_y = max(ulusc(:));

   if isempty(ulusc)
      llusc = llusc - orig_usc;
      ulusc = [];
   else
      llusc = llusc - orig_usc;
      ulusc = ulusc - orig_usc;
   end

   if ~isempty(ulusc)
      h2 = errorbar(range, orig_usc(range,lv_idx), abs(llusc(range,lv_idx)), ulusc(range,lv_idx), 'ok');
   end

   hold off;

   axis([min_x,max_x,min_y-margin_y,max_y+margin_y]);

   set(ax_hdl,'userdata','BrainScores','tickdir','out', ...
	'ticklength', [0.005 0.005],'box','on');
   ylabel('Brain Scores');

   grid on;

   set(ax_hdl,'xticklabel',1:num_grp, 'xtick', xmark);

   xlabel('Groups');

   try
      txtbox_hdl = getappdata(gcf,'txtbox_hdl');
      delete(txtbox_hdl);                           % clear rri_txtbox
   catch
   end

   return;                                              % PlotBrainScores

