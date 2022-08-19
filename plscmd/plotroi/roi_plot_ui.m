function roi_plot_ui(action)

   if isstruct(action)
      if exist('plslog.m','file')
         plslog('Open ROI Plot');
         plslog(pwd);
      end

      init(action);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   switch action
   case 'load_bg_img'
      load_bg_img;
   case 'click_roi'
      click_roi;
   case 'fig_bt_dn'
      fig_bt_dn;
   case 'zooming'
      zoom_on_state = get(gcbo,'Userdata');
      if (zoom_on_state == 1)
         zoom on;
         set(gcbo,'Userdata',0,'Label','&Zoom off');
         set(gcf,'pointer','crosshair');
      else
 	 zoom off;
         set(gcbo,'Userdata',1,'Label','&Zoom on');
         set(gcf,'pointer','arrow');
      end;
   end;

   return;						% roi_plot_ui


%----------------------------------------------------------------------------
function init(roi)

   w = 0.65;
   h = 0.85;
   x = (1-w)/2;
   y = (1-h)/2;

   pos = [x y w h];

   h0 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'NumberTitle','on', ...
        'Menubar', 'none', ...
   	'Position', pos, ...
	'buttondown','roi_plot_ui(''fig_bt_dn'');', ...
   	'ToolBar','none');

   fnt = 12;

   x = .07;
   y = .07;
   w = .75;
   h = .85;

   pos = [x y w h];

   axes_h = axes('Parent',h0, ...			% image axes
        'Units','normal', ...
   	'Position',pos, ...
   	'Color',[1 1 1], ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','ImageAxes');

   x = x+w+.02;
   w = .04;

   pos = [x y w h];

   colorbar_h = axes('Parent',h0, ...			% color axes
        'Units','normal', ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','Colorbar');

   x = 0.01;
   y = 0;
   w = 1;
   h = 0.03;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Message Line
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ForegroundColor',[0.8 0.0 0.0], ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Tag','MessageLine');

   %  menu bar
   %
   h_file = uimenu('Parent',h0, ...
	'Label', 'File', ...
	'Tag', 'FileMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Load background image', ...
   	'Callback','roi_plot_ui(''load_bg_img'');');

   % Zoom submenu
   %
   h2 = uimenu('Parent',h0, ...
   	   'Label','&Zoom on', ...
	   'Userdata', 1, ...
           'Callback','roi_plot_ui(''zooming'')', ...
   	   'Tag','ZoomToggleMenu');

   rri_file_menu(h0);

   setappdata(gcf,'roi',roi);
   show_image([]);

   return;						% init


%----------------------------------------------------------------------------
function show_image(bg_img)

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   if isempty(bg_img)
      no_background_image = 1;
   else
      no_background_image = 0;
   end

   roi = getappdata(gcf,'roi');
   thresh = roi.threshold;
   brainlv = roi.comparelv;
   roiselect = roi.roiselect;

   max_blv = roi.max_val; %max(brainlv(:));
   min_blv = roi.min_val; %min(brainlv(:));

   num_blv_colors = 25;
   brain_region_color_idx = 1;
   first_lower_color_idx = 151;
   first_upper_color_idx = 176;

   bg_brain_values = [1 1 1];
   if (no_background_image),
      bg_cmap = ones(150,1)*bg_brain_values;	% the brain regions
   else
      bg_cmap = bone(200);
      bg_cmap = bg_cmap(1:150,:);
   end;

   cmap = ones(256,3);
   cmap(241:end,:) = gray(16);
   jetmap = jet(64);
   cmap(1:150,:) = bg_cmap;
   cmap(151:175,:) = jetmap([1:25],:);
   cmap(176:200,:) = jetmap([36:60],:);
   cmap(241:end,:) = gray(16);

   cbar_size = 100;
   cbar_map = ones(cbar_size,1) * bg_brain_values; 
   cbar_step = (max_blv - min_blv) / cbar_size;

   if no_background_image
      img = zeros(size(roi.flooded_image)) + brain_region_color_idx;

      coords = find(roi.flooded_image>240 & roi.flooded_image<256);
      img(coords) = roi.flooded_image(coords);
   else
      max_bg = max(bg_img(:));
      min_bg = min(bg_img(:));
      img = (bg_img - min_bg) / (max_bg - min_bg) * 150;

      coords = find(roi.flooded_image>240 & roi.flooded_image<256);
      img(coords) = roi.flooded_image(coords);
   end

   if cbar_step ~= 0

      if max_blv > -abs(thresh)
         num_lower_color = round((abs(min_blv) - thresh) / cbar_step);
      else
         num_lower_color = round((abs(min_blv) - abs(max_blv)) / cbar_step);
      end

      if round(64 / 25 * num_lower_color) > 0 & min_blv < abs(thresh)
         jetmap = jet(round(64 / 25 * num_lower_color));
         cbar_map(1:num_lower_color,:) = jetmap(1:num_lower_color,:);	
      end

      if min_blv < abs(thresh)
         num_upper_color = round((max_blv - thresh) / cbar_step);
      else
         num_upper_color = round((max_blv - min_blv) / cbar_step);
      end

      if round(64 / 25 * num_upper_color) > 0 & max_blv > -abs(thresh)
         jetmap = jet(round(64 / 25 * num_upper_color));
         first_jet_color = round((36 / 64) * size(jetmap,1));
         jet_range = [first_jet_color:first_jet_color+num_upper_color-1];
         cbar_map(end-num_upper_color+1:end,:) = jetmap(jet_range,:);
      end

      if max_blv > -abs(thresh)
         lower_interval = (abs(min_blv) - thresh) / (num_blv_colors-1);
      else
         lower_interval = (abs(min_blv) - abs(max_blv)) / (num_blv_colors-1);
      end

      if min_blv < abs(thresh)
         upper_interval = (max_blv - thresh) / (num_blv_colors-1);
      else
         upper_interval = (max_blv - min_blv) / (num_blv_colors-1);
      end

      lower_idx = find(brainlv <= -thresh);
      blv_offset = brainlv(lower_idx) - min_blv; 

      if lower_interval ~=0
         lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
      else
         lower_color_idx = ones(size(blv_offset)) * first_lower_color_idx;
      end

      upper_idx = find(brainlv >= thresh);
      blv_offset = max_blv - brainlv(upper_idx); 

      if upper_interval ~=0
         upper_color_idx = num_blv_colors - round(blv_offset/upper_interval);
      else
         upper_color_idx = num_blv_colors * ones(size(blv_offset));
      end

      upper_color_idx = upper_color_idx + first_upper_color_idx - 1;

      for i = 1:length(lower_idx)
         img(roi.coord{roiselect(lower_idx(i))}) = lower_color_idx(i);
      end

      for i = 1:length(upper_idx)
         img(roi.coord{roiselect(upper_idx(i))}) = upper_color_idx(i);
      end
   end

   if isempty(roi.title)
      tit = ['LV',num2str(roi.lv)];
      set(gcf,'name',tit);
      tit = ['LV',num2str(roi.lv),' BootRatio ',num2str(roi.threshold)];
   else
      tit = [roi.title,',LV',num2str(roi.lv)];
      set(gcf,'name',tit);
      tit = [roi.title,': LV',num2str(roi.lv),' BootRatio ',num2str(roi.threshold)];
   end

   axes_h = findobj(gcf,'Tag','ImageAxes');
   colorbar_h = findobj(gcf,'Tag','Colorbar');

   axes(axes_h);
   h_img = image(flipud(img));
   set(h_img,'buttondown','roi_plot_ui(''click_roi'');');
   title(tit);
   set(gca,'xtick',[],'ytick',[],'ydir','normal','Tag','ImageAxes');

   if min_blv == max_blv
      if abs(min_blv) < 1e-6
         max_blv = min_blv + eps;
      else
         max_blv = min_blv + abs(min_blv)*1e-9;
      end
   end

   create_colorbar(colorbar_h,cbar_map,min_blv,max_blv);
   colormap(cmap);
   set(gcf,'Pointer',old_pointer);

   return;						% show_image


%--------------------------------------------------------------------------
function load_bg_img

   [fn, pn] = uigetfile('*.tif','Load background image');

   if isequal(fn, 0) | isequal(pn, 0)
      return;
   end;

   bg_img_file = fullfile(pn, fn);
   bg_img = double(imread(bg_img_file))+1;

   roi = getappdata(gcf,'roi');

   if isequal(size(roi.flooded_image), size(bg_img))
      show_image(bg_img);
   else
      msg = 'ERROR: The size of background image does not match with the size of flooded image';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   return;						% load_bg_img


%--------------------------------------------------------------------------
function create_colorbar(axes_hdl,cmap,min_range,max_range)

   tick_steps = (max_range - min_range) / (size(cmap,1) - 1);
   y_range = [min_range:tick_steps:max_range];
   range = [max_range:-tick_steps:min_range];
   
   axes(axes_hdl);
   img_h = image([0,1],[min_range max_range],[1:size(cmap,1)]');

   bar_data = get(img_h,'CData');
   len = length(bar_data);
   cdata = zeros(len,1,3);

   cdata(1:len,1,:) = cmap(bar_data(1:len),:);
   set(img_h,'CData',cdata);

   set(axes_hdl, 'XTick',[], ...
            'YLim',[min_range max_range], ...
	    'YDir','normal', ...
            'Tag','Colorbar', ...
            'YAxisLocation','right');

   return;						% create_colorbar


%----------------------------------------------------------------------------
function click_roi

   roi = getappdata(gcf,'roi');

   pos = round(get(gca,'currentpoint'));
   pos_x = pos(1,1,1);
   pos_y = size(roi.flooded_image,1)-pos(1,2,1)+1;

   roi_idx = roi.flooded_image(pos_y, pos_x);
   roiselect_idx = find(roi.roiselect == roi.flooded_image(pos_y, pos_x));

   if roi_idx >= 1 & roi_idx <= size(roi.roi_name,1)

      roi_name1 = ['ROI ' num2str(roi_idx)];
      roi_name2 = roi.roi_name(roi_idx,:);

      roi_name3 = 'Value';

      if isempty(roiselect_idx)
         roi_name4 = 'N/A';
      else
         roi_name4 = num2str(roi.comparelv(roiselect_idx));
      end

      txtbox_hdl = rri_txtbox(gca, roi_name1, roi_name2, roi_name3, roi_name4);
      setappdata(gcf, 'txtbox_hdl', txtbox_hdl);
   else
      fig_bt_dn;
   end

   return;						% click_roi


%-----------------------------------------------------------
function fig_bt_dn

   try
      txtbox_hdl = getappdata(gcf,'txtbox_hdl');
      delete(txtbox_hdl);				% clear rri_txtbox
   catch
   end

   return;						% fig_bt_dn

