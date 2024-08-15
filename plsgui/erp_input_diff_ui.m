%ERP_INPUT_DIFF_UI Choosing condition difference couple
%
%   %Usage: new_couple_lst = erp_input_diff_ui(couple_lst, cond_name);
%   Usage: h01 = erp_input_diff_ui(h0);
%
%   See also RRI_INPUT_CONDITION_UI
%

%   %I (couple_lst) - old couple_lst cell array, or action word call recursively
%   %I (cond_name)  - condition name cell array
%   %O (new_couple_lst) - new couple_lst cell array
%   I (h0) - handle of the wave plotting figure
%   O (h01) - handle of the cond_diff choosing figure
%
%   Modified on 7-MAY-2003 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function new_couple_lst = erp_input_diff_ui(varargin)
function h01 = erp_input_diff_ui(varargin)

%   if nargin == 0
%      old_couple_lst = [];
%   end;

   if nargin == 0 | ~ischar(varargin{1})
%      old_couple_lst = varargin{1} + 1;
%      cond_name = [{''} varargin{2}];

   h01 = init(varargin{1});
%      init(old_couple_lst, cond_name);
%      uiwait;				% wait for user finish

%      new_couple_lst = getappdata(gcf,'curr_couple_lst') - 1;

%      [r c] = find(~new_couple_lst);
%      mask = ones(size(new_couple_lst,1),1);
%      mask(r) = 0;
%      new_couple_lst = new_couple_lst(find(mask),:);

%      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   if strcmp(action,'UPDATE_DIFF'),
      UpdateCouple;
   elseif strcmp(action,'EDIT_DIFF'),
      set(findobj(gcbf,'Tag','MessageLine'),'String', ...
	'Use Add Button to add condition couple');
   elseif strcmp(action,'DELETE_DIFF'),
      DeleteCouple;
   elseif strcmp(action,'ADD_DIFF'),
      AddCouple;
   elseif strcmp(action,'MOVE_SLIDER'),
      MoveSlider;
   elseif strcmp(action,'DELETE_FIG')
      delete_fig;
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
%      old_couple_lst = getappdata(gcf,'old_couple_lst');
%      setappdata(gcf,'curr_couple_lst',old_couple_lst);
%      uiresume;
      close(gcf);
   elseif strcmp(action,'DONE_BUTTON_PRESSED'),
%      uiresume;
      click_ok;
   end;

   return;


%----------------------------------------------------------------------------

%function init(old_couple_lst, cond_name)
function h01 = init(h0)

   old_couple_lst = getappdata(h0,'cond_couple_lst') + 1;
   cond_name = [{''} getappdata(h0,'org_wave_name') getappdata(h0,'mean_wave_name')];

   save_setting_status = 'on';
   input_diff_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(input_diff_pos) & strcmp(save_setting_status,'on')

      pos = input_diff_pos;

   else

      w = 0.6;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h01 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','Choose Condition Difference Couple', ...
        'MenuBar','none', ...
        'NumberTitle','off', ...
	'deletefcn','erp_input_diff_ui(''DELETE_FIG'');', ...
   	'Position',pos, ...
        'WindowStyle', 'modal', ...
   	'ToolBar','none');
%	'DoubleBuffer', 'on', ...
%	'Renderer', 'OpenGL', ...

   x = 0.06;
   y = 0.9;
   w = 1;
   h = 0.06;

   pos = [x y w h];

   c = uicontrol('Parent',h01, ...
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.6, ...
	'FontName', 'FixedWidth', ...
   	'FontAngle','italic', ...
   	'FontWeight','bold', ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Choose Condition Difference Couple: ');

   x = 0.03;
   y = 0.83;
   w = 0.07;

   pos = [x y w h];

   c_h1 = uicontrol('Parent',h01, ...		% couple idx
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','right', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','1.');

   x = x+w+0.01;
   w = 0.29;

   pos = [x y w h];

   c_h2 = uicontrol('Parent',h01, ...		% condition 1 name
   	'Style','popupmenu', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String',cond_name);

   x = x+w+0.01;
   w = 0.03;

   pos = [x y w h];

   c_h3 = uicontrol('Parent',h01, ...		% minus sign
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','-');

   x = x+w+0.01;
   w = 0.29;

   pos = [x y w h];

   c_h4 = uicontrol('Parent',h01, ...		% condition 2 name
   	'Style','popupmenu', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String',cond_name);

   x = x+w+0.01;
   w = 0.12;

   pos = [x y w h];

   c_h5 = uicontrol('Parent',h01, ...		% add / delete button
   	'Units','normal', ...
   	'Position',pos, ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'ListboxTop',0, ...
   	'String','Add');

   x = x+w+0.02;
   w = 0.04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h01, ...		% scroll bar
	'Style', 'slider', ...
   	'Units','normal', ...
   	'Min',1, ...
   	'Max',20, ...
   	'Value',20, ...
   	'Position',pos, ...
   	'Callback','erp_input_diff_ui(''MOVE_SLIDER'');', ...
   	'Tag','CondSlider');

   x = 0.11;
   y = 0.08;
   w = 0.2;

   pos = [x y w h];

   h1 = uicontrol('Parent',h01, ...			% DONE
        'Units','normal', ...
        'Callback','', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','OK', ...
   	'Callback','erp_input_diff_ui(''DONE_BUTTON_PRESSED'');', ...
        'Tag','DONEButton');

   x = 0.67;

   pos = [x y w h];

   h1 = uicontrol('Parent',h01, ...			% CANCEL
        'Units','normal', ...
        'Callback','', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Cancel', ...
   	'Callback','erp_input_diff_ui(''CANCEL_BUTTON_PRESSED'');', ...
        'Tag','CANCELButton');

   x = 0.01;
   y = 0;
   w = 1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h01, ...			% Message Line
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ForegroundColor',[0.8 0.0 0.0], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','', ...
        'Tag','MessageLine');

   couple1_hdls = [c_h1,c_h2,c_h3,c_h4,c_h5];		% save handles for row
   setappdata(h01,'couple_hlist',couple1_hdls);

   couple_template = copyobj_legacy(couple1_hdls,h01);
   set(couple_template,'visible','off');

   setappdata(h01,'old_couple_lst',old_couple_lst);
   setappdata(h01,'curr_couple_lst',old_couple_lst);
   setappdata(h01,'couple_template',couple_template);

   cond_h = 0.06;
   setappdata(h01,'ConditionHeight', cond_h);

   lower_h = 0.01;      % vert. space for Number of rows etc.
   setappdata(h01,'lower_h',lower_h);

   setappdata(h01,'top_couple_idx',1);

   SetupCoupleRows;
   SetupSlider;
   CreateAddRow;
   DisplayCouple;
   UpdateSlider;

   return;						% init


%----------------------------------------------------------------------------
function SetupCoupleRows()

   couple_hdls = getappdata(gcf,'couple_hlist');
   cond_h = getappdata(gcf,'ConditionHeight');
   lower_h = getappdata(gcf,'lower_h');

   bottom_pos = get(findobj(gcf,'Tag','DONEButton'),'Position');
   top_pos = get(couple_hdls(1,2),'Position');

   rows = floor(( top_pos(2) - bottom_pos(2) - lower_h ) / cond_h);

   % A row of vertical positions, at which the 13 4-controls will be located.
   v_pos = top_pos(2) - [0:rows-1]*cond_h;

   couple_template = getappdata(gcf,'couple_template');
   edit_cbf = 'erp_input_diff_ui(''UPDATE_DIFF'');';
   delete_cbf = 'erp_input_diff_ui(''DELETE_DIFF'');';

   nr = size(couple_hdls,1);		% nr = 1 for the initial
   if (rows < nr)			% too many rows
      for i=rows+1:nr,
          delete(couple_hdls(i,:));
      end;
      couple_hdls = couple_hdls(1:rows,:);
   else					% add new rows to 'rows' amount
      for i=nr+1:rows,
         new_c_hdls = copyobj_legacy(couple_template,gcf);
         couple_hdls = [couple_hdls; new_c_hdls'];
      end;
   end

   v = 'off';
   for i=1:rows
      % take out the handle list created above, and use it in the following 'label,edit,delete'.
      % those handles are valid, since they are all obtained from function copyobj_legacy() above.
      new_c_hdls = couple_hdls(i,:);

      % init label
      pos = get(new_c_hdls(1),'Position'); pos(2) = v_pos(i)-0.01;
      set(new_c_hdls(1),'String','','Position',pos,'Visible',v,'UserData',i);

      % init each edit box setup, insert callback property while doing setup
      pos = get(new_c_hdls(2),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(2), 'Position',pos, 'Visible',v, ...
                        'UserData',[i,1],'Callback',edit_cbf);

      % init each edit box setup, insert callback property while doing setup
      pos = get(new_c_hdls(3),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(3), 'Position',pos, 'Visible',v, ...
                        'UserData',i);

      % init each edit box setup, insert callback property while doing setup
      pos = get(new_c_hdls(4),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(4), 'Position',pos, 'Visible',v, ...
                        'UserData',[i,2],'Callback',edit_cbf);

      % init each delete button setup, insert callback property while doing setup
      pos = get(new_c_hdls(5),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(5),'String','Delete','Position',pos,'Visible',v, ...
                        'UserData',i,'Callback',delete_cbf);

   end

   setappdata(gcf,'couple_hlist',couple_hdls);
   setappdata(gcf,'NumRows',rows);

   return;					% SetupCoupleRows


%----------------------------------------------------------------------------
function DisplayCouple()

   curr_couple_lst = getappdata(gcf,'curr_couple_lst');
   top_couple_idx = getappdata(gcf,'top_couple_idx');

   couple_hdls = getappdata(gcf,'couple_hlist');
   rows = getappdata(gcf,'NumRows');

   num_couple = size(curr_couple_lst, 1);
   couple_idx = top_couple_idx;
   last_row = 0;

   for i=1:rows
      c_hdls = couple_hdls(i,:);
      if (couple_idx <= num_couple),
         set(c_hdls(1),'string',sprintf('%d.',couple_idx),'visible','on');
         set(c_hdls(2),'value',curr_couple_lst(couple_idx,1),'visible','on');
         set(c_hdls(3),'visible','on');
         set(c_hdls(4),'value',curr_couple_lst(couple_idx,2),'visible','on');
         set(c_hdls(5),'string','Delete','visible','on');

         couple_idx = couple_idx + 1;
         last_row = i;
      else
         set(c_hdls(1),'String','','Visible','off');
         set(c_hdls(2),'Visible','off');
         set(c_hdls(3),'Visible','off');
         set(c_hdls(4),'Visible','off');
         set(c_hdls(5),'String','Delete','Visible','off');
      end;
   end;

   %  display or hide the add row
   %
   if (last_row < rows)
      row_idx = last_row+1;
      c_hdls = couple_hdls(row_idx,:);
      pos = get(c_hdls(2),'Position');
      ShowAddRow(couple_idx,pos(2),row_idx);
   else
      HideAddRow;
   end;

   %  display or hide the slider
   %
   if (top_couple_idx ~= 1) | (last_row == rows)
     ShowSlider;
   else
     HideSlider;
   end;

   return;						% DisplayCouple


%----------------------------------------------------------------------------
function CreateAddRow()

%   edit_cbf = 'erp_input_diff_ui(''EDIT_DIFF'');';
   edit_cbf = 'set(findobj(gcf,''Tag'',''MessageLine''),''string'',';
   edit_cbf = [edit_cbf, '''Use Add Button to add condition couple'');'];

   couple_template = getappdata(gcf,'couple_template');
   a_hdls = copyobj_legacy(couple_template,gcf);


   set(a_hdls(1),'String','','Foreground',[0.4 0.4 0.4],'Visible','off', ...
                 'UserData',1);

   set(a_hdls(2),'String',[' '],'Enable','off','Background',[0.9 0.9 0.9], ...
		 'Visible','off','buttondown',edit_cbf);

   set(a_hdls(3),'String','-','Enable','on','Background',[0.8 0.8 0.8], ...
		 'Visible','off');

   set(a_hdls(4),'String',[' '],'Enable','off','Background',[0.9 0.9 0.9], ...
		 'Visible','off','buttondown',edit_cbf);

   set(a_hdls(5),'String','Add','Visible','off', ...
		     'callback','erp_input_diff_ui(''ADD_DIFF'');');

   setappdata(gcf,'AddRowHdls',a_hdls);

   return;						% CreateAddRow


%----------------------------------------------------------------------------
function ShowAddRow(couple_idx,v_pos,row_idx)
%
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

   set(a_hdls(1),'Visible','On','String',sprintf('%d.',couple_idx),'UserData',row_idx);

   return;						% ShowAddRow


%----------------------------------------------------------------------------
function HideAddRow()

   a_hdls = getappdata(gcf,'AddRowHdls');
   for j=1:length(a_hdls),
      set(a_hdls(j),'Visible','off');
   end;

   return;						% HideAddRow


%----------------------------------------------------------------------------
%function UpdateCouple(couple_idx)
function UpdateCouple

   curr_couple_lst = getappdata(gcf,'curr_couple_lst');
   couple_hdls = getappdata(gcf,'couple_hlist');

   user_idx = get(gcbo,'UserData');
   row_idx = user_idx(1);
   col_idx = user_idx(2);
   col2_idx = 2 - col_idx + 1;
   couple_idx = str2num(get(couple_hdls(row_idx,1),'String'));
   old_value = curr_couple_lst(couple_idx,col_idx);
   curr_couple_lst(couple_idx,col_idx) = get(gcbo,'value');

   if curr_couple_lst(couple_idx,col_idx) == curr_couple_lst(couple_idx,col2_idx)
      set(findobj(gcbf,'Tag','MessageLine'),'String', ...
	'Choose different condition for difference');
      set(gcbo,'value',old_value);
      return;
   end

   setappdata(gcf,'curr_couple_lst',curr_couple_lst);

   return;						% UpdateCouple


%----------------------------------------------------------------------------
function DeleteCouple()

   curr_couple_lst = getappdata(gcf,'curr_couple_lst');
   couple_hdls = getappdata(gcf,'couple_hlist');

   row_idx = get(gcbo,'UserData');
   couple_idx = str2num(get(couple_hdls(row_idx,1),'String'));

   mask = ones(1,size(curr_couple_lst,1));  mask(couple_idx) = 0;
   idx = find(mask == 1);
   curr_couple_lst = curr_couple_lst(idx,:);

   setappdata(gcf,'curr_couple_lst',curr_couple_lst);

   DisplayCouple;
   UpdateSlider;

   return;						% DeleteCouple


%----------------------------------------------------------------------------
function AddCouple()

   curr_couple_lst = getappdata(gcf,'curr_couple_lst');
   rows = getappdata(gcf,'NumRows');
   a_hdls = getappdata(gcf,'AddRowHdls');
   couple_idx = str2num(get(a_hdls(1),'String'));
   num_couple = size(curr_couple_lst,1);

   num_couple = num_couple + 1;
   curr_couple_lst(num_couple,1) = 1;
   curr_couple_lst(num_couple,2) = 1;

   setappdata(gcf,'curr_couple_lst',curr_couple_lst);

   new_couple_row = get(a_hdls(1),'UserData');

   if (new_couple_row == rows),  	% the new couple row is the last row
      top_couple_idx = getappdata(gcf,'top_couple_idx');
      setappdata(gcf,'top_couple_idx',top_couple_idx+1);
   end;

   DisplayCouple;

   couple_hdls = getappdata(gcf,'couple_hlist');

   if (new_couple_row == rows),  	% the new couple row is the last row
      set(gcf,'CurrentObject',couple_hdls(rows-1,2));
   else
      set(gcf,'CurrentObject',couple_hdls(new_couple_row,2));
   end;

   UpdateSlider;

   return;						% AddCouple


%----------------------------------------------------------------------------
function MoveSlider()

   slider_hdl = findobj(gcf,'Tag','CondSlider');
   curr_value = round(get(slider_hdl,'Value'));
   total_rows = round(get(slider_hdl,'Max'));

   top_couple_idx = total_rows - curr_value + 1;

   setappdata(gcf,'top_couple_idx',top_couple_idx);

   DisplayCouple;

   return;						% MoveSlider


%----------------------------------------------------------------------------
function SetupSlider()

   couple_hdls = getappdata(gcf,'couple_hlist');
   top_pos = get(couple_hdls(1,3),'Position');
   bottom_pos = get(couple_hdls(end,3),'Position');

   slider_hdl = findobj(gcf,'Tag','CondSlider');
   pos = get(slider_hdl,'Position');
   pos(2) = bottom_pos(2);
   pos(4) = top_pos(2)+top_pos(4) - pos(2);
   set(slider_hdl,'Position', pos);

   return;						% SetupSlider


%----------------------------------------------------------------------------
function UpdateSlider()

   top_couple_idx = getappdata(gcf,'top_couple_idx');
   rows = getappdata(gcf,'NumRows');

   curr_couple_lst = getappdata(gcf,'curr_couple_lst');
   num_couple = size(curr_couple_lst,1);

   total_rows = num_couple+1;
   slider_hdl = findobj(gcf,'Tag','CondSlider');

   if (num_couple ~= 0)		% don't need to update when no couple
      set(slider_hdl,'Min',1,'Max',total_rows, ...
                  'Value',total_rows-top_couple_idx+1, ...
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
function delete_fig

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       input_diff_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'input_diff_pos');
    catch
    end

    return;


%----------------------------------------------------------------------------
function click_ok

   h01 = gcbf;
   h0 = getappdata(h01,'main_fig');
   datamat_file = getappdata(h0,'datamat_file');  % get filename for setting
   setting = getappdata(h0,'setting');

   new_couple_lst = getappdata(h01,'curr_couple_lst') - 1;

   %  get rid of 0 in new_couple_lst
   %
   [r c] = find(~new_couple_lst);
   mask = ones(size(new_couple_lst,1),1);
   mask(r) = 0;
   new_couple_lst = new_couple_lst(find(mask),:);

   setting.cond_couple_lst = new_couple_lst;
   old_setting = getappdata(h0, 'setting');

   if isequal(setting,old_setting)		%  nothing was changed
      close(h01);
      return;
   end

   try
      setting2 = setting;
      save(datamat_file, '-append', 'setting2');
   catch
      msg = 'Cannot save setting information';
      set(findobj(h01,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      return;
   end;

   wave_amplitude = getappdata(h0,'org_wave_amplitude');
   [dim1 dim2 dim3] = size(wave_amplitude);

   if ~isempty(new_couple_lst)
      for i = 1:size(new_couple_lst,1)
         wave_amplitude(:,:,dim3+i) = ...
		wave_amplitude(:,:,new_couple_lst(i,1)) - ...
		wave_amplitude(:,:,new_couple_lst(i,2));
      end
   end

   org_selected_wave = getappdata(h0,'org_selected_wave');
   org_wave_name = getappdata(h0,'org_wave_name');
   mean_wave_name = getappdata(h0,'mean_wave_name');

   selected_wave = [org_selected_wave ...
	length(org_selected_wave)+[1:length(mean_wave_name)] ...
	length(org_selected_wave)+length(mean_wave_name)+[1:size(new_couple_lst,1)]];
%	[org_selected_wave length(org_selected_wave)+[1:size(new_couple_lst,1)]];

   wave_selection = getappdata(h0,'wave_selection');
   wave_selection = wave_selection(find(wave_selection <= length(org_selected_wave)));
   wave_selection = ...
	[wave_selection length(org_selected_wave)+length(mean_wave_name)+[1:size(new_couple_lst,1)]];

   wave_name = [org_wave_name, mean_wave_name];

   %  couple name
   %
   couple_name = cell(1,size(new_couple_lst,1));

   for i = 1:size(new_couple_lst,1)
      couple_name{i} = ...
	[wave_name{new_couple_lst(i,1)} ' - ' wave_name{new_couple_lst(i,2)}];
%	['cond' num2str(new_couple_lst(i,1)) ' - cond' num2str(new_couple_lst(i,2))];
   end

   wave_name = [wave_name, couple_name];

   setappdata(h0,'brain_amplitude',wave_amplitude);
   setappdata(h0,'wave_amplitude',wave_amplitude);
   setappdata(h0,'selected_wave',selected_wave);
   setappdata(h0,'wave_selection',wave_selection);
   setappdata(h0,'wave_name',wave_name);
   setappdata(h0,'cond_couple_lst',new_couple_lst);

   setappdata(h0,'setting',setting);
   setappdata(h0,'init_option',[]);

   close(h01);

   old_pointer0 = get(h0,'pointer');
   set(h0,'pointer','watch');

   erp_showplot_ui(h0);

   set(h0,'pointer',old_pointer0);

   return;					% click_ok

