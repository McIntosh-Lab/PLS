% draw subplot for selected channels in the calling figure
% h0 is the handle of calling figure
%
%----------------------------------------------------------

function h01 = erp_detailplot_ui(varargin)

   h01 = [];

   if nargin == 0

      h0 = gcbf;					% main figure
      chan_name_hdl = getappdata(h0, 'chan_name_hdl');
      selected_chan_idx = getappdata(gcf,'selected_chan_idx');
      selected_chan_list = [];
      selected_chan_name = [];

      for i=selected_chan_idx

         % collect selected list
         %
         if strcmp(get(chan_name_hdl(i),'fontweight'), 'bold')
            selected_chan_list = [selected_chan_list i];
            selected_chan_name = ...
		[selected_chan_name {get(chan_name_hdl(i),'string')}]; 
         end

      end

      if isempty(selected_chan_list)	% nothing to display
         hm_detail = getappdata(h0,'hm_detail');
         set(hm_detail, 'userdata',0, 'check','off');
         msg = 'At least one channel must be selected.';
         uiwait(msgbox(msg,'ERROR','modal'));
         return;
      end

%      set(h0,'visible','off');

      [tmp tit_fn] = rri_fileparts(get(gcf,'name'));
      h01 = init(h0, selected_chan_list, selected_chan_name, tit_fn);

      return

   end

   action = varargin{1};

   if strcmp(action,'zoom')			% zoom menu clicked
      zoom_on_state = get(gcbo,'Userdata');
      if (zoom_on_state == 1)			% zoom on
         zoom on;
         set(gcbo,'Userdata',0,'Label','&Zoom off');
         set(gcf,'pointer','crosshair');
      else					% zoom off
         zoom off;
         set(gcbo,'Userdata',1,'Label','&Zoom on');
         set(gcf,'pointer','arrow');
      end
   elseif (strcmp(action,'crosshair'))
      crosshair;
   elseif (strcmp(action,'set_xhair_color'))
      set_xhair_color;
   elseif strcmp(action,'gps')
      gps;
   elseif strcmp(action,'de_gps')
      de_gps;
   elseif strcmp(action,'point2txt')
      point2txt;
   elseif strcmp(action,'delete_fig')
      delete_fig;
   end

   return;


%-----------------------------------------------------------
function h02 = init(h0, selected_chan_list, selected_chan_name, tit_fn)

   %------------------------- figure ----------------------

   tit = ['Detail Plot  [', tit_fn, ']'];

   save_setting_status = 'on';
   erp_detailplot_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(erp_detailplot_pos) & strcmp(save_setting_status,'on')

      pos = erp_detailplot_pos;

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
        'user', 'Detail Plot', ...
	'name', tit, ...
        'deleteFcn','erp_detailplot_ui(''delete_fig'');', ...
        'tag','detail_fig', ...
        'position', pos);

%        'windowbuttondown','erp_detailplot_ui(''gps'');',...

   %  file menu
   %
   rri_file_menu(h02);

   %  xhair
   %
   h_xhair = uimenu('parent',h02, ...
        'label','Crosshair');
   h_xhair_view = uimenu('parent',h_xhair, ...
        'userdata', 0, ...
        'callback','erp_detailplot_ui(''crosshair'');', ...
        'label','Crosshair off');
   h_xhair_color = uimenu('parent',h_xhair, ...
        'userdata', [1 0 0], ...
        'callback','erp_detailplot_ui(''set_xhair_color'');', ...
        'label','Color ...');

   %  zoom
   %
   h1 = uimenu('parent',h02, ...
        'userdata', 1, ...
        'callback','erp_detailplot_ui(''zoom'');', ...
        'label','&Zoom on');

   %  point2txt
   %
   h_point2txt = uimenu('parent',h02, ...
        'callback','erp_detailplot_ui(''point2txt'');', ...
        'visible', 'off', ...
        'label','point2txt');

   % calculate layout
   %
   num_selected = length(selected_chan_list);
   c = ceil(sqrt(num_selected));		% amount cols for subplot
   r = ceil(num_selected/c);			% amount rows for subplot

   if c==2 & r==1				% only 2 channels selected
      c=2; r=2;					% make it square
   end

   view_option = getappdata(h0,'view_option');	% what was plotted
   switch view_option
      case {1}                               %  subj
         ylabel = ['ERP Amplitude' ' (\muV)'];
      case {2}                               %  avg
         ylabel = ['Average Amplitude' ' (\muV)'];
      case {3}                               %  salience
         ylabel = 'Electrode Salience';
      case {4}                               %  grp
         ylabel = ['Subject Amplitude' ' (\muV)'];
         set(h_point2txt, 'visible', 'on');
      case {5}                               %  correlation
         ylabel = 'Correlation';
   end
   xlabel = '        Time (ms)';

   selected_wave_idx = getappdata(h0,'selected_wave_idx');
   selected_avg_idx = getappdata(h0,'selected_avg_idx');
   selected_bs_idx = getappdata(h0,'selected_bs_idx');
   wave_amplitude = getappdata(h0,'wave_amplitude');
   avg_amplitude = getappdata(h0,'avg_amplitude');
   bs_x_amplitude = getappdata(h0,'bs_x_amplitude');
   bs_y_amplitude = getappdata(h0,'bs_y_amplitude');
   selected_wave_name = getappdata(h0,'selected_wave_name');
   selected_avg_name = getappdata(h0,'selected_avg_name');
   selected_bs_name = getappdata(h0,'selected_bs_name');
   init_option = getappdata(h0,'init_option');
   color_code1 = init_option.color_code1;
   color_code2 = init_option.color_code2;
   color_code3 = init_option.color_code3;
   avg_max = init_option.avg_max;
   avg_min = init_option.avg_min;
   wave_top = init_option.wave_top;
   wave_bottom = init_option.wave_bottom;
   timepoint = init_option.timepoint;
   start_timepoint = init_option.start_timepoint;
   digit_interval = init_option.digit_interval;
   num_cond = size(selected_wave_name,1);
   num_avg = size(selected_avg_name,1);

   x_wave = (start_timepoint:(start_timepoint+timepoint-1)) ...
		*digit_interval;

   ax_hdl = [];
   wave_hdl = [];
   bs_wave_hdl = [];

   for i=1:num_selected

      subplot(r,c,i);

      ax_hdl(i) = gca;
      pos = get(gca,'position');
      xy = pos(1:2);
      wh = pos(3:4);
      wh = wh .* .8;
      pos = [xy,wh];
      set(gca,'position',pos);

      set(gca, 'xgrid', 'on', 'ygrid', 'on', 'box', 'on', ...
	'buttondown','erp_detailplot_ui(''de_gps'');', 'user', [], ...
	'xlim', [start_timepoint, (start_timepoint+timepoint-1)] ...
		* digit_interval, ...
	'ylim', [wave_bottom, wave_top]);

      set(get(gca,'xlabel'), 'string', [selected_chan_name{i} xlabel]);
      set(get(gca,'ylabel'), 'string', ylabel);
      hold on

      seq_idx = 1;
%      for j=1:num_avg
      for j=selected_avg_idx
         y_wave = avg_amplitude(:,selected_chan_list(i),j);
         avg_wave_hdl(i,j) = plot(x_wave, y_wave, color_code1(seq_idx,:), ...
				'linewidth', 2, 'userdata', [seq_idx, i]);
         seq_idx = seq_idx + 1;
      end

      seq_idx = 1;
      for j=selected_wave_idx
         y_wave = wave_amplitude(:,selected_chan_list(i),j);
         wave_hdl(i,j) = plot(x_wave, y_wave, color_code2(seq_idx,:), ...
				'buttondown','erp_detailplot_ui(''gps'');', ...
				'userdata', [seq_idx, i]);
         seq_idx = seq_idx + 1;
      end

      seq_idx = 1;
      for j=selected_bs_idx

         x_mask = bs_x_amplitude(:,selected_chan_list(i),j);
         x_mask = find(x_mask)';

         if ~isempty(x_mask)
            bs_x_wave = x_wave(x_mask);

            bs_y_wave = bs_y_amplitude(:,selected_chan_list(i),j);
            bs_y_wave = (bs_y_wave(x_mask) + ...
			wave_bottom/(wave_top-wave_bottom)) ...
			* (wave_top-wave_bottom) * 0.9;
            bs_wave_hdl(i,j) = plot(bs_x_wave,bs_y_wave,color_code3(seq_idx,:), ...
				'userdata', [seq_idx, i]);
         else
            bs_wave_hdl(i,j) = 99999;
         end

         seq_idx = seq_idx + 1;

      end

      hold off

   end

   setappdata(h02, 'selected_chan_name', selected_chan_name);
   setappdata(h02, 'ax_hdl', ax_hdl);
   setappdata(h02, 'h_xhair_view', h_xhair_view);
   setappdata(h02, 'h_xhair_color', h_xhair_color);
   setappdata(h02, 'wave_hdl', wave_hdl);
   setappdata(h02, 'bs_wave_hdl', bs_wave_hdl);
   setappdata(h02, 'xlim', [start_timepoint, (start_timepoint+timepoint-1)] ...
		* digit_interval);
   setappdata(h02, 'ylim', [wave_bottom, wave_top]);

   return;						% init


%--------------------------------------------------------------
function gps

   de_gps;

   user = get(gco,'user');
   main_fig = getappdata(gcf,'main_fig');
   selected_chan_name = getappdata(gcf, 'selected_chan_name');
   selected_wave_name = getappdata(main_fig,'selected_wave_name');

   chan_name = selected_chan_name{user(2)};
   wave_name = selected_wave_name(user(1),:);

   xlim = get(gca,'xlim');			% current xy limitation
   ylim = get(gca,'ylim');

   loc = get(gca,'CurrentPoint');		% get location
   loc_xy = loc(1,1:2);

   if loc_xy(1) >= xlim(1) & loc_xy(1) <= xlim(2) & ...
      loc_xy(2) >= ylim(1) & loc_xy(2) <= ylim(2)

      rri_txtbox(gca, 'Wave', wave_name, 'Channel', chan_name, ...
         'X', num2str(loc_xy(1)), 'Y', num2str(loc_xy(2)));
      set(gco, 'selected', 'on');

      h = findobj(gcf,'tag', 'rri_txtbox');
      pos = get(h, 'position');
      p = get(gca, 'position');
      pos(1) = p(1)+p(3);
      pos(2) = p(2)+p(4);
      set(h, 'position', pos);
   end

   return;						% gps


%--------------------------------------------------------------
function de_gps

   h_xhair_view = getappdata(gcf,'h_xhair_view');
   h_xhair_color = getappdata(gcf,'h_xhair_color');

   if get(h_xhair_view,'user')
      visibility = 'off';
   else
      visibility = 'on';
   end

   wave_hdl = getappdata(gcf,'wave_hdl');
   main_fig = getappdata(gcf,'main_fig');
   selected_wave_idx = getappdata(main_fig,'selected_wave_idx');

   %  plot xhair
   %
   loc = get(gca, 'CurrentPoint');		% get location
   loc_xy = loc(1,1:2);

   xhair = rri_xhair(loc_xy, get(gca, 'user'));
   set(xhair.lx, 'xdata', getappdata(gcf,'xlim'), 'visible', visibility, ...
	'color', get(h_xhair_color,'user'));
   set(xhair.ly, 'ydata', getappdata(gcf,'ylim'), 'visible', visibility, ...
	'color', get(h_xhair_color,'user'));
   set(gca, 'user', xhair);

   for i = 1:size(wave_hdl,1)
      for j=selected_wave_idx
         if wave_hdl(i,j)~=0 & ishandle(wave_hdl(i,j))
            set(wave_hdl(i,j), 'selected', 'off');
         end
      end
   end

   h = findobj(gcf,'tag', 'rri_txtbox');

   if ishandle(h)
      delete(h);
   end

   return;						% de_gps


%--------------------------------------------------------------
function point2txt

   if isempty(gco) | strcmp(lower(get(gco,'selected')), 'off')
      return;
   end

   user = get(gco,'user');
   main_fig = getappdata(gcf,'main_fig');
   selected_chan_name = getappdata(gcf, 'selected_chan_name');
   selected_wave_name = getappdata(main_fig,'selected_wave_name');

   chan_name = selected_chan_name{user(2)};
   wave_name = selected_wave_name(user(1),:);

   loc = get(gca,'CurrentPoint');		% get location
   loc_xy = num2str(loc(1,1:2));

   filename = getappdata(main_fig, 'datamat_file');
   filename = strrep(filename, '_ERPresult.mat', '_ERPdetail.txt');

   str = [wave_name, '  ', chan_name, '  ', loc_xy];

   fid = fopen(filename, 'at');

   if fid == -1
      msg = ['File ', filename, ' can not be open to write'];
      msgbox(msg, 'Error');
      return;
   end

   fprintf(fid, '%s\n', str);
   fclose(fid);

   return;						% point2txt


%--------------------------------------------------------------
function crosshair

   xhair_on_state = get(gcbo,'Userdata');

   if (xhair_on_state == 1)
      set(gcbo,'Userdata',0,'Label','Crosshair off');
      visibility = 'on';           
   else
      set(gcbo,'Userdata',1,'Label','Crosshair on');
      visibility = 'off';           
   end;

   ax_hdl = getappdata(gcf,'ax_hdl');

   for i = 1:length(ax_hdl)
      xhair = get(ax_hdl(i),'user');

      if isstruct(xhair) & ishandle(xhair.lx) & ishandle(xhair.ly)
         set(xhair.lx,'visible',visibility);
         set(xhair.ly,'visible',visibility);
      end
   end

   return;						% crosshair


%--------------------------------------------------------------
function set_xhair_color

   ax_hdl = getappdata(gcf,'ax_hdl');
   old_color = get(gcbo,'user');
   new_color = uisetcolor(old_color);
   set(gcbo,'user',new_color);

   for i = 1:length(ax_hdl)
      xhair = get(ax_hdl(i),'user');

      if isstruct(xhair) & ishandle(xhair.lx) & ishandle(xhair.ly)
         set(xhair.lx,'color',new_color);
         set(xhair.ly,'color',new_color);
      end
   end

   return;						% set_xhair_color


%--------------------------------------------------------------
function delete_fig

%
% close detail fig & enable main_fig
%

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      erp_detailplot_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'erp_detailplot_pos');
   catch
   end

   h0 = getappdata(gcbf,'main_fig');
   hm_detail = getappdata(h0,'hm_detail');
   set(hm_detail, 'userdata',0, 'check','off');

   return;						% delete_fig

