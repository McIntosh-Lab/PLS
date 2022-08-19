function perm_order = missnk_rri_perm_order_notall(num_subj_lst, num_cond, num_perm, bscan, not_in_cond)

  if ~exist('bscan','var')
    bscan = 1:num_cond;
  end

  if ~exist('not_in_cond','var')
    not_in_cond = 0;
  end

  num_subj_grp = sum(num_subj_lst);
  total_rows = num_subj_grp * num_cond;

  num_bcond = length(bscan);
  bcond_rows = num_subj_grp * num_bcond;

   mask = zeros(1, total_rows);

   for g = 1:length(num_subj_lst)
      gmask = zeros(1, total_rows);
      n = num_subj_lst(g);
      span = sum(num_subj_lst(1:g-1)) * num_cond;

      for i = bscan
         mask( span+1+n*(i-1) : span+n*i ) = 1;
         gmask( span+1+n*(i-1) : span+n*i ) = 1;
      end

      grow_idx{g} = find(gmask);
   end

  row_idx = find(mask);

  perm_order = zeros(bcond_rows,num_perm);

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

        task_group = [];

        for g=1:length(num_subj_lst)
           tmp = reshape(grow_idx{g},num_subj_lst(g),num_bcond);
           task_group = [task_group, tmp'];
        end
      
        origin_task_group = task_group;

        %  exclude this block (to swap conditions for each subject)
        %  for structure Non-Behavior PLS
        %
        if ~not_in_cond

           %  permute tasks within each group.
           %
           for i = 1:num_subj_grp,
              task_perm = randperm(num_bcond);
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

       if num_bcond > 1

        for c=1:num_bcond
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
           tmp = reshape(tmp', [num_bcond*num_subj_lst(g),1]);

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

   template = mask4bscan(num_subj_lst, num_cond, bscan);
   mat = repmat([1:total_rows]', [1 num_perm]);
   mat(template,:) = perm_order;
   perm_order = mat;

  return;

