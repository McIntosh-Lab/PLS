%STRUCT_CREATE_DATAMAT Creates a datamat file
%
%  USAGE: struct_create_datamat({session_file})
%

%   Called by struct_session_profile_ui
%
%   I (session_file) - Matlab data file that contains a structure array
%			containing the session information for the study
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function struct_create_datamat(varargin)

   if nargin == 0 | ~ischar(varargin{1})
      session_file = varargin{1}{1};
      init(session_file);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = varargin{1};

   if strcmp(action,'filename_edit')
      filename_hdl = getappdata(gcf, 'filename_hdl');
      filename = get(filename_hdl, 'string');
      setappdata(gcf,'filename',filename);
   elseif strcmp(action,'create_bn_pressed')
      if (SaveDatamatOptions) 
         CreateDatamat;
      end
   elseif strcmp(action,'EDIT_NORMAL_VOLUME')
      msg = 'Please keep this check box unchecked unless you have a good reason not to do so.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
   elseif strcmp(action,'MERGE_CONDITIONS'),
      MergeConditions;
   elseif strcmp(action,'EDIT_BRAIN_REGION_FILE'),
      EditBrainRegionFile;
   elseif strcmp(action,'BRAIN_REGION_FILE_BUTTON'),
      SelectBrainRegionFile;
   elseif strcmp(action,'ORIENT'),
      orient;
   elseif strcmp(action,'close_bn_pressed')
      close(gcf);
   end

   return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   init: Initialize the GUI layout
%
%   I (session_file) - Matlab data file that contains a structure array
%			containing the session information for the study
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function init(session_file)

   session_win_hdl = gcf;
   session_info = session_file;

   subj_name = session_info.subj_name;
   cond_name = session_info.condition;

   pls_data_path = session_info.pls_data_path;
   filename = [session_info.datamat_prefix, '_STRUCTsessiondata.mat'];
   dataname = [session_info.datamat_prefix, '_STRUCTdata.mat'];

   selected_subjects = ones(1, session_info.num_subjects);	% select all

   h01 = struct_create_modify_ui(0);

   subj_lst_hdl = getappdata(h01,'subj_lst_hdl');
   filename_hdl = getappdata(h01,'filename_hdl');

   set(subj_lst_hdl, 'string', subj_name);
   set(filename_hdl, 'string', filename);

   setappdata(h01,'selected_subjects', selected_subjects);
   setappdata(h01,'filename', filename);
   setappdata(h01,'dataname', dataname);
   setappdata(h01,'session_info', session_info);
   setappdata(h01,'session_file', session_file);
   setappdata(h01,'SessionFile',session_file);
   setappdata(h01,'session_win_hdl',session_win_hdl);

   setappdata(h01,'BrainRegionFile',[]);
   setappdata(h01, 'merged_conds', []);

   set(subj_lst_hdl, 'value',find(selected_subjects), 'list',1);

   return;					% init


%----------------------------------------------------------------------------
function MergeConditions()

   session_info = getappdata(gcf, 'session_info');
   condition = session_info.condition;
   merged_conds = fmri_merge_condition_ui(condition);
   setappdata(gcf, 'merged_conds', merged_conds);

   return;					% MergeConditions


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
      msg = 'ERROR: Cannot open the file.  Make sure it is an IMG or NII file.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   set(gcbo,'String',pathfile);
   setappdata(gcf,'BrainRegionFile',pathfile);

   return;					% EditBrainRegionFile


%----------------------------------------------------------------------------
function SelectBrainRegionFile()

   session_info = getappdata(gcf,'session_info');
   [fname, fpath] = rri_selectfile(['*' session_info.img_ext],'Brain Region Mask');

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
      msg = 'ERROR: Cannot open the file.  Make sure it is an IMG or NII file.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   set(findobj(gcbf,'Tag','PredefineRegionFileEdit'),'String',fname);
   setappdata(gcf,'BrainRegionFile',fname);
   
   return;					% SelectBrainRegionFile


%----------------------------------------------------------------------------
function orient()

   nii = getappdata(gcf, 'nii');
   orient_pattern = getappdata(gcf, 'orient_pattern');
   session_info = getappdata(gcf, 'session_info');
   imgfile = fullfile(session_info.dataset_path, session_info.subj_files{1,1});

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


%----------------------------------------------------------------------------
function status = SaveDatamatOptions()

   status = 0;			% set status to fail first

   STOptions.session_win_hdl = getappdata(gcf,'session_win_hdl');
   STOptions.UseBrainRegionFile = 1;
   STOptions.BrainRegionFile = getappdata(gcf,'BrainRegionFile');

   if isempty(STOptions.BrainRegionFile),
       msg = 'ERROR: Invalid file for the brain region mask.';
       set(findobj(gcf,'Tag','MessageLine'),'String',msg);
       return;
   end;

   STOptions.Threshold = [];
   STOptions.ConsiderAllVoxels = 0;

   h = findobj(gcbf,'Tag','MeanRatioChkButton');
   STOptions.NormalizeVolumeMean = get(h,'Value');

   session_info = getappdata(gcf,'session_info');
   selected_subjects = zeros(1, session_info.num_subjects);
   subj_value = get(getappdata(gcf,'subj_lst_hdl'), 'value');
   selected_subjects(subj_value) = 1;
   STOptions.selected_subjects = selected_subjects;

   status = 1;
   setappdata(gcf,'STOptions',STOptions);

   return;					% SaveDatamatOptions


%----------------------------------------------------------------------------
function CreateDatamat()

    if exist('plslog.m','file')
       plslog('Create STRUCT Datamat');
    end

    tic;
    options = getappdata(gcf,'STOptions');

    merged_conds = getappdata(gcf, 'merged_conds');
%    session_file = getappdata(gcf,'SessionFile');

%    load(session_file);
    session_info = getappdata(gcf,'session_info');

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
    dataset_path = session_info.dataset_path;
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
    filename = [datamat_prefix, '_STRUCTsessiondata.mat'];
    dataname = [datamat_prefix, '_STRUCTdata.mat'];

    selected_subjects = options.selected_subjects;

    use_brain_mask = options.UseBrainRegionFile;
    brain_mask_file = options.BrainRegionFile;

    brain_mask = [];
    mask_dims = [];

    brain_mask = load_nii(brain_mask_file, 1);
    brain_mask = reshape(int8(brain_mask.img), [brain_mask.hdr.dime.dim(2:3) 1 brain_mask.hdr.dime.dim(4)]);
    mask_dims = size(brain_mask);

    if length(mask_dims)==2
       mask_dims = [mask_dims 1 1];
    end

    create_datamat_info.brain_mask_file = brain_mask_file;

    normalize_volume_mean = options.NormalizeVolumeMean;
    create_datamat_info.normalize_volume_mean = normalize_volume_mean;

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
            subj_files{i,j} = fullfile(dataset_path, subj_files{i,j});
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

       if length(coords)/prod(dims) > 0.25
          msg1 = ['This brain mask takes more than 25% of image volume for brain voxels, so it does not seem correct. '];
          msg2 = 'If you intentionally designed this, you can click "Proceed".';
          msg3 = 'Otherwise, please click "Stop", and check the brain mask file.';

          quest = questdlg({msg1 '' msg2 '' msg3 ''}, 'Choose','Proceed','Stop','Stop');

          if strcmp(quest,'Stop')
             return;
          end;
       end;
    end;

    num_voxels = prod(dims);

    %  to make progress bar in the center
    %
    fig1 = gcf;
    progress_hdl = rri_progress_ui('initialize', 'Creating Datamat');
    close(fig1);

    section1 = n*k/(n*k+0);		% 1st section of progress bar
    factor = 1/(n*k+0);		% factor for the 2nd section

    rri_progress_ui(progress_hdl, '', 0.5*factor);


    sugg3=0;			% suggestion3 doesn't work here

    %  make datamat, which includes non_brain voxels
    %
if sugg3	
    try
       if str2num(v7(1))<7
          datamat=double(zeros(n*k,length(coords)));
       else
          datamat=single(zeros(n*k,length(coords)));
       end
    catch
       close(progress_hdl);
       errmsg = ['ERROR: there is too much data, please delete some subjects in the "Edit Subject" window by clicking "Select Subjects" button in the session information window.'];
       errordlg(errmsg,'Too much data');
       waitfor(gcf);
       return;
    end
else
    datamat=[];
end

    for i = 1:k

if ~sugg3
        temp=[];
end

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

            try
               img = img(coords)';
if sugg3
               datamat(((i-1)*n+j),:) = img(:)';
else
               temp = [temp; img(:)'];
end
            catch
               close(progress_hdl);
               errmsg = ['ERROR: there is too much data after condition ' num2str(i) ' at subject ' num2str(j) ', please delete some subjects in the "Edit Subject" window by clicking "Select Subjects" button in the session information window.'];
               errordlg(errmsg,'Too much data');
               waitfor(gcf);
               return;
            end

        end

if ~sugg3
        datamat=[datamat;temp];
end
        rri_progress_ui(progress_hdl, '', ((i-1)*n+j)*factor);

    end

    message = 'Selecting only the brain voxels ...';
    rri_progress_ui(progress_hdl,'Building datamat',message);

    [dr,dc]=size(datamat);

    factor = 0.1/dr;			% factor for the 2nd section
    for i=1:dr
        rri_progress_ui(progress_hdl,'',section1+(i*factor)*(1-section1));
    end

    %  Check zero variance voxels & NaN voxels, and remove them from coords
    %
    try
       check_var = var(datamat);
    catch
       close(progress_hdl);
       errmsg = ['ERROR: there is too much data to check zero variance, please delete some subjects in the "Edit Subject" window by clicking "Select Subjects" button in the session information window.'];
       errordlg(errmsg,'Too much data');
       waitfor(gcf);
       return;
    end

    bad_coords = find( (check_var==0) | isnan(check_var) );
    coords(bad_coords) = [];
    datamat(:,bad_coords) = [];

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
    datafile = fullfile(home, dataname);

   %  check if exist data file
   %
   if(exist(datafile,'file')==2)  % data file with same filename exist
      dlg_title = 'Confirm File Overwrite';
      msg = ['File ',dataname,' exist. Are you sure you want to overwrite it?'];
      response = questdlg(msg,dlg_title,'Yes','No','Yes');

      if(strcmp(response,'No'))
           close(progress_hdl);
           msg1 = ['WARNING: Data file is not saved.'];
           set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
           return;
      end
   end

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

   %  save data file
   %
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
          save(datafile,'datamat','create_ver');
          done = 1;
       catch
          close(progress_hdl);
          msg1 = ['ERROR: Unable to write data file.'];
          set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
          return;
       end
    end

   %  save datamat file
   %
    done = 0;

    while ~done
       try
          save(datamatfile,'datafile','coords','behavdata','behavname', ...
		'bad_coords', 'selected_subjects', ...
		'dims','voxel_size','origin','session_info', ...
		'create_ver','create_datamat_info','singleprecision');
          done = 1;
       catch
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

