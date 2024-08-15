function [subj_name, subjects, subj_files, num_subj_init, filter] = ...
		struct_input_subject_ui(varargin)

   if nargin == 0 | ~ischar(varargin{1})
      old_subj_name = varargin{1};  
      old_subjects = varargin{2};  
      old_subj_files = varargin{3};
      condition = varargin{4};
      selected_conditions = varargin{5};
      num_subj_init = varargin{6};
      filter = varargin{7};
      cond_filter = varargin{8};
      dataset_dir = varargin{9};

      init(old_subj_name, old_subjects, num_subj_init, filter, cond_filter, dataset_dir);

      setappdata(gcf,'old_subj_files',old_subj_files);
      setappdata(gcf,'subj_files',old_subj_files);
      setappdata(gcf,'condition',condition);
      setappdata(gcf,'selected_conditions',selected_conditions);
      setappdata(gcf,'SessionPLSDir',getappdata(gcbf, 'SessionPLSDir'));

      uiwait;				% wait for user finish 

      subj_name = getappdata(gcf,'curr_subj_name');
      subjects = getappdata(gcf,'CurrSubjects');
      subj_files = getappdata(gcf,'subj_files');
      filter = getappdata(gcf,'filter');
      h = findobj(gcf,'Tag','SubjectInitEdit');
      if ~isempty(h)
         num_subj_init = str2num(get(h, 'string'));
      end

      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   if strcmp(action,'UPDATE_SUBJECT'),
      UpdateSubject;
   elseif strcmp(action,'EDIT_SUBJ_NAME'),
      EditSubjName;
   elseif strcmp(action,'DELETE_SUBJECT'),
      DeleteSubject;
   elseif strcmp(action,'ADD_SUBJECT'),
      AddSubject;
   elseif strcmp(action,'EDIT_SUBJECT'),
      EditSubject;
   elseif strcmp(action,'BUTTONDOWN_SUBJECTS'),
      msg = 'Use Add button to add the subject';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'MOVE_SLIDER'),
      MoveSlider;
   elseif strcmp(action,'SUBJ_INIT_EDIT'),
      subj_init_edit;
   elseif strcmp(action,'DELETE_FIG'),
      delete_fig;
   elseif strcmp(action,'TOGGLE_FULL_PATH'),
      SwitchFullPath;
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      old_subj_name = getappdata(gcf,'old_subj_name');
      old_subjects = getappdata(gcf,'OldSubjects');
      old_subj_files = getappdata(gcf,'old_subj_files');

      setappdata(gcf,'curr_subj_name',old_subj_name);
      setappdata(gcf,'CurrSubjects',old_subjects);
      setappdata(gcf,'subj_files',old_subj_files);

      uiresume;
   elseif strcmp(action,'DONE_BUTTON_PRESSED'),
      DoneButtonPressed;
   end;

   return;


%----------------------------------------------------------------------------

function init(old_subj_name, old_subjects, num_subj_init, filter, cond_filter, dataset_dir)

   save_setting_status = 'on';
   input_subject_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(input_subject_pos) & strcmp(save_setting_status,'on')

      pos = input_subject_pos;

   else

      w = 0.6;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','Edit Subject Directory', ...
        'MenuBar','none', ...
        'NumberTitle','off', ...
        'deletefcn','struct_input_subject_ui(''DELETE_FIG'');', ...
   	'Position',pos, ...
        'WindowStyle', 'modal', ...
   	'Tag','InputSubject', ...
   	'ToolBar','none');

   x = 0.06;
   y = 0.9;
   w = 1;
   h = 0.06;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% subject label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.6, ...
	'FontName', 'FixedWidth', ...
   	'FontAngle','italic', ...
   	'FontWeight','bold', ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Subjects Directory: ', ...
   	'Tag','SubjectTitleLabel');

   x = 0.03;
   y = 0.83;
   w = 0.07;

   pos = [x y w h];

   c_h1 = uicontrol('Parent',h0, ...		% subject idx
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','1.', ...
   	'Tag','SubjectIdxLabel');

   x = x+w+0.01;
   w = 0.5;

   pos = [x y w h];

   c_h2 = uicontrol('Parent',h0, ...		% subject name
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
	'Enable','on',...
   	'Tag','SubjectNameEdit');

   x = x+w+0.01;
   w = 0.12;

   pos = [x y w h];

   c_h3 = uicontrol('Parent',h0, ...		% subject add/delete button
   	'Units','normal', ...
   	'Position',pos, ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'String','Add ...', ...
   	'Tag','ADD/DELButton');

   x = x+w+0.01;

   pos = [x y w h];

   c_h4 = uicontrol('Parent',h0, ...		% subject edit button
   	'Units','normal', ...
   	'Position',pos, ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'String','Edit ...', ...
   	'Tag','EDITButton');

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
   	'Callback','struct_input_subject_ui(''MOVE_SLIDER'');', ...
   	'Tag','SubjSlider');

   x = 0.11;
   y = 0.15-0.01;
   w = 0.52;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% Subject Init. Label
	'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'ListboxTop',0, ...
	'Value', 0, ...
        'Position',pos, ...
        'HorizontalAlignment','left', ...
        'String','Number of characters for subject initial:', ...
	'visible', 'off', ...
        'Tag','SubjectInitLabel');

   ext = get(h1, 'extent');
   w = ext(3);
   pos(3) = w;
   set(h1, 'position', pos);

   x = x+w+0.01;
   y = 0.15;
   w = 0.05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% Subject Init. Edit
	'Style','edit', ...
        'Units','normal', ...
        'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'ListboxTop',0, ...
	'Value', 0, ...
        'Position',pos, ...
        'HorizontalAlignment','left', ...
        'String',num2str(num_subj_init), ...
        'Callback','struct_input_subject_ui(''SUBJ_INIT_EDIT'');', ...
	'visible', 'off', ...
        'Tag','SubjectInitEdit');

   x = 0.67;
   w = 0.2;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% Full Path Checkbox
	'Style','checkbox', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'ListboxTop',0, ...
	'Value', 0, ...
        'Position',pos, ...
        'HorizontalAlignment','left', ...
        'String','Full Path', ...
        'Callback','struct_input_subject_ui(''TOGGLE_FULL_PATH'');', ...
	'visible', 'off', ...
        'Tag','FullPathChkbox');

   x = 0.11;
   y = 0.08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% DONE
        'Units','normal', ...
        'Callback','', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'Position',pos, ...
        'String','DONE', ...
   	'Callback','struct_input_subject_ui(''DONE_BUTTON_PRESSED'');', ...
        'Tag','DONEButton');

   x = 0.67;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% CANCEL
        'Units','normal', ...
        'Callback','', ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
        'Position',pos, ...
        'String','CANCEL', ...
   	'Callback','struct_input_subject_ui(''CANCEL_BUTTON_PRESSED'');', ...
        'Tag','CANCELButton');

   x = 0.01;
   y = 0;
   w = 1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...               % Message Line Label
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

   subj1_hdls = [c_h1,c_h2,c_h3,c_h4];  	% save handles for subject#1
   setappdata(h0,'Subj_hlist',subj1_hdls);

   subj_template = copyobj_legacy(subj1_hdls,h0);
   set(subj_template,'visible','off');

   setappdata(h0,'old_subj_name',old_subj_name);
   setappdata(h0,'curr_subj_name',old_subj_name);
   setappdata(h0,'OldSubjects',old_subjects);
   setappdata(h0,'CurrSubjects',old_subjects);
   setappdata(h0,'SubjectTemplate',subj_template);

   subj_h = 0.06;
   setappdata(h0,'SubjectHeight',subj_h);

   lower_h = 0.06;	% vert. space for Number of rows etc.
   setappdata(h0,'lower_h',lower_h);

   setappdata(h0,'TopSubjectIdx',1);
   setappdata(h0,'SubjectMap',[1:length(old_subjects)]);
   setappdata(h0,'full_path', 0);
   setappdata(h0,'filter', filter);
   setappdata(h0,'cond_filter', cond_filter);
   setappdata(h0,'dataset_dir', dataset_dir);

   SetupSubjectRows;
   SetupSlider;
   CreateAddRow;
   DisplaySubjects(0);
   UpdateSlider;

   return;						% init


%----------------------------------------------------------------------------
function SetupSubjectRows()

   subj_hdls = getappdata(gcf,'Subj_hlist');
   subj_h = getappdata(gcf,'SubjectHeight');
   lower_h = getappdata(gcf,'lower_h');

   bottom_pos = get(findobj(gcf,'Tag','SubjectInitLabel'),'Position');
   top_pos = get(subj_hdls(1,2),'Position');

   rows = floor(( top_pos(2) - bottom_pos(2) - lower_h) / subj_h + 1);
   v_pos = top_pos(2) - [0:rows-1]*subj_h;

   subj_template = getappdata(gcf,'SubjectTemplate');
   edit_cbf = 'struct_input_subject_ui(''UPDATE_SUBJECT'');';
   subj_name_cbf = 'struct_input_subject_ui(''EDIT_SUBJ_NAME'');';
   delete_cbf = 'struct_input_subject_ui(''DELETE_SUBJECT'');';
   detail_cbf = 'struct_input_subject_ui(''EDIT_SUBJECT'');';
   buttondown_subject = 'struct_input_subject_ui(''BUTTONDOWN_SUBJECTS'');';

   nr = size(subj_hdls,1);		% nr = 1 for the initial
   if (rows < nr)			% too many rows
      for i=rows+1:nr,
          delete(subj_hdls(i,:));
      end;
      subj_hdls = subj_hdls(1:rows,:);
   else					% add new rows
      for i=nr+1:rows,
         new_c_hdls = copyobj_legacy(subj_template,gcf);
         subj_hdls = [subj_hdls; new_c_hdls'];
      end;
   end;

   v = 'Off';
   for i=1:rows,
      % take out the handle list created above, and use it in the following 'label,edit,delete'.
      % those handles are valid, since they are all obtained from function copyobj_legacy() above.
      new_c_hdls = subj_hdls(i,:);

      % init label
      pos = get(new_c_hdls(1),'Position'); pos(2) = v_pos(i)-0.01;
      set(new_c_hdls(1),'String','','Position',pos,'Visible',v,'UserData',i);

      % init each edit box setup, insert callback property while doing setup
      pos = get(new_c_hdls(2),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(2),'String','', 'Position',pos, 'Visible',v, ...
                        'UserData',i,'Callback',subj_name_cbf);

      % init each delete button setup, insert callback property while doing setup
      pos = get(new_c_hdls(3),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(3),'String','Delete','Position',pos,'Visible',v, ...
                        'UserData',i,'Callback',delete_cbf);

      % init each edit button setup, insert callback property while doing setup
      pos = get(new_c_hdls(4),'Position'); pos(2) = v_pos(i);
      set(new_c_hdls(4),'String','Edit ...','Position',pos,'Visible',v, ...
                        'UserData',i,'Callback',detail_cbf);

   end;

   setappdata(gcf,'Subj_hlist',subj_hdls);
   setappdata(gcf,'NumRows',rows);

   return;					% SetupSubjectRows


%----------------------------------------------------------------------------
function DisplaySubjects(full_path)

   curr_subj_name = getappdata(gcf,'curr_subj_name');
   curr_subj = getappdata(gcf,'CurrSubjects');
   top_subj_idx = getappdata(gcf,'TopSubjectIdx');
   subj_map = getappdata(gcf,'SubjectMap');

   subj_hdls = getappdata(gcf,'Subj_hlist');
   rows = getappdata(gcf,'NumRows');

   num_subj = length(curr_subj);
   subj_idx = top_subj_idx;
   last_row = 0;

   for i=1:rows
      c_hdls = subj_hdls(i,:);
      if (subj_idx <= num_subj),
         set(c_hdls(1),'String',sprintf('%d.',subj_idx),'Visible','on');

%         curr_subj_name = sprintf('%s',curr_subj{subj_idx});
         if(full_path)
             set(c_hdls(2), 'String', curr_subj_name{subj_idx}, ...
                       'Visible', 'on');
         else
 %            [p_path, p_name, p_ext] = fileparts(curr_subj_name);
%             curr_subj_name = [p_name p_ext];
             set(c_hdls(2), 'String', curr_subj_name{subj_idx}, ...
                       'Visible', 'on');
         end

         set(c_hdls(3),'String','Delete','Visible','on');
         set(c_hdls(4),'String','Edit ...','Visible','on');
         set(c_hdls(3),'String','Delete','Enable','on');

         subj_idx = subj_idx + 1;
         last_row = i;
      else
         set(c_hdls(1),'String','','Visible','off');
         set(c_hdls(2),'String','','Visible','off');
         set(c_hdls(3),'String','Delete','Visible','off');
         set(c_hdls(4),'String','Edit ...','Visible','off');
      end;
   end;

   %  display or hide the add row
   %
   if (last_row < rows)
      row_idx = last_row+1;
      c_hdls = subj_hdls(row_idx,:);
      pos = get(c_hdls(2),'Position');
      ShowAddRow(subj_idx,pos(2),row_idx);
   else
      HideAddRow;
   end;

   %  display or hide the slider
   %
   if (top_subj_idx ~= 1) | (last_row == rows)
     ShowSlider;
   else
     HideSlider;
   end;

   return;						% DisplaySubjects


%----------------------------------------------------------------------------
function CreateAddRow()

   subj_template = getappdata(gcf,'SubjectTemplate');
   buttondown_subject = 'struct_input_subject_ui(''BUTTONDOWN_SUBJECTS'');';

   a_hdls = copyobj_legacy(subj_template,gcf);

   set(a_hdls(1),'String','','Foreground',[0.4 0.4 0.4],'Visible','off', ...
                 'UserData',1);

   set(a_hdls(2),'String','','Background',[1 1 1], 'Visible','off',...
		 'enable','on');

   set(a_hdls(3),'String','Add ...','Visible','off', ...
		     'Callback','struct_input_subject_ui(''ADD_SUBJECT'');');

   set(a_hdls(4),'String','Edit ...','Visible','off');

   setappdata(gcf,'AddRowHdls',a_hdls);

   return;						% CreateAddRow


%----------------------------------------------------------------------------
function ShowAddRow(subj_idx,v_pos,row_idx)
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
      set(a_hdls(j),'Visible','On');
   end;

   set(a_hdls(4),'Visible','Off');
   set(a_hdls(2),'String','');
   set(a_hdls(1),'Visible','On','String',sprintf('%d.',subj_idx),'UserData',row_idx);

   return;						% ShowAddRow


%----------------------------------------------------------------------------
function HideAddRow()

   a_hdls = getappdata(gcf,'AddRowHdls');
   for j=1:length(a_hdls),
      set(a_hdls(j),'Visible','off');
   end;

   return;						% HideAddRow


%----------------------------------------------------------------------------
function UpdateSubject(subj_idx)

   curr_subj = getappdata(gcf,'CurrSubjects');
   subj_hdls = getappdata(gcf,'Subj_hlist');

   row_idx = get(gcbo,'UserData');
   subj_idx = str2num(get(subj_hdls(row_idx,1),'String'));
   curr_subj{subj_idx} = get(gcbo,'String');

   setappdata(gcf,'CurrSubjects',curr_subj);

   return;						% UpdateSubject


%----------------------------------------------------------------------------
function DeleteSubject()

   subj_files = getappdata(gcf,'subj_files');
   curr_subj_name = getappdata(gcf,'curr_subj_name');
   curr_subj = getappdata(gcf,'CurrSubjects');
   subj_hdls = getappdata(gcf,'Subj_hlist');

   row_idx = get(gcbo,'UserData');
   subj_idx = str2num(get(subj_hdls(row_idx,1),'String'));

   mask = ones(1,length(curr_subj));  mask(subj_idx) = 0;
   idx = find(mask == 1);

   curr_subj_name = curr_subj_name(idx);
   curr_subj = curr_subj(idx);
   subj_files = subj_files(:,idx);

   setappdata(gcf,'curr_subj_name',curr_subj_name);
   setappdata(gcf,'subj_files', subj_files);
   setappdata(gcf,'CurrSubjects',curr_subj);

   full_path = getappdata(gcf,'full_path');
   DisplaySubjects(full_path);

   UpdateSlider;

   return;						% DeleteSubject


%----------------------------------------------------------------------------
function AddSubject()

   rows = getappdata(gcf,'NumRows');
   a_hdls = getappdata(gcf,'AddRowHdls');
   curr_subj_name = getappdata(gcf,'curr_subj_name');
   curr_subj = getappdata(gcf,'CurrSubjects');
   subj_name = get(a_hdls(2),'String');
   subj_idx = str2num(get(a_hdls(1),'String'));

   condition = getappdata(gcf,'condition');
   selected_conditions = getappdata(gcf,'selected_conditions');
   subj_files = getappdata(gcf,'subj_files');

   num_subj_init = ...
	str2num(get(findobj(gcf,'Tag','SubjectInitEdit'),'string'));
   subj_dir = [];

   filter = getappdata(gcf,'filter');
   cond_filter = getappdata(gcf,'cond_filter');
   dataset_dir = getappdata(gcf,'dataset_dir');

%   [subj_dir, subj_files_row, filter] = ...
%	rri_getsubject_ui(condition, selected_conditions, old_dir, ...
%		[], subj_files, num_subj_init, filter);

   subj_dir = rri_getitem1('Select a subject',dataset_dir, cond_filter{1});

   if iscellstr(subj_dir)
      curr_subj_name = {};
      subj_files = {};

      for k=1:length(subj_dir)
         dir_struct = dir(fullfile(dataset_dir, subj_dir{k}));
         subj_list = {dir_struct.name};
         subj_files_row = cell(length(cond_filter), 1);

         for i=1:length(cond_filter)
            dir_struct = dir(fullfile(dataset_dir, cond_filter{i}));

            for j=1:length(subj_list)
               if ismember(subj_list{j}, {dir_struct.name})
                  subj_files_row{i} = subj_list{j};
                  break;
               end
            end
         end

         [tmp subj_name] = fileparts(subj_dir{k});
         subj_name = strrep(subj_name, '*',  '');

         curr_subj_name{k} = subj_name;
         subj_files = [subj_files subj_files_row];
      end

      setappdata(gcf,'curr_subj_name',curr_subj_name);
      setappdata(gcf,'CurrSubjects',subj_dir);
      setappdata(gcf,'subj_files',subj_files);

      uiresume;
      return;
   end

   dir_struct = dir(fullfile(dataset_dir, subj_dir));
   subj_list = {dir_struct.name};
   subj_files_row = cell(length(cond_filter), 1);

   for i=1:length(cond_filter)
      dir_struct = dir(fullfile(dataset_dir, cond_filter{i}));

      for j=1:length(subj_list)
         if ismember(subj_list{j}, {dir_struct.name})
            subj_files_row{i} = subj_list{j};
            break;
         end
      end
   end

   num_subj = length(curr_subj)+1;

   if isempty(subj_name)
      [tmp subj_name] = fileparts(subj_dir);
      subj_name = strrep(subj_name, '*',  '');
   end

   curr_subj_name{num_subj} = subj_name;
   setappdata(gcf,'curr_subj_name',curr_subj_name);

   if isempty(subj_dir), return; end;		% CANCEL from rri_getsubject

%   num_subj = length(curr_subj)+1;

   curr_subj{num_subj} = subj_dir;
   subj_files(:,num_subj) = subj_files_row;

   setappdata(gcf,'CurrSubjects',curr_subj);
   setappdata(gcf,'subj_files',subj_files);
   new_subj_row = get(a_hdls(1),'UserData');

   if (new_subj_row == rows),  	% the new subject row is the last row
      top_subj_idx = getappdata(gcf,'TopSubjectIdx');
      setappdata(gcf,'TopSubjectIdx',top_subj_idx+1);
   end;

   full_path = getappdata(gcf,'full_path');
   DisplaySubjects(full_path);

   subj_hdls = getappdata(gcf,'Subj_hlist');
   if (new_subj_row == rows),  	% the new subject row is the last row
      set(gcf,'CurrentObject',subj_hdls(rows-1,2));
   else
      set(gcf,'CurrentObject',subj_hdls(new_subj_row,2));
   end;

   UpdateSlider;

   return;						% AddSubjects


%----------------------------------------------------------------------------
function EditSubject()

   condition = getappdata(gcf,'condition');
   selected_conditions = getappdata(gcf,'selected_conditions');
   subj_files = getappdata(gcf,'subj_files');
   full_path = getappdata(gcf,'full_path');

   curr_subj_name = getappdata(gcf,'curr_subj_name');
   curr_subj = getappdata(gcf,'CurrSubjects');
   subj_hdls = getappdata(gcf,'Subj_hlist');

   row_idx = get(gcbo,'UserData');
   subj_idx = str2num(get(subj_hdls(row_idx,1),'String'));

   if ~isempty(subj_files)
      subj_files_row_old = subj_files(:,subj_idx);
   else
      subj_files_row_old = [];
   end

   num_subj_init = ...
	str2num(get(findobj(gcf,'Tag','SubjectInitEdit'),'string'));

   filter = getappdata(gcf,'filter');

   cond_filter = getappdata(gcf,'cond_filter');
   dataset_dir = getappdata(gcf,'dataset_dir');

%   [subj_dir, subj_files_row, filter] = ...
%	rri_getsubject_ui(condition, selected_conditions, ...
%		pls_data_dir, subj_files_row_old, subj_files, num_subj_init, filter);

   subj_dir = rri_getitem1('Select a subject',dataset_dir, cond_filter{1}, curr_subj{subj_idx});

   if isempty(subj_dir), return; end;		% CANCEL from rri_getsubject

   if iscellstr(subj_dir)

      curr_subj_name = {};
      subj_files = {};

      for k=1:length(subj_dir)
         dir_struct = dir(fullfile(dataset_dir, subj_dir{k}));
         subj_list = {dir_struct.name};
         subj_files_row = cell(length(cond_filter), 1);

         for i=1:length(cond_filter)
            dir_struct = dir(fullfile(dataset_dir, cond_filter{i}));

            for j=1:length(subj_list)
               if ismember(subj_list{j}, {dir_struct.name})
                  subj_files_row{i} = subj_list{j};
                  break;
               end
            end
         end

         [tmp subj_name] = fileparts(subj_dir{k});
         subj_name = strrep(subj_name, '*',  '');

         curr_subj_name{k} = subj_name;
         subj_files = [subj_files subj_files_row];
      end

      setappdata(gcf,'curr_subj_name',curr_subj_name);
      setappdata(gcf,'CurrSubjects',subj_dir);
      setappdata(gcf,'subj_files',subj_files);

      uiresume;
      return;
   end

   dir_struct = dir(fullfile(dataset_dir, subj_dir));
   subj_list = {dir_struct.name};
   subj_files_row = cell(length(cond_filter), 1);

   for i=1:length(cond_filter)
      dir_struct = dir(fullfile(dataset_dir, cond_filter{i}));

      for j=1:length(subj_list)
         if ismember(subj_list{j}, {dir_struct.name})
            subj_files_row{i} = subj_list{j};
            break;
         end
      end
   end

   [tmp subj_name] = fileparts(subj_dir);
   subj_name = strrep(subj_name, '*',  '');
   curr_subj_name{subj_idx} = subj_name;
   setappdata(gcf,'curr_subj_name',curr_subj_name);

   if(~isempty(subj_dir)),
      curr_subj{subj_idx} = subj_dir;
      subj_files(:,subj_idx) = subj_files_row;

      if(full_path)
         set(subj_hdls(row_idx,2), 'String', subj_dir);
      else
         [p_path, p_name, p_ext] = fileparts(subj_dir);
         subj_dir = [p_name p_ext];
         set(subj_hdls(row_idx,2), 'String', subj_dir);
      end

      setappdata(gcf,'CurrSubjects',curr_subj);
      setappdata(gcf,'subj_files',subj_files);

   end;

   return;						% EditSubjects


%----------------------------------------------------------------------------
function MoveSlider()

   slider_hdl = findobj(gcf,'Tag','SubjSlider');
   curr_value = round(get(slider_hdl,'Value'));
   total_rows = round(get(slider_hdl,'Max'));

   top_subj_idx = total_rows - curr_value + 1;

   setappdata(gcf,'TopSubjectIdx',top_subj_idx);

   full_path = getappdata(gcf,'full_path');
   DisplaySubjects(full_path);

   return;						% MoveSlider


%----------------------------------------------------------------------------
function SetupSlider()

   subj_hdls = getappdata(gcf,'Subj_hlist');
   top_pos = get(subj_hdls(1,4),'Position');
   bottom_pos = get(subj_hdls(end,4),'Position');

   slider_hdl = findobj(gcf,'Tag','SubjSlider');
   pos = get(slider_hdl,'Position');

   pos(2) = bottom_pos(2);
   pos(4) = top_pos(2) + top_pos(4) - pos(2);

   set(slider_hdl,'Position', pos);

   return;						% SetupSlider


%----------------------------------------------------------------------------
function UpdateSlider()

   top_subj_idx = getappdata(gcf,'TopSubjectIdx');
   rows = getappdata(gcf,'NumRows');

   curr_subj = getappdata(gcf,'CurrSubjects');
   num_subj = length(curr_subj);

   total_rows = num_subj+1;
   slider_hdl = findobj(gcf,'Tag','SubjSlider');

   if (num_subj ~= 0)		% don't need to update when no subject
      set(slider_hdl,'Min',1,'Max',total_rows, ...
                  'Value',total_rows-top_subj_idx+1, ...
                  'Sliderstep',[1/(total_rows-1)-0.00001 1/(total_rows-1)]); 
   end;
   
   return;						% UpdateSlider


%----------------------------------------------------------------------------
function ShowSlider()

   slider_hdl = findobj(gcf,'Tag','SubjSlider');
   set(slider_hdl,'visible','on'); 

   return;						% ShowSlider


%----------------------------------------------------------------------------
function HideSlider()

   slider_hdl = findobj(gcf,'Tag','SubjSlider');
   set(slider_hdl,'visible','off');

   return;						% HideSlider


%----------------------------------------------------------------------------
function SwitchFullPath()

   h = findobj(gcf,'Tag','FullPathChkbox');
   full_path = get(h,'Value');

   setappdata(gcf,'full_path',full_path);
   DisplaySubjects(full_path);

   return;					% SwitchFullPath


%----------------------------------------------------------------------------
function DoneButtonPressed()

   curr_subj = getappdata(gcf,'CurrSubjects');
   num_subj = length(curr_subj);

   for i = 1:num_subj-1
      if isempty(curr_subj{i})
         msg = 'ERROR: All subjects must have directory specified.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
      for j = i+1:num_subj
         if length(curr_subj{i}) == length(curr_subj{j}) ...
					& curr_subj{i} == curr_subj{j}
            msg = 'ERROR: No subjects should be duplicated.';
            set(findobj(gcf,'Tag','MessageLine'),'String',msg);
            return;
         end
      end
   end

   if isempty(curr_subj) | isempty(curr_subj{num_subj})
      msg = 'ERROR: All subjects must have directory specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   uiresume;

   return;						% DoneButtonPressed


%----------------------------------------------------------------------------
function delete_fig

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       input_subject_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'input_subject_pos');
    catch
    end

    return;


%----------------------------------------------------------------------------
function subj_init_edit

    init_value = str2num(get(gcbo,'string'));

    if init_value < 0 | round(init_value) ~= init_value
%        msg = 'Only none zero integer is accepted here.';
%        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%        set(gcbo,'string','3');
        set(gcbo,'string','-1');
    end

    return;


%----------------------------------------------------------------------------
function EditSubjName

   curr_subj_name = getappdata(gcf,'curr_subj_name');
   Subj_hlist = getappdata(gcf, 'Subj_hlist');
   [r c] = ind2sub(size(Subj_hlist), find(Subj_hlist==gco));
   subj_idx = str2num(get(Subj_hlist(r,1),'String'));
   curr_subj_name{subj_idx} = get(gco,'String');
   setappdata(gcf,'curr_subj_name',curr_subj_name);

   return;

