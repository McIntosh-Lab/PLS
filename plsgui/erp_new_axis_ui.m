% Copy axis from previous figure to this figure
%
%---------------------------------------------------------

function h01 = erp_new_axis_ui(varargin)

   h01 = [];

   if nargin == 0
      h01 = init;
      return;
   end

   action = varargin{1};

   if strcmp(action,'delete_fig')
      delete_fig;
   end

   return; 					% erp_new_axis_ui


%----------------------------------------------------------

function h01 = init

   old_axis = gca;

   % ----------------------- Figure --------------------------

   save_setting_status = 'on';
   erp_new_axis_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(erp_new_axis_pos) & strcmp(save_setting_status,'on')

      pos = erp_new_axis_pos;

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
	'name','Current Axis', ...
	'color', [0.8 0.8 0.8], ...
	'deleteFcn', 'erp_new_axis_ui(''delete_fig'');', ...
	'doubleBuffer','on', ...
	'position',pos);

   % ----------------------- Menu --------------------------

   %  file
   %
   rri_file_menu(h01);

   h0 = gcbf;
   copy_axis = copyobj_legacy(old_axis, h0);
   new_axis = copyobj_legacy(copy_axis, h01);
   delete(copy_axis);
   set(new_axis, 'position', [.08 .12 .86 .8]);

   return; 						% init


%--------------------------------------------------------------

function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      erp_new_axis_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'erp_new_axis_pos');
   catch
   end

   h0 = getappdata(gcbf,'main_fig');
   hm_axis = getappdata(h0,'hm_axis');
   set(hm_axis, 'userdata',0, 'check','off');

   return;						% delete_fig

