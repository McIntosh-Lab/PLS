%
%   Usage: fig = bfm_plot_scores_ui(LINK, fname, is_design_plot);
%
function bfm_plot_scores_ui(varargin)

   if ~ischar(varargin{1})

      is_design_plot = varargin{1};
      fig = [];

      [tmp tit_fn] = rri_fileparts(get(gcf,'name'));
      fig_hdl = init(is_design_plot, tit_fn);
%      fig_hdl = init(b_scores,d_scores,designlv, ...
%		perm_result,conditions,evt_list,fname);

      if ~isempty(fig_hdl)

         link_info.hdl = gcbf;
         link_info.name = 'ScorePlotHdl';
         setappdata(fig_hdl,'LinkFigureInfo',link_info);
         setappdata(gcbf,'ScorePlotHdl',fig_hdl);

         lv_idx = getappdata(gcbf,'CurrLVIdx');

         if (lv_idx ~= 1)
            bfm_plot_scores_ui('UPDATE_LV_SELECTION',fig_hdl,lv_idx);
         end

         old_pointer = get(gcf,'Pointer');
         set(gcf,'Pointer','watch');

         SetupSlider;
         DisplayLVButtons;
         PlotBrainDesignScores;
         PlotDesignScores;

         set(gcf,'Pointer',old_pointer);

      end

      return;

%      if (fig_hdl == -1),
%         close(gcf);
%         return;
%      end;

   end

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   switch (action),
     case {'RESIZE_FIGURE'},
         SetObjectPositions;
         PlotBrainDesignScores;
         PlotDesignScores;
     case {'MOVE_SLIDER'},
         MoveSlider;
     case {'SET_TOP_LV_BUTTON'},
         lv_idx = varargin{2};
         SetTopLVButton(lv_idx);
     case {'TOGGLE_LEGEND'},
         ToggleLegend;
     case {'TOGGLE_BRAIN_DESIGN_SCORES'},
         ToggleBrainDesignScores;
     case {'TOGGLE_DESIGN_SCORES'},
         ToggleDesignScores;
     case {'TOGGLE_PERM_DESIGN_LV'},
         ToggleDesignLV;
     case {'UPDATE_LV_SELECTION'},
         old_pointer = get(gcf,'Pointer');
         set(gcf,'Pointer','watch');
         fig_hdl = varargin{2};
         lv_idx = varargin{3};
         figure(fig_hdl);		% may be calling from another figure
	 SelectLV(lv_idx);
         PlotBrainDesignScores;
         PlotDesignScores;
         PlotDesignLV;
         set(gcf,'Pointer',old_pointer);
     case {'SELECT_LV'},
         old_pointer = get(gcf,'Pointer');
         set(gcf,'Pointer','watch');
	 SelectLV;
         PlotBrainDesignScores;
         PlotDesignScores;
         PlotDesignLV;
         set(gcf,'Pointer',old_pointer);
     case {'DELETE_FIGURE'}
  	 delete_fig;
     otherwise
	 disp(sprintf('ERROR: Unknown action "%s"',action));
   end;

   return;					% bfm_plot_scores_ui


%---------------------------------------------------------------------------
function hh = init(is_design_plot, tit_fn)
%function fig_hdl = init(b_scores,d_scores,designlv, ...
%	perm_result,conditions,evt_list,PLSresultFile)

   tit = ['PLS Scores Plot  [', tit_fn, ']'];

   hh = [];
   scores_fig = getappdata(gcbf,'ScorePlotHdl');

   if ~isempty(scores_fig)
      msg = 'ERROR: Scores Plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   h0 = findobj(gcbf,'Tag','ResultFile');
   PLSresultFile = get(h0,'UserData');

   save_setting_status = 'on';
   bfm_plot_scores_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(bfm_plot_scores_pos) & strcmp(save_setting_status,'on')

      pos = bfm_plot_scores_pos;

   else

      w = 0.85;
      h = 0.75;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   hh = figure('Units','normal', ...
	   'user','PLS Scores Plot', ...
	   'name',tit, ...
	   'NumberTitle','off', ...
	   'Color', [0.8 0.8 0.8], ...
 	   'DoubleBuffer','on', ...
	   'Menubar', 'none', ...
	   'DeleteFcn', 'bfm_plot_scores_ui(''DELETE_FIGURE'');', ...
	   'Position',pos, ...
	   'Tag','PlotScoresFig');

   x = 0.03;
   y = 0.2;
   w = 0.18;
   h = 0.74;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
           'Units','normal', ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'frame', ...
	   'Position', pos, ...
           'HorizontalAlignment', 'left',...
	   'Tag', 'LVFrame');

   x = 0.06;
   y = 0.9;
   w = 0.12;
   h = 0.05;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
           'Units','normal', ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'text', ...
	   'Position', pos, ...
           'HorizontalAlignment', 'left',...
	   'FontUnits', 'normal', ...
	   'FontSize', 0.5, ...
	   'String', ' Display LVs', ...
	   'Tag', 'DisplayLVLabel');

   x = 0.07;
   y = 0.85;
   w = 0.1;

   pos = [x y w h];

% the font normal does not work here

   lv_h = uicontrol('Parent',hh, ...
           'Units','normal', ...
	   'BackgroundColor', [0.8 0.8 0.8], ...
 	   'Style', 'radiobutton', ...
	   'Position', pos, ...
           'HorizontalAlignment', 'center',...
	   'FontUnits', 'point', ...
	   'FontSize', 10, ...
	   'String', 'LV #1', ...
	   'Visible', 'off', ...
   	   'Callback','bfm_plot_scores_ui(''SELECT_LV'');', ...
	   'Tag', 'LVRadioButton');

   x = x+w+.01;
   w = 0.02;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...		% LV Button Slider
     	   'Style','slider', ...
   	   'Units','normal', ...
           'Min', 0, ...
           'Max', 1, ...
	   'Visible', 'off', ...
   	   'Position',pos, ...
   	   'Callback','bfm_plot_scores_ui(''MOVE_SLIDER'');', ...
   	   'Tag','LVButtonSlider');

   x = 0.07;
   y = 0.08;
   w = 0.1;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'Style', 'push', ...
	  'Position', pos, ...
	  'FontUnits', 'normal', ...
	  'FontSize', 0.5, ...
          'String', 'Close', ...
          'CallBack', 'close(gcf)', ...
	  'Tag', 'CloseButton');

   x = 0.01;
   y = 0;
   w = .5;
   h = 0.04;

   pos = [x y w h];

   h0 = uicontrol('Parent',hh, ...		% Message Line
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

   rri_file_menu(hh);

   h_menu = uimenu('Parent',hh, ...
   	   'Label','&View', ...
   	   'Tag','ViewMenu');

   h0 = uimenu('Parent',h_menu, ...
   	   'Label','&Hide Legend', ...
	   'Userdata',1, ...		% show legend
           'CallBack', 'bfm_plot_scores_ui(''TOGGLE_LEGEND'');', ...
   	   'Tag','LegendMenu');

   if(is_design_plot)
      h0 = uimenu('Parent',h_menu, ...
   	   'Label','Hide &Design Scores', ...
	   'Userdata',1, ...		% show design scores
           'CallBack', 'bfm_plot_scores_ui(''TOGGLE_DESIGN_SCORES'');', ...
   	   'Tag','DesignMenu');
      h0 = uimenu('Parent',h_menu, ...
   	   'Label','Hide &Brain vs Design Scores', ...
	   'Userdata',1, ...		% show brain vs design scores
           'CallBack', 'bfm_plot_scores_ui(''TOGGLE_BRAIN_DESIGN_SCORES'');', ...
   	   'Tag','BrainDesignMenu');
      h0 = uimenu('Parent',h_menu, ...
   	   'Label','Show Design &Latent Variables', ...
	   'Userdata',0, ...		% show permutation design lv
           'CallBack', 'bfm_plot_scores_ui(''TOGGLE_PERM_DESIGN_LV'');', ...
   	   'Tag','DesignLVMenu');
   else
      h0 = uimenu('Parent',h_menu, ...
   	   'Label','Hide Be&havior Scores', ...
	   'Userdata',1, ...		% show behavior scores
           'CallBack', 'bfm_plot_scores_ui(''TOGGLE_DESIGN_SCORES'');', ...
   	   'Tag','BehavMenu');
      h0 = uimenu('Parent',h_menu, ...
   	   'Label','Hide &Brain vs Behavior Scores', ...
	   'Userdata',1, ...		% show brain vs behavior scores
           'CallBack', 'bfm_plot_scores_ui(''TOGGLE_BRAIN_DESIGN_SCORES'');', ...
   	   'Tag','BrainBehavMenu');
      h0 = uimenu('Parent',h_menu, ...
   	   'Label','Show Behavior &Latent Variables', ...
	   'Userdata',0, ...		% show permutation behavior lv
           'CallBack', 'bfm_plot_scores_ui(''TOGGLE_PERM_DESIGN_LV'');', ...
   	   'Tag','BehavLVMenu');
   end


   %  set up the axes for plotting
   %
%	   'FontUnits', 'normal', ...
%	   'FontSize', 0.07, ...
%    axes font were not normalized because the Legend can't display properly
%
   %
   x = 0.28;
   y = 0.1;
   w = 0.69;
   h = 0.85;

   pos = [x y w h];

   handle_main_axes = axes('units','normal', ...
        'box', 'on', ...
        'tickdir', 'out', ...
        'ticklength', [0.005 0.005], ...
	'fontsize', 10, ...
	'xtickmode', 'auto', ...
	'xticklabelmode', 'auto', ...
	'ytickmode', 'auto', ...
	'yticklabelmode', 'auto', ...
        'Tag','ScoreAxes', ...
        'Visible','off', ...
	'position',pos);

   h = 0.37;

   pos = [x y w h];

   handle_bottom_axes = axes('units','normal', ...
        'box', 'on', ...
        'tickdir', 'out', ...
        'ticklength', [0.005 0.005], ...
	'fontsize', 10, ...
	'xtickmode', 'auto', ...
	'xticklabelmode', 'auto', ...
	'ytickmode', 'auto', ...
	'yticklabelmode', 'auto', ...
        'Tag','ScoreAxesBottom', ...
	'position',pos);

   y = 0.58;

   pos = [x y w h];

   handle_top_axes = axes('units','normal', ...
        'box', 'on', ...
        'tickdir', 'out', ...
        'ticklength', [0.005 0.005], ...
	'fontsize', 10, ...
	'xtickmode', 'auto', ...
	'xticklabelmode', 'auto', ...
	'ytickmode', 'auto', ...
	'yticklabelmode', 'auto', ...
        'Tag','ScoreAxesTop', ...
	'position',pos);

%   if ~isempty(PLSresultFile)
%      set(hh,'Name',sprintf('PLS Scores Plot: %s',PLSresultFile));
%   end;

   lv_template = copyobj_legacy(lv_h,gcf);
   set(lv_template,'Tag','LVTemplate','Visible','off');

   [b_scores,d_scores,designlv,s,perm_result,conditions, ...
			num_conds,num_subjs_grp1,fname]=...
			load_pls_scores(PLSresultFile, is_design_plot);
   if isempty(b_scores)
      return;
   end

   num_lv = size(b_scores,2);
   curr_lv_state = zeros(1,num_lv);
   curr_lv_state(1) = 1;

   setappdata(gcf,'BrainScores',b_scores);
   setappdata(gcf,'DesignScores',d_scores);
   setappdata(gcf,'DesignLV',designlv);
   setappdata(gcf,'s',s);
   setappdata(gcf,'PermutationResult',perm_result);
   setappdata(gcf,'Conditions',conditions);
   setappdata(gcf,'num_conds',num_conds);
   setappdata(gcf,'num_subjs_grp1',num_subjs_grp1);
   setappdata(gcf,'CurrLVState',curr_lv_state);

   % for GUI
   setappdata(gcf,'LVButtonHeight',0.05);
   setappdata(gcf,'LV_hlist',[lv_h]);
   setappdata(gcf,'LVButtonTemplate',lv_template);
   setappdata(gcf,'TopLVButton',1);
   setappdata(gcf,'ScoreAxes',handle_main_axes);
   setappdata(gcf,'ScoreAxes_bottom',handle_bottom_axes);
   setappdata(gcf,'ScoreAxes_top',handle_top_axes);
   setappdata(gcf,'PlotDesignState',1);
   setappdata(gcf,'PlotBrainDesignState',1)
   setappdata(gcf,'PlotDesignLVState',0);
   setappdata(gcf, 'is_design_plot', is_design_plot);

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


%---------------------------------------------------------------------------
function PlotBrainDesignScores()

   if (getappdata(gcf,'PlotBrainDesignState') == 0)
      return;
   end;

   s = getappdata(gcf,'s');
   cb = erp_per(s);
   perm_result = getappdata(gcf,'PermutationResult');
   b_scores = getappdata(gcf,'BrainScores');
   d_scores = getappdata(gcf,'DesignScores');
   conditions = getappdata(gcf,'Conditions');
   lv_state = getappdata(gcf,'CurrLVState');

   if (getappdata(gcf,'PlotDesignState') == 1),
      ax_hdl = getappdata(gcf,'ScoreAxes_bottom');
   else
      ax_hdl = getappdata(gcf,'ScoreAxes');
   end;


   colour_code =[ 'bo';'rx';'g+';'m*';'bs';'rd';'g^';'m<';'bp';'r>'; ...
                  'gh';'mv';'ro';'gx';'m+';'b*';'rs';'gd';'m^';'b<'];


   num_conds = getappdata(gcf,'num_conds');
   num_subjs_grp1 = getappdata(gcf,'num_subjs_grp1');

   lv_idx = find(lv_state == 1);

   min_x = min(d_scores(:)); max_x = max(d_scores(:));
   min_y = min(b_scores(:)); max_y = max(b_scores(:));
   margin_x = abs((max_x - min_x) / 100);
   margin_y = abs((max_y - min_y) / 100);

   axes(ax_hdl);
   cla; grid off; hold on;

   for n=1:num_subjs_grp1
      for k=1:num_conds
         j = (k-1) * num_subjs_grp1 + n;
         plot(d_scores(j,lv_idx),b_scores(j,lv_idx), colour_code(k,:));
         axis([min_x-margin_x,max_x+margin_x,min_y-margin_y,max_y+margin_y]);
      end
   end
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
      [l_hdl, o_hdl] = legend(conditions);
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
%      set(get(gca,'xlabel'), ...
%	'FontUnits', 'normal', ...
%	'FontSize', 0.07, ...
%	'string','Design Scores');

   else
      xlabel('Behavior Scores');
%      set(get(gca,'xlabel'), ...
%	'FontUnits', 'normal', ...
%	'FontSize', 0.07, ...
%	'string','Behavior Scores');
   end

   ylabel('Brain Scores');
%   set(get(gca,'ylabel'), ...
%	'FontUnits', 'normal', ...
%	'FontSize', 0.07, ...
%	'string','Brain Scores');
   title('');

   if (getappdata(gcf,'PlotDesignState') == 1) | isempty(perm_result)
      return;
   else
      title(sprintf('LV %d:  %.2f%% crossblock,  p < %.3f', lv_idx, 100*cb(lv_idx), perm_result.sprob(lv_idx)));
   end

   return;                                              % PlotBrainDesignScores


%---------------------------------------------------------------------------
function PlotDesignScores()

   if (getappdata(gcf,'PlotDesignState') == 0),
      return;
   end;

   s = getappdata(gcf,'s');
   cb = erp_per(s);
   perm_result = getappdata(gcf,'PermutationResult');
   d_scores = getappdata(gcf,'DesignScores');

   conditions = getappdata(gcf,'Conditions');
   lv_state = getappdata(gcf,'CurrLVState');

   if (getappdata(gcf,'PlotBrainDesignState') == 1),
      ax_hdl = getappdata(gcf,'ScoreAxes_top');
   else
      ax_hdl = getappdata(gcf,'ScoreAxes');
   end;

   axes(ax_hdl);
   cla;hold on;

   if isempty(conditions),
      num_conds = 1:size(b_scores,1);
   else
      num_conds = length(conditions);
   end;

   num_subjs_grp1 = getappdata(gcf,'num_subjs_grp1');

   % like ERP, we aggregate the same design score together
   %
   mask = [];

   for k = 1:num_conds
      mask = [mask,num_subjs_grp1*(k-1)+1];
   end

   d_scores = d_scores(mask,:);

   min_x = 0.5;				max_x = num_conds+0.5;
   min_y = min(d_scores(:));		max_y = max(d_scores(:));
   margin_x = abs((max_x - min_x) / 20);
   margin_y = abs((max_y - min_y) / 20);

   lv_idx = find(lv_state == 1);

   load('rri_color_code');

   for k = 1:num_conds
      bar_hdl = bar(k, d_scores(k,lv_idx));
      set(bar_hdl,'facecolor',color_code(k,:));
   end

   hold off;

%   set(ax_hdl,'XTick',[0.5:num_conds:(size(d_scores,1)+1)],'XTickLabel',{});

   axis([min_x,max_x,min_y-margin_y,max_y+margin_y]);

   set(ax_hdl,'xtick',1:num_conds);
   set(ax_hdl,'xticklabel',1:num_conds);

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

   grid on;

   xlabel('Conditions');
%   set(get(gca,'xlabel'), ...
%	'FontUnits', 'normal', ...
%	'FontSize', 0.07, ...
%	'string','Conditions');

   if(getappdata(gcf, 'is_design_plot'))
      ylabel('Design Scores');
%      set(get(gca,'ylabel'), ...
%	'FontUnits', 'normal', ...
%	'FontSize', 0.07, ...
%	'string','Design Scores');
   else
      ylabel('Behavior Scores');
%      set(get(gca,'ylabel'), ...
%	'FontUnits', 'normal', ...
%	'FontSize', 0.07, ...
%	'string','Design Scores');
   end

   title('');

   if isempty(perm_result)
      return;
   else
      title(sprintf('LV %d:  %.2f%% crossblock,  p < %.3f', lv_idx, 100*cb(lv_idx), perm_result.sprob(lv_idx)));
   end

   return;                                              % PlotDesignScores



%---------------------------------------------------------------------------
function PlotDesignLV()

   if (getappdata(gcf,'PlotDesignLVState') == 0)
      return;
   end;

   s = getappdata(gcf,'s');
   cb = erp_per(s);
   perm_result = getappdata(gcf,'PermutationResult');
   designlv = getappdata(gcf,'DesignLV');

   lv_state = getappdata(gcf,'CurrLVState');
   lv_idx = find(lv_state == 1);
   num_lv = length(lv_state);

   conditions = getappdata(gcf,'Conditions');
   num_conds = length(conditions);

   mask = zeros(1, size(designlv,1));
   mask( [1 : num_conds] ) = 1;
   designlv = designlv(find(mask), :);

   min_x = 0.5;				max_x = num_conds+0.5;
   min_y = min(designlv(:));	max_y = max(designlv(:));
   margin_x = abs((max_x - min_x) / 20);
   margin_y = abs((max_y - min_y) / 20);

if(1)
   ax_hdl = getappdata(gcf,'ScoreAxes_bottom');
   axes(ax_hdl);
   set(ax_hdl,'visible','off');
end

   %  plot of the designlv
   %
   ax_hdl = getappdata(gcf,'ScoreAxes_top');
   axes(ax_hdl);
   cla;hold on;

%   num_contrasts = size(designlv,1);
%   tick_step = round(num_contrasts / 20);

   load('rri_color_code');

   for k = 1:num_conds
      bar_hdl = bar(k, designlv(k,lv_idx));
      set(bar_hdl,'facecolor',color_code(k,:));
   end

   hold off;

   set(ax_hdl,'xtick',1:num_conds);
   set(ax_hdl,'xticklabel',1:num_conds);
   set(ax_hdl,'tickdir','out','ticklength',[0.005 0.005],'box','on');

   ylabel('Weights');

%   min_value = min(designlv(:,lv_idx));
%   max_value = max(designlv(:,lv_idx));
%   offset = (max_value - min_value) / 20;
%   axis([0 size(designlv,1)+1 min_value-offset max_value+offset]);

   title('Weights of the contrasts for the design LV'); 

   grid on;

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

   xlabel('Conditions');


if(0)

   %  plot of the designlv permuation result if any
   %
   ax_hdl = getappdata(gcf,'ScoreAxes_bottom');
   axes(ax_hdl);


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

   bar(perm_result.sprob(:,lv_idx)*100,'r');
   set(ax_hdl,'XTick',[1:tick_step:num_contrasts]);
%   axis([0 size(designlv,1)+1 0 105]);
   axis([min_x,max_x,min_y-margin_y,max_y+margin_y]);

   xlabel('Contrasts');
   ylabel('Probability (%)');
%   title(sprintf('Elements of the design LV smaller than those of the %d permutation %tests',perm_result.num_perm));

   if(getappdata(gcf, 'is_design_plot'))
      title(sprintf('Permuted design LV greater than observed, %d permutation tests, %d%% crossblock', perm_result.num_perm, cb(lv_idx)));
   else
      title(sprintf('Permuted behav LV greater than observed, %d permutation tests, %d%% crossblock', perm_result.num_perm, cb(lv_idx)));
   end

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

   return;                                           % ToggleBrainDesignScores


%---------------------------------------------------------------------------
function DisplayBrainDesignScores(on_off)

   design_state = getappdata(gcf,'PlotDesignState');

   switch (on_off)
     case {'on'},
        if (design_state == 1),		% need to display design scores
           h = getappdata(gcf,'ScoreAxes');
           axes(h); cla; set(h,'Visible','off');

           set(getappdata(gcf,'ScoreAxes_top'),'Visible','on');
           PlotDesignScores;

           set(getappdata(gcf,'ScoreAxes_bottom'),'Visible','on');
           PlotBrainDesignScores;
        else
           h = getappdata(gcf,'ScoreAxes_top');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'ScoreAxes_bottom');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'ScoreAxes'); 
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
        DisplayLegend('off');
        if (design_state == 1) 
           h = getappdata(gcf,'ScoreAxes_top');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'ScoreAxes_bottom');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'ScoreAxes');
           axes(h); cla; set(h,'Visible','on');
           PlotDesignScores;
        else
           h = getappdata(gcf,'ScoreAxes'); 
           axes(h); cla; set(h,'Visible','off');
	end;

   end;  % switch

   return;                                         % DisplayBrainDesignScores


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
           h = getappdata(gcf,'ScoreAxes'); 
           axes(h); cla; set(h,'Visible','off');

           set(getappdata(gcf,'ScoreAxes_top'),'Visible','on');
           PlotDesignScores;

           set(getappdata(gcf,'ScoreAxes_bottom'),'Visible','on');
           PlotBrainDesignScores;
        else
           h = getappdata(gcf,'ScoreAxes_top');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'ScoreAxes_bottom');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'ScoreAxes'); 
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
           h = getappdata(gcf,'ScoreAxes_top');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'ScoreAxes_bottom');
           axes(h); cla; set(h,'Visible','off');

           set(getappdata(gcf,'ScoreAxes'),'Visible','on');
           PlotBrainDesignScores;
        else
           h = getappdata(gcf,'ScoreAxes'); 
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
           m_hdl = findobj(gcf,'Tag','DesignLVMenu');
           set(m_hdl,'Label','Hide Design &Latent Variables');
           setappdata(gcf,'PlotDesignLVState',1);
	   DisplayDesignLV('on');

           setappdata(gcf,'PlotBrainDesignState',0);
           m_hdl = findobj(gcf,'Tag','BrainDesignMenu');
           set(m_hdl,'Label','Show &Brain vs Design Scores');
           DisplayBrainDesignScores('off');

           setappdata(gcf,'PlotDesignState',0);
           m_hdl = findobj(gcf,'Tag','DesignMenu');
           set(m_hdl,'Label','Show &Design Scores');
           DisplayDesignScores('off');
 	else
           m_hdl = findobj(gcf,'Tag','BehavLVMenu');
           set(m_hdl,'Label','Hide Behavior &Latent Variables');
           setappdata(gcf,'PlotDesignLVState',1);
	   DisplayDesignLV('on');

           setappdata(gcf,'PlotBrainDesignState',0);
           m_hdl = findobj(gcf,'Tag','BrainBehavMenu');
           set(m_hdl,'Label','Show &Brain vs Behavior Scores');
           DisplayBrainDesignScores('off');

           setappdata(gcf,'PlotDesignState',0);
           m_hdl = findobj(gcf,'Tag','BehavMenu');
           set(m_hdl,'Label','Show &Behavior Scores');
           DisplayDesignScores('off');
	end

%	set(findobj(gcf,'Tag','LegendMenu'),'Enable','off');

     case {1},
        new_state = 0;
        if is_design_plot
           m_hdl = findobj(gcf,'Tag','DesignLVMenu');
           set(m_hdl,'Label','Show Design &Latent Variables');
           setappdata(gcf,'PlotDesignLVState',0);
	   DisplayDesignLV('off');

           setappdata(gcf,'PlotBrainDesignState',1);
           m_hdl = findobj(gcf,'Tag','BrainDesignMenu');
           set(m_hdl,'Label','Hide &Brain vs Design Scores');
           DisplayBrainDesignScores('on');

           setappdata(gcf,'PlotDesignState',1);
           m_hdl = findobj(gcf,'Tag','DesignMenu');
           set(m_hdl,'Label','Hide &Design Scores');
           DisplayDesignScores('on');
	else
           m_hdl = findobj(gcf,'Tag','BehavLVMenu');
           set(m_hdl,'Label','Show Behavior &Latent Variables');
           setappdata(gcf,'PlotDesignLVState',0);
	   DisplayDesignLV('off');

           setappdata(gcf,'PlotBrainDesignState',1);
           m_hdl = findobj(gcf,'Tag','BrainBehavMenu');
           set(m_hdl,'Label','Hide &Brain vs Behavior Scores');
           DisplayBrainDesignScores('on');

           setappdata(gcf,'PlotDesignState',1);
           m_hdl = findobj(gcf,'Tag','BehavMenu');
           set(m_hdl,'Label','Hide &Behavior Scores');
           DisplayDesignScores('on');
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

           h = getappdata(gcf,'ScoreAxes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'ScoreAxes_top');
           axes(h); cla; set(h,'Visible','on');

           h = getappdata(gcf,'ScoreAxes_bottom');
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
           h = getappdata(gcf,'ScoreAxes');
           axes(h); cla; set(h,'Visible','off');

           h = getappdata(gcf,'ScoreAxes_top');
           axes(h); cla; set(h,'Visible','off');
%           PlotDesignScores;

           h = getappdata(gcf,'ScoreAxes_bottom');
           axes(h); cla; set(h,'Visible','off');
%	   PlotBrainDesignScores;

   end;  % switch

   return;                                         % DesignLV



%---------------------------------------------------------------------------
function [brainscores,designscores,designlv,s,perm_result,conditions, ...
				num_conds,num_subjs_grp1,fname]...
				= load_pls_scores(fname, is_design_plot)

   b_scores = [];
   d_scores = [];
   designlv = [];
   conditions = [];
   s = [];
   perm_result = [];
   num_conds = [];

   if ~exist('fname','var') | isempty(fname),
     f_pattern = 'PLSresult*.mat';
     [PLSresultFile,PLSresultFilePath] = rri_selectfile(f_pattern,'Load PLS scores');

     if isequal(PLSresultFile,0),
        return;
     end;

     fname = [PLSresultFilePath,PLSresultFile];
   end;

   try
      if(is_design_plot)
         load( fname,'brainscores','designscores','designlv', ...
					'subj_name','num_behav_subj', ...
					's','perm_result','SessionProfiles' );
      else
         load( fname,'brainscores','behavscores','behavlv', ...
					'subj_name','num_behav_subj', ...
					's','perm_result','SessionProfiles' );
         designscores = behavscores;
         designlv = behavlv;
      end
   catch
      msg = sprintf('Cannot load the PLS result from file: %s',PLSresultFile);
      disp(['ERROR: ' msg]);
      return;
   end;
%   evt_list = lv_evt_list;

   load(SessionProfiles{1}{1}, 'session_info');		% load cond info
   conditions = session_info.condition;
   num_conds = session_info.num_conditions;
   num_subjs_grp1 = num_behav_subj;

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

     bfm_plot_scores_pos = get(gcbf,'position');

     save(pls_profile, '-append', 'bfm_plot_scores_pos');
   catch
   end

   return;					% delete_fig
  
