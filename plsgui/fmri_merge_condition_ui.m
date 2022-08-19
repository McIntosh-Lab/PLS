function [merged_conditions] = fmri_merge_condition_ui(varargin) 
% 
%  USAGE: [merged_conditions] = fmri_merge_condition_ui(condition) 
% 
   if nargin == 0 
      old_conditions = [];
   elseif (nargin > 1)
      return;
   end;


   if nargin == 0 | ~ischar(varargin{1})
      old_conditions = [];

      if (nargin == 1) 
         old_conditions = varargin{1};
      end;
      
      init(old_conditions);
      uiwait;				% wait for user finish 
      merged_conditions = getappdata(gcf,'MergedConditions');
      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   if strcmp(action,'MOVE_UP'),
      MoveUpOneCondition;
   elseif strcmp(action,'MOVE_DOWN'),
      MoveDownOneCondition;
   elseif strcmp(action,'COMBINE_BUTTON'),
      MergeConditions;
   elseif strcmp(action,'DONE_BUTTON'),
      uiresume;
   elseif strcmp(action,'CANCEL_BUTTON'),
      setappdata(gcf,'MergedConditions',[]);
      uiresume;
   elseif strcmp(action,'DELETE_FIG'),
      delete_fig;
   end;
   
   return;


%----------------------------------------------------------------------------
function init(old_conditions)

   curr_dir = pwd;

   save_setting_status = 'on';
   fmri_merge_condition_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_merge_condition_pos) & strcmp(save_setting_status,'on')

      pos = fmri_merge_condition_pos;

   else

      w = 0.5;
      h = 0.6;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','Merge Conditions', ...
        'NumberTitle','off', ...
        'WindowStyle', 'modal', ...
        'MenuBar','none', ...
   	'Tag','MergeConditions', ...
   	'Position',pos, ...
	'deletefcn','fmri_merge_condition_ui(''DELETE_FIG'');', ...
   	'ToolBar','none');

   x = .05;
   y = .9;
   w = 1-2*x;
   h = .06;

   pos = [x y w h];

   fnt = 0.6;

   c = uicontrol('Parent',h0, ...		% condition label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
	'FontName', 'FixedWidth', ...
   	'FontAngle','italic', ...
   	'FontWeight','bold', ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Conditions', ...
   	'Tag','ConditionTitleLabel');

   y = .2;
   w = 1-2*x-.25;
   h = .65;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% condition list box
   	'Style','listbox', ...
   	'Units','normal', ...
	'fontunit','normal',...
   	'FontSize',0.05, ...
   	'HorizontalAlignment','left', ...
        'Min',1, ...
        'Max',3, ...
   	'ListboxTop',1, ...
   	'Position',pos, ...
   	'String','', ...
   	'Tag','ConditionListBox');

   x = 1 - .25;
   y = .7;
   w = .2;
   h = .06;

   pos = [x y w h];

   fnt = fnt-0.1;

   c = uicontrol('Parent',h0, ...			% UP
        'Units','normal', ...
	'fontunit','normal',...
        'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','UP', ...
   	'Callback','fmri_merge_condition_ui(''MOVE_UP'');', ...
        'Tag','UPButton');

   y = y-.08;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...			% DOWN
        'Units','normal', ...
	'fontunit','normal',...
        'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','DOWN', ...
   	'Callback','fmri_merge_condition_ui(''MOVE_DOWN'');', ...
        'Tag','DOWNButton');


   y = .3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...			% COMBINE BUTTON
        'Units','normal', ...
	'fontunit','normal',...
        'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','COMBINE', ...
   	'Callback','fmri_merge_condition_ui(''COMBINE_BUTTON'');', ...
        'Tag','COMBINEButton');

   x = .1;
   y = .1;
   w = .2;
   h = .06;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...			% DONE BUTTON
        'Units','normal', ...
	'fontunit','normal',...
        'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','DONE', ...
   	'Callback','fmri_merge_condition_ui(''DONE_BUTTON'');', ...
        'Tag','DONEButton');

   x = 1-w-.35;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...			% CANCEL BUTTON
        'Units','normal', ...
	'fontunit','normal',...
        'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','CANCEL', ...
   	'Callback','fmri_merge_condition_ui(''CANCEL_BUTTON'');', ...
        'Tag','CANCELButton');

   x = .01;
   y = 0;
   w = 1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               	% Message Line
        'Style','text', ...
        'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
        'ForegroundColor',[0.8 0.0 0.0], ...
	'fontunit','normal',...
        'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','', ...
        'Tag','MessageLine');              


   for i=1:length(old_conditions),
      MergedCondition(i).name = old_conditions{i};
      MergedCondition(i).cond_idx = i;
   end;

   setappdata(h0,'MergedConditions',MergedCondition);
   setappdata(h0,'OldConditions',old_conditions);
   setappdata(h0,'CurrConditions',old_conditions);
   setappdata(h0,'NumRows',15);

   ShowConditions;

   return;						% init


%----------------------------------------------------------------------------
function ShowConditions()

   curr_cond = getappdata(gcf,'CurrConditions');
   num_cond = length(curr_cond);

   h = findobj(gcf,'Tag','ConditionListBox');
   set(h,'String',curr_cond);

   return;						% DoneButtonPressed


%----------------------------------------------------------------------------
function MoveUpOneCondition()

   merged_cond = getappdata(gcf,'MergedConditions');
   curr_cond = getappdata(gcf,'CurrConditions');
   num_rows = getappdata(gcf,'NumRows');

   h = findobj(gcf,'Tag','ConditionListBox');
   curr_value = get(h,'Value');
   list_top = get(h,'ListBoxTop');

   if isempty(curr_value) | (curr_value(1) == 1)
      return;
   end;

   num_selected = length(curr_value);
   range = curr_value(1):(curr_value(1)+num_selected-1);
   if (num_selected > 1) & ~isequal(range,curr_value),
      errmsg = 'ERROR: only allow to move consecutive conditions';
      set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
      return;
   end;

   for i=range,
     temp_buffer = curr_cond(i-1);
     curr_cond(i-1) = curr_cond(i);
     curr_cond(i) = temp_buffer;

     temp_buffer = merged_cond(i-1);
     merged_cond(i-1) = merged_cond(i);
     merged_cond(i) = temp_buffer;
   end;

   curr_value = curr_value - 1;
   set(h,'String',curr_cond,'Value',curr_value);

   if (curr_value(1) < list_top)
      set(h,'ListBoxTop',curr_value(1));
   else
      set(h,'ListBoxTop',list_top);
   end;
   setappdata(gcf,'CurrConditions',curr_cond);
   setappdata(gcf,'MergedConditions',merged_cond);

   return;					% MoveUpOneCondition


%----------------------------------------------------------------------------
function MoveDownOneCondition()

   merged_cond = getappdata(gcf,'MergedConditions');
   curr_cond = getappdata(gcf,'CurrConditions');
   num_rows = getappdata(gcf,'NumRows');

   h = findobj(gcf,'Tag','ConditionListBox');
   curr_value = get(h,'Value');
   list_top = get(h,'ListBoxTop');

   if isempty(curr_value) | (curr_value(end) == length(curr_cond))
      return;
   end;

   num_selected = length(curr_value);
   range = curr_value(1):(curr_value(1)+num_selected-1);
   if (num_selected > 1) & ~isequal(range,curr_value),
      errmsg = 'ERROR: only allow to move consecutive conditions';
      set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
      return;
   end;

   for i=range(num_selected:-1:1),
     temp_buffer = curr_cond(i+1);
     curr_cond(i+1) = curr_cond(i);
     curr_cond(i) = temp_buffer;

     temp_buffer = merged_cond(i+1);
     merged_cond(i+1) = merged_cond(i);
     merged_cond(i) = temp_buffer;
   end;

   curr_value = curr_value + 1;
   set(h,'String',curr_cond,'Value',curr_value);

   if (curr_value(1) >= (list_top+num_rows))
      set(h,'ListBoxTop',curr_value(1));
   else
      set(h,'ListBoxTop',list_top);
   end;
   setappdata(gcf,'CurrConditions',curr_cond);
   setappdata(gcf,'MergedConditions',merged_cond);

   return;					% MoveDownOneCondition


%----------------------------------------------------------------------------
function MergeConditions()

   merged_cond = getappdata(gcf,'MergedConditions');
   curr_cond = getappdata(gcf,'CurrConditions');
   h = findobj(gcf,'Tag','ConditionListBox');
   curr_value = get(h,'Value');
   list_top = get(h,'ListBoxTop');

   num_selected = length(curr_value);
   if (num_selected <= 1),
      return;
   end;

   prompt = 'Enter the name for the newly combined condition';
   title = 'Condition Name';
   num_line = 1;
   merged_condition_name = inputdlg(prompt,title,num_line);

   if isempty(merged_condition_name) | isempty(merged_condition_name{1})
      return;
   end;

   mask = zeros(1,length(curr_cond));
   mask(curr_value) = 1;
   mask(curr_value(1)) = 0;
   cond_idx = find(mask == 0);

   curr_cond(curr_value(1)) = merged_condition_name;

   merged_cond(curr_value(1)).name = merged_condition_name{1};
   merged_cond(curr_value(1)).cond_idx = [merged_cond(curr_value).cond_idx];

   new_curr_cond = curr_cond(cond_idx); 
   new_merged_cond = merged_cond(cond_idx);

   if (list_top > curr_value(1)),
      list_top = curr_value(1);
   end;
   setappdata(gcf,'MergedConditions',new_merged_cond);
   setappdata(gcf,'CurrConditions',new_curr_cond);
   set(h,'String',new_curr_cond,'Value',curr_value(1),'ListBoxTop',list_top);
   
   return;					% MergeConditions


%----------------------------------------------------------------------------
function delete_fig

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');
 
       fmri_merge_condition_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'fmri_merge_condition_pos');
    catch
    end

    return;

