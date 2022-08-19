% draw subplot for selected channels in the calling figure
% h0 is the handle of calling figure
%
%----------------------------------------------------------

function h01 = pet_plot_detail_stim_ui(action,varargin)

   if strcmp(action,'STARTUP')
      h0 = gcbf;
      h01 = init(h0,varargin{1},varargin{2},varargin{3}, ...
		varargin{4},varargin{5},varargin{6});
   elseif strcmp(action,'fig_bt_dn')
      fig_bt_dn;
   elseif strcmp(action,'select_subj')
      select_subj;
   elseif strcmp(action,'delete_fig')
      delete_fig;
   end

   return;


%-----------------------------------------------------------
%
function h02 = init(h0,st_data,condition,axes_margin,plot_dims,cond_idx,tit)

   save_setting_status = 'on';
   pet_detailplot_pos = [];


   pet_detail_user = [];
   try
      pet_detail_user = get(getappdata(gcf,'pet_detail_hdl'),'user');
   catch
   end

   if ~isempty(pet_detail_user) & strcmp(pet_detail_user,'PET Detail Plot')

      h02 = getappdata(gcf,'pet_detail_hdl');
      figure(h02);

   else

      try
         load('pls_profile');
      catch
      end

      if ~isempty(pet_detailplot_pos) & strcmp(save_setting_status,'on')

         pos = pet_detailplot_pos;

      else

         w = 0.9;
         h = 0.8;
         x = (1-w)/2;
         y = (1-h)/2;

         pos = [x y w h];

      end

      xp = 0.0227273;
      yp = 0.0294118;
      wp = 1-2*xp;
      hp = 1-2*yp;

      pos_p = [xp yp wp hp];

      h02 = figure('unit','normal', ...
        'paperunit','normal', ...
        'paperorient','land', ...
        'paperposition',pos_p, ...
        'papertype','usletter', ...
        'numberTitle','off', ...
        'menubar', 'none', ...
        'toolbar','none', ...
        'user', 'PET Detail Plot', ...
	'name', [tit, ' plot per LV'], ...
        'deleteFcn','ssb_pet_plot_detail_stim_ui(''delete_fig'');', ...
        'tag','detail_fig', ...
        'position', pos);

      %  file menu
      %
      rri_file_menu(h02);

   end

   cond_name = condition.cond_name;
   subj_name = condition.subj_name;

   plotmarkercolour=[
      'bo';'rd';'g<';'m>';'bs';'rv';'g^';'mp';'bh';'rx';'g+';'m*';
      'ro';'gd';'m<';'b>';'rs';'gv';'m^';'bp';'rh';'gx';'m+';'b*';
      'go';'md';'b<';'r>';'gs';'mv';'b^';'rp';'gh';'mx';'b+';'r*';
      'mo';'bd';'r<';'g>';'ms';'bv';'r^';'gp';'mh';'bx';'r+';'g*'];

   if length([condition.subj_name{:}])>length(plotmarkercolour)  % need more color

      tmp = [];

      for i=1:ceil( length([condition.subj_name{:}])/length(plotmarkercolour) )
         tmp = [tmp; plotmarkercolour];
      end

      plotmarkercolour = tmp;

   end

   linc_wave = st_data.linc_wave;
   brain_wave = st_data.brain_wave;
   behav_wave = st_data.behav_wave;
   behavname = st_data.behavname;
   strong_r = st_data.strong_r;

   brainscores = getappdata(gcbf, 'brainscores');
   behavdata = getappdata(gcbf, 'behavdata');
%   min_x = min(behavdata(:));		max_x = max(behavdata(:));
   min_y = min(brainscores(:));		max_y = max(brainscores(:));
%   margin_x = abs((max_x - min_x) / 20);
   margin_y = abs((max_y - min_y) / 20);

   numbehav = size(behav_wave, 2);
   num_conds = size(behav_wave, 3);

   num_selected = numbehav * num_conds;
   c = ceil(sqrt(num_selected));		% amount cols for subplot
   r = ceil(num_selected/c);			% amount rows for subplot

   if c==2 & r==1				% only 2 channels selected
      c=2; r=2;					% make it square
   end

   for i=1:numbehav

      per_behav = [];

      for j=1:num_conds
         numsubj = length(condition.subj_name{j});
         tmp_per_behav = behav_wave(1:numsubj,i,j);
         per_behav = [per_behav; tmp_per_behav(:)];
      end					% for j=1:num_conds

      min_x = min(per_behav(:));		max_x = max(per_behav(:));
      margin_x = abs((max_x - min_x) / 20);

      for j=1:num_conds

         numsubj = length(condition.subj_name{j});
         subj_name = condition.subj_name{j};

         k=(i-1)*num_conds + j;
         subplot(r,c,k);

         pos = get(gca,'position');
         xy = pos(1:2);
         w = pos(3);
         h = pos(4);
         w = w * .9;
         h = h * .6;
         pos = [xy,w,h];
         set(gca,'position',pos);

         set(gca, 'xgrid', 'on', 'ygrid', 'on', 'box', 'on');
         set(gca,'buttondown','ssb_pet_plot_cond_stim_ui(''fig_bt_dn'');');

%         set(get(gca,'xlabel'), 'string', ['Behavior Name: ', behavname{i}]);

         set(get(gca,'ylabel'), 'string', tit);

         task_tit{1} = ['Behavior Name: ', behavname{i}];
         task_tit{2} = ['Task Name: ', cond_name{j}];
         LV = num2str(find(getappdata(gcbf, 'CurrLVState')));
         task_tit{3} = ['LV=',LV,',  r=',num2str(strong_r(1,i,j),2)];
         set(get(gca,'title'), 'string', task_tit);

         hold on;

         plot(behav_wave(1:numsubj,i,j), linc_wave(1:numsubj,i,j));

         for n=1:length(subj_name)

            score_hdl(i,j,n) = plot(behav_wave(n,i,j), ...
		brain_wave(n,1,j),plotmarkercolour(n,:), ...
		'MarkerSize',10, 'userdata', [n j], 'buttondown', ...
		'ssb_pet_plot_detail_stim_ui(''select_subj'');');

         end

         axis([min_x-margin_x, max_x+margin_x, min_y-margin_y, max_y+margin_y]);

         hold off;

      end
   end

   tit_fn = getappdata(gcbf,'tit_fn');

   if isempty(findstr(tit_fn, 'ERPresult.mat'))			% brain scores
      tit = ['Brain Scores Overview  [', tit_fn, ']'];
      setappdata(gcf, 'is_erp', 0);
   else								% scalp scores
      tit = ['Scalp Scores Overview  [', tit_fn, ']'];
      setappdata(gcf, 'is_erp', 1);
   end

   set(gcf,'name',tit);

   setappdata(gcf, 'score_hdl', score_hdl);
   setappdata(gcf,'ST_data',st_data);
   setappdata(gcf,'ST_condition',condition);
   setappdata(gcf,'PlotCondIdx',cond_idx);
   setappdata(gcf,'PlotDims',plot_dims);

   return;


%--------------------------------------------------------------
%
function delete_fig

   is_erp = getappdata(gcbf,'is_erp');

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      pet_detailplot_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'pet_detailplot_pos');
   catch
   end

   h0 = getappdata(gcbf,'main_fig');

   if ishandle(h0)
      setappdata(h0,'PlotDetailState',0);
      hm_detail = findobj(h0,'Tag','DetailMenu');

      if is_erp
         set(hm_detail,'Label','Show &Scalp Scores Overview');
      else
         set(hm_detail,'Label','Show &Brain Scores Overview');
      end
   end

   return;						% delete_fig


%-----------------------------------------------------------
%
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
%
function select_subj

   % don't do anything if we're supposed to be zooming
   tmp = zoom(gcf,'getmode');
   if (isequal(tmp,'in') | isequal(tmp,'on')), return; end

   score_hdl = getappdata(gcf,'score_hdl');

   st_data = getappdata(gcf,'ST_data');
   condition = getappdata(gcf,'ST_condition');

   subj_name = condition.subj_name;

   behav_wave = st_data.behav_wave;
   numbehav = size(behav_wave, 2);
   num_conds = size(behav_wave, 3);

   for i=1:length(score_hdl(:))
      set(score_hdl(i), 'selected', 'off');		% remove selection
   end

   n = get(gco, 'userdata');
   c = n(2);
   n = n(1);

   for i=1:numbehav
         set(score_hdl(i,c,n),'selected','on');
   end

   txtbox_hdl = rri_txtbox(gca, 'Subject Name', subj_name{c}{n});
   setappdata(gcf, 'txtbox_hdl', txtbox_hdl);

   return;					% select_subj

