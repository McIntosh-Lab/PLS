%RRI_GETSUBJECT_UI Get subject directory based on conditions
%
%   Usage: [selected_dir, subj_files_row, img_ext] = ...
%	rri_getsubject_ui(condition, selected_conditions, ...
%		old_dir, subj_files_row_old, subj_files, num_subj_init, img_ext)
%
%   RRI_GETSUBJECT_UI(condition, selected_conditions, old_dir) returns
%   a selected directory, with a subject-image vector containing all
%   the filtered images in that directory, and a condtion-image
%   vector containing the images corresponding to the selected
%   conditions.
%
%   See also RRI_GETDIRECTORY
%

%   Called by rri_input_subject_ui
%
%   I (condition) - A cell array containing all the conditions.
%   I (selected_conditions) - <obsolete>
%   I (old_dir) - Starting directory name. If none, use current directory.
%   I (subj_files_row_old) - subj file name returned by this function.
%   I (subj_files) - subj_files field in session file.
%   I (num_subj_init) - Number of characters for subject initial
%   I (img_ext) - filter (img file extension)
%   O (selected_dir) - full directory spec name that user selected.
%   O (subj_files_row) - A cell array containing all the filtered images.
%   O (img_ext) - filter (img file extension)
%
%   Created on 23-SEP-2002 by Jimmy Shen
%   Modified feb,03 to allow muliple choose & case insensitive
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [selected_dir, subj_files_row, filter] = rri_getsubject_ui(varargin)

    if nargin == 0 | ~ischar(varargin{1})		% if not action
        condition = [];
        selected_conditions = [];
        old_dir = pwd;
        if isempty(old_dir)
            old_dir = filesep;
        end;

        if(nargin > 1)
            condition = varargin{1};
            selected_conditions = varargin{2};

            if(nargin > 2), old_dir = varargin{3}; end;
            if(nargin > 3), subj_files_row_old = varargin{4}; end;
            if(nargin > 4), subj_files = varargin{5}; end;
            if(nargin > 5), num_subj_init = varargin{6}; end;
            if(nargin > 6), filter = varargin{7}; end
        else
            error('Check input arguments');
        end

        init(condition, selected_conditions, old_dir, ...
		subj_files_row_old, subj_files, num_subj_init, filter);

        uiwait;						% wait for user finish

        selected_dir = getappdata(gcf, 'selected_dir');
        subj_files_row = getappdata(gcf,'subj_files_row');
        filter = getappdata(gcf,'imgfile_filter');

        cd (getappdata(gcf,'StartDirectory'));		% go back to start dir
        close(gcf);
        return;
    end

    h = findobj(gcf,'Tag','MessageLine');
    set(h,'String','');					% clear the message line,

    action = varargin{1};

    if strcmp(action,'move_slider'),
        MoveSlider;
    elseif strcmp(action,'update_directorylist'),
        UpdateDirectoryList;
    elseif strcmp(action,'update_imagefilter'),
        UpdateImageFilter;
    elseif strcmp(action,'update_selecteddir'),
        UpdateSelectedDir;
    elseif strcmp(action,'select_imagefile'),
	select_imagefile
    elseif strcmp(action,'done_button_pressed'),
        DoneButtonPressed;
    elseif strcmp(action,'cancel_button_pressed'),
        setappdata(gcf, 'selected_dir',[]);
        uiresume;
    elseif strcmp(action,'delete_fig')
        delete_fig;
    end;

    return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Init: Initialize the GUI layout
%
%   I (condition) - A cell array containing all the conditions.
%   I (selected_conditions) - <obsolete>
%   I (old_dir) - Starting directory name. If none, use current directory.
%   I (subj_files_row_old) - Old subj_files_row that was saved before.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function init(condition, selected_conditions, old_dir, ...
		subj_files_row_old, subj_files, num_subj_init, filter)

    StartDirectory = pwd;				% save start dir
    if isempty(StartDirectory),
        StartDirectory = filesep;
    end;

    save_setting_status = 'on';
    getsubject_pos = [];

    try
       load('pls_profile');
    catch
    end

    if ~isempty(getsubject_pos) & strcmp(save_setting_status,'on')

       pos = getsubject_pos;

    else

       w = 0.8;
       h = 0.7;
       x = (1-w)/2;
       y = (1-h)/2;

       pos = [x y w h];

    end

    h0 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','Subject Directory Detail', ...
        'MenuBar','none', ...
        'NumberTitle','off', ...
        'interruptible', 'off', ...
        'busyaction', 'cancel', ...
        'deletefcn','rri_getsubject_ui(''delete_fig'');', ...
   	'Position',pos, ...
        'WindowStyle', 'modal', ...
   	'Tag','figGetSubject', ...
   	'ToolBar','none');

    x = 0.01;
    y = 0;
    w = 1;
    h = 0.06;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% Message Line Label
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

    x = 0.05;
    y = 0.88;
    w = 0.25;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% directories label
	'Units','normal', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','Directory', ...
	'Style','text', ...
	'Tag','lblDirs');

    y = 0.25;
    h = 0.63;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% directories listbox
	'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.048, ...
	'Position',pos, ...
	'String','', ...
	'Style','listbox', ...
        'Callback','rri_getsubject_ui(''update_directorylist'');', ...
	'Tag','listDirs', ...
        'max',1, ...
        'User',1, ...
	'Value',1);

    y = 0.16;
    h = 0.06;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% selected dir label
	'Units','normal', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','Selected Directory', ...
	'Style','text', ...
	'Tag','lblSelectedDir');

    y = 0.1;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% selected dir edit
	'Units','normal', ...
	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','', ...
	'Style','edit', ...
        'Callback','rri_getsubject_ui(''update_selecteddir'');', ...
	'Tag','editSelectedDir');

    x = 0.32;
    y = 0.16;
    w = 0.2;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% subject filter label
	'Units','normal', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','Subject File Filter', ...
	'Style','text', ...
	'Tag','lblImageFilter');


    x = 0.6;
    w = 0.35;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% subj name consistency check
	'Units','normal', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','File names are the same across subjects', ...
	'Style','check', ...
	'value', 1, ...
	'enable','on', ...
	'Tag','chkSubjConsistency');


    x = 0.32;
    y = 0.1;
    w = 0.2;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% subject filter edit
	'Units','normal', ...
	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String',filter, ...
	'Style','edit', ...
        'Callback','rri_getsubject_ui(''update_imagefilter'');', ...
	'Tag','editImageFilter');

    x = 0.6;
    y = y-0.02;
    w = 0.15;
    h = 0.07;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% DONE
	'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.4, ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','DONE', ...
        'Callback','rri_getsubject_ui(''done_button_pressed'');', ...
	'Tag','DONEButton');

    x = 0.8;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% CANCEL
	'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.4, ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','CANCEL', ...
        'Callback','rri_getsubject_ui(''cancel_button_pressed'');', ...
	'Tag','CANCELButton');

    x = 0.35;
    y = 0.88;
    w = 0.4;
    h = 0.06;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% selected condition label
	'Units','normal', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'HorizontalAlignment','center', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','   Inputed Conditions', ...
	'Style','text', ...
	'Tag','lblCondition');

    x = x+w;
    y = 0.88;
    w = 0.18;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% filtered file label
	'Units','normal', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'HorizontalAlignment','center', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','Subject Files', ...
	'Style','text', ...
	'Tag','lblFilteredFile');

    x = 0.32;
    y = 0.25;
    w = 0.63;
    h = 0.63;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% selected condition frame
	'Units','normal', ...
	'BackgroundColor',[0.9 0.9 0.9], ...
	'Position',pos, ...
	'Style','frame', ...
	'Tag', 'frameCondition');

    x = 0.917;
    w = 0.03;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% v scroll bar
	'Style', 'slider', ...
   	'Units','normal', ...
   	'Min',1, ...
   	'Max',20, ...
   	'Value',20, ...
   	'Position',pos, ...
	'Enable','Off', ...
   	'Callback','rri_getsubject_ui(''move_slider'');', ...
   	'Tag','sliderCondition');

    x = 0.33;
    y = 0.81;
    w = 0.04;
    h = 0.06;

    pos = [x y w h];

    c_h1 = uicontrol('Parent',h0, ...		% selected condition idx
   	'Style','text', ...
   	'Units','normal', ...
	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','', ...
	'Visible','On', ...
   	'Tag','idxCondition');

    x = x+w+0.01;
    w = 0.33;

    pos = [x y w h];

    c_h2 = uicontrol('Parent',h0, ...		% selected condition name
	'Units','normal', ...
	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','', ...
	'Style','edit', ...
	'Enable','Inactive', ...
	'Tag','nameCondition');

    x = x+w;
    w = 0.02;

    pos = [x y w h];

    c_h3 = uicontrol('Parent',h0, ...		% colon label
	'Units','normal', ...
	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String',':', ...
	'Style','text', ...
	'Tag','lblColon');

    x = x+w;
    w = 0.17;

    pos = [x y w h];

    c_h4 = uicontrol('Parent',h0, ...		% filtered file name combo box
	'Units','normal', ...
	'BackgroundColor',[1 1 1], ...
   	'FontUnits','normal', ...
   	'FontSize',0.5, ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String',' ', ...
	'Style','push', ...
	'horizon','left', ...
	'Tag','cboImageFile', ...
	'Value', 1);
%	'Style','popupmenu', ...

    if num_subj_init == -1
       set(findobj(h0,'tag','chkSubjConsistency'), 'value', 0);
       num_subj_init = 0;
       chksubj = 0;
    else
       chksubj = 1;
    end

    setappdata(h0,'chksubj',chksubj);
    setappdata(h0,'num_subj_init',num_subj_init);
    setappdata(h0,'StartDirectory',StartDirectory);
    setappdata(h0,'condition', condition);
    setappdata(h0,'selected_conditions', selected_conditions);
    setappdata(h0,'old_dir', old_dir);
    setappdata(h0,'subj_files_row_old', subj_files_row_old);
    setappdata(h0,'subj_files', subj_files);
    setappdata(h0,'selected_dir', old_dir);

    setappdata(h0,'frame_pos', ...
	get(findobj(gcf,'Tag','frameCondition'),'Position'));
    setappdata(h0,'imgfile_filter', ...
	get(findobj(gcf,'Tag','editImageFilter'),'String'));

    imgfile_height = 0.06;
    setappdata(h0,'imgfile_height', imgfile_height);

    setappdata(h0,'top_cond_idx', 1);
    setappdata(h0,'duplicate_img',0);

    imgfile1_hdls = [c_h1,c_h2,c_h3,c_h4];	% save handles for the 1st one
    setappdata(h0,'imgfile_hlist', imgfile1_hdls);

    imgfile_template = copyobj_legacy(imgfile1_hdls,h0);
    set(imgfile_template, 'visible', 'off');
    setappdata(h0,'imgfile_template', imgfile_template);
    setappdata(h0,'saved_map',{});		% init saved subj map list
    setappdata(h0,'grp_selected_dir',{});	% init

    if isempty(subj_files_row_old)
       ListDirectory(old_dir, 1, []);
    else
       ListDirectory(old_dir, 1, old_dir);
    end

    SetupSubjectImageMap(0,0);
    SetupConditionRows;
    SetupSlider;
    DisplayConditions(1);
    UpdateSlider;

    return;						% init


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   ListDirectory: List all the subdirectories under dir_name
%
%   I (dir_name) - name of the directory that will be listed.
%   I (exist_sub) - set to 0 if there is no subdirectory under dir_name.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListDirectory(dir_name, exist_sub, old_dir)

    if ~exist('old_dir','var')
       old_dir = [];
    end

    imgfile_filter = getappdata(gcf,'imgfile_filter');

    dir_struct = dir(dir_name);
    if isempty(dir_struct)
        % msg = 'ERROR: Directory not found!';
        msg1 = 'Cannot find directory "';
        msg2 = '", please enter full path.';
        msg = [msg1,dir_name,msg2];
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        return;
    end

	% preserve old mouse pointer, and make current pointer as 'Busy'
	% it is useful to execute slow process
	%
    old_pointer = get(gcf,'Pointer');
    set(gcf,'Pointer','watch');

	% get directory list
	%
    dir_list = dir_struct(find([dir_struct.isdir] == 1));
    [sorted_dir_names, sorted_dir_index] = sortrows({dir_list.name}');

	% get file list
	%
    dir_struct = dir([dir_name, filesep, imgfile_filter]);

    if isempty(dir_struct)
        sorted_file_names = [];
    else
        file_list = dir_struct(find([dir_struct.isdir] == 0));
        [sorted_file_names, sorted_file_index] = sortrows({file_list.name}');
    end;

    if (exist_sub)
        set(findobj(gcf,'Tag','listDirs'),'String',sorted_dir_names,'Value',1);
        set(findobj(gcf,'Tag','editSelectedDir'),'String',dir_name);
    end

    setappdata(gcf, 'filtered_files', sorted_file_names);


    %  add init char unique check  -jimmy
    %
    chk_init = char(sorted_file_names);

    if ~isempty(chk_init)
       num_subj_init = getappdata(gcf,'num_subj_init');
       chksubj = getappdata(gcf,'chksubj');
       chk_init = lower(chk_init(:,1:num_subj_init));
       chk_init = unique(chk_init,'rows');

       if size(chk_init,1) == 1 & chksubj
          set(findobj(gcf,'Tag','chkSubjConsistency'),'enable','on','value',1);
       else
          set(findobj(gcf,'Tag','chkSubjConsistency'),'enable','off','value',0);
       end
    end


    if isempty(old_dir)				% called by add subject
       set(gcf,'Pointer',old_pointer);		% Put 'Arrow' pointer back
       return; 					% ListDirectory
    else					% called by edit subj

       [pn, fn]=fileparts(old_dir);

       dir_struct = dir(pn);
       dir_list = dir_struct(find([dir_struct.isdir] == 1));
       [sorted_dir_names, sorted_dir_index] = sortrows({dir_list.name}');

       [tmp, idx] = intersect(sorted_dir_names, fn);

       set(findobj(gcf,'Tag','listDirs'),'String',sorted_dir_names,'Value',idx);
       set(findobj(gcf,'Tag','editSelectedDir'),'String',pn);

    end

    set(gcf,'Pointer',old_pointer);		% Put 'Arrow' pointer back
    return; 					% ListDirectory


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   SetupSubjectImageMap: For each subject, setup row of mapping matrix
%
%   modify_saved_map: flag. If 1, modify; if 0 not modify saved_map
%
%   sample_idx: use saved_map(sample_idx) as sample of all other subjects
%		if user request to change all other subj sequence when one
%		of them (sample_idx) was changed. valid value should > 0.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetupSubjectImageMap(modify_saved_map,sample_idx)

    selected_condition = getappdata(gcf,'selected_conditions');
    cond_name = getappdata(gcf,'condition');
    condnum = length(cond_name);
    cond_name(find(selected_condition == 0)) = [];

    h1 = findobj(gcf,'Tag','listDirs');
    selected_dir_idx = get(h1,'user');

    if length(selected_dir_idx) > 1

        msg = 'For this action, please select one directory only.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        return;

    end

    saved_map = getappdata(gcf,'saved_map');
    keep_saved_map = 0;

    % don't need to modify saved_map array
    %
    if(~modify_saved_map)

        % if saved_map{selected_dir_idx} is available, while modify saved_map is not
        % required, then save the data and return
        %
        if length(saved_map)>=selected_dir_idx & ~isempty(saved_map{selected_dir_idx})
            subj_files_row = saved_map{selected_dir_idx};
            setappdata(gcf,'subj_files_row',subj_files_row);
            setappdata(gcf,'cond_name', cond_name);
            return;
        end
    end

    num_subj_init = getappdata(gcf,'num_subj_init');
    subj_files = getappdata(gcf,'subj_files');

    is_same_name = 0;

    filtered_files = getappdata(gcf, 'filtered_files');	% list of imgfile name

    if(length(filtered_files) < condnum)	% don't have enough imgfile

%        padnum = ceil(condnum/length(filtered_files));

%        temp = [];
%        for i = 1:padnum
%           temp = [temp; filtered_files];
%        end
%        filtered_files = temp;

%        setappdata(gcf,'duplicate_img',1);

        for i=1:(condnum-length(filtered_files))
            filtered_files = [filtered_files; {''}];
        end

    end

    % check sample usability
    %
    sample_chk = 0;

    if sample_idx > 0
        tmp = char(saved_map{sample_idx});

        if ~isempty(tmp)
            sample_chk = 1;
        end
    end

    % if any subject has already been entered
    % or if the subject file is being swapped
    %
    if ~isempty(subj_files) | (sample_idx > 0 & sample_chk == 1)

        if sample_idx > 0
           sample = char(saved_map{sample_idx});
        else
           sample = char(subj_files(:, 1));
        end

        sample = cellstr(sample(:, num_subj_init+1:end));

        cursor = char(filtered_files);
        cursor = cellstr(cursor(:, num_subj_init+1:end));

        compare = ismember(lower(sample), lower(cursor));
        is_same_name = all(compare);

        % Matlab 5 does not have index feature for ismember function
        %
        % [compare,idx] = ismember(lower(sample), lower(cursor));
        %
        % all the code below is used to get the idx
        %

        if is_same_name

            x=lower(sample);
            y=lower(cursor);

            for i=1:length(x)
               [tmp,idx(i)] = intersect(y,x(i));
            end
        end

    end

    if is_same_name &  get(findobj(gcf,'Tag','chkSubjConsistency'),'value')

        cursor = char(filtered_files);

        if isempty(cursor)
            subj_files_row = filtered_files(1:condnum);
        else
            sample = cellstr(cursor);

            sample = char(sample([idx]));
            sample = sample(:, num_subj_init+1:end);

            cursor = cursor(1:size(sample,1), 1:num_subj_init);

            subj_files_row = cellstr([cursor, sample]);
        end

    else
        subj_files_row = filtered_files(1:condnum);
    end

    saved_map{selected_dir_idx} = subj_files_row;

    if modify_saved_map
       setappdata(gcf,'saved_map',saved_map);		% save subj map list
    end

    setappdata(gcf,'subj_files_row',subj_files_row);
    setappdata(gcf,'cond_name', cond_name);

    return; 						% SetupSubjectImageMap


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   SetupConditionRows: Initially lay out all rows for the selected
%	conditions and their corresponding image files. Position is
%	determined by the frame position.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetupConditionRows()

    frame_pos = getappdata(gcf,'frame_pos');
    imgfile_height = getappdata(gcf,'imgfile_height');

    rows = floor(frame_pos(4) / imgfile_height);

    imgfile_hdls = getappdata(gcf,'imgfile_hlist');
    imgfile_template = getappdata(gcf,'imgfile_template');

	% A row of vertical positions, at which
	% the 10 4-controls will be located.
	%
    top_pos = get(imgfile_hdls(1,2),'Position');
    v_pos = top_pos(2) - [0:rows-1] * imgfile_height;

    select_cbf = 'rri_getsubject_ui(''select_imagefile'');';

    nr = size(imgfile_hdls, 1);		% size(x,1) get # of rows. nr = 1 for the initial
    if (rows < nr)						% too many rows
        for i = rows+1:nr,
            delete(imgfile_hdls(i,:));
        end
        imgfile_hdls = imgfile_hdls(1:rows, :);
    else							% add new rows
        for i = nr + 1:rows
            new_c_hdls = copyobj_legacy(imgfile_template, gcf);
            imgfile_hdls = [imgfile_hdls; new_c_hdls'];		% stack imgfile_hdls
        end
    end

    v = 'Off';
    for i=1:rows

	% take out the handle list created above, and use it
	% in the following 'idx,name,colon,combo'.
	% those handles are valid, since they are all obtained
	% from function copyobj_legacy() above.
	%

        new_c_hdls = imgfile_hdls(i,:);

	% init each condition idx
	%
        pos = get(new_c_hdls(1),'Position'); pos(2) = v_pos(i)-0.01;
        set(new_c_hdls(1),'String','','Position',pos,'Visible',v,'UserData',i);

	% init each condition name
	%
        pos = get(new_c_hdls(2),'Position'); pos(2) = v_pos(i);
        set(new_c_hdls(2),'String','','Position',pos,'Visible',v,'UserData',i);

	% init each colon (:)
	%
        pos = get(new_c_hdls(3),'Position'); pos(2) = v_pos(i);
        set(new_c_hdls(3),'String',':','Position',pos,'Visible',v,'UserData',i);

	% init each image file combo box
	%
        pos = get(new_c_hdls(4),'Position'); pos(2) = v_pos(i);
        set(new_c_hdls(4),'String',' ','Position',pos,'Visible',v, ...
						'UserData',i,'Callback',select_cbf);
    end

    setappdata(gcf,'imgfile_hlist', imgfile_hdls);
    setappdata(gcf,'NumRows',rows);

    return;						% SetupConditionRows


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   SetupSlider: Draw a slider,
%	%and use full displayed image file rows
%	%to determine the slider position.
%	and use the frame to determine the slider position
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetupSlider()

    pos_frame = get(findobj(gcf,'Tag','frameCondition'),'Position');

    slider_hdl = findobj(gcf,'Tag','sliderCondition');
    pos = get(slider_hdl,'Position');
    pos(2) = pos_frame(2) + 0.003030303;
    pos(4) = pos_frame(4) - 0.006060606;
    set(slider_hdl,'Position', pos);

    return;						% SetupSlider


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   DisplayConditions: Display all the selected conditions and their
%	corresponding image files.
%
%   I (init_flag): 1 means called by initial routine
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DisplayConditions(init_flag)

    subj_files_row_old = getappdata(gcf, 'subj_files_row_old');
    filtered_files = getappdata(gcf, 'filtered_files');
    subj_files_row = getappdata(gcf, 'subj_files_row');
    cond_name = getappdata(gcf, 'cond_name');

    if (init_flag & ~isempty(subj_files_row_old))	% called from init
        % more file in directory than what we needed
        %
        if length(subj_files_row_old) <= length(filtered_files)
            subj_files_row = subj_files_row_old;
            setappdata(gcf, 'subj_files_row', subj_files_row);
        % not enough file in directory
        %
        else
            subj_files_row = [];	% indicate error, because
					% image files is less than saved
            msg = 'ERROR: Some subject files have been removed.';
            set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        end
    end

    top_cond_idx = getappdata(gcf,'top_cond_idx');
    imgfile_hdls = getappdata(gcf,'imgfile_hlist');
    rows = getappdata(gcf,'NumRows');

    last_row = 0;				% no row at the beginning
    cond_idx = top_cond_idx;			% start from top row. Here's 1

    for i = 1:rows
        c_hdls = imgfile_hdls(i,:);
        if cond_idx <= length(cond_name)	% only display to these many rows
            set(c_hdls(1),'String',sprintf('%d.',cond_idx),'Visible','on');
            set(c_hdls(2),'String',sprintf('%s',cond_name{cond_idx}), ...
			'Visible','on');
            set(c_hdls(3),'String',':','Visible','on');
            if ~isempty(subj_files_row)
                set(c_hdls(4),'String',subj_files_row{cond_idx},'Value', ...
					cond_idx,'Visible','on');
            else					% display empty combo box
		set(c_hdls(4),'String',' ','Value',1,'Visible','on');
            end
            cond_idx = cond_idx + 1;
            last_row = i;
        else
            set(c_hdls(1),'String','','Visible','off');
            set(c_hdls(2),'String','','Visible','off');
            set(c_hdls(3),'String','','Visible','off');
            set(c_hdls(4),'String',' ','Visible','off');
        end;
    end;

	%  display or hide the slider
	%
    if (top_cond_idx ~= 1) | (last_row == rows)
        slider_hdl = findobj(gcf,'Tag','sliderCondition');
        set(slider_hdl,'Enable','On'); 
    else
        slider_hdl = findobj(gcf,'Tag','sliderCondition');
        set(slider_hdl,'Enable','Off'); 
    end

    return;						% DisplayConditions


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   UpdateSlider: Set slider's (Min, Max, Value, Sliderstep) based on
%	how many rows of image files.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function UpdateSlider()

    top_cond_idx = getappdata(gcf,'top_cond_idx');
    num_cond = length(getappdata(gcf, 'subj_files_row'));

    rows = getappdata(gcf,'NumRows');
    total_rows = num_cond + 1;		% so, Max-Min = total_rows - 1
    slider_hdl = findobj(gcf,'Tag','sliderCondition');

    if (num_cond ~= 0)			% don't need to update when no cond
        set(slider_hdl, 'Min', 1, 'Max', total_rows, ...
		'Value', total_rows - top_cond_idx + 1, ...
		'Sliderstep', [1/(total_rows-1)-0.00001, 1/(total_rows-1)]); 
    end
   
    return;						% UpdateSlider


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   MoveSlider: Respond to move slider action by changing the top index
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MoveSlider()

    slider_hdl = findobj(gcf,'Tag','sliderCondition');
    slider_value = round(get(slider_hdl,'Value'));

    total_rows = round(get(slider_hdl,'Max'));

	% when slider_value = 1, top_cond_idx will be total_rows
	%
    top_cond_idx = total_rows - slider_value + 1;	% see above fcn
    setappdata(gcf,'top_cond_idx',top_cond_idx);
    DisplayConditions(0);

    return;						% MoveSlider


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   UpdateDirectoryList: Respond to go into subdirectory
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function UpdateDirectoryList()

    listed_dir = get(gcbo,'String');
    selected_dir_idx = get(gcbo,'Value');

    if length(selected_dir_idx) > 1
       chksubj = getappdata(gcf,'chksubj');

       if chksubj
          set(findobj(gcf,'Tag','chkSubjConsistency'),'enable','on');
       end

       selected_dir_name = {listed_dir{selected_dir_idx}};
    else
       % set(findobj(gcf,'Tag','chkSubjConsistency'),'enable','off');
       selected_dir_name = listed_dir{selected_dir_idx};
       % selected_dir = [getappdata(gcf,'selected_dir') filesep selected_dir_name];
    end

    h = findobj(gcf,'Tag','editSelectedDir');

    if length(selected_dir_idx) > 1
        selected_dir_name = char(selected_dir_name);
        grp_selected_dir = [get(h,'String') filesep];
        grp_selected_dir = repmat(grp_selected_dir,[length(selected_dir_idx),1]);
        grp_selected_dir = [grp_selected_dir selected_dir_name];
        grp_selected_dir = (cellstr(grp_selected_dir))';

        setappdata(gcf,'grp_selected_dir',grp_selected_dir);
        return;
    end

    selected_dir = [get(h,'String') filesep selected_dir_name];

    %  go into subdirectory
    %
    try
        cd (selected_dir);
    catch
        msg = 'ERROR: Cannot access the directory';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        return;
    end

    if isempty(pwd)
        selected_dir = filesep;
    else
        selected_dir = pwd;
    end

    dir_struct = dir(selected_dir);
    if isempty(dir_struct)
        % msg = 'ERROR: Directory not found!';
        msg1 = 'Cannot find directory "';
        msg2 = '", please enter full path.';
        msg = [msg1,selected_dir,msg2];
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        return;
    end

	% preserve old mouse pointer, and make current pointer as 'Busy'
	% it is useful to execute slow process
	%
    old_pointer = get(gcf,'Pointer');
    set(gcf,'Pointer','watch');

    if (sum([dir_struct.isdir]) < 3)		% could be no subdir

        set(gcbo,'max',2);
        dir_list = dir_struct(find([dir_struct.isdir] == 1));

        if (dir_list(1).name == '.' & dir_list(2).name == '..')		% no subdir

            set(gcbo,'Value',selected_dir_idx);

            setappdata(gcf,'selected_dir', selected_dir);
            setappdata(gcf,'duplicate_img',0);

            saved_map = getappdata(gcf,'saved_map');

            % preload saved_map list when reach no subdir situation


            if isempty(saved_map)		% create saved_map list

               num_dir = size(listed_dir,1);
               for i = 3:num_dir

                  selected_dir2 = [get(h,'String') filesep listed_dir{i}];
                  ListDirectory(selected_dir2,0);
                  set(gcbo,'user',i);

                  if i == 3
                     SetupSubjectImageMap(1,0);
                  end

                  SetupSubjectImageMap(1,3);
               end

               ListDirectory(selected_dir,0);
               set(gcbo,'user',get(gcbo,'value'));
               SetupSubjectImageMap(1,3);

            else				% just display subject file

               set(gcbo,'user',get(gcbo,'value'));
               SetupSubjectImageMap(0,0);

            end

            DisplayConditions(0);

            %msg = 'INFO: No more subdirectory.';
            %set(findobj(gcf,'Tag','MessageLine'),'String',msg);

            set(gcf,'Pointer',old_pointer);
            return;

        end

    else

        set(gcbo,'max',1);
        setappdata(gcf,'saved_map',{});		% clean saved subj map list

    end

    setappdata(gcf,'selected_dir', selected_dir);

    h = findobj(gcf,'Tag','editSelectedDir');
    set(h,'String',selected_dir);

    ListDirectory(selected_dir,1);
    setappdata(gcf,'duplicate_img',0);

    SetupSubjectImageMap(0,0);
    DisplayConditions(0);

    set(gcf,'Pointer',old_pointer);
    return;					% UpdateDirectoryList


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   UpdateImageFilter: Respond to modifying Image Filter Edit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function UpdateImageFilter()

    imgfile_filter = get(findobj(gcf,'Tag','editImageFilter'),'String');
    setappdata(gcf,'imgfile_filter', imgfile_filter);

    selected_dir = getappdata(gcf,'selected_dir');
    ListDirectory(selected_dir,1);

    setappdata(gcf,'duplicate_img',0);
    setappdata(gcf,'saved_map',{});		% clean saved subj map list
    SetupSubjectImageMap(0,0);
    DisplayConditions(0);

    return;					% UpdateImageFilter


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   UpdateSelectedDir: Respond to modifying Selected Directory Edit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function UpdateSelectedDir()

    selected_dir = get(findobj(gcf,'Tag','editSelectedDir'),'String');
    setappdata(gcf,'selected_dir',selected_dir);
    ListDirectory(selected_dir,1);

    setappdata(gcf,'duplicate_img',0);
    setappdata(gcf,'saved_map',{});		% clean saved subj map list
    SetupSubjectImageMap(0,0);
    DisplayConditions(0);

    return;					% UpdateSelectedDir


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_imagefile: Respond to the selection of Image File combo box
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_imagefile

    h1 = findobj(gcf,'Tag','listDirs');
    selected_dir_idx = get(h1,'Value');
    listed_dir = get(h1,'String');

    %  Can't select subject file while selecting multiple subject directories
    %
    if length(selected_dir_idx) > 1

        msg = 'For this action, please select one directory only.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        return;

    end

    setappdata(gcf,'duplicate_img',0);		% reset. added for 'done' check

    subj_files_row = getappdata(gcf, 'subj_files_row');
    imgfile_hdls = getappdata(gcf, 'imgfile_hlist');

    imgfile_filter = getappdata(gcf, 'imgfile_filter');
    selected_dir = getappdata(gcf, 'selected_dir');

    row_idx = get(gcbo, 'UserData');
    cond_idx = str2num(get(imgfile_hdls(row_idx, 1), 'String'));

    %  get new subject order from dialog box generated by rri_getfile1
    %
    subject_file = rri_getfile1('Select a Subject', ...
	selected_dir, imgfile_filter, get(gcbo, 'string'));

    if isempty(subject_file)
        return;
    end

    set(gcbo,'string',subject_file);

    subj_files_row{cond_idx} = subject_file;
    setappdata(gcf, 'subj_files_row', subj_files_row);

    %  update saved map with current subject file order
    %
    saved_map = getappdata(gcf,'saved_map');
    saved_map{selected_dir_idx} = subj_files_row;

    num_dir = size(listed_dir,1);
    h2 = findobj(gcf,'Tag','editSelectedDir');

    setappdata(gcf,'saved_map',saved_map);		% save subj map list

    if get(findobj(gcf,'Tag','chkSubjConsistency'),'value')

       %  update all saved map, using the above subject order as sample
       %
       for i = 3:num_dir
           selected_dir2 = [get(h2,'String') filesep listed_dir{i}];
           ListDirectory(selected_dir2,0);
           set(h1,'user',i);
           SetupSubjectImageMap(1,selected_dir_idx);
       end

       %  update current set_files_row (inside SetupSubjectImageMap)
       %
       ListDirectory(selected_dir,0);
       h1 = findobj(gcf,'Tag','listDirs');
       set(h1,'user',get(h1,'value'));
       SetupSubjectImageMap(1,selected_dir_idx);

    end

    return;					% select_imagefile


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   DoneButtonPressed: Respond to the DONE button. This is the place
%	to check all user entry, and make sure there is no mistake.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DoneButtonPressed()

    num_subj_init = getappdata(gcf,'num_subj_init');
    subj_files = getappdata(gcf,'subj_files');

    h = findobj(gcf,'Tag','listDirs');
    selected_dir_idx = get(h,'Value');

    %  the following block executed when user choose multiple subjects
    %
    if length(selected_dir_idx) > 1

       saved_map = getappdata(gcf,'saved_map');
       saved_map = saved_map([selected_dir_idx]);

       first_select = char(saved_map{1});
       first_select = lower(first_select(:,num_subj_init+1:end));

       %  combine cell to make it look like 'subj_files' field in session_info
       %
       subj_files_row = {};

       for i=1:length(saved_map)

          if get(findobj(gcf,'Tag','chkSubjConsistency'),'value')

             curr_select = char(saved_map{i});
             curr_select = lower(curr_select(:,num_subj_init+1:end));

             if ~isequal(curr_select,first_select)
                msg = 'Subject file name convention is not consistent.';
                set(findobj(gcf,'Tag','MessageLine'),'String',msg);
                return;
              end
          end

          subj_files_row = [subj_files_row saved_map{i}];
       end

       selected_dir = getappdata(gcf,'grp_selected_dir');


       condnum = size(subj_files_row, 1);
       subjnum = size(subj_files_row, 2);

       for i = 1:condnum-1
          for j = i+1:condnum
             for n = 1:subjnum
                if length(subj_files_row{i,n}) == length(subj_files_row{j,n}) ...
			& subj_files_row{i,n} == subj_files_row{j,n}
                   setappdata(gcf,'duplicate_img', 1);
                   msg = 'ERROR: No subject should be duplicated.';
                   set(findobj(gcf,'Tag','MessageLine'),'String',msg);
                   return;
                end
             end
          end
       end    

       setappdata(gcf,'selected_dir',selected_dir);
       setappdata(gcf,'subj_files_row',subj_files_row);

       uiresume;

    end

    if(isempty(getappdata(gcf,'filtered_files')))   % no image file available
        msg = 'ERROR: No subject file in the selected directory.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        return;
    end

    subj_files_row = getappdata(gcf, 'subj_files_row');
    condnum = length(subj_files_row);

    for i = 1:condnum-1
        for j = i+1:condnum

            if isempty(subj_files_row{i}) | isempty(subj_files_row{j})
                msg = 'ERROR: All condition need a subject.';
                set(findobj(gcf,'Tag','MessageLine'),'String',msg);
                return;
            end

            if length(subj_files_row{i}) == length(subj_files_row{j}) ...
				& subj_files_row{i} == subj_files_row{j}
                setappdata(gcf,'duplicate_img', 1);
                msg = 'ERROR: No subject should be duplicated.';
                set(findobj(gcf,'Tag','MessageLine'),'String',msg);
                return;
            end

        end
    end    

    if get(findobj(gcf,'Tag','chkSubjConsistency'),'value') & ...
	~isempty(subj_files)

       first_select = char(subj_files(:, 1));
       first_select = lower(first_select(:,num_subj_init+1:end));

       curr_select = char(subj_files_row(:, 1));
       curr_select = lower(curr_select(:,num_subj_init+1:end));

       if ~isequal(curr_select,first_select)
          msg = 'Subject file name convention is not consistent.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
        end
    end

    if(getappdata(gcf,'duplicate_img'))
        msg = 'ERROR: No subject should be duplicated.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
    else
        uiresume;
    end

    return;					% DoneButtonPressed


%----------------------------------------------------------------------------
function delete_fig

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       getsubject_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'getsubject_pos');
    catch
    end

    return;

