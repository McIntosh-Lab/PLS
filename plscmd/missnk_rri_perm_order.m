function perm_order = missnk_rri_perm_order(num_subj_lst, num_cond, num_perm, not_in_cond)
%
%  USAGE:  perm_order = missnk_rri_perm_order(num_subj_lst, num_cond, num_perm)
%   
%  Method:  
%     There are 2 steps to generate the permutation orders.  First permute 
%     tasks within each subject, then apply permutation for subjects across
%     groups.
%
%  Note: In this NK version, the first sample is unpermuted data
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

  num_subj_grp = sum(num_subj_lst);
  total_rows = num_subj_grp * num_cond;
  row_idx = 1:total_rows;

  perm_order = zeros(total_rows,num_perm);

  %  set first as sequental order
  %
  perm_order(:,1) = row_idx';
  
  vernum = get_matlab_version;
  if vernum < 7002
     rand('state',sum(100*clock));
  elseif vernum < 7013
     rand('twister',sum(100*clock));
  else
     rng_default; rng_shuffle;
  end

  for p=2:num_perm,

     cnt = 0;
     duplicated = 1;

     while (duplicated)
        cnt = cnt+1;

        first = 1;
        last = 0;
        task_group = [];

        for g=1:length(num_subj_lst)
           last = last + num_cond*num_subj_lst(g);
           tmp = reshape([first:last],num_subj_lst(g),num_cond);
           task_group = [task_group, tmp'];
           first = last + 1;
        end
      
        origin_task_group = task_group;

        %  exclude this block (to swap conditions for each subject)
        %  for structure Non-Behavior PLS
        %
        if ~not_in_cond

           %  permute tasks within each group.
           %
           for i = 1:num_subj_grp,
              task_perm = randperm(num_cond);
              task_group(:,i) = task_group(task_perm,i);
           end
        end
      
        %  permute tasks across groups
        %
        group_perm = randperm(num_subj_grp);
        task_group = task_group(:,group_perm);
      
        %  make sure the average is not the same as original for
        %  @cond and for @group. will mark it as duplicate for invalid one
        %
        duplicated = 0;

       if num_cond > 1

        for c=1:num_cond
           accum = 0;

           for g=1:length(num_subj_lst)
              if isequal(sort(task_group(c,(accum+1):(accum+num_subj_lst(g)))), origin_task_group(c,(accum+1):(accum+num_subj_lst(g))))
                 duplicated = 1; % cond avg is the same as the origin
              end

              accum = accum + num_subj_lst(g);
           end
        end

       end

        new_perm_order = [];
        for g=1:length(num_subj_lst)
           tmp = ...
              task_group(:,[sum(num_subj_lst(1:(g-1)))+1:sum(num_subj_lst(1:g))]);
           tmp = reshape(tmp', [num_cond*num_subj_lst(g),1]);

           new_perm_order = [new_perm_order; tmp];
        end

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
%        if isequal([1:total_rows]', new_perm_order)
 %          duplicated = 1;
  %      end

        if (cnt > 500),
           duplicated = 0;
           disp('ERROR:  Duplicated permutation orders are used!');
        end;

    end;  % while (duplicated)

    perm_order(:,p) = new_perm_order;

  end;  % for num_perm

  return;

