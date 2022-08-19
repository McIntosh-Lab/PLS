function perm_order = rri_perm_order(num_subj_lst, num_cond, num_perm, not_in_cond)
%
%  USAGE:  perm_order = rri_perm_order(num_subj_lst, num_cond, num_perm)
%   
%  Method:  
%     There are 2 steps to generate the permutation orders.  First permute 
%     tasks within each subject, then apply permutation for subjects across
%     groups.  
%
%  Input:
%         num_subj_lst: a N elements vector, each element specifies
%			the number of subjects of one of the groups.
%         num_cond:	number of conditions in the experiment
%         num_perm:	number of permutation to be performed
%         not_in_cond:	do not permute conditions within a group for
%			structure Non-Behavior PLS
%
%  Output: 
%        perm_order:	an MxN matrix that stores the new order for 
%			the N permutations, where M is the total number
%			of rows of the st_datamat.
%			(i.e M = num_subj_grp * num_cond)
%

  if ~exist('not_in_cond','var')
     not_in_cond = 0;
  end

  %  treat condition as group for single_subject case
  %  however, duplication will still be taken care of

  total_rows = sum([num_subj_lst{:}]);
  perm_order = zeros(total_rows,num_perm);

  vernum = get_matlab_version;
  if vernum < 7002
     rand('state',sum(100*clock));
  elseif vernum < 7013
     rand('twister',sum(100*clock));
  else
     rng_default; rng_shuffle;
  end

  for p=1:num_perm,

     cnt = 0;
     duplicated = 1;

     while (duplicated)
        cnt = cnt+1;

        %  permute tasks across groups (treat condition as group for single_subject case)
        %
        task_group = randperm(total_rows);
        origin_task_group = task_group;

        %  make sure the average is not the same as original for
        %  @cond and for @group. will mark it as duplicate for invalid one
        %
        duplicated = 0;
        accum = 0;

        subj_group = [num_subj_lst{:}];

        for g=1:length(subj_group)
           if isequal(sort(task_group((accum+1):(accum+subj_group(g)))), origin_task_group((accum+1):(accum+subj_group(g))))
              duplicated = 1;			% cond avg is the same as the origin
           end

           accum = accum + subj_group(g);
        end

        new_perm_order = task_group(:);

        %  make sure the permuation order is not a repeated one
        %
%        duplicated = 0;
        for i=1:p-1,
           if isequal(perm_order(:,i),new_perm_order)
               duplicated = 1;
               break;
           end;
        end;

        %  treat sequential order as duplicated one
        %
        if isequal([1:total_rows]', new_perm_order)
           duplicated = 1;
        end

        if (cnt > 500),
            duplicated = 0;
            disp('ERROR:  Duplicated permutation orders are used!');
        end;

     end;  % while (duplicated)

     perm_order(:,p) = new_perm_order;

  end;  % for num_perm

  return;

