%PET_ANALYSIS Apply PLS on the PET data based on the information saved in
%    the datamat file.
%
%    Usage: [resultFile, elapsed_time] = ...
%	pet_analysis(isbehav, datamat_files, num_perm, ...
%	num_boot, Clim)
%
%    see also PLS_FMRI_ANALYSIS
%

%   Called by pet_analysis_ui
%
%  INPUT:
%    isbehav - 1 if run Behavior PLS; 0 for Task PLS.
%    datamat_files - a cell array, one element per group.  Each element
%               in the array is another cell array contains the names of
%               session profiles for the group.
%    num_perm - number of permutations to be performed.
%    num_boot - number of bootstrap resampling to be performed.
%    Clim - upper limit of confidence interval estimated
%
%   OUTPUT FILE:
%         - file stores the information of the PLS result.
%
%   Created July 2001 by Wilkin Chau, Rotman Research Institute
%   Modified on 02-OCT-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [resultFile, elapsed_time] = pet_analysis(varargin)

  singledatamat = 0;		% init singledatamat to false

  isbehav = varargin{1};
  datamat_files = varargin{2};
  num_perm = varargin{3};
  num_split = varargin{4};
  meancentering_type = varargin{5};
  cormode = varargin{6};
  boot_type = varargin{7};
  nonrotated_boot = varargin{8};
  num_boot = varargin{9};
  Clim = varargin{10};
  posthoc = varargin{11};
  cond_selection = varargin{12};
  behavname = varargin{13};
  behavdata = varargin{14};
  behavdata_lst = varargin{15};
  ContrastFile = varargin{16};
  iscontrast = varargin{17};
  ismean = varargin{18};
  save_datamat = varargin{19};
  ismultiblock = varargin{20};
  bscan = varargin{21};
  isnonrotatebehav = varargin{22};
  isnonrotatemultiblock = varargin{23};

  if (nargin > 23)
     output_file = varargin{24};
     intel_system = varargin{25};
     for_batch = 1;
  else
     for_batch = 0;
  end;

  datamat_files_timestamp = datamat_files;

  for i = 1:length(datamat_files)
     tmp = dir(datamat_files{i});
     datamat_files_timestamp{i} = tmp.date;

        warning off;
        load(datamat_files{i}, 'singleprecision');
        warning on;

        if exist('singleprecision','var') & singleprecision
           singledatamat = 1;
        end
  end

  if exist('output_file','var') & ~isempty(output_file)
    resultFile = output_file;
  else

    load(datamat_files{1},'session_info');
    datamat_prefix = session_info.datamat_prefix;

    [result_file,result_path] = ...
	rri_selectfile([datamat_prefix '_PETresult.mat'],'Saving PLS Result');

    if isequal(result_file,0)		% Cancel was clicked
%       msg1 = ['WARNING: No file is saved.'];
%%       msgbox(msg1,'Uncompleted');
       resultFile = [];
%       disp('ERROR: Result file is not saved.');
       elapsed_time = 0;
       return;
    else
       resultFile = fullfile(result_path,result_file);
    end;
  end;


   fid = fopen(resultFile,'wb');

   if fid < 0
      tit = sprintf('Cannot write file %s.', resultFile);
      msg = 'Please check whether you have write permission to save the result file to this folder.';
%      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      msgbox(msg, tit, 'modal');
      return;
   else
      fclose(fid);
   end


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
   end;
 end

  progress_hdl = rri_progress_ui('initialize');

  % load the session info and datamat
  %
  [behavdata_lst, newdata_lst, newcoords, dims, num_cond_lst, ...
	num_subj_lst, subj_name_lst, voxel_size, origin, ...
	behavname, behavdata] = pet_get_common(datamat_files,  ...
	cond_selection, behavname, behavdata, ...
	behavdata_lst, progress_hdl);

   if isempty(newcoords)
      disp('ERROR: There are no common voxels found.');
      return;
   else
      for i = 1:length(newdata_lst)
         if isempty(newdata_lst{i})
            disp('ERROR: Merged datamat is empty.');
            return;
         end
      end
   end


   for grp=1:length(newdata_lst)
      if singleanalysis
         newdata_lst{grp} = single(newdata_lst{grp});
      else
         newdata_lst{grp} = double(newdata_lst{grp});
      end
   end


  %  start PLS Run...
  %

  perm_result = [];
  boot_result = [];
  create_ver = plsgui_vernum;

  if(isnonrotatemultiblock)

     rri_progress_ui(progress_hdl, 'Running NonRotated Multiblock PLS', 'Running Multiblock PLS ...');

     method = 6;

     opt.progress_hdl = progress_hdl;
     opt.method = method;
     opt.num_perm = num_perm;
     opt.is_struct = 0;			% 1 only for Structure PLS
     opt.num_boot = num_boot;
     opt.clim = Clim;
     opt.bscan = bscan;

     opt.stacked_designdata = ContrastFile;
     opt.stacked_behavdata = behavdata;

     opt.meancentering_type = meancentering_type;
     opt.cormode = cormode;
     opt.boot_type = boot_type;
     opt.nonrotated_boot = nonrotated_boot;
     opt.num_split = num_split;

     datamat_lst = newdata_lst;
     result = pls_analysis(datamat_lst, num_subj_lst, num_cond_lst(1), opt);

     saved_info=['''method'', ''result'', ', ...
		'''newcoords'', ''cond_selection'', ''dims'', ', ...
		'''voxel_size'', ''origin'', ''behavname'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ''subj_name_lst'', ', ...
		'''behavdata_lst'', ''datamat_files'', ', ...
		'''datamat_files_timestamp'', ''create_ver'''];

     if save_datamat
         saved_info = [saved_info, ', ''datamat_lst'''];
     end

  elseif(ismultiblock)

     rri_progress_ui(progress_hdl, 'Running Multiblock PLS', 'Running Multiblock PLS ...');

     method = 4;

     opt.progress_hdl = progress_hdl;
     opt.method = method;
     opt.num_perm = num_perm;
     opt.is_struct = 0;			% 1 only for Structure PLS
     opt.num_boot = num_boot;
     opt.clim = Clim;
     opt.bscan = bscan;

     opt.stacked_behavdata = behavdata;

     opt.meancentering_type = meancentering_type;
     opt.cormode = cormode;
     opt.boot_type = boot_type;
     opt.nonrotated_boot = nonrotated_boot;
     opt.num_split = num_split;

     datamat_lst = newdata_lst;
     result = pls_analysis(datamat_lst, num_subj_lst, num_cond_lst(1), opt);

     saved_info=['''method'', ''result'', ', ...
		'''newcoords'', ''cond_selection'', ''dims'', ', ...
		'''voxel_size'', ''origin'', ''behavname'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ''subj_name_lst'', ', ...
		'''behavdata_lst'', ''datamat_files'', ', ...
		'''datamat_files_timestamp'', ''create_ver'''];

     if save_datamat
         saved_info = [saved_info, ', ''datamat_lst'''];
     end

  elseif(isnonrotatebehav)

     rri_progress_ui(progress_hdl, 'Running NonRotated Behavior PLS', 'Running NonRotated Behavior PLS ...');

     method = 5;

     opt.progress_hdl = progress_hdl;
     opt.method = method;
     opt.num_perm = num_perm;
     opt.is_struct = 0;			% 1 only for Structure PLS
     opt.num_boot = num_boot;
     opt.clim = Clim;
     opt.bscan = bscan;

     opt.stacked_designdata = ContrastFile;
     opt.stacked_behavdata = behavdata;

     opt.meancentering_type = meancentering_type;
     opt.cormode = cormode;
     opt.boot_type = boot_type;
     opt.nonrotated_boot = nonrotated_boot;
     opt.num_split = num_split;

     datamat_lst = newdata_lst;
     result = pls_analysis(datamat_lst, num_subj_lst, num_cond_lst(1), opt);

     saved_info=['''method'', ''result'', ', ...
		'''newcoords'', ''cond_selection'', ''dims'', ', ...
		'''voxel_size'', ''origin'', ''behavname'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ''subj_name_lst'', ', ...
		'''behavdata_lst'', ''datamat_files'', ', ...
		'''datamat_files_timestamp'', ''create_ver'''];

     if save_datamat
         saved_info = [saved_info, ', ''datamat_lst'''];
     end

  elseif(isbehav)

     rri_progress_ui(progress_hdl, 'Running Behavior PLS', 'Running Behavior PLS ...');

     method = 3;

     opt.progress_hdl = progress_hdl;
     opt.method = method;
     opt.num_perm = num_perm;
     opt.is_struct = 0;			% 1 only for Structure PLS
     opt.num_boot = num_boot;
     opt.clim = Clim;
     opt.bscan = bscan;

     opt.stacked_behavdata = behavdata;

     opt.meancentering_type = meancentering_type;
     opt.cormode = cormode;
     opt.boot_type = boot_type;
     opt.nonrotated_boot = nonrotated_boot;
     opt.num_split = num_split;

     datamat_lst = newdata_lst;
     result = pls_analysis(datamat_lst, num_subj_lst, num_cond_lst(1), opt);

     saved_info=['''method'', ''result'', ', ...
		'''newcoords'', ''cond_selection'', ''dims'', ', ...
		'''voxel_size'', ''origin'', ''behavname'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ''subj_name_lst'', ', ...
		'''behavdata_lst'', ''datamat_files'', ', ...
		'''datamat_files_timestamp'', ''create_ver'''];

     if save_datamat
         saved_info = [saved_info, ', ''datamat_lst'''];
     end

  elseif(iscontrast)			% contrast analysis

     rri_progress_ui(progress_hdl, 'Running NonRotated Task PLS', 'Running NonRotated Task PLS ...');

     method = 2;

     opt.progress_hdl = progress_hdl;
     opt.method = method;
     opt.num_perm = num_perm;
     opt.is_struct = 0;			% 1 only for Structure PLS
     opt.num_boot = num_boot;
     opt.clim = Clim;
     opt.bscan = bscan;

     opt.stacked_designdata = ContrastFile;

     opt.meancentering_type = meancentering_type;
     opt.cormode = cormode;
     opt.boot_type = boot_type;
     opt.nonrotated_boot = nonrotated_boot;
     opt.num_split = num_split;

     datamat_lst = newdata_lst;
     result = pls_analysis(datamat_lst, num_subj_lst, num_cond_lst(1), opt);

     saved_info=['''method'', ''result'', ', ...
		'''newcoords'', ''cond_selection'', ''dims'', ', ...
		'''voxel_size'', ''origin'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ''subj_name_lst'', ', ...
		'''datamat_files'', ''datamat_files_timestamp'', ', ...
		'''create_ver'''];


%     saved_info=['''brainlv'', ''s'', ''designlv'', ''brainscores'', ', ...
%		'''designscores'', ''lvintercorrs'', ''design'', ', ...
%		'''perm_result'', ''boot_result'', ', ...
%		'''newcoords'', ''cond_selection'', ''dims'', ', ...
%		'''voxel_size'', ''origin'', ''method'', ', ...
%		'''num_cond_lst'', ''num_subj_lst'', ''subj_name_lst'', ', ...
%		'''datamat_files'', ''datamat_files_timestamp'', ', ...
%		'''create_ver'''];

     if save_datamat
%         saved_info = [saved_info, ', ''newdata_lst'''];
         saved_info = [saved_info, ', ''datamat_lst'''];
     end

  else					% deviation analysis

     rri_progress_ui(progress_hdl, 'Running Task PLS', 'Running Task PLS ...');


     method = 1;

     opt.progress_hdl = progress_hdl;
     opt.method = method;
     opt.num_perm = num_perm;
     opt.is_struct = 0;			% 1 only for Structure PLS
     opt.num_boot = num_boot;
     opt.clim = Clim;
     opt.bscan = bscan;

     opt.meancentering_type = meancentering_type;
     opt.cormode = cormode;
     opt.boot_type = boot_type;
     opt.nonrotated_boot = nonrotated_boot;
     opt.num_split = num_split;

     datamat_lst = newdata_lst;
     result = pls_analysis(datamat_lst, num_subj_lst, num_cond_lst(1), opt);

     saved_info=['''method'', ''result'', ', ...
		'''newcoords'', ''cond_selection'', ''dims'', ', ...
		'''voxel_size'', ''origin'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ''subj_name_lst'', ', ...
		'''datamat_files'', ''datamat_files_timestamp'', ', ...
		'''create_ver'''];


%     saved_info=['''brainlv'', ''s'', ''designlv'', ''brainscores'', ', ...
%		'''designscores'', ''method'', ', ...
%		'''perm_result'', ''boot_result'', ', ...
%		'''newcoords'', ''cond_selection'', ''dims'', ', ...
%		'''voxel_size'', ''origin'', ', ...
%		'''num_cond_lst'', ''num_subj_lst'', ''subj_name_lst'', ', ...
%		'''datamat_files'', ''datamat_files_timestamp'', ', ...
%		'''create_ver'''];


     if save_datamat
%         saved_info = [saved_info, ', ''newdata_lst'''];
         saved_info = [saved_info, ', ''datamat_lst'''];
     end

  end


   %  Either used "single" in analysis or had "single" in datamat
   %
   if singleanalysis | singledatamat
      singleprecision = 1;
   else
      singleprecision = 0;
   end

   if ~isempty(boot_result)
      boot_result.Clim = Clim;
   end

   saved_info = [saved_info, ', ''singleprecision'''];


  %  save results
  %
  msg = 'Saving to the disk ...';

  if exist('progress_hdl','var') & ishandle(progress_hdl)
     rri_progress_ui(progress_hdl, 'Save', msg);
  end

  if ~for_batch
%     elapsed_time = toc;
     disp('RunPLS is done ...');
  end

  if isempty(result)
     resultFile = '';
     done = 1;
  else
     done = 0;
  end

  while ~done
    try
       eval(['save(''', resultFile, ''',' saved_info,');']);
       done = 1;
    catch
          resultFile = [];
          msg1 = ['ERROR: Unable to write datamat file.'];
          return;
    end
  end

  return; 					% pet_analysis

