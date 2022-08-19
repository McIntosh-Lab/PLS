%
%  Called by bfm_plot_brainlv
%
function [axes_h,colorbar_h] = bfm_create_newblv_ui()

   save_setting_status = 'on';
   bfm_result_newfig_pos = [];

   try
      load('pls_profile');
   catch 
   end

   if ~isempty(bfm_result_newfig_pos) & strcmp(save_setting_status,'on')

      pos = bfm_result_newfig_pos;

   else

      w = 0.6;
      h = 0.8;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   tit = get(gcbf,'name');

   fig_h = figure('Units','normal', ...
   	'Color',[0.8 0.8 0.8], ...
	'Name',tit, ...
        'NumberTitle','off', ...
   	'DoubleBuffer','on', ...
   	'Position',pos, ...
   	'DeleteFcn','bfm_result_ui(''DeleteNewFigure'')', ...
	'InvertHardcopy', 'off', ...
	'PaperPositionMode', 'auto', ...
        'Userdata','Clone', ...
   	'Tag','PlotBrainLV2');

   rri_file_menu(fig_h);

   %

   x = .1;
   y = .1;
   w = .7;
   h = .85;

   pos = [x y w h];

   axes_h = axes('Parent',fig_h, ...			% axes
        'Units','normal', ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',[1 1 1], ...
  	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','BlvAxes');

   x = x+w+.03;
   w = .055;

   pos = [x y w h];

   colorbar_h = axes('Parent',fig_h, ...			% c axes
        'Units','normal', ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','Colorbar');

   setappdata(gcf,'Colorbar',colorbar_h);
   setappdata(gcf,'BlvAxes',axes_h);

   return; 						% bfm_create_newblv_ui

