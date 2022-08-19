
% num_skipped_scans has already been handled in "bfm_hrf_create_datamat_ui.m"

function bfm_hrf_get_datamat(sessionFile, run_idx, varargin)

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
          brain_mask = int8(brain_mask.img);
          mask_dims = size(brain_mask);
      else
          use_brain_mask = 0;		% compute brain region from the data
          coord_thresh = varargin{1};
      end;
   
      if (nargin >= 4)
         sd_thresh = varargin{2};
      end;
   
      if (nargin >= 5)
%         ignore_slices = varargin{3};
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
         use_reml = varargin{10};
      end;

      if (nargin >= 13)
         ConsiderAllVoxels = varargin{11};
      end;

      if (nargin >= 14)
         SingleSubject = varargin{12};
      end;

      if (nargin >= 15)
         Legendre = varargin{13};
      end;

      if (nargin >= 16)
         TR = varargin{14};
      end;

      if (nargin >= 17)
         HRF = varargin{15};
      end;

      if (nargin >= 18)
         Design_Matrix = varargin{16};
      end;

      if (nargin >= 19)
         orient = varargin{17};
      end;

      if (nargin >= 20)
         for_batch = varargin{18};
      end;

   end

   create_datamat_info.brain_mask_file = brain_mask_file;
   create_datamat_info.brain_coord_thresh = coord_thresh;
   create_datamat_info.consider_all_voxels_as_brain = ConsiderAllVoxels;
%   create_datamat_info.num_skipped_scans = num_skipped_scans;
%   create_datamat_info.run_idx = run_idx;
%   create_datamat_info.ignore_slices = ignore_slices;
   create_datamat_info.normalize_volume_mean = normalize_volume_mean;
   create_datamat_info.Use_SPM_ReML = use_reml;
   create_datamat_info.merge_across_runs = merge_across_runs_flg;

   if isempty(orient)
      create_datamat_info.isreorient = 0;
   else
      create_datamat_info.isreorient = ~isempty(orient.orient_pattern);
   end

   create_datamat_info.Legendre = Legendre;
   create_datamat_info.TR = TR;
   create_datamat_info.HRF = HRF;
   create_datamat_info.Design_Matrix = Design_Matrix;

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


   %  This block is added to check scan not included due to out of bound.
   %  The same way as fMRI & BfMRI did.
   %
   for i = run_idx
      run_info = session_info.run(i);
      num_files = run_info.num_scans;

      for j = 1:num_conds
         num_onsets = length(run_info.evt_onsets{j});

         for k = 1:num_onsets

            %  the followings are bit different from fmri & bfmri
            %        compare carefully
            %
            start_scan = run_info.evt_onsets{j}(k) - run_info.num_scans_skipped;

            if (start_scan < 0) | (start_scan > num_files-1)
               disp(sprintf('Scans %03d for the condition %d of run%d are not included due to out of bound', round(run_info.evt_onsets{j}(k)), j, run_idx(i)));
            end
         end
      end
   end


   %  get image files path/file name <for read only one image file>
   %
   run_info = session_info.run(1);
   data_path = run_info.data_path;
   flist = run_info.data_files;
   img_file = fullfile(data_path, flist{1});

   if (use_brain_mask == 1)			% coords from brain_mask
      st_coords = find( brain_mask(:) > 0)';
   end;

   if ~isempty(orient) & ~isempty(orient.orient_pattern)
       dims = orient.dims;
       voxel_size = orient.voxel_size;
       origin = orient.origin;

       %  same reason as "hrf_inv_xform", since we'll mask "untouch" not mask "regular"
       %
       if (use_brain_mask==1)
          [tmp inv_pattern] = sort(orient.orient_pattern);
          brain_mask = brain_mask(inv_pattern);
          brain_mask = reshape(brain_mask, dims);
       end
   else
      [dims,voxel_size,origin] = rri_imginfo(img_file);
   end

   % compare with either re-oriented scan (above if) or no reorient (above else)
   % and mask does not involve those re-orient anyway.
   % however, both dims are after xform, i.e. not the untouched version
   % we can also use "hrf_inv_xform" for that

   if (use_brain_mask==1) & ~isequal(dims,mask_dims),
       close(progress_hdl);
       errmsg ='ERROR: Dimensions of the data do not match that of the brain mask!';
       errordlg(errmsg,'Brain Mask Error');
       waitfor(gcf);
       return;
   end;

   nii1 = hrf_load_untouch1_nii(img_file,1);
   num_slices = nii1.hdr.dime.dim(4);		% num_slices in untouch img

   if (use_brain_mask==1)
      brain_mask = hrf_inv_xform(brain_mask, nii1.hdr);
   else
      brain_mask = zeros(dims);
      brain_mask = hrf_inv_xform(brain_mask, nii1.hdr);
   end

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

   num_voxels = prod(dims);
   num_cols = num_voxels;

   if (use_brain_mask == 0)
      thresh_coords = zeros(1, num_voxels);
   end

%   datamat = [];				% st datamat before coords
%   st_datamat = [];				% st datamat
   st_evt_list = [];
   st_evt_cnt = [];

   v7 = version;
   if str2num(v7(1))<7
      singleprecision = 0;
   else
      singleprecision = 1;
   end

   %  Initialize fit image Beta
   %
   for i = run_idx
      for j = 1:num_conds
         Beta{i,j} = zeros(size(nii1.img));
      end
   end

   max_scans = [session_info.run.num_scans];
   max_scans = max(max_scans);


%  now also used to need to find brain_mask (if use thresh)
%  or normalize with volume mean

   % **************  use SPM normalization below **************

   % create step for progress bar
   %
   progress_step = 1 / (num_runs * max_scans);

   %  Extracting data run by run
   %
   for i = run_idx
      g = 0;

      run_info = session_info.run(i);

      %  get image files path/file name
      %
      data_path = run_info.data_path;
      flist = run_info.data_files;
      num_files = run_info.num_scans;

      vol_mean = ones(num_files,1);

      for scan = 1:num_files

         rri_progress_ui(progress_hdl, '', ...
		sprintf('Inspecting run#%d scan#%d... ',i,scan));

         if length(flist)>1
            img_file = fullfile(data_path, flist{scan});
            img = load_untouch_nii(img_file, 1);
         else
            [p fn]=rri_fileparts(flist{1});
            img_file = fullfile(data_path, fn);
            img = load_untouch_nii(img_file, scan);
         end

         if singleprecision
            img = single(img.img(:));
         else
            img = double(img.img(:));
         end

         %  find brain voxel coords for each run, and
         %  accumulated to find common coords for all runs
         %
         if (use_brain_mask == 0)
            thresh_coords = thresh_coords + find_onset_coords(img(:)',coord_thresh,ConsiderAllVoxels);
         end

         if (normalize_volume_mean == 1)
            if (use_brain_mask == 0)
               vol_mean(scan) = mean(img(find(thresh_coords == 0)));
            else
               vol_mean(scan) = mean(img(find(brain_mask)));
            end
         end

         %  spm_global uses a criteria of greater than > (global mean)/8
         %
         g = g + mean(img(find(img > mean(img)/8)));

         stp = (i-1)*max_scans + scan;
         rri_progress_ui(progress_hdl, '', 0.2 * stp * progress_step);
      end		% for scan

      gSF{i} = (100 / (g/num_files)) ./ vol_mean;

   end			% for run

   if (use_brain_mask == 0)
      udims = size(brain_mask);
      brain_mask(find(thresh_coords == 0)) = 1;
      brain_mask = reshape(brain_mask, udims);

      nii = nii1;
      nii.img = brain_mask;
      nii = xform_nii(nii);

      if ~isempty(orient) & ~isempty(orient.orient_pattern)
         thresh_coords = nii.img(orient.orient_pattern);
      else
         thresh_coords = nii.img(:);
      end

      st_coords = find( thresh_coords(:) > 0)';
   end

   % **************  use SPM normalization above **************


   % create step for progress bar
   %
   progress_step = 1 / (num_runs * num_slices * max_scans);


if use_reml

   % **************  use SPM ReML below **************

   %  By default, SPM use ReML (restricted maximum likelihood) estimates.
   %  Therefore, the program has to process the same data twice. In first
   %  time, the whitening/weighting matrix W is computed, and in second
   %  time, the W is applied while processing the data. If we set W to
   %  always be the identity matrix, then, there is no ML estimates, and
   %  the fit image is only obtained by using ordinary least squares.
   %
   W = cell(1,max(run_idx));

   %  1 of 2 processes

   %  Extracting data run by run
   %
   for i = run_idx

      s101 = 0;
      Cy = 0;

      X = Design_Matrix{i};

      %  add_constant 1
      %
      X = [X legendre_regressor(size(X,1), Legendre)];

      %  SPM filter
      %
      K.HParam = 128;
      K.row = 1:size(X,1);
      K.RT = TR;
      K = hrf_spm_filter(K);

      KX = hrf_spm_filter(K,X);
      xKXs = hrf_ml_spm_sf_set(KX);		% called by hrf_ml_spm_sf_ry.m
      pKX = pinv(KX);

      %  Used for ReML
      %
      [iX0, xCon, X1o, Hsqr, trRV, trMV, UFp, UF] = hrf_ml_spm_get_fc(xKXs);

      run_info = session_info.run(i);

      %  get image files path/file name
      %
      data_path = run_info.data_path;
      flist = run_info.data_files;
      num_files = run_info.num_scans;

      %  Extracting data slice by slice
      %
      for k = 1:num_slices

         Y = zeros(num_files,nii1.hdr.dime.dim(2)*nii1.hdr.dime.dim(3));

         rri_progress_ui(progress_hdl, '', ...
		sprintf('Processing pass#1 run#%d slice#%d... ',i,k));

         for scan = 1:num_files
            if length(flist)>1
               img_file = fullfile(data_path, flist{scan});
               img_slice = load_untouch_nii(img_file, 1, '', '', '', '', k);
            else
               [p fn]=rri_fileparts(flist{1});
               img_file = fullfile(data_path, fn);
               img_slice = load_untouch_nii(img_file, scan, '', '', '', '', k);
            end

            if singleprecision
               Y(scan,:) = [single(img_slice.img(:))]';
            else
               Y(scan,:) = [double(img_slice.img(:))]';
            end

            stp = (i-1)*num_slices*max_scans + (k-1)*max_scans + scan;
            rri_progress_ui(progress_hdl, '', 0.2 + 0.39 * stp * progress_step);
         end		% for scan

         Y = Y*gSF{i}(k);
         Cm = find(brain_mask(:,:,k));
         Y = Y(:,Cm);
         KWY = hrf_spm_filter(K,Y);

         %  Create Beta fit image for each slice ( GLM: Y = X * B + e )
         %
         B = pKX * KWY;

         Residual = hrf_ml_spm_sf_ry(xKXs, KWY);
         ResSS = sum(Residual.^2);

         [s101,Cy] = hrf_ml_spm_update_cy(s101,Cy,Y,B,ResSS,Hsqr,trRV,trMV,UF);

      end		% for slice

      if s101 == 0
         warning('Please check your data: There are no significant voxels.');
         return
      end

      Cy = Cy/s101;
      xviv = hrf_ml_spm_get_xviv(Cy, K, X, num_files);

      %  Use W*W' = inv(xviv) to give ReML estimates, and compute whitening 
      %  / weighting matrix W
      %
      [u s102] = hrf_ml_spm_svd(xviv);
      s102 = spdiags(1./sqrt(diag(s102)),0,length(s102),length(s102));
      W{i} = u*s102*u';
      W{i} = W{i}.*(abs(W{i}) > 1e-6);
      W{i} = double(W{i});

   end			% for run

end		% if use_reml


   %  2 of 2 processes

   % **************  use SPM ReML above **************


   %  Extracting data run by run
   %
   for i = run_idx

if ~use_reml
   W{i} = 1;
end

      X = Design_Matrix{i};

      %  add_constant 1
      %
      X = [X legendre_regressor(size(X,1), Legendre)];

      %  SPM filter
      %
      K.HParam = 128;
      K.row = 1:size(X,1);
      K.RT = TR;
      K = hrf_spm_filter(K);

      KX = hrf_spm_filter(K,W{i}*X);
      xKXs = hrf_ml_spm_sf_set(KX);		% called by hrf_ml_spm_sf_ry.m
      pKX = pinv(KX);


      run_info = session_info.run(i);

      %  get image files path/file name
      %
      data_path = run_info.data_path;
      flist = run_info.data_files;
      num_files = run_info.num_scans;

      %  Extracting data slice by slice
      %
      for k = 1:num_slices

         Y = zeros(num_files,nii1.hdr.dime.dim(2)*nii1.hdr.dime.dim(3));

if use_reml
         rri_progress_ui(progress_hdl, '', ...
		sprintf('Processing pass#2 run#%d slice#%d... ',i,k));
else
         rri_progress_ui(progress_hdl, '', ...
		sprintf('Processing run#%d slice#%d... ',i,k));
end

         for scan = 1:num_files
            if length(flist)>1
               img_file = fullfile(data_path, flist{scan});
               img_slice = load_untouch_nii(img_file, 1, '', '', '', '', k);
            else
               [p fn]=rri_fileparts(flist{1});
               img_file = fullfile(data_path, fn);
               img_slice = load_untouch_nii(img_file, scan, '', '', '', '', k);
            end

            if singleprecision
               Y(scan,:) = [single(img_slice.img(:))]';
            else
               Y(scan,:) = [double(img_slice.img(:))]';
            end

            stp = (i-1)*num_slices*max_scans + (k-1)*max_scans + scan;

if use_reml
            rri_progress_ui(progress_hdl, '', 0.59 + 0.4 * stp * progress_step);
else
            rri_progress_ui(progress_hdl, '', 0.2 + 0.79 * stp * progress_step);
end
         end		% for scan

         Y = Y*gSF{i}(k);
         KWY = hrf_spm_filter(K,W{i}*double(Y));

         %  Create Beta fit image for each slice ( GLM: Y = X * B + e )
         %
         B = pKX * KWY;

         for j = 1:num_conds
            Beta{i,j}(:,:,k) = ...
		reshape(B(j,:),[nii1.hdr.dime.dim(2) nii1.hdr.dime.dim(3)]);
         end
      end		% for slice
   end			% for run


   %  Initialize st_datamat
   %
   if (merge_across_runs_flg == 0)	% merge data within run only
      st_datamat = zeros(num_runs*num_conds,length(st_coords));
   else
      st_datamat = zeros(num_conds,length(st_coords));
   end

   %  Apply affine transformation in NIfTI, and also apply re-orient button
   %  for each fit image. Total number of fit image is:  num_runs*num_conds.
   %  Beta fit images will be stacked into a datamat.
   %
   for i = run_idx
      for j = 1:num_conds
         clear nii;
         nii = nii1;
         nii.img = Beta{i,j};
         nii = xform_nii(nii);

         if ~isempty(orient) & ~isempty(orient.orient_pattern)
            Beta{i,j} = nii.img(orient.orient_pattern);
         else
            Beta{i,j} = nii.img(:);
         end

         Beta{i,j} = [Beta{i,j}(:)]';

         if 0
            Beta{i,j} = reshape(Beta{i,j}, dims);	% for test only
         elseif (merge_across_runs_flg == 0)	% merge data within run only
            st_datamat((i-1)*num_conds+j,:) = Beta{i,j}(st_coords);
         else
            st_datamat(j,:) = st_datamat(j,:) + Beta{i,j}(st_coords);
         end
      end		% for cond
   end			% for run

   if (merge_across_runs_flg ~= 0)	% merge data across run
      st_datamat = st_datamat / num_runs;
      st_evt_list = [1:num_conds];
   else
      for i = run_idx
         st_evt_list = [st_evt_list (i-1)*num_conds+[1:num_conds]];
      end
   end

   %  everything is done, ready to save the information
   %
   st_dims = [dims(1) dims(2) 1 dims(3)];
   st_voxel_size = voxel_size;
   st_origin = origin;
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
%   num_subj_cond = [];
      num_subj_cond = ones(1, num_conds1);


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

   return;						% bfm_hrf_get_datamat


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

