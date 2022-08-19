% Allow user to edit the input string matrix
% and output the new edited string matrix
%
%---------------------------------------------------------------------

function [new_string_matrix, new_behav_name] = ...
	rri_edit_behav(old_string_matrix, old_behav_name, title)

   if ~exist('old_string_matrix', 'var') | isempty(old_string_matrix)
      old_string_matrix = '';
   end

   if ~exist('old_behav_name', 'var') | isempty(old_behav_name)
      old_behav_name = {};
   end

   if ~exist('title', 'var')
      title = 'Edit';
   end

   if ~iscell(old_string_matrix) 
      if ~ischar(old_string_matrix) 
         return;
      end

      init(old_string_matrix, old_behav_name, title);
      uiwait;

      new_string_matrix = getappdata(gcf,'new_string_matrix');
      new_behav_name = getappdata(gcf,'new_behav_name');

      close(gcf);
      return;
   end

   if strcmp(old_string_matrix{1},'ok')
      new_string_matrix = get(findobj(gcf,'tag','edit_behav_data'),'string');
      r = size(new_string_matrix, 1);
      mask = [1:r];					% remove empty rows

      for i=1:r
         if isempty(deblank(new_string_matrix(i,:)))
            mask(i) = 0;
         end
      end

      setappdata(gcf,'new_string_matrix',new_string_matrix(find(mask),:));
      uiresume;
   elseif strcmp(old_string_matrix{1},'clear')
      set(findobj(gcf,'tag','edit_behav_data'),'string','');
      set(findobj(gcf,'tag','edit_behav_name'),'string','');
      set(findobj(gcf,'tag','behav_name_list'),'string',' ');
      setappdata(gcf,'new_behav_name',{});
   elseif strcmp(old_string_matrix{1},'cancel')
      old_string_matrix = getappdata(gcf,'old_string_matrix');
      setappdata(gcf,'new_string_matrix',old_string_matrix);

      old_behav_name = getappdata(gcf,'old_behav_name');
      setappdata(gcf,'new_behav_name',old_behav_name);

      uiresume;
   elseif strcmp(old_string_matrix{1},'delete_fig')
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         rri_edit_behav_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'rri_edit_behav_pos');
      catch
      end
   elseif strcmp(old_string_matrix{1},'edit_behav_data')
      edit_behav_data;
   elseif strcmp(old_string_matrix{1},'select_behav_data')
      select_behav_data;
   elseif strcmp(old_string_matrix{1},'remove_behav_name')
      remove_behav_name;
   elseif strcmp(old_string_matrix{1},'save_behav_data')
      save_behav_data;
   end

   return


%---------------------------------------------------------------------

function init(old_string_matrix, old_behav_name, title)

   save_setting_status = 'on';
   rri_edit_behav_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(rri_edit_behav_pos) & strcmp(save_setting_status,'on')

      pos = rri_edit_behav_pos;

   else

      w = 0.8;
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
	'deletefcn','rri_edit_behav({''delete_fig''})', ...
        'position', pos);

   x = 0.04;
   y = 0.85;
   w = 0.16;
   h = 0.06;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'style', 'text', ...
	'unit', 'normal', ...
	'back', [.8 .8 .8], ...
	'horizon', 'left', ...
	'fontsize', 12, ...
	'string', 'Behavior Name:', ...
	'position', pos);

   x = x + w;
   w = 1 - x - 0.2;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'style', 'edit', ...
	'unit', 'normal', ...
	'back', [1 1 1], ...
	'horizon', 'left', ...
	'fontname', 'courier', ...
	'fontsize', 12, ...
	'max', 1, ...
	'tag', 'edit_behav_name', ...
	'callback', 'rri_edit_behav({''edit_behav_data''});', ...
	'string', behav_cell2str(old_behav_name), ...
	'tooltip', 'Behavior name should not contain space. Use space to separate each name.', ...
	'position', pos);

   x = x + w + 0.03;
   y = 0.8;
   w = 0.13;
   h = 0.12;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'style', 'text', ...
	'unit', 'normal', ...
	'back', [.8 .8 .8], ...
	'horizon', 'left', ...
	'fontsize', 12, ...
	'string', 'Select behavior name to remove:', ...
	'position', pos);

   x = 0.04;
   y = 0.75;
   w = 0.16;
   h = 0.06;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'style', 'text', ...
	'unit', 'normal', ...
	'back', [.8 .8 .8], ...
	'horizon', 'left', ...
	'fontsize', 12, ...
	'string', 'Behavior Data:', ...
	'position', pos);

   y = 0.65;
   w = 0.13;
   h = 0.07;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'unit', 'normal', ...
	'fontsize', 12, ...
	'string', 'Load', ...
	'callback', 'rri_edit_behav({''select_behav_data''});', ...
	'position', pos);

   y = 0.55;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'unit', 'normal', ...
	'fontsize', 12, ...
	'string', 'Save', ...
	'callback', 'rri_edit_behav({''save_behav_data''});', ...
	'position', pos);

   x = 0.2;
   y = 0.15;
   w = 1 - x - 0.2;
   h = 0.65;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'style', 'edit', ...
	'unit', 'normal', ...
	'back', [1 1 1], ...
	'horizon', 'left', ...
	'fontname', 'courier', ...
	'fontsize', 12, ...
	'max', 2, ...
	'tag', 'edit_behav_data', ...
	'callback', 'rri_edit_behav({''edit_behav_data''});', ...
	'string', old_string_matrix, ...
	'tooltip', 'Behavior data should only contain numbers. Use space to separate each column.', ...
	'position', pos);

   x = x + w + 0.03;
   y = 0.25;
   w = 0.13;
   h = 0.55;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'style', 'listbox', ...
	'unit', 'normal', ...
	'back', [1 1 1], ...
	'fontsize', 12, ...
	'tag', 'behav_name_list', ...
	'value', [], ...
	'max', 2, ...
	'string', old_behav_name, ...
	'tooltip', 'Choose the behavior name that you would like to remove from this window.', ...
	'position', pos);

   y = 0.15;
   w = 0.13;
   h = 0.07;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'unit', 'normal', ...
	'fontsize', 12, ...
	'tag', 'remove_behav_name', ...
	'string', 'Remove', ...
	'callback', 'rri_edit_behav({''remove_behav_name''});', ...
	'position', pos);

   x = 0.2;
   y = 0.04;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'unit', 'normal', ...
	'fontunit','normal', ...
	'fontsize', 0.5, ...
	'string', 'OK', ...
	'callback', 'rri_edit_behav({''ok''});', ...
	'position', pos);

   x = (x+0.8)/2 - w/2;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'unit', 'normal', ...
	'fontunit','normal', ...
	'fontsize', 0.5, ...
	'string', 'Clear', ...
	'callback', 'rri_edit_behav({''clear''});', ...
	'position', pos);

   x = 1 - w - 0.2;

   pos = [x y w h];

   h1 = uicontrol('parent', h0, ...
	'unit', 'normal', ...
	'fontunit','normal', ...
	'fontsize', 0.5, ...
	'string', 'Cancel', ...
	'callback', 'rri_edit_behav({''cancel''});', ...
	'position', pos);

   edit_behav_data;

   setappdata(h0,'old_string_matrix',old_string_matrix);
   setappdata(h0,'old_behav_name',old_behav_name);

   return


%----------------------------------------------------------------------
function edit_behav_data

   behav_name_str = get(findobj(gcf,'tag','edit_behav_name'),'string');
   behav_name_str = deblank(fliplr(behav_name_str));
   behav_name_str = deblank(fliplr(behav_name_str));
   behav_name_cell = behav_str2cell(behav_name_str);

   behav_data = get(findobj(gcf,'tag','edit_behav_data'),'string');
   num_col = size(str2num(behav_data),2);

   num_behav = length(behav_name_cell);			% number of behav name

   if num_col > num_behav				% behavdata# > behavname#
      for i = num_behav+1 : num_col
         behav_name_str = [behav_name_str, ' behav', num2str(i)];
      end

      behav_name_str = deblank(fliplr(behav_name_str));
      behav_name_str = deblank(fliplr(behav_name_str));
      behav_name_cell = behav_str2cell(behav_name_str);
   else
      behav_name_cell = behav_name_cell(1:num_col);
      behav_name_str = behav_cell2str(behav_name_cell);
   end

   setappdata(gcf,'new_behav_name',behav_name_cell);
   set(findobj(gcf,'tag','edit_behav_name'),'string',behav_name_str);

   behav_name_list_hdl = findobj(gcf,'tag','behav_name_list');
   set(behav_name_list_hdl, 'value', [], 'string', behav_name_cell);

   return;


%----------------------------------------------------------------------
function behav_name_cell = behav_str2cell(r)

   behav_name_cell = {};

   while ~isempty(r)
      [t r] = strtok(r, '	 ');
      t=deblank(fliplr(t));
      t=deblank(fliplr(t));
      behav_name_cell = [behav_name_cell, {t}];
   end

   return;


%----------------------------------------------------------------------
function behav_name_str = behav_cell2str(behav_name_cell)

   behav_name_str = '';

   for i = 1:length(behav_name_cell)
      behav_name_str = [behav_name_str behav_name_cell{i} ' '];
   end

   behav_name_str = deblank(behav_name_str);

   return;


%----------------------------------------------------------------------
function select_behav_data

   [filename,pathname]=rri_selectfile('*.*','Select Behavior Data File');
        
   if isequal(filename,0) | isequal(pathname,0)		% Cancel was clicked
      return;
   end;
   
   behavdata_file = [pathname, filename];

   try
      behavdata = load(behavdata_file);
   catch						% cannot open file
      msg = ['ERROR: Could not open file'];
      msgbox(msg,'ERROR','modal');
      return;
   end

   set(findobj(gcf,'tag','edit_behav_data'),'string',num2str(behavdata, ' %0.5g '));
   edit_behav_data;

   behav_name_cell = getappdata(gcf,'new_behav_name');
   behav_name_str = [];

   for i = 1:length(behav_name_cell)
      behav_name_str = [behav_name_str, ' behav', num2str(i)];
   end

   behav_name_str = deblank(fliplr(behav_name_str));
   behav_name_str = deblank(fliplr(behav_name_str));
   behav_name_cell = behav_str2cell(behav_name_str);

   setappdata(gcf,'new_behav_name',behav_name_cell);
   set(findobj(gcf,'tag','edit_behav_name'),'string',behav_name_str);

   behav_name_list_hdl = findobj(gcf,'tag','behav_name_list');
   set(behav_name_list_hdl, 'value', [], 'string', behav_name_cell);

   return;


%----------------------------------------------------------------------
function remove_behav_name

   remove_behav_name_hdl = findobj(gcf,'tag','remove_behav_name');

   behav_name_list_hdl = findobj(gcf,'tag','behav_name_list');
   behav_name_idx = get(behav_name_list_hdl, 'value');

   if ~isempty(behav_name_idx)

      behav_name_str = get(findobj(gcf,'tag','edit_behav_name'),'string');
      behav_name_str = deblank(fliplr(behav_name_str));
      behav_name_str = deblank(fliplr(behav_name_str));
      behav_name_cell = behav_str2cell(behav_name_str);
      behav_name_cell(behav_name_idx) = [];

      behav_data = get(findobj(gcf,'tag','edit_behav_data'),'string');
      behav_data = str2num(behav_data);
      behav_data(:,behav_name_idx) = [];
      behav_data = num2str(behav_data, ' %0.5g ');

      setappdata(gcf,'new_behav_name',behav_name_cell);
      set(findobj(gcf,'tag','edit_behav_name'),'string',behav_cell2str(behav_name_cell));

      setappdata(gcf,'new_string_matrix',behav_data);
      set(findobj(gcf,'tag','edit_behav_data'),'string',behav_data);

      set(behav_name_list_hdl, 'value', [], 'string', behav_name_cell);

   end

   return;


%----------------------------------------------------------------------
function save_behav_data

   new_string_matrix = get(findobj(gcf,'tag','edit_behav_data'),'string');
   behav_data = double(str2num(new_string_matrix));

   [fn, pn] = rri_selectfile('*.txt','Save Behavior Data File');

   if ~fn
      return;
   else
      behav_file = [pn filesep fn];

      try
         save(behav_file, '-ascii', 'behav_data');
      catch
         msg = 'Cannot Save Behavior Data File';
         uiwait(msgbox(msg,'ERROR'));
      end
   end

   return;

