function [status,allbehavname,allbehavdata,behavdata_lst,new_evt_list,newdata_lst] = ...
	smallfc_get_behavior(datamat_lst, cond_selection)

  status = 1;
  allbehavname = {};
  allbehavdata = [];
  behavdata_lst = {};
  new_evt_list = [];
  newdata_lst = {};

  num_groups = length(datamat_lst);

  for i = 1:num_groups,
     datamatFile = datamat_lst{i};
     load(datamatFile,'session_info');
     curr_conditions = session_info.condition;
     num_conditions = session_info.num_conditions;
     num_subjects = session_info.num_subjects;
     selected_subjects = ones(num_subjects,1);
     bmask = selected_subjects * cond_selection;
     bmask = find(bmask(:));

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

     prev_conditions = curr_conditions;
     newdata_lst{i} = 1:length(bmask);
     new_evt_list = [new_evt_list newdata_lst{i}];
  end;

  return;

