function fig = fmri_plot_taskpls_bs(varargin)

   if strcmp('LINK',varargin{1})
      fname = varargin{2};
      LINKFig = 1;
   else
      fname = [];
      LINKFig = 0;
   end;

   if (nargin == 0) | ~ischar(varargin{1}) | (LINKFig == 1)
      fig = [];

      if (nargin == 0 | LINKFig)

          [b_scores,d_scores,designlv,s,perm_result,boot_result,conditions,evt_list,fname, ...
		subj_name,subj_group,num_subj_lst,num_cond_lst,subj_name_lst, ...
		num_grp,result_ver,method] = load_pls_scores(fname);

          if isempty(result_ver) | ( str2num(result_ver) < 5.0807091 )
              msgbox('Please run Task PLS again with this new program');
              return;
          end;

          if method==4 & ( str2num(result_ver) < 5.0908261 )
              msgbox('Please run Multiblock PLS again with this new program');
              return;
          end;

          if isempty(b_scores),		
              return;
          end;

      else
          b_scores = varargin{1};
          d_scores = varargin{2};
          conditions = varargin{3};
          evt_list = varargin{4};
          perm_result = varargin{5};
          fname = [];
      end;

      [tmp tit_fn] = rri_fileparts(get(gcf,'name'));
      fig_hdl = init(b_scores,d_scores,designlv,s,perm_result,boot_result, ...
		conditions,evt_list,fname,subj_name,subj_group,num_subj_lst, ...
		num_cond_lst,subj_name_lst,num_grp,tit_fn);

      if (fig_hdl == -1),
         close(gcf);
         return;
      end;

      SetupSlider;
      DisplayLVButtons;
%      PlotBrainDesignScores;
 %     PlotDesignScores;
      PlotBrainScores;

      if (nargout >= 1)
         fig = fig_hdl;
      end;
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   switch (action),
     case {'RESIZE_FIGURE'},
         SetObjectPositions;
%         PlotBrainDesignScores;
 %        PlotDesignScores;
         PlotBrainScores;
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
         fig_hdl = varargin{2};
         lv_idx = varargin{3};
         figure(fig_hdl);		% may be calling from another figure
	 SelectLV(lv_idx);
%         PlotBrainDesignScores;
 %        PlotDesignScores;
  %       PlotDesignLV;
         PlotBrainScores;
     case {'SELECT_LV'},
	 SelectLV;
%         PlotBrainDesignScores;
 %        PlotDesignScores;
  %       PlotDesignLV;
         PlotBrainScores;
     case {'DELETE_FIGURE'}
  	 delete_fig; 
     case {'ZOOM'}
         zoom_on_state = get(gcbo,'Userdata');
         if (zoom_on_state == 1)                   % zoom on
            zoom on;
            set(gcbo,'Userdata',0,'Label','&Zoom off');
            set(gcf,'pointer','crosshair');
         else                                      % zoom off
            zoom off;
            set(gcf,'buttondown','fmri_plot_taskpls_bs(''fig_bt_dn'');');
            set(gcbo,'Userdata',1,'Label','&Zoom on');
            set(gcf,'pointer','arrow');
         end
     case {'FIG_BT_DN'}
         fig_bt_dn;
     case {'EDIT_GROUP'}
         edit_group
     case {'SELECT_SUBJ'}
  	 select_subj;
     otherwise
	 disp(sprintf('ERROR: Unknown action "%s"',action));
   end;

   return;					% PLS_PLOT_SCORES


%---------------------------------------------------------------------------
function fig_hdl = init(b_scores,d_scores,designlv,s,perm_result,boot_result,conditions, ...
	evt_list,PLSresultFile,subj_name,subj_group,num_subj_lst,num_cond_lst, ...
	subj_name_lst,num_grp,tit_fn)

   tit = ['PLS Brain Scores Plot  [', tit_fn, ']'];

   fig_hdl = -1;

   save_setting_status = 'on';
   fmri_plot_taskpls_bs_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_plot_taskpls_bs_pos) & strcmp(save_setting_status,'on')

      pos = fmri_plot_taskpls_bs_pos;

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
	   'DeleteFcn', 'fmri_plot_taskpls_bs(''DELETE_FIGURE'');', ...
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
           'HorizontalAlignment', 'center',...
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
           'HorizontalAlignment', 'left',...
	   'FontUnits', 'point', ...
	   'FontSize', 10, ...
	   'String', 'LV #1', ...
	   'Visible', 'off', ...
   	   'Callback','fmri_plot_taskpls_bs(''SELECT_LV'');', ...
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
   	   'Callback','fmri_plot_taskpls_bs(''MOVE_SLIDER'');', ...
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

   % ----------------------- Menu --------------------------

   %  file
   %
   rri_file_menu(hh);

   %  view
   %
   h_menu = uimenu('Parent',hh, ...
   	   'Label','&View', ...
	   'visible', 'off', ...
   	   'Tag','ViewMenu');

   h0 = uimenu('Parent',h_menu, ...
   	   'Label','Hide &Design Scores', ...
	   'Userdata',1, ...		% show design scores
           'CallBack', 'fmri_plot_taskpls_bs(''TOGGLE_DESIGN_SCORES'');', ...
   	   'Tag','DesignMenu');
   h0 = uimenu('Parent',h_menu, ...
   	   'Label','Hide &Brain vs Design Scores', ...
	   'Userdata',1, ...		% show brain vs design scores
           'CallBack', 'fmri_plot_taskpls_bs(''TOGGLE_BRAIN_DESIGN_SCORES'');', ...
   	   'Tag','BrainDesignMenu');
   h0 = uimenu('Parent',h_menu, ...
   	   'Label','Show Design &Latent Variables', ...
	   'Userdata',0, ...		% show permutation design lv
           'CallBack', 'fmri_plot_taskpls_bs(''TOGGLE_PERM_DESIGN_LV'');', ...
   	   'Tag','DesignLVMenu');
   h0 = uimenu('Parent',h_menu, ...
   	   'Label','&Hide Legend', ...
           'separator', 'on', ...
	   'Userdata',1, ...		% show legend
           'CallBack', 'fmri_plot_taskpls_bs(''TOGGLE_LEGEND'');', ...
   	   'Tag','LegendMenu');

   %  zoom
   %
   h2 = uimenu('parent',hh, ...
	'visible', 'off', ...
        'userdata', 1, ...
        'callback','fmri_plot_taskpls_bs(''zoom'');', ...
        'label','&Zoom on');

   %  set up the axes for plotting
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

   num_lv = size(b_scores,2);
   curr_lv_state = zeros(1,num_lv); 
   curr_lv_state(1) = 1;

   setappdata(gcf,'EventList',evt_list);
   setappdata(gcf,'BrainScores',b_scores);
   setappdata(gcf,'DesignScores',d_scores);
   setappdata(gcf,'DesignLV',designlv);
   setappdata(gcf,'s',s);
   setappdata(gcf,'PermutationResult',perm_result);
   setappdata(gcf,'boot_result',boot_result);
   setappdata(gcf,'Conditions',conditions);
   setappdata(gcf,'CurrLVState',curr_lv_state);
   setappdata(gcf,'subj_name',subj_name);
   setappdata(gcf,'num_subj_lst',num_subj_lst);
   setappdata(gcf,'num_cond_lst',num_cond_lst);
   setappdata(gcf,'subj_name_lst',subj_name_lst);
   setappdata(gcf,'num_grp',num_grp);

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

   fig_hdl = hh;

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
   num_cond_lst = getappdata(gcf, 'num_cond_lst');
   num_subj_lst = getappdata(gcf, 'num_subj_lst');
   num_grp = getappdata(gcf, 'num_grp');
   num_conds = num_cond_lst(1);

   lv_state = getappdata(gcf,'CurrLVState');
   lv_idx = find(lv_state == 1);

   if (getappdata(gcf,'PlotDesignState') == 1),
      ax_hdl = getappdata(gcf,'ScoreAxes_bottom');
   else
      ax_hdl = getappdata(gcf,'ScoreAxes');
   end;

   set(ax_hdl, ...
	'buttondown','fmri_plot_taskpls_bs(''fig_bt_dn'');', ...
	'userdata', 'PlotBrainDesignScores');

   evt_list = getappdata(gcf,'EventList');

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

   min_x = min(d_scores(:)); max_x = max(d_scores(:));
   min_y = min(b_scores(:)); max_y = max(b_scores(:));
   margin_x = abs((max_x - min_x) / 100);
   margin_y = abs((max_y - min_y) / 100);
   
   axes(ax_hdl);
   cla; grid off; hold on;
   
   for grp_idx = 1:num_grp

      num_subjs = num_subj_lst(grp_idx);
      first = sum(num_in_grp(1:grp_idx)) + 1;
      last = sum(num_in_grp(1:(grp_idx+1)));
      tmp_evt_list = evt_list(first:last);
      tmp_d_scores = d_scores(first:last,:);
      tmp_b_scores = b_scores(first:last,:);

      % reorder with evt_list to make it cond1(subj1, subj2 ...), cond2, ...
      %
      [new_evt_list, reorder_idx] = sort(tmp_evt_list);
      tmp_d_scores = tmp_d_scores(reorder_idx,:);
      tmp_b_scores = tmp_b_scores(reorder_idx,:);

      for n=1:num_subjs
         for k=1:num_conds
            j = (k-1) * num_subjs + n;
            score_hdl(grp_idx,n,k) = plot(tmp_d_scores(j,lv_idx), ...
		   tmp_b_scores(j,lv_idx), ...
                   color_code(k,:), ...
                   'buttondown','fmri_plot_taskpls_bs(''select_subj'');', ...
                   'userdata', [grp_idx, n]);
         end

%         axis([min_x-margin_x,max_x+margin_x,min_y-margin_y,max_y+margin_y]);

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

   xlabel('Design Scores'); 
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
      title(sprintf('LV %d:  %.2f%% crossblock,  p < %.3f', lv_idx, 100*cb(lv_idx), perm_result.s_prob(lv_idx)));
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
   evt_list = getappdata(gcf,'EventList');
   lv_state = getappdata(gcf,'CurrLVState');


   if (getappdata(gcf,'PlotBrainDesignState') == 1),
      ax_hdl = getappdata(gcf,'ScoreAxes_top');
   else
      ax_hdl = getappdata(gcf,'ScoreAxes');
   end;

   axes(ax_hdl);
   cla;hold on;

   lv_idx = find(lv_state == 1);
   num_conds = length(conditions);
   num_cond_lst = getappdata(gcf, 'num_cond_lst');
   num_subj_lst = getappdata(gcf, 'num_subj_lst');
   num_in_grp = [0 num_cond_lst.*num_subj_lst];
   num_grp = getappdata(gcf,'num_grp');
   grp_d_scores = [];

   for grp_idx = 1:num_grp

      num_subjs = num_subj_lst(grp_idx);
      first = sum(num_in_grp(1:grp_idx)) + 1;
      last = sum(num_in_grp(1:(grp_idx+1)));
      tmp_d_scores = d_scores(first:last,:);
      tmp_evt_list = evt_list(first:last);
      [tmp, new_idx] = unique(tmp_evt_list);

      grp_d_scores = [grp_d_scores; tmp_d_scores(new_idx,:)];

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
    
   xlabel('Groups');
   set(ax_hdl,'xtick',([1:num_grp] - 1)*num_conds + 0.5);
   set(ax_hdl,'xticklabel',1:num_grp);

   hold off;

   axis([min_x,max_x,min_y-margin_y,max_y+margin_y]);

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

   ylabel('Design Scores'); 
   title('');
   grid on;

   if isempty(perm_result)
      return;
   else
      title(sprintf('LV %d:  %.2f%% crossblock,  p < %.3f', lv_idx, 100*cb(lv_idx), perm_result.s_prob(lv_idx)));
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

%   designlv = designlv([1:num_conds],:);

   min_x = 0.5;				max_x = size(designlv,1)+0.5;
   min_y = min(designlv(:));		max_y = max(designlv(:));
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

   num_grp = getappdata(gcf,'num_grp');

   for g=1:num_grp
      for k = 1:num_conds
         bar_hdl = bar((g-1)*num_conds + k,designlv((g-1)*num_conds + k,lv_idx));
         set(bar_hdl,'facecolor',color_code(k,:));
      end
   end

   xlabel('Groups');
   set(ax_hdl,'xtick',([1:num_grp] - 1)*num_conds + 0.5);
   set(ax_hdl,'xticklabel',1:num_grp);

%   bar(designlv(:,lv_idx));

%   set(ax_hdl,'XTick',[1:tick_step:num_contrasts]);

%   set(ax_hdl,'xtick',1:num_conds);
%   set(ax_hdl,'xticklabel',1:num_conds);

   set(ax_hdl,'tickdir','out','ticklength', [0.005 0.005], ...
	'box','on');

   ylabel('Weights');

   min_value = min(designlv(:,lv_idx));
   max_value = max(designlv(:,lv_idx));
   offset = (max_value - min_value) / 20;
%   axis([0 size(designlv,1)+1 min_value-offset max_value+offset]);
   axis([min_x,max_x,min_y-margin_y,max_y+margin_y]);

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

%   xlabel('Conditions');


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
      title('--- No permutation test has been performed --- ')
      return;
   end;

   bar(perm_result.designlv_prob(:,lv_idx)*100,'r');
   set(ax_hdl,'XTick',[1:tick_step:num_contrasts]);
%   axis([0 size(designlv,1)+1 0 105]);

   xlabel('Contrasts');
   ylabel('Probability (%)');
%   title(sprintf('Elements of the design LV smaller than those of the %d permutation tests',perm_result.num_perm));

   title(sprintf('Permuted design LV greater than observed, %d permutation tests, %d%% crossblock', perm_result.num_perm, cb(lv_idx)));

end

   hold off
   return;                                              % PlotDesignLV


%---------------------------------------------------------------------------
function ToggleLegend

   h = findobj(gcf,'Tag','LegendMenu');
   l_hdls = getappdata(gcf,'LegendHdl');

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
   m_hdl = findobj(gcf,'Tag','BrainDesignMenu');

   switch (brain_design_state)
     case {0},
   	set(m_hdl,'Label','Hide &Brain vs Design Scores');
        setappdata(gcf,'PlotBrainDesignState',1);
	DisplayBrainDesignScores('on');
%   	set(findobj(gcf,'Tag','LegendMenu'),'Enable','on');

        setappdata(gcf,'PlotDesignLVState',0);
        m_hdl = findobj(gcf,'Tag','DesignLVMenu');
        set(m_hdl,'Label','Show Design &Latent Variables');
     case {1},
   	set(m_hdl,'Label','Show &Brain vs Design Scores');
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
%        DisplayLegend('off');
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
   m_hdl = findobj(gcf,'Tag','DesignMenu');

   switch (design_state)
     case {0},
        set(m_hdl,'Label','Hide &Design Scores');
        setappdata(gcf,'PlotDesignState',1);
	DisplayDesignScores('on');

        setappdata(gcf,'PlotDesignLVState',0);
        m_hdl = findobj(gcf,'Tag','DesignLVMenu');
        set(m_hdl,'Label','Show Design &Latent Variables');
     case {1},
        new_state = 0;
        set(m_hdl,'Label','Show &Design Scores');
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
   m_hdl = findobj(gcf,'Tag','DesignLVMenu');

   switch (designlv_state)
     case {0},
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

%   	set(findobj(gcf,'Tag','LegendMenu'),'Enable','off');
     case {1},
        new_state = 0;
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
function delete_fig(),

   link_info = getappdata(gcbf,'LinkFigureInfo');

   try
      rmappdata(link_info.hdl,link_info.name);
   end;

   try
     load('pls_profile');
     pls_profile = which('pls_profile.mat');

     fmri_plot_taskpls_bs_pos = get(gcbf,'position');

     save(pls_profile, '-append', 'fmri_plot_taskpls_bs_pos');
   catch
   end

   return;					% delete_fig
  

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

function edit_group



   return;						% edit_group


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


%---------------------------------------------------------------------------
function [b_scores,d_scores,designlv,s,perm_result,boot_result,conditions,evt_list,fname, ...
	subj_name,subj_group,num_subj_lst,num_cond_lst,subj_name_lst, ...
	num_grp, result_ver, method] = load_pls_scores(fname)

   b_scores = [];
   d_scores = [];
   designlv = [];
   conditions = [];
   s = [];
   perm_result = [];
   boot_result = [];
   evt_list = [];

   subj_name = {};
   num_subj_lst = [];
   subj_name_lst = {};
   num_cond_lst = [];

   result_ver = [];

   %  the following part will not get called in plsgui
   %
   if ~exist('fname','var') | isempty(fname),
     f_pattern = '*_fMRIresult.mat';
     [PLSresultFile,PLSresultFilePath] = rri_selectfile(f_pattern,'Load PLS scores');

     if isequal(PLSresultFile,0), 
        return;
     end;

     fname = [PLSresultFilePath,PLSresultFile];
   end;

   cond_selection = [];
   load(fname);

   if exist('result','var')
      if ismember(method, [4 6])
         b_scores = result.TBusc{1};
         d_scores = result.TBvsc{1};
         designlv = result.TBv{1};
      else
         b_scores = result.usc;
         d_scores = result.vsc;
         designlv = result.v;
      end

      s = result.s;
      subj_group = result.num_subj_lst;
      num_subj_lst = result.num_subj_lst;

      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end

      if isfield(result,'perm_result')
         perm_result = result.perm_result;
         perm_result.s_prob = perm_result.sprob;
      else
         perm_result = [];
      end
   end

if 0
   try 
      warning off;
      load( fname,'b_scores','d_scores','lv_evt_list','designlv','subj_group','create_ver', ...
		's','perm_result','boot_result','SessionProfiles','subj_name','num_subj_lst','method');
      warning on;
   catch
      msg = sprintf('Cannot load the PLS result from file: %s',PLSresultFile);
      disp(['ERROR: ' msg]);
      return;
   end;
end

   if exist('create_ver','var')
      result_ver = create_ver;
   end

   rri_changepath('fmriresult');

   evt_list = lv_evt_list;

   if isempty(subj_group)
      num_grp = 1;
   else
      num_grp = length(subj_group);
   end

   load(SessionProfiles{1}{1});	    % load the condition from session profile
   conditions = session_info.condition;

if 0
   cond_selection = [];
   try 
      warning off;
      load( fname, 'cond_selection', 'bscan');
      warning on;
   catch
   end;
end

   if isempty(cond_selection)
      cond_selection = ones(1,session_info.num_conditions);
   end

%   if exist('bscan','var') & ~isempty(bscan)
 %     tmp = find(cond_selection);
  %    cond_selection = zeros(size(cond_selection));
   %   cond_selection(tmp(bscan)) = 1;
   %end

   num_cond_lst = ones(1,length(num_subj_lst))*sum(cond_selection);
   conditions = conditions(find(cond_selection));

   if isempty(subj_group) | isempty(num_subj_lst)
      num_cond_lst = sum(cond_selection);
      subj_name_lst{1} = subj_name;
      return;
   end

   num_cond_lst = ones(1,length(num_subj_lst))*sum(cond_selection);

   first = 1;
   last = 0;
   for i = 1:length(num_subj_lst)

if iscell(num_subj_lst)
      subj_name_lst = subj_name;
else

      last = last + num_subj_lst(i);

      subj_name_lst{i} = {};

      for j = first:last
%         subj_name_lst{i} = [subj_name_lst{i} {['Grp',num2str(i),subj_name{j}]}];
         subj_name_lst{i} = [subj_name_lst{i} {[subj_name{j}]}];
      end

      first = first + num_subj_lst(i);

end					% if iscell(num_subj_lst)

   end				% for i = 1:length(num_subj_lst)

   return;					% load_pls_scores 


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

   ax_hdl = getappdata(gcf,'ScoreAxes_bottom');
   axes(ax_hdl);
   set(ax_hdl,'visible','off');

   ax_hdl = getappdata(gcf,'ScoreAxes_top');
   axes(ax_hdl);
   set(ax_hdl,'visible','off');

   ax_hdl = getappdata(gcf,'ScoreAxes');
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

   conditions = getappdata(gcf, 'Conditions');

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
%       [l_hdl, o_hdl] = legend(conditions, 'Location', 'northeast'); % LP 27.06.2018
        [l_hdl, o_hdl] = legend(conditions,'Location','northeast');
        
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

