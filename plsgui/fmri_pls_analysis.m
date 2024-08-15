function fmri_pls_analysis(varargin)
%
%  USAGE: 
%          fmri_pls_analysis
%    or    fmri_pls_analysis(SessionProfiles,ContrastFile, ...
%                              num_perm,num_boot,grp_analysis_flg,output_file)
%
%    Apply PLS on the fMRI data based on the session information saved in
%    the "sessionFile".  Assume session information, and st_datamat have 
%    been created.
%
%
%  INPUT:
%    SessionProfiles - a cell array, one element per group.  Each element 
%               in the array is another cell array contains the names of 
%               session profiles for the group.
%    ContrastFile - the contrast file to be used to generate the design matrix.
%                   Helmert matrix will be specified using the string of
%                   'HELMERT'.  If contrast is empty, use deviation from 
%                   grand mean for the contrast.
%    num_perm - number of permutations to be performed.
%    num_boot - number of bootstrap resampling to be performed.
%    grp_analysis_flg - flag indicates group analysis.
%    output_file - (optional) the name of output file
%
%                  
%  OUTPUT FILE:
%         - file stores the information of the PLS result.
%
%  NOTE:
%    To create session information, use 'pls_input_session_info'.
%    To create st_datamat, use 'fmri_gen_datamat', 'fmri_combine_coords',
%       and 'fmri_gen_st_datamat'.
%
%  Script needed: fmri_perm_test.m, fmri_deviation_perm_test.m
%
%   -- Created July 2001 by Wilkin Chau, Rotman Research Institute
%

  singledatamat = 0;		% init singledatamat to false

  if (nargin == 0),
     [SessionProfiles,ContrastFile,num_perm,group_analysis] = options_query;
  else
     SessionProfiles = varargin{1};
     ContrastFile = varargin{2};
     num_perm = varargin{3};
     num_boot = varargin{4};
     Clim = varargin{5};
     posthoc = varargin{6};
     save_datamat = varargin{7};
     group_analysis = varargin{8};
     cond_selection = varargin{9};
     behavname = varargin{10};
     behavdata = varargin{11};
     behavdata_lst = varargin{12};
     bscan = varargin{13};
     has_unequal_subj = varargin{14};
     num_split = varargin{15};
     meancentering_type = varargin{16};
     cormode = varargin{17};
     boot_type = varargin{18};
     nonrotated_boot = varargin{19};
     method = varargin{20};

     if (nargin > 20)
        output_file = varargin{21};
        intel_system = varargin{22};
        for_batch = 1;
     else
        for_batch = 0;
     end;
  end;

%  session_files_timestamp = SessionProfiles;
%  datamat_files_timestamp = SessionProfiles;

%  change_timestamp = 0;

  for i = 1:length(SessionProfiles)
     for j = 1:length(SessionProfiles{i})
        warning off;
        load(SessionProfiles{i}{j}, 'singleprecision');
        warning on;

        if exist('singleprecision','var') & singleprecision
           singledatamat = 1;
        end
     end
  end

  %  save results
  %
  if exist('output_file','var') & ~isempty(output_file)
    resultFile = output_file;
    fn = strrep(resultFile, 'result', 'session');
  else

    fn = SessionProfiles{1}{1};
    load(fn,'session_info');
    datamat_prefix = session_info.datamat_prefix;

    if findstr('BfMRIsessiondata.mat', fn)
       [result_file,result_path] = ...
		rri_selectfile([datamat_prefix,'_BfMRIresult.mat'],'Saving PLS Result');
    else
       [result_file,result_path] = ...
		rri_selectfile([datamat_prefix,'_fMRIresult.mat'],'Saving PLS Result');
    end

    if isequal(result_file,0)			% Cancel was clicked
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

  progress_hdl = ShowProgress('initialize');


   %  "num_behav_subj" was "num_subj". 
   %  It is not in use, because we have "num_subj_lst"
   %
   [st_datamat, st_coords, st_dims, num_conditions, ...
	st_evt_list, st_win_size, st_voxel_size, st_origin, subj_group, ...
	subj_name, cond_name, num_behav_subj, ...
	newdata_lst, num_subj_lst, has_ssb ] = ...
		concat_st_datamat(behavdata, singleanalysis, ...
		SessionProfiles,progress_hdl, ...
		posthoc, cond_selection, has_unequal_subj);


   SingleSubject = has_ssb;

   if isempty(st_datamat),
      return;
   end;

   if ~singleanalysis
      st_datamat = double(st_datamat);

      if ~isempty(newdata_lst)
         for g = 1:length(newdata_lst)
            newdata_lst{g} = double(newdata_lst{g});
         end
      end
   end


   lv_evt_list = st_evt_list;

        last = 0;
        for g = 1:length(num_subj_lst)
           first = last + 1;

           if iscell(num_subj_lst)
              last = first+sum(subj_group{g})-1;
           else
              last = last + num_conditions*num_subj_lst(g);
           end

           [tmp idx] = sort(st_evt_list(first:last));
           tmp = st_datamat(first:last,:);
           grp_datamat{g} = tmp(idx,:);
        end;


   switch  (method) 
   case 1
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
   case 2
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
   case 3
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
   case 4
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
   case 5
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
   case 6
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
   end

   result = pls_analysis(grp_datamat, num_subj_lst, num_conditions, opt);

   %  Either used "single" in analysis or had "single" in datamat
   %
   if singleanalysis | singledatamat
      singleprecision = 1;
   else
      singleprecision = 0;
   end

   create_ver = plsgui_vernum;

   saved_info=['method result ', ...
	'st_coords st_dims st_voxel_size st_origin ', ...
	'lv_evt_list st_win_size SessionProfiles ', ...
	'cond_name cond_selection subj_name create_ver ', ...
	'singleprecision SingleSubject '];

   if save_datamat & ~isempty(result)
      st_datamat = grp_datamat;
      datamat_lst = st_datamat;
      saved_info = [saved_info, ' datamat_lst'];
   end

   if ismember(method,[3 4 5 6])
      saved_info = [saved_info, ' behavname', ' behavdata_lst'];
   end


if 0

  if (group_analysis == 0)
     subj_group = [];		% for nongroup analysis
  end;

  %  get the contrast 
  %
  switch  (method) 
     case {1}
        USE_DEVIATION_PERM_TEST = 1;
	isbehav = 0;
        ContrastFile = 'NONE';
     case {2}
        USE_DEVIATION_PERM_TEST = 0;
	isbehav = 0;
        if isnumeric(ContrastFile)
           contrasts = ContrastFile;
        else
           contrasts = load(ContrastFile);
        end
     case {3}
        USE_DEVIATION_PERM_TEST = 0;
	isbehav = 1;
        contrasts = behavdata;
     case {4}
        USE_DEVIATION_PERM_TEST = 0;
	isbehav = 2;
        contrasts = behavdata;
     case {5}
        USE_DEVIATION_PERM_TEST = 0;
	isbehav = 3;
        if isnumeric(ContrastFile)
           contrasts = ContrastFile;
        else
           contrasts = load(ContrastFile);
        end
     case {6}
        USE_DEVIATION_PERM_TEST = 0;
	isbehav = 3;	% or 4?
        if isnumeric(ContrastFile)
           contrasts = ContrastFile;
        else
           contrasts = load(ContrastFile);
        end
  end;

  create_ver = plsgui_vernum;

  %  start permutation PLS ...
  %
  perm_result = [];
  boot_result = [];
  if (USE_DEVIATION_PERM_TEST)		% mean

     if (num_boot > 0),
        num_rep = length(st_evt_list) / num_conditions;

%        boot_progress = rri_progress_ui('initialize');

        if isempty(subj_group)
           [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
              = rri_boot_check(num_rep, 1, num_boot, 1, ...
                for_batch);
%                boot_progress, for_batch);
        else

          if iscell(subj_group) 
            [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
              = ssb_rri_boot_check(subj_group, num_conditions, num_boot, 1, ...
                for_batch);
          else
            [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
              = rri_boot_check(subj_group, num_conditions, num_boot, 1, ...
                for_batch);
          end				% if iscell(subj_group)

%                boot_progress, for_batch);
        end;

        num_boot = new_num_boot;
     end;

     if (num_perm > 0) | (num_boot == 0),
        if ~isempty(progress_hdl) & ishandle(progress_hdl), figure(progress_hdl); end;

        [brainlv,s,designlv,b_scores,d_scores,perm_result,lv_evt_list] = ...
           fmri_deviation_perm_test(st_datamat,num_conditions,st_evt_list, ...
                                   num_perm,subj_group);
     end;

     if (num_boot > 0),
        if ~isempty(progress_hdl) & ishandle(progress_hdl), figure(progress_hdl); end;

        [brainlv2,s2,designlv2,b_scores2,d_scores2,boot_result,lv_evt_list2] = ...
           fmri_deviation_boot_test(st_datamat,Clim,num_conditions,st_evt_list, ...
                                   num_boot, subj_group, ...
         min_subj_per_group,is_boot_samples,boot_samples,new_num_boot);

        if num_perm == 0
           brainlv = brainlv2;
           s = s2;
           designlv = designlv2;
           b_scores = b_scores2;
           d_scores = d_scores2;
           lv_evt_list = lv_evt_list2;
           perm_result = [];
        end
     end;

     saved_info=['brainlv s designlv perm_result boot_result st_coords ', ...
  	         'st_dims lv_evt_list st_win_size st_voxel_size st_origin ', ...
		 'SessionProfiles ContrastFile b_scores d_scores ', ...
		 'subj_group num_conditions cond_name cond_selection ', ...
		 'num_subj_lst subj_name session_files_timestamp ', ...
		 'datamat_files_timestamp create_ver'];

     if save_datamat & ~isempty(brainlv)
        last = 0;
%        grp_datamat = [];
        for g = 1:length(num_subj_lst)
           first = last + 1;

           if iscell(num_subj_lst)
              last = first+sum(subj_group{g})-1;
           else
              last = last + num_conditions*num_subj_lst(g);
           end

           [tmp idx] = sort(st_evt_list(first:last));
           tmp = st_datamat(first:last,:);
%           grp_datamat = [grp_datamat; tmp(idx,:)];
           grp_datamat{g} = tmp(idx,:);
        end;
        
        st_datamat = grp_datamat;
        datamat_lst = st_datamat;
        saved_info = [saved_info, ' datamat_lst'];
     end

  elseif isbehav == 2			% Multiblock Analysis

        ibehavdata_lst = behavdata_lst;

        if (num_boot > 0),
%           boot_progress = rri_progress_ui('initialize');

          if iscell(subj_group) 
            [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
              = ssb_rri_boot_check(num_subj_lst, num_conditions, num_boot, 0, ...
                for_batch);
          else
            [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
              = rri_boot_check(num_subj_lst, num_conditions, num_boot, 0, ...
                for_batch);
          end				% if iscell(subj_group)

%                boot_progress, for_batch);

           num_boot = new_num_boot;
        end;

        if (num_perm > 0) | (num_boot == 0),
           if ~isempty(progress_hdl) & ishandle(progress_hdl), figure(progress_hdl); end;

           if iscell(subj_group) 
             [brainlv,s,designlv,behavlv,brainscores,d_scores,behavscores,lvcorrs, ...
		origpost,perm_result,behavdata,lv_evt_list,behavdata_lst,datamatcorrs_lst, ...
		b_scores,behav_row_idx] = ...
			ssb_fmri_perm_multiblock(st_datamat,contrasts,st_evt_list, ...
			ibehavdata_lst, newdata_lst, num_subj_lst, ...
			num_perm,num_conditions,num_behav_subj,posthoc,bscan);
           else
             [brainlv,s,designlv,behavlv,brainscores,d_scores,behavscores,lvcorrs, ...
		origpost,perm_result,behavdata,lv_evt_list,behavdata_lst,datamatcorrs_lst, ...
		b_scores,behav_row_idx] = ...
			fmri_perm_multiblock(st_datamat,contrasts,st_evt_list, ...
			ibehavdata_lst, newdata_lst, num_subj_lst, ...
			num_perm,num_conditions,num_behav_subj,posthoc,bscan);
           end
        end;

        if (num_boot > 0),
           if num_perm == 0, origpost = []; end;
           if ~isempty(progress_hdl) & ishandle(progress_hdl), figure(progress_hdl); end;

           if iscell(subj_group) 
             [brainlv2,s2,designlv2,behavlv2,brainscores2,d_scores2,behavscores2,lvcorrs2, ...
		boot_result,behavdata2,lv_evt_list2,behavdata_lst2,datamatcorrs_lst2,b_scores2,behav_row_idx2] = ...
			ssb_fmri_boot_multiblock(st_datamat,contrasts,st_evt_list, ...
			ibehavdata_lst, newdata_lst, num_subj_lst, ...
			num_boot,num_conditions,num_behav_subj,Clim, ...
                        min_subj_per_group,is_boot_samples,boot_samples, ...
			new_num_boot,bscan);
           else
             [brainlv2,s2,designlv2,behavlv2,brainscores2,d_scores2,behavscores2,lvcorrs2, ...
		boot_result,behavdata2,lv_evt_list2,behavdata_lst2,datamatcorrs_lst2,b_scores2,behav_row_idx2] = ...
			fmri_boot_multiblock(st_datamat,contrasts,st_evt_list, ...
			ibehavdata_lst, newdata_lst, num_subj_lst, ...
			num_boot,num_conditions,num_behav_subj,Clim, ...
                        min_subj_per_group,is_boot_samples,boot_samples, ...
			new_num_boot,bscan);
           end

           if num_perm == 0
              brainlv = brainlv2;
              s = s2;
              designlv = designlv2;
              behavlv = behavlv2;
              brainscores = brainscores2;
              d_scores = d_scores2;
              behavscores = behavscores2;
              lvcorrs = lvcorrs2;
              behavdata = behavdata2;
              lv_evt_list = lv_evt_list2;
              behavdata_lst = behavdata_lst2;
              datamatcorrs_lst = datamatcorrs_lst2;
              b_scores = b_scores2;
	      behav_row_idx = behav_row_idx2;
              perm_result = [];
           end
        end;

        ismultiblock = 1;

        saved_info=['brainlv s designlv behavlv brainscores b_scores d_scores behavscores lvcorrs ', ...
			'origpost perm_result boot_result st_coords ', ...
			'behavdata behavname datamatcorrs_lst ', ...
			'num_conditions subj_name cond_name cond_selection ', ...
			'st_dims lv_evt_list st_win_size st_voxel_size ', ...
			'subj_group behavdata_lst num_subj_lst ', ...
			'st_origin SessionProfiles ContrastFile ', ...
			'session_files_timestamp datamat_files_timestamp ', ...
			'create_ver ismultiblock bscan'];

        if save_datamat & ~isempty(brainlv)
            last = 0;
%            grp_datamat = [];
            for g = 1:length(num_subj_lst)
               first = last + 1;

               if iscell(num_subj_lst)
                  last = first+sum(subj_group{g})-1;
               else
                  last = last + num_conditions*num_subj_lst(g);
               end

               [tmp idx] = sort(st_evt_list(first:last));
               tmp = st_datamat(first:last,:);
%               grp_datamat = [grp_datamat; tmp(idx,:)];
               grp_datamat{g} = tmp(idx,:);
            end;
        
            st_datamat = grp_datamat;
            datamat_lst = st_datamat;
            saved_info = [saved_info, ' datamat_lst'];
        end

  elseif isbehav == 3			% Non Rotate Behavior Analysis

        if (num_boot > 0),
           num_rep = length(st_evt_list) / num_conditions;

%           boot_progress = rri_progress_ui('initialize');

           if isempty(subj_group)
              [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
                 = rri_boot_check(num_rep, 1, num_boot, 0, ...
                   for_batch);
%                   boot_progress, for_batch);
           else

             if iscell(subj_group) 
               [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
                 = ssb_rri_boot_check(subj_group, num_conditions, num_boot, 0, ...
                   for_batch);
             else
               [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
                 = rri_boot_check(subj_group, num_conditions, num_boot, 0, ...
                   for_batch);
             end				% if iscell(subj_group)

%                   boot_progress, for_batch);
           end

           num_boot = new_num_boot;
        else
           min_subj_per_group=[];is_boot_samples=[];boot_samples=[];new_num_boot=[];
        end;

        origpost = [];
        if ~isempty(progress_hdl) & ishandle(progress_hdl), figure(progress_hdl); end;

        if iscell(subj_group) 
          [brainlv,s,behavlv,brainscores,behavscores,lvcorrs,lvintercorrs, ...
             perm_result,boot_result,behavdata,lv_evt_list,datamatcorrs_lst] = ...
		ssb_fmri_behavpls_norotate(st_datamat,contrasts,num_conditions,...
		Clim, behavdata, behavdata_lst, newdata_lst, num_subj_lst, ...
		st_evt_list,num_boot,num_perm,subj_group, ...
		min_subj_per_group,is_boot_samples,boot_samples,new_num_boot);
        else
          [brainlv,s,behavlv,brainscores,behavscores,lvcorrs,lvintercorrs, ...
             perm_result,boot_result,behavdata,lv_evt_list,datamatcorrs_lst] = ...
		fmri_behavpls_norotate(st_datamat,contrasts,num_conditions,...
		Clim, behavdata, behavdata_lst, newdata_lst, num_subj_lst, ...
		st_evt_list,num_boot,num_perm,subj_group, ...
		min_subj_per_group,is_boot_samples,boot_samples,new_num_boot);
        end

        saved_info=['brainlv s behavlv brainscores behavscores lvcorrs lvintercorrs ', ...
			'origpost perm_result boot_result st_coords ', ...
			'behavdata behavname datamatcorrs_lst ', ...
			'num_conditions subj_name cond_name cond_selection ', ...
			'st_dims lv_evt_list st_win_size st_voxel_size ', ...
			'subj_group behavdata_lst num_subj_lst ', ...
			'st_origin SessionProfiles ContrastFile ', ...
			'session_files_timestamp datamat_files_timestamp ', ...
			'create_ver'];

        if save_datamat & ~isempty(brainlv)
            last = 0;
%            grp_datamat = [];
            for g = 1:length(num_subj_lst)
               first = last + 1;

               if iscell(num_subj_lst)
                  last = first+sum(subj_group{g})-1;
               else
                  last = last + num_conditions*num_subj_lst(g);
               end

               [tmp idx] = sort(st_evt_list(first:last));
               tmp = st_datamat(first:last,:);
%               grp_datamat = [grp_datamat; tmp(idx,:)];
               grp_datamat{g} = tmp(idx,:);
            end;
        
            st_datamat = grp_datamat;
            datamat_lst = st_datamat;
            saved_info = [saved_info, ' datamat_lst'];
        end

  else					% behav & non rotate taskpls

     if (isbehav)			% Behavior Analysis

        if (num_boot > 0),
%           boot_progress = rri_progress_ui('initialize');

           if iscell(subj_group)
              [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
                 = ssb_rri_boot_check(num_subj_lst, num_conditions, num_boot, 0, ...
                   for_batch);
           else
              [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
                 = rri_boot_check(num_subj_lst, num_conditions, num_boot, 0, ...
                   for_batch);
           end				% if iscell(subj_group)

%                boot_progress, for_batch);

           num_boot = new_num_boot;
        end;

        if (num_perm > 0) | (num_boot == 0),
           if ~isempty(progress_hdl) & ishandle(progress_hdl), figure(progress_hdl); end;

           if iscell(subj_group)
              [brainlv,s,behavlv,brainscores,behavscores,lvcorrs, ...
		   origpost,perm_result,behavdata,lv_evt_list,datamatcorrs_lst] = ...
			ssb_fmri_perm_behav(st_datamat,contrasts,st_evt_list, ...
			behavdata_lst, newdata_lst, num_subj_lst, ...
			num_perm,num_conditions,num_behav_subj,posthoc);
           else
              [brainlv,s,behavlv,brainscores,behavscores,lvcorrs, ...
		   origpost,perm_result,behavdata,lv_evt_list,datamatcorrs_lst] = ...
			fmri_perm_behav(st_datamat,contrasts,st_evt_list, ...
			behavdata_lst, newdata_lst, num_subj_lst, ...
			num_perm,num_conditions,num_behav_subj,posthoc);
           end			% if iscell(subj_group)
        end;

        if (num_boot > 0),
           if num_perm == 0, origpost = []; end;
           if ~isempty(progress_hdl) & ishandle(progress_hdl), figure(progress_hdl); end;

           if iscell(subj_group)
              [brainlv2,s2,behavlv2,brainscores2,behavscores2,lvcorrs2, ...
		   boot_result,behavdata,lv_evt_list2,datamatcorrs_lst2] = ...
			ssb_fmri_boot_behav(st_datamat,contrasts,st_evt_list, ...
			behavdata_lst, newdata_lst, num_subj_lst, ...
			num_boot,num_conditions,num_behav_subj,Clim, ...
                        min_subj_per_group,is_boot_samples,boot_samples,new_num_boot);
           else
              [brainlv2,s2,behavlv2,brainscores2,behavscores2,lvcorrs2, ...
		   boot_result,behavdata,lv_evt_list2,datamatcorrs_lst2] = ...
			fmri_boot_behav(st_datamat,contrasts,st_evt_list, ...
			behavdata_lst, newdata_lst, num_subj_lst, ...
			num_boot,num_conditions,num_behav_subj,Clim, ...
                        min_subj_per_group,is_boot_samples,boot_samples,new_num_boot);
           end			% if iscell(subj_group)

           if num_perm == 0
              brainlv = brainlv2;
              s = s2;
              behavlv = behavlv2;
              brainscores = brainscores2;
              behavscores = behavscores2;
              lvcorrs = lvcorrs2;
              lv_evt_list = lv_evt_list2;
              datamatcorrs_lst = datamatcorrs_lst2;
              perm_result = [];
           end
        end;

        saved_info=['brainlv s behavlv brainscores behavscores lvcorrs ', ...
			'origpost perm_result boot_result st_coords ', ...
			'behavdata behavname datamatcorrs_lst ', ...
			'num_conditions subj_name cond_name cond_selection ', ...
			'st_dims lv_evt_list st_win_size st_voxel_size ', ...
			'subj_group behavdata_lst num_subj_lst ', ...
			'st_origin SessionProfiles ContrastFile ', ...
			'session_files_timestamp datamat_files_timestamp ', ...
			'create_ver'];

        if save_datamat & ~isempty(brainlv)
            last = 0;
%            grp_datamat = [];
            for g = 1:length(num_subj_lst)
               first = last + 1;

               if iscell(num_subj_lst)
                  last = first+sum(subj_group{g})-1;
               else
                  last = last + num_conditions*num_subj_lst(g);
               end

               [tmp idx] = sort(st_evt_list(first:last));
               tmp = st_datamat(first:last,:);
%               grp_datamat = [grp_datamat; tmp(idx,:)];
               grp_datamat{g} = tmp(idx,:);
            end;
        
            st_datamat = grp_datamat;
            datamat_lst = st_datamat;
            saved_info = [saved_info, ' datamat_lst'];
        end

     else						% Non Rotated Task

        if (num_boot > 0),
           num_rep = length(st_evt_list) / num_conditions;

%           boot_progress = rri_progress_ui('initialize');

           if isempty(subj_group)
              [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
                 = rri_boot_check(num_rep, 1, num_boot, 0, ...
                   for_batch);
%                   boot_progress, for_batch);
           else

              if iscell(subj_group) 
                 [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
                   = ssb_rri_boot_check(subj_group, num_conditions, num_boot, 0, ...
                     for_batch);
              else
                [min_subj_per_group,is_boot_samples,boot_samples,new_num_boot] ...
                   = rri_boot_check(subj_group, num_conditions, num_boot, 0, ...
                     for_batch);
              end				% if iscell(subj_group)

%                   boot_progress, for_batch);
           end

           num_boot = new_num_boot;
        else
           min_subj_per_group=[];is_boot_samples=[];boot_samples=[];new_num_boot=[];
        end;

        if ~isempty(progress_hdl) & ishandle(progress_hdl), figure(progress_hdl); end;

        [brainlv,s,designlv,b_scores,d_scores,lvintercorrs,design, ...
            perm_result,boot_result,lv_evt_list] = ...
		fmri_taskpls_norotate(st_datamat,Clim,contrasts,num_conditions,...
			st_evt_list,num_boot,num_perm,subj_group, ...
         min_subj_per_group,is_boot_samples,boot_samples,new_num_boot);

        saved_info=['brainlv s designlv perm_result boot_result st_coords ', ...
  	         'st_dims lv_evt_list st_win_size st_voxel_size st_origin ', ...
                 'SessionProfiles ContrastFile b_scores d_scores design ', ...
		 'subj_group num_conditions cond_name cond_selection ', ...
		 'num_subj_lst subj_name lvintercorrs design ', ...
		 'session_files_timestamp datamat_files_timestamp create_ver'];

        if save_datamat & ~isempty(brainlv)
            last = 0;
%            grp_datamat = [];
            for g = 1:length(num_subj_lst)
               first = last + 1;

               if iscell(num_subj_lst)
                  last = first+sum(subj_group{g})-1;
               else
                  last = last + num_conditions*num_subj_lst(g);
               end

               [tmp idx] = sort(st_evt_list(first:last));
               tmp = st_datamat(first:last,:);
%               grp_datamat = [grp_datamat; tmp(idx,:)];
               grp_datamat{g} = tmp(idx,:);
            end;
        
            st_datamat = grp_datamat;
            datamat_lst = st_datamat;
            saved_info = [saved_info, ' datamat_lst'];
        end

     end

  end;


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

   saved_info = [saved_info, ' singleprecision SingleSubject method'];


  %  Requested by Nancy, because they no longer use "dp" or "dprob" to evaluate
  %  designlv
  %
  if ~isempty(perm_result) & ~isbehav
     perm_result = rmfield(perm_result, 'dp');
     perm_result = rmfield(perm_result, 'designlv_prob');
  end

end


  if exist('progress_hdl','var') & ishandle(progress_hdl)
     progress_bar = getappdata(gcf,'ProgressBar');
     set(progress_bar,'Position',[0 0 1 1],'Visible','on');
  end

  if ~for_batch
     disp('RunPLS is done ...');
  end

  if isempty(result)
     done = 1;
  else
     done = 0;
  end

  while ~done
    try
       %eval(['save ''' resultFile ''' ' saved_info]);
       eval(['save ''' resultFile ''' ' saved_info ' ' '-v7.3']);
       done = 1;
    catch
       if findstr('BfMRIsessiondata.mat', fn)
          [result_file,result_path] = rri_selectfile('*BfMRIresult.mat', ...
			'Can not write file, please try again');
       else
          [result_file,result_path] = rri_selectfile('*fMRIresult.mat', ...
			'Can not write file, please try again');
       end

       if isequal(result_file,0)		% Cancel was clicked
          resultFile = [];
          msg1 = ['WARNING: No file is saved.'];
%          uiwait(msgbox(msg1,'Uncompleted','modal'));
          return;
       else
          resultFile = fullfile(result_path,result_file);
       end;
    end
  end

  return; 					% fmri_pls_analysis


%-------------------------------------------------------------------------
function contrasts = load_contrast_file(contrastFile)

  load(contrastFile);

  num_contrasts = length(pls_contrasts);
  num_conditions = length(pls_contrasts(1).value);

  contrasts = zeros(num_conditions,num_contrasts);
  for i=1:num_contrasts,
     contrasts(:,i) = pls_contrasts(i).value';
  end;

  return;					% get_contrast


%-------------------------------------------------------------------------
function  [SessionProfiles,ContrastFile,num_perm,single_subj] = options_query()

  %  get the session profiles
  %
  num_session = 0;
  not_done = 1;
  while (not_done)
     msg = [ '\nEnter the name of file contains the session information ', ...
             '(Press <Enter> when done): '];
     sessionFile = input(msg,'s');

     if (isempty(sessionFile))
        not_done = 0;
     else
        if sessionFile(1) ~= '/',
            sessionFile = sprintf('%s/%s',pwd,sessionFile);
        end;
        num_session = num_session + 1;
        SessionProfiles{num_session} = sessionFile;
     end;
  end;


  msg = ['\nEnter the contrast file: ', ...
         '\n   (Type "HELMERT" for Helmert matrix or ', ...
         '\n    press <Enter> to use deviation from grand mean) '];
  ContrastFile = input(msg,'s');

  %  get the number of iterations for the permutation test 
  %
  num_perm = input('\nNumber of permutations: ');


  %  single subject analysis ?
  %
  single_subj_ans=input('\nDoes the data come from single subject? [Y/N] ','s');
  if (upper(single_subj_ans) == 'Y')
     single_subj = 1;
  else
     single_subj = 0;
  end;

  return;					% options_query


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
function [new_st_datamat, new_st_coords, st_dims, num_conditions, ...
	new_evt_list, win_size, voxel_size, origin, subj_group, ...
	subj_name, curr_conditions, num_behav_subj, ...
	newdata_lst, num_subj_lst, has_ssb ] = ...
		concat_st_datamat(behavdata, singleanalysis, ...
		SessionProfiles,progress_hdl, ...
		posthoc, cond_selection, has_unequal_subj)
%
%
   has_ssb = 0;
   newdata_lst = {};
   num_subj_lst = [];

   new_st_datamat = [];			%  stacked datamat
   new_st_coords = [];
   st_dims = [];
   num_conditions = [];
   new_evt_list = [];
   new_evt_list_lst = {};
   win_size = [];
   voxel_size = [];
   origin = [];
   subj_group = [];
   subj_name = {};
   curr_conditions = {};

   msg = sprintf('Merging datamats ...');
   ShowProgress(progress_hdl,msg);

   num_groups = length(SessionProfiles);

   profile_list = [];
   session_group = zeros(1,num_groups);

   for i=1:num_groups,
      session_group(i) = length(SessionProfiles{i});
      profile_list = [profile_list; SessionProfiles{i}];
      load(SessionProfiles{i}{1}, 'SingleSubject');

      if (exist('SingleSubject','var') & SingleSubject == 1 ) | has_unequal_subj
         subj_group = [];
         SingleSubject = 1;
         has_unequal_subj = 1;
      end
   end;

   num_profiles = length(profile_list);

   st_info = cell(1,num_profiles);

   %  get the coords ...
   %
   total_evts = 0;

   if ~has_unequal_subj
      subj_group = zeros(1,num_groups);
   end

   cnt = 0;

   fn = SessionProfiles{1}{1};

   for i=1:num_groups,
      for j=1:session_group(i),
         cnt = cnt+1;

         msg = sprintf('Get common coordinates ...');
         ShowProgress(progress_hdl,msg);

         sessionFile = profile_list{cnt};

         try
            warning off;

            load(sessionFile,'st_coords','st_dims','st_evt_list', ...
			'st_win_size','st_voxel_size','st_origin', ...
			'num_subj_cond','SingleSubject','session_info');
            warning on;
         catch
            disp(sprintf('ERROR: cannot open data file: %s',sessionFile));
            new_st_datamat = [];
            return;   
         end;

         curr_conditions = session_info.condition;

         %  get the st_datamat and st_evt_list 
         %
         datamat_prefix = session_info.datamat_prefix;

         curr = pwd;

         if isempty(curr)
            curr = filesep;
         end

         if exist('SingleSubject','var') & SingleSubject == 1
            has_ssb = 1;
         end

         st_info{cnt}.sessionFile = sessionFile;
         st_info{cnt}.num_cond = session_info.num_conditions;
         st_info{cnt}.coords = st_coords;
         st_info{cnt}.dims = st_dims;
         st_info{cnt}.evt_list = st_evt_list;
         st_info{cnt}.win_size = st_win_size;
         st_info{cnt}.voxel_size = st_voxel_size;
         st_info{cnt}.origin = st_origin;

         num_evts = length(st_evt_list);
         total_evts = total_evts + num_evts;

         if ~has_unequal_subj
            subj_group(i) = subj_group(i) + num_evts/length(curr_conditions);
         else
            num_subj_cond = num_subj_cond(find(cond_selection));

            if exist('SingleSubject','var') & SingleSubject == 1
               subj_group{i} = num_subj_cond;
            else
               if length(subj_group)>=i
                  subj_group{i} = subj_group{i} + num_subj_cond;
               else
                  subj_group{i} = num_subj_cond;
               end
            end
         end

         if (cnt > 1),	% make sure the st_datamat are compatible
            if (st_info{cnt-1}.dims ~= st_info{cnt}.dims),
               msg = 'The datamats have different volume dimension.';
               ShowProgress(progress_hdl,['ERROR: ', msg]);
               disp(msg);
               return;
            end;
   
            if (st_info{cnt-1}.win_size ~= st_info{cnt}.win_size),
               msg = 'The datamats have different window size.';
               ShowProgress(progress_hdl,['ERROR: ', msg]);
               disp(msg);
               return;
            end;

            if (st_info{cnt-1}.dims ~= st_info{cnt}.dims),
               msg = 'The datamats have different volume dimension.';
               ShowProgress(progress_hdl,['ERROR: ', msg]);
               disp(msg);
               return;
            end;

            if (st_info{cnt-1}.voxel_size ~= st_info{cnt}.voxel_size),
               msg = 'The datamats have different voxel size.';
               ShowProgress(progress_hdl,['ERROR: ', msg]);
               disp(msg);
               return;
            end;
   
            if ~isequal(curr_conditions,prev_conditions)
               msg='The datamats are created from different conditions.';
               ShowProgress(progress_hdl,['ERROR: ', msg]);
               disp(msg);
               return;
            end;
         end;  % (cnt > 1)
   
         prev_conditions = curr_conditions;
      end;
   end;

   num_conditions = length(curr_conditions);  
   st_dims = st_info{1}.dims; 

   %  determine the common coords ...
   %
   m = zeros(1,prod(st_info{1}.dims));

   for i=1:num_profiles
      m(st_info{i}.coords) = m(st_info{i}.coords) + 1;
   end;

   new_st_coords = find(m == num_profiles);

   if isempty(new_st_coords)
      disp('ERROR: no common coords among datamats!');
      new_st_datamat = [];
      return;
   end

   %  stack the st_datamat together
   %
   win_size = st_info{1}.win_size;
   voxel_size = st_info{1}.voxel_size;

   if isempty(st_info{1}.origin) | isequal(st_info{1}.origin,[0 0 0]),
      origin = floor(st_dims([1 2 4])/2); 
   else
      origin = st_info{1}.origin;
   end;

   num_voxels = length(new_st_coords);
   first_row = 1;
   first_cond_order = [];

   %  go through each subject, which is represented by each profile
   %
   tmp_new_st_datamat = [];
   cnt=0;

   for i=1:num_groups,

      grp_tmp_new_st_datamat = [];
      grp_tmp_new_evt_list = [];
      grp_first_cond_order = [];
      grp_subj_cond_name = {};

      if has_unequal_subj
         num_subj_cond = subj_group{i};
         cnt2 = cnt+1;
         load(st_info{cnt2}.sessionFile,'SingleSubject');

%         for ii = 1:length(num_subj_cond)		% length(num_subj_cond) is num_cond
         for ii = find(cond_selection)			% cond_selection could be [1 0 1 1]
            subj_cond_name = {};

            for jj = 1:num_subj_cond(ii)
               if exist('SingleSubject','var') & SingleSubject == 1
                  load(st_info{cnt2}.sessionFile);
                  Subj = session_info.datamat_prefix;
                  subj_cond_name = [subj_cond_name, {[Subj, '_Onset', num2str(jj)]}];
               elseif jj == 1
                  cnt2 = cnt;
                  for iii=1:session_group(i),
                     cnt2 = cnt2+1;
                     load(st_info{cnt2}.sessionFile);
                     Subj = session_info.datamat_prefix;
                     subj_cond_name = [subj_cond_name, {[Subj]}];
                  end
               end
            end

            grp_subj_cond_name = [grp_subj_cond_name, {subj_cond_name}];
         end

         subj_name = [subj_name, {grp_subj_cond_name}];
      end

      for j=1:session_group(i),
         cnt = cnt+1;

         ShowProgress(progress_hdl,cnt/(num_profiles));
         msg = sprintf('Loading datamat: %d out of %d',cnt,num_profiles);
         ShowProgress(progress_hdl,msg);

         load(st_info{cnt}.sessionFile);
         Subj = session_info.datamat_prefix;

         if singleanalysis
            st_datamat = single(st_datamat);
         else
            st_datamat = double(st_datamat);
         end

         coord_idx = find( m(st_info{cnt}.coords) == num_profiles ); 
         nr = length(st_info{cnt}.evt_list);	% number of runs
         nc = length(st_info{cnt}.coords);
         last_row = nr + first_row - 1; 

         this_subj_order = zeros(1, nr);
         first_cond = 1;
         jj = 1;

         %  get first_cond of each run
         %
         while first_cond <= nr
            this_subj_order(first_cond) = 1;
            first_cond = first_cond + num_conditions;

            if ~has_unequal_subj
               if exist('SingleSubject','var') & SingleSubject == 1
                  subj_name = [subj_name, {[Subj, '_Onset', num2str(jj)]}];
               else
                  if str2num(create_ver) < 4.0512201
                     subj_name = [subj_name, {['Subj', num2str(cnt), 'Run', num2str(jj)]}];
                  else
                     subj_name = [subj_name, {[Subj]}];
                  end
               end
            end		% if ~has_unequal_subj

            jj = jj + 1;
         end

         first_cond_order = [first_cond_order, this_subj_order];
         grp_first_cond_order = [grp_first_cond_order, this_subj_order];	% for behavpls

         %  stack datamat
         %
         tmp_datamat = reshape(st_datamat,[nr,win_size,nc]);
         tmp_new_st_datamat = ...
		reshape(tmp_datamat(:,:,coord_idx),[nr,win_size*num_voxels]);
         tmp_evt_list = st_info{cnt}.evt_list;

         grp_tmp_new_st_datamat = [grp_tmp_new_st_datamat; tmp_new_st_datamat];
         grp_tmp_new_evt_list = [grp_tmp_new_evt_list, tmp_evt_list];

         clear st_datamat tmp_datamat;
         first_row = last_row + 1;
      end;				% session_group j

      [grp_tmp_new_evt_list idx] = sort(grp_tmp_new_evt_list);
    
      new_evt_list = [new_evt_list, grp_tmp_new_evt_list];
      new_st_datamat = [new_st_datamat; grp_tmp_new_st_datamat(idx,:)];

      %  Deselect Conditions
      %
      [mask, grp_tmp_new_evt_list, evt_length] = ...
		fmri_mask_evt_list(grp_tmp_new_evt_list, cond_selection);

      datamat_in_grp = grp_tmp_new_st_datamat(idx,:);
      newdata_lst{i} = datamat_in_grp(mask,:);

   end					% num_group i

   %  "num_behav_subj" was "num_subj". 
   %  It is not in use, because we have "num_subj_lst"
   %
   num_behav_subj = [];

   %  Deselect Conditions
   %
   num_conditions = sum(cond_selection);
   curr_conditions = curr_conditions(find(cond_selection));

   [mask, new_evt_list, evt_length] = ...
	fmri_mask_evt_list(new_evt_list, cond_selection);

   new_st_datamat = new_st_datamat(mask,:);

   %  validate posthoc data
   %
   if ~isempty(posthoc)
      num_behavdata_col = size(behavdata,2);
      [r_posthoc,c_posthoc] = size(posthoc);

      if r_posthoc ~= num_behavdata_col * num_conditions * num_groups
         msg = sprintf('Rows in Posthoc data file do not match.');
         ShowProgress(progress_hdl,['ERROR: ', msg]);
         uiwait(msgbox(msg,'ERROR','modal'));
         new_st_datamat = [];
         return;
      end
   end

   num_subj_lst = subj_group;

   return;					% concat_st_datamat

