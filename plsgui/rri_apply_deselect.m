function datamat_lst = rri_apply_deselect(datamat_lst, num_subj, cond_selection)

   k = length(cond_selection);

   for g = 1:length(datamat_lst)
      datamat = datamat_lst{g};
      n = num_subj(g);

      idx = zeros(n,k);
      idx(:, find(cond_selection)) = 1;
      idx = find(idx);

      datamat_lst{g} = datamat(idx,:);
   end

   return;

