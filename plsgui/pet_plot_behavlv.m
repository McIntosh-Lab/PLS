% Plot Behav LV for all groups
%
%---------------------------------------------------------

function h01 = pet_plot_behavlv(varargin)

   h01 = [];

   if nargin == 0
      h01 = init;
      return;
   end

   action = varargin{1};

   if strcmp(action,'delete_fig')
      delete_fig;
   end

   return; 					% pet_plot_behavlv


%----------------------------------------------------------

function h01 = init

   % ----------------------- Figure --------------------------

   save_setting_status = 'on';
   pet_plot_behavlv_pos = [];


   pet_dlv_user = [];
   try
      pet_dlv_user = get(getappdata(gcf,'pet_dlv_hdl'),'user');
   catch
   end

   if ~isempty(pet_dlv_user) & strcmp(pet_dlv_user,'BehavLV Plot')

      h01 = getappdata(gcf,'pet_dlv_hdl');
      figure(h01);

   else

      h0 = gcbf;

      try
         load('pls_profile');
      catch
      end

      if ~isempty(pet_plot_behavlv_pos) & strcmp(save_setting_status,'on')

         pos = pet_plot_behavlv_pos;

      else

         w = 0.8;
         h = 0.7;
         x = (1-w)/2 + 0.02;
         y = (1-h)/2 - 0.03;

         pos = [x y w h];

      end

      xp = 0.0227273;
      yp = 0.0294118;
      wp = 1-2*xp;
      hp = 1-2*yp;

      pos_p = [xp yp wp hp];

      h01 = figure('units','normal', ...
        'paperunit','normal', ...
        'paperorient','land', ...
        'paperposition',pos_p, ...
        'papertype','usletter', ...
	'numberTitle','off', ...
	'menubar', 'none', ...
	'toolbar', 'none', ...
	'name',' ', ...
	'user','BehavLV Plot', ...
	'color', [0.8 0.8 0.8], ...
	'deleteFcn', 'pet_plot_behavlv(''delete_fig'');', ...
	'doubleBuffer','on', ...
	'position',pos);

   % ----------------------- Axes --------------------------

      pos = [.08 .12 .86 .8];

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

   % ----------------------- Menu --------------------------

      %  file
      %
      rri_file_menu(h01);

   end

   plot_dlv_scores;

   return; 						% init


%--------------------------------------------------------------

function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      pet_plot_behavlv_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'pet_plot_behavlv_pos');
   catch
   end

   h0 = getappdata(gcbf,'main_fig');

   if ishandle(h0)
      setappdata(h0,'PlotDLVState',0);
      hm_dlv = findobj(h0,'Tag','DLVMenu');
      set(hm_dlv,'Label','Show Behavior &LV Overview');
   end

   return;						% delete_fig


%--------------------------------------------------------------

function plot_dlv_scores

      tit_fn = getappdata(gcbf,'tit_fn');
      tit = ['Behav LV Plot  [', tit_fn, ']'];
      set(gcf,'name',tit);

      s = getappdata(gcbf,'s');
      cb = erp_per(s);
      perm_result = getappdata(gcbf,'perm_result');
      behavlv = getappdata(gcbf,'behavlv');

      num_beh = length(getappdata(gcbf, 'behavname'));
      num_cond_lst = getappdata(gcbf, 'num_cond_lst');
      num_subj_lst = getappdata(gcbf, 'num_subj_lst');
      num_grp = length(num_subj_lst);
      lv_idx = find(getappdata(gcbf,'CurrLVState'));
      num_conds = num_cond_lst(1);

      min_x = 0.5;				max_x = size(behavlv,1)+0.5;
      min_y = min(behavlv(:));			max_y = max(behavlv(:));
      margin_x = abs((max_x - min_x) / 20);
      margin_y = abs((max_y - min_y) / 20);

      %  plot of the behavlv
      %
      cla;hold on;

      %  the rows are stacked by groups. each group has several conditions.
      %  each condition could have several contrasts.
      %

      load('rri_color_code');

      for g=1:num_grp
         for k=1:num_conds
             bar_hdl = bar((g-1)*num_beh*num_conds + [1:num_beh] + num_beh*(k-1), ...
		behavlv((g-1)*num_beh*num_conds + [1:num_beh] + num_beh*(k-1), ...
			lv_idx));
            set(bar_hdl,'facecolor',color_code(k,:));
         end
      end

      hold off;

      axis([min_x,max_x,min_y-margin_y,max_y+margin_y]);

      set(gca,'tickdir','out','ticklength', [0.005 0.005], ...
		'box','on');
      ylabel('Behav LV');

      if isempty(perm_result)
         title(sprintf('LV %d:  %.2f%% crossblock', lv_idx, 100*cb(lv_idx)));
      else
         title(sprintf('LV %d:  %.2f%% crossblock,  p < %.3f', lv_idx, 100*cb(lv_idx), perm_result.sprob(lv_idx)));
      end

      grid on;

      set(gca,'xtick',([1:num_grp] - 1) * num_beh*num_conds + 0.5);
      set(gca,'xticklabel',1:num_grp);

      selected_conditions = getappdata(gcbf, 'selected_conditions');

      %  solve wrong label problem for bfm/fmri
      %
      if max(selected_conditions) == 1
         selected_conditions = find(selected_conditions);
      end

      conditions = getappdata(gcbf, 'Conditions');
      conditions = conditions(selected_conditions);

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

      else

         setappdata(gcbf,'LegendHdl3',[]);

      end;

      xlabel('Groups');

      return;

