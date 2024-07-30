function [condition_names,condition_baseline,removed_condition_idx] = ...
                                           fmri_input_condition_ui(varargin) 
% 
%  USAGE: [condition_name,condition_baseline,removed_condition_idx] = ...
%	fmri_input_condition_ui(old_condition,old_baseline,protected_conds) 
% 

   if nargin == 0 
      old_conditions = [];
   end;

   if nargin == 0 | ~ischar(varargin{1})
      old_conditions = [];
      old_condition_baseline = [];
      protected_conds = [];

      if (nargin == 1)
         old_conditions = varargin{1};
      elseif (nargin == 2)
         old_conditions = varargin{1};
         old_condition_baseline = varargin{2};
      elseif (nargin == 3)
         old_conditions = varargin{1};
         old_condition_baseline = varargin{2};
         protected_conds = varargin{3};
      end;

      init(old_conditions,old_condition_baseline,protected_conds);
      uiwait;				% wait for user finish 
      removed_condition_idx = getappdata(gcf,'RemovedConditions');
      condition_names = getappdata(gcf,'CurrConditions');
      condition_baseline = getappdata(gcf,'CurrConditionBaseline');
      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   if strcmp(action,'UPDATE_CONDITION'),
      UpdateCondition;
   elseif strcmp(action,'UPDATE_OFFSET'),
      UpdateOffset;
   elseif strcmp(action,'UPDATE_LENGTH'),
      UpdateLength;
   elseif strcmp(action,'DELETE_CONDITION'),
      DeleteCondition;
   elseif strcmp(action,'ADD_CONDITION'),
      AddCondition;
   elseif strcmp(action,'MOVE_SLIDER'),
      MoveSlider;
   elseif strcmp(action,'DELETE_FIG')
      delete_fig;
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      old_conditions = getappdata(gcf,'OldConditions');
      setappdata(gcf,'CurrConditions',old_conditions);
      uiresume;
   elseif strcmp(action,'DONE_BUTTON_PRESSED'),
      DoneButtonPressed;
   end;
   
   return;


%----------------------------------------------------------------------------
function init(old_conditions,old_condition_baseline,protected_conds)

   curr_dir = pwd;

   save_setting_status = 'on';
   fmri_input_condition_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_input_condition_pos) & strcmp(save_setting_status,'on')

      pos = fmri_input_condition_pos;

   else

      w = 0.6;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','Edit Condition', ...
        'MenuBar','none', ...
        'NumberTitle','off', ...
	'deletefcn','fmri_input_condition_ui(''DELETE_FIG'');', ...
   	'Position',pos, ...
        'WindowStyle', 'modal', ...
   	'Tag','InputCondition', ...
   	'ToolBar','none');
%	'DoubleBuffer', 'on', ...
%	'Renderer', 'OpenGL', ...

   x = 0.11;
   y = 0.9;
   w = 0.21;
   h = 0.06;

   pos = [x y w h];

   fnt = 0.4;

   l_h2 = uicontrol('Parent',h0, ...		% condition name lbl
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'FontWeight','bold', ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Condition Name', ...
        'tooltipstring','Condition Name', ...
   	'Tag','ConditionNameEditLbl');

   x = x+w+0.01;
   w = 0.2;

   pos = [x y w h];

   l_h4 = uicontrol('Parent',h0, ...            % condition offset lbl
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
        'FontSize',fnt, ...
   	'FontWeight','bold', ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Relative Ref. Scan Onset', ...
        'tooltipstring','Reference Scan Onset', ...
        'Tag','ConditionOffsetEditLbl');

   x = x+w+0.01;
   w = 0.2;

   pos = [x y w h];

   l_h5 = uicontrol('Parent',h0, ...            % baseline length lbl
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
        'FontSize',fnt, ...
   	'FontWeight','bold', ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Number of Reference Scans', ...
        'tooltipstring','Number of Reference Scans', ...
        'Tag','ConditionLengthEditLbl');

   x = 0.03;
   y = 0.82;
   w = 0.07;

   pos = [x y w h];

   fnt = fnt+0.1;

   c_h1 = uicontrol('Parent',h0, ...		% condition idx
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','1.', ...
   	'Tag','ConditionIdxLabel');

   x = x+w+0.01;
   w = 0.21;

   pos = [x y w h];

   c_h2 = uicontrol('Parent',h0, ...		% condition name
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
        'tooltipstring','Condition Name', ...
   	'Tag','ConditionNameEdit');

   x = x+w+0.01;
   w = 0.2;

   pos = [x y w h];

   c_h4 = uicontrol('Parent',h0, ...            % condition offset
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
        'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','', ...
        'tooltipstring','Reference scan onset', ...
        'Tag','ConditionOffsetEdit');

   x = x+w+0.01;
   w = 0.2;

   pos = [x y w h];

   c_h5 = uicontrol('Parent',h0, ...            % baseline length
        'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
        'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','', ...
        'tooltipstring','Number of reference scans', ...
        'Tag','ConditionLengthEdit');

   x = x+w+0.01;
   w = 0.12;

   pos = [x y w h];

   c_h3 = uicontrol('Parent',h0, ...		% condition button
   	'Units','normal', ...
   	'Position',pos, ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'String','Add', ...
   	'Tag','ADD/DELButton');

   x = x+w+0.02;
   w = 0.04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% scroll bar
	'Style', 'slider', ...
   	'Units','normal', ...
   	'Min',1, ...
   	'Max',20, ...
   	'Value',20, ...
   	'Position',pos, ...
   	'Callback','fmri_input_condition_ui(''MOVE_SLIDER'');', ...
   	'Tag','CondSlider');

   x = 0.11;
   y = 0.08;
   w = 0.2;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% DONE
        'Units','normal', ...
        'Callback','', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','DONE', ...
   	'Callback','fmri_input_condition_ui(''DONE_BUTTON_PRESSED'');', ...
        'Tag','DONEButton');

   x = 0.67;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% CANCEL
        'Units','normal', ...
        'Callback','', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','CANCEL', ...
   	'Callback','fmri_input_condition_ui(''CANCEL_BUTTON_PRESSED'');', ...
        'Tag','CANCELButton');

   x = 0.01;
   y = 0;
   w = 1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Message Line
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ForegroundColor',[0.8 0.0 0.0], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','', ...
        'Tag','MessageLine');

   cond1_hdls = [c_h1,c_h2,c_h3,c_h4,c_h5];	% save handles for condition#1
   setappdata(h0,'Cond_hlist',cond1_hdls);

   cond_template = copyobj_legacy(cond1_hdls,h0);
   set(cond_template,'visible','off');

   setappdata(h0,'ProtectedConditions',protected_conds);
   setappdata(h0,'OldConditions',old_conditions);
   setappdata(h0,'OldConditionBaseline',old_condition_baseline);
   setappdata(h0,'CurrConditions',old_conditions);
   setappdata(h0,'CurrConditionBaseline',old_condition_baseline);
   setappdata(h0,'ConditionTemplate',cond_template);

   cond_h = 0.06;
   setappdata(h0,'ConditionHeight', cond_h);

   lower_h = 0.01;      % vert. space for Number of rows etc.
   setappdata(h0,'lower_h',lower_h);

   setappdata(h0,'TopConditionIdx',1);
   setappdata(h0,'RemovedConditions',[]);
   setappdata(h0,'ConditionMap',[1:length(old_conditions)]);

   SetupConditionRows;
   SetupSlider;
   CreateAddRow;
   DisplayConditions;
   UpdateSlider;

   return;						% init


%----------------------------------------------------------------------------
function DoneButtonPressed()

   curr_cond = getappdata(gcf,'CurrConditions');
   num_cond = length(curr_cond);

   empty_condition = 0;
   for i=1:num_cond,
      if  isempty(curr_cond{i}),
          empty_condition = 1;
          break;
      end;
   end;

   if (empty_condition)
      msg = 'ERROR: All conditions must have name specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   else
      for i=1:num_cond
         for j=i+1:num_cond
            if(strcmp(curr_cond{i}, curr_cond{j}))
               msg = 'ERROR: No conditions should be duplicated.';
               set(findobj(gcf,'Tag','MessageLine'),'String',msg);
               return;
            end
         end;
      end

      AddCondition;
      uiresume;
   end;

   return;						% DoneButtonPressed


%----------------------------------------------------------------------------
function SetupConditionRows()

   cond_hdls = getappdata(gcf,'Cond_hlist');
   cond_h = getappdata(gcf,'ConditionHeight');
   lower_h = getappdata(gcf,'lower_h');

   bottom_pos = get(findobj(gcf,'Tag','DONEButton'),'Position');
   top_pos = get(cond_hdls(1,2),'Position');

   rows = floor(( top_pos(2) - bottom_pos(2) - lower_h ) / cond_h);

   % A row of vertical positions, at which the 13 4-controls will be located.
   v_pos = top_pos(2) - [0:rows-1]*cond_h;

   cond_template = getappdata(gcf,'ConditionTemplate');
   edit_cbf = 'fmri_input_condition_ui(''UPDATE_CONDITION'');';
   edit_cbf4 = 'fmri_input_condition_ui(''UPDATE_OFFSET'');';
   edit_cbf5 = 'fmri_input_condition_ui(''UPDATE_LENGTH'');';
   delete_cbf = 'fmri_input_condition_ui(''DELETE_CONDITION'');';

   nr = size(cond_hdls,1);		% nr = 1 for the initial
   if (rows < nr)			% too many rows
      for i=rows+1:nr,
          delete(cond_hdls(i,:));
      end;
      cond_hdls = cond_hdls(1:rows,:);
   else					% add new rows to 'rows' amount
      for i=nr+1:rows,
         new_c_hdls = copyobj_legacy(cond_template,gcf);
         cond_hdls = [cond_hdls; new_c_hdls'];
      end;
   end

   v = 'off';
   for i=1:rows
      % take out the handle list created above, and use it in the following 'label,edit,delete'.
      % those handles are valid, since they are all obtained from function copyobj_legacy() above.
      new_c_hdls = cond_hdls(i,:);

      % init label
      pos = get(new_c_hdls(1),'Position'); pos(2) = v_pos(i)-0.01;
      set(new_c_hdls(1),'String','','Position',pos,'Visible',v,'UserData',i);

      % init each edit box setup, insert callback property while doing setup
      pos = get(new_c_hdls(2),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(2),'String','', 'Position',pos, 'Visible',v, ...
                        'UserData',i,'Callback',edit_cbf);

      pos = get(new_c_hdls(4),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(4),'String','', 'Position',pos, 'Visible',v, ...
                        'UserData',i,'Callback',edit_cbf4);

      pos = get(new_c_hdls(5),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(5),'String','', 'Position',pos, 'Visible',v, ...
                        'UserData',i,'Callback',edit_cbf5);

      % init each delete button setup, insert callback property while doing setup
      pos = get(new_c_hdls(3),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(3),'String','Delete','Position',pos,'Visible',v, ...
                        'UserData',i,'Callback',delete_cbf);

   end

   setappdata(gcf,'Cond_hlist',cond_hdls);
   setappdata(gcf,'NumRows',rows);

   return;					% SetupConditionRows


%----------------------------------------------------------------------------
function DisplayConditions()

   protected_cond = getappdata(gcf,'ProtectedConditions');
   cond_map = getappdata(gcf,'ConditionMap');

   curr_cond = getappdata(gcf,'CurrConditions');
   curr_cond_baseline = getappdata(gcf,'CurrConditionBaseline');
   top_cond_idx = getappdata(gcf,'TopConditionIdx');
   cond_hdls = getappdata(gcf,'Cond_hlist');
   rows = getappdata(gcf,'NumRows');

   num_cond = length(curr_cond);

   last_row = 0;
   cond_idx = top_cond_idx;
   for i=1:rows
      c_hdls = cond_hdls(i,:);
      if (cond_idx <= num_cond),
         set(c_hdls(1),'String',sprintf('%d.',cond_idx),'Visible','on');
         set(c_hdls(2),'String',sprintf('%s',curr_cond{cond_idx}), ...
                       'Visible','on');
         set(c_hdls(4),'String',sprintf('%s', ...
			num2str(curr_cond_baseline{cond_idx}(1))), ...
                       'Visible','on');
         set(c_hdls(5),'String',sprintf('%s', ...
			num2str(curr_cond_baseline{cond_idx}(2))), ...
                       'Visible','on');
         set(c_hdls(3),'String','Delete','Visible','on');
         if isempty(protected_cond) | isempty(cond_map) 
             set(c_hdls(3),'String','Delete','Enable','on');
         elseif isempty(find(protected_cond == cond_map(cond_idx)))
             set(c_hdls(3),'String','Delete','Enable','on');
         else
             set(c_hdls(3),'String','Delete','Enable','off');
         end

         cond_idx = cond_idx + 1;
         last_row = i;
      else
         set(c_hdls(1),'String','','Visible','off');
         set(c_hdls(2),'String','','Visible','off');
         set(c_hdls(4),'String','','Visible','off');
         set(c_hdls(5),'String','','Visible','off');
         set(c_hdls(3),'String','Delete','Visible','off');
      end;
   end;

   %  display or hide the add row
   %
   if (last_row < rows)
      row_idx = last_row+1;
      c_hdls = cond_hdls(row_idx,:);
      pos = get(c_hdls(2),'Position');
      ShowAddRow(cond_idx,pos(2),row_idx);
   else
      HideAddRow;
   end;

   %  display or hide the slider
   %
   if (top_cond_idx ~= 1) | (last_row == rows)
     ShowSlider;
   else
     HideSlider;
   end;

   return;						% DisplayConditions


%----------------------------------------------------------------------------
function CreateAddRow()

   cond_template = getappdata(gcf,'ConditionTemplate');

   a_hdls = copyobj_legacy(cond_template,gcf);

   set(a_hdls(1),'String','','Foreground',[0.4 0.4 0.4],'Visible','off', ...
                 'UserData',1);

   set(a_hdls(2),'String','','Enable','on','Background',[1 1 1], ...
		 'Visible','off');

   set(a_hdls(4),'String','0','Enable','on','Background',[1 1 1], ...
                 'Visible','off');

   set(a_hdls(5),'String','1','Enable','on','Background',[1 1 1], ...
                 'Visible','off');

   set(a_hdls(3),'String','Add','Visible','off', ...
		     'Callback','fmri_input_condition_ui(''ADD_CONDITION'');');

   setappdata(gcf,'AddRowHdls',a_hdls);

   return;						% CreateAddRow


%----------------------------------------------------------------------------
function ShowAddRow(cond_idx,v_pos,row_idx)
%
%	Add row with 'Add' button at 'v_pos' position
%	Also display the subject row number, with its 'UserData' updated with row_idx
%

   a_hdls = getappdata(gcf,'AddRowHdls');

   for j=1:length(a_hdls),
      new_pos = get(a_hdls(j),'Position');

      if j==1
         new_pos(2) = v_pos-0.01;
      else
         new_pos(2) = v_pos;
      end

      set(a_hdls(j),'Position',new_pos);
      set(a_hdls(j),'Visible','on');
   end;

   set(a_hdls(2),'String','');
   set(a_hdls(1),'Visible','On','String',sprintf('%d.',cond_idx),'UserData',row_idx);

   return;						% ShowAddRow


%----------------------------------------------------------------------------
function HideAddRow()

   a_hdls = getappdata(gcf,'AddRowHdls');
   for j=1:length(a_hdls),
      set(a_hdls(j),'Visible','off');
   end;

   return;						% HideAddRow


%----------------------------------------------------------------------------
function UpdateCondition(cond_idx)

   curr_cond = getappdata(gcf,'CurrConditions');
   cond_hdls = getappdata(gcf,'Cond_hlist');

   row_idx = get(gcbo,'UserData');
   cond_idx = str2num(get(cond_hdls(row_idx,1),'String'));

   condname = get(gcbo,'String');
   condname = deblank(fliplr(deblank(fliplr(condname))));
   curr_cond{cond_idx} = condname;

   setappdata(gcf,'CurrConditions',curr_cond);

   return;						% UpdateCondition


%----------------------------------------------------------------------------
function DeleteCondition()

   curr_cond = getappdata(gcf,'CurrConditions');
   curr_cond_baseline = getappdata(gcf,'CurrConditionBaseline');
   cond_hdls = getappdata(gcf,'Cond_hlist');
   protected_cond = getappdata(gcf,'ProtectedConditions');
   cond_map = getappdata(gcf,'ConditionMap');

   row_idx = get(gcbo,'UserData');
   cond_idx = str2num(get(cond_hdls(row_idx,1),'String'));

   % check whether the condition is not allowed to be removed 
   %
   if ~isempty(protected_cond) & ~isempty(cond_map) ...
         & ~isempty(find(protected_cond == cond_map(cond_idx)))
      msg = 'ERROR: The condition cannot be removed.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   %  update the removed condition list, don't do it for the new conditions.
   removed_cond = getappdata(gcf,'RemovedConditions');
   if cond_map(cond_idx) ~= 0,
      removed_cond = [removed_cond cond_map(cond_idx)];
   end;

   mask = ones(1,length(curr_cond));  mask(cond_idx) = 0;
   idx = find(mask == 1);
   curr_cond = curr_cond(idx);
   curr_cond_baseline = curr_cond_baseline(idx);
   cond_map = cond_map(idx);

   setappdata(gcf,'RemovedConditions',removed_cond);
   setappdata(gcf,'CurrConditions',curr_cond);
   setappdata(gcf,'CurrConditionBaseline',curr_cond_baseline);
   setappdata(gcf,'ConditionMap',cond_map);

   DisplayConditions;
   UpdateSlider;

   return;						% DeleteCondition


%----------------------------------------------------------------------------
function AddCondition()

   curr_cond = getappdata(gcf,'CurrConditions');
   curr_cond_baseline = getappdata(gcf,'CurrConditionBaseline');
   cond_map = getappdata(gcf,'ConditionMap');

   rows = getappdata(gcf,'NumRows');
   a_hdls = getappdata(gcf,'AddRowHdls');

   cond_idx = str2num(get(a_hdls(1),'String'));
   condname = get(a_hdls(2),'String');
   condname = deblank(fliplr(deblank(fliplr(condname))));
   baseline_offset = str2num(get(a_hdls(4),'String'));
   baseline_length = str2num(get(a_hdls(5),'String'));
   num_cond = length(curr_cond);

%   num_cond = length(curr_cond)+1;
%   curr_cond{num_cond} = '';

   if isempty(condname)
      msg = 'ERROR: All conditions must have name specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   if isempty(baseline_offset) | isempty(baseline_length)
      msg = 'ERROR: Baseline offset and length must be numbers.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   if baseline_length < 1
      msg = 'ERROR: Baseline length should not be less than 1.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   for i=1:num_cond
      if(strcmp(curr_cond{i},condname))
         msg = 'ERROR: No conditions should be duplicated.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end;
   end

   num_cond = num_cond + 1;
   curr_cond{num_cond} = condname;

   curr_cond_baseline{num_cond}(1) = baseline_offset;
   curr_cond_baseline{num_cond}(2) = baseline_length;

   cond_map(num_cond) = 0;

   setappdata(gcf,'CurrConditions',curr_cond);
   setappdata(gcf,'CurrConditionBaseline',curr_cond_baseline);
   setappdata(gcf,'ConditionMap',cond_map);

   new_cond_row = get(a_hdls(1),'UserData');

   if (new_cond_row == rows),  	% the new condition row is the last row
      top_cond_idx = getappdata(gcf,'TopConditionIdx');
      setappdata(gcf,'TopConditionIdx',top_cond_idx+1);
   end;

   DisplayConditions;

   cond_hdls = getappdata(gcf,'Cond_hlist');
   if (new_cond_row == rows),  	% the new condition row is the last row
      set(gcf,'CurrentObject',cond_hdls(rows-1,2));
   else
      set(gcf,'CurrentObject',cond_hdls(new_cond_row,2));
   end;

   UpdateSlider;

   return;						% AddConditions


%----------------------------------------------------------------------------
function MoveSlider()

   slider_hdl = findobj(gcf,'Tag','CondSlider');
   curr_value = round(get(slider_hdl,'Value'));
   total_rows = round(get(slider_hdl,'Max'));

   top_cond_idx = total_rows - curr_value + 1;

   setappdata(gcf,'TopConditionIdx',top_cond_idx);

   DisplayConditions;

   return;						% MoveSlider


%----------------------------------------------------------------------------
function SetupSlider()

   cond_hdls = getappdata(gcf,'Cond_hlist');
   top_pos = get(cond_hdls(1,1),'Position');
   bottom_pos = get(cond_hdls(end,1),'Position');

   slider_hdl = findobj(gcf,'Tag','CondSlider');
   pos = get(slider_hdl,'Position');
   pos(2) = bottom_pos(2);
   pos(4) = top_pos(2)+top_pos(4) - pos(2);
   set(slider_hdl,'Position', pos);

   return;						% SetupSlider


%----------------------------------------------------------------------------
function UpdateSlider()

   top_cond_idx = getappdata(gcf,'TopConditionIdx');
   rows = getappdata(gcf,'NumRows');

   curr_cond = getappdata(gcf,'CurrConditions');
   num_cond = length(curr_cond);

   total_rows = num_cond+1;
   slider_hdl = findobj(gcf,'Tag','CondSlider');

   if (num_cond ~= 0)		% don't need to update when no condition
      set(slider_hdl,'Min',1,'Max',total_rows, ...
                  'Value',total_rows-top_cond_idx+1, ...
                  'Sliderstep',[1/(total_rows-1)-0.00001 1/(total_rows-1)]); 
   end;
   
   return;						% UpdateSlider


%----------------------------------------------------------------------------
function ShowSlider()

   slider_hdl = findobj(gcf,'Tag','CondSlider');
   set(slider_hdl,'visible','on'); 

   return;						% ShowSlider


%----------------------------------------------------------------------------
function HideSlider()

   slider_hdl = findobj(gcf,'Tag','CondSlider');
   set(slider_hdl,'visible','off'); 

   return;						% HideSlider


%----------------------------------------------------------------------------
function UpdateOffset(cond_idx)

   curr_cond_baseline = getappdata(gcf,'CurrConditionBaseline');
   cond_hdls = getappdata(gcf,'Cond_hlist');

   row_idx = get(gcbo,'UserData');
   cond_idx = str2num(get(cond_hdls(row_idx,1),'String'));
   curr_cond_baseline{cond_idx}(1) = str2num(get(gcbo,'String'));

   setappdata(gcf,'CurrConditionBaseline',curr_cond_baseline);

   return;


%----------------------------------------------------------------------------
function UpdateLength(cond_idx)

   curr_cond_baseline = getappdata(gcf,'CurrConditionBaseline');
   cond_hdls = getappdata(gcf,'Cond_hlist');

   row_idx = get(gcbo,'UserData');
   cond_idx = str2num(get(cond_hdls(row_idx,1),'String'));

   old_baseline_length = curr_cond_baseline{cond_idx}(2);
   curr_baseline_length = str2num(get(gcbo,'String'));

   if curr_baseline_length < 1
      set(gcbo,'string',num2str(old_baseline_length));
      msg = 'ERROR: Baseline length should not be less than 1.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   else
      curr_cond_baseline{cond_idx}(2) = str2num(get(gcbo,'String'));
   end

   setappdata(gcf,'CurrConditionBaseline',curr_cond_baseline);

   return;


%----------------------------------------------------------------------------
function delete_fig()

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       fmri_input_condition_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'fmri_input_condition_pos');
    catch
    end
 
    return;

