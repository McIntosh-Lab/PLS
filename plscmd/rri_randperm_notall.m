function reorder = rri_randperm_notall(num_subj_lst, num_cond, bscan)

   total_rows = sum(num_subj_lst*num_cond);
   reorder = 1 : total_rows;
   mask = zeros(1, total_rows);

   for g = 1:length(num_subj_lst)
      n = num_subj_lst(g);
      span = sum(num_subj_lst(1:g-1)) * num_cond;

      for i = bscan
         mask( span+1+n*(i-1) : span+n*i ) = 1;
      end
   end

   mask2 = find(mask);
   mask3 = mask2(randperm(length(mask2)));
   reorder(mask2) = mask3;

   return;

