function fig = struct_analysis_ui(varargin)

   if (nargin == 0),
      init;

      setappdata(gcf,'CallingFigure',gcbf);
      set(gcbf,'visible','off');

      uiwait(gcf);
      close(gcf);

      return;
   end;


   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   h = findobj(gcf,'Tag','LOADBATCHButton');
   set(h,'enable','off');

   action = upper(varargin{1});

   switch (action)
     case {'MENU_DESELECT_CONDITION'}
        deselect_condition;
     case {'MENU_MODIFY_BEHAVDATA'}
        modify_behavdata;
     case {'MENU_MULTIBLOCK_DESELECT_CONDITION'}
        multiblock_deselect_condition;
     case {'MENU_CREATE_CONTRASTS'}
        pls_session = '';
        num_groups = 0;
        cond_selection = [];
        tmp = getappdata(gcf);

        if ~isempty(tmp.CurrGroupProfiles)
           pls_session = tmp.CurrGroupProfiles{1};
           num_groups = length(tmp.CurrGroupProfiles);
        end

        if ~isempty(tmp.cond_selection)
           cond_selection = tmp.cond_selection;
        end

        if isempty(pls_session)
           msg = 'Group need to be added before you can open contrast window';
           set(findobj(gcf,'Tag','MessageLine'),'String',msg);
           return;
        end

        behavname = getappdata(gcf, 'behavname');

        if get(findobj(gcf,'Tag','SelectNonRotateBehav'),'value') | get(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'value')
           if isempty(behavname)
              msg = 'Behavior data must be loaded first';
              set(findobj(gcf,'Tag','MessageLine'),'String',msg);
              return;
           end
        end

        ContrastMatrix = getappdata(gcf, 'ContrastMatrix');

        if get(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'value')
           designdata = rri_input_contrast_ui({'STRUCT'},pls_session,cond_selection,num_groups,'nonrotatemultiblock',0,behavname,ContrastMatrix);
        else
           designdata = rri_input_contrast_ui({'STRUCT'},pls_session,cond_selection,num_groups,[],0,behavname,ContrastMatrix);
        end

        if ~isempty(designdata)
           ContrastMatrix = designdata;
        end

        setappdata(gcf, 'ContrastMatrix', ContrastMatrix);
     case {'SELECT_GROUP'}
        SelectGroupProfiles;
     case {'DELETE_GROUP'}
        DeleteGroupProfiles;
     case {'ADD_GROUP'}
        AddGroupProfiles;
     case {'MOVE_SLIDER'}
	MoveSlider;
     case {'BUTTONDOWN_GROUP'}
        msg = 'Use Add button to add the group';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     case {'TOGGLE_SAVE_DATAMAT'}
        SwitchSaveDatamat;
     case {'TOGGLE_FULL_PATH'}
        SwitchFullPath;
     case {'TASKPLS_SELECTED'}
	SelectTaskPLS;
     case {'CONTRASTDATA_SELECTED'}
        SelectContrastData;
     case {'BEHAVPLS_SELECTED'}
	SelectBehavPLS;
     case {'NON_ROTATE_BEHAVPLS_SELECTED'}
	SelectNonRotatedBehavPLS;
     case {'MULTIBLOCK_SELECTED'}
	SelectMultiblockData;
     case {'NON_ROTATE_MULTIBLOCK_SELECTED'}
	SelectNonRotatedMultiblock;
     case {'EDIT_NUM_PERM'}
	EditNumPerm;
     case {'EDIT_NUM_SPLIT'}
	EditNumSplit;
     case {'NONROTATED_BOOT'}
        NONROTATED_BOOT;
     case {'EDIT_NUM_BOOT'}
	EditNumBoot;
     case{'EDIT_POSTHOC_DATA_FILE'}
	EditPosthocDataFile;
     case{'SELECT_POSTHOC_DATA_FILE'}
	SelectPosthocDataFile;
     case {'BROWSE_CONTRAST_FILE'}
        dlg_title = 'Select Contrast File';
        [contrast_file,contrast_path] = rri_selectfile('*_STRUCTcontrast.txt',dlg_title);
        if (contrast_file ~= 0)
          c_filename = fullfile(contrast_path,contrast_file);
          set(findobj(gcf,'Tag','ContrastFileEdit'),'String',c_filename);
          set(findobj(gcf,'Tag','ContrastFileEdit'),'TooltipString',c_filename);
        end;

     % Run Task and Behavioral PLS
     %
     case {'RUN_BUTTON_PRESSED'}
        if SavePLSOptions == 1
           ExecutePLS;
        end
     case {'CRUN_BUTTON_PRESSED'}
        if (SavePLSOptions == 1);
           if cExecutePLS;
              calling_fig = getappdata(gcf,'CallingFigure');
              close(calling_fig);
              close(gcf);
              disp(' ');
              disp('Batch file is created! You can follow Batch Process')
              disp('section in PLS User''s Guide to run PLS analysis.');
              disp(' ');
%              uiresume(gcf);
           end
        end;
     case {'LOADBATCH_BUTTON_PRESSED'}
        LoadBatch;
     case {'CANCEL_BUTTON_PRESSED'}
        uiresume(gcf);
        return;
     case {'DELETE_FIGURE'}
        calling_fig = getappdata(gcf,'CallingFigure');

        if ishandle(calling_fig)
           set(calling_fig,'visible','on');
        end

        try
           load('pls_profile');
           pls_profile = which('pls_profile.mat');

           struct_analysis_pos = get(gcbf,'position');

           save(pls_profile, '-append', 'struct_analysis_pos');
        catch
        end
     otherwise
        disp(sprintf('ERROR: Unknown action "%s"',action));
   end;

   return;


% --------------------------------------------------------------------
function init()

   save_setting_status = 'on';
   struct_analysis_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(struct_analysis_pos) & strcmp(save_setting_status,'on')

      pos = struct_analysis_pos;

   else

      w = 0.6;
      h = 0.8;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
	'Units','normal', ...
	'Name','PLS Analysis for Structural datamat', ...
	'NumberTitle', 'off', ...
   	'Position',pos, ...
   	'Menubar','none', ...
        'DeleteFcn','struct_analysis_ui(''DELETE_FIGURE'');', ...
   	'Tag','PermutationOptionsFigure', ...
   	'ToolBar','none');

   %-------------- group frame -----------------
   %
   x = 0.04;
   y = 0.66;
   w = 0.92;
   h = 0.3;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','GroupProfileFrame');

   x = 0.06;
   h = 0.05;
   y = 0.9 - 0.2*h;
   w = 0.5;

   pos = [x y w h];

   fnt = 0.5;

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Datamat File', ...
   	'Style','text', ...
   	'Tag','SessionProfileLabel');

   x = 0.08;
   y = 0.85;
   w = 0.15;

   pos = [x y w h];

   g_h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Group #1:', ...
   	'Style','text', ...
   	'Tag','GroupLabel');

   x = x+w+0.01;
   w = 0.4;

   pos = [x y w h];

   g_h2 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
   	'Style','edit', ...
	'Enable','inactive', ...
   	'Tag','GroupEdit');

   x = x + w + 0.01;
   w = 0.1;

   pos = [x y w h];

   g_h3 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Add', ...
   	'Tag','GroupAddButton');

   x = x + w;
   w = 0.1;

   pos = [x y w h];

   g_h4 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Select', ...
   	'Tag','GroupSelectButton');

   x = x + w + 0.01;
   w = 0.04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% scroll bar
	'Style', 'slider', ...
   	'Units','normal', ...
   	'Min',1, ...
   	'Max',20, ...
   	'Value',20, ...
   	'Position',pos, ...
   	'Callback','struct_analysis_ui(''MOVE_SLIDER'');', ...
   	'Tag','GroupSlider');

   x = 0.08;
   y = 0.68 - 0.2*h;
   w = 0.18;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Group Total:', ...
   	'Style','text', ...
   	'Tag','NumGroupLabel');

   x = x+w+0.02;
   y = 0.68;
   w = 0.08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','0', ...
   	'Style','edit', ...
	'Enable','Inactive', ...
   	'Tag','NumberGroupEdit');

   x = x+w+0.04;
   w = 0.26;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
	'Style','checkbox', ...
        'Units','normal', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
	'Value', 0, ...
        'Position',pos, ...
        'HorizontalAlignment','left', ...
        'String','Save Datamats', ...
        'Tag','SaveDatamatChkbox');

   x = x+w+0.04;
   w = 0.18;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
	'Style','checkbox', ...
        'Units','normal', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
	'Value', 0, ...
        'Position',pos, ...
        'HorizontalAlignment','left', ...
        'String','Full Path', ...
        'Callback','struct_analysis_ui(''TOGGLE_FULL_PATH'');', ...
        'Tag','FullPathChkbox');

   %-------------- contrast frame -----------------
   %

   x = 0.04;
   y = 0.35;
   w = 0.92;
   h = 0.3;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','ContrastFrame');

   x = 0.06;
   h = 0.05;
   y = 0.59 - 0.2*h;
   w = 0.5;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','PLS Option', ...
   	'Style','text', ...
   	'Tag','ContrastsLabel');

   x = 0.06;
   y = 0.54;
   w = 0.28;
   h = 0.05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Style','radiobutton', ...
	'string','Mean-Centering PLS', ...
	'Value',1, ...
   	'Tag','TaskPLSBn', ...
   	'Callback','struct_analysis_ui(''TASKPLS_SELECTED'');', ...
        'Position',pos);

   y = y - h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Style','radio', ...
	'string','Non-Rotated Task PLS', ...
	'Value',0, ...
	'tag','SelectContrastData', ...
   	'Callback','struct_analysis_ui(''CONTRASTDATA_SELECTED'');', ...
	'position',pos);

   x = 0.36;
   y = 0.54;
   w = 0.27;
   h = 0.05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Style','radiobutton', ...
	'string','Regular Behav PLS', ...
	'Value',0, ...
   	'Tag','BehavPLSBn', ...
   	'Callback','struct_analysis_ui(''BEHAVPLS_SELECTED'');', ...
	'enable','on', ...
        'Position',pos);

   y = y - h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Style','radio', ...
	'string','Multiblock PLS', ...
	'Value',0, ...
	'tag','SelectMultiblockData', ...
   	'Callback','struct_analysis_ui(''MULTIBLOCK_SELECTED'');', ...
	'enable','on', ...
	'position',pos);

   x = 0.06;
   w = 0.29;
   x = 1 - x - w;
   y = 0.54;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Style','radio', ...
	'string','Non-Rotated Behav PLS', ...
	'Value',0, ...
	'tag','SelectNonRotateBehav', ...
   	'Callback','struct_analysis_ui(''NON_ROTATE_BEHAVPLS_SELECTED'');', ...
	'position',pos);

   y = y - h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Style','radio', ...
	'string','Non-Rotated Multiblock', ...
	'Value',0, ...
	'tag','SelectNonRotateMultiblock', ...
   	'Callback','struct_analysis_ui(''NON_ROTATE_MULTIBLOCK_SELECTED'');', ...
	'position',pos);

   y = 0.54 - h;

   x = 0.08;
   w = 0.25;
   y = y - 1.5*h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'ListboxTop',0, ...
   	'Style','text', ...
	'string','Contrast Data File:', ...
	'Enable','off', ...
	'Value',0, ...
	'tag','ContrastDataLabel', ...
	'visible','off', ...
	'position',pos);

   x = 0.38;
   y = y + 0.2*h;
   w = 0.32;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
   	'Style','edit', ...
	'enable','off', ...
	'visible','off', ...
   	'Tag','ContrastFileEdit');

   x = 0.06;
   w = 0.25;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
	'Enable','off', ...
   	'Style','push', ...
        'String', 'Load behavior data', ...
   	'Callback','struct_analysis_ui(''MENU_MODIFY_BEHAVDATA'');', ...
        'Tag', 'ModifyBehavdataMenu');

   x = x+w+0.01;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Load design data', ...
	'enable','off', ...
   	'Callback','struct_analysis_ui(''MENU_CREATE_CONTRASTS'');', ...
        'Tag', 'CreateContrastsMenu');

   x = 0.08;
   h = 0.05;
   y = 0.37 - 0.2*h;
   w = 0.25;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
	'Enable','off', ...
   	'String','Posthoc Data File:', ...
   	'Style','text', ...
	'visible','off', ...
   	'Tag','PosthocDataLabel');

   x = x+w+0.05;
   y = 0.37;
   w = 0.32;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
	'Enable','off', ...
   	'Style','edit', ...
   	'Callback','struct_analysis_ui(''EDIT_POSTHOC_DATA_FILE'');', ...
	'visible','off', ...
   	'Tag','PosthocDataEdit');

   x = 0.33;
   y = y - 0.01;
   w = 0.25;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Style','text', ...
	'string','Mean-Centering Type:', ...
	'Value',0, ...
	'tag','MeanCenteringTypeLabel', ...
	'position',pos);

   x = x+w;
   w = 0.06;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
	'style','popupmenu', ...
   	'BackgroundColor',[1 1 1], ...
        'Units','normal', ...
        'Position',pos, ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
	'Value',1, ...
        'String','0|1|2|3', ...
	'Tag', 'MeanCenteringTypeMenu');

   x = x+w+0.04;
   w = 0.2;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Style','text', ...
	'string','Correlation Mode:', ...
	'Value',0, ...
	'tag','CorModeLabel', ...	
	'Enable', 'off', ...
	'position',pos);

   x = x+w;
   w = 0.06;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
	'style','popupmenu', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
        'Units','normal', ...
        'Position',pos, ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
	'Enable', 'off', ...
	'Value',1, ...
        'String','0|2|4|6', ...
	'Tag', 'CorModeMenu');

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
	'visible','off', ...
	'Enable','off', ...
   	'Style','push', ...
   	'Callback','struct_analysis_ui(''SELECT_POSTHOC_DATA_FILE'');', ...
   	'Tag','PosthocDataBn');

   %-------------- permutation frame -----------------
   %

   x = 0.04;
   y = 0.12;
   w = 0.92;
   h = 0.22;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','PermutationFrame');

   x = 0.06;
   h = 0.05;
   y = 0.28 - 0.2*h - 0.02;
   w = 0.25;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Number of Permutation:', ...
   	'Style','text', ...
   	'Tag','NumPermutationLabel');

   x = x+w+0.01;
   y = 0.28 - 0.02;
   w = 0.08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','0', ...
   	'Style','edit', ...
   	'Callback','struct_analysis_ui(''EDIT_NUM_PERM'');', ...
   	'Tag','NumPermutationEdit');

   x = x+w+0.1;
   y = 0.28 - 0.2*h - 0.02;
   w = 0.1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','# of Split:', ...
   	'Style','text', ...
	'Enable', 'on', ...
   	'Tag','NumSplitLabel');

   x = x+w;
   y = 0.28 - 0.02;
   w = 0.08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','0', ...
   	'Style','edit', ...
	'Enable', 'on', ...
   	'Callback','struct_analysis_ui(''EDIT_NUM_SPLIT'');', ...
   	'Tag','NumSplitEdit');


   x = x+w+0.05;
   y = 0.28 - 0.2*h - 0.01;
   w = 0.22;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Use segment data', ...
   	'Style','checkbox', ...
	'value', 1, ...
	'Enable', 'on', ...
   	'Tag','UseSegmentData');


   x = 0.06;
   y = 0.23 - 0.2*h - 0.02;
   w = 0.25;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Number of Bootstrap:', ...
   	'Style','text', ...
   	'Tag','NumBootstrapLabel');

   x = x+w+0.01;
   y = 0.23 - 0.02;
   w = 0.08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','0', ...
   	'Style','edit', ...
	'Tooltip','Requires at least 3 subjects per group', ...
   	'Callback','struct_analysis_ui(''EDIT_NUM_BOOT'');', ...
   	'Tag','NumBootstrapEdit');


   x = x+w+0.1;
   y = 0.23 - 0.2*h - 0.02;
   w = 0.2;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Style','text', ...
	'string','Bootstrap Type:', ...
	'Value',0, ...
	'Enable', 'on', ...
	'visible','off', ...
	'tag','BootstrapTypeLabel', ...
	'position',pos);

   x = x+w;
   y = 0.23 - 0.03;
   w = 0.14;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
	'style','popupmenu', ...
   	'BackgroundColor',[1 1 1], ...
        'Units','normal', ...
        'Position',pos, ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
	'Value',1, ...
        'String','strat|nonstrat', ...
	'Enable', 'on', ...
	'visible','off', ...
	'Tag', 'BootstrapTypeMenu');


   x = 0.06;
   y = 0.18 - 0.2*h - 0.02;
   w = 0.25;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Confidence Level:', ...
   	'Style','text', ...
   	'Enable','on', ...
   	'Tag','ClimLabel');

   x = x+w+0.01;
   y = 0.18 - 0.02;
   w = 0.08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','95', ...
   	'Style','edit', ...
   	'Enable','on', ...
   	'Tag','ClimEdit');


   x = x+w+0.1;
   y = 0.18 - 0.2*h - 0.03;
   w = 0.35;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
	'Style','checkbox', ...
        'Units','normal', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
	'Value', 0, ...
        'Position',pos, ...
        'HorizontalAlignment','left', ...
	'Enable', 'on', ...
	'visible', 'off', ...
        'String','Non-Rotated Bootstrap', ...
   	'Callback','struct_analysis_ui(''NONROTATED_BOOT'');', ...
        'Tag','nonrotated_boot');


   x = 0.07;
   y = 0.06;
   w = 0.19;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Run', ...
   	'Callback','struct_analysis_ui(''RUN_BUTTON_PRESSED'');', ...
   	'Tag','RUNButton');

   x = 1-x-w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Cancel', ...
   	'Callback','struct_analysis_ui(''CANCEL_BUTTON_PRESSED'');', ...
   	'Tag','CANCELButton');

   x = .07+(1-2*.07-w)/3;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Save to Batch', ...
   	'Callback','struct_analysis_ui(''CRUN_BUTTON_PRESSED'');', ...
   	'Tag','CRUNButton');

   x = .07+2*(1-2*.07-w)/3;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Load from Batch', ...
   	'Callback','struct_analysis_ui(''LOADBATCH_BUTTON_PRESSED'');', ...
   	'Tag','LOADBATCHButton');

   x = 0.01;
   y = 0;
   w = 1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% Message Line
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

   % Menu Bar
   h_deselect = uimenu('Parent',h0, ...
	'Label', '&Deselect', ...
	'Tag', 'DeselectMenu');
   m1 = uimenu(h_deselect, ...
        'Label', 'Deselect conditions (before loading behavior data)', ...
   	'Callback','struct_analysis_ui(''MENU_DESELECT_CONDITION'');', ...
        'Tag', 'DeselectConditionMenu');
%   m1 = uimenu(h_deselect, ...
 %       'Label', 'Modify Behavior Data (behavior data should only contain the above selected conditions)', ...
  % 	'Callback','struct_analysis_ui(''MENU_MODIFY_BEHAVDATA'');', ...
   %     'Tag', 'ModifyBehavdataMenu');
   m1 = uimenu(h_deselect, ...
        'Label', 'Deselect behaviorblock conditions for Multiblock PLS (after loading behavior data)', ...
   	'Callback','struct_analysis_ui(''MENU_MULTIBLOCK_DESELECT_CONDITION'');', ...
	'enable', 'off', ...
        'Tag', 'MultiblockDeselectConditionMenu');

   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
           'Tag', 'Help');

%           'Callback','rri_helpfile_ui(''struct_analysis_hlp.txt'',''How to use PLS ANALYSIS'');', ...
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','web([''file:///'', which(''UserGuide.htm''), ''#_Toc128820723'']);', ...
	   'visible', 'on', ...
           'Tag', 'How');

   Hm_new = uimenu('Parent',Hm_topHelp, ...
           'Label', '&What''s new', ...
	   'Callback','rri_helpfile_ui(''whatsnew.txt'',''What''''s new'');', ...
           'Tag', 'New');

   Hm_about = uimenu('Parent',Hm_topHelp, ...
           'Label', '&About this program', ...
           'Tag', 'About', ...
           'CallBack', 'plsgui_version');

   % save handles for the group profiles
   %
   group_hdls = [g_h1, g_h2, g_h3, g_h4];
   setappdata(h0,'Group_hlist',group_hdls);

   group_template = copyobj_legacy(group_hdls,h0);
   set(group_template,'visible','off','Tag','GroupUIControls');
   setappdata(h0,'GroupTemplate',group_template);

   group_h = 0.05;
   setappdata(h0,'GroupHeight', group_h);

   lower_h = 0.08;	% vert. space for Number of groups etc.
   setappdata(h0,'lower_h',lower_h);

   setappdata(h0,'CurrGroupProfiles',[]);
   setappdata(h0,'TopGroupIdx',1);
   setappdata(h0,'full_path', 0);
   setappdata(h0,'num_selected_cond',1);
   setappdata(h0,'posthoc_data_file','');

   setappdata(h0,'cond_selection',[]);
   setappdata(h0,'bscan',[]);
   setappdata(gcf,'behavname',{});
   setappdata(gcf,'behavdata',[]);
   setappdata(gcf,'behavdata_lst',{});

   SetupGroupRows;
   CreateAddRow;
   DisplayGroupProfiles(0);
   UpdateSlider;


   session_lst = dir('*_STRUCTsession.mat');
   sessiondata_lst = dir('*_STRUCTsessiondata.mat');

   if ~isempty(session_lst) & isempty(sessiondata_lst)
      msg = 'PLS now combines session/datamat files to sessiondata ';
      msg = [msg 'file. You must use commmand session2sessiondata '];
      msg = [msg 'to convert session/datamat into sessiondata. For '];
      msg = [msg 'more detail, please type: help session2sessiondata'];
      uiwait(msgbox(msg,'Error','modal'));
   end


   return;							% Init


%----------------------------------------------------------------------------
function SetupGroupRows()

   group_hdls = getappdata(gcf,'Group_hlist');
   group_h = getappdata(gcf,'GroupHeight');
   lower_h = getappdata(gcf,'lower_h');

   bottom_pos = get(findobj(gcf,'Tag','GroupProfileFrame'),'Position');
   top_pos = get(group_hdls(1,1),'Position');

   rows = floor(( top_pos(2) - bottom_pos(2) - lower_h) / group_h + 1);
   v_pos = top_pos(2) - [0:rows-1]*group_h;

   group_template = getappdata(gcf,'GroupTemplate');
   edit_cbf = '';
   select_cbf = 'struct_analysis_ui(''SELECT_GROUP'');';
   delete_cbf = 'struct_analysis_ui(''DELETE_GROUP'');';
   buttondown_group = 'struct_analysis_ui(''BUTTONDOWN_GROUP'');';

   nr = size(group_hdls,1);
   if (rows < nr)			% too many rows
      for i=rows+1:nr,
          delete(group_hdls(i,:));
      end;
      group_hdls = group_hdls(1:rows,:);
   else					% add new rows
      for i=nr+1:rows,
         new_g_hdls = copyobj_legacy(group_template,gcf);
         group_hdls = [group_hdls; new_g_hdls'];
      end;
   end;

   v = 'off';
   top_g_hdls = group_hdls(1,:);
   for i=1:rows,
      new_g_hdls = group_hdls(i,:);
      pos = get(top_g_hdls(1),'Position'); pos(2) = v_pos(i);
      set(new_g_hdls(1),'String','?','Position',pos,'Visible',v,'UserData',i);

      pos = get(top_g_hdls(2),'Position'); pos(2) = v_pos(i);
      set(new_g_hdls(2),'String','', 'Position',pos, 'Visible',v, ...
                        'UserData',i, 'Callback',edit_cbf, ...
			'ButtonDownFcn',buttondown_group);

      pos = get(top_g_hdls(3),'Position'); pos(2) = v_pos(i);
      set(new_g_hdls(3),'String','Delete','Position',pos,'Visible',v, ...
                        'UserData',i,'Callback',delete_cbf);

      pos = get(top_g_hdls(4),'Position'); pos(2) = v_pos(i);
      set(new_g_hdls(4),'String','Select','Position',pos,'Visible',v, ...
                        'UserData',i,'Callback',select_cbf);

   end;


   %  setup slider position
   %
   slider_hdl = findobj(gcf,'Tag','GroupSlider');
   s_pos = get(slider_hdl,'Position');

   s_pos(2) = v_pos(end);
   s_pos(4) = group_h * rows;
   set(slider_hdl,'Position',s_pos);


   setappdata(gcf,'Group_hlist',group_hdls);
   setappdata(gcf,'NumRows',rows);

   return;					% SetupGroupRows


%----------------------------------------------------------------------------
function DisplayGroupProfiles(full_path)

   curr_group_profiles = getappdata(gcf,'CurrGroupProfiles');
   top_group_idx = getappdata(gcf,'TopGroupIdx');
   group_hdls = getappdata(gcf,'Group_hlist');
   rows = getappdata(gcf,'NumRows');

   num_group = length(curr_group_profiles);

   last_row = 0;
   group_idx = top_group_idx;

   for i=1:rows
      g_hdls = group_hdls(i,:);
      if (group_idx <= num_group),
         set(g_hdls(1),'String',sprintf('Group #%d:',group_idx),'Visible','on');

         curr_group_name = sprintf('%s',curr_group_profiles{group_idx});
         if(full_path)
            set(g_hdls(2), 'String', curr_group_name, ...
                       'Visible','on');
         else
            [p_path, p_name, p_ext] = fileparts(curr_group_name);
            curr_group_name = [p_name p_ext];
            set(g_hdls(2), 'String', curr_group_name, ...
                       'Visible','on');
         end

         set(g_hdls(3),'String','Delete','Enable','on','Visible','on');
         set(g_hdls(4),'String','Select','Enable','on','Visible','on');

         group_idx = group_idx + 1;
         last_row = i;
      else
         set(g_hdls(1),'String','','Visible','off');
         set(g_hdls(2),'String','','Visible','off');
         set(g_hdls(3),'String','Delete','Visible','off');
         set(g_hdls(4),'String','Select','Visible','off');
      end;
   end;

   %  display or hide the add row
   %
   if (last_row < rows)
      row_idx = last_row+1;
      g_hdls = group_hdls(row_idx,:);
      pos = get(g_hdls(1),'Position');
      ShowAddRow(group_idx,pos(2),row_idx);
   else
      HideAddRow;
   end;

   %  display or hide the slider
   %
   if (top_group_idx ~= 1) | (last_row == rows)
     ShowSlider;
   else
     HideSlider;
   end;

   return;						% DisplayGroupProfiles


%----------------------------------------------------------------------------
function CreateAddRow()

   group_template = getappdata(gcf,'GroupTemplate');
   buttondown_group = 'struct_analysis_ui(''BUTTONDOWN_GROUP'');';

   a_hdls = copyobj_legacy(group_template,gcf);

   set(a_hdls(1),'String','','Foreground',[0.4 0.4 0.4],'Visible','off', ...
                 'UserData',1);

   set(a_hdls(2),'String','','Background',[0.9 0.9 0.9], 'Visible','off',...
		 'ButtonDownFcn',buttondown_group,'enable','inactive');

   set(a_hdls(3),'String','Add','Visible','off', ...
		     'Callback','struct_analysis_ui(''ADD_GROUP'');');

   set(a_hdls(4),'Visible','off','Enable','off');

   setappdata(gcf,'AddRowHdls',a_hdls);

   return;						% CreateAddRow


%----------------------------------------------------------------------------
function ShowAddRow(group_idx,v_pos,row_idx)

   a_hdls = getappdata(gcf,'AddRowHdls');
   g_hdls = getappdata(gcf,'Group_hlist');

   for j=1:length(a_hdls),
      new_pos = get(g_hdls(1,j),'Position');
      new_pos(2) = v_pos;

      set(a_hdls(j),'Position',new_pos);
      set(a_hdls(j),'Visible','on');
   end;

   set(a_hdls(1),'String',sprintf('Group #%d:',group_idx), ...
		'Visible','On','UserData',row_idx);
   set(a_hdls(2),'String','');
   set(a_hdls(4),'Visible','Off');


   return;						% ShowAddRow


%----------------------------------------------------------------------------
function HideAddRow()

   a_hdls = getappdata(gcf,'AddRowHdls');
   for j=1:length(a_hdls),
      set(a_hdls(j),'Visible','off');
   end;

   return;						% HideAddRow


%----------------------------------------------------------------------------
function DeleteGroupProfiles()

   setappdata(gcf,'new_evt_list',[]);
   setappdata(gcf,'behavdata',[]);
   setappdata(gcf,'behavdata_lst',{});
   set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'value',1);
   set(findobj(gcf,'Tag','TaskPLSBn'),'Value',1);
   SelectTaskPLS;
   set(findobj(gcf,'Tag','NumPermutationEdit'),'String','0');
   EditNumPerm;
   set(findobj(gcf,'Tag','NumBootstrapEdit'),'String','0');
   EditNumBoot;

   curr_group_profiles = getappdata(gcf,'CurrGroupProfiles');
   group_hdls = getappdata(gcf,'Group_hlist');

   row_idx = get(gcbo,'UserData');
   group_id = get(group_hdls(row_idx,1),'String');
   start_idx = findstr(group_id,'#')+1;
   group_idx = str2num(group_id(start_idx:end-1));

   mask = ones(1,length(curr_group_profiles));  mask(group_idx) = 0;
   idx = find(mask == 1);
   curr_group_profiles = curr_group_profiles(idx);

   num_group = length(curr_group_profiles);
   set(findobj(gcf,'Tag','NumberGroupEdit'),'String',num2str(num_group));

   setappdata(gcf,'CurrGroupProfiles',curr_group_profiles);

   full_path = getappdata(gcf,'full_path');
   DisplayGroupProfiles(full_path);

   UpdateSlider;

   return;						% DeleteGroupProfiles


%----------------------------------------------------------------------------
function AddGroupProfiles()

   curr_group_profiles = getappdata(gcf,'CurrGroupProfiles');
   num_group = length(curr_group_profiles)+1;

   rows = getappdata(gcf,'NumRows');
   a_hdls = getappdata(gcf,'AddRowHdls');

   group_id = get(a_hdls(1),'String');
   start_idx = findstr(group_id,'#')+1;
   group_idx = str2num(group_id(start_idx:end-1));

   group_profile = get(a_hdls(2),'String');

   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   pf_path = curr;
   pf_name = '';

   % if no pre-entry, open rri_getfiles window
   % otherwise, just read from pre-entry
   %
   if isempty(group_profile)

      if(group_idx ~= 1)
         [pf_path pf_name pf_ext] = fileparts(curr_group_profiles{group_idx-1});
      end

      pf_path = fullfile(pf_path, '*_STRUCTsessiondata.mat');
      [pf_name pf_path] = rri_selectfile(pf_path, 'Select a session profile');

	% if there is error, rri_selectfile return 0 for pf_name or pf_path
	% isstr(0) return 0
        %
      if (~isstr(pf_name) | ~isstr(pf_path))
         return;
      end

      cd(pf_path);
      curr_group_profiles{num_group} = fullfile(pf_path, pf_name);

   elseif exist(group_profile) ~= 2
      msg = 'ERROR: Could not find the session profile you specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   else
      curr_group_profiles{num_group} = group_profile;
   end;

   if isempty(getappdata(gcf,'cond_selection'))
      tmp = load(curr_group_profiles{1});
      cond_selection = ones(1, tmp.session_info.num_conditions);
      setappdata(gcf, 'cond_selection', cond_selection);
   end

   setappdata(gcf,'behavname',{});
   setappdata(gcf,'behavdata',[]);
   setappdata(gcf,'behavdata_lst',{});

   setappdata(gcf,'CurrGroupProfiles',curr_group_profiles);
   set(findobj(gcf,'Tag','NumberGroupEdit'),'String',num2str(num_group));

   new_group_row = get(a_hdls(1),'UserData');
   if (new_group_row == rows),  	% the new group row is the last row
      top_group_idx = getappdata(gcf,'TopGroupIdx');
      setappdata(gcf,'TopGroupIdx',top_group_idx+1);
   end;

   group_hdls = getappdata(gcf,'Group_hlist');

   full_path = getappdata(gcf,'full_path');
   DisplayGroupProfiles(full_path);

   UpdateSlider;

   return;						% AddGroupProfiles


%----------------------------------------------------------------------------
function SelectGroupProfiles(group_idx)

   curr_group_profiles = getappdata(gcf,'CurrGroupProfiles');
   group_hdls = getappdata(gcf,'Group_hlist');

   row_idx = get(gcbo,'UserData');
   group_id = get(group_hdls(row_idx,1),'String');
   start_idx = findstr(group_id,'#')+1;
   group_idx = str2num(group_id(start_idx:end-1));

   curr_profile = curr_group_profiles{group_idx};
   [pf_path pf_name pf_ext] = fileparts(curr_profile);
   pf_path = fullfile(pf_path, '*_STRUCTsessiondata.mat');
   [pf_name pf_path] = rri_selectfile(pf_path, 'Select a session profile');

   curr_group_profiles{group_idx} = fullfile(pf_path, pf_name);

	% if there is error, rri_selectfile return 0 for pf_name or pf_path
	% isstr(0) return 0
        %
      if (~isstr(pf_name) | ~isstr(pf_path))
         return;
      end;

   cd(pf_path);
   profiles_str = fullfile(pf_path, pf_name);

   if ~isempty(profiles_str)
      curr_group_profiles{group_idx} = profiles_str;
      setappdata(gcf,'CurrGroupProfiles',curr_group_profiles);
      set(group_hdls(row_idx,2),'String',profiles_str);

      tmp = load(curr_group_profiles{1});
      cond_selection = ones(1, tmp.session_info.num_conditions);
      setappdata(gcf, 'cond_selection', cond_selection);
      setappdata(gcf,'behavname',{});
      setappdata(gcf,'behavdata',[]);
      setappdata(gcf,'behavdata_lst',{});
   end;

   full_path = getappdata(gcf,'full_path');
   DisplayGroupProfiles(full_path);

   UpdateSlider;

   return;						% SelectGroupProfiles


%----------------------------------------------------------------------------
function MoveSlider()

   slider_hdl = findobj(gcf,'Tag','GroupSlider');
   curr_value = round(get(slider_hdl,'Value'));
   total_rows = round(get(slider_hdl,'Max'));

   top_group_idx = total_rows - curr_value + 1;

   setappdata(gcf,'TopGroupIdx',top_group_idx);

   full_path = getappdata(gcf,'full_path');
   DisplayGroupProfiles(full_path);

   return;						% MoveSlider


%----------------------------------------------------------------------------
function UpdateSlider()

   top_group_idx = getappdata(gcf,'TopGroupIdx');
   rows = getappdata(gcf,'NumRows');

   curr_group_profiles = getappdata(gcf,'CurrGroupProfiles');
   num_groups = length(curr_group_profiles);

   total_rows = num_groups + 1;
   slider_hdl = findobj(gcf,'Tag','GroupSlider');

   if (total_rows > 1)           % don't need to update when no group
       set(slider_hdl,'Min',1,'Max',total_rows, ...
                  'Value',total_rows-top_group_idx+1, ...
                  'Sliderstep',[1/(total_rows-1)-0.00001 1/(total_rows-1)]);
   end;

   return;                                              % UpdateSlider


%----------------------------------------------------------------------------
function ShowSlider()

   slider_hdl = findobj(gcf,'Tag','GroupSlider');
   set(slider_hdl,'visible','on'); 

   return;						% ShowSlider


%----------------------------------------------------------------------------
function HideSlider()

   slider_hdl = findobj(gcf,'Tag','GroupSlider');
   set(slider_hdl,'visible','off');

   return;						% HideSlider


%----------------------------------------------------------------------------
function SelectTaskPLS;

   if get(findobj(gcf,'Tag','TaskPLSBn'),'Value') == 0		% click itself
      set(findobj(gcf,'Tag','TaskPLSBn'),'Value',1);
   else
      set(findobj(gcf,'Tag','SelectContrastData'),'Value',0);
      set(findobj(gcf,'Tag','BehavPLSBn'),'Value',0);
      set(findobj(gcf,'Tag','SelectMultiblockData'),'Value',0);
      set(findobj(gcf,'Tag','SelectNonRotateBehav'),'Value',0);
      set(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'Value',0);

      set(findobj(gcf,'Tag','ContrastFileEdit'),'BackGroundColor',[0.9 0.9 0.9]);
      set(findobj(gcf,'Tag','ContrastDataLabel'),'Enable','off');
      set(findobj(gcf,'Tag','ContrastFileEdit'),'Enable','off');
      set(findobj(gcf,'Tag','CreateContrastsMenu'),'Enable','off');

      set(findobj(gcf,'Tag','PosthocDataEdit'),'BackGroundColor',[0.9 0.9 0.9]);
      set(findobj(gcf,'Tag','ModifyBehavdataMenu'),'Enable','off');
      set(findobj(gcf,'Tag','PosthocDataLabel'),'Enable','off');
      set(findobj(gcf,'Tag','PosthocDataEdit'),'Enable','off');
      set(findobj(gcf,'Tag','PosthocDataBn'),'Enable','off');
      set(findobj(gcf,'Tag','MeanCenteringTypeLabel'),'Enable','on');
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'Enable','on');
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'background',[1 1 1]);

      set(findobj(gcf,'Tag','CorModeLabel'),'Enable','off');
      set(findobj(gcf,'Tag','CorModeMenu'),'Enable','off','value',1);
      set(findobj(gcf,'Tag','CorModeMenu'),'background',[0.9 0.9 0.9]);

      num_boot = str2num(get(findobj(gcf,'Tag','NumBootstrapEdit'),'String'));
      if  ~isempty(num_boot) & num_boot ~= 0
         set(findobj(gcf,'Tag','ClimEdit'),'BackGroundColor',[1 1 1]);
         set(findobj(gcf,'Tag','ClimLabel'),'Enable','on');
         set(findobj(gcf,'Tag','ClimEdit'),'Enable','on');
      end

      set(findobj(gcf,'Tag','MultiblockDeselectConditionMenu'),'Enable','off');
   end

   return;						% SelectTaskPLS


%----------------------------------------------------------------------------
function SelectContrastData;

   if get(findobj(gcf,'Tag','SelectContrastData'),'Value') == 0	% click itself
      set(findobj(gcf,'Tag','SelectContrastData'),'Value',1);
   else
      set(findobj(gcf,'Tag','TaskPLSBn'),'Value',0);
      set(findobj(gcf,'Tag','BehavPLSBn'),'Value',0);
      set(findobj(gcf,'Tag','SelectMultiblockData'),'Value',0);
      set(findobj(gcf,'Tag','SelectNonRotateBehav'),'Value',0);
      set(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'Value',0);

      set(findobj(gcf,'Tag','PosthocDataEdit'),'BackGroundColor',[0.9 0.9 0.9]);
      set(findobj(gcf,'Tag','ModifyBehavdataMenu'),'Enable','off');
      set(findobj(gcf,'Tag','PosthocDataLabel'),'Enable','off');
      set(findobj(gcf,'Tag','PosthocDataEdit'),'Enable','off');
      set(findobj(gcf,'Tag','PosthocDataBn'),'Enable','off');
      set(findobj(gcf,'Tag','MeanCenteringTypeLabel'),'Enable','on');
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'Enable','on');
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'background',[1 1 1]);

      set(findobj(gcf,'Tag','CorModeLabel'),'Enable','off');
      set(findobj(gcf,'Tag','CorModeMenu'),'Enable','off','value',1);
      set(findobj(gcf,'Tag','CorModeMenu'),'background',[0.9 0.9 0.9]);

      set(findobj(gcf,'Tag','ContrastFileEdit'),'BackGroundColor',[1 1 1]);
      set(findobj(gcf,'Tag','ContrastDataLabel'),'Enable','on');
      set(findobj(gcf,'Tag','ContrastFileEdit'),'Enable','on');
      set(findobj(gcf,'Tag','CreateContrastsMenu'),'Enable','on');

      num_boot = str2num(get(findobj(gcf,'Tag','NumBootstrapEdit'),'String'));
      if  ~isempty(num_boot) & num_boot ~= 0
         set(findobj(gcf,'Tag','ClimEdit'),'BackGroundColor',[1 1 1]);
         set(findobj(gcf,'Tag','ClimLabel'),'Enable','on');
         set(findobj(gcf,'Tag','ClimEdit'),'Enable','on');
      end

      set(findobj(gcf,'Tag','MultiblockDeselectConditionMenu'),'Enable','off');
   end

   return;						% SelectContrastData


%----------------------------------------------------------------------------
function SelectBehavPLS

   if get(findobj(gcf,'Tag','BehavPLSBn'),'Value') == 0		% click itself
      set(findobj(gcf,'Tag','BehavPLSBn'),'Value',1);
   else
      set(findobj(gcf,'Tag','TaskPLSBn'),'Value',0);
      set(findobj(gcf,'Tag','SelectMultiblockData'),'Value',0);
      set(findobj(gcf,'Tag','SelectContrastData'),'Value',0);
      set(findobj(gcf,'Tag','SelectNonRotateBehav'),'Value',0);
      set(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'Value',0);

      set(findobj(gcf,'Tag','ContrastFileEdit'),'BackGroundColor',[0.9 0.9 0.9]);
      set(findobj(gcf,'Tag','ContrastDataLabel'),'Enable','off');
      set(findobj(gcf,'Tag','ContrastFileEdit'),'Enable','off');
      set(findobj(gcf,'Tag','CreateContrastsMenu'),'Enable','off');

      set(findobj(gcf,'Tag','PosthocDataEdit'),'BackGroundColor',[1 1 1]);
      set(findobj(gcf,'Tag','ModifyBehavdataMenu'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataLabel'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataEdit'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataBn'),'Enable','on');

      set(findobj(gcf,'Tag','MeanCenteringTypeLabel'),'Enable','off');
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'Enable','off','value',1);
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'background',[0.9 0.9 0.9]);

      set(findobj(gcf,'Tag','CorModeLabel'),'Enable','on');
      set(findobj(gcf,'Tag','CorModeMenu'),'Enable','on');
      set(findobj(gcf,'Tag','CorModeMenu'),'background',[1 1 1]);

      num_boot = str2num(get(findobj(gcf,'Tag','NumBootstrapEdit'),'String'));
      if  ~isempty(num_boot) & num_boot ~= 0
         set(findobj(gcf,'Tag','ClimEdit'),'BackGroundColor',[1 1 1]);
         set(findobj(gcf,'Tag','ClimLabel'),'Enable','on');
         set(findobj(gcf,'Tag','ClimEdit'),'Enable','on');
      end

      set(findobj(gcf,'Tag','MultiblockDeselectConditionMenu'),'Enable','off');
   end

   return;						% SelectBehavPLS


%----------------------------------------------------------------------------
function SelectMultiblockData;

   if get(findobj(gcf,'Tag','SelectMultiblockData'),'Value') == 0	% click itself
      set(findobj(gcf,'Tag','SelectMultiblockData'),'Value',1);
   else
      set(findobj(gcf,'Tag','TaskPLSBn'),'Value',0);
      set(findobj(gcf,'Tag','BehavPLSBn'),'Value',0);
      set(findobj(gcf,'Tag','SelectContrastData'),'Value',0);
      set(findobj(gcf,'Tag','SelectNonRotateBehav'),'Value',0);
      set(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'Value',0);

      set(findobj(gcf,'Tag','ContrastFileEdit'),'BackGroundColor',[0.9 0.9 0.9]);
      set(findobj(gcf,'Tag','ContrastDataLabel'),'Enable','off');
      set(findobj(gcf,'Tag','ContrastFileEdit'),'Enable','off');
      set(findobj(gcf,'Tag','CreateContrastsMenu'),'Enable','off');

      set(findobj(gcf,'Tag','PosthocDataEdit'),'BackGroundColor',[1 1 1]);
      set(findobj(gcf,'Tag','ModifyBehavdataMenu'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataLabel'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataEdit'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataBn'),'Enable','on');

      set(findobj(gcf,'Tag','MeanCenteringTypeLabel'),'Enable','on');
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'Enable','on');
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'background',[1 1 1]);

      set(findobj(gcf,'Tag','CorModeLabel'),'Enable','on');
      set(findobj(gcf,'Tag','CorModeMenu'),'Enable','on');
      set(findobj(gcf,'Tag','CorModeMenu'),'background',[1 1 1]);

      num_boot = str2num(get(findobj(gcf,'Tag','NumBootstrapEdit'),'String'));
      if  ~isempty(num_boot) & num_boot ~= 0
         set(findobj(gcf,'Tag','ClimEdit'),'BackGroundColor',[1 1 1]);
         set(findobj(gcf,'Tag','ClimLabel'),'Enable','on');
         set(findobj(gcf,'Tag','ClimEdit'),'Enable','on');
      end

      set(findobj(gcf,'Tag','MultiblockDeselectConditionMenu'),'Enable','on');
   end

   return;						% SelectMultiblockData


%----------------------------------------------------------------------------
function EditNumPerm

      num_perm = str2num(get(findobj(gcf,'Tag','NumPermutationEdit'),'String'));
      if  ~isempty(num_perm) & num_perm ~= 0
%         set(findobj(gcf,'Tag','NumSplitLabel'),'Enable','on');
 %        set(findobj(gcf,'Tag','NumSplitEdit'),'Enable','on');
  %       set(findobj(gcf,'Tag','NumSplitEdit'),'BackGroundColor',[1 1 1]);
      else
%         set(findobj(gcf,'Tag','NumSplitLabel'),'Enable','off');
 %        set(findobj(gcf,'Tag','NumSplitEdit'),'Enable','off','String','0');
  %       set(findobj(gcf,'Tag','NumSplitEdit'),'BackGroundColor',[0.9 0.9 0.9]);
      end

   return;						% EditNumPerm


%----------------------------------------------------------------------------
function EditNumSplit

   num_split = str2num(get(findobj(gcf,'Tag','NumSplitEdit'),'String'));

   if  ~isempty(num_split) & num_split > 0
      set(findobj(gcf,'Tag','nonrotated_boot'),'value',1,'enable','on');
   end

   return;						% EditNumSplit


%----------------------------------------------------------------------------
function NONROTATED_BOOT

   nb = get(findobj(gcf,'Tag','nonrotated_boot'),'value');

   if nb
      set(findobj(gcf,'Tag','NumSplitEdit'),'string',num2str(100));
   end

   return;						% NONROTATED_BOOT


%----------------------------------------------------------------------------
function EditNumBoot

   %  contain behavpls
   %
%   if get(findobj(gcf,'Tag','BehavPLSBn'),'Value') == 1 | ...
%	get(findobj(gcf,'Tag','SelectMultiblockData'),'Value') == 1

      num_boot = str2num(get(findobj(gcf,'Tag','NumBootstrapEdit'),'String'));
      if  ~isempty(num_boot) & num_boot ~= 0
%         set(findobj(gcf,'Tag','ClimEdit'),'BackGroundColor',[1 1 1]);
 %        set(findobj(gcf,'Tag','ClimLabel'),'Enable','on');
  %       set(findobj(gcf,'Tag','ClimEdit'),'Enable','on');

%         set(findobj(gcf,'Tag','BootstrapTypeLabel'),'Enable','on');
 %        set(findobj(gcf,'Tag','BootstrapTypeMenu'),'Enable','on');
  %       set(findobj(gcf,'Tag','BootstrapTypeMenu'),'BackGroundColor',[1 1 1]);

%         set(findobj(gcf,'Tag','nonrotated_boot'),'Enable','on');
      else
%         set(findobj(gcf,'Tag','ClimEdit'),'BackGroundColor',[0.9 0.9 0.9]);
 %        set(findobj(gcf,'Tag','ClimLabel'),'Enable','off');
         set(findobj(gcf,'Tag','ClimEdit'),'String','95');
  %       set(findobj(gcf,'Tag','ClimEdit'),'Enable','off');

%         set(findobj(gcf,'Tag','BootstrapTypeLabel'),'Enable','off');
 %        set(findobj(gcf,'Tag','BootstrapTypeMenu'),'Enable','off','value',1);
  %       set(findobj(gcf,'Tag','BootstrapTypeMenu'),'BackGroundColor',[0.9 0.9 0.9]);

%         set(findobj(gcf,'Tag','nonrotated_boot'),'Enable','off','value',0);
      end
%   end

   return;						% EditNumBoot


%----------------------------------------------------------------------------
function SelectContrastNone;

   if get(findobj(gcf,'Tag','ContrastNoneChkBox'),'Value') == 0		% click itself
      set(findobj(gcf,'Tag','ContrastNoneChkBox'),'Value',1);
   else
      set(findobj(gcf,'Tag','ContrastHelmertChkBox'),'Value',0);

      set(findobj(gcf,'Tag','ContrastFileChkBox'),'Value',0);
      set(findobj(gcf,'Tag','ContrastFileEdit'),'Enable','off');
      set(findobj(gcf,'Tag','ContrastFileButton'),'Enable','off');
   end

   return;						% SelectContrastNone


%----------------------------------------------------------------------------
function SelectContrastHelmert

   if get(findobj(gcf,'Tag','ContrastHelmertChkBox'),'Value') == 0
      set(findobj(gcf,'Tag','ContrastHelmertChkBox'),'Value',1);
   else
      set(findobj(gcf,'Tag','ContrastNoneChkBox'),'Value',0);

      set(findobj(gcf,'Tag','ContrastFileChkBox'),'Value',0);
      set(findobj(gcf,'Tag','ContrastFileEdit'),'Enable','off');
      set(findobj(gcf,'Tag','ContrastFileButton'),'Enable','off');
   end

   return;						% SelectContrastHelmert


%----------------------------------------------------------------------------
function SelectContrastFile

   if get(findobj(gcf,'Tag','ContrastFileChkBox'),'Value') == 0
      set(findobj(gcf,'Tag','ContrastFileChkBox'),'Value',1);
   else
      set(findobj(gcf,'Tag','ContrastNoneChkBox'),'Value',0);
      set(findobj(gcf,'Tag','ContrastHelmertChkBox'),'Value',0);

      set(findobj(gcf,'Tag','ContrastFileEdit'),'Enable','on');
      set(findobj(gcf,'Tag','ContrastFileButton'),'Enable','on');
   end

   return;						% SelectContrastFile

%----------------------------------------------------------------------------
function status = SavePLSOptions

   status = -1;
   setappdata(gcf,'PLSoptions',[]);

   %  profiles
   %
   curr_profiles = getappdata(gcf,'CurrGroupProfiles');
   num_groups = length(curr_profiles);

   if num_groups == 0
      msg = 'ERROR: Datamat group is not specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   save_datamat = get(findobj(gcf,'Tag','SaveDatamatChkbox'),'Value');
   isbehav = get(findobj(gcf,'Tag','BehavPLSBn'),'Value');
   iscontrast = get(findobj(gcf,'Tag','SelectContrastData'),'Value');
   ismultiblock = get(findobj(gcf,'Tag','SelectMultiblockData'),'Value');
   isnonrotatebehav = get(findobj(gcf,'Tag','SelectNonRotateBehav'),'Value');
   isnonrotatemultiblock = get(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'Value');

   PLSoptions.meancentering_type = get(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'Value')-1;
   CorModeValue = [0 2 4 6];
   PLSoptions.cormode = CorModeValue(get(findobj(gcf,'Tag','CorModeMenu'),'Value'));
   BootTypeValue = {'strat', 'nonstrat'};
   PLSoptions.boot_type = BootTypeValue{get(findobj(gcf,'Tag','BootstrapTypeMenu'),'Value')};
   PLSoptions.nonrotated_boot = get(findobj(gcf,'Tag','nonrotated_boot'),'Value');
   PLSoptions.is_struct = get(findobj(gcf,'Tag','UseSegmentData'),'Value');

   PLSoptions.save_datamat = save_datamat;
   PLSoptions.cond_selection = getappdata(gcf,'cond_selection');
   PLSoptions.behavname = getappdata(gcf,'behavname');
   PLSoptions.behavdata = getappdata(gcf,'behavdata');
   PLSoptions.behavdata_lst = getappdata(gcf,'behavdata_lst');
   PLSoptions.bscan = getappdata(gcf,'bscan');
   if isempty(PLSoptions.bscan)
      PLSoptions.bscan = 1:sum(PLSoptions.cond_selection);
   end

   %  Check data integrity for behav PLS analysis
   %
   PLSoptions.profiles = cell(1,num_groups);

   for i=1:num_groups
      PLSoptions.profiles{i} = curr_profiles{i};

      behavname = {};

      warning off;
      try
         load(curr_profiles{i},'behavname');
      catch
      end
      warning on;

%      if isbehav & isempty(behavname) & isempty(PLSoptions.behavdata)
%         msg = ['ERROR: Behav data is required for BehavPLS'];
%%		curr_profiles{i}, '.'];
%         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%         return;
%      end
   end

   % make sure the conditions in each profile are the same
   %
   total_profiles = ValidateProfiles(PLSoptions.profiles);

   if (total_profiles == -1)
      return;
   end;

   PLSoptions.TotalNumberProfiles = total_profiles;

   if (ismultiblock == 1)

      PLSoptions.ismultiblock = 1;
      PLSoptions.isnonrotatebehav = 0;
      PLSoptions.isnonrotatemultiblock = 0;
      PLSoptions.ismean = 1;
      PLSoptions.isbehav = 1;
      PLSoptions.iscontrast = 0;
      PLSoptions.ContrastFile = [];

      %  posthoc data file
      %
      posthoc_data_file = getappdata(gcf, 'posthoc_data_file');
      if ~isempty(posthoc_data_file)
         try
            PLSoptions.posthoc = load(posthoc_data_file);
         catch
            msg = sprintf('Invalid posthoc data file.');
            set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
            return;
         end
         [r_posthoc,c_posthoc] = size(PLSoptions.posthoc);
         if r_posthoc ~= getappdata(gcf,'num_selected_behav') * getappdata(gcf,'num_selected_cond') * num_groups
            msg = sprintf('Rows in Posthoc data file do not match.');
            set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
            return;
         end
      else
         PLSoptions.posthoc = [];
      end

   elseif (isbehav == 1)

      PLSoptions.ismultiblock = 0;
      PLSoptions.isnonrotatebehav = 0;
      PLSoptions.isnonrotatemultiblock = 0;
      PLSoptions.ismean = 0;
      PLSoptions.isbehav = 1;
      PLSoptions.iscontrast = 0;
      PLSoptions.ContrastFile = [];

      %  posthoc data file
      %
      posthoc_data_file = getappdata(gcf, 'posthoc_data_file');
      if ~isempty(posthoc_data_file)
         try
            PLSoptions.posthoc = load(posthoc_data_file);
         catch
            msg = sprintf('Invalid posthoc data file.');
            set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
            return;
         end
         [r_posthoc,c_posthoc] = size(PLSoptions.posthoc);
         if r_posthoc ~= getappdata(gcf,'num_selected_behav') * getappdata(gcf,'num_selected_cond') * num_groups
            msg = sprintf('Rows in Posthoc data file do not match.');
            set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
            return;
         end
      else
         PLSoptions.posthoc = [];
      end

   elseif (isnonrotatebehav == 1)

      PLSoptions.ismultiblock = 0;
      PLSoptions.isnonrotatebehav = 1;
      PLSoptions.isnonrotatemultiblock = 0;
      PLSoptions.ismean = 0;
      PLSoptions.isbehav = 0;
      PLSoptions.iscontrast = 0;
      PLSoptions.posthoc = [];
      PLSoptions.ContrastFile = get(findobj(gcf,'tag','ContrastFileEdit'),'string');
      ContrastMatrix = getappdata(gcf,'ContrastMatrix');

      if isempty(PLSoptions.ContrastFile) & isempty(ContrastMatrix)
          msg = 'ERROR: Contrast file is not specified.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
      end;

if isempty(ContrastMatrix)
      try
          use_contrast = load(PLSoptions.ContrastFile,'conditions');
          cond_selection = getappdata(gcf,'cond_selection');
          behavname = getappdata(gcf,'behavname');

          if size(use_contrast,1) ~= num_groups*sum(cond_selection)*length(behavname)
             msg = 'ERROR: incompatible number of condition in contrast.';
             set(findobj(gcf,'Tag','MessageLine'),'String',msg);
             return;
          end
      catch
          msg = 'ERROR: cannot load the contrast file.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
      end;
else
          PLSoptions.ContrastFile = ContrastMatrix;
          use_contrast = ContrastMatrix;
          cond_selection = getappdata(gcf,'cond_selection');
          behavname = getappdata(gcf,'behavname');

          if size(use_contrast,1) ~= num_groups*sum(cond_selection)*length(behavname)
             msg = 'ERROR: incompatible number of condition in contrast.';
             set(findobj(gcf,'Tag','MessageLine'),'String',msg);
             return;
          end
end

      %  check if the contrast matrix is rank deficient
      %
      if (rank(use_contrast) ~= size(use_contrast,2))
         msg = 'Your Contrast matrix is rank deficient. Please check your contrasts and run the program again';
         uiwait(msgbox(msg,'Warning: Contrasts are not linear independent','modal'));
%         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%         return;	
      end;

      %  check if the contrast matrix is orthogonal
      %
%      if abs(sum(sum(use_contrast'*use_contrast-diag(diag(use_contrast'*use_contrast))))) > 1e-6
      check_orth = abs(triu(use_contrast'*use_contrast) - tril(use_contrast'*use_contrast));
      if max(check_orth(:)) > 1e-4
         msg = 'Effects expressed by each contrast are not independent. Check variable lvintercorrs in result file to see overlap of effects between LVs';
         uiwait(msgbox(msg,'Warning: Contrasts are not orthogonal','modal'));
%         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%         return;	
      end

   elseif (isnonrotatemultiblock == 1)

      PLSoptions.ismultiblock = 0;
      PLSoptions.isnonrotatebehav = 0;
      PLSoptions.isnonrotatemultiblock = 1;
      PLSoptions.ismean = 0;
      PLSoptions.isbehav = 0;
      PLSoptions.iscontrast = 0;
      PLSoptions.posthoc = [];
      PLSoptions.ContrastFile = get(findobj(gcf,'tag','ContrastFileEdit'),'string');
      ContrastMatrix = getappdata(gcf,'ContrastMatrix');

      if isempty(PLSoptions.ContrastFile) & isempty(ContrastMatrix)
          msg = 'ERROR: Contrast file is not specified.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
      end;

if isempty(ContrastMatrix)
      try
          use_contrast = load(PLSoptions.ContrastFile,'conditions');
          cond_selection = getappdata(gcf,'cond_selection');
          behavname = getappdata(gcf,'behavname');

          if size(use_contrast,1) ~= num_groups*sum(cond_selection)*(1+length(behavname))
             msg = 'ERROR: incompatible number of condition in contrast.';
             set(findobj(gcf,'Tag','MessageLine'),'String',msg);
             return;
          end
      catch
          msg = 'ERROR: cannot load the contrast file.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
      end;
else
          PLSoptions.ContrastFile = ContrastMatrix;
          use_contrast = ContrastMatrix;
          cond_selection = getappdata(gcf,'cond_selection');
          behavname = getappdata(gcf,'behavname');

          if size(use_contrast,1) ~= num_groups*sum(cond_selection)*(1+length(behavname))
             msg = 'ERROR: incompatible number of condition in contrast.';
             set(findobj(gcf,'Tag','MessageLine'),'String',msg);
             return;
          end
end

      %  check if the contrast matrix is rank deficient
      %
      if (rank(use_contrast) ~= size(use_contrast,2))
         msg = 'Your Contrast matrix is rank deficient. Please check your contrasts and run the program again';
         uiwait(msgbox(msg,'Warning: Contrasts are not linear independent','modal'));
%         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%         return;	
      end;

      %  check if the contrast matrix is orthogonal
      %
%      if abs(sum(sum(use_contrast'*use_contrast-diag(diag(use_contrast'*use_contrast))))) > 1e-6
      check_orth = abs(triu(use_contrast'*use_contrast) - tril(use_contrast'*use_contrast));
      if max(check_orth(:)) > 1e-4
         msg = 'Effects expressed by each contrast are not independent. Check variable lvintercorrs in result file to see overlap of effects between LVs';
         uiwait(msgbox(msg,'Warning: Contrasts are not orthogonal','modal'));
%         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%         return;	
      end

   elseif (iscontrast == 1)			% contrast

      PLSoptions.ismultiblock = 0;
      PLSoptions.isnonrotatebehav = 0;
      PLSoptions.isnonrotatemultiblock = 0;
      PLSoptions.ismean = 0;
      PLSoptions.isbehav = 0;
      PLSoptions.iscontrast = 1;
      PLSoptions.posthoc = [];
      PLSoptions.ContrastFile = get(findobj(gcf,'tag','ContrastFileEdit'),'string');
      ContrastMatrix = getappdata(gcf,'ContrastMatrix');

      if isempty(PLSoptions.ContrastFile) & isempty(ContrastMatrix)
          msg = 'ERROR: Contrast file is not specified.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
      end;

if isempty(ContrastMatrix)
      try
          use_contrast = load(PLSoptions.ContrastFile,'conditions');
          cond_selection = getappdata(gcf,'cond_selection');

          if size(use_contrast,1) ~= sum(cond_selection)*num_groups
             msg = 'ERROR: incompatible number of condition in contrast.';
             set(findobj(gcf,'Tag','MessageLine'),'String',msg);
             return;
          end
      catch
          msg = 'ERROR: cannot load the contrast file.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
      end;
else
          PLSoptions.ContrastFile = ContrastMatrix;
          use_contrast = ContrastMatrix;
          cond_selection = getappdata(gcf,'cond_selection');

          if size(use_contrast,1) ~= sum(cond_selection)*num_groups
             msg = 'ERROR: incompatible number of condition in contrast.';
             set(findobj(gcf,'Tag','MessageLine'),'String',msg);
             return;
          end
end

      %  check if the contrast matrix is rank deficient
      %
      if (rank(use_contrast) ~= size(use_contrast,2))
         msg = 'Your Contrast matrix is rank deficient. Please check your contrasts and run the program again';
         uiwait(msgbox(msg,'Warning: Contrasts are not linear independent','modal'));
%         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%         return;	
      end;

      %  check if the contrast matrix is orthogonal
      %
%      if abs(sum(sum(use_contrast'*use_contrast-diag(diag(use_contrast'*use_contrast))))) > 1e-6
      check_orth = abs(triu(use_contrast'*use_contrast) - tril(use_contrast'*use_contrast));
      if max(check_orth(:)) > 1e-4
         msg = 'Effects expressed by each contrast are not independent. Check variable lvintercorrs in result file to see overlap of effects between LVs';
         uiwait(msgbox(msg,'Warning: Contrasts are not orthogonal','modal'));
%         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
%         return;	
      end

   else						% deviation

      PLSoptions.ismultiblock = 0;
      PLSoptions.isnonrotatebehav = 0;
      PLSoptions.isnonrotatemultiblock = 0;
      PLSoptions.ismean = 1;
      PLSoptions.isbehav = 0;
      PLSoptions.iscontrast = 0;
      PLSoptions.posthoc = [];
      PLSoptions.ContrastFile = [];

   end

   %  number of permutation
   %
   h = findobj(gcf,'Tag','NumPermutationEdit');
   PLSoptions.num_perm = str2num(get(h,'String'));
   if isempty(PLSoptions.num_perm)
      msg = 'ERROR: Invalid number of permutation specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   %  number of split
   %
   h = findobj(gcf,'Tag','NumSplitEdit');
   PLSoptions.num_split = str2num(get(h,'String'));
   if isempty(PLSoptions.num_split)
      msg = 'ERROR: Invalid number of split specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   %  number of bootstrap
   %
   h = findobj(gcf,'Tag','NumBootstrapEdit');
   PLSoptions.num_boot = str2num(get(h,'String'));
   if isempty(PLSoptions.num_boot)
      msg = 'ERROR: Invalid number of bootstrap specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   %  upper limit of confidence interval estimated
   %
   h = findobj(gcf,'Tag','ClimEdit');
   PLSoptions.Clim = str2num(get(h,'String'));
   if isempty(PLSoptions.Clim)
      msg = 'ERROR: Invalid upper limit of confidence specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

%   if (PLSoptions.num_boot > 0)
%      min_subj_required = 3;
%         for i=1:num_groups,
%           if (length(PLSoptions.profiles{i}) < min_subj_required)
%              msg = 'All groups must have at least 3 subjects for bootstrap.';
%              set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ' msg]);
%              return;
%           end
%         end
%   end;

   % everything should be alright, save the option now
   %
   setappdata(gcf,'PLSoptions',PLSoptions);
   % save PLSoptions PLSoptions;

   status = 1;

   return;						% SavePLSoptions


%----------------------------------------------------------------------------
function total_profiles = ValidateProfiles(group_profiles,conditions),

   num_groups = length(group_profiles);

   cell_buffer = [];
   for i=1:num_groups,
      cell_buffer = [cell_buffer; group_profiles(i)];
   end;

   % check for duplicated profile
   %
   total_profiles = length(cell_buffer);
   for i=1:total_profiles-1,
      for j=i+1:total_profiles,
         if isequal(cell_buffer{i},cell_buffer{j}),
            [p_path, p_name, p_ext] = fileparts(cell_buffer{i});
            msg = sprintf('"%s" has been used for more than 1 group',p_name);
            set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
            total_profiles = -1;
            return;
         else
            set(findobj(gcf,'Tag','MessageLine'),'String','');
         end;
      end;
   end;


   % make sure all conditions are the same
   %
   s = load(cell_buffer{1},'session_info');
   prev_condition = s.session_info.condition;
   prev_select = getappdata(gcf,'cond_selection');
   for i=2:total_profiles,
      s = load(cell_buffer{i},'session_info');
      curr_condition = s.session_info.condition;
      curr_select = getappdata(gcf,'cond_selection');
      if ~isequal(curr_condition,prev_condition)...
	 | ~isequal(curr_select, prev_select)
          [p_path, p_name, p_ext] = fileparts(cell_buffer{i});
          msg = sprintf('Incompatible conditions found in "%s".',p_name);
          set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
          total_profiles = -1;
          return;
      else
          prev_condition = curr_condition;
          prev_select = curr_select;
      end;
   end;

   setappdata(gcf,'num_selected_cond',sum(prev_select));

   ismultiblock = get(findobj(gcf,'Tag','SelectMultiblockData'),'Value');
   isbehav = get(findobj(gcf,'Tag','BehavPLSBn'),'Value');
   isnonrotatebehav = get(findobj(gcf,'Tag','SelectNonRotateBehav'),'Value');
   isnonrotatemultiblock = get(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'Value');

   if ismultiblock | isbehav | isnonrotatebehav | isnonrotatemultiblock

      % make sure all behaviors are the same
      %
      newbehavdata = getappdata(gcf,'behavdata');

      s = load(cell_buffer{1},'behavdata','behavname');

      if isempty(s.behavdata) & isempty(newbehavdata)
           total_profiles = -1;

           msg = 'Behavior data is required';
           set(findobj(gcf,'Tag','MessageLine'),'String',msg);
           return;         
      end

      if(~exist('behavname','var'))
         s.behavname = {};
         for j=1:size(s.behavdata, 2)
            s.behavname = [s.behavname, {['behav', num2str(j)]}];
         end
      end
      
      prev_behavname = s.behavname;
      for i=2:total_profiles,
         s = load(cell_buffer{i},'behavdata','behavname');

         if(~exist('behavname','var'))
            s.behavname = {};
            for j=1:size(s.behavdata, 2)
               s.behavname = [s.behavname, {['behav', num2str(j)]}];
            end
         end

         curr_behavname = s.behavname;
         if ~isequal(curr_behavname,prev_behavname) & isempty(newbehavdata)
             [p_path, p_name, p_ext] = fileparts(cell_buffer{i});
             msg = sprintf('Incompatible behaviors found in "%s".',p_name);
             set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
             total_profiles = -1;
             return;
         else
             prev_behavname = curr_behavname;
         end;
      end;

      if isempty(newbehavdata)  
         setappdata(gcf,'num_selected_behav',size(s.behavdata,2));
      else
         setappdata(gcf,'num_selected_behav',size(newbehavdata,2));
      end

   end

   return;						% ValidateProfiles


%----------------------------------------------------------------------------
function SwitchFullPath()

   h = findobj(gcf,'Tag','FullPathChkbox');
   full_path = get(h,'Value');

   setappdata(gcf,'full_path',full_path);
   DisplayGroupProfiles(full_path);

   return;					% SwitchFullPath


%----------------------------------------------------------------------------
function ExecutePLS()

   tic
   PLSoptions = getappdata(gcf,'PLSoptions');
   progress_hdl = rri_progress_ui('initialize','Loading datamat');

   if exist('plslog.m','file')
      if PLSoptions.ismultiblock
         plslog('STRUCT Multiblock Analysis');
      elseif PLSoptions.isnonrotatebehav
         plslog('STRUCT Non-Rotated Behavior Analysis');
      elseif PLSoptions.isnonrotatemultiblock
         plslog('STRUCT Non-Rotated Multiblock Analysis');
      elseif PLSoptions.isbehav
         plslog('STRUCT Regular Behavior Analysis');
      elseif PLSoptions.iscontrast
         plslog('STRUCT Non-Rotated Task Analysis');
      else
         plslog('STRUCT Mean-Centering Analysis');
      end
   end

   [resultFile] = struct_analysis(PLSoptions.isbehav, ...
	PLSoptions.profiles, PLSoptions.num_perm, ...
	PLSoptions.num_split, PLSoptions.meancentering_type, ...
	PLSoptions.cormode, PLSoptions.boot_type, PLSoptions.nonrotated_boot, ...
	PLSoptions.num_boot, PLSoptions.Clim, PLSoptions.posthoc, ...
	PLSoptions.cond_selection, PLSoptions.behavname, ...
	PLSoptions.behavdata, PLSoptions.behavdata_lst, PLSoptions.ContrastFile, ...
	PLSoptions.iscontrast, PLSoptions.ismean, PLSoptions.save_datamat, ...
	PLSoptions.ismultiblock, PLSoptions.bscan, PLSoptions.isnonrotatebehav, ...
	PLSoptions.isnonrotatemultiblock, PLSoptions.is_struct);

   if exist('progress_hdl','var') & ishandle(progress_hdl)
      close(progress_hdl);
   end

%   msg1 = ['Result file "',resultFile,'" has been created and saved on your hard drive.'];
 %  msg2 = ['The total elapse time to build this datamat is ',num2str(elapsed_time),' seconds.'];

   if 0 % ~isempty(resultFile)
      uiwait(msgbox({msg1;'';msg2},'Completed','modal'));
%      uiwait(msgbox(msg1,'Completed','modal'));
   end

   uiresume;
   return;						% ExecutePLS


%----------------------------------------------------------------------------
function EditPosthocDataFile

   posthoc_data_file = deblank(strjust(get(gcbo,'String'),'left'));

   set(gcbo,'String',posthoc_data_file);

   if ~isempty(posthoc_data_file)
      if ( exist(posthoc_data_file,'file') == 2 )		% specified file exists
         setappdata(gcf,'posthoc_data_file',posthoc_data_file);
         return;
      end;

      if ( exist(posthoc_data_file,'dir') == 7 )		% it is a directory!
         msg = 'ERROR: The specified file is a direcotry!';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         setappdata(gcf,'posthoc_data_file','');
         return;
      end;
   else
%      msg = 'ERROR: Invalid input file!';
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'posthoc_data_file','');
      return;
   end;

   return;						% EditPosthocDataFile


%----------------------------------------------------------------------------
function SelectPosthocDataFile

   h = findobj(gcf,'Tag','PosthocDataEdit');

   [filename,pathname]=rri_selectfile('*.*','Select Posthoc Data File');

   if isequal(filename,0) | isequal(pathname,0)
      return;
   end;

   posthoc_data_file = [pathname, filename];

   set(h,'String',posthoc_data_file);
   set(h,'TooltipString',posthoc_data_file);
   setappdata(gcf,'posthoc_data_file',posthoc_data_file);

   return;						% SelectPosthocDataFile


%----------------------------------------------------------------------------
function deselect_condition

   curr_profiles = getappdata(gcf,'CurrGroupProfiles');

   if isempty(curr_profiles)
      msg = 'Group need to be added before you can deselect condition';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   tmp = load(curr_profiles{1});
   condition = tmp.session_info.condition;
   cond_selection = getappdata(gcf,'cond_selection');
   new_cond_selection = rri_deselect_cond_ui(condition, cond_selection);

   if ~isequal(new_cond_selection, cond_selection)
      setappdata(gcf,'cond_selection',new_cond_selection);
      setappdata(gcf,'behavname',{});
      setappdata(gcf,'behavdata',[]);
      setappdata(gcf,'behavdata_lst',{});
      setappdata(gcf, 'bscan', []);
   end

   return;						% deselect_condition


%----------------------------------------------------------------------------
function modify_behavdata

   curr_profiles = getappdata(gcf,'CurrGroupProfiles');

   if isempty(curr_profiles)
      msg = 'Group need to be added before you can modify behavior data';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   cond_selection = getappdata(gcf,'cond_selection');
   behavname = getappdata(gcf,'behavname');
   behavdata = getappdata(gcf,'behavdata');
   behavdata_lst = getappdata(gcf,'behavdata_lst');
   new_evt_list = getappdata(gcf,'new_evt_list');
   newdata_lst = getappdata(gcf,'newdata_lst');

   if isempty(behavdata) | isempty(new_evt_list)
      [status,behavname,behavdata,behavdata_lst,new_evt_list,newdata_lst] = ...
		struct_get_behavior(curr_profiles, cond_selection);

      behavdata2 = getappdata(gcf,'behavdata');

      if ~isempty(behavdata2)
         behavname = getappdata(gcf,'behavname');
         behavdata = getappdata(gcf,'behavdata');
         behavdata_lst = getappdata(gcf,'behavdata_lst');
      end
   else
      status = 1;
   end

   if status == 0
      msg = 'Condition or behavior incompatible in datamat file.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   else
      nr = length(new_evt_list);
      [new_behavdata, new_behavname] = rri_edit_behav(num2str(behavdata), ...
		behavname, 'Edit Behavior Data');
      new_behavdata = str2num(new_behavdata);

      while ~isempty(new_behavdata) & size(new_behavdata, 1) ~= nr
         if size(new_behavdata, 1) ~= nr
            msg1 = ['Number of rows should be equal to ' num2str(nr)];
            msg2 = '. For Multiblock PLS analysis, please also fill';
            msg3 = ' any values for subjects of those conditions that';
            msg4 = ' will be deselected in the behavior block';
            msg = [msg1 msg2 msg3 msg4];
            % set(findobj(gcf,'Tag','MessageLine'),'String',msg);
            uiwait(msgbox(msg, 'Error'));
         end

         [new_behavdata, new_behavname] = rri_edit_behav(num2str(behavdata), ...
		behavname, 'Edit Behavior Data');
         new_behavdata = str2num(new_behavdata);
      end

      if isempty(new_behavdata)
         msg = ['Behavior Data is not set'];
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      elseif ~isequal(new_behavdata, behavdata) | ...
		~isequal(new_behavname, behavname)
         behavname = new_behavname;
         behavdata = new_behavdata;
         behavdata_lst = {};

         for i = 1:length(newdata_lst)
            mask = [];

            for j = 1:length(newdata_lst)
               if j == i
                  mask = [mask;ones(length(newdata_lst{j}),1)];
               else
                  mask = [mask;zeros(length(newdata_lst{j}),1)];
               end
            end

            behavdata_lst{i} = behavdata(find(mask),:);
         end
      end
   end

   setappdata(gcf,'behavname',behavname);
   setappdata(gcf,'behavdata',behavdata);
   setappdata(gcf,'behavdata_lst',behavdata_lst);
   setappdata(gcf,'new_evt_list',new_evt_list);
   setappdata(gcf,'newdata_lst',newdata_lst);

   return;						% modify_behavdata


%----------------------------------------------------------------------------
function multiblock_deselect_condition

   curr_profiles = getappdata(gcf,'CurrGroupProfiles');

   if isempty(curr_profiles)
      msg = 'Group need to be added before you can deselect condition';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   tmp = load(curr_profiles{1});
   cond_selection = getappdata(gcf,'cond_selection');

   bscan = getappdata(gcf,'bscan');
   if isempty(bscan)
      multiblock_cond_selection = ones(1, sum(cond_selection));
   else
      multiblock_cond_selection = zeros(1, sum(cond_selection));
      multiblock_cond_selection(bscan) = 1;
   end

   condition = tmp.session_info.condition;
   condition = condition(find(cond_selection));

   new_cond_selection = rri_deselect_cond_ui(condition, multiblock_cond_selection);
   new_bscan = find(new_cond_selection);

   if ~isequal(new_bscan, bscan)
      setappdata(gcf, 'bscan', new_bscan);
   end

   return;						% multiblock_deselect_condition


%----------------------------------------------------------------------------
function status = cExecutePLS()

   status = 0;

   PLSoptions = getappdata(gcf,'PLSoptions');

   if exist('plslog.m','file')
      if PLSoptions.ismultiblock
         plslog('cSTRUCT Multiblock Analysis');
      elseif PLSoptions.isnonrotatebehav
         plslog('cSTRUCT Non-Rotated Behavior Analysis');
      elseif PLSoptions.isnonrotatemultiblock
         plslog('cSTRUCT Non-Rotated Multiblock Analysis');
      elseif PLSoptions.isbehav
         plslog('cSTRUCT Regular Behavior Analysis');
      elseif PLSoptions.iscontrast
         plslog('cSTRUCT Non-Rotated Task Analysis');
      else
         plslog('cSTRUCT Mean-Centering Analysis');
      end
   end

   if PLSoptions.ismultiblock
      method = 4;			% Multiblock PLS
      ContrastFile = 'MULTIBLOCK';
   elseif PLSoptions.isnonrotatebehav
      method = 5;			% Non-Rotated Behav PLS
      ContrastFile = PLSoptions.ContrastFile;
   elseif PLSoptions.isnonrotatemultiblock
      method = 6;			% Non-Rotated Multiblock PLS
      ContrastFile = PLSoptions.ContrastFile;
   elseif PLSoptions.isbehav
      method = 3;			% Behavior PLS
      ContrastFile = 'BEHAV';
   elseif PLSoptions.iscontrast
      method = 2;			% Non-Rotated Task PLS
      ContrastFile = PLSoptions.ContrastFile;
   else
      method = 1;			% Mean-Centering Task PLS
      ContrastFile = 'NONE';
   end

   datamat_files = PLSoptions.profiles;
   num_perm = PLSoptions.num_perm;
   num_boot = PLSoptions.num_boot;
   Clim = PLSoptions.Clim;
   is_struct = PLSoptions.is_struct;
   save_datamat = PLSoptions.save_datamat;

   num_split = PLSoptions.num_split;
   mean_type = PLSoptions.meancentering_type;
   cormode = PLSoptions.cormode;
   boot_type = PLSoptions.boot_type;
   nonrotated_boot = PLSoptions.nonrotated_boot;

   cond_selection = PLSoptions.cond_selection;
   behavname = PLSoptions.behavname;
   behavdata = PLSoptions.behavdata;
   bscan = PLSoptions.bscan;

   %  save results
   %
   fn = datamat_files{1};
   load(fn,'session_info');
   datamat_prefix = session_info.datamat_prefix;

   [result_file,result_path] = ...
      rri_selectfile([datamat_prefix,'_STRUCTresult.mat'],'Please enter a result file name that will be used by the created batch file');

   if isequal(result_file,0)			% Cancel was clicked
      return;
   else
      resultFile = result_file;
   end;

   %  save batch input file
   %
   [input_file,input_path] = ...
      rri_selectfile([datamat_prefix,'_STRUCTanalysis.txt'],'Please enter a batch file name that will be used by "batch_plsgui"');

   if isequal(input_file,0)			% Cancel was clicked
      return;
   else
      inputFile = input_file;
   end;

   v7 = version;
   if str2num(v7(1))<7
      singleanalysis = 0;
   else
      singleanalysis = 1;
   end

 if str2num(v7(1:3))<7.4 & strcmp(v7(4),'.')
   pc = computer;
   if singleanalysis & ( strcmp(pc,'GLNXA64') | strcmp(pc,'GLNXI64') | strcmp(pc,'PCWIN64') )
         singleanalysis = 0;
   end
 end

   fid = fopen(inputFile, 'wt');

   fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  Result File Name Start  %');
   fprintf(fid, '\t%s\n\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '%s\n', '%  Note: Result file must be listed first, and must follow the file');
   fprintf(fid, '%s\n', '%	 name format of xxxx_yyyyresult.mat, where xxxx stands for');
   fprintf(fid, '%s\n', '%	 "any result file name prefix" and yyyy stands for the name');
   fprintf(fid, '%s\n', '%	 of PLS module (either PET ERP fMRI BfMRI STRUCT or SmallFC).');
   fprintf(fid, '%s\n\n', '%	 File name is case sensitive on Unix or Linux computers.');

   fprintf(fid, 'result_file\t%s\n\n', resultFile);

   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  Result File Name End  %');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  Group Section Start  %');
   fprintf(fid, '\t%s\n\n', '%%%%%%%%%%%%%%%%%%%%%%%%%');

   for i=1:length(datamat_files)
      fprintf(fid, 'group_files\t');

      [tmp datamat_file]=rri_fileparts(datamat_files{i});
      fprintf(fid, '%s ', datamat_file);
      fprintf(fid, '\n');
   end

   fprintf(fid, '\n%s\n\n', '% ... following above pattern for more groups');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  Group Section End  %');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  PLS Section Start  %');
   fprintf(fid, '\t%s\n\n', '%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '%s\n', '%  Notes:');
   fprintf(fid, '%s\n', '%    1. Mean-Centering PLS');
   fprintf(fid, '%s\n', '%    2. Non-Rotated Task PLS (please also fill out contrast data below)');
   fprintf(fid, '%s\n', '%    3. Regular Behav PLS (please also fill out behavior data & name below)');
   fprintf(fid, '%s\n', '%    4. Multiblock PLS (please also fill out behavior data & name below)');
   fprintf(fid, '%s\n', '%    5. Non-Rotated Behav PLS (please also fill out contrast data and');
   fprintf(fid, '%s\t%s\n', '%', 'behavior data & name below)');
   fprintf(fid, '%s\n', '%    6. Non-Rotated Multiblock PLS (please also fill out contrast data and');
   fprintf(fid, '%s\t%s\n\n', '%', 'behavior data & name below)');

   fprintf(fid, 'pls\t\t%d\t\t%s\n\n', method, '% PLS Option (between 1 to 6, see above notes)');

   fprintf(fid, '%s\n', '%  Mean-Centering Type:');
   fprintf(fid, '%s\n', '%    0. Remove group condition means from conditon means within each group');
   fprintf(fid, '%s\n', '%    1. Remove grand condition means from each group condition mean');
   fprintf(fid, '%s\n', '%    2. Remove grand mean over all subjects and conditions');
   fprintf(fid, '%s\n\n', '%    3. Remove all main effects by subtracting condition and group means');

   fprintf(fid, 'mean_type\t%d\t\t%s\n\n', mean_type, '% Mean-Centering Type (between 0 to 3, see above)');

   fprintf(fid, '%s\n', '%  Correlation Mode:');
   fprintf(fid, '%s\n', '%    0. Pearson correlation');
   fprintf(fid, '%s\n', '%    2. covaraince');
   fprintf(fid, '%s\n', '%    4. cosine angle');
   fprintf(fid, '%s\n\n', '%    6. dot product');

   fprintf(fid, 'cormode\t\t%d\t\t%s\n\n', cormode, '% Correlation Mode (can be 0,2,4,6, see above)');

   fprintf(fid, 'num_perm\t%d\t\t%s\n', num_perm, '% Number of Permutation');
   fprintf(fid, 'num_split\t%d\t\t%s\n', num_split, '% Natasha Perm Split Half');
   fprintf(fid, 'num_boot\t%d\t\t%s\n', num_boot, '% Number of Bootstrap');
   fprintf(fid, 'boot_type\t%s\t\t%s\n', boot_type, '% Either strat or nonstrat bootstrap type');
%   fprintf(fid, 'nonrotated_boot\t%d\t\t%s\n', nonrotated_boot, '% Set to 1 if not using procrust rotation');
   fprintf(fid, 'clim\t\t%d\t\t%s\n', Clim, '% Confidence Level for Behavior PLS');
   fprintf(fid, 'is_struct\t%d\t\t%s\n', is_struct, '% Set to 0 if not use segmented data');
   fprintf(fid, 'save_data\t%d\t\t%s\n\n', save_datamat, '% Set to 1 to save stacked datamat');

   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  PLS Section End  %');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  Condition Selection Start  %');
   fprintf(fid, '\t%s\n\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

   fprintf(fid, '%s\n', '%  Notes: If you don''t need to deselect conditions, just leave');
   fprintf(fid, '%s\n\n', '%  "selected_cond" and "selected_bcond" to be commented.');
   fprintf(fid, '%s\n', '%  First put k number of 1 after "selected_cond" keyword, where k is the');
   fprintf(fid, '%s\n', '%  number of conditions in sessiondata file. Then, replace with 0 for');
   fprintf(fid, '%s\n', '%  those conditions that you would like to deselect for any case except');
   fprintf(fid, '%s\n', '%  behavior block of multiblock PLS. e.g. If you have 3 conditions in');
   fprintf(fid, '%s\n', '%  sessiondata file, and you would like to deselect the 2nd condition,');
   fprintf(fid, '%s\n', '%  then you should enter 1 0 1 after selected_cond.');
   fprintf(fid, '%s\n', '%');

   fprintf(fid, 'selected_cond\t');
   for i=1:length(cond_selection)
      fprintf(fid, '%d ', cond_selection(i));
   end;
   fprintf(fid, '\n\n');

   if method == 4 | method == 6
      bscan_id = zeros(size(cond_selection));
      cond_selection_id = find(cond_selection);
      bscan_id(cond_selection_id(bscan)) = 1;

      fprintf(fid, '%s\n', '%  First put k number of 1 after "selected_bcond" keyword, where k is the');
      fprintf(fid, '%s\n', '%  number of conditions in sessiondata file. Then, replace with 0 for');
      fprintf(fid, '%s\n', '%  those conditions that you would like to deselect only for behavior');
      fprintf(fid, '%s\n', '%  block of multiblock PLS. e.g. If you have 3 conditions in');
      fprintf(fid, '%s\n', '%  sessiondata file, and you would like to deselect the 2nd condition,');
      fprintf(fid, '%s\n', '%  then you should enter 1 0 1 after selected_cond. you can not select');
      fprintf(fid, '%s\n', '%  any conditions for "selected_bcond" that were deselected in');
      fprintf(fid, '%s\n', '%  "selected_cond". e.g. in the above comments, you can not select the');
      fprintf(fid, '%s\n', '%  2nd condition for "selected_bcond" because it was already deselected');
      fprintf(fid, '%s\n', '%  in "selected_cond".');
      fprintf(fid, '%s\n', '%');

      fprintf(fid, 'selected_bcond\t');
      for i=1:length(bscan_id)
         fprintf(fid, '%d ', bscan_id(i));
      end;
      fprintf(fid, '\n\n');
   end;

   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\t%s\n', '%  Condition Selection End  %');
   fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
   fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');


   if method == 2 | method == 5 | method == 6

      fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '\t%s\n', '%  Contrast Data Start  %');
      fprintf(fid, '\t%s\n\n', '%%%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '%s\n\n', '%  Notes: only list selected conditions (selected_cond)');

      contrast = getappdata(gcf, 'ContrastMatrix');

      for i=1:size(contrast,1)
         fprintf(fid, 'contrast_data\t');

         for j=1:size(contrast,2)
            fprintf(fid, '%.15f ', contrast(i,j));
         end

         fprintf(fid, '\n');
      end

      fprintf(fid, '\n%s\n\n', '% ... following above pattern for more groups');
      fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '\t%s\n', '%  Contrast Data End  %');
      fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');

   end;


   if method == 3 | method == 4 | method == 5 | method == 6

      fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '\t%s\n', '%  Behavior Data Start  %');
      fprintf(fid, '\t%s\n\n', '%%%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '%s\n\n', '%  Notes: only list selected conditions (selected_cond)');

      for i=1:size(behavdata,1)
         fprintf(fid, 'behavior_data\t');

         for j=1:size(behavdata,2)
            fprintf(fid, '%.15f ', behavdata(i,j));
         end

         fprintf(fid, '\n');
      end

      fprintf(fid, '\n%s\n\n', '% ... following above pattern for more groups');
      fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '\t%s\n', '%  Behavior Data End  %');
      fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');
      fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '\t%s\n', '%  Behavior Name Start  %');
      fprintf(fid, '\t%s\n\n', '%%%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '%s\n\n', '%  Numbers of Behavior Name should match the Behavior Data above');

      fprintf(fid, 'behavior_name\t');

      for j=1:size(behavname,2)
         fprintf(fid, '%s ', behavname{j});
      end

      fprintf(fid, '\n\n\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '\t%s\n', '%  Behavior Name End  %');
      fprintf(fid, '\t%s\n', '%%%%%%%%%%%%%%%%%%%%%%%');
      fprintf(fid, '\n%s\n\n', '%------------------------------------------------------------------------');

   end;

   fclose(fid);
   status = 1;

   return;						% cExecutePLS


%----------------------------------------------------------------------------
function SelectNonRotatedBehavPLS

   if get(findobj(gcf,'Tag','SelectNonRotateBehav'),'Value') == 0		% click itself
      set(findobj(gcf,'Tag','SelectNonRotateBehav'),'Value',1);
   else
      set(findobj(gcf,'Tag','TaskPLSBn'),'Value',0);
      set(findobj(gcf,'Tag','BehavPLSBn'),'Value',0);
      set(findobj(gcf,'Tag','SelectMultiblockData'),'Value',0);
      set(findobj(gcf,'Tag','SelectContrastData'),'Value',0);
      set(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'Value',0);

      set(findobj(gcf,'Tag','ContrastFileEdit'),'BackGroundColor',[1 1 1]);
      set(findobj(gcf,'Tag','ContrastDataLabel'),'Enable','on');
      set(findobj(gcf,'Tag','ContrastFileEdit'),'Enable','on');
      set(findobj(gcf,'Tag','CreateContrastsMenu'),'Enable','on');

      set(findobj(gcf,'Tag','PosthocDataEdit'),'BackGroundColor',[1 1 1]);
      set(findobj(gcf,'Tag','ModifyBehavdataMenu'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataLabel'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataEdit'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataBn'),'Enable','on');

      set(findobj(gcf,'Tag','MeanCenteringTypeLabel'),'Enable','off');
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'Enable','off','value',1);
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'background',[0.9 0.9 0.9]);

      set(findobj(gcf,'Tag','CorModeLabel'),'Enable','on');
      set(findobj(gcf,'Tag','CorModeMenu'),'Enable','on');
      set(findobj(gcf,'Tag','CorModeMenu'),'background',[1 1 1]);

      num_boot = str2num(get(findobj(gcf,'Tag','NumBootstrapEdit'),'String'));
      if  ~isempty(num_boot) & num_boot ~= 0
         set(findobj(gcf,'Tag','ClimEdit'),'BackGroundColor',[1 1 1]);
         set(findobj(gcf,'Tag','ClimLabel'),'Enable','on');
         set(findobj(gcf,'Tag','ClimEdit'),'Enable','on');
      end

      set(findobj(gcf,'Tag','MultiblockDeselectConditionMenu'),'Enable','off');
   end

   return;						% SelectNonRotatedBehavPLS


%----------------------------------------------------------------------------
function SelectNonRotatedMultiblock

   if get(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'Value') == 0	% click itself
      set(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'Value',1);
   else
      set(findobj(gcf,'Tag','TaskPLSBn'),'Value',0);
      set(findobj(gcf,'Tag','BehavPLSBn'),'Value',0);
      set(findobj(gcf,'Tag','SelectContrastData'),'Value',0);
      set(findobj(gcf,'Tag','SelectMultiblockData'),'Value',0);
      set(findobj(gcf,'Tag','SelectNonRotateBehav'),'Value',0);

      set(findobj(gcf,'Tag','PosthocDataEdit'),'BackGroundColor',[1 1 1]);
      set(findobj(gcf,'Tag','ModifyBehavdataMenu'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataLabel'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataEdit'),'Enable','on');
      set(findobj(gcf,'Tag','PosthocDataBn'),'Enable','on');

      set(findobj(gcf,'Tag','ContrastFileEdit'),'BackGroundColor',[1 1 1]);
      set(findobj(gcf,'Tag','ContrastDataLabel'),'Enable','on');
      set(findobj(gcf,'Tag','ContrastFileEdit'),'Enable','on');
      set(findobj(gcf,'Tag','CreateContrastsMenu'),'Enable','on');

      set(findobj(gcf,'Tag','MeanCenteringTypeLabel'),'Enable','on');
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'Enable','on');
      set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'background',[1 1 1]);

      set(findobj(gcf,'Tag','CorModeLabel'),'Enable','on');
      set(findobj(gcf,'Tag','CorModeMenu'),'Enable','on');
      set(findobj(gcf,'Tag','CorModeMenu'),'background',[1 1 1]);

      num_boot = str2num(get(findobj(gcf,'Tag','NumBootstrapEdit'),'String'));
      if  ~isempty(num_boot) & num_boot ~= 0
         set(findobj(gcf,'Tag','ClimEdit'),'BackGroundColor',[1 1 1]);
         set(findobj(gcf,'Tag','ClimLabel'),'Enable','on');
         set(findobj(gcf,'Tag','ClimEdit'),'Enable','on');
      end

      set(findobj(gcf,'Tag','MultiblockDeselectConditionMenu'),'Enable','on');
   end

   return;						% SelectNonRotatedMultiblock


%----------------------------------------------------------------------------
function status = LoadBatch()

   set(findobj(gcf,'Tag','LOADBATCHButton'),'Enable','off');

   [f p]=rri_selectfile;
   if p==0, return; end;
   fname=fullfile(p,f);
   fid=fopen(fname);
   tmp=fgetl(fid);

   if ischar(tmp) & ~isempty(tmp)
      tmp = strrep(tmp, char(9), ' ');
      tmp = deblank(fliplr(deblank(fliplr(tmp))));
   end

   while ~feof(fid) & (isempty(tmp) | isnumeric(tmp) | strcmpi(tmp(1), '%'))
      tmp = fgetl(fid);

      if ischar(tmp) & ~isempty(tmp)
         tmp = strrep(tmp, char(9), ' ');
         tmp = deblank(fliplr(deblank(fliplr(tmp))));
      end
   end

   fseek(fid, 0, 'bof');

   if ischar(tmp) & ~isempty(tmp)
      tok = strtok(tmp);
   else
      tok = '';
   end

   if ~strcmpi(tok, 'result_file')
      error('This is not the batch script file to run PLS analysis.');
   end

   batch_pls_analysis2(fid);

   return;						% LoadBatch


%----------------------------------------------------------------------------
function batch_pls_analysis2(fid)

   result_file = '';
   group_files = {};
   pls = 1;

   num_perm = 0;
   num_boot = 0;
   clim = 95;
   save_data = 0;
   has_unequal_subj = 0;
   intel_system = 1;
   is_struct = 1;

   num_split = 0;
   mean_type = 0;
   cormode = 0;
   boot_type = 'strat';
   nonrotated_boot = 0;

   contrasts = [];
   behavdata = [];
   behavname = {};
   selected_cond = [];
   selected_bcond = [];
   bscan = [];

   wrongbatch = 0;

   while ~feof(fid)

      tmp = fgetl(fid);

      if ischar(tmp) & ~isempty(tmp)
         tmp = strrep(tmp, char(9), ' ');
         tmp = deblank(fliplr(deblank(fliplr(tmp))));
      end

      while ~feof(fid) & (isempty(tmp) | isnumeric(tmp) | strcmpi(tmp(1), '%'))
         tmp = fgetl(fid);

         if ischar(tmp) & ~isempty(tmp)
            tmp = strrep(tmp, char(9), ' ');
            tmp = deblank(fliplr(deblank(fliplr(tmp))));
         end
      end

      if ischar(tmp) & ~isempty(tmp)
         [tok rem] = strtok(tmp);

         if ~isempty(rem)
            [rem junk] = strtok(rem, '%');
            rem = deblank(fliplr(deblank(fliplr(rem))));
         end
      else
         tok = '';
      end

      switch tok
      case 'result_file'
         result_file = rem;
         if isempty(rem), wrongbatch = 1; end;
      case 'group_files'
         this_group = {};

         while ~isempty(rem)
            [tmp rem] = strtok(rem);
            this_group = [this_group; {tmp}];
         end

         if isempty(this_group), wrongbatch = 1; end;
         group_files = [group_files {this_group}];
      case 'pls'
         pls = str2num(rem);
         if isempty(pls), pls = 1; end;
      case 'num_perm'
         num_perm = str2num(rem);
         if isempty(num_perm), num_perm = 0; end;
      case 'num_boot'
         num_boot = str2num(rem);
         if isempty(num_boot), num_boot = 0; end;
      case 'clim'
         clim = str2num(rem);
         if isempty(clim), clim = 95; end;

      case 'num_split'
         num_split = str2num(rem);
         if isempty(num_split), num_split = 0; end;
      case 'mean_type'
         mean_type = str2num(rem);
         if isempty(mean_type), mean_type = 0; end;
      case 'cormode'
         cormode = str2num(rem);
         if isempty(cormode), cormode = 0; end;
      case 'boot_type'
         boot_type = rem;
         if isempty(cormode), cormode = 'strat'; end;
      case 'nonrotated_boot'
         nonrotated_boot = str2num(rem);
         if isempty(nonrotated_boot), nonrotated_boot = 0; end;

      case 'save_data'
         save_data = str2num(rem);
         if isempty(save_data), save_data = 0; end;
      case 'intel_system'
         intel_system = str2num(rem);
         if isempty(intel_system), intel_system = 1; end;
      case 'is_struct'
         is_struct = str2num(rem);
         if isempty(is_struct), is_struct = 1; end;
      case 'selected_cond'
         selected_cond = str2num(rem);
      case 'selected_bcond'
         selected_bcond = str2num(rem);
      case 'contrast_data'
         this_row = [];

         while ~isempty(rem)
            [tmp rem] = strtok(rem);
            this_row = [this_row str2num(tmp)];
         end

         if isempty(this_row)
            wrongbatch = 1;
            break;
         end

         if ~isempty(contrasts) & size(contrasts,2) ~= length(this_row)
            wrongbatch = 1;
            break;
         end

         contrasts = [contrasts; this_row];
      case 'behavior_data'
         this_row = [];

         while ~isempty(rem)
            [tmp rem] = strtok(rem);
            this_row = [this_row str2num(tmp)];
         end

         if isempty(this_row)
            wrongbatch = 1;
            break;
         end

         if ~isempty(behavdata) & size(behavdata,2) ~= length(this_row)
            wrongbatch = 1;
            break;
         end

         behavdata = [behavdata; this_row];
      case 'behavior_name'
         while ~isempty(rem)
            [tmp rem] = strtok(rem);
            behavname = [behavname {tmp}];
         end
      end
   end

   fclose(fid);

   if wrongbatch
      error('There is error(s) in batch file, please read ''UserGuide.htm'' for help');
   end

%   progress_hdl = rri_progress_status('create','PLS Analysis');
   first_file = group_files{1}{1};
   load(first_file, 'session_info');

   if isempty(selected_cond) | sum(selected_cond) == 0 | ...
	( length(selected_cond) ~= session_info.num_conditions & ...
          isempty(findstr(first_file, '_STRUCTsessiondata.mat')) )
      selected_cond = ones(1, session_info.num_conditions);
   end

   if isempty(selected_bcond) | sum(selected_bcond) == 0 | ...
	( length(selected_bcond) ~= session_info.num_conditions & ...
          isempty(findstr(first_file, '_STRUCTsessiondata.mat')) )
      selected_bcond = ones(1, length(selected_cond));
   end

   selected_bcond = selected_bcond .* selected_cond;

   if sum(selected_bcond) == 0
      selected_bcond = selected_cond;
   end

   bscan = find(selected_bcond(find(selected_cond)));

%   if isempty(bscan) | length(bscan) > sum(selected_cond) ...
%	| max(bscan) > sum(selected_cond)
%      bscan = 1:sum(selected_cond);
%   end

   if ~isempty(findstr(first_file, '_STRUCTsessiondata.mat'))	% STRUCT

      PLSoptions.profiles = [group_files{:}];
      PLSoptions.meancentering_type = mean_type;
      PLSoptions.cormode = cormode;
      PLSoptions.boot_type = boot_type;
      PLSoptions.nonrotated_boot = nonrotated_boot;

      PLSoptions.num_perm = num_perm;
      PLSoptions.num_split = num_split;
      PLSoptions.num_boot = num_boot;
      PLSoptions.posthoc = [];
      PLSoptions.Clim = clim;
      PLSoptions.save_datamat = save_data;
      PLSoptions.cond_selection = selected_cond;

      PLSoptions.behavname = {};
      PLSoptions.behavdata = [];
      PLSoptions.behavdata_lst = {};
      PLSoptions.bscan = bscan;

      PLSoptions.output_file = result_file;
      PLSoptions.intel_system = intel_system;
      PLSoptions.is_struct = is_struct;

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      for g=1:length(PLSoptions.profiles)
         curr_group_profiles = getappdata(gcf,'CurrGroupProfiles');
         num_group = length(curr_group_profiles)+1;

         rows = getappdata(gcf,'NumRows');
         a_hdls = getappdata(gcf,'AddRowHdls');

         group_id = get(a_hdls(1),'String');
         start_idx = findstr(group_id,'#')+1;
         group_idx = str2num(group_id(start_idx:end-1));

         group_profile = get(a_hdls(2),'String');

         curr = pwd;
         if isempty(curr)
            curr = filesep;
         end

         pf_path = curr;
         pf_name = PLSoptions.profiles{g};

         curr_group_profiles{num_group} = fullfile(pf_path, pf_name);

         if isempty(getappdata(gcf,'cond_selection'))
            tmp = load(curr_group_profiles{1});
            cond_selection = ones(1, tmp.session_info.num_conditions);
            setappdata(gcf, 'cond_selection', cond_selection);
         end

         setappdata(gcf,'behavname',{});
         setappdata(gcf,'behavdata',[]);
         setappdata(gcf,'behavdata_lst',{});

         setappdata(gcf,'CurrGroupProfiles',curr_group_profiles);
         set(findobj(gcf,'Tag','NumberGroupEdit'),'String',num2str(num_group));

         new_group_row = get(a_hdls(1),'UserData');
         if (new_group_row == rows),  	% the new group row is the last row
            top_group_idx = getappdata(gcf,'TopGroupIdx');
            setappdata(gcf,'TopGroupIdx',top_group_idx+1);
         end;

         group_hdls = getappdata(gcf,'Group_hlist');

         full_path = getappdata(gcf,'full_path');
         DisplayGroupProfiles(full_path);

         UpdateSlider;
      end

      set(findobj(gcf,'Tag','SaveDatamatChkbox'),'Value', PLSoptions.save_datamat);
      setappdata(gcf, 'cond_selection', PLSoptions.cond_selection);

      set(findobj(gcf,'Tag','UseSegmentData'),'Value', PLSoptions.is_struct);

      switch pls
      case 1
         set(findobj(gcf,'Tag','TaskPLSBn'),'Value',1);
	SelectTaskPLS;
      case 2
         set(findobj(gcf,'Tag','SelectContrastData'),'Value',1);
        SelectContrastData;
         setappdata(gcf, 'ContrastMatrix', contrasts);
      case 3
         set(findobj(gcf,'Tag','BehavPLSBn'),'Value',1);
	SelectBehavPLS;

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end

         setappdata(gcf,'behavname',PLSoptions.behavname);
         setappdata(gcf,'behavdata',PLSoptions.behavdata);
         setappdata(gcf,'behavdata_lst',PLSoptions.behavdata_lst);
      case 4
         set(findobj(gcf,'Tag','SelectMultiblockData'),'Value',1);
	SelectMultiblockData;

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end

         setappdata(gcf,'behavname',PLSoptions.behavname);
         setappdata(gcf,'behavdata',PLSoptions.behavdata);
         setappdata(gcf,'behavdata_lst',PLSoptions.behavdata_lst);
         setappdata(gcf, 'bscan', PLSoptions.bscan);
      case 5
         set(findobj(gcf,'Tag','SelectNonRotateBehav'),'Value',1);
	SelectNonRotatedBehavPLS;

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;

         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end

         setappdata(gcf,'behavname',PLSoptions.behavname);
         setappdata(gcf,'behavdata',PLSoptions.behavdata);
         setappdata(gcf,'behavdata_lst',PLSoptions.behavdata_lst);
         setappdata(gcf, 'ContrastMatrix', contrasts);
      case 6
         set(findobj(gcf,'Tag','SelectNonRotateMultiblock'),'Value',1);
	SelectNonRotatedMultiblock;

         PLSoptions.behavdata = behavdata;
         PLSoptions.behavname = behavname;

         last = 0;
         for g = 1:length(group_files)
            load(PLSoptions.profiles{g}, 'session_info');
            bidx = last + [1: sum(selected_cond)*session_info.num_subjects];
            last = last + length(bidx);
            PLSoptions.behavdata_lst{g} = behavdata(bidx, :);
         end

         setappdata(gcf,'behavname',PLSoptions.behavname);
         setappdata(gcf,'behavdata',PLSoptions.behavdata);
         setappdata(gcf,'behavdata_lst',PLSoptions.behavdata_lst);
         setappdata(gcf, 'bscan', PLSoptions.bscan);
         setappdata(gcf, 'ContrastMatrix', contrasts);

%         PLSoptions.BehavDataCol = size(PLSoptions.behavdata, 2);
      end

      if ismember(pls,[1 2 4 6])
         set(findobj(gcf,'Tag','MeanCenteringTypeLabel'),'Enable','on');
         set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'Enable','on');
         set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'background',[1 1 1]);
         set(findobj(gcf,'Tag','MeanCenteringTypeMenu'),'Value',PLSoptions.meancentering_type+1);
      end

      if ismember(pls,[3 4 5 6])
         set(findobj(gcf,'Tag','CorModeLabel'),'Enable','on');
         set(findobj(gcf,'Tag','CorModeMenu'),'Enable','on');
         set(findobj(gcf,'Tag','CorModeMenu'),'background',[1 1 1]);
         CorModeValue = [1 0 2 0 3 0 4];
         set(findobj(gcf,'Tag','CorModeMenu'),'Value',CorModeValue(PLSoptions.cormode+1));
      end

      if isfield(PLSoptions,'num_perm') & ~isempty(PLSoptions.num_perm) & PLSoptions.num_perm ~= 0
         set(findobj(gcf,'Tag','NumPermutationEdit'),'String',num2str(PLSoptions.num_perm));

         set(findobj(gcf,'Tag','NumSplitLabel'),'Enable','on');
         set(findobj(gcf,'Tag','NumSplitEdit'),'Enable','on');
         set(findobj(gcf,'Tag','NumSplitEdit'),'BackGroundColor',[1 1 1]);
      end

      if isfield(PLSoptions,'num_split') & ~isempty(PLSoptions.num_split) & PLSoptions.num_split ~= 0
         set(findobj(gcf,'Tag','NumSplitEdit'),'String',num2str(PLSoptions.num_split));
      end

      if isfield(PLSoptions,'num_boot') & ~isempty(PLSoptions.num_boot) & PLSoptions.num_boot ~= 0
         set(findobj(gcf,'Tag','NumBootstrapEdit'),'String',num2str(PLSoptions.num_boot));

         set(findobj(gcf,'Tag','ClimEdit'),'String',num2str(PLSoptions.Clim));
         set(findobj(gcf,'Tag','ClimEdit'),'BackGroundColor',[1 1 1]);
         set(findobj(gcf,'Tag','ClimLabel'),'Enable','on');
         set(findobj(gcf,'Tag','ClimEdit'),'Enable','on');

         if strcmp(PLSoptions.boot_type,'nonstrat')
            set(findobj(gcf,'Tag','BootstrapTypeMenu'),'Value',2);
         else
            set(findobj(gcf,'Tag','BootstrapTypeMenu'),'Value',1);
         end

         set(findobj(gcf,'Tag','BootstrapTypeMenu'),'BackGroundColor',[1 1 1]);
         set(findobj(gcf,'Tag','BootstrapTypeMenu'),'Enable','on');
         set(findobj(gcf,'Tag','BootstrapTypeLabel'),'Enable','on');
         set(findobj(gcf,'Tag','nonrotated_boot'),'Enable','on');
         set(findobj(gcf,'Tag','nonrotated_boot'),'Value',PLSoptions.nonrotated_boot);
      end
   else
      error('Incorrect batch script file.');
   end

   return;					% batch_pls_analysis2

