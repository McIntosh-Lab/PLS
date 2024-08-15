%ERP_SHOWPLOT_UI display ERP waveforms on a figure
%
%  USAGE: erp_showplot_ui(fig)
%
%   ERP_SHOWPLOT_UI(fig) will display ERP waveforms on 'fig'.
%

%   Called by ERP_PLOT_UI, ERP_PLOT_OPTION_UI
%
%   I (fig) - figure where ERP waveform will be displayed on
%
%   Created on 25-NOV-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function erp_showplot_ui(fig)

   if ~exist('fig','var')
      fig = gcf;
   end

   system = getappdata(fig,'system');
   time_info = getappdata(fig,'time_info');

   timepoint = round(time_info.timepoint);
   start_timepoint = floor(time_info.start_timepoint);
   start_time = time_info.start_time;
   end_time = time_info.end_time;
   digit_interval = time_info.digit_interval;
   prestim = time_info.prestim;

   init_option = getappdata(fig,'init_option');

   if isempty(init_option)
      init_flag = 1;
   else
      init_flag = 0;
   end

   ha = getappdata(fig,'ha');			% main axes
   hm_chan_name = getappdata(fig,'hm_chan_name');
   need_chan_name = get(hm_chan_name,'userdata');
   hm_chan_axes = getappdata(fig,'hm_chan_axes');
   need_chan_axes = get(hm_chan_axes,'userdata');
   hm_chan_tick = getappdata(fig,'hm_chan_tick');
   need_chan_tick = get(hm_chan_tick,'userdata');

   font_size_list = [6 8 10 11 12 14 16 18];

   if(init_flag)				%% if first time run showplot

      % close detail window particularly for rescale
      %
      hm_detail = getappdata(fig,'hm_detail');
      set(hm_detail, 'userdata',0, 'check','off');

      try
         detail_fig_name = get(getappdata(gcf,'detail_fig'),'user');
         if ~isempty(detail_fig_name) & strcmp(detail_fig_name,'Detail Plot')
            close(getappdata(gcf,'detail_fig'));
         end
      catch
      end

      %  delete possible old_legend
      %
      old_legend_hdl = getappdata(fig,'legend_hdl');
      if ~isempty(old_legend_hdl)
         try
            delete(old_legend_hdl{1});
            hm_legend = getappdata(fig,'hm_legend');
            setappdata(fig,'legend_hdl',[]);
            set(hm_legend,'Userdata',1,'Label','&Legend on');
         catch
         end
      end

      old_txtbox_hdl = getappdata(fig,'txtbox_hdl');
      if ~isempty(old_txtbox_hdl)
         try
            delete(old_txtbox_hdl);
            setappdata(fig,'txtbox_hdl',[]);
         catch
         end
      end

      view_option = getappdata(fig,'view_option');
      color_code = getappdata(fig,'color_code');	% color & linestyle
      bs_color_code = getappdata(fig,'bs_color_code');

      wave_selection = getappdata(fig,'wave_selection');
      avg_selection = getappdata(fig,'avg_selection');
      bs_selection = getappdata(fig,'bs_selection');

      wave_selection(find(wave_selection==0)) = [];
      avg_selection(find(avg_selection==0)) = [];
      bs_selection(find(bs_selection==0)) = [];

      color_selection = 1:(length(wave_selection)+length(avg_selection));
      bs_color_selection = 1:length(bs_selection);

      if length(color_selection) > length(color_code)	% need more color

         tmp = [];

         for i=1:ceil( length(color_selection)/length(color_code) )
            tmp = [tmp; color_code];
         end

         color_code = tmp;

      end

      if length(bs_color_selection)>length(bs_color_code)  % need more color

         tmp = [];

         for i=1:ceil( length(bs_color_selection)/length(bs_color_code) )
            tmp = [tmp; bs_color_code];
         end

         bs_color_code = tmp;

      end

      x_interval_selection = getappdata(fig,'x_interval_selection');
      y_interval_selection = getappdata(fig,'y_interval_selection');

      %  display wave size scale, from 0.05 to 1, 1 means full screen
      %
      eta = getappdata(fig,'eta');

      %  font size
      %
      font_size = font_size_list(getappdata(fig,'font_size_selection'));

      color_code1 = color_code(1:length(avg_selection),:);
      color_code2 = color_code((length(avg_selection)+1): ...
				length(color_selection),:);
      color_code3 = bs_color_code(1:length(bs_selection),:);

      wave_amplitude = getappdata(fig,'brain_amplitude'); % input wave

      rescale = getappdata(fig,'rescale'); % Scale by Singular Value
      s = getappdata(fig,'s'); % Singular Value

      if rescale
         for i=1:length(s)
            wave_amplitude(:,:,i) = wave_amplitude(:,:,i).*s(i);
         end
      end

      wave_name = getappdata(fig,'wave_name');		% wave legend

      selected_wave_info = getappdata(fig,'selected_wave_info');
			% [condition(selected), subjects(selected)]

      selected_wave = getappdata(fig,'selected_wave');	% based on
					% selected_cond & selected_subj
      selected_wave_idx = selected_wave(wave_selection);

      selected_channels = getappdata(fig,'selected_channels');
      selected_chan_idx = find(selected_channels);

      wave_disp = wave_amplitude(:,selected_chan_idx,selected_wave_idx);

      selected_wave_name = wave_name(selected_wave_idx);
      selected_wave_name = char(selected_wave_name);	% legend string
      num_wave = size(selected_wave_name,1);		% # of wave to display

      avg_amplitude = getappdata(fig,'avg_amplitude');	% input avg
      avg_name = getappdata(fig,'avg_name');		% avg legend

      if ~isempty(avg_amplitude)
         selected_avg = find(getappdata(fig,'selected_conditions'));
         selected_avg_idx = selected_avg(avg_selection);
         avg_disp = avg_amplitude(:,selected_chan_idx,selected_avg_idx);
         selected_avg_name = avg_name(selected_avg_idx);
      else
         selected_avg = [];
         selected_avg_idx = [];
         avg_disp = [];
         selected_avg_name = [];
      end

      selected_avg_name = char(selected_avg_name);
      num_avg = size(selected_avg_name,1);

      bs_amplitude = getappdata(fig,'bs_amplitude');	% input bootstrap
      bs_name = getappdata(fig,'bs_name');		% bs legend

      if ~isempty(bs_amplitude)

         bs_x_amplitude = bs_amplitude;
         selected_bs = getappdata(fig,'selected_bs');	% 1 to lv
         num_lv = length(selected_bs);

         % re-order the LV sequence, so that LV1 will be put on top,
         % LV2 will be put on bottom, LV3 will be put next top, ...
         %
         bs_y_amplitude = [];
         for i = 1:ceil(num_lv / 2)
            bs_y_amplitude = [bs_y_amplitude, num_lv-i+1];
            if (num_lv - i + 1) ~= i
               bs_y_amplitude = [bs_y_amplitude, i];
            end
         end

         % normalize the new order, and reshape it to the required
         % y direction vector for bootstrap
         %
         if num_lv > 1
            bs_y_amplitude = (bs_y_amplitude - 1) / (num_lv - 1);
         end;

         bs_y_amplitude = reshape(bs_y_amplitude, [1,1,num_lv]);
         bs_y_amplitude = repmat(bs_y_amplitude, ...
				[timepoint, size(bs_amplitude, 2)]);

         selected_bs_idx = selected_bs(bs_selection);
         selected_bs_name = bs_name(selected_bs_idx);

      else
         bs_y_amplitude = [];
         selected_bs_idx = [];
         bs_x_amplitude = [];
         selected_bs_name = [];
      end

      selected_bs_name = char(selected_bs_name);
      num_bs = size(selected_bs_name,1);

      if ~isempty(wave_disp)
         wave_max = max(wave_disp(:));
         wave_min = min(wave_disp(:));
      else
         wave_max = 0;
         wave_min = 0;
      end

      if ~isempty(avg_disp)
         avg_max = max(avg_disp(:));
         avg_min = min(avg_disp(:));
      else
         avg_max = 0;
         avg_min = 0;
      end

      wave_top = max(double(wave_max), double(avg_max));	% top end of y axis
      if wave_max < 0
         wave_top = 0;
      end

      wave_bottom = min(double(wave_min), double(avg_min));	% bottom end of y axis
      if wave_min > 0
         wave_bottom = 0;
      end

      if wave_top + wave_bottom == 0
         msg = 'ERROR: No wave to display.';
         uiwait(msgbox(msg,'ERROR','modal'));
         return;
      end

      if view_option == 3
         north = [sprintf('%0.2f',wave_top)];
         south = [sprintf('%0.2f',wave_bottom)];
      else
         north = [sprintf('%0.2f',wave_top) ' \muV'];
         south = [sprintf('%0.2f',wave_bottom) ' \muV'];
      end

      west = sprintf('%d ms', start_timepoint * digit_interval);	
%      east = sprintf('%d ms', (start_timepoint+timepoint-1) * digit_interval);
      east = sprintf('%d ms', (start_timepoint+timepoint) * digit_interval);

      %  belows are 4 lines represent the channel axis
      %
      hor_x = [0 1];
      hor_y = [0 0];

      if start_timepoint < 0
         ver_x = ((-start_timepoint)/(timepoint-1)) * [1 1];
      else
         ver_x = [0 0];
      end

      ver_y = [wave_bottom wave_top] / (wave_top - wave_bottom);

      xtick_length = 1/40;

      if start_timepoint < 0
         xtick_x = ((-start_timepoint)/(timepoint-1)) * [1 1];
      else
         xtick_x = [0 0];
      end

      xtick_y = [-xtick_length xtick_length];

      ytick_length = 1/80;

      if start_timepoint < 0
         ytick_x = ((-start_timepoint)/(timepoint-1))+ ...
				[-ytick_length ytick_length];
      else
         ytick_x = [-ytick_length ytick_length];
      end

      ytick_y = [0 0];

      % ------------------- below: set waveform origin -------------

      switch system.class
         case 1
            type_str = 'BESAThetaPhi|EGI128|EGI256|EGI128_v2';

            switch system.type
               case 1
                  load('erp_loc_besa148');
               case 2
                  load('erp_loc_egi128');
               case 3
                  load('erp_loc_egi256');
               case 4
                  load('erp_loc_egi128_v2');
            end
         case 2
            type_str = 'CTF-150';

            switch system.type
               case 1
                  load('erp_loc_ctf150');
            end
      end

      x = chan_loc(:,1);
      y = chan_loc(:,2);

      min_x = min(x);	max_x = max(x);
      min_y = min(y);	max_y = max(y);

      % apply channel mask
      %
      chan_mask = getappdata(fig,'chan_mask');
      chan_nam = chan_nam(chan_mask,:);
      chan_loc = chan_loc(chan_mask,:);

      for i=selected_chan_idx
         x(i) = chan_loc(i,1);
         y(i) = chan_loc(i,2);
      end

      % normalize & shift x & y array
      %
      x = ((x-min_x) / (max_x-min_x))*0.95+0.05;
      y = ((y-min_y) / (max_y-min_y))*0.9;

      % ------------------- above: set waveform origin -------------

      % ------------------- below: start to draw axes & wave -------------

      if ~isempty(wave_disp) | ~isempty(avg_disp)  %  there is wave

         axes(ha); cla;
         hold on;

         %  create template for sub axis
         %
         axis_template = plot(hor_x,hor_y,'k-',ver_x,ver_y,'k-', ...
            'visible','off');
         xtick_template_hdl = plot(xtick_x,xtick_y,'k-', ...
            'visible','off');
         ytick_template_hdl = plot(ytick_x,ytick_y,'k-', ...
            'visible','off');

         % xtick
         %
         x_interval_pattern = [5 2 1];			% nice $ pattern
         x_interval = x_interval_pattern;

         while(x_interval(1) <= timepoint)
            x_interval = [x_interval_pattern.*10, x_interval];
            x_interval_pattern = x_interval_pattern.*10;
         end

         x_interval(find(x_interval > timepoint))=[];	% take out too large
         x_interval(1) = [];	% make large one close to half timepoint
         x_interval = x_interval .* digit_interval;	% become (ms)

         if isempty(x_interval_selection)	% default
            x_interval2 = x_interval(1);
         else
            x_interval2 = x_interval(x_interval_selection); 
         end

         xtick_start = ceil(start_time/x_interval2) * x_interval2;
         xtick_end = floor(end_time/x_interval2) * x_interval2;
         xtick_pos = [xtick_start:x_interval2:xtick_end];	% (ms)

         if xtick_start > 0
            xtick_pos = xtick_pos - start_time;		% shift y axis
         end

         xtick_pos = xtick_pos ./ digit_interval;	% point again

         xtick_template = [];

         % traverse x axis and put tick on
         %
         k = 1;

         for j = xtick_pos
            xtick_template(k,:) = copyobj_legacy(xtick_template_hdl, ha);
            set(xtick_template(k,:),'xdata', ...
               get(xtick_template(k,:),'xdata') ...
               + j/timepoint);

            if j==0
               set(xtick_template(k,:),'user','origin');
            end

            k = k + 1;
         end

         if isempty(j)
            j = 0;
         end

         % ytick
         %
         if abs(wave_top) > abs(wave_bottom)
            wave_long = abs(wave_top);
         else
            wave_long = abs(wave_bottom);
         end

         % choose [2 4 8] as divisor to determin ytick interval
         %
         y_interval(1) = rri_ceil(wave_long, 2);
         y_interval(2) = rri_ceil(wave_long, 4);
         y_interval(3) = rri_ceil(wave_long, 8);

         if isempty(y_interval_selection)	% interval not selected
            y_interval2 = y_interval(1);	% select 1st one
         else
            y_interval2 = y_interval(y_interval_selection);
         end

         ytick_start = ceil(wave_bottom/y_interval2) * y_interval2;
         ytick_end = floor(wave_top/y_interval2) * y_interval2;
         ytick_pos = [ytick_start:y_interval2:ytick_end];

         ytick_template = [];

         % traverse upper half of y axis and put tick on
         %
         k = 1;

         for j = ytick_pos
            ytick_template(k,:) = copyobj_legacy(ytick_template_hdl, ha);
            set(ytick_template(k,:),'ydata', ...
               get(ytick_template(k,:),'ydata') ...
               +j/(wave_top - wave_bottom));

            if j==0
               set(ytick_template(k,:),'user','origin');
            end

            k = k + 1;
         end

         %  create legend axis
         %
         offset = 0.08;			% legend axis offset to left
         offset2 = 0;			% legend axis offset to bottom
         offset3 = 0.01;		% axis label offset to axis

         laxis_hdl = copyobj_legacy(axis_template, ha);

         for j=1:2			% just for 2 axis line
            set(laxis_hdl(j), 'visible', 'on', ...
               'xdata',eta*get(laxis_hdl(j),'xdata') ...
               +offset, ...
               'ydata',eta*(get(laxis_hdl(j),'ydata') ...
               +abs(wave_bottom)/(abs(wave_bottom)+abs(wave_top))) ...
               +offset2);
         end

         %  create legend tickmark
         %
         if ~isempty(xtick_template)
            lxtick_hdl = copyobj_legacy(xtick_template, ha);
            for j=1:size(lxtick_hdl,1) % for all the components on xtick
               set(lxtick_hdl(j), 'visible', 'on', ...
                  'xdata',eta*get(lxtick_hdl(j),'xdata') ...
                  +offset, ...
                  'ydata',eta*(get(lxtick_hdl(j),'ydata') ...
                  +abs(wave_bottom)/(abs(wave_bottom)+abs(wave_top))) ...
                  +offset2);

               if strcmp(get(lxtick_hdl(j),'user'),'origin')
                  set(lxtick_hdl(j), 'visible', 'off');
               end

               % create legend tickmark label
               %
%               lxticklabel_x = get(lxtick_hdl(j),'xdata');
%               lxticklabel_x = lxticklabel_x(1);
%               lxticklabel_y = get(lxtick_hdl(j),'ydata');
%               lxticklabel_y = lxticklabel_y(1);
%               lxticklabel_hdl(j) = text(double(lxticklabel_x), double(lxticklabel_y), ...
%                  num2str(x_interval*j), ...
%                  'horizon', 'center', 'vertical', 'top', ...
%                  'fontsize',12,'clipping','on');
            end
         else
            lxtick_hdl = [];
         end
         if ~isempty(ytick_template)
            lytick_hdl = copyobj_legacy(ytick_template, ha);
            for j=1:size(lytick_hdl,1) % for all the components on ytick
               set(lytick_hdl(j), 'visible', 'on', ...
                  'xdata',eta*get(lytick_hdl(j),'xdata') ...
                  +offset, ...
                  'ydata',eta*(get(lytick_hdl(j),'ydata') ...
                  +abs(wave_bottom)/(abs(wave_bottom)+abs(wave_top))) ...
                  +offset2);

               if strcmp(get(lytick_hdl(j),'user'),'origin')
                  set(lytick_hdl(j), 'visible', 'off');
               end

               % create legend tickmark label
               %
%               lyticklabel_x = get(lytick_hdl(j),'xdata');
%               lyticklabel_x = lyticklabel_x(2);
%               lyticklabel_y = get(lytick_hdl(j),'ydata');
%               lyticklabel_y = lyticklabel_y(2);
%               lyticklabel_hdl(j) = text(double(lyticklabel_x), double(lyticklabel_y), ...
%                  num2str(y_interval2*j), ...
%                  'horizon', 'left', 'vertical', 'middle', ...
%                  'fontsize',12,'clipping','on');
            end
         else
            lytick_hdl = [];
         end

         %  create legend axis label
         %
         %--------------------------------

         % north
         %
         if start_timepoint < 0
            ltext_x = eta * ((-start_timepoint)/(timepoint-1)) + offset;
         else
            ltext_x = offset;
         end

         ltext_y = eta + offset2 + offset3;

         legend_text_hdl(1) = text(double(ltext_x),double(ltext_y), ...
            deblank(north), ...
            'horizon', 'center', 'vertical', 'bottom', ...
            'fontsize',font_size,'clipping','on');

         % south
         %
         if start_timepoint < 0
            ltext_x = eta * ((-start_timepoint)/(timepoint-1)) + offset;
         else
            ltext_x = offset;
         end

         ltext_y = offset2 - offset3;

         legend_text_hdl(2) = text(double(ltext_x),double(ltext_y), ...
            deblank(south), ...
            'horizon', 'center', 'vertical', 'top', ...
            'fontsize',font_size,'clipping','on');

         % east 
         %
         ltext_x = eta + offset + offset3; 
         ltext_y = eta * abs(wave_bottom)/(abs(wave_bottom) ...
            + abs(wave_top)) + offset2;

         legend_text_hdl(3) = text(double(ltext_x),double(ltext_y), ...
            deblank(east), ...
            'horizon', 'left', 'vertical', 'middle', ...
            'fontsize',font_size,'clipping','on');

         % west 
         %
         ltext_x = offset - offset3;
         ltext_y = eta * abs(wave_bottom)/(abs(wave_bottom) ...
            + abs(wave_top)) + offset2;

         legend_text_hdl(4) = text(double(ltext_x),double(ltext_y), ...
            deblank(west), ...
            'horizon', 'right', 'vertical', 'middle', ...
            'fontsize',font_size,'clipping','on');

         axis_hdl = [];
         xtick_hdl = [];
         ytick_hdl = [];
         selected_subjects = getappdata(fig,'selected_subjects');
         selected_conditions = getappdata(fig,'selected_conditions');

         %  create new waves, and save the handles
         %
         for i=selected_chan_idx

            %  draw sub axes
            %
            axis_hdl(:,i) = copyobj_legacy(axis_template, ha);

            for j=1:size(axis_hdl,1)	% for all the components on axis
               set(axis_hdl(j,i), ...
		'xdata',eta*get(axis_hdl(j,i),'xdata')+x(i), ...
		'ydata',eta*get(axis_hdl(j,i),'ydata')+y(i));
            end

            if ~isempty(xtick_template)
               xtick_hdl(:,i) = copyobj_legacy(xtick_template, ha);
               for j=1:size(xtick_hdl,1) % for all the components on xtick
                  set(xtick_hdl(j,i), ...
                     'xdata',eta*get(xtick_hdl(j,i),'xdata')+x(i), ...
                     'ydata',eta*get(xtick_hdl(j,i),'ydata')+y(i));

                  if strcmp(get(xtick_hdl(j,i),'user'),'origin')
                     set(xtick_hdl(j,i), 'visible', 'off');
                  end

               end
            end

            if ~isempty(ytick_template)
               ytick_hdl(:,i) = copyobj_legacy(ytick_template, ha);
               for j=1:size(ytick_hdl,1) % for all the components on ytick
                  set(ytick_hdl(j,i), ...
                     'xdata',eta*get(ytick_hdl(j,i),'xdata')+x(i), ...
                     'ydata',eta*get(ytick_hdl(j,i),'ydata')+y(i));

                  if strcmp(get(ytick_hdl(j,i),'user'),'origin')
                     set(ytick_hdl(j,i), 'visible', 'off');
                  end

               end
            end

            x_wave = eta * (0:timepoint-1)/(timepoint-1) + x(i);

            if num_avg ~= 0

               seq_idx = 1;

               for j = selected_avg_idx

                  y_wave = eta * ...
			avg_amplitude(:,i,j)/ ...
			(abs(wave_bottom)+abs(wave_top))+y(i);
                  avg_wave_hdl(i,j) = plot(x_wave, y_wave, ...
                     color_code1(seq_idx,:), ...
                     'linewidth', 2, ...
                     'userdata',[seq_idx,i]);

                  seq_idx = seq_idx + 1;

               end		% for selected_avg_idx
            else
               avg_wave_hdl = [];
            end

            if num_wave ~= 0

               seq_idx = 1;

               for j = selected_wave_idx

                  y_wave = eta * ...
                     wave_amplitude(:,i,j)/ ...
                        (abs(wave_bottom)+abs(wave_top))+y(i);
                  if view_option == 1
                     condition_num = selected_wave_info(j,1);
                     subject_num = selected_wave_info(j,2);
                  else
                     condition_num = [];
                     subject_num = [];
                  end

                  % wave_hdl(channel, wave)
                  % userdata [wave_sequence, channel, condition, subject]
                  %
                  wave_hdl(i,j) = plot(x_wave, y_wave, ...
                     color_code2(seq_idx,:), ...
                     'buttondown','erp_plot_ui(''select_wave'');',...
                     'userdata', [seq_idx, i, condition_num, subject_num]);

                  seq_idx = seq_idx + 1;

               end			% for num_wave
            else
               wave_hdl = [];
            end

            if num_bs ~= 0

               seq_idx = 1;

               for j = selected_bs_idx

                  x_mask = bs_x_amplitude(:,i,j);
                  x_mask = find(x_mask)';

                  if ~isempty(x_mask)

                     bs_x_wave = x_wave(x_mask);

                     bs_y_wave = bs_y_amplitude(:,i,j);
                     bs_y_wave = eta * (bs_y_wave(x_mask) - abs(wave_bottom) ...
			/ (abs(wave_bottom) + abs(wave_top))) ...
			+ y(i);

                     bs_wave_hdl(i,j) = plot(bs_x_wave, bs_y_wave, ...
                        color_code3(seq_idx,:), ...
			'markersize',6, ...
                        'userdata',[seq_idx,i]);

                  else
                     bs_wave_hdl(i,j) = 99999;
                  end

                  seq_idx = seq_idx + 1;

               end		% for selected_bs_idx
            else
               bs_wave_hdl = [];
            end

            %  create new chan_names, and save the handles
            %
   

            if start_timepoint < 0
               text_x = x + eta*((-start_timepoint)/(timepoint-1));
            else
               text_x = x;
            end

            text_y = y + eta*wave_top/(abs(wave_bottom)+abs(wave_top));

            chan_name_hdl(i) = text(double(text_x(i)),double(text_y(i)), ...
               deblank(chan_nam(i,:)), 'userdata', [0, i], ...
               'buttondown','erp_plot_ui(''select_chan_name'');', ...
               'horizon', 'center', 'vertical', 'bottom', ...
               'fontsize',font_size,'clipping','on','Interpreter','none');

         end			% for selected_chan_idx

         hold off;

         %  create plot title
         %
         switch view_option
            case {1}
               h_title=text(.03,.99,'ERP Amplitude', ...
			'fontsize',font_size, 'fontweight','bold','Interpreter','none');
            case {2}
               h_title=text(.03,.99,'Grand Average Amplitude', ...
			'fontsize',font_size, 'fontweight','bold','Interpreter','none');
            case {3}
               h_title=text(.03,.99,'Electrode Salience', ...
			'fontsize',font_size, 'fontweight','bold','Interpreter','none');
            case {4}
               h_title=text(.03,.99,'Group Subject Amplitude', ...
			'fontsize',font_size, 'fontweight','bold','Interpreter','none');
            case {5}
               h_title=text(.03,.99,'Spatiotemporal Correlations', ...
			'fontsize',font_size, 'fontweight','bold','Interpreter','none');
         end

         setappdata(fig,'axis_template',axis_template);
         setappdata(fig,'xtick_template',xtick_template);
         setappdata(fig,'ytick_template',ytick_template);
         setappdata(fig,'laxis_hdl',laxis_hdl);
         setappdata(fig,'lxtick_hdl',lxtick_hdl);
         setappdata(fig,'lytick_hdl',lytick_hdl);
         setappdata(fig,'ltext_x',ltext_x);
         setappdata(fig,'ltext_y',ltext_y);
         setappdata(fig,'legend_text_hdl',legend_text_hdl);
         setappdata(fig,'offset',offset);
         setappdata(fig,'offset2',offset2);
         setappdata(fig,'offset3',offset3);
         setappdata(fig,'axis_hdl',axis_hdl);
         setappdata(fig,'xtick_hdl',xtick_hdl);
         setappdata(fig,'ytick_hdl',ytick_hdl);
         setappdata(fig,'wave_hdl',wave_hdl);
         setappdata(fig,'avg_wave_hdl',avg_wave_hdl);
         setappdata(fig,'bs_wave_hdl',bs_wave_hdl);
         setappdata(fig,'chan_name_hdl',chan_name_hdl);
         setappdata(fig,'chan_nam',chan_nam);
         setappdata(fig,'h_title',h_title);
         setappdata(fig,'x_interval',x_interval);
         setappdata(fig,'y_interval',y_interval);
         setappdata(fig,'avg_amplitude',avg_amplitude);
         setappdata(fig,'wave_amplitude',wave_amplitude);
         setappdata(fig,'bs_x_amplitude',bs_x_amplitude);
         setappdata(fig,'bs_y_amplitude',bs_y_amplitude);
         setappdata(fig,'selected_wave_name',selected_wave_name);
         setappdata(fig,'selected_avg_name',selected_avg_name);
         setappdata(fig,'selected_bs_name',selected_bs_name);
         setappdata(fig,'selected_wave_idx',selected_wave_idx);
         setappdata(fig,'selected_avg_idx',selected_avg_idx);
         setappdata(fig,'selected_bs_idx',selected_bs_idx);
         setappdata(fig,'selected_chan_idx',selected_chan_idx);

      else		%  if there is NO wave

         setappdata(fig,'wave_hdl',[]);
         setappdata(fig,'avg_wave_hdl',[]);
         setappdata(fig,'bs_wave_hdl',[]);
         setappdata(fig,'legend_hdl',[]);
         setappdata(fig,'chan_name_hdl',[]);

         return;
      end		%  end of ~isempty(wave_disp) | ~isempty(avg_disp)

      init_option.color_code1 = color_code1;
      init_option.color_code2 = color_code2;
      init_option.color_code3 = color_code3;
      init_option.avg_max = avg_max;
      init_option.avg_min = avg_min;
      init_option.wave_max = wave_max;
      init_option.wave_min = wave_min;
      init_option.wave_top = wave_top;
      init_option.wave_bottom = wave_bottom;
      init_option.timepoint = timepoint;
      init_option.start_timepoint = start_timepoint;
      init_option.start_time = start_time;
      init_option.end_time = end_time;
      init_option.digit_interval = digit_interval;
      init_option.prestim = prestim;
      init_option.x = x;
      init_option.y = y;

      setappdata(fig,'init_option',init_option);


   else		%%%%%%%%%%%%%%%%%%%%% if NOT first time run showplot

      %++++++++++++++++++++++++++++++++++++++++++++++++

      init_option = getappdata(fig,'init_option');

      avg_max = init_option.avg_max;
      avg_min = init_option.avg_min;
      wave_max = init_option.wave_max;
      wave_min = init_option.wave_min;
      wave_top = init_option.wave_top;
      wave_bottom = init_option.wave_bottom;
      timepoint = round(init_option.timepoint);
      start_timepoint = floor(init_option.start_timepoint);
      x = init_option.x;
      y = init_option.y;

      orig_axis_hdl = getappdata(fig,'axis_template');
      orig_xtick_hdl = getappdata(fig,'xtick_template');
      orig_ytick_hdl = getappdata(fig,'ytick_template');
      laxis_hdl = getappdata(fig,'laxis_hdl');
      lxtick_hdl = getappdata(fig,'lxtick_hdl');
      lytick_hdl = getappdata(fig,'lytick_hdl');
      ltext_x = getappdata(fig,'ltext_x');
      ltext_y = getappdata(fig,'ltext_y');
      legend_text_hdl = getappdata(fig,'legend_text_hdl');
      offset = getappdata(fig,'offset');
      offset2 = getappdata(fig,'offset2');
      offset3 = getappdata(fig,'offset3');
      axis_hdl = getappdata(fig,'axis_hdl');
      xtick_hdl = getappdata(fig,'xtick_hdl');
      ytick_hdl = getappdata(fig,'ytick_hdl');
      wave_hdl = getappdata(fig,'wave_hdl');
      avg_wave_hdl = getappdata(fig,'avg_wave_hdl');
      bs_wave_hdl = getappdata(fig,'bs_wave_hdl');
      chan_name_hdl = getappdata(fig,'chan_name_hdl');
      h_title = getappdata(fig,'h_title');
      wave_amplitude = getappdata(fig,'wave_amplitude');
      avg_amplitude = getappdata(fig,'avg_amplitude');
      bs_x_amplitude = getappdata(fig,'bs_x_amplitude');
      bs_y_amplitude = getappdata(fig,'bs_y_amplitude');
      selected_wave_name = getappdata(fig,'selected_wave_name');
      selected_avg_name = getappdata(fig,'selected_avg_name');
      selected_bs_name = getappdata(fig,'selected_bs_name');
      selected_wave_idx = getappdata(fig,'selected_wave_idx');
      selected_avg_idx = getappdata(fig,'selected_avg_idx');
      selected_bs_idx = getappdata(fig,'selected_bs_idx');
      selected_chan_idx = getappdata(fig,'selected_chan_idx');
      eta = getappdata(fig,'eta');
      font_size = font_size_list(getappdata(fig,'font_size_selection'));

      num_wave = size(selected_wave_name,1);
      num_avg = size(selected_avg_name,1);
      num_bs = size(selected_bs_name,1);

      %  update legend axis
      %
      for j=1:size(laxis_hdl,1)    % for all the components on legend axis
         set(laxis_hdl(j), ...
            'xdata',eta*get(orig_axis_hdl(j),'xdata') ...
            +offset, ...
            'ydata',eta*(get(orig_axis_hdl(j),'ydata') ...
            +abs(wave_bottom)/(abs(wave_bottom)+abs(wave_top))) ...
            +offset2);
      end

      %  update legend tick marks
      %
      if ~isempty(orig_xtick_hdl)
         for j=1:size(lxtick_hdl,1)	% for all the components on legend xtick
            set(lxtick_hdl(j), ...
               'xdata',eta*get(orig_xtick_hdl(j),'xdata') ...
               +offset, ...
               'ydata',eta*(get(orig_xtick_hdl(j),'ydata') ...
               +abs(wave_bottom)/(abs(wave_bottom)+abs(wave_top))) ...
               +offset2);
         end
      end

      if ~isempty(orig_ytick_hdl)
         for j=1:size(lytick_hdl,1)	% for all the components on legend ytick
            set(lytick_hdl(j), ...
               'xdata',eta*get(orig_ytick_hdl(j),'xdata') ...
               +offset, ...
               'ydata',eta*(get(orig_ytick_hdl(j),'ydata') ...
               +abs(wave_bottom)/(abs(wave_bottom)+abs(wave_top))) ...
               +offset2);
         end
      end

      %  update legend axis label
      %
      %--------------------------------

      % north
      %
      if start_timepoint < 0
         ltext_x = eta * ((-start_timepoint)/(timepoint-1)) + offset;
      else
         ltext_x = offset;
      end
      ltext_y = eta + offset2 + offset3;
      set(legend_text_hdl(1),'position',[ltext_x,ltext_y,0], ...
	'fontsize',font_size);

      % south
      %
      if start_timepoint < 0
         ltext_x = eta * ((-start_timepoint)/(timepoint-1)) + offset;
      else
         ltext_x = offset;
      end
      ltext_y = offset2 - offset3;
      set(legend_text_hdl(2),'position',[ltext_x,ltext_y,0], ...
	'fontsize',font_size);

      % east
      %
      ltext_x = eta + offset + offset3;
      ltext_y = eta * abs(wave_bottom)/(abs(wave_bottom) ...
         + abs(wave_top)) + offset2;
      set(legend_text_hdl(3),'position',[ltext_x,ltext_y,0], ...
	'fontsize',font_size);

      % west
      %
      ltext_x = offset - offset3;
      ltext_y = eta * abs(wave_bottom)/(abs(wave_bottom) ...
         + abs(wave_top)) + offset2;
      set(legend_text_hdl(4),'position',[ltext_x,ltext_y,0], ...
	'fontsize',font_size);

      for i=selected_chan_idx

         for j=1:size(axis_hdl,1)    % for all the components on axis
            set(axis_hdl(j,i), ...
             'xdata',eta*get(orig_axis_hdl(j),'xdata')+x(i), ...
             'ydata',eta*get(orig_axis_hdl(j),'ydata')+y(i));
         end

         if ~isempty(orig_xtick_hdl)
            for j=1:size(xtick_hdl,1)	% for all the components on xtick
               set(xtick_hdl(j,i), ...
                  'xdata',eta*get(orig_xtick_hdl(j),'xdata')+x(i), ...
                  'ydata',eta*get(orig_xtick_hdl(j),'ydata')+y(i));
            end
         end

         if ~isempty(orig_ytick_hdl)
            for j=1:size(ytick_hdl,1)	% for all the components on ytick
               set(ytick_hdl(j,i), ...
                  'xdata',eta*get(orig_ytick_hdl(j),'xdata')+x(i), ...
                  'ydata',eta*get(orig_ytick_hdl(j),'ydata')+y(i));
            end
         end

         x_wave = eta * (0:timepoint-1)/(timepoint-1) + x(i);

         if num_avg ~= 0
            for j=selected_avg_idx
               y_wave = eta * ...
                  avg_amplitude(:,i,j)/(abs(wave_bottom)+abs(wave_top))+y(i);
               set(avg_wave_hdl(i,j),'xdata',x_wave,'ydata',y_wave);
            end              % for selected_avg_idx
         end

         if num_wave ~= 0
            for j=selected_wave_idx
               y_wave = eta * ...
                  wave_amplitude(:,i,j)/(abs(wave_bottom)+abs(wave_top))+y(i);
               set(wave_hdl(i,j),'xdata',x_wave,'ydata',y_wave);
            end
         end

         if num_bs ~= 0
            for j = selected_bs_idx

               x_mask = bs_x_amplitude(:,i,j);
               x_mask = find(x_mask)';
               bs_x_wave = x_wave(x_mask);

               bs_y_wave = bs_y_amplitude(:,i,j);
               bs_y_wave = eta * (bs_y_wave(x_mask) - abs(wave_bottom) ...
                     / (abs(wave_bottom) + abs(wave_top))) ...
                     + y(i);

               if bs_wave_hdl(i,j) ~= 99999
                  set(bs_wave_hdl(i,j),'xdata',bs_x_wave,'ydata',bs_y_wave);
               end

            end
         end

         if start_timepoint < 0
            text_x = x + eta*((-start_timepoint)/(timepoint-1));
         else
            text_x = x;
         end

         text_y = y + eta*wave_top/(abs(wave_bottom)+abs(wave_top));

         set(chan_name_hdl(i),'position',[text_x(i),text_y(i)], ...
		'fontsize',font_size);

      end	% for selected_chan_idx

      set(h_title,'fontsize',font_size);	% update title font size

   end					%%  if init_flag end

   if need_chan_name
      erp_plot_ui('display_chan_name','on');
   else
      erp_plot_ui('display_chan_name','off');
   end
 
   if need_chan_axes
      erp_plot_ui('display_chan_axes','on');
   else
      erp_plot_ui('display_chan_axes','off');
   end

   if need_chan_tick & need_chan_axes
      erp_plot_ui('display_chan_tick','on');
   else
      erp_plot_ui('display_chan_tick','off');
   end

   % below is the test routine, don't remove it
   %
   if(0)	% set 1 for test, 0 for normal

      switch system.class
         case 1
            type_str = 'BESAThetaPhi|EGI128|EGI256|EGI128_v2';

            switch system.type
               case 1
                  load('erp_loc_besa148');
               case 2
                  load('erp_loc_egi128');
               case 3
                  load('erp_loc_egi256');
               case 4
                  load('erp_loc_egi128_v2');
            end
         case 2
            type_str = 'CTF-150';

            switch system.type
               case 1
                  load('erp_loc_ctf150');
            end
      end

      for i=1:size(chan_loc,1)
         x(i) = chan_loc(i,1);
         y(i) = chan_loc(i,2);
      end

      min_x = min(x);	max_x = max(x);
      min_y = min(y);	max_y = max(y);
      %  normalize & shift x & y array
      %
      x = (x-min_x) / (max_x-min_x);
      y = (y-min_y) / (max_y-min_y);

      for i=1:size(chan_loc,1)
         text(double(x(i)), double(y(i)), chan_nam(i,:),'Interpreter','none');
      %    text(double(x(i)), double(y(i)), num2str(i),'Interpreter','none');
      end

   end

   return;					% erp_showplot_ui

