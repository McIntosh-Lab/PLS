% Plot Design LV for all groups
%
%---------------------------------------------------------

function h01 = erp_plot_dlv_ui(varargin)

   h01 = [];

   if nargin == 0
      h01 = init;
      return;
   end

   action = varargin{1};

   if strcmp(action,'delete_fig')
      delete_fig;
   end

   return; 					% erp_plot_dlv_ui


%----------------------------------------------------------

function h01 = init

   % ----------------------- Figure --------------------------

   save_setting_status = 'on';
   erp_plot_dlv_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(erp_plot_dlv_pos) & strcmp(save_setting_status,'on')

      pos = erp_plot_dlv_pos;

   else

      w = 0.8;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

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
	'user','LV Plot', ...
	'color', [0.8 0.8 0.8], ...
	'deleteFcn', 'erp_plot_dlv_ui(''delete_fig'');', ...
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

   return; 						% init


%--------------------------------------------------------------

function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      erp_plot_dlv_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'erp_plot_dlv_pos');
   catch
   end

   h0 = getappdata(gcbf,'main_fig');
   hm_dlv = getappdata(h0,'hm_dlv');

   if ishandle(hm_dlv)
      set(hm_dlv, 'userdata',0, 'check','off');
   end

   return;						% delete_fig

