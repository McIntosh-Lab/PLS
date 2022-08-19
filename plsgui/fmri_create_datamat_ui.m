function fmri_create_datamat_ui(varargin) 
% 
%  USAGE:  fmri_create_datamat_ui(session_file,num_runs,num_slices) 
% 
%  fmri_create_datamat_ui - create ST datatmat options GUI 
% 


   if (nargin == 3), 
      session_file = varargin{1};
      num_runs = varargin{2};
      num_slices = varargin{3};

      init(session_file,num_runs,num_slices);
      uiwait(gcf);			% wait for user finish 

      progress_hdl=findobj(gcf,'tag','ProgressFigure');
      gen_datamat_hdl=findobj(gcf,'tag','STDatamatOptions');

%      if (~isempty(progress_hdl) & ishandle(progress_hdl)) | ...
%		(~isempty(gen_datamat_hdl) & ishandle(gen_datamat_hdl))
%         close(gcf);
%      end

      if (~isempty(progress_hdl) & ishandle(progress_hdl))
         close(progress_hdl);
      end

      if (~isempty(gen_datamat_hdl) & ishandle(gen_datamat_hdl))
         close(gen_datamat_hdl);
      end

      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   if strcmp(action,'PREDEFINE_BRAIN_REGION_BUTTON'),
      SelectPredefineBrainRegion;
   elseif strcmp(action,'EDIT_BRAIN_REGION_FILE'),
      EditBrainRegionFile;
   elseif strcmp(action,'BRAIN_REGION_FILE_BUTTON'),
      SelectBrainRegionFile;
   elseif strcmp(action,'AUTO_BRAIN_REGION_BUTTON'),
      SelectAutoBrainRegion;
   elseif strcmp(action,'CONSIDER_ALL_VOXELS'),
      SelectConsiderAllVoxels;
   elseif strcmp(action,'SET_THRESHOLD'),
      SetThreshold;
   elseif strcmp(action,'SET_MAX_STD_DEVIATION'),
      SetMaxStdDeviation;
   elseif strcmp(action,'MERGE_DATA_WITH_RUN_BUTTON'),
      SelectMergeDataWithinRun;
   elseif strcmp(action,'MERGE_DATA_ACROSS_RUNS_BUTTON'),
      SelectMergeDataAcrossRuns;
   elseif strcmp(action,'EDIT_SKIPPED_SCANS'),
      SetScanSkipped;
   elseif strcmp(action,'EDIT_RUN_INCLUDED'),
      SetRunIncluded;
   elseif strcmp(action,'EDIT_IGNORE_SLICES'),
      SetIgnoreSlices;
   elseif strcmp(action,'EDIT_TEMPORAL_WINDOW_SIZE'),
      SetTemporalWindowSize
   elseif strcmp(action,'RUN_BUTTON'),
      if (SaveSTDatamatOptions) 
         RunGenDatamat;
%         uiresume(gcf);
      end;
   elseif strcmp(action,'CANCEL_BUTTON'),
      setappdata(gcf,'STOptions',[]);
      uiresume(gcf);
   elseif strcmp(action,'DELETE_FIGURE'),
      delete_fig;
   elseif strcmp(action,'EDIT_NUM_BEHAVIOR')
      msg = 'Click the "Edit Behavior Data ..." button to edit behavior data';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_NORMAL_VOLUME')
      msg = 'Please keep this check box unchecked unless you have a good reason not to do so.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_NORMAL_SIGNAL')
      msg = 'Please keep this check box checked unless you have a good reason not to do so.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'EDIT_BEHAV_DATA_ALL')
      EditBehavData_all;
   elseif strcmp(action,'EDIT_BEHAV_DATA_EACH')
      EditBehavData_each;
   elseif strcmp(action,'EDIT_BEHAV_DATA_ALL_SINGLE')
      EditBehavData_all_single;
   elseif strcmp(action,'EDIT_BEHAV_DATA_EACH_SINGLE')
      EditBehavData_each_single;
   elseif strcmp(action,'SINGLESUBJECTBUTTON')
      check_singlesubject;
   elseif strcmp(action,'SELECT_BEHAV_DATA')
      SelectBehavData;
   elseif strcmp(action,'SINGLEREFSCANBUTTON')
      SingleRefScanButton;
   elseif strcmp(action,'SINGLEREFSCANONSETEDIT')
      SingleRefScanOnsetEdit;
   elseif strcmp(action,'SINGLEREFSCANNUMBEREDIT')
      SingleRefScanNumberEdit;
   end;

   return;


%----------------------------------------------------------------------------
function init(session_file,num_runs,num_slices),

   curr_dir = pwd;
   session_win_hdl = gcf;

   save_setting_status = 'on';
   fmri_create_datamat_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_create_datamat_pos) & strcmp(save_setting_status,'on')

      pos = fmri_create_datamat_pos;

   else

      w = 0.6;
%      h = 0.9;
      h = 0.8;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure( ...
        'Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','Generate ST Datamat', ...
        'NumberTitle','off', ...
   	'Position', pos, ...
        'deleteFcn','fmri_create_datamat_ui(''DELETE_FIGURE'');', ...
        'Menubar', 'none', ...
        'WindowStyle','modal', ...
   	'Tag','STDatamatOptions', ...
   	'ToolBar','none');

   x = 0.05;
%   y = 0.63;
   y = 0.64;
   w = 1 - 2*x;
%   h = 0.33;
   h = 0.32;

   pos = [x y w h];

   %-------- for Brain Region Frame
   c = uicontrol('Parent',h0, ...		% Brain Region Frame
   	'Style','frame', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Position', pos, ...
        'Value',0, ...
   	'Tag','BrainRegionFrame');

   x = 0.1;
%   y = 0.9;
   y = 0.88;
   w = 1 - 2*x;
%   h = 0.04;
   h = 0.045;

   pos = [x y w h];

   fnt = 0.6;

   c = uicontrol('Parent',h0, ...		% Brain Region Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
	'FontName', 'FixedWidth', ...
   	'FontAngle','italic', ...
   	'FontWeight','bold', ...
   	'HorizontalAlignment','left', ...
   	'Position', pos, ...
   	'String','Brain Region', ...
   	'Tag','BrainRegionLabel');

   x = 0.1;
%   y = y-.04;
   y = y-.05;
   w = 0.05;

   pos = [x y w h];

   fnt = fnt-0.1;

   c = uicontrol('Parent',h0, ...		% Predefine Region Button
   	'Style','radiobutton', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
        'Value', 0, ...
   	'Position', pos, ...
   	'String','', ...
   	'Callback', ...
             'fmri_create_datamat_ui(''PREDEFINE_BRAIN_REGION_BUTTON'');', ...
   	'Tag','PredefineRegionChkButton');

   x = x+w;
   w = 0.5;
   y = y-.01;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Predefine Region Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position', pos, ...
   	'String','Use predefined brain region.', ...
   	'Tag','PredefineRegionLabel');

   x = 0.2;
%   y = y-.05;
   y = y-.05;
   w = 0.08;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Predefine Region File Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'ForegroundColor',[0.5 0.5 0.5], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','File:', ...
        'TooltipString','The IMG file that specifies the brain region.', ...
   	'Tag','PredefineRegionFileLabel');

   x = x+w+.02;
   y = y+.01;
   w = 0.42;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Predefine Region File Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
        'Enable','off', ...
   	'Callback','fmri_create_datamat_ui(''EDIT_BRAIN_REGION_FILE'');',...
   	'Tag','PredefineRegionFileEdit');

   x = x+w+.02;
   w = 0.15;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Predefine Region File Button
   	'Style','pushbutton', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','Browse', ...
        'Enable','off', ...
   	'Callback', 'fmri_create_datamat_ui(''BRAIN_REGION_FILE_BUTTON'');', ...
   	'Tag','PredefineRegionFileButton');

   x = 0.1;
%   y = y-.05;
   y = y-.05;
   w = 0.05;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               % Auto Region Button
        'Style','radiobutton', ...
        'Units','normal', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'HorizontalAlignment','center', ...
        'Value', 1, ...
        'Position',pos, ...
        'String','', ...
   	'Callback','fmri_create_datamat_ui(''AUTO_BRAIN_REGION_BUTTON'');', ...
        'Tag','AutoRegionChkButton');

   x = x+w;
   y = y-.01;
   w = 0.5;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               % Auto Region Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','Define brain region automatically.', ...
        'Tag','AutoRegionLabel');

   x = 0.1;
%   y = y-.05;
   y = y-.05;
   w = 0.18;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Auto Region Threshold Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','Threshold:', ...
        'TooltipString','Voxels with values below 1/threshold of the max. value in the volumes will be removed.', ...
   	'Tag','AutoRegionThresholdLabel');

   x = x+w+.02;
   y = y+.01;
   w = 0.1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Auto Region Threshold Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','0.15', ...
        'TooltipString','Enter value between 0 and 1.', ...
   	'Callback','fmri_create_datamat_ui(''SET_THRESHOLD'');', ...
   	'Tag','AutoRegionThresholdEdit');

   x = x+w+0.11;
   w = 0.4;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Consider all voxels as brain
   	'Style','check', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','Consider all voxels as brain', ...
   	'Callback','fmri_create_datamat_ui(''CONSIDER_ALL_VOXELS'');', ...
   	'Tag','ConsiderAllVoxels');

   x = 0.1;
%   y = y-.05-.01;
   y = y-.05-.01;
   w = 0.4;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Brain Region Max SD Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Max. standard deviation allowed:', ...
        'TooltipString','The maximum absolution standard deviation allowed in the brain voxels.', ...
	'visible', 'off', ...
   	'Tag','BrainRegionStdDevLabel');

   x = x+w;
   y = y+.01;
   w = 0.1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Brain Region Max SD Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','4', ...
   	'Callback','fmri_create_datamat_ui(''SET_MAX_STD_DEVIATION'');', ...
	'visible', 'off', ...
   	'Tag','BrainRegionStdDevEdit');

   x = 0.05;
%   y = 0.12;
   y = 0.14;
   w = 1 - 2*x;
%   h = 0.5;
   h = 0.47;

   pos = [x y w h];

   %-------- for ST Datamat frame
   c = uicontrol('Parent',h0, ...		% ST Datamat Frame
   	'Units','normal', ...
   	'Style','frame', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Position',pos, ...
        'Value',0, ...
   	'Tag','STDatamatFrame');

   x = 0.1;
%   y = 0.56;
   y = 0.52;
   w = 1 - 2*x;
%   h = 0.04;
   h = 0.045;

   pos = [x y w h];

   fnt = fnt+0.1;

   c = uicontrol('Parent',h0, ...		% ST Datamat Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
	'FontName', 'FixedWidth', ...
   	'FontAngle','italic', ...
   	'FontWeight','bold', ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','ST Datamat', ...
   	'Tag','STDatamatLabel');

   fnt = fnt-0.1;

   x = 0.1;
%   y = y-.05;
   y = y-.055;
   w = 0.4;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of scans to be skipped
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Number of scans to be skipped:', ...
	'visible','off',...
        'TooltipString','The number of first few scans that have unstable magnetic signals.', ...
   	'Tag','NumScansSkippedLabel');

   x = x+w;
   y = y+.01;
   w = 0.1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of skipped scans edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','0', ...
	'visible','off',...
        'TooltipString','Enter a positive integer.', ...
   	'Callback','fmri_create_datamat_ui(''EDIT_SKIPPED_SCANS'');', ...
   	'Tag','NumScansSkippedEdit');

   x = 0.1;
%   y = y-.05-.01;
   y = y-.055-.01;
   w = 0.25;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% ST Datamat Run Included Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Run to be included:', ...
	'visible','off',...
        'TooltipString','The indices of the runs to be used to generate the ST Datamat.', ...
   	'Tag','STDatamatRunIncludedLabel');

   x = x+w;
   y = y+.01;
   w = 0.4;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		%  ST Datamat Run Included Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String',num2str([1:num_runs]), ...
	'visible','off',...
        'TooltipString','Enter a series of run indices.', ...
   	'Callback','fmri_create_datamat_ui(''EDIT_RUN_INCLUDED'');', ...
   	'Tag','STDatamatRunIncludedEdit');

   x = 0.1;
%   y = y-.05-.01;
   y = y-.055-.01;
   w = 0.25;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Ignore Slices 
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
	'visible','off',...
   	'String','Slices to be ignored:', ...
   	'Tag','STDatamatIgnoreSlicesLabel');

   x = x+w;
   y = y+.01;
   w = 0.4;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Ignore Slices Edit 
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
        'TooltipString','Enter the slice numbers.', ...
	'visible','off',...
   	'Callback','fmri_create_datamat_ui(''EDIT_IGNORE_SLICES'');', ...
   	'Tag','STDatamatIgnoreSlicesEdit');

   x = 0.1;
%   y = y-.05-.01;
   y = y-.055-.01+0.16;
   w = 0.4;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Window Size Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Temporal window size (in scans):', ...
        'TooltipString','The temporal window size for each condition.', ...
   	'Tag','STDatamatWindowSizeLabel');

   x = x+w;
   y = y+.01;
   w = 0.1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Window Size Edit 
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','8', ...
        'TooltipString','Enter a positive integer.', ...
   	'Callback','fmri_create_datamat_ui(''EDIT_TEMPORAL_WINDOW_SIZE'');', ...
   	'Tag','STDatamatWindowSizeEdit');

   x = 0.1;
%   y = y-.05;
   y = y-.08;
   w = 0.4;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Mean Ratio Button
   	'Style','check', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'Value', 0, ...
   	'Position',pos, ...
   	'String','Normalize data with volume mean', ...
   	'Callback','fmri_create_datamat_ui(''EDIT_NORMAL_VOLUME'');', ...
   	'Tag','MeanRatioChkButton');

   x = x+w+0.05;
   w = 0.35;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Mean Signal Button
   	'Style','check', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'Value', 1, ...
   	'Position',pos, ...
   	'String','Normalize data with ref. scans', ...
   	'Callback','fmri_create_datamat_ui(''EDIT_NORMAL_SIGNAL'');', ...
   	'Tag','MeanSignalChkButton');

   x = 0.1;
%   y = y-.05;
   w = 0.5;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Merge Data Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Merge data of each condition:', ...
	'visible', 'off', ...
   	'Tag','MergeDataLabel');

   x = 0.1;
%   y = y-.04;
   w = 0.22;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Merge Data Across Runs Button
   	'Style','radiobutton', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
        'Value', 1, ...
   	'Position',pos, ...
   	'String','Across All Runs', ...
	'visible', 'off', ...
   	'Callback','fmri_create_datamat_ui(''MERGE_DATA_ACROSS_RUNS_BUTTON'');', ...
   	'Tag','MergeDataAcrossRunsButton');

   x = x+w;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Merge Data Within Run Button
   	'Style','radiobutton', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
        'Value', 0, ...
   	'Position',pos, ...
   	'String','Within Each Run', ...
	'visible', 'off', ...
   	'Callback','fmri_create_datamat_ui(''MERGE_DATA_WITH_RUN_BUTTON'');', ...
   	'Tag','MergeDataWithinRunButton');

%   x = 0.55;
%   w = 0.35;
   x = 0.1;
%   y = y-.05;
   y = y-.055;
   w = 0.4;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Single Subject
   	'Style','check', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
   	'String','Single subject analysis', ...
   	'Callback','fmri_create_datamat_ui(''SINGLESUBJECTBUTTON'');', ...
   	'Tag','SingleSubjectChkButton');

   x = x+w+0.05;
   w = 0.35;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Single Reference Scan
   	'Style','check', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'Value', 0, ...
   	'Position',pos, ...
   	'String','Single reference scan', ...
   	'Callback','fmri_create_datamat_ui(''SingleRefScanButton'');', ...
   	'Tag','SingleRefScanButton');

   x = 0.1;
   y = y-.055-.03;
   w = 0.4;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% single ref scan onset label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Single reference scan onset:', ...
	'enable', 'off', ...
   	'Tag','SingleRefScanOnsetLabel');

   x = x+w;
   y = y+.01;
   w = 0.1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% single ref scan onset edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','0', ...
   	'Callback','fmri_create_datamat_ui(''SingleRefScanOnsetEdit'');', ...
	'enable', 'off', ...
   	'Tag','SingleRefScanOnsetEdit');

   x = 0.1;
   y = y-.055-.01;
   w = 0.4;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% single ref scan number label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Single reference scan number:', ...
	'enable', 'off', ...
   	'Tag','SingleRefScanNumberLabel');

   x = x+w;
   y = y+.01;
   w = 0.1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% single ref scan number edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','1', ...
   	'Callback','fmri_create_datamat_ui(''SingleRefScanNumberEdit'');', ...
	'enable', 'off', ...
   	'Tag','SingleRefScanNumberEdit');

   x = 0.1;
   y = y-.055-.03;
   w = 0.18;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Behav Data Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','right', ...
   	'Position',pos, ...
   	'String','Behavior Data:', ...
	'visible', 'off', ...
   	'Tag','BehavDataLabel');

   x = x+w+0.02;
   y = y+.01;
   w = 0.1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of behavior edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','0', ...
   	'buttondown','fmri_create_datamat_ui(''EDIT_NUM_BEHAVIOR'');', ...
	'enable', 'inactive', ...
	'visible', 'off', ...
   	'Tag','NumberBehaviorEdit');

   x = x+w+.02;
   w = 0.3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Behavior Data Edit
   	'Units','normal', ...
	'string', 'Edit Behavior Data...', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','fmri_create_datamat_ui(''EDIT_BEHAV_DATA_ALL'');', ...
	'enable', 'on', ...
	'visible', 'off', ...
   	'Tag','BehavDataEdit_all');

   c = uicontrol('Parent',h0, ...		% Behavior Data Edit
   	'Units','normal', ...
	'string', 'Edit Behavior Data...', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','fmri_create_datamat_ui(''EDIT_BEHAV_DATA_EACH'');', ...
	'enable', 'on', ...
	'visible','off', ...
   	'Tag','BehavDataEdit_each');

   c = uicontrol('Parent',h0, ...		% Behavior Data Edit
   	'Units','normal', ...
	'string', 'Edit Behavior Data...', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','fmri_create_datamat_ui(''EDIT_BEHAV_DATA_ALL_SINGLE'');', ...
	'enable', 'on', ...
	'visible','off', ...
   	'Tag','BehavDataEdit_all_single');

   c = uicontrol('Parent',h0, ...		% Behavior Data Edit
   	'Units','normal', ...
	'string', 'Edit Behavior Data...', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
	'callback','fmri_create_datamat_ui(''EDIT_BEHAV_DATA_EACH_SINGLE'');', ...
	'enable', 'on', ...
	'visible','off', ...
   	'Tag','BehavDataEdit_each_single');

   x = x+w+.02;
   w = 0.15;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Behav Data Button
   	'Style','pushbutton', ...
        'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
        'Position',pos, ...
        'String','Browse ...', ...
   	'Callback','fmri_create_datamat_ui(''SELECT_BEHAV_DATA'');', ...
	'enable', 'on', ...
	'visible', 'off', ...
   	'Tag','BehavDataButton');

   x = 0.05;
%   y = 0.05;
   y = 0.05;
   w = 0.4;
%   h = 0.04;
   h = 0.045;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% ORIENT Button
   	'Style','pushbutton', ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','Check image orientation', ...
   	'Callback','bfm_create_datamat_ui(''ORIENT'');',...
   	'Tag','ORIENTButton');

%   x = 0.25;
   x = 0.5;
%   y = 0.05;
%   w = 0.15;
   w = 0.2;
%   h = 0.04;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% RUN Button
   	'Style','pushbutton', ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','Create', ...
   	'Callback','fmri_create_datamat_ui(''RUN_BUTTON'');',...
   	'Tag','RUNButton');

%   x = 1-x-w;
   x = x + w + 0.05;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% CANCEL Button
   	'Style','pushbutton', ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','Cancel', ...
   	'Callback','fmri_create_datamat_ui(''CANCEL_BUTTON'');',...
   	'Tag','CANCELButton');

   x = 0.01;
   y = 0;
   w = 1;
%   h = 0.04;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...               % Message Line
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


   setappdata(h0,'SessionFile',session_file);
   setappdata(h0,'NumRuns',num_runs);
   setappdata(h0,'NumSlices',num_slices);
   setappdata(h0,'BehavData',[]);
   setappdata(h0,'BehavName',{});
%   setappdata(gcf,'NumBehavior',0);
%   set_num_behav;

   setappdata(h0, 'session_win_hdl', session_win_hdl);

   InitOptions(num_runs); 

   return;						% init


%----------------------------------------------------------------------------
function InitOptions(num_runs)


   setappdata(gcf,'BrainRegionFile',[]);

   setappdata(gcf,'Threshold',0.15);
   setappdata(gcf,'MaxStdDev',4);

   setappdata(gcf,'NumScansSkipped',0);
   setappdata(gcf,'RunsIncluded',[1:num_runs]);
   setappdata(gcf,'SliceIgnored',[]);
   setappdata(gcf,'TemporalWindowSize',8);

   return;						% InitOptions


%----------------------------------------------------------------------------
function SelectPredefineBrainRegion()

if get(findobj(gcf,'Tag','PredefineRegionChkButton'),'Value') == 0		% click itself
   set(findobj(gcf,'Tag','PredefineRegionChkButton'),'Value',1);
else

   set(findobj(gcbf,'Tag','AutoRegionChkButton'),'Value',0);
   set(findobj(gcbf,'Tag','AutoRegionThresholdLabel'), ...
                                                'Foreground',[0.5 0.5 0.5]);
   set(findobj(gcbf,'Tag','AutoRegionThresholdEdit'),'Enable','off');
   set(findobj(gcf,'Tag','ConsiderAllVoxels'),'Value', 0);
   set(findobj(gcbf,'Tag','ConsiderAllVoxels'),'Enable','off');

   set(findobj(gcbf,'Tag','PredefineRegionFileLabel'),'Foreground',[0 0 0]);
   set(findobj(gcbf,'Tag','PredefineRegionFileEdit'),'Enable','on');
   set(findobj(gcbf,'Tag','PredefineRegionFileButton'),'Enable','on');

end

   return;					% SelectPredefineBrainRegion

%----------------------------------------------------------------------------
function EditBrainRegionFile()

   fname = get(gcbo,'String');

   if isempty(fname)
      setappdata(gcf,'BrainRegionFile',[]);
      return;
   end;

   if (exist(fname,'file') ~= 2)
      msg = 'ERROR: Invalid file specified.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'BrainRegionFile',[]);
      return;
   end;

   %  make sure the IMG file can be accessed.
   %
   try
      dummy = rri_imginfo(fname);
   catch 
      msg = 'ERROR: Cannot open the file.  Make sure it is an IMG file.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   if (fname(1) == filesep)			% full path 
      setappdata(gcf,'BrainRegionFile',fname);
      return;
   end;

   % construct the path
   %
   [fpath, fname, fext] = fileparts(fname);

   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   if isempty(fpath) 				% just filename no path
      fpath = curr;
   else 					% relative path
      curr_path = curr;
      cd (fpath);  
      fpath = curr;
      cd (curr_path);  
   end;

   if isempty(fpath),				% in the root directory 
      fpath = filesep; 
   end;

   fname = fullfile(fpath,[fname, fext]); 
   set(gcbo,'String',fname);

   setappdata(gcf,'BrainRegionFile',fname);

   return;					% EditBrainRegionFile


%----------------------------------------------------------------------------
function SelectBrainRegionFile()

   [fname, fpath] = rri_selectfile('*.img','Brain Region Mask');

   if isequal(fname,0),			% no file has been selected
      return;
   end;

   if ~isequal(fpath,filesep) & ~isequal(fpath,0)
      fname = fullfile(fpath,fname);
   end;

   %  make sure the IMG file can be accessed.
   %
   try
      dummy = rri_imginfo(fname);
   catch 
      msg = 'ERROR: Cannot open the file.  Make sure it is an IMG file.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   set(findobj(gcbf,'Tag','PredefineRegionFileEdit'),'String',fname);
   setappdata(gcf,'BrainRegionFile',fname);
   
   return;					% SelectBrainRegionFile


%----------------------------------------------------------------------------
function SelectAutoBrainRegion()

if get(findobj(gcf,'Tag','AutoRegionChkButton'),'Value') == 0		% click itself
   set(findobj(gcf,'Tag','AutoRegionChkButton'),'Value',1);
else

   set(findobj(gcbf,'Tag','PredefineRegionChkButton'),'Value',0);
   set(findobj(gcbf,'Tag','PredefineRegionFileLabel'), ...
                                                'Foreground',[0.5 0.5 0.5]);
   set(findobj(gcbf,'Tag','PredefineRegionFileEdit'),'Enable','off');
   set(findobj(gcbf,'Tag','PredefineRegionFileButton'),'Enable','off');

   set(findobj(gcbf,'Tag','AutoRegionThresholdLabel'),'Foreground',[0 0 0]);
   set(findobj(gcbf,'Tag','AutoRegionThresholdEdit'),'Enable','on');
   set(findobj(gcbf,'Tag','ConsiderAllVoxels'),'Enable','on');

end

   return;					% SelectAutoBrainRegion


%----------------------------------------------------------------------------
function SelectConsiderAllVoxels

   if get(findobj(gcbf,'Tag','ConsiderAllVoxels'),'Value') == 0
      set(findobj(gcbf,'Tag','AutoRegionThresholdEdit'),'Enable','on');
      set(findobj(gcbf,'Tag','AutoRegionThresholdEdit'),'String','0.15');
      setappdata(gcbf,'Threshold',0.25);
   else
      set(findobj(gcbf,'Tag','AutoRegionThresholdEdit'),'Enable','off');
      set(findobj(gcbf,'Tag','AutoRegionThresholdEdit'),'String','0');
      setappdata(gcbf,'Threshold',0);
   end

   return;					% SelectConsiderAllVoxels


%----------------------------------------------------------------------------
function SetThreshold()
   
   try
      threshold = str2num(get(gcbo,'String'));
      if (threshold < 0) | (threshold > 1)
         msg = 'ERROR: Threshold must be between 0 and 1.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         setappdata(gcf,'Threshold',[]);
         return;
      end;

      setappdata(gcf,'Threshold',threshold);
   catch
      msg = 'ERROR: Invalid threshold value.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'Threshold',[]);
      return;
   end;


   return;					% SetThreshold

%----------------------------------------------------------------------------
function SetMaxStdDeviation()
   
   try
      max_std_dev = str2num(get(gcbo,'String'));
      if (max_std_dev <= 0)
         msg = 'ERROR: Max. standard deviation must be larger than 0';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         setappdata(gcf,'MaxStdDev',[]);
         return;
      end;

      setappdata(gcf,'MaxStdDev',max_std_dev);
   catch
      msg = 'ERROR: Invalid value for the max. standard deviation.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'MaxStdDev',[]);
      return;
   end;

   return;					% SetMaxStdDeviation


%----------------------------------------------------------------------------
function SelectMergeDataWithinRun()

if get(findobj(gcf,'Tag','MergeDataWithinRunButton'),'Value') == 0		% click itself
   set(findobj(gcf,'Tag','MergeDataWithinRunButton'),'Value',1);
else
   set(findobj(gcbf,'Tag','MergeDataAcrossRunsButton'),'Value',0);

   if get(findobj(gcf,'Tag','SingleSubjectChkButton'),'Value')
      set(findobj(gcbf,'Tag','BehavDataEdit_all'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_all_single'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each_single'),'Visible','On');
   else
      set(findobj(gcbf,'Tag','BehavDataEdit_all'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each'),'Visible','On');
      set(findobj(gcbf,'Tag','BehavDataEdit_all_single'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each_single'),'Visible','Off');
   end

%   set_num_behav;
end

   return;					% SelectMergeDataWithinRun


%----------------------------------------------------------------------------
function SelectMergeDataAcrossRuns()

if get(findobj(gcf,'Tag','MergeDataAcrossRunsButton'),'Value') == 0		% click itself
   set(findobj(gcf,'Tag','MergeDataAcrossRunsButton'),'Value',1);
else
   set(findobj(gcbf,'Tag','MergeDataWithinRunButton'),'Value',0);

   if get(findobj(gcf,'Tag','SingleSubjectChkButton'),'Value')
      set(findobj(gcbf,'Tag','BehavDataEdit_all'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_all_single'),'Visible','On');
      set(findobj(gcbf,'Tag','BehavDataEdit_each_single'),'Visible','Off');
   else
      set(findobj(gcbf,'Tag','BehavDataEdit_all'),'Visible','On');
      set(findobj(gcbf,'Tag','BehavDataEdit_each'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_all_single'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each_single'),'Visible','Off');
   end

%   set_num_behav;
end

   return;					% SelectMergeDataAcrossRuns


%----------------------------------------------------------------------------
function check_singlesubject

if 0
if get(findobj(gcf,'Tag','MergeDataAcrossRunsButton'),'Value')

   if get(findobj(gcf,'Tag','SingleSubjectChkButton'),'Value')
      set(findobj(gcbf,'Tag','BehavDataEdit_all'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_all_single'),'Visible','On');
      set(findobj(gcbf,'Tag','BehavDataEdit_each_single'),'Visible','Off');
   else
      set(findobj(gcbf,'Tag','BehavDataEdit_all'),'Visible','On');
      set(findobj(gcbf,'Tag','BehavDataEdit_each'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_all_single'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each_single'),'Visible','Off');
   end

else

   if get(findobj(gcf,'Tag','SingleSubjectChkButton'),'Value')
      set(findobj(gcbf,'Tag','BehavDataEdit_all'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_all_single'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each_single'),'Visible','On');
   else
      set(findobj(gcbf,'Tag','BehavDataEdit_all'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each'),'Visible','On');
      set(findobj(gcbf,'Tag','BehavDataEdit_all_single'),'Visible','Off');
      set(findobj(gcbf,'Tag','BehavDataEdit_each_single'),'Visible','Off');
   end

end

%   set_num_behav;
end

   return;


%----------------------------------------------------------------------------
function SetScanSkipped()
   
   num_scans_skipped = str2num(get(gcbo,'String'));

   if isempty(num_scans_skipped) | (num_scans_skipped < 0)
      msg = 'ERROR: Invalid value for the number of skipped scans.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'NumScansSkipped',[]);
      return;
   end;

   setappdata(gcf,'NumScansSkipped',num_scans_skipped);

   return;					% SetScanSkipped


%----------------------------------------------------------------------------
function SetRunIncluded()
   
   run_idx = str2num(get(gcbo,'String'));

   if isempty(run_idx) 
      msg = 'ERROR: Invalid value for the run indices.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'RunsIncluded',[]);
      return;
   end;

   num_runs = getappdata(gcf,'NumRuns');
   if ~isempty(find(run_idx <= 0 | run_idx > num_runs))
      msg = sprintf('ERROR: Slice number must be between 1 to %d',num_runs);
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'RunsIncluded',[]);
      return;
   end;


   setappdata(gcf,'RunsIncluded',run_idx);

   return;					% SetRunIncluded


%----------------------------------------------------------------------------
function SetIgnoreSlices()
   
   ignore_slices = str2num(get(gcbo,'String'));

   if isempty(ignore_slices) 
      msg = 'ERROR: Invalid value for the slice number.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'SliceIgnored',-1);
      return;
   end;

   num_slices = getappdata(gcf,'NumSlices');
   if ~isempty(find(ignore_slices <= 0 | ignore_slices > num_slices))
      msg = sprintf('ERROR: Slice number must be between 1 to %d',num_slices);
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'SliceIgnored',-1);
      return;
   end;

   setappdata(gcf,'SliceIgnored',ignore_slices);

   return;					% SetIgnoreSlices


%----------------------------------------------------------------------------
function SetTemporalWindowSize()
   
   try
      window_size = str2num(get(gcbo,'String'));
      if (window_size <= 0)
         msg = 'ERROR: The temporal window size must be larger than 0';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         setappdata(gcf,'TemporalWindowSize',[]);
         return;
      end;
   catch
      msg = 'ERROR: Invalid value for the max. standard deviation.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      setappdata(gcf,'TemporalWindowSize',[]);
      return;
   end;

   setappdata(gcf,'TemporalWindowSize',window_size);

   return;					% SetTemporalWindowSize


%----------------------------------------------------------------------------
function status = SaveSTDatamatOptions()

   status = 0;			% set status to fail first

   STOptions.session_win_hdl = getappdata(gcf,'session_win_hdl');

   %  For brain region
   %
   if (get(findobj(gcbf,'Tag','PredefineRegionChkButton'),'Value') == 1)
      STOptions.UseBrainRegionFile = 1;
      STOptions.BrainRegionFile = getappdata(gcf,'BrainRegionFile');
      if isempty(STOptions.BrainRegionFile),
          msg = 'ERROR: Invalid file for the brain region mask.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
      end;

      STOptions.Threshold = [];
      STOptions.ConsiderAllVoxels = 0;
   else
      STOptions.UseBrainRegionFile = 0;
      STOptions.BrainRegionFile = [];
      STOptions.Threshold = getappdata(gcf,'Threshold');
      if isempty(STOptions.Threshold) 
          msg = 'ERROR: Invalid threshold value.';
          set(findobj(gcf,'Tag','MessageLine'),'String',msg);
          return;
      end;
      STOptions.ConsiderAllVoxels = ...
	get(findobj(gcbf,'Tag','ConsiderAllVoxels'),'value');
   end;

   STOptions.MaxStdDev = getappdata(gcf,'MaxStdDev');
   if isempty(STOptions.MaxStdDev) 
      msg = 'ERROR: Invalid max. standard deviation value.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   % for ST Datamat
   %
   STOptions.NumScansSkipped = getappdata(gcf,'NumScansSkipped');
   if isempty(STOptions.NumScansSkipped) 
      msg = 'ERROR: Invalid value for the number of skipped scans.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   STOptions.RunsIncluded = getappdata(gcf,'RunsIncluded');
   if isempty(STOptions.RunsIncluded) 
      msg = 'ERROR: Invalid run indices.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   STOptions.SliceIgnored = getappdata(gcf,'SliceIgnored');
   if ~isempty(STOptions.SliceIgnored) & (STOptions.SliceIgnored == -1) 
      msg = 'ERROR: Invalid slice number to be ignored.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   STOptions.TemporalWindowSize = getappdata(gcf,'TemporalWindowSize');
   if isempty(STOptions.TemporalWindowSize) 
      msg = 'ERROR: Invalid temporal window size.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   h = findobj(gcbf,'Tag','MeanRatioChkButton');
   STOptions.NormalizeVolumeMean = get(h,'Value');

   h = findobj(gcbf,'Tag','MeanSignalChkButton');
   STOptions.NormalizeSignalMean = get(h,'Value');

   h = findobj(gcbf,'Tag','SingleSubjectChkButton');
   STOptions.SingleSubject = get(h,'Value');

   h = findobj(gcbf,'Tag','MergeDataAcrossRunsButton');
   STOptions.MergeDataAcrossRuns = get(h,'Value');
   STOptions.MergeDataAcrossRuns = getappdata(STOptions.session_win_hdl,'SessionAcrossRun');

   STOptions.BehavData = []; % getappdata(gcf,'BehavData');
   STOptions.BehavName = {}; % getappdata(gcf,'BehavName');
   STOptions.NumBehavior = 0; % getappdata(gcf,'NumBehavior');

   if ~isempty(STOptions.BehavData)

      session_file = getappdata(gcbf,'SessionFile');
      load(session_file);
      num_cond = session_info.num_conditions;
      num_run = length(STOptions.RunsIncluded);

      if STOptions.MergeDataAcrossRuns & ~STOptions.SingleSubject
         if STOptions.NumBehavior == num_cond
            num_behav_not_match = 0;
         else
            num_behav_not_match = num_cond;
         end
      elseif ~STOptions.MergeDataAcrossRuns & ~STOptions.SingleSubject
         if STOptions.NumBehavior == num_cond * num_run
            num_behav_not_match = 0;
         else
            num_behav_not_match = num_cond * num_run;
         end
      elseif STOptions.MergeDataAcrossRuns & STOptions.SingleSubject
         sess = load(session_file);
         if STOptions.NumBehavior == num_cond * length(sess.session_info.run(1).evt_onsets{1})
            num_behav_not_match = 0;
         else
            num_behav_not_match = num_cond * length(sess.session_info.run(1).evt_onsets{1});
         end
      elseif ~STOptions.MergeDataAcrossRuns & STOptions.SingleSubject
         sess = load(session_file);

         total_onset = 0;         
         for i = 1:sess.session_info.num_runs
            total_onset = total_onset + length(sess.session_info.run(i).evt_onsets{1});
         end

         if STOptions.NumBehavior == num_cond * total_onset
            num_behav_not_match = 0;
         else
            num_behav_not_match = num_cond * total_onset;
         end
      end

      if num_behav_not_match
         msg = ['ERROR: Rows of behavior data file should be ' num2str(num_behav_not_match)];
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end;

   end

   STOptions.SingleRefScanButton = get(findobj(gcf,'Tag','SingleRefScanButton'), 'value');
   STOptions.SingleRefScanOnset = str2num(get(findobj(gcf,'Tag','SingleRefScanOnsetEdit'), 'string'));
   STOptions.SingleRefScanNumber = str2num(get(findobj(gcf,'Tag','SingleRefScanNumberEdit'), 'string'));

   status = 1;
   setappdata(gcf,'STOptions',STOptions);

   return;					% SaveSTDatamatOptions


%----------------------------------------------------------------------------
function RunGenDatamat(),

   if exist('plslog.m','file')
      plslog('Create fMRI Datamat');
   end

   options = getappdata(gcf,'STOptions');
   session_file = getappdata(gcf,'SessionFile');
   orient = getappdata(gcf,'orient');
   num_runs = getappdata(gcf,'NumRuns');

   if options.SingleSubject
      session_info = session_file;

      old = [];
      for r = 1:session_info.num_runs

         if ~options.MergeDataAcrossRuns
            old = [];
         end

        if 0
          for c = 1:session_info.num_conditions0
            tmp = session_info.run(r).evt_onsets{c};
            tmp = tmp(find(tmp>=options.NumScansSkipped));
            new = length(tmp);

            if ~isempty(old) & ~isequal(old, new)
               msg = 'Number of onsets must be the same.';
               set(findobj(gcf,'Tag','MessageLine'),'String',msg);
               return;
            end

            old = new;
          end
        end
      end
   end

   % to make progress bar in the center
   % progress_hdl = rri_progress_status(gcf,'Create','Spatial/Temporal Datamat');
   fig1 = gcf;
   progress_hdl = rri_progress_status('Create','Spatial/Temporal Datamat');
   close(fig1);
   run_idx = options.RunsIncluded;

   
   %  generate datamat for each run
   %
%   progress_factor = 1 / length(run_idx) * 0.6;
%   setappdata(progress_hdl,'ProgressScale',progress_factor);

%   for i = run_idx,
   i = run_idx;
%      curr_progress = (i-1)*progress_factor;
%      setappdata(progress_hdl,'ProgressStart',curr_progress);

       if (options.UseBrainRegionFile == 1)
%          fmri_gen_datamat(session_file,i,options.BrainRegionFile, ...
          fmri_get_datamat(session_file,i,options.BrainRegionFile, ...
             				options.MaxStdDev, ...
					options.SliceIgnored, ...
					options.NormalizeVolumeMean, ...
					options.NumScansSkipped, ...
					options.TemporalWindowSize, ...
					options.MergeDataAcrossRuns, ...
					options.BehavData, ...
					options.BehavName, ...
					options.session_win_hdl, ...
					options.NormalizeSignalMean, ...
					options.ConsiderAllVoxels, ...
					options.SingleSubject, ...
					options.SingleRefScanButton, ...
					options.SingleRefScanOnset, ...
					options.SingleRefScanNumber, ...
					orient);
       else
%          fmri_gen_datamat(session_file,i,options.Threshold, ...
          fmri_get_datamat(session_file,i,options.Threshold, ...
					options.MaxStdDev, ...
					options.SliceIgnored, ...
					options.NormalizeVolumeMean, ...
					options.NumScansSkipped, ...
					options.TemporalWindowSize, ...
					options.MergeDataAcrossRuns, ...
					options.BehavData, ...
					options.BehavName, ...
					options.session_win_hdl, ...
					options.NormalizeSignalMean, ...
					options.ConsiderAllVoxels, ...
					options.SingleSubject, ...
					options.SingleRefScanButton, ...
					options.SingleRefScanOnset, ...
					options.SingleRefScanNumber, ...
					orient);
       end
%   end;

   return;					% RunGenDatamat


   %  determine the common brain region from all runs
   %
   progress_factor = 1 / (length(run_idx)+1) * 0.4;
   setappdata(progress_hdl,'ProgressScale',progress_factor);
   setappdata(progress_hdl,'ProgressStart',0.6);

   rri_progress_status(progress_hdl,'Show_message', ...
                             'Determine the common brain region ...');

   coords_info = fmri_combine_coords(session_file,run_idx);

   rri_progress_status(progress_hdl,'Update_bar',1);

   %  prepare clear up the datamat
   %  this block is moved up, because there is a possibility that
   %  datamat_prefix was changed during saving
   %
   load(session_file);
   pls_data_path = session_info.pls_data_path;
   datamat_prefix = session_info.datamat_prefix;

   %  generate the ST datamat
   %
   progress_factor = 1 / (length(run_idx)+3) * 0.4;
   setappdata(progress_hdl,'ProgressStart',progress_factor+0.6);

%   fmri_gen_st2_datamat(session_file, options.NumScansSkipped, ...
   fmri_gen_st_datamat(session_file, options.NumScansSkipped, ...
                                    options.TemporalWindowSize, ...
			            options.RunsIncluded, coords_info, ...
				    options.MergeDataAcrossRuns, ...
                                    options.BehavData, ...
                                    options.BehavName);

   %  clear up the datamat
   %
   for i=run_idx,
      datamat_file = sprintf('%s_run%d.mat',datamat_prefix,i);
      datamat_file = fullfile(pls_data_path,datamat_file);
      % rm_command = sprintf('rm %s',datamat_file);
      % unix(rm_command);
      try
         eval(['delete ', datamat_file]);
      catch
      end
   end;

   return;					% RunGenDatamat


% --------------------------------------------------------------------
function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      fmri_create_datamat_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'fmri_create_datamat_pos');
   catch
   end

   return;


%----------------------------------------------------------------------------
function SelectBehavData

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

   setappdata(gcf,'BehavData',behavdata);
   setappdata(gcf,'NumBehavior',size(behavdata, 1));
   set(findobj(gcf,'Tag','NumberBehaviorEdit'),'String',size(behavdata,1));

   return;						% SelectBehavData


%----------------------------------------------------------------------------
function EditBehavData_all

   session_file = getappdata(gcbf,'SessionFile');
   load(session_file);

   if isfield(session_info, 'behavname_all')
      behavname = session_info.behavname_all;
      behavdata = session_info.behavdata_all;
   else
      behavname = {};
      behavdata = [];
   end

   [newbehavdata, newbehavname] = rri_edit_behav(num2str(behavdata), behavname, 'Edit Behavior Data');

   if isequal(str2num(newbehavdata),behavdata) & isequal(newbehavname,behavname)
      return;
   else
      answer = questdlg('Do you want to update session file with new behavior data?');
      if ~strcmpi(answer,'yes')
         return;
      end
   end

   behavdata = newbehavdata;
   behavname = newbehavname;

   setappdata(gcf,'BehavData',str2num(behavdata));
   setappdata(gcf,'BehavName',behavname);
   setappdata(gcf,'NumBehavior',size(str2num(behavdata), 1));

   set(findobj(gcf,'Tag','NumberBehaviorEdit'),'String',size(str2num(behavdata),1));

   session_info.behavname_all = behavname;
   session_info.behavdata_all = str2num(behavdata);

   save(session_file, '-append', 'session_info');

   return;


%----------------------------------------------------------------------------
function EditBehavData_each

   session_file = getappdata(gcbf,'SessionFile');
   load(session_file);

   if isfield(session_info, 'behavname_each')
      behavname = session_info.behavname_each;
      behavdata = session_info.behavdata_each;
   else
      behavname = {};
      behavdata = [];
   end

   [newbehavdata, newbehavname] = rri_edit_behav(num2str(behavdata), behavname, 'Edit Behavior Data');

   if isequal(str2num(newbehavdata),behavdata) & isequal(newbehavname,behavname)
      return;
   else
      answer = questdlg('Do you want to update session file with new behavior data?');
      if ~strcmpi(answer,'yes')
         return;
      end
   end

   behavdata = newbehavdata;
   behavname = newbehavname;

   setappdata(gcf,'BehavData',str2num(behavdata));
   setappdata(gcf,'BehavName',behavname);
   setappdata(gcf,'NumBehavior',size(str2num(behavdata), 1));

   set(findobj(gcf,'Tag','NumberBehaviorEdit'),'String',size(str2num(behavdata),1));

   session_info.behavname_each = behavname;
   session_info.behavdata_each = str2num(behavdata);

   save(session_file, '-append', 'session_info');

   return;


%----------------------------------------------------------------------------
function EditBehavData_all_single

   session_file = getappdata(gcbf,'SessionFile');
   load(session_file);

   if isfield(session_info, 'behavname_all_single')
      behavname = session_info.behavname_all_single;
      behavdata = session_info.behavdata_all_single;
   else
      behavname = {};
      behavdata = [];
   end

   [newbehavdata, newbehavname] = rri_edit_behav(num2str(behavdata), behavname, 'Edit Behavior Data');

   if isequal(str2num(newbehavdata),behavdata) & isequal(newbehavname,behavname)
      return;
   else
      answer = questdlg('Do you want to update session file with new behavior data?');
      if ~strcmpi(answer,'yes')
         return;
      end
   end

   behavdata = newbehavdata;
   behavname = newbehavname;

   setappdata(gcf,'BehavData',str2num(behavdata));
   setappdata(gcf,'BehavName',behavname);
   setappdata(gcf,'NumBehavior',size(str2num(behavdata), 1));

   set(findobj(gcf,'Tag','NumberBehaviorEdit'),'String',size(str2num(behavdata),1));

   session_info.behavname_all_single = behavname;
   session_info.behavdata_all_single = str2num(behavdata);

   save(session_file, '-append', 'session_info');

   return;


%----------------------------------------------------------------------------
function EditBehavData_each_single

   session_file = getappdata(gcbf,'SessionFile');
   load(session_file);

   if isfield(session_info, 'behavname_each_single')
      behavname = session_info.behavname_each_single;
      behavdata = session_info.behavdata_each_single;
   else
      behavname = {};
      behavdata = [];
   end

   [newbehavdata, newbehavname] = rri_edit_behav(num2str(behavdata), behavname, 'Edit Behavior Data');

   if isequal(str2num(newbehavdata),behavdata) & isequal(newbehavname,behavname)
      return;
   else
      answer = questdlg('Do you want to update session file with new behavior data?');
      if ~strcmpi(answer,'yes')
         return;
      end
   end

   behavdata = newbehavdata;
   behavname = newbehavname;

   setappdata(gcf,'BehavData',str2num(behavdata));
   setappdata(gcf,'BehavName',behavname);
   setappdata(gcf,'NumBehavior',size(str2num(behavdata), 1));

   set(findobj(gcf,'Tag','NumberBehaviorEdit'),'String',size(str2num(behavdata),1));

   session_info.behavname_each_single = behavname;
   session_info.behavdata_each_single = str2num(behavdata);

   save(session_file, '-append', 'session_info');

   return;


%----------------------------------------------------------------------------
function set_num_behav

   session_file = getappdata(gcbf,'SessionFile');
   load(session_file);

   if get(findobj(gcf,'Tag','MergeDataAcrossRunsButton'),'Value')	% all

      if get(findobj(gcf,'Tag','SingleSubjectChkButton'),'Value')
         if isfield(session_info, 'behavname_all_single')
            behavname = session_info.behavname_all_single;
            behavdata = session_info.behavdata_all_single;
         else
            behavname = {};
            behavdata = [];
         end
      else
         if isfield(session_info, 'behavname_all')
            behavname = session_info.behavname_all;
            behavdata = session_info.behavdata_all;
         else
            behavname = {};
            behavdata = [];
         end
      end

   else									% each

      if get(findobj(gcf,'Tag','SingleSubjectChkButton'),'Value')
         if isfield(session_info, 'behavname_each_single')
            behavname = session_info.behavname_each_single;
            behavdata = session_info.behavdata_each_single;
         else
            behavname = {};
            behavdata = [];
         end
      else
         if isfield(session_info, 'behavname_each')
            behavname = session_info.behavname_each;
            behavdata = session_info.behavdata_each;
         else
            behavname = {};
            behavdata = [];
         end
      end

   end

   setappdata(gcf,'BehavData',behavdata);
   setappdata(gcf,'BehavName',behavname);
   setappdata(gcf,'NumBehavior',size(behavdata, 1));

   set(findobj(gcf,'Tag','NumberBehaviorEdit'),'String',size(behavdata,1));

   return;


%----------------------------------------------------------------------------
function SingleRefScanButton

   if(get(gco,'Value'))
      set(findobj(gcf,'Tag','SingleRefScanOnsetLabel'),'Enable','on');
      set(findobj(gcf,'Tag','SingleRefScanOnsetEdit'),'Enable','on');
      set(findobj(gcf,'Tag','SingleRefScanNumberLabel'),'Enable','on');
      set(findobj(gcf,'Tag','SingleRefScanNumberEdit'),'Enable','on');
   else
      set(findobj(gcf,'Tag','SingleRefScanOnsetLabel'),'Enable','off');
      set(findobj(gcf,'Tag','SingleRefScanOnsetEdit'),'Enable','off');
      set(findobj(gcf,'Tag','SingleRefScanNumberLabel'),'Enable','off');
      set(findobj(gcf,'Tag','SingleRefScanNumberEdit'),'Enable','off');
   end

   return;


%----------------------------------------------------------------------------
function SingleRefScanOnsetEdit

   SingleRefScanOnset = str2num(get(gco, 'string'));

   if length(SingleRefScanOnset) ~= 1
      msg = 'Please input exactly 1 number for single reference scan onset';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   if SingleRefScanOnset < 0
      msg = 'Single reference scan onset should not be less than 0';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   this_app = getappdata(gcf);
   last_app = getappdata(this_app.session_win_hdl);
   run_info = last_app.SessionRunInfo;

   for i = 1:length(run_info)
      if( run_info(i).num_scans < (SingleRefScanOnset+1) )
         msg = 'Single reference scan onset should not exceed number of scans';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
   end

   return;


%----------------------------------------------------------------------------
function SingleRefScanNumberEdit

   SingleRefScanOnset = str2num(get(findobj(gcf,'Tag','SingleRefScanOnsetEdit'), 'string'));
   SingleRefScanNumber = str2num(get(gco, 'string'));

   if length(SingleRefScanNumber) ~= 1
      msg = 'Please input exactly 1 number for single reference scan number';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   if SingleRefScanNumber <= 0
      msg = 'Single reference scan number should be greater than 0';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   this_app = getappdata(gcf);
   last_app = getappdata(this_app.session_win_hdl);
   run_info = last_app.SessionRunInfo;

   for i = 1:length(run_info)
      if( run_info(i).num_scans < (SingleRefScanNumber+SingleRefScanOnset) )
         msg = 'Single reference scan number should not exceed number of scans';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
   end

   return;

