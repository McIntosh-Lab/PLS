%ERP_COND_MEAN_UI will average user selected conditions, and save the newly created
%	condition into a new condition.
%
%   Usage: [mean_wave_list, mean_wave_name] = ...
%		erp_cond_mean_ui(mean_wave_list, mean_wave_name, org_wave_name)
%
%   see also RRI_CHAGNEPATH_UI

%   Called by ERP_RESULT_UI
%
%   Created on 14-May-2003 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mean_wave_list, mean_wave_name, cond_couple_lst] = ...
	erp_cond_mean_ui(mean_wave_list, mean_wave_name, org_wave_name, cond_couple_lst)

   if ~ischar(mean_wave_list)

      init(mean_wave_list, mean_wave_name, org_wave_name, cond_couple_lst);

      uiwait;						% wait for user finish

      mean_wave_list = getappdata(gcf, 'mean_wave_list');
      mean_wave_name = getappdata(gcf, 'mean_wave_name');
      cond_couple_lst = getappdata(gcf, 'cond_couple_lst');

      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = mean_wave_list;

   if strcmp(action,'click_add'),
      click_add;
   elseif strcmp(action,'click_del'),
      click_del;
   elseif strcmp(action,'click_cond_list')
      click_cond_list;
   elseif strcmp(action,'click_cancel'),
      setappdata(gcf,'mean_wave_list',getappdata(gcf,'old_mean_wave_list'));
      setappdata(gcf,'mean_wave_name',getappdata(gcf,'old_mean_wave_name'));
      setappdata(gcf,'cond_couple_lst',getappdata(gcf,'old_cond_couple_lst'));
      uiresume;
   elseif strcmp(action,'click_ok'),
      uiresume;
   elseif strcmp(action,'delete_fig')
      delete_fig;
   end;

   return;


% --------------------------------------------------------------------

function init(mean_wave_list, mean_wave_name, org_wave_name, cond_couple_lst)

   tit_nam = 'Select conditions to average';

   save_setting_status = 'on';
   erp_cond_mean_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(erp_cond_mean_pos) & strcmp(save_setting_status,'on')

      pos = erp_cond_mean_pos;

   else

      w = 0.7;
      h = 0.4;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name',tit_nam, ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Position',pos, ...
        'DeleteFcn','erp_cond_mean_ui(''delete_fig'');', ...
        'WindowStyle', 'normal', ...
        'ToolBar','none');

   left_margin = 0.05;
   text_height = 0.1;

   x = left_margin;
   y = 0.8;
   w = 0.25;
   h = text_height;

   pos = [x y w h];

   fnt = 0.5;

   h1 = uicontrol('Parent',h0, ...            % cond_list label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'String','Condition List', ...
        'Position',pos);

   y = 0.1;
   h = 0.7;

   pos = [x y w h];

   fnt = 0.07;

   h1 = uicontrol('Parent',h0, ...            % cond_list listbox
        'Style','list', ...
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
	'Max', 2, ...
        'Position',pos, ...
        'String', org_wave_name, ...
        'Callback','erp_cond_mean_ui(''click_cond_list'');', ...
        'Tag','cond_list');

   x = 0.25 + left_margin * 2;
   w = 1 - x * 2;
   y = 0.8;
   h = text_height;

   pos = [x y w h];

   fnt = 0.5;

   h1 = uicontrol('Parent',h0, ...            % cond name label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'String','Name for New Averaged Condition', ...
        'Position',pos);

   y = 0.7;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % cond name edit
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',org_wave_name{1}, ...
        'Tag','cond_name');

   y = 0.1;
   w = 0.14;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % OK
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'HorizontalAlignment','center', ...
        'String','OK', ...
        'Callback','erp_cond_mean_ui(''click_ok'');', ...
        'Position',pos);

   x = 1 - x - w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % CANCEL
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'HorizontalAlignment','center', ...
        'String','Cancel', ...
        'Callback','erp_cond_mean_ui(''click_cancel'');', ...
        'Position',pos);

   x = 0.46;
   y = 0.55;
   w = 0.08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % Add
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'HorizontalAlignment','center', ...
        'String','--->>', ...
        'Callback','erp_cond_mean_ui(''click_add'');', ...
        'Position',pos);

   y = 0.35;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % Delete
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'HorizontalAlignment','center', ...
        'String','<<---', ...
        'Callback','erp_cond_mean_ui(''click_del'');', ...
        'Position',pos);

   x = 1 - left_margin - 0.25;
   y = 0.8;
   w = 0.25;
   h = text_height;

   pos = [x y w h];

   fnt = 0.5;

   h1 = uicontrol('Parent',h0, ...            % mean_list label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'String','Averaged Conditions', ...
        'Position',pos);

   y = 0.1;
   h = 0.7;

   pos = [x y w h];

   fnt = 0.07;

   h1 = uicontrol('Parent',h0, ...            % mean_list listbox
        'Style','list', ...
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
	'Max', 2, ...
        'Position',pos, ...
        'String', mean_wave_name, ...
        'Tag','mean_list');

   x = .01;
   y = 0;
   w = 1;
   h = text_height;

   pos = [x y w h];

   fnt = 0.5;

   c = uicontrol('Parent',h0, ...		% Message Line
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ForegroundColor',[0.8 0.0 0.0], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Tag','MessageLine');

   setappdata(h0, 'org_wave_name', org_wave_name);
   setappdata(h0, 'mean_wave_name', mean_wave_name);
   setappdata(h0, 'mean_wave_list', mean_wave_list);
   setappdata(h0, 'cond_couple_lst', cond_couple_lst);
   setappdata(h0, 'old_mean_wave_name', mean_wave_name);
   setappdata(h0, 'old_mean_wave_list', mean_wave_list);
   setappdata(h0, 'old_cond_couple_lst', cond_couple_lst);

   return;					% init


%----------------------------------------------------------------------------

function delete_fig

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       erp_cond_mean_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'erp_cond_mean_pos');
    catch
    end

   return;					% delete_fig


%----------------------------------------------------------------------------

function click_add

   mean_wave_name = getappdata(gcf, 'mean_wave_name');
   mean_wave_list = getappdata(gcf, 'mean_wave_list');

   org_wave_select = get(findobj(gcf,'Tag','cond_list'), 'value');
   cond_name = get(findobj(gcf,'tag','cond_name'), 'string');

   if isempty(cond_name)
      cond_name = 'new_avg_cond';
   end

   if isempty(org_wave_select)
      msg = 'Please select at least 1 condition';
      set(findobj(gcf,'Tag','MessageLine'),'string',msg);      
      return;
   end

   mean_wave_list = [mean_wave_list {org_wave_select}];
   mean_wave_name = [mean_wave_name {cond_name}];

   setappdata(gcf, 'mean_wave_list', mean_wave_list);
   setappdata(gcf, 'mean_wave_name', mean_wave_name);

   set(findobj(gcf,'Tag','mean_list'), 'value', 1, 'string', mean_wave_name);

   return;					% click_add


%----------------------------------------------------------------------------

function click_del

   mean_wave_name = getappdata(gcf, 'mean_wave_name');
   mean_wave_list = getappdata(gcf, 'mean_wave_list');
   cond_couple_lst = getappdata(gcf, 'cond_couple_lst');
   org_wave_name = getappdata(gcf, 'org_wave_name');

   mean_wave_select = get(findobj(gcf,'Tag','mean_list'), 'value');

   if isempty(mean_wave_select)
      msg = 'Please select at least 1 condition';
      set(findobj(gcf,'Tag','MessageLine'),'string',msg);      
      return;
   end

   mask = ones(1, length(mean_wave_name));
   mask(mean_wave_select) = 0;

   mean_wave_list = mean_wave_list(find(mask));
   mean_wave_name = mean_wave_name(find(mask));

   %  update cond_couple_lst
   %
   mask = ones(size(cond_couple_lst,1),1);

   for i = mean_wave_select
      cond_idx = length(org_wave_name) + i;

      %  find cond_idx and delete from cond_couple_lst
      %
      if ~isempty(cond_couple_lst)
         [r c] = find(cond_couple_lst == cond_idx);
         mask(r) = 0;
      end
   end

   cond_couple_lst = cond_couple_lst(find(mask),:);
   cond_couple_lst(find(cond_couple_lst > cond_idx)) = ...
	cond_couple_lst(find(cond_couple_lst > cond_idx)) - 1;

   setappdata(gcf, 'mean_wave_list', mean_wave_list);
   setappdata(gcf, 'mean_wave_name', mean_wave_name);
   setappdata(gcf, 'cond_couple_lst', cond_couple_lst);

   set(findobj(gcf,'Tag','mean_list'), 'value', 1, 'string', mean_wave_name);

   return;					% click_del


%----------------------------------------------------------------------------

function click_ok

   mean_wave_list = getappdata(gcf, 'mean_wave_list');
   mean_wave = get(findobj(gcf,'Tag','cond_list'), 'value');

   if isempty(mean_wave)
      msg = 'Please select at least 1 condition';
      set(findobj(gcf,'Tag','MessageLine'),'string',msg);      
      return;
   end

   mean_wave_list = [mean_wave_list {mean_wave}];

   mean_wave_name = getappdata(gcf, 'mean_wave_name');
   cond_name = get(findobj(gcf,'tag','cond_name'), 'string');

   if isempty(cond_name)
      cond_name = 'new_avg_cond';
   end

   mean_wave_name = [mean_wave_name, {cond_name}];

   setappdata(gcf, 'mean_wave_list', mean_wave_list);
   setappdata(gcf, 'mean_wave_name', mean_wave_name);
   uiresume;

   return;					% click_ok


%----------------------------------------------------------------------------

function click_cond_list

   org_wave_name = getappdata(gcf, 'org_wave_name');
   org_wave_select = get(findobj(gcf,'Tag','cond_list'), 'value');

   wave_name = org_wave_name(org_wave_select);
   cond_name = [];

   for i = 1:length(wave_name)
      cond_name = [cond_name ' + ' wave_name{i}];
   end

   cond_name = cond_name(4:end);	%  take off first +
   set(findobj(gcf,'tag','cond_name'), 'string', cond_name);

   return;					% click_cond_list

