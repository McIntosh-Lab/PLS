% Allow user to edit the input string matrix
% and output the new edited string matrix
%
%---------------------------------------------------------------------

function new_string_matrix = rri_edit_string(old_string_matrix, title)

   if ~exist('old_string_matrix', 'var') | isempty(old_string_matrix)
      old_string_matrix = '';
   end

   if ~exist('title', 'var')
      title = 'Edit';
   end

   if ~isnumeric(old_string_matrix) 
      init(old_string_matrix, title);
      uiwait;
      new_string_matrix = getappdata(gcf,'new_string_matrix');
      close(gcf);
      return;
   end

   if old_string_matrix == 0
      hedit = getappdata(gcf,'hedit');
      new_string_matrix = get(hedit,'string');
      r = size(new_string_matrix, 1);
      mask = [1:r];

      for i=1:r
         if isempty(deblank(new_string_matrix(i,:)))
            mask(i) = 0;
         end
      end

      setappdata(gcf,'new_string_matrix',new_string_matrix(find(mask),:));
      uiresume;
   elseif old_string_matrix == 1
      hedit = getappdata(gcf,'hedit');
      set(hedit,'string','');
   elseif old_string_matrix == 2
      old_string_matrix = getappdata(gcf,'old_string_matrix');
      setappdata(gcf,'new_string_matrix',old_string_matrix);
      uiresume;
   else
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         rri_edit_string_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'rri_edit_string_pos');
      catch
      end
   end

   return


%---------------------------------------------------------------------

function init(old_string_matrix, title)

   save_setting_status = 'on';
   rri_edit_string_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(rri_edit_string_pos) & strcmp(save_setting_status,'on')

      pos = rri_edit_string_pos;

   else

      w = 0.68;
      h = 0.6;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
        'units','normal', ...
	'windowstyle','modal', ...
        'name', title, ...
        'numberTitle','off', ...
        'menubar', 'none', ...
        'toolbar','none', ...
	'deletefcn','rri_edit_string(3)', ...
        'position', pos);

   x = 0.1;
   y = 0.15;
   w = 1 - 2*x;
   h = 0.75;

   pos = [x y w h];

   hedit = uicontrol('parent', h0, ...
	'style', 'edit', ...
	'unit', 'normal', ...
	'back', [1 1 1], ...
	'horizon', 'left', ...
	'fontname', 'courier', ...
	'fontsize', 12, ...
	'max', 2, ...
	'string', old_string_matrix, ...
	'position', pos);

   x = 0.16;
   y = 0.04;
   w = 0.16;
   h = 0.07;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'unit', 'normal', ...
	'fontunit','normal', ...
	'fontsize', 0.5, ...
	'string', 'OK', ...
	'callback', 'rri_edit_string(0);', ...
	'position', pos);

   x = 0.5 - w/2;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'unit', 'normal', ...
	'fontunit','normal', ...
	'fontsize', 0.5, ...
	'string', 'Clear', ...
	'callback', 'rri_edit_string(1);', ...
	'position', pos);

   x = 1 - 0.16 - 0.16;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'unit', 'normal', ...
	'fontunit','normal', ...
	'fontsize', 0.5, ...
	'string', 'Cancel', ...
	'callback', 'rri_edit_string(2);', ...
	'position', pos);

   setappdata(h0,'old_string_matrix',old_string_matrix);
   setappdata(h0,'hedit',hedit);

   return


