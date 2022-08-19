function [status,behavname,behavdata,behavdata_lst,new_evt_list,newdata_lst] = ...
	fmri_get_behavior(SessionProfiles, cond_selection)

  status = 1;
  behavname = {};
  behavdata = [];
  behavdata_lst = {};

  new_evt_list = [];
  newdata_lst = {};
  num_conditions = [];
  new_behavdata = [];			%  stacked behavdata
  curr_conditions = {};

  num_groups = length(SessionProfiles);

  profile_list = [];
  session_group = zeros(1,num_groups);
  for i=1:num_groups,
     session_group(i) = length(SessionProfiles{i}.name);
     profile_list = [profile_list; SessionProfiles{i}.name];
  end;
  num_profiles = length(profile_list);

  st_info = cell(1,num_profiles);

  %  get the coords ...
  %
  total_evts = 0;
  subj_group = zeros(1,num_groups);
  cnt = 0;

  fn = SessionProfiles{1}.name{1};

  for i=1:num_groups,
      for j=1:session_group(i),
       cnt = cnt+1;

       sessionFile = profile_list{cnt};
       load(sessionFile);
       curr_conditions = session_info.condition;

        %  get the st_datamat and st_evt_list 
        %
        datamat_prefix = session_info.datamat_prefix;

        if findstr('BfMRIsessiondata.mat', fn)
           st_datamatFile = sprintf('%s_BfMRIsessiondata.mat',datamat_prefix);
        else
           st_datamatFile = sprintf('%s_fMRIsessiondata.mat',datamat_prefix);
        end

%        st_datamatFile = fullfile(session_info.pls_data_path,st_datamatFile);

	try
           clear('behavdata');
           warning off;

           load(st_datamatFile,'st_evt_list','behavdata','behavname','SingleSubject','unequal_subj');
           warning on;
	catch
           msg = sprintf('ERROR: cannot open data file: %s',st_datamatFile);
           set(findobj(gcf,'Tag','MessageLine'),'String',msg);

           status = 0;
           behavname = {};
           behavdata = [];
           behavdata_lst = {};
	   return;   
	end;

        if ~exist('behavdata','var')
            behavdata = [];
        end

        if ~exist('behavname','var')
            behavname = {};
            for bcol=1:size(behavdata, 2)
               behavname = [behavname, {['behav', num2str(bcol)]}];
            end
        end

        if ~exist('SingleSubject','var')
            SingleSubject = 0;
        end

        if ~exist('unequal_subj','var')
            unequal_subj = 0;
        end

        if cnt > 1				% check behavcol among profiles

           if ~isequal(behavname, st_info{cnt-1}.behavname)
              status = 2;
           end

        end

        st_info{cnt}.evt_list = st_evt_list;
        st_info{cnt}.behavdata = behavdata;
        st_info{cnt}.behavname = behavname;
        st_info{cnt}.SingleSubject = SingleSubject;
        st_info{cnt}.unequal_subj = unequal_subj;

        if isempty(behavdata)			% check behavdataempty

           status = 2;

        end

        if (cnt > 1),	% make sure the st_datamat are compatible
           if ~isequal(curr_conditions,prev_conditions)
              msg = sprintf('ERROR: The datamats are created from different conditions');
              set(findobj(gcf,'Tag','MessageLine'),'String',msg);

              status = 0;
              behavname = {};
              behavdata = [];
              behavdata_lst = {};
              return;
           end;
        end;  % (2nd cnt > 1)

        prev_conditions = curr_conditions;

    end;
  end;

  num_conditions = length(curr_conditions);

  first_row = 1;

  first_cond_order = [];

  num_behavdata_col = size(st_info{1}.behavdata,2);

  cnt=0;

  for i=1:num_groups,

    grp_tmp_new_st_datamat = [];
    grp_tmp_new_behavdata = [];
    grp_first_cond_order = [];

    for j=1:session_group(i),
       cnt = cnt+1;

       nr = length(st_info{cnt}.evt_list);	% number of runs
       last_row = nr + first_row - 1; 

       %  stack behavdata and get behavmask (re-order for each session file
       %  to make it 'each condition in each run (yes, reversed)'
       %
       if status ~= 2

          tmp_new_behavdata = st_info{cnt}.behavdata(:,1:num_behavdata_col);

          behavmask = 1:size(tmp_new_behavdata,1);

          %  nrr could be nr, depend on 'across run' or 'within run'
          %
          nrr = size(tmp_new_behavdata,1) / num_conditions;

          behavmask = reshape(behavmask, [nrr, num_conditions]);
          behavmask = behavmask';
          behavmask = reshape(behavmask, [size(tmp_new_behavdata,1),1]);

          tmp_new_behavdata = tmp_new_behavdata(behavmask,:);

          grp_tmp_new_behavdata = [grp_tmp_new_behavdata; tmp_new_behavdata];
          new_behavdata = [new_behavdata; tmp_new_behavdata];

       end	% if status ~= 2

       this_subj_order = zeros(1, nr);
       first_cond = 1;

       %  get first_cond of each run
       %
       while first_cond <= nr
          this_subj_order(first_cond) = 1;
          first_cond = first_cond + num_conditions;
       end

       first_cond_order = [first_cond_order, this_subj_order];
       grp_first_cond_order = [grp_first_cond_order, this_subj_order];	% for behavpls


       %  stack datamat
       %
       tmp_evt_list = st_info{cnt}.evt_list;

       if status ~= 2
          tmp_evt_list = tmp_evt_list(behavmask);
       end

       grp_tmp_new_st_datamat = [grp_tmp_new_st_datamat tmp_evt_list];

       first_row = last_row + 1;

    end;				% session_group j

    grp_subj_mask = [];

    for ii = 1:num_conditions
       grp_subj_mask = [grp_subj_mask, find(grp_first_cond_order)];
       grp_first_cond_order = [grp_first_cond_order(end), grp_first_cond_order(1:end-1)];
    end

    if ~isempty(grp_tmp_new_behavdata)
       grp_tmp_new_behavdata = grp_tmp_new_behavdata(grp_subj_mask,:);
    end

    grp_tmp_new_st_datamat = grp_tmp_new_st_datamat(grp_subj_mask);

    behavdata_lst{i} = grp_tmp_new_behavdata;
    newdata_lst{i} = grp_tmp_new_st_datamat;

    if st_info{cnt}.SingleSubject
       newdata_lst{i} = st_info{cnt}.evt_list;
    end

  end					% num_group i


  %  Deselect Conditions
  %
  for i = 1:length(newdata_lst)		% go through new_evt_list_lst

     new_evt_list = newdata_lst{i};

     [mask, new_evt_list, evt_length] = ...
		fmri_mask_evt_list(new_evt_list, cond_selection);

     newdata_lst{i} = new_evt_list;

     if status ~= 2
        behavdata = behavdata_lst{i};
        behavdata_lst{i} = behavdata(mask,:);
     end

  end


  behavdata = [];
  new_evt_list = [];

  for i=1:num_groups,
     behavdata = [behavdata; behavdata_lst{i}];
     new_evt_list = [new_evt_list newdata_lst{i}];
  end

  if status == 2
     status = 1;
     behavname = {};
     behavdata = [];
     behavdata_lst = {};
  end

  return;

