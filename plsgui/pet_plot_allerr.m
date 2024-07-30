% Plot Correlation Overview
%
%---------------------------------------------------------

function h01 = pet_plot_allerr(varargin)

   h01 = [];

   if nargin == 0
      h01 = init;
      return;
   end

   action = varargin{1};

   if strcmp(action,'delete_fig')
      delete_fig;
   end

   return; 					% pet_plot_allerr


%----------------------------------------------------------

function h01 = init

   % ----------------------- Figure --------------------------

   save_setting_status = 'on';
   pet_plot_allerr_pos = [];


   pet_allerr_user = [];
   try
      pet_allerr_user = get(getappdata(gcf,'pet_allerr_hdl'),'user');
   catch
   end

   if ~isempty(pet_allerr_user) & strcmp(pet_allerr_user,'Correlation Overview')

      h01 = getappdata(gcf,'pet_allerr_hdl');
      figure(h01);

   else

      h0 = gcbf;

      try
         load('pls_profile');
      catch
      end

      if ~isempty(pet_plot_allerr_pos) & strcmp(save_setting_status,'on')

         pos = pet_plot_allerr_pos;

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
	'user','Correlation Overview', ...
	'color', [0.8 0.8 0.8], ...
	'deleteFcn', 'pet_plot_allerr(''delete_fig'');', ...
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

   plot_allerr;

   return; 						% init


%--------------------------------------------------------------

function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      pet_plot_allerr_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'pet_plot_allerr_pos');
   catch
   end

   h0 = getappdata(gcbf,'main_fig');

   if ishandle(h0)
      setappdata(h0,'PlotAllerrState',0);
      hm_allerr = findobj(h0,'Tag','AllerrMenu');
      set(hm_allerr,'Label','Show &Correlation Overview');
   end

   return;						% delete_fig


%--------------------------------------------------------------

function plot_allerr;

      tit_fn = getappdata(gcbf,'tit_fn');
      tit = ['Correlation Overview Plot  [', tit_fn, ']'];
      set(gcf,'name',tit);

      num_beh = length(getappdata(gcbf, 'behavname'));
      num_cond_lst = getappdata(gcbf, 'num_cond_lst');
      num_subj_lst = getappdata(gcbf, 'num_subj_lst');
      num_grp = length(num_subj_lst);
      lv_idx = find(getappdata(gcbf,'CurrLVState'));
      num_conds = num_cond_lst(1);

      selected_conditions = getappdata(gcbf, 'selected_conditions');

      %  solve wrong label problem for bfm/fmri
      %
      if max(selected_conditions) == 1
         selected_conditions = find(selected_conditions);
      end

      conditions = getappdata(gcbf, 'Conditions');
      conditions = conditions(selected_conditions);

      boot_result = getappdata(gcbf,'boot_result');
      lvcorrs = getappdata(gcbf,'lvcorrs');

      if isempty(boot_result)
         orig_corr = lvcorrs;
         ulcorr = [];
         llcorr = lvcorrs;

%         min_y = min(orig_corr(:));		max_y = max(orig_corr(:));
      else
         orig_corr = boot_result.orig_corr;
         ulcorr = boot_result.ulcorr;
         llcorr = boot_result.llcorr;

         min_y = min(llcorr(:));		max_y = max(ulcorr(:));
      end

      if isempty(ulcorr)
         llcorr = llcorr - orig_corr;
         ulcorr = [];
      else
         llcorr = llcorr - orig_corr;
         ulcorr = ulcorr - orig_corr;
      end

      min_x = 0.5;				max_x = size(orig_corr,1)+0.5;
%      min_y = min(orig_corr(:));		max_y = max(orig_corr(:));
      min_y = -1;				max_y = 1;

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
		orig_corr((g-1)*num_beh*num_conds + [1:num_beh] + num_beh*(k-1), ...
			lv_idx));
            set(bar_hdl,'facecolor',color_code(k,:));
         end
      end

      if ~isempty(conditions),

         % remove the old legend to avoid the bug in the MATLAB5
         old_legend = getappdata(gcbf,'LegendHdl4');
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
         setappdata(gcbf,'LegendHdl4',[{l_hdl} {o_hdl}]);

      else

         setappdata(gcbf,'LegendHdl3',[]);

      end;

      if ~isempty(ulcorr)

         range = [];

         for g=1:num_grp
            for k=1:num_conds
               range = [range (g-1)*num_beh*num_conds + [1:num_beh] + num_beh*(k-1)];
            end
         end

         h2 = errorbar(range, orig_corr(range,lv_idx), abs(llcorr(range,lv_idx)), ulcorr(range,lv_idx), 'ok');

      end

      hold off;

      axis([min_x,max_x,min_y-margin_y,max_y+margin_y]);

      set(gca,'tickdir','out','ticklength', [0.005 0.005], ...
		'box','on');
      ylabel('Correlations');

      grid on;

      set(gca,'xtick',([1:num_grp] - 1) * num_beh*num_conds + 0.5);
      set(gca,'xticklabel',1:num_grp);

      xlabel('Groups');

      return;

