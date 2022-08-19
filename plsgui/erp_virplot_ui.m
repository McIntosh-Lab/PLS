%----------------------------------------------------------
function h01 = erp_virplot_ui(varargin)

   h01 = [];

   if nargin == 0

      h0 = gcbf;					% main figure
      chan_name_hdl = getappdata(h0, 'chan_name_hdl');
      selected_chan_idx = getappdata(gcf,'selected_chan_idx');
      chan_mask = getappdata(gcf,'chan_mask');
      selected_chan_list = [];
      selected_chan_name = [];
      selected_chan_id = [];

      for i=selected_chan_idx

         % collect selected list
         %
         if strcmp(get(chan_name_hdl(i),'fontweight'), 'bold')
            selected_chan_list = [selected_chan_list i];
            selected_chan_name = ...
		[selected_chan_name {get(chan_name_hdl(i),'string')}]; 
         end
      end

      selected_chan_id = chan_mask(selected_chan_list);

      if isempty(selected_chan_list)	% nothing to display
         hm_vir = getappdata(h0,'hm_vir');
         set(hm_vir, 'userdata',0, 'check','off');
         msg = 'At least one channel must be selected.';
         uiwait(msgbox(msg,'ERROR','modal'));
         return;
      end

%      set(h0,'visible','off');

      [tmp tit_fn] = rri_fileparts(get(gcf,'name'));
      h01 = init(h0, selected_chan_id, selected_chan_list, selected_chan_name, tit_fn);

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
   elseif strcmp(action,'vir')
      vir;
   elseif strcmp(action,'mve')
      mve;

   end

   return;


%-----------------------------------------------------------
function h02 = init(h0, selected_chan_id, selected_chan_list, selected_chan_name, tit_fn)

   %------------------------- figure ----------------------

   tit = ['Subject Amplitude for Given Timepoints  [', tit_fn, ']'];

   save_setting_status = 'on';
   erp_virplot_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(erp_virplot_pos) & strcmp(save_setting_status,'on')

      pos = erp_virplot_pos;

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
        'user', 'Subject Amplitude for Given Timepoints', ...
	'name', tit, ...
        'deleteFcn','erp_virplot_ui(''delete_fig'');', ...
        'tag','vir_fig', ...
        'position', pos);

%        'windowbuttondown','erp_virplot_ui(''gps'');',...

   %  file menu
   %
   rri_file_menu(h02);

   %  xhair
   %
   h_xhair = uimenu('parent',h02, ...
        'label','Crosshair');
   h_xhair_view = uimenu('parent',h_xhair, ...
        'userdata', 0, ...
        'callback','erp_virplot_ui(''crosshair'');', ...
        'label','Crosshair off');
   h_xhair_color = uimenu('parent',h_xhair, ...
        'userdata', [1 0 0], ...
        'callback','erp_virplot_ui(''set_xhair_color'');', ...
        'label','Color ...');

   %  zoom
   %
   h1 = uimenu('parent',h02, ...
        'userdata', 1, ...
        'callback','erp_virplot_ui(''zoom'');', ...
        'label','&Zoom on');

   %  point2txt
   %
   h_point2txt = uimenu('parent',h02, ...
        'callback','erp_virplot_ui(''point2txt'');', ...
        'visible', 'off', ...
        'label','point2txt');

   %  vir
   %
   h1 = uimenu('parent',h02, ...
        'userdata', 1, ...
        'callback','erp_virplot_ui(''vir'');', ...
        'label','Response Plot');

   %  mve
   %
   h1 = uimenu('parent',h02, ...
        'userdata', 1, ...
        'callback','erp_virplot_ui(''mve'');', ...
        'label','Multiple Extraction');

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
   prestim = init_option.prestim;
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
	'buttondown','erp_virplot_ui(''de_gps'');', 'user', [], ...
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
				'buttondown','erp_virplot_ui(''gps'');', ...
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

   setappdata(h02, 'digit_interval', digit_interval);
   setappdata(h02, 'prestim', prestim);
   setappdata(h02, 'selected_chan_id', selected_chan_id);
   setappdata(h02, 'selected_chan_list', selected_chan_list);
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
   selected_chan_id = getappdata(gcf, 'selected_chan_id');
   selected_chan_list = getappdata(gcf, 'selected_chan_list');
   selected_chan_name = getappdata(gcf, 'selected_chan_name');
   selected_wave_idx = getappdata(main_fig,'selected_wave_idx');

   chan_id = selected_chan_id(user(2));
   chan_list = selected_chan_list(user(2));
   chan_name = selected_chan_name{user(2)};
   wave_idx = selected_wave_idx(user(1));

   xlim = get(gca,'xlim');			% current xy limitation
   ylim = get(gca,'ylim');

   loc = get(gca,'CurrentPoint');		% get location
   loc_xy = loc(1,1:2);

   if loc_xy(1) >= xlim(1) & loc_xy(1) <= xlim(2) & ...
      loc_xy(2) >= ylim(1) & loc_xy(2) <= ylim(2)

      linkfig = getappdata(gcbf,'RFPlotHdl');

      if ~isempty(linkfig) & ishandle(linkfig)
         figure(linkfig); erp_plot_rf_task('NewCoord', loc_xy(1), ...
		chan_id, chan_list, chan_name, wave_idx);
      end
   end

   return;						% gps


%--------------------------------------------------------------
function de_gps
return
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
   filename = strrep(filename, '_ERPresult.mat', '_ERPvir.txt');

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
% close vir_fig & rf_fig
%

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      erp_virplot_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'erp_virplot_pos');
   catch
   end

   rf_fig = getappdata(gcbf,'RFPlotHdl');

   try
      delete(rf_fig);
   catch
   end

   h0 = getappdata(gcbf,'main_fig');
   hm_vir = getappdata(h0,'hm_vir');
   set(hm_vir, 'userdata',0, 'check','off');

   return;						% delete_fig


%  like Voxel Intensity Response
%
%--------------------------------------------------
function vir

  rf_plot = getappdata(gcbf,'RFPlotHdl');
  if ~isempty(rf_plot)
      msg = 'ERROR: Response plot window has already opened';
      uiwait(msgbox(msg,'ERROR','modal'));
      return;
  end;

  h0 = getappdata(gcf, 'main_fig');
  rf_plot = erp_plot_rf_task('LINK',getappdata(h0,'datamat_file'),h0);

  link_info.hdl = gcbf;
  link_info.name = 'RFPlotHdl';
  setappdata(rf_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'RFPlotHdl',rf_plot);
  figure(link_info.hdl);

   return;						% vir


%  like MultipleVoxel
%
%--------------------------------------------------
function mve

   main_fig = getappdata(gcf,'main_fig');
   curr_fig = gcf;
   PLSresultFile = getappdata(main_fig,'datamat_file');

   %  get input filename
   %
   [fn,pn] = rri_selectfile('*.*','Please select a time points file');
   if (pn == 0), return; end;
   voxel_file = fullfile(pn, fn);

   if ~exist(voxel_file,'file')
      msg = 'Time points file does not exist';
      uiwait(msgbox(msg,'ERROR','modal'));
      return;
   end

   time_point = load(voxel_file);

   if isempty(time_point) | size(time_point,2) ~= 1
      msg = 'Time points file should contain 1 time point for each row';
      uiwait(msgbox(msg,'ERROR','modal'));
      return;
   end

   % --- the following part is copied from erp_plot_rf_task/load_voxel_intensity
   warning off;
   load(PLSresultFile, 'datamat_files', 'common_conditions', 'cond_name', ...
	'subj_name_lst', 'common_time_info', 'common_channels', 'result');
   warning on;

   if exist('result','var')
      method = result.method;
      num_lv = length(result.s);
   end

   num_group = length(datamat_files);

   % get upper & lower limit of timepoints (from erp_datacub2datamat)
   %
   start_timepoint = floor((common_time_info.start_time - ...
	common_time_info.prestim) / common_time_info.digit_interval +1);
   end_timepoint = start_timepoint + common_time_info.timepoint -1;

%   all_datamat = [];

   for i = 1:num_group
      load(datamat_files{i}, 'datafile', 'selected_subjects', 'selected_conditions');
      rri_changepath('erpdata');
      load(datafile, 'datamat');
      datamat_lst{i} = datamat([start_timepoint:end_timepoint],find(common_channels),find(selected_subjects),find(common_conditions));
      all_datamat_lst{i} = datamat([start_timepoint:end_timepoint],find(common_channels),find(selected_subjects),find(selected_conditions));
%      all_datamat = cat(3, all_datamat, tmp(:,:,:));
   end

   data_point = round( (time_point - common_time_info.prestim) / ...
			common_time_info.digit_interval) + 1;

   data_point = data_point - start_timepoint + 1;
   xyz = data_point;
   coords = data_point;

   dxyz=ones(size(xyz,1),1)*common_time_info.timepoint;
   dxyz=dxyz-xyz;

   if any(xyz(:)<=0) | any(dxyz(:)<0)
      outrange = unique([find(xyz<0);find(dxyz<0)])';
      msg1='Please remove the following entry(s) from the time points file and try again, because they are out of the range ';
      msg1=[msg1 'between ',num2str(common_time_info.start_time), ' (ms) and ', num2str(common_time_info.end_time), ' (ms): '];
      msg2=num2str(outrange);
      msg={msg1;'';msg2};
      uiwait(msgbox(msg,'ERROR','modal'));
      return;
   end

   %  get output filename
   %
   pattern = ...
      ['<ONLY INPUT PREFIX>*_ERP_grp1_timepointdata.txt'];
   [fn,pn] = rri_selectfile(pattern,'Please enter a prefix of saving files');
   if (pn == 0), return; end;

   fn = strrep(fn,'_ERP_grp1_timepointdata.txt','');

   [tmp fn] = fileparts(fn);

   msg = 'If you would like to use average value of the neighborhood data points, please enter neighborhood size that is the number of data points from inputted time point: ';

   CallBackFig = getappdata(curr_fig,'main_fig');
   bs_ratio = getappdata(CallBackFig,'bs_ratio');
   LVm = size(bs_ratio,2);
   holdoffresidual = 1;

   if holdoffresidual
      if LVm > 0
         msg2 = 'Since the program detected that there is Bootstrap Ratio in this result file, please also enter which LV of Bootstrap Ratio that will be used to threshold the neighborhood time points: ';
         tmp = inputdlg({msg,msg2}, 'Questions', 1, {'0','1'});
      else
         tmp = inputdlg({msg}, 'Questions', 1, {'0'});
      end
   elseif isempty(findstr(datamat_files{1}, 'sessiondata.mat')) | ...
	~exist('method','var')
      if LVm > 0
         msg2 = 'Since the program detected that there is Bootstrap Ratio in this result file, please also enter which LV of Bootstrap Ratio that will be used to threshold the neighborhood time points: ';
         tmp = inputdlg({msg,msg2}, 'Questions', 1, {'0','1'});
      else
         tmp = inputdlg({msg}, 'Questions', 1, {'0'});
      end
   elseif isequal(method,2) | isequal(method,5) | isequal(method,6)
      if LVm > 0
         msg2 = 'Since the program detected that there is Bootstrap Ratio in this result file, please also enter which LV of Bootstrap Ratio that will be used to threshold the neighborhood time points: ';
         tmp = inputdlg({msg,msg2}, 'Questions', 1, {'0','1'});
      else
         tmp = inputdlg({msg}, 'Questions', 1, {'0'});
      end
   elseif isequal(method,3) | isequal(method,4)
      if LVm > 0
         msg2 = 'Since the program detected that there is Bootstrap Ratio in this result file, please also enter which LV of Bootstrap Ratio that will be used to threshold the neighborhood time points: ';
         tmp = inputdlg({msg,msg2}, 'Questions', 1, {'0','1'});
      else
         tmp = inputdlg({msg}, 'Questions', 1, {'0'});
      end
   else
      msg3 = 'If you also want to export Residualized Data, please enter 1 below. Otherwise, Residualized Data will not be exported: ';

      if LVm > 0
         msg2 = 'Since the program detected that there is Bootstrap Ratio in this result file, please also enter which LV of Bootstrap Ratio that will be used to threshold the neighborhood time points: ';
         tmp = inputdlg({msg,msg2,msg3}, 'Questions', 1, {'0', '1', '0'});
      else
         tmp = inputdlg({msg,msg3}, 'Questions', 1, {'0','0'});
      end
   end

   CurrLVIdx = 1;
   export_resid = 0;

   if isempty(tmp)
      return;
   else
      neighbor_size = round(str2num(tmp{1}));

      if exist('msg3','var')
         if LVm > 0
            CurrLVIdx = round(str2num(tmp{2}));

            if CurrLVIdx > LVm
               msg = ['LV value must not be greater than ' num2str(LVm)];
               uiwait(msgbox(msg,'ERROR','modal'));
               return;
            end

            export_resid = round(str2num(tmp{3}));
         else
            export_resid = round(str2num(tmp{2}));
         end
      else
         if LVm > 0
            CurrLVIdx = round(str2num(tmp{2}));

            if CurrLVIdx > LVm
               msg = ['LV value must not be greater than ' num2str(LVm)];
               uiwait(msgbox(msg,'ERROR','modal'));
               return;
            end
         end
      end
   end

   if isempty(neighbor_size) | ~isnumeric(neighbor_size) | neighbor_size < 0
      neighbor_size = 0;
   end

   if isempty(export_resid) | ~isnumeric(export_resid) | export_resid < 0
      export_resid = 0;
   end

   old_pointer = get(main_fig,'Pointer');
   set(main_fig,'Pointer','watch');
   msg = 'Extracting time points, please wait ...';
   h_wait = rri_wait_box(msg,[0.4 0.1]);

   chan_id = getappdata(curr_fig, 'selected_chan_id');
   chan_list = getappdata(curr_fig, 'selected_chan_list');
   chan_name = getappdata(curr_fig, 'selected_chan_name');

   all_behavdata = [];

   %  export data in those coords to output files
   %
   for g = 1:num_group
      behavdata = [];
      all_grp_behavdata = [];
      for v = 1:length(coords)

            %  Unlike E.R.fMRI, where the temporal window (e.g. 
            %  lag = [1:8]) is flattened into 1 volume, ERP has 
            %  to worry about its channel. In addition, E.R.fMRI 
            %  will have the entire lag for each voxel, ERP will
            %  have to go through all the channels for each time 
            %  point. Therefore, we need a neighbor_coord matrix,
            %  instead of neighbor_coord vector. We have to change
            %  neighbor_coord vector like this:
            %
            neighbor_coord = zeros(common_time_info.timepoint,1);
            neighbor_coord(coords(v)) = 1;
            neighbor_coord = neighbor_coord * ones(1,length(chan_list));

            if neighbor_size > 0

               %  Get neighborhood XYZs
               %
               data_point = coords(v);

               x1 = data_point - neighbor_size;
               if x1 < 1, x1 = 1; end;

               x2 = data_point + neighbor_size;
               if x2 > common_time_info.timepoint, x2 = common_time_info.timepoint; end;

               %  Get neighborhood coords relative to whole volume
               %
               data_point_coord = neighbor_coord;
               neighbor_coord([x1:x2],:) = 1;

               %  If "Bootstrap" is computed, voxels that meet the bootstrap ratio
               %  threshold will be used as a criteria to select surrounding voxels
               %
               bs_field = getappdata(CallBackFig,'bs_field');

               if ~isempty(bs_field)
                  bs_field = bs_field{CurrLVIdx};
                  BSThreshold = bs_field.thresh;
                  BSThreshold2 = bs_field.thresh2;

                  selected_channels = getappdata(CallBackFig,'selected_channels');
                  BSRatio = bs_ratio(:,CurrLVIdx);
                  BSRatio = reshape(BSRatio, [common_time_info.timepoint sum(selected_channels)]);
                  BSRatio = BSRatio(:,chan_list);

                  all_voxel = (BSRatio > BSThreshold) | (BSRatio < BSThreshold2);
                  neighbor_coord = data_point_coord + neighbor_coord .* all_voxel;
               end

            end;		% if neighbor_size > 0

         %  combine subj & cond in 1 dimension by removing last ,:
         %
         st_data = datamat_lst{g}(:,chan_list,:);
         all_st_data = all_datamat_lst{g}(:,chan_list,:);

         for ch = 1:length(chan_list)
            tmp = mean(st_data(find(neighbor_coord(:,ch)),ch,:),1);
            behavdata = [behavdata tmp(:)];

            all_tmp = mean(all_st_data(find(neighbor_coord(:,ch)),ch,:),1);
            all_grp_behavdata = [all_grp_behavdata all_tmp(:)];
         end;

      end				% for v

      behavdata_file = fullfile(pn,sprintf('%s_ERP_grp%d_timepointdata.txt',fn,g));
      behavdata = double(behavdata);
      save_header(behavdata_file, behavdata, chan_name, time_point);

      all_behavdata = [all_behavdata; behavdata];
   end					% for g

   behavdata = double(all_behavdata);

   if export_resid

      %  Calculate residual
      %
      dlv = result.v;
      num_subj_lst = result.num_subj_lst;
      num_cond = result.num_conditions;

      designlv_expanded = [];

      for g = 1:length(num_subj_lst)
         tmp = rri_expandvec(dlv(1:num_cond,:), num_subj_lst(g));
         designlv_expanded = [designlv_expanded; tmp];
         dlv(1:num_cond,:) = [];
      end

      for lv = 2:num_lv
         newdata = behavdata;

         for i = 1:lv-1
            newdata = residualize(designlv_expanded(:,i), newdata);
         end

         PLSbehavdataFile = fullfile(pn,sprintf('%s_ERPtimepointdata_residLV%d.txt',fn,lv));
         save_header(PLSbehavdataFile, newdata, chan_name, time_point);
      end

      PLSbehavdataFile = fullfile(pn,sprintf('%s_ERPtimepointdata.txt',fn));
      save_header(PLSbehavdataFile, behavdata, chan_name, time_point);
   else
      PLSbehavdataFile = fullfile(pn,sprintf('%s_ERPtimepointdata.txt',fn));
      save_header(PLSbehavdataFile, behavdata, chan_name, time_point);
   end

   close(h_wait);
   set(main_fig,'Pointer',old_pointer);

   return;						% mve


%
%
%--------------------------------------------------
function save_header(fn, data, chan_name, time_point)

   fid = fopen(fn, 'wt');

   fprintf(fid,'%%');

   for i=1:length(time_point)
      for j=1:length(chan_name)
         fprintf(fid,'%s(ms)%s\t',num2str(time_point(i)),chan_name{j});
      end
   end

   fprintf(fid,'\n');

   for i=1:size(data,1)
      for j=1:size(data,2)
         fprintf(fid,'%+.7e\t',data(i,j));
      end

      fprintf(fid,'\n');
   end

   fclose(fid);

   return;

