function [status,allbehavname,allbehavdata,behavdata_lst,new_evt_list,newdata_lst] = ...
	pet_get_behavior(datamat_lst, cond_selection)

  status = 1;
  allbehavname = {};
  allbehavdata = [];
  behavdata_lst = {};
  new_evt_list = [];
  newdata_lst = {};

  num_groups = length(datamat_lst);

  for i = 1:num_groups,
     datamatFile = datamat_lst{i};
     load(datamatFile);		% ,'session_info','behavdata','behavname');

     if(~isfield(session_info,'behavname'))
         session_info.behavname = {};
         for j=1:size(session_info.behavdata, 2)
            session_info.behavname = [session_info.behavname, {['behav', num2str(j)]}];
         end
         selected_behav = ones(1, size(session_info.behavdata, 2));
     end

     if sum(cond_selection) > sum(selected_conditions)
        status = 0;
        behavname = {};
        behavdata = [];
        behavdata_lst = {};
        return;
     end

     if i <2
        prev_conditions = session_info.condition(find(selected_conditions));
        prev_behavname = session_info.behavname;
        prev_select = selected_behav;
     end

     curr_behavname = session_info.behavname;
     curr_select = selected_behav;

     if ~isequal(curr_behavname,prev_behavname)...
	    | ~isequal(curr_select, prev_select)
        status = 0;
        behavname = {};
        behavdata = [];
        behavdata_lst = {};
        return;
     else
        prev_behavname = curr_behavname;
        prev_select = curr_select;
     end;

     behavdata = session_info.behavdata(:, find(selected_behav));
     behavname = session_info.behavname(find(selected_behav));

     curr_conditions = session_info.condition(find(selected_conditions));
%     curr_conditions = session_info.condition;
%     num_conditions = session_info.num_conditions;
%     num_subjects = session_info.num_subjects;
%     selected_subjects = ones(num_subjects,1);

     selected_conditions_idx = find(selected_conditions);
     new_cond_selection = zeros(1, length(selected_conditions));
     new_cond_selection(selected_conditions_idx(find(cond_selection))) = 1;

     bmask = selected_subjects' * new_cond_selection;
     bmask = find(bmask(:));

     if i > 1				% check behavcol among profiles
        if ~isequal(behavname, allbehavname)
           status = 2;
        end
     end

     if isempty(behavdata)			% check behavdataempty
        status = 2;
     end

     if (i > 1),	% make sure the st_datamat are compatible
        if ~isequal(curr_conditions,prev_conditions)
           msg = sprintf('ERROR: The datamats are created from different conditions');
           set(findobj(gcf,'Tag','MessageLine'),'String',msg);

           status = 0;
           behavname = {};
           behavdata = [];
           behavdata_lst = {};
           return;
        end;
     end;

     if ~isempty(behavdata)
        behavdata = behavdata(bmask,:);
     end

     prev_conditions = curr_conditions;
     allbehavname = behavname;
     allbehavdata = [allbehavdata; behavdata];
     behavdata_lst{i} = behavdata;
     newdata_lst{i} = 1:length(bmask);
     new_evt_list = [new_evt_list newdata_lst{i}];
  end;

  if status == 2
     status = 1;
     allbehavname = {};
     allbehavdata = [];
     behavdata_lst = {};
  end

  return;

