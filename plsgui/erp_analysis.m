%ERP_ANALYSIS Apply PLS on the ERP data based on the information saved in
%    the datamat file.
%
%    Usage: [resultFile, elapsed_time] = ...
%	erp_analysis(ismean, ishelmert, iscontrast, isbehav, ...
%	behavdata_col, contrastdata_col, datamat_files, ...
%	num_perm, num_boot, Clim, system, ContrastFile)
%
%    see also PLS_FMRI_ANALYSIS
%

%   Called by erp_analysis_ui
%
%  INPUT:
%    ismean - 1 if select grand mean deviation.
%    ishelmert - 1 if using helmert matrix.
%    iscontrast - 1 if using contrast data.
%    isbehav - 1 if using behavior data.
%    behavdata_col - Selected column mask for Behavior Data;
%    contrastdata_col - Selected column mask for Contrast Data;
%    posthoc - posthoc data.
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
%   Modified on Jan 10, 03 to add contrast & helmert
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [resultFile, elapsed_time] = erp_analysis(varargin)

  progress_hdl = rri_progress_ui('initialize');

  ismean = varargin{1};
  ishelmert = varargin{2};
  iscontrast = varargin{3};
  isbehav = varargin{4};
  behavdata_col = varargin{5};
  contrastdata_col = varargin{6};
  posthoc = varargin{7};
  datamat_files = varargin{8};
  save_datamat = varargin{9};
  num_perm = varargin{10};
  num_boot = varargin{11};
  Clim = varargin{12};
  system = varargin{13};
  ContrastFile = varargin{14};
  cond_selection = varargin{15};
  behavdata_lst0 = varargin{16};
  behavname0 = varargin{17};
  ismultiblock = varargin{18};
  bscan = varargin{19};
  isnonrotatebehav = varargin{20};
  num_split = varargin{21};
  meancentering_type = varargin{22};
  cormode = varargin{23};
  boot_type = varargin{24};
  nonrotated_boot = varargin{25};
  isnonrotatemultiblock = varargin{26};

  if (nargin > 26)
     output_file = varargin{27};
     for_batch = 1;
  else
     for_batch = 0;
  end;

  datamat_files_timestamp = datamat_files;

  for i = 1:length(datamat_files)
     tmp = dir(datamat_files{i});
     datamat_files_timestamp{i} = tmp.date;
  end

  if exist('output_file','var') & ~isempty(output_file)
    resultFile = output_file;
  else

    load(datamat_files{1},'session_info');
    datamat_prefix = session_info.datamat_prefix;

    [result_file,result_path] = rri_selectfile([datamat_prefix '_ERPresult.mat'], ...
	'Saving PLS Result');

    if isequal(result_file,0)		% Cancel was clicked
       resultFile = [];
%       msg1 = ['WARNING: No file is saved.'];
%%       uiwait(msgbox(msg1,'Uncompleted','modal'));
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


  % load the session info and datamat
  %
  [newdata_lst, behavdata_lst, helmertdata_lst, contrastdata_lst, ...
	subj_name_lst, num_cond_lst, num_subj_lst, common_behav, ...
	common_channels, common_conditions, common_time_info, ...
	chan_order, cond_name, behavname] = erp_get_common(datamat_files, ...
	behavdata_col, contrastdata_col, cond_selection, progress_hdl);

  if ~isempty(behavdata_lst0) & ~isempty(behavname0)
     behavdata_lst = behavdata_lst0;
     behavname = behavname0;
  end

  for i = 1:length(newdata_lst)
    if isempty(newdata_lst{i})
      return;
    end
  end

  behavdata = [];

  for i = 1:length(behavdata_lst)
     behavdata = [behavdata; behavdata_lst{i}];
  end

  %  start PLS Run...
  %

  perm_result = [];
  boot_result = [];
  setting2 = [];
  setting3 = [];
  setting4 = [];

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
		'''cond_name'', ''behavname'', ''cond_selection'', ', ...
		'''common_channels'', ', ...
		'''common_conditions'', ''common_time_info'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ', ...
		'''subj_name_lst'', ''system'', ', ...
		'''chan_order'', ''setting2'', ''setting3'', ', ...
		'''setting4'', ''datamat_files'', ''behavdata_lst'', ', ...
		'''datamat_files_timestamp'', ''create_ver'''];

     if save_datamat
         saved_info = [saved_info, ', ''datamat_lst'''];
     end

  elseif(ismultiblock)

     rri_progress_ui(progress_hdl, 'Runing Multiblock PLS', 'Runing Multiblock PLS ...');

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
		'''cond_name'', ''behavname'', ''cond_selection'', ', ...
		'''common_channels'', ', ...
		'''common_conditions'', ''common_time_info'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ', ...
		'''subj_name_lst'', ''system'', ', ...
		'''chan_order'', ''setting2'', ''setting3'', ', ...
		'''setting4'', ''datamat_files'', ''behavdata_lst'', ', ...
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
		'''cond_name'', ''behavname'', ''cond_selection'', ', ...
		'''common_channels'', ', ...
		'''common_conditions'', ''common_time_info'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ', ...
		'''subj_name_lst'', ''system'', ', ...
		'''chan_order'', ''setting2'', ''setting3'', ', ...
		'''setting4'', ''datamat_files'', ''behavdata_lst'', ', ...
		'''datamat_files_timestamp'', ''create_ver'''];

     if save_datamat
         saved_info = [saved_info, ', ''datamat_lst'''];
     end

  elseif(isbehav)

     rri_progress_ui(progress_hdl, 'Runing Behavior PLS', 'Runing Behavior PLS ...');

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
		'''cond_name'', ''behavname'', ''cond_selection'', ', ...
		'''common_channels'', ', ...
		'''common_conditions'', ''common_time_info'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ', ...
		'''subj_name_lst'', ''system'', ', ...
		'''chan_order'', ''setting2'', ''setting3'', ', ...
		'''setting4'', ''datamat_files'', ''behavdata_lst'', ', ...
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
		'''cond_name'', ''cond_selection'', ''common_channels'', ', ...
		'''common_conditions'', ''common_time_info'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ', ...
		'''subj_name_lst'', ''system'', ', ...
		'''chan_order'', ''setting2'', ''setting3'', ', ...
		'''setting4'', ''datamat_files'', ', ...
		'''datamat_files_timestamp'', ''create_ver'''];

     if save_datamat
%         saved_info = [saved_info, ', ''newdata_lst'''];
         saved_info = [saved_info, ', ''datamat_lst'''];
     end

  else					% deviation analysis

     rri_progress_ui(progress_hdl, 'Runing Task PLS', 'Runing Task PLS ...');

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
		'''cond_name'', ''cond_selection'', ''common_channels'', ', ...
		'''common_conditions'', ''common_time_info'', ', ...
		'''num_cond_lst'', ''num_subj_lst'', ', ...
		'''subj_name_lst'', ''system'', ', ...
		'''chan_order'', ''setting2'', ''setting3'', ', ...
		'''setting4'', ''datamat_files'', ', ...
		'''datamat_files_timestamp'', ''create_ver'''];

     if save_datamat
         saved_info = [saved_info, ', ''datamat_lst'''];
     end

  end

   if ~isempty(boot_result)
      boot_result.Clim = Clim;
   end

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

  done = 0;

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

  return; 					% erp_analysis

