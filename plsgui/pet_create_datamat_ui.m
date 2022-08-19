function pet_create_datamat_ui(varargin) 
% 
%  USAGE:  pet_create_datamat_ui(session_file) 
% 
%  pet_create_datamat_ui - Creates a datamat file
% 

    if nargin == 0 | ~ischar(varargin{1})

        session_file = varargin{1}{1};

        init(session_file);
%        uiwait;				% wait for user finish

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
   elseif strcmp(action,'MERGE_CONDITIONS'),
      MergeConditions;
   elseif strcmp(action,'ORIENT'),
      orient;
   elseif strcmp(action,'RUN_BUTTON'),
      if (SaveDatamatOptions) 
         CreateDatamat;
      end;
   elseif strcmp(action,'CANCEL_BUTTON'),
%      uiresume(gcf);
      close(gcf);
   elseif strcmp(action,'DELETE_FIG'),
      delete_fig;
   elseif strcmp(action,'EDIT_NORMAL_VOLUME')
      msg = 'Please keep this check box checked unless you have a good reason not to do so.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   end;

   return;


%----------------------------------------------------------------------------
function init(session_file),

   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   curr_dir = curr;
   session_win_hdl = gcf;

   save_setting_status = 'on';
   pet_create_datamat_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(pet_create_datamat_pos) & strcmp(save_setting_status,'on')

      pos = pet_create_datamat_pos;

   else

      w = 0.6;
      h = 0.5;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure( ...
        'Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Name','Create PET Datamat', ...
        'NumberTitle','off', ...
   	'Position', pos, ...
        'deleteFcn','pet_create_datamat_ui(''DELETE_FIG'');', ...
        'Menubar', 'none', ...
        'WindowStyle','modal', ...
   	'Tag','STDatamatOptions', ...
   	'ToolBar','none');

   x = 0.05;
   y = 0.23;
   w = 1 - 2*x;
   h = 0.7;

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
   y = 0.8;
   w = 1 - 2*x;
   h = 0.07;

   pos = [x y w h];

   fnt = 0.7;

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
   y = y-.1;
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
             'pet_create_datamat_ui(''PREDEFINE_BRAIN_REGION_BUTTON'');', ...
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
   y = y-.08;
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
   	'Callback','pet_create_datamat_ui(''EDIT_BRAIN_REGION_FILE'');',...
   	'Tag','PredefineRegionFileEdit');

   x = x+w+.02;
   w = 0.16;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Predefine Region File Button
   	'Style','pushbutton', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','Browse', ...
        'Enable','off', ...
   	'Callback', 'pet_create_datamat_ui(''BRAIN_REGION_FILE_BUTTON'');', ...
   	'Tag','PredefineRegionFileButton');

   x = 0.1;
   y = y-.1;
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
   	'Callback','pet_create_datamat_ui(''AUTO_BRAIN_REGION_BUTTON'');', ...
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
   y = y-.08;
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
   	'String','0.25', ...
        'TooltipString','Enter value between 0 and 1.', ...
   	'Callback','pet_create_datamat_ui(''SET_THRESHOLD'');', ...
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
   	'Callback','pet_create_datamat_ui(''CONSIDER_ALL_VOXELS'');', ...
   	'Tag','ConsiderAllVoxels');

   x = 0.1;
   y = y-.12;
   w = 0.39;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Mean Ratio Button
   	'Style','check', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
        'Value', 1, ...
   	'Position',pos, ...
   	'String','Normalize data with volume mean', ...
   	'Callback','pet_create_datamat_ui(''EDIT_NORMAL_VOLUME'');', ...
   	'Tag','MeanRatioChkButton');

   x = x+w+0.02;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Merge Conditions
   	'Style','push', ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Merge Conditions', ...
   	'Callback','pet_create_datamat_ui(''MERGE_CONDITIONS'');',...
   	'Tag','MergeConditions');

   x = 0.05;
   y = 0.1;
   w = 0.4;
   h = 0.07;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% ORIENT Button
   	'Style','pushbutton', ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','Check image orientation', ...
   	'Callback','pet_create_datamat_ui(''ORIENT'');',...
   	'Tag','ORIENTButton');

%   x = 0.25;
   x = 0.5;
   y = 0.1;
%   w = 0.15;
   w = 0.2;
   h = 0.07;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% RUN Button
   	'Style','pushbutton', ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','Create', ...
   	'Callback','pet_create_datamat_ui(''RUN_BUTTON'');',...
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
   	'Callback','pet_create_datamat_ui(''CANCEL_BUTTON'');',...
   	'Tag','CANCELButton');

   x = 0.01;
   y = 0;
   w = 1;
   h = 0.04;

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
   setappdata(h0, 'session_win_hdl',session_win_hdl);
   setappdata(h0,'BrainRegionFile',[]);
   setappdata(h0,'Threshold',0.25);
   setappdata(h0, 'merged_conds', []);

   return;						% init


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
      set(findobj(gcbf,'Tag','AutoRegionThresholdEdit'),'String','0.25');
      setappdata(gcbf,'Threshold',0.25);
   else
      set(findobj(gcbf,'Tag','AutoRegionThresholdEdit'),'Enable','off');
      set(findobj(gcbf,'Tag','AutoRegionThresholdEdit'),'String','0');
      setappdata(gcbf,'Threshold',0);
   end

   return;					% SelectConsiderAllVoxels


%----------------------------------------------------------------------------
function EditBrainRegionFile()

   fname = get(gcbo,'String');
   fname = deblank(fliplr(deblank(fliplr(fname))));

   if isempty(fname)
      setappdata(gcf,'BrainRegionFile',[]);
      return;
   end;

   pathfile = fullfile(pwd, fname);

   if (exist(pathfile,'file') ~= 2)

      pathfile = fname;

      if (exist(pathfile,'file') ~= 2)
         msg = 'ERROR: Invalid file specified.';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         setappdata(gcf,'BrainRegionFile',[]);
         return;
      end
   end;

   %  make sure the IMG file can be accessed.
   %
   try
      dummy = rri_imginfo(pathfile);
   catch 
      msg = 'ERROR: Cannot open the file.  Make sure it is an IMG file.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   set(gcbo,'String',pathfile);
   setappdata(gcf,'BrainRegionFile',pathfile);

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
function nonbrain_coords = find_nonbrain_coords(dataset,coord_thresh,considerall)

   [num_scans num_voxels] = size(dataset);
   nonbrain_coords = zeros(1,num_voxels);

   for i=1:num_scans,
      scan_threshold = double(max(dataset(i,:))) * coord_thresh;

      if considerall
         idx = find(dataset(i,:) < scan_threshold);
      else
         idx = find(dataset(i,:) <= scan_threshold);
      end

      nonbrain_coords(idx) = 1; 
   end

   return;


%----------------------------------------------------------------------------
function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      pet_create_datamat_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'pet_create_datamat_pos');
   catch
   end

   return;					% delete_fig


%----------------------------------------------------------------------------
function status = SaveDatamatOptions()

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

   h = findobj(gcbf,'Tag','MeanRatioChkButton');
   STOptions.NormalizeVolumeMean = get(h,'Value');

   status = 1;
   setappdata(gcf,'STOptions',STOptions);

   return;					% SaveDatamatOptions


%----------------------------------------------------------------------------
function CreateDatamat()

    if exist('plslog.m','file')
       plslog('Create PET Datamat');
    end

    tic;
    options = getappdata(gcf,'STOptions');

    merged_conds = getappdata(gcf, 'merged_conds');
    session_info = getappdata(gcf,'SessionFile');

    if isfield(session_info, 'behavdata')
       behavdata = session_info.behavdata;
    else
       behavdata = [];
    end

    if isfield(session_info, 'behavname')
       behavname = session_info.behavname;
    else
       behavname = {};
    end

    pls_data_path = session_info.pls_data_path;
    num_behavior = session_info.num_behavior;
    datamat_prefix = session_info.datamat_prefix;
    num_conditions = session_info.num_conditions;
    condition = session_info.condition;
    num_subjects = session_info.num_subjects;
    subject = session_info.subject;
    subj_name = session_info.subj_name;
    subj_files = session_info.subj_files;

    k = num_conditions;
    n = num_subjects;
    filename = [datamat_prefix, '_PETsessiondata.mat'];

    use_brain_mask = options.UseBrainRegionFile;
    brain_mask_file = options.BrainRegionFile;

    brain_mask = [];
    mask_dims = [];

    if use_brain_mask
       brain_mask = load_nii(brain_mask_file, 1);
       brain_mask = reshape(int8(brain_mask.img), [brain_mask.hdr.dime.dim(2:3) 1 brain_mask.hdr.dime.dim(4)]);
       mask_dims = size(brain_mask);

       create_datamat_info.brain_mask_file = brain_mask_file;
       create_datamat_info.brain_coord_thresh = [];
    else
       create_datamat_info.brain_mask_file = '';
       create_datamat_info.brain_coord_thresh = options.Threshold;
    end

    coord_thresh = options.Threshold;
    normalize_volume_mean = options.NormalizeVolumeMean;

    create_datamat_info.normalize_volume_mean = normalize_volume_mean;
    create_datamat_info.consider_all_voxels_as_brain = options.ConsiderAllVoxels;

    curr = pwd;
    if isempty(curr)
       curr = filesep;
    end

    savepwd = curr;
    home = curr;	% pls_data_path;

    %  add path for all subject
    %
    for i = 1:k
        for j = 1:n
            subj_files{i,j} = fullfile(subject{j}, subj_files{i,j});
        end
    end

    orient_pattern = getappdata(gcf, 'orient_pattern');

    if isempty(orient_pattern)
       [dims, voxel_size, origin] = rri_imginfo(subj_files{1,1});
    else
       dims = getappdata(gcf, 'dims');
       voxel_size = getappdata(gcf, 'voxel_size');
       origin = getappdata(gcf, 'origin');
    end

    dims = [dims(1) dims(2) 1 dims(3)];

    if (use_brain_mask==1) & ~isequal(dims,mask_dims),
       errmsg ='ERROR: Dimensions of the data do not match that of the brain mask!';
       errordlg(errmsg,'Brain Mask Error');
       waitfor(gcf);
       return;
    end;

    if (use_brain_mask == 1)			% coords from brain_mask
       coords = find( brain_mask(:) > 0)';
       m = zeros(dims);		
       m(coords) = 1;
       coords = find(m == 1)';
    end;

    num_voxels = prod(dims);

    if (use_brain_mask == 0)
       coords = zeros(1, num_voxels);		% initial st_coords
    end

    %  to make progress bar in the center
    %
    fig1 = gcf;
    progress_hdl = rri_progress_ui('initialize', 'Creating Datamat');
    close(fig1);

    section1 = n*k/(n*k+10);		% 1st section of progress bar
    factor = 1/(n*k+10);		% factor for the 2nd section

    rri_progress_ui(progress_hdl, '', 0.5*factor);

    %  make tdatamat, which includes non_brain voxels
    %
    tdatamat=[];
    for i = 1:k

        temp=[];

        for j=1:n

            message=['Loading condition ',num2str(i),', subject ',num2str(j),'.'];
            rri_progress_ui(progress_hdl,'Loading Images',message);

            img = load_nii(subj_files{i,j}, 1);

            v7 = version;
            if str2num(v7(1))<7
               img = reshape(double(img.img), [img.hdr.dime.dim(2:3) 1 img.hdr.dime.dim(4)]);
            else
               img = reshape(single(img.img), [img.hdr.dime.dim(2:3) 1 img.hdr.dime.dim(4)]);
            end

            if ~isempty(orient_pattern)
               img = img(orient_pattern);
            end

%            img = reshape(img,[size(img,1)*size(img,2),size(img,4)]);

            temp = [temp; img(:)'];

            %  find brain voxel coords, and
            %  accumulated to find common coords for all img
            %
            if (use_brain_mask == 0)
               coords = coords + find_nonbrain_coords(img(:)',coord_thresh,options.ConsiderAllVoxels);
            end

        end

        tdatamat=[tdatamat;temp];
        rri_progress_ui(progress_hdl, '', ((i-1)*n+j)*factor);

    end

    message = 'Selecting only the brain voxels ...';
    rri_progress_ui(progress_hdl,'Building datamat',message);

    %  determine the coords of the brain region
    %
    if (use_brain_mask == 0)	% coords from thresh by 'find_nonbrain_coords' 
       coords = find(coords == 0);
    end

    [dr,dc]=size(tdatamat);
    factor = 0.1/dr;			% factor for the 2nd section
    for i=1:dr
        rri_progress_ui(progress_hdl,'',section1+(i*factor)*(1-section1));
    end

    %  remap data to eliminate non-brain voxels
    %
    datamat = tdatamat(:,coords);
%    raw_datamat = datamat;

    [dr,dc]=size(datamat);		% update dr/dc

    if (normalize_volume_mean == 1)

       % perform whole-brain ratio adjustment
       gmean=mean(datamat,2);		% grand mean for each image

       rri_progress_ui(progress_hdl,'Normalizing datamat',section1+0.2*(1-section1));

       message = 'Normalize datamat with its volume mean ...';
       rri_progress_ui(progress_hdl,'',message);

       factor = 0.8/dc;				% factor for the 2nd section
       checkpoint = floor(dc/10);		% set check point
       check = checkpoint;
       percentage = 10;

       for i=1:dc
           datamat(:,i)=(datamat(:,i))./gmean;	% normalized on the mean of each img

           if(i==check)
               rri_progress_ui(progress_hdl,'',section1+(0.2+i*factor)*(1-section1));
               message = [num2str(percentage), '% of the volume is normalized.'];
               rri_progress_ui(progress_hdl,'',message);
               check = check + checkpoint;
               percentage = percentage + 10;
           end
       end

    end

    if ~isempty(merged_conds)
        new_num_conditions = length(merged_conds);
        new_condition = {merged_conds.name};
        [b_dr b_dc] = size(behavdata);

        for i = 1:k
            datamat_cond{i} = datamat((i-1)*n+1:i*n,:);
            datamat_cond{i} = datamat_cond{i}(:)';

            if ~isempty(behavdata)
                behav_cond{i} = behavdata((i-1)*n+1:i*n,:);
                behav_cond{i} = behav_cond{i}(:)';
            end
        end

        clear datamat;

        for i = 1:new_num_conditions
            new_datamat_cond{i} = ...
		mean(cat(1, datamat_cond{merged_conds(i).cond_idx}), 1);
            new_datamat_cond{i} = reshape(new_datamat_cond{i}, [n dc]);

            if ~isempty(behavdata)
                new_behav_cond{i} = ...
			mean(cat(1, behav_cond{merged_conds(i).cond_idx}), 1);
                new_behav_cond{i} = reshape(new_behav_cond{i}, [n b_dc]);
            end
        end

        clear datamat_cond behav_cond;
        datamat = cat(1, new_datamat_cond{:});

        if ~isempty(behavdata)
            behavdata = cat(1, new_behav_cond{:});
            session_info.behavdata = behavdata;
            session_info.num_behavior = size(behavdata,1);
        end

        clear new_datamat_cond new_behav_cond;
        session_info.num_conditions = new_num_conditions;
        session_info.condition = new_condition;

    end

    rri_progress_ui(progress_hdl,'',1);
    message = 'Saving to the disk ...';
    rri_progress_ui(progress_hdl,'Save',message);

%    elapsed_time = toc;
%    disp('Datamat is created ...');

    % save to disk

    datamatfile = fullfile(home, filename);

    if(exist(datamatfile,'file')==2)	% datamat file with the same file name exist

        dlg_title = 'Confirm File Overwrite';
        msg = ['File ',filename,' exist. Are you sure you want to overwrite it?'];
        response = questdlg(msg,dlg_title,'Yes','No','Yes');

        if(strcmp(response,'No'))
           close(progress_hdl);
           msg1 = ['WARNING: Datamat file is not saved.'];
           set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
           return;
        end
    end

    savfig = [];
    if strcmpi(get(gcf,'windowstyle'),'modal')
       savfig = gcf;
       set(gcf,'windowstyle','normal');
    end

    create_ver = plsgui_vernum;
    done = 0;

    v7 = version;
    if str2num(v7(1))<7
%       datamat = double(datamat);
       singleprecision = 0;
    else
       singleprecision = 1;
    end


   [r_mat c_mat] = size(datamat);

   for i = 1:c_mat
      if any(isnan(datamat(:,i)))
         coords(i) = -1;
      end
   end

   datamat(:,find(coords == -1)) = [];
   coords(find(coords == -1)) = [];

    while ~done
       try
          save(datamatfile,'datamat','coords','behavdata','behavname', ...
		'dims','voxel_size','origin','session_info', ...
		'create_ver','create_datamat_info','singleprecision');
          done = 1;
       catch
%          putfile_filter = [datamat_prefix,'_PETsessiondata.mat'];
 %         [datamatfile, status] = prompt_save(putfile_filter, 'Can not save datamat file, please try again', ''', ''PET'',''sessiondata'')', progress_hdl);
  %        if isempty(datamatfile) & status, return; end;
          close(progress_hdl);
          msg1 = ['ERROR: Unable to write datamat file.'];
          set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
          return;
       end
    end

    if ~isempty(savfig)
       set(savfig,'windowstyle','modal');
    end

    cd(savepwd);

    close(progress_hdl);


    [filepath filename] = rri_fileparts(datamatfile);
    set(options.session_win_hdl,'Name',['Session File: ' filename]);


%    msg1 = ['Datamat file "',datamatfile,'" has been created and saved on your hard drive.'];
%    msg2 = ['The total elapse time to build this datamat is ',num2str(elapsed_time),' seconds.'];

%    uiwait(msgbox({msg1;'';msg2},'Completed','modal'));
%%    uiwait(msgbox(msg1,'Completed','modal'));
    %% msgbox({msg1;'';msg2},'Completed');	% however, this works for PC

   msg1 = ['WARNING: Do not change file name manually in command window.'];
   uiwait(msgbox(msg1,'File has been saved'));

%    uiresume;
    return;					% CreateDatamat


%----------------------------------------------------------------------------
function MergeConditions()

   session_info = getappdata(gcf,'SessionFile');

   condition = session_info.condition;
   merged_conds = fmri_merge_condition_ui(condition);
   setappdata(gcf, 'merged_conds', merged_conds);

   return;					% MergeConditions


%----------------------------------------------------------------------------
function orient()

   nii = getappdata(gcf, 'nii');
   orient_pattern = getappdata(gcf, 'orient_pattern');
   session_info = getappdata(gcf,'SessionFile');

   imgfile = fullfile(session_info.subject{1}, session_info.subj_files{1,1});

   [dims, voxel_size, origin, nii, orient_pattern] = ...
	rri_orient_pattern_ui(imgfile, nii, orient_pattern);

   if isempty(nii)
      return;
   end

   setappdata(gcf, 'dims', double(nii.hdr.dime.dim(2:4)));
   setappdata(gcf, 'voxel_size', double(nii.hdr.dime.pixdim(2:4)));
   setappdata(gcf, 'origin', double(nii.hdr.hist.originator(1:3)));
   setappdata(gcf, 'nii', nii);
   setappdata(gcf, 'orient_pattern', orient_pattern);

   return;					% orient

