%ERP_BS_OPTION_UI Option window for BootStrap Display
%
%   USAGE: bs_option_fig = erp_bs_option_ui
%
%   See also: ERP_PLOT_OPTION_UI

%   Called by ERP_PLOT_UI
%
%   O (bs_option_fig) - handle of bootstrap option figure
%
%   Modified on 15-Jan-2003 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h01 = erp_bs_option_ui(varargin)

   if nargin == 0 | ~ischar(varargin{1})

      h01 = init(varargin{1});

      return;

   end

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = varargin{1};

   if strcmp(action,'select_all')
      select_all;
   elseif strcmp(action,'select_lv')
      select_lv;
   elseif strcmp(action,'edit_thresh')
      edit_thresh;
   elseif strcmp(action,'edit_thresh2')
      edit_thresh2;
   elseif strcmp(action,'edit_min_ratio')
      edit_min_ratio;
   elseif strcmp(action,'edit_max_ratio')
      edit_max_ratio;
   elseif strcmp(action,'reset_bs_fields')
      reset_bs_fields;
   elseif strcmp(action,'set_bs_fields')
      h01 = set_bs_fields(varargin{2});
   elseif strcmp(action,'click_ok')
      click_ok;
   elseif strcmp(action,'click_cancel')
      close(gcf);
   elseif strcmp(action,'delete_fig')
      delete_fig;
   end

   return;					% erp_bs_option_ui


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  initialize GUI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h01 = init(h0)

   %------------------- control panel figure ----------------------

   save_setting_status = 'on';
   erp_bs_option_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(erp_bs_option_pos) & strcmp(save_setting_status,'on')

      pos = erp_bs_option_pos;

   else

      w = 0.6;
      h = 0.58;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h01 = figure('units','normal', ...
        'numberTitle','off', ...
        'menubar', 'none', ...
        'toolBar','none', ...
        'name','BootStrap Options', ...
        'deletefcn','erp_bs_option_ui(''delete_fig'');', ...
	'tag','bs_option_fig', ...
        'position', pos);

   % numbers of lines excluding 'MessageLine'

   top_margin = 0.05;
   left_margin = 0.05;
   num_line = 14;
   factor_line = (1-top_margin)/(num_line+1);

   %----------------------- LV selection ---------------------------

   x = left_margin;
   y = (num_line-0) * factor_line;
   w = 0.5 - 2*left_margin;
   h = 1 * factor_line;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% bs_edit label
        'units','normal', ...
        'style','text', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
	'back',[0.8 0.8 0.8], ...
        'string','Select an LV to Edit', ...
        'position',pos);

   x = left_margin + 0.5;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% bs_disp label
        'units','normal', ...
        'style','text', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
	'back',[0.8 0.8 0.8], ...
        'string','Select LV(s) to Display', ...
        'position',pos);

   x = left_margin;
   y = (num_line-4)*factor_line;
   w = 0.5 - 2*left_margin;
   h = 4 * factor_line;

   pos = [x y w h];

   h_bs_edit = uicontrol('parent',h01, ...	% bs_edit listbox
	'unit','normal', ...
	'style','listbox', ...
	'fontunit','normal', ...
	'fontsize',0.144, ...
	'max',1, ...
        'callback','erp_bs_option_ui(''select_lv'');', ...
	'position',pos);

   x = left_margin + 0.5;

   pos = [x y w h];

   h_bs_disp = uicontrol('parent',h01, ...	% bs_disp listbox
	'unit','normal', ...
	'style','listbox', ...
	'fontunit','normal', ...
	'fontsize',0.144, ...
	'max',2, ...
	'position',pos);

   x = left_margin + 0.55;
   y = (num_line-6)*factor_line;
   w = 0.35;
   h = 1 * factor_line;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% bs selection selectall
	'unit','normal', ...
	'style','push', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
	'string','Select All LVs', ...
	'callback', 'erp_bs_option_ui(''select_all'');', ...
	'position',pos);

   %-------------------- BootStrap field selection ----------------------

   y = (num_line-8)*factor_line;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% field selection reset
	'unit','normal', ...
	'style','push', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
	'string','Reset to default value', ...
	'callback', 'erp_bs_option_ui(''reset_bs_fields'');', ...
	'position',pos);

   x = left_margin;
   y = (num_line-6) * factor_line;
   w = 0.3;
   h = 1 * factor_line;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% PValue label
        'units','normal', ...
        'style','text', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [0.8 0.8 0.8], ...
	'string', 'Approximate P Value:', ...
	'visible','off', ...
        'position',pos);

   x = x + w;
   y = (num_line-6) * factor_line;
   w = 0.15;

   pos = [x y w h];

   h_p_value = uicontrol('parent',h01, ...	% PValue edit
        'units','normal', ...
        'style','text', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','right', ...
        'back',[0.8 0.8 0.8], ...
	'string','', ...
	'visible','off', ...
        'position',pos);

   x = left_margin;
   y = (num_line-6) * factor_line;
   w = 0.3;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...      	% Pos.Thresh label
        'units','normal', ...
        'style','text', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [0.8 0.8 0.8], ...
        'string', 'Pos.Thresh:', ...
        'position',pos);

   x = x + w;
   y = (num_line-6) * factor_line;
   w = 0.15;

   pos = [x y w h];

   h_thresh = uicontrol('parent',h01, ...	% Pos.Thresh edit
        'units','normal', ...
        'style','edit', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','right', ...
        'back',[1 1 1], ...
        'string','', ...
        'callback','erp_bs_option_ui(''edit_thresh'');', ...
        'position',pos);

   x = left_margin;
   y = (num_line-8) * factor_line;
   w = 0.3;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...      	% Neg.Thresh label
        'units','normal', ...
        'style','text', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','left', ...
        'back', [0.8 0.8 0.8], ...
        'string', 'Neg.Thresh:', ...
        'position',pos);

   x = x + w;
   y = (num_line-8) * factor_line;
   w = 0.15;

   pos = [x y w h];

   h_thresh2 = uicontrol('parent',h01, ...	% Neg.Thresh edit
        'units','normal', ...
        'style','edit', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','right', ...
        'back',[1 1 1], ...
        'string','', ...
        'callback','erp_bs_option_ui(''edit_thresh2'');', ...
        'position',pos);

   x = left_margin;
   y = (num_line-10) * factor_line;
   w = 0.3;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% Max. Ratio label
        'units','normal', ...
        'style','text', ...
        'fontunit','normal', ...
        'fontsize', 0.55, ...
        'horizon','left', ...
        'back',[0.8 0.8 0.8], ...
        'string','Maximum Ratio:', ...
        'position',pos);

   x = x + w;
   y = (num_line-10) * factor_line;
   w = 0.15;

   pos = [x y w h];

   h_max_ratio = uicontrol('parent',h01, ...	% Max. Ratio edit
        'units','normal', ...
        'style','edit', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','right', ...
        'back',[1 1 1], ...
	'string', '', ...
        'callback','erp_bs_option_ui(''edit_max_ratio'');', ...
        'position',pos);

   x = left_margin;
   y = (num_line-12) * factor_line;
   w = 0.3;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% Min. Ratio label
        'units','normal', ...
        'style','text', ...
        'fontunit','normal', ...
        'fontsize', 0.55, ...
        'horizon','left', ...
        'back',[0.8 0.8 0.8], ...
        'string','Minimum Ratio:', ...
        'position',pos);

   x = x + w;
   y = (num_line-12) * factor_line;
   w = 0.15;

   pos = [x y w h];

   h_min_ratio = uicontrol('parent',h01, ...	% Min. Ratio edit
        'units','normal', ...
        'style','edit', ...
        'fontunits','normal', ...
        'fontsize',0.55, ...
        'horizon','right', ...
        'back',[1 1 1], ...
	'string', '', ...
        'callback','erp_bs_option_ui(''edit_min_ratio'');', ...
        'position',pos);

   %--------------------  selection button -------------------

   x = x + w + 0.1;
   y = (num_line-12) * factor_line;
   w = 0.15;
   h = 1 * factor_line;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% OK button
	'unit','normal', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
	'horizon','center', ...
	'string', 'OK', ...
	'callback', 'erp_bs_option_ui(''click_ok'');', ...
	'position',pos);

   x = x + w + 0.05;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% Cancel button
	'unit','normal', ...
	'fontunit','normal', ...
	'fontsize',0.55, ...
	'hor','center', ...
	'string', 'Cancel', ...
	'callback', 'erp_bs_option_ui(''click_cancel'');', ...
	'position',pos);

   x = 0.01;
   y = 0;
   w = 1;

   pos = [x y w h];

   h1 = uicontrol('parent',h01, ...		% Message Line
   	'style','text', ...
   	'units','normal', ...
	'horizon','left', ...
	'fontunit','normal', ...
   	'fontsize',0.55, ...
   	'back',[0.8 0.8 0.8], ...
   	'fore',[0.8 0.0 0.0], ...
   	'String','', ...
   	'tag', 'MessageLine', ...
	'position',pos);

   bs_name = getappdata(h0,'bs_name');		% bs_name string
   bs_selection = getappdata(h0,'bs_selection') + 1;

   bs_ratio = getappdata(h0,'bs_ratio');
   bs_field = getappdata(h0,'bs_field');

   set(h_bs_edit, 'value', 1, 'string', char(bs_name));

   set(h_bs_disp, 'value', bs_selection, ...
		'string', char([{'(none)'} bs_name]));

   set(h_p_value, 'string', sprintf('%8.5f', bs_field{1}.p_value));
   set(h_thresh, 'string', sprintf('%8.5f', bs_field{1}.thresh));
   set(h_thresh2, 'string', sprintf('%8.5f', bs_field{1}.thresh2));
   set(h_min_ratio, 'string', sprintf('%8.5f', bs_field{1}.min_ratio));
   set(h_max_ratio, 'string', sprintf('%8.5f', bs_field{1}.max_ratio));

   setappdata(h01,'bs_option_fig',h01);
   setappdata(h01,'bs_ratio',bs_ratio);
   setappdata(h01,'h_bs_edit',h_bs_edit);
   setappdata(h01,'h_bs_disp',h_bs_disp);
   setappdata(h01,'h_p_value',h_p_value);
   setappdata(h01,'h_thresh',h_thresh);
   setappdata(h01,'h_thresh2',h_thresh2);
   setappdata(h01,'h_min_ratio',h_min_ratio);
   setappdata(h01,'h_max_ratio',h_max_ratio);

   setappdata(h01,'bs_selection',getappdata(h0,'bs_selection'));
   setappdata(h01,'bs_field',bs_field);

   return;					%  init


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_all: select all the boot straps
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_all

   h_bs_disp = getappdata(gcf, 'h_bs_disp');
   bs_selection = 1 : size(get(h_bs_disp, 'string'), 1);
   set(h_bs_disp, 'value', bs_selection);

   return					% select_all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_lv: select lv to edit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_lv

   h_p_value = getappdata(gcf,'h_p_value');
   h_thresh = getappdata(gcf,'h_thresh');
   h_thresh2 = getappdata(gcf,'h_thresh2');
   h_min_ratio = getappdata(gcf,'h_min_ratio');
   h_max_ratio = getappdata(gcf,'h_max_ratio');

   lv_idx = get(gco,'value');
   bs_field = getappdata(gcf,'bs_field');

   set(h_p_value, 'string', sprintf('%8.5f', bs_field{lv_idx}.p_value));
   set(h_thresh, 'string', sprintf('%8.5f', bs_field{lv_idx}.thresh));
   set(h_thresh2, 'string', sprintf('%8.5f', bs_field{lv_idx}.thresh2));
   set(h_min_ratio, 'string', sprintf('%8.5f', bs_field{lv_idx}.min_ratio));
   set(h_max_ratio, 'string', sprintf('%8.5f', bs_field{lv_idx}.max_ratio));

   return;					% select_lv


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   edit_min_ratio: edit minimum bootstrap ratio field to display
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_min_ratio

   h_bs_edit = getappdata(gcf,'h_bs_edit');
   h_p_value = getappdata(gcf,'h_p_value');
   h_thresh = getappdata(gcf,'h_thresh');
   h_thresh2 = getappdata(gcf,'h_thresh2');
   h_min_ratio = getappdata(gcf,'h_min_ratio');
   h_max_ratio = getappdata(gcf,'h_max_ratio');

   bs_field = getappdata(gcf,'bs_field');
   lv_idx = get(h_bs_edit,'value');
   thresh = str2num(get(h_thresh,'string'));
   thresh2 = str2num(get(h_thresh2,'string'));
   min_ratio = str2num(get(h_min_ratio,'string'));
   max_ratio = str2num(get(h_max_ratio,'string'));

   if isempty(max_ratio) | isempty(min_ratio) | isempty(thresh) | isempty(thresh2) ...
      | thresh < thresh2 | max_ratio < thresh | min_ratio > thresh2

      msg = 'Invalid Minimum Ratio Value';
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      set(h_min_ratio,'string',sprintf('%8.5f',bs_field{lv_idx}.min_ratio));
      return;

   end

   %  update bs_field
   %
   set(h_min_ratio, 'string', sprintf('%8.5f', min_ratio));
   bs_field = getappdata(gcf,'bs_field');
   bs_field{lv_idx}.min_ratio = min_ratio;
   setappdata(gcf, 'bs_field', bs_field);

   return;					% edit_min_ratio


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   edit_max_ratio: edit maximum bootstrap ratio field to display
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_max_ratio

   h_bs_edit = getappdata(gcf,'h_bs_edit');
   h_p_value = getappdata(gcf,'h_p_value');
   h_thresh = getappdata(gcf,'h_thresh');
   h_thresh2 = getappdata(gcf,'h_thresh2');
   h_min_ratio = getappdata(gcf,'h_min_ratio');
   h_max_ratio = getappdata(gcf,'h_max_ratio');

   bs_field = getappdata(gcf,'bs_field');
   lv_idx = get(h_bs_edit,'value');
   thresh = str2num(get(h_thresh,'string'));
   thresh2 = str2num(get(h_thresh2,'string'));
   min_ratio = str2num(get(h_min_ratio,'string'));
   max_ratio = str2num(get(h_max_ratio,'string'));

   if isempty(max_ratio) | isempty(min_ratio) | isempty(thresh) | isempty(thresh2) ...
      | thresh < thresh2 | max_ratio < thresh | min_ratio > thresh2

      msg = 'Invalid Maximum Ratio Value';
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      set(h_max_ratio,'string',sprintf('%8.5f',bs_field{lv_idx}.max_ratio));
      return;

   end

   %  update bs_field
   %
   set(h_max_ratio, 'string', sprintf('%8.5f', max_ratio));
   bs_field = getappdata(gcf,'bs_field');
   bs_field{lv_idx}.max_ratio = max_ratio;
   setappdata(gcf, 'bs_field', bs_field);

   return;					% edit_max_ratio


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   reset_bs_fields: reset bootstrap values to their default values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function reset_bs_fields

   h_bs_edit = getappdata(gcf,'h_bs_edit');
   h_p_value = getappdata(gcf,'h_p_value');
   h_thresh = getappdata(gcf,'h_thresh');
   h_thresh2 = getappdata(gcf,'h_thresh2');
   h_min_ratio = getappdata(gcf,'h_min_ratio');
   h_max_ratio = getappdata(gcf,'h_max_ratio');

   bs_ratio = getappdata(gcf,'bs_ratio');
   bs_field = set_bs_fields(bs_ratio);
   lv_idx = get(h_bs_edit,'value');
   thresh = bs_field{lv_idx}.thresh;
   thresh2 = bs_field{lv_idx}.thresh2;
   p_value = bs_field{lv_idx}.p_value;
   min_ratio = bs_field{lv_idx}.min_ratio;
   max_ratio = bs_field{lv_idx}.max_ratio;

   %  update bs_field
   %
   set(h_thresh, 'string', sprintf('%8.5f', thresh));
   set(h_thresh2, 'string', sprintf('%8.5f', thresh2));
   set(h_p_value, 'string', sprintf('%8.5f', p_value));
   set(h_min_ratio, 'string', sprintf('%8.5f', min_ratio));
   set(h_max_ratio, 'string', sprintf('%8.5f', max_ratio));
   setappdata(gcf, 'bs_field', bs_field);

   return;					% reset_bs_fields


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   set initial bootstrap field
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bs_field = set_bs_fields(bs_ratio)

   bs_field = [];

   if isempty(bs_ratio)			% no bootstrap data -> return;
      return;
   end

   lv_num = size(bs_ratio,2);

   bs95 = percentile(bs_ratio, 95);

   for lv_idx = 1:lv_num

      bs_value.min_ratio = min(bs_ratio(:,lv_idx));
      bs_value.max_ratio = max(bs_ratio(:,lv_idx));

      %  find 95 percentile as initial threshold
      %
      bs_value.thresh = bs95(lv_idx);
      bs_value.thresh2 = -bs_value.thresh;
      bs_value.p_value = UpdatePValue(bs_ratio, lv_idx, bs_value.thresh);

      bs_field{lv_idx} = bs_value;
   end

   return;					% set_bs_fields


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   p_value is updated whenever threshold or LV index is changed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p_value = UpdatePValue(bs_ratio, lv_idx, thresh)

   curr_bs_ratio = bs_ratio(:,lv_idx);
   curr_bs_ratio = curr_bs_ratio(find(isnan(curr_bs_ratio) == 0));

   idx = find(abs(curr_bs_ratio) < std(curr_bs_ratio) * 5); % avoid the outliers
   std_ratio = std(curr_bs_ratio(idx));

   p_value = ratio2p(thresh,0,1);	%std_ratio);

   return;					% UpdatePValue


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   calculate p_value, based on threshold (x) and ratio std (sigma)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  p_value = ratio2p(x,mu,sigma)

   p_value = (1 + erf( (x - mu) / (sqrt(2)*sigma))) / 2;
   p_value = (1 - p_value) * 2;

   return;					% ratio2p


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   click_ok
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function click_ok

   h01 = gcbf;
   h0 = getappdata(h01,'main_fig');
   datamat_file = getappdata(h0,'datamat_file');  % get filename for setting
   view_option = getappdata(h0,'view_option');
   setting = getappdata(h0,'setting');
   bsr = getappdata(h0,'bs_ratio');
   bs_amplitude = getappdata(h0,'bs_amplitude');
   [ti, ch, lv] = size(bs_amplitude);
   bs_amplitude = [];

   % listbox value are taken now, no callback fcn for listbox
   %
   bs_selection = get(getappdata(h01,'h_bs_disp'),'value') - 1;
   if ~isempty(bs_selection)
      setappdata(h01,'bs_selection', bs_selection);
   end

   % collecting setting that may have been changed by callback fcn
   %
   setting.bs_selection = getappdata(h01,'bs_selection');
   setting.bs_field = getappdata(h01,'bs_field');

   old_setting = getappdata(h0, 'setting');

   if isequal(setting,old_setting)		%  nothing was changed
      close(h01);
      return;
   end

   try
      switch view_option
         case {2}
            setting2 = setting;
            save(datamat_file, '-append', 'setting2');
         case {3}
            setting3 = setting;
            save(datamat_file, '-append', 'setting3');
      end
   catch
      msg = 'Cannot save setting information';
      set(findobj(h01,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   for i = 1:size(bsr,2)

      too_large = find(bsr > (setting.bs_field{i}.max_ratio));
      bsr(too_large) = setting.bs_field{i}.max_ratio;

      too_small = find(bsr < (setting.bs_field{i}.min_ratio));
      bsr(too_small) = setting.bs_field{i}.min_ratio;

      bs_amplitude(:,i) = [bsr(:,i)<setting.bs_field{i}.thresh2] | [bsr(:,i)>setting.bs_field{i}.thresh];

   end

   bs_amplitude = reshape(bs_amplitude, [ti, ch, lv]);

   setappdata(h0,'bs_amplitude',bs_amplitude);
   setappdata(h0,'bs_selection',setting.bs_selection);
   setappdata(h0,'bs_field',setting.bs_field);

   setappdata(h0,'setting',setting);
   setappdata(h0, 'init_option',[]);		% means need to redraw

   close(h01);

   old_pointer0 = get(h0,'pointer');
   set(h0,'pointer','watch');

   erp_showplot_ui(h0);

   set(h0,'pointer',old_pointer0);

   return;					% click_ok


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   delete_fig
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      erp_bs_option_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'erp_bs_option_pos');
   catch
   end

   return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   edit_thresh: edit positive threshold field
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_thresh

   h_bs_edit = getappdata(gcf,'h_bs_edit');
   h_p_value = getappdata(gcf,'h_p_value');
   h_thresh = getappdata(gcf,'h_thresh');
   h_thresh2 = getappdata(gcf,'h_thresh2');
   h_min_ratio = getappdata(gcf,'h_min_ratio');
   h_max_ratio = getappdata(gcf,'h_max_ratio');

   bs_field = getappdata(gcf,'bs_field');
   lv_idx = get(h_bs_edit,'value');
   thresh = str2num(get(h_thresh,'string'));
   thresh2 = str2num(get(h_thresh2,'string'));
   min_ratio = str2num(get(h_min_ratio,'string'));
   max_ratio = str2num(get(h_max_ratio,'string'));

   if isempty(max_ratio) | isempty(min_ratio) | isempty(thresh) | isempty(thresh2) ...
      | thresh < thresh2 | max_ratio < thresh | min_ratio > thresh2

      msg = 'Invalid Pos.Thresh Value';
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      set(h_thresh, 'string', sprintf('%8.5f', bs_field{lv_idx}.thresh));
      return;

   end

   %  update p_value
   %
   bs_ratio = getappdata(gcf,'bs_ratio');
   p_value = UpdatePValue(bs_ratio, lv_idx, thresh);
   set(h_p_value, 'string', sprintf('%8.5f', p_value));

   %  update bs_field
   %
   set(h_thresh, 'string', sprintf('%8.5f', thresh));
   bs_field = getappdata(gcf,'bs_field');
   bs_field{lv_idx}.thresh = thresh;
   bs_field{lv_idx}.p_value = p_value;
   setappdata(gcf, 'bs_field', bs_field);

   return;					% edit_thresh


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   edit_thresh2: edit negtive threshold field
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_thresh2

   h_bs_edit = getappdata(gcf,'h_bs_edit');
   h_p_value = getappdata(gcf,'h_p_value');
   h_thresh = getappdata(gcf,'h_thresh');
   h_thresh2 = getappdata(gcf,'h_thresh2');
   h_min_ratio = getappdata(gcf,'h_min_ratio');
   h_max_ratio = getappdata(gcf,'h_max_ratio');

   bs_field = getappdata(gcf,'bs_field');
   lv_idx = get(h_bs_edit,'value');
   thresh = str2num(get(h_thresh,'string'));
   thresh2 = str2num(get(h_thresh2,'string'));
   min_ratio = str2num(get(h_min_ratio,'string'));
   max_ratio = str2num(get(h_max_ratio,'string'));

   if isempty(max_ratio) | isempty(min_ratio) | isempty(thresh) | isempty(thresh2) ...
      | thresh < thresh2 | max_ratio < thresh | min_ratio > thresh2

      msg = 'Invalid Neg.Thresh Value';
      set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      set(h_thresh2, 'string', sprintf('%8.5f', bs_field{lv_idx}.thresh2));
      return;

   end

   %  update p_value
   %
   bs_ratio = getappdata(gcf,'bs_ratio');
   p_value = UpdatePValue(bs_ratio, lv_idx, thresh);
   set(h_p_value, 'string', sprintf('%8.5f', p_value));

   %  update bs_field
   %
   set(h_thresh2, 'string', sprintf('%8.5f', thresh2));
   bs_field = getappdata(gcf,'bs_field');
   bs_field{lv_idx}.thresh2 = thresh2;
   bs_field{lv_idx}.p_value = p_value;
   setappdata(gcf, 'bs_field', bs_field);

   return;					% edit_thresh2

