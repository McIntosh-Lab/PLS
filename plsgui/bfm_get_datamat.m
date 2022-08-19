%BFM_GET_DATAMAT will create the Event Related or Blocked fMRI datamat
%
%	Usage: bfm_get_datamat(sessionFile, run_idx, brain_mask, ...
%		sd_thresh, ignore_slices, normalize_volume_mean, ...
%		num_skipped_scans, merge_across_runs_flg, ...
%		behavdata, behavname)
%
%   Input: 
%       sessionFile:  the name of file that contains the session information.
%       brain_mask:  a matrix, with same size as the IMG files, defines the
%                   brain region.  Any element larger than 0 is treated as
%                   part of the brain region.
%       coord_thresh: threshold to generate compute the brain region 
%                    [default: 0.15];
%       ignored_slices: a vector specifies the number of slices which should
%       (optional) be skipped to generate the datamat. [default: []]
%       num_skipped_scans:  (optional) [default: num_skipped_scans = 0]
%       run_idx:   (optional) [default: run_idx contains all the runs]
%		  The indices of runs that will be used to generate st_datamat.
%       merge_across_runs_flg:  1 - merge the same condition across all runs
%       (optional)                  to become one row of the ST datamat
%                              0 - merge the same condition only within a run
%                  	       [default: merge_across_runs_flg = 1]
%
%	See also FMRI_GEN_DATAMAT, FMRI_GEN_ST_DATAMAT

% 'floor' chnaged to 'round' on line 311 329 331

%
%	the following paramater is removed:
%
%       sd_thresh: maximum standard deviation (s.d.) for the brain voxels. Any
%       (optional) voxels with s.d. greater than this value will be removed to
%                 avoid the inclusion of venous and sinus. [default: 2];
%

%	called by FMRI_CREATE_DATAMAT_UI
%
%   Modified on 12-May-2003 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bfm_get_datamat(sessionFile, run_idx, varargin)

   progress_hdl = rri_progress_ui('initialize');
   brain_mask_file = '';
   brain_mask = [];
   coord_thresh = [];
   sd_thresh = 2;
   ignore_slices = [];
   normalize_volume_mean = 0;
   num_skipped_scans = 0;
   for_batch = 0;

   mask_dims = [];

   if (nargin == 2),
      use_brain_mask = 0;
   elseif (nargin >= 2),
      if  (ischar(varargin{1})) ,	% use predefined brain region
          use_brain_mask = 1;
          brain_mask_file = varargin{1};
          brain_mask = load_nii(brain_mask_file, 1);
          brain_mask = reshape(int8(brain_mask.img), [brain_mask.hdr.dime.dim(2:3) 1 brain_mask.hdr.dime.dim(4)]);
          mask_dims = size(brain_mask);
      else
          use_brain_mask = 0;		% compute brain region from the data
          coord_thresh = varargin{1};
      end;
   
      if (nargin >= 4)
         sd_thresh = varargin{2};
      end;
   
      if (nargin >= 5)
         ignore_slices = varargin{3};
      end;

      if (nargin >= 6)
         normalize_volume_mean = varargin{4};
      end;

      if (nargin >= 7)
         num_skipped_scans = varargin{5};
      end;

      if (nargin >= 8)
         merge_across_runs_flg = varargin{6};
      end;

      if (nargin >= 9)
         behavdata = varargin{7};
      end;

      if (nargin >= 10)
         behavname = varargin{8};
      end;

      if (nargin >= 11)
         session_win_hdl = varargin{9};
      end;

      if (nargin >= 12)
         normalize_signal_mean = varargin{10};
      end;

      if (nargin >= 13)
         ConsiderAllVoxels = varargin{11};
      end;

      if (nargin >= 14)
         SingleSubject = varargin{12};
      end;

      if (nargin >= 15)
         SingleRefScanButton = varargin{13};
         orient = varargin{14};
      end;

      if (nargin >= 16)
         SingleRefScanOnset = varargin{14};
      end;

      if (nargin >= 17)
         SingleRefScanNumber = varargin{15};
      end;

      if (nargin >= 18)
         orient = varargin{16};
      end;

      if (nargin >= 19)
         for_batch = varargin{17};
      end;

   end

   create_datamat_info.brain_mask_file = brain_mask_file;
   create_datamat_info.brain_coord_thresh = coord_thresh;
   create_datamat_info.consider_all_voxels_as_brain = ConsiderAllVoxels;
%   create_datamat_info.num_skipped_scans = num_skipped_scans;
%   create_datamat_info.run_idx = run_idx;
%   create_datamat_info.ignore_slices = ignore_slices;
   create_datamat_info.normalize_volume_mean = normalize_volume_mean;
   create_datamat_info.normalize_with_baseline = normalize_signal_mean;
   create_datamat_info.merge_across_runs = merge_across_runs_flg;
   create_datamat_info.single_subject_analysis = SingleSubject;
   create_datamat_info.single_reference_scan = SingleRefScanButton;

   if SingleRefScanButton
      create_datamat_info.single_reference_scan_onset = SingleRefScanOnset;
      create_datamat_info.single_reference_scan_number = SingleRefScanNumber;
   end

   session_info = sessionFile;

   pls_data_path = session_info.pls_data_path;
   datamat_prefix = session_info.datamat_prefix;

   %  save temp data into datamat_file
   %
%   fname = sprintf('%s_run.mat',datamat_prefix);
%   datamat_file = fullfile(pls_data_path,fname);

      curr = pwd;
      if isempty(curr)
         curr = filesep;
      end


   %  get stuff from session_info first
   %
   cond_baseline = session_info.condition_baseline0;
   num_conds = session_info.num_conditions0;	% original cond
   num_conds1 = session_info.num_conditions;	% cond with run

   % get maximum number of onsets
   %
   max_onsets = 0;

   for i = run_idx
      run_info = session_info.run(i);
      tmp = find_max_onsets(run_info);

      if tmp > max_onsets
         max_onsets = tmp;
      end
   end

   %  get image files path/file name <for read only one image file>
   %
   data_path = run_info.data_path;
   flist = run_info.data_files;

   [p fn]=rri_fileparts(flist{1});
   img_file = fullfile(data_path,fn);

   if ~isempty(orient) & ~isempty(orient.orient_pattern)
       dims = orient.dims;
       voxel_size = orient.voxel_size;
       origin = orient.origin;
   else
      [dims,voxel_size,origin] = rri_imginfo(img_file);
   end

   dims = [dims(1) dims(2) 1 dims(3)];

   if (use_brain_mask==1) & ~isequal(dims,mask_dims),
       close(progress_hdl);
       errmsg ='ERROR: Dimensions of the data do not match that of the brain mask!';
       errordlg(errmsg,'Brain Mask Error');
       waitfor(gcf);
       return;
   end;

   %  runs included
   %
   num_runs = session_info.num_runs;
   if ~exist('run_idx','var') | isempty(run_idx),
      run_idx = [1:num_runs];
   else
      num_runs = length(run_idx);
   end;

   %  default is merge_across_runs
   %
   if ~exist('merge_across_runs_flg','var') | isempty(merge_across_runs_flg),
      merge_across_runs_flg = 1;
   end;

   %  skipped scans handling
   %
   if ~exist('num_skipped_scans','var') | isempty(num_skipped_scans)
      num_skipped_scans = 0;
   end;

   %  ignored slices handling
   %
   if ~exist('ignore_slices','var') | isempty(ignore_slices)
      s_idx = [1:dims(4)];			% handle all slices
   else
      idx = zeros(1,dims(4));
      idx(ignore_slices) = 1;
      s_idx = find(s_idx == 0);
   end;

   if (use_brain_mask == 1)			% coords from brain_mask
      coords = find( brain_mask(:) > 0)';
      if ~isempty(ignore_slices)		% skip the slices if any
         m = zeros(dims);		
         m(coords) = 1;
         m(:,:,:,s_idx);
         coords = find(m == 1)';
      end;
   end;

   num_voxels = prod(dims);
   num_cols = num_voxels;

   if (use_brain_mask == 0)
      coords = zeros(1, num_voxels);		% initial st_coords
   end

   datamat = [];				% st datamat before coords
   st_datamat = [];				% st datamat
   st_evt_list = [];
   st_evt_cnt = [];

   % create step for progress bar
   %
   progress_step = 1 / (num_runs * num_conds * max_onsets);

   for i = run_idx

      run_info = session_info.run(i);

      if isfield(run_info,'num_scans_skipped')
         num_skipped_scans = run_info.num_scans_skipped;
      else
         num_skipped_scans = 0;
      end

      %  get image files path/file name
      %
      data_path = run_info.data_path;
      flist = run_info.data_files;
      num_files = length(flist);

      if num_files==1
         [p fn]=rri_fileparts(flist{1});
         img_file = fullfile(data_path,fn);
         num_files = get_nii_frame(img_file);
      end

      for j = 1:num_conds

         num_onsets = length(run_info.blk_onsets{j});

         %  extract the datamat scans that matches the current condition
         %
         row_idx = 0;
         num_onsets = length(run_info.blk_onsets{j});

         if SingleSubject
            evt_datamat = [];
         else
            evt_datamat = zeros(1,num_cols);
         end

         rri_progress_ui(progress_hdl, '', ...
            sprintf('Creating datamat for run#%d condition#%d ... ',i,j));

         for k = 1:num_onsets

            blk_size = run_info.blk_length{j}(k);
            start_scan = round(run_info.blk_onsets{j}(k) - num_skipped_scans) + 1;
            end_scan = start_scan + blk_size - 1;

            if SingleRefScanButton
               baseline_start = SingleRefScanOnset+1;
               baseline_end = baseline_start+SingleRefScanNumber-1;
            else
               if isempty(cond_baseline)
                  baseline_start = start_scan;
                  baseline_end = baseline_start;
               else
                  baseline_info = cond_baseline{j};
                  baseline_start = start_scan + baseline_info(1);
                  baseline_end = baseline_start+baseline_info(2)-1;
               end;
            end

            if (start_scan <= 0) | (num_files < end_scan)	% out of bound
                disp(sprintf('Scans %03d for the condition %d of run%d are not included due to out of bound', round(run_info.blk_onsets{j}(k)), j, run_idx(i)));
            elseif (baseline_start <= 0)
                disp(sprintf('Scans %03d for the condition %d of run%d are not included due to out of bound baseline', round(run_info.blk_onsets{j}(k)), j, run_idx(i)));
            else

               %  read in image files
               %
               dataset = zeros(length([start_scan:end_scan]), num_voxels);

               for scan = start_scan:end_scan
                  if length(flist)>1
                     img_file = fullfile(data_path, flist{scan});
                     img = load_nii(img_file);
                  else
                     [p fn]=rri_fileparts(flist{1});
                     img_file = fullfile(data_path, fn);
                     img = load_nii(img_file, scan);
                  end

                  v7 = version;
                  if str2num(v7(1))<7
                     img = reshape(double(img.img), [img.hdr.dime.dim(2:3) 1 img.hdr.dime.dim(4)]);
                  else
                     img = reshape(single(img.img), [img.hdr.dime.dim(2:3) 1 img.hdr.dime.dim(4)]);
                  end

                  if ~isempty(orient) & ~isempty(orient.orient_pattern)
                     img = img(orient.orient_pattern);
                     img = reshape(img,dims);
                  end

                  img = img(:,:,:,s_idx);
                  dataset(scan - start_scan + 1,:) = img(:)';
               end;

               tmp_datamat = dataset;

               %  find brain voxel coords for each onset, and
               %  accumulated to find common coords for all onsets
               %
               if (use_brain_mask == 0)
                  coords = coords + find_onset_coords(dataset,coord_thresh,ConsiderAllVoxels);
               end

               if (normalize_volume_mean == 1)
                  if (use_brain_mask == 0)
                     mean_dataset = dataset(:,find(coords == 0));
                  else
                     mean_dataset = dataset(:,coords);
                  end

                  mean_dataset = mean(mean_dataset, 2);
                  mean_dataset = mean_dataset(:,ones(1,num_voxels));
                  dataset = dataset ./ mean_dataset;
               end

               tmp_datamat = mean(dataset,1);

               %  read in baseline_signals image files
               %
               dataset = zeros(length([baseline_start:baseline_end]), num_voxels);

               for scan = baseline_start:baseline_end
                  if length(flist)>1
                     img_file = fullfile(data_path, flist{scan});
                     img = load_nii(img_file);
                  else
                     [p fn]=rri_fileparts(flist{1});
                     img_file = fullfile(data_path, fn);
                     img = load_nii(img_file, scan);
                  end

                  img = reshape(double(img.img), [img.hdr.dime.dim(2:3) 1 img.hdr.dime.dim(4)]);

                  if ~isempty(orient) & ~isempty(orient.orient_pattern)
                     img = img(orient.orient_pattern);
                     img = reshape(img,dims);
                  end

                  img = img(:,:,:,s_idx);
                  dataset(scan - baseline_start + 1,:) = img(:)';
               end;

               %  this is not a duplicate of normalize_volume_mean,
               %  it is doing for baseline dataset
               %
               if (normalize_volume_mean == 1)
                  if (use_brain_mask == 0)
                     mean_dataset = dataset(:,find(coords == 0));
                  else
                     mean_dataset = dataset(:,coords);
                  end

                  mean_dataset = mean(mean_dataset, 2);
                  mean_dataset = mean_dataset(:,ones(1,num_voxels));
                  dataset = dataset ./ mean_dataset;
               end

               baseline_signals = mean(dataset,1);

               %  repmat for win_size of rows
               %
%               baseline_signals = baseline_signals(ones(1,win_size),:);

               %  if 0, make it less significant, so it can be removed later
               %
		zero_baseline_idx = find(baseline_signals==0);
               baseline_signals(zero_baseline_idx) = 99999;

               if normalize_signal_mean
                  tmp_datamat = ...
                     (tmp_datamat - baseline_signals ) * 100 ./ baseline_signals;
               end

		tmp_datamat(zero_baseline_idx) = 0; %99999

               row_idx = row_idx + 1;

               if SingleSubject
                  evt_datamat = [evt_datamat; single(tmp_datamat)];
               else
                  evt_datamat = single(double(evt_datamat) + tmp_datamat);
               end

               stp = (i-1)*num_conds*max_onsets + (j-1)*max_onsets + k;
               rri_progress_ui(progress_hdl, '', stp * progress_step);

            end;
         end;				% for num_onsets

         if (merge_across_runs_flg == 0 & row_idx == 0),
            close(progress_hdl);
            errmsg = sprintf('No onsets for condition #%d in the run #%d',j,i);
            errordlg(['ERROR: ' errmsg],'Generating ST Datamat Error');
            waitfor(gcf);
            return;
         end;

         %  Generate the spatial/temporal datamat from evt_datamat
         %  depending on 'across run' or 'within run'
         %
         if (row_idx ~= 0),		% some stimuli for the current condition

            if (merge_across_runs_flg == 0)	% merge data within run only
               if SingleSubject
%                  st_evt_list = [st_evt_list j*ones(1, size(evt_datamat,1))];
                  st_evt_list = [st_evt_list ((i-1)*num_conds+j)*ones(1, size(evt_datamat,1))];
                  datamat = [datamat; evt_datamat];
               else
%                  st_evt_list = [st_evt_list j];
                  st_evt_list = [st_evt_list (i-1)*num_conds+j];
                  datamat = [datamat; single(double(evt_datamat) / num_onsets)];
               end
            else
               if isempty(st_evt_list) 
                  idx = [];
               else
                  idx = find(st_evt_list == j);
               end;

               if isempty(idx),			% new event
                  st_evt_list = [st_evt_list j];
                  st_evt_cnt = [st_evt_cnt row_idx];

		  %  init
		  %
                  if SingleSubject
                     datamat = [datamat; {evt_datamat(:)'}];
                  else
                     datamat = [datamat; evt_datamat];
                  end
               else
                  st_evt_cnt(idx) = st_evt_cnt(idx) + row_idx;	% merge

		  %  merge data across runs
		  %
                  if SingleSubject
                     datamat{idx} = double(datamat{idx}) + double(evt_datamat(:)');
                  else
                     datamat(idx,:) = double(datamat(idx,:)) + double(evt_datamat);
                  end
               end;
            end;	% if across_run==0
         end;		% for (row_idx~=0)

      end;		% for num_conds

      %  save some memory usage
      %
      clear('tmp_datamat');

   end;			% for num_runs (run_idx)

   rri_progress_ui(progress_hdl,'','Postprocessing to shape the datamat, please wait ...');

   %    determine the coords of the brain region
   %
   if (use_brain_mask == 0)	% coords from thresh by 'find_onset_coords' 

      coords = find(coords == 0);

   end

   if (merge_across_runs_flg == 1) & SingleSubject	% merge across all runs 
      single_datamat = [];
      single_evt_list = [];		% tmp variable for st_evt_list

      for j=1:length(st_evt_list)
         tmp = double(datamat{j}) / num_runs;
         SingleSubject_rows = length(tmp)/num_cols;
         tmp = reshape(tmp, [SingleSubject_rows num_cols]);
         single_datamat = [single_datamat; single(tmp)];
         single_evt_list = [single_evt_list; repmat(st_evt_list(j), [SingleSubject_rows 1])];
      end;

      datamat = single_datamat;
      clear single_datamat;

      st_evt_list = single_evt_list; % repmat(st_evt_list, [SingleSubject_rows 1]);
      st_evt_list = st_evt_list(:)';
   end;

   %    apply the coords of the brain region
   %
if 0
   for i = 1:size(datamat,1)
      tmp = datamat(i,:);
%      tmp = reshape(tmp, [win_size, num_voxels]);

      tmp = tmp(:, coords);
%      tmp = reshape(tmp, [1, win_size*length(coords)]);
      st_datamat = [st_datamat; tmp];
   end
end

   st_datamat = datamat(:, coords);

   if (merge_across_runs_flg == 1) & ~SingleSubject	% merge across all runs 
      for j=1:length(st_evt_list)
         st_datamat(j,:) = single(double(st_datamat(j,:)) / st_evt_cnt(j));
      end;
   end;

%   [new_evt_list, order_idx] = reorder_evt_list(st_evt_list,num_conds);
   if 0 % isempty(new_evt_list),
      close(progress_hdl);
      errmsg = sprintf('ERROR: Some conditions have no trials at all.\n');
      errordlg(errmsg,'Creating ST Datamat Error');
      waitfor(gcf);
      return;
   end;

%   st_datamat = st_datamat(order_idx,:);
 %  st_evt_list = new_evt_list;

   [st_evt_list, idx] = sort(st_evt_list);
   st_datamat = st_datamat(idx,:);

   %  everything is done, ready to save the information
   %
   st_dims = dims;
   st_voxel_size = voxel_size;
   st_origin = origin;
   st_coords = coords;
   st_win_size = 1;	% win_size;


   fname = sprintf('%s_BfMRIsessiondata.mat',datamat_prefix);
   st_datafile = fullfile(curr,fname);

   rri_progress_ui(progress_hdl,'',1);
   rri_progress_ui(progress_hdl,'',['Saving ST Datamat into the file: ' fname]);

   if(exist(st_datafile,'file')==2)  % datamat file with same filename exist
if ~for_batch

      dlg_title = 'Confirm File Overwrite';
      msg = ['File ',fname,' exist. Are you sure you want to overwrite it?'];
      response = questdlg(msg,dlg_title,'Yes','No','Yes');

      if(strcmp(response,'No'))
           close(progress_hdl);
           msg1 = ['WARNING: Datamat file is not saved.'];
           set(findobj(session_win_hdl,'Tag','MessageLine'),'String',msg1);
           return;
      end
else
      disp(['WARNING: File ',fname,' is overwritten.']);
end
   end

   create_ver = plsgui_vernum;

   savfig = [];
   if strcmpi(get(gcf,'windowstyle'),'modal')
      savfig = gcf;
      set(gcf,'windowstyle','normal');
   end

   done = 0;

   v7 = version;
   if str2num(v7(1))<7
      st_datamat = double(st_datamat);
      singleprecision = 0;
   else
      singleprecision = 1;
   end


   [r_mat c_mat] = size(st_datamat);

   for i = 1:c_mat
      if any(isnan(st_datamat(:,i)))
         st_coords(i) = -1;
      end
   end

   st_datamat(:,find(st_coords == -1)) = [];
   st_coords(find(st_coords == -1)) = [];


   %  num_subj_cond for single subj analysis
   %
   unequal_subj = 0;
   num_subj_cond = [];

   if SingleSubject
      single_evt_list = unique(st_evt_list);
      old_num_subj = [];

      for i = single_evt_list
         num_subj = length(find(st_evt_list==i));

         if ~isempty(old_num_subj) & old_num_subj ~= num_subj
            unequal_subj = 1;
         end

         old_num_subj = num_subj;
         num_subj_cond = [num_subj_cond num_subj];
      end
   else
      num_subj_cond = ones(1, num_conds1);
   end


   while ~done
      try
         save(st_datafile,'st_datamat','st_coords','st_dims','st_voxel_size', ...
                'st_origin','st_evt_list', 'st_win_size','session_info', ...
		'normalize_volume_mean','behavdata','behavname','create_ver', ...
		'create_datamat_info','SingleSubject','singleprecision','unequal_subj','num_subj_cond');
         done = 1;
      catch
          close(progress_hdl);
          msg1 = ['ERROR: Unable to write datamat file.'];
          set(findobj(session_win_hdl,'Tag','MessageLine'),'String',msg1);
          return;
      end
   end

   if ~isempty(savfig)
      set(savfig,'windowstyle','modal');
   end

   close(progress_hdl);

   [filepath filename] = rri_fileparts(st_datafile);
   set(session_win_hdl,'Name',['Session File: ' filename]);

   set(findobj(session_win_hdl,'Tag','MessageLine'),'String','');
   msg1 = ['WARNING: Do not change file name manually in command window.'];

   if ~for_batch
      uiwait(msgbox(msg1,'File has been saved'));
   end

   return;


   %    determine the coords of the brain region
   %
   if (use_brain_mask == 0)		% compute coords from (temp) datamat
      coords = rri_make_coords(datamat, 1/coord_thresh);
      datamat = datamat(:,coords);

      %  get rid of voxels that have standard deviation "sd_thresh" times larger 
      %  than the grand average standard deviation.
      %
      std_d = std(datamat);
      thresh = mean(std_d) * sd_thresh;
      idx = find(std_d < thresh);
      coords = coords(idx);
   else
      coords = find( brain_mask(:) > 0)';
      if ~isempty(ignore_slices)	% skip the slices if any
         m = zeros(dims);		
         m(coords) = 1;
         m(:,:,:,s_idx);
         coords = find(m == 1)';
      end;
   end;

   %    apply the coords of the brain region
   %
   for j = 1:num_conds
      num_onsets = length(run_info.blk_onsets{j});
      for k = 1:num_onsets
         tmp_datamat{j,k} = tmp_datamat{j,k}(:,coords);
         baseline_signals{j,k} = baseline_signals{j,k}(:,coords);

         if (normalize_volume_mean == 1),
            num_voxels = length(coords);

            mean_tmp_datamat = mean(tmp_datamat{j,k},2);
            tmp_datamat{j,k} = tmp_datamat{j,k} ./ ...
		mean_tmp_datamat(:,ones(1,num_voxels));

            mean_baseline_signals = mean(baseline_signals{j,k},2);
            baseline_signals{j,k} = baseline_signals{j,k} ./ ...
		mean_baseline_signals(:,ones(1,num_voxels));
         end;
      end;
   end;

   ShowProgress(progress_hdl, (num_conds * max_onsets + 1) * progress_step);

   %  save the datamat, which is a matrix contains only the brain voxels.
   %
   ShowProgress(progress_hdl,['Saving datamat into the file: ' fname ]);

   try 
      save(datamat_file,'tmp_datamat','baseline_signals','coords', ...
	'dims','voxel_size','origin','session_info','normalize_volume_mean');
   catch
      errmsg = sprintf('ERROR: Cannot save datamat to file: \n   %s.', ...
                       datamat_file);
      errordlg(errmsg,'Save Datamat Error');
      waitfor(gcf);
      return;
   end

   return;						% bfm_get_datamat


%-------------------------------------------------------------------------
function [new_evt_list,reorder_idx] = reorder_evt_list(evt_list,num_conditions)
%  make sure the row order of the st_datamat is repeat order of
%  conditions, i.e cond#1, cond#2,... cond#1, cond#2, .... etc
%

  num_rep = length(evt_list) / num_conditions;

  [new_evt_list, reorder_idx] = sort(evt_list);
  if ~isequal(reshape(new_evt_list,[num_rep,num_conditions]), ...
             repmat([1:num_conditions],num_rep,1))
     new_evt_list = [];
     reorder_idx = [];
  end;

  return;					% reorder evt_list


%-------------------------------------------------------------------------
function hdl = ShowProgress(progress_hdl,info)

  %  'initialize' - return progress handle if any
  %
  if ischar(progress_hdl) & strcmp(lower(progress_hdl),'initialize'),
     if ~isempty(gcf) & isequal(get(gcf,'Tag'),'ProgressFigure'),
         hdl = gcf;
     else
         hdl = [];
     end;
     return;
  end;


  if ~isempty(progress_hdl)
      if ischar(info)
         rri_progress_status(progress_hdl,'Show_message',info);
      else
         rri_progress_status(progress_hdl,'Update_bar',info);
      end;
      return;
  end;

  if ischar(info),
     disp(info)
  end;

  return;					% ShowProgress


%-------------------------------------------------------------------------
function hdl = ShowProgress2(progress_hdl,info)

  %  'initialize' - return progress handle if any
  %
  if ischar(progress_hdl) & strcmp(lower(progress_hdl),'initialize'),
     if ~isempty(gcf) & isequal(get(gcf,'Tag'),'ProgressFigure'),
         hdl = gcf;
     else
         hdl = [];
     end;
     return;
  end;

  if ~isempty(progress_hdl)
     if ischar(info)
         rri_progress_status(progress_hdl,'Show_message',info);
     else
         rri_progress_status(progress_hdl,'Update_bar',info);
     end;
     return;
  end;

  if ischar(info),
     disp(info)
  end;

  return;					% ShowProgress


%----------------------------------------------------------------------------
%
%  get the maximum number of onsets within a run
%
%----------------------------------------------------------------------------

function max_onsets = find_max_onsets(run_info)

   num_cond = length(run_info.blk_onsets);
   max_onsets = 0;

   for i = 1:num_cond
      if length(run_info.blk_onsets{i}) > max_onsets
         max_onsets = length(run_info.blk_onsets{i});
      end;
   end;

   return;						% find_max_onsets


%----------------------------------------------------------------------------
%
%  find brain voxel coords for each onset, and return onset_coords array
%
%	1:	represents non_brain voxels
%	0:	represents brain voxels
%
%----------------------------------------------------------------------------

function nonbrain_coords = find_onset_coords(dataset,coord_thresh,considerall)

   [num_scans num_voxels] = size(dataset);
   nonbrain_coords = zeros(1,num_voxels);

   for i=1:num_scans,
      scan_threshold = max(dataset(i,:)) * coord_thresh;

      if considerall
         idx = find(dataset(i,:) < scan_threshold);
      else
         idx = find(dataset(i,:) <= scan_threshold);
      end

      nonbrain_coords(idx) = 1; 
   end

   return;

