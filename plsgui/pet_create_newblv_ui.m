%

%  Called by pet_plot_brainlv
%   Modified on 17-JUN-2003 by Jimmy Shen, and add 'newcolor'
%
function [axes_h,colorbar_h] = pet_create_newblv_ui()

   save_setting_status = 'on';
   pet_result_newfig_pos = [];

   try
      load('pls_profile');
   catch 
   end

   if ~isempty(pet_result_newfig_pos) & strcmp(save_setting_status,'on')

      pos = pet_result_newfig_pos;

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
   	'DeleteFcn','pet_result_ui(''DeleteNewFigure'')', ...
	'InvertHardcopy','off', ...
	'PaperPositionMode', 'auto', ...
        'Userdata','Clone', ...
   	'Tag','PlotBrainLV2');

   rri_file_menu(fig_h);

   %

   x = .1;
   y = .1;
   w = .7;				% newcolor: was 0.8
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

   x = x+w+.03;				% newcolor: following lines was commented
   w = .055;

   pos = [x y w h];

   colorbar_h = axes('Parent',fig_h, ...		% axes
        'Units','normal', ...
  	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','Colorbar');
%colorbar_h = [];			% newcolor: colorbar_h was set to []
   setappdata(gcf,'Colorbar',colorbar_h);
   setappdata(gcf,'BlvAxes',axes_h);

   return; 						% pet_create_newblv_ui

