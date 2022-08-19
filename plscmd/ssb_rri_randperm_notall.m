function reorder = rri_randperm_notall(num_subj_lst, num_cond, bscan)

   total_rows = sum([num_subj_lst{:}]);
   reorder = 1 : total_rows;
   mask = zeros(1, total_rows);
   step = 0;

   for g = 1:length(num_subj_lst)
      n = num_subj_lst{g};

      for i=1:max(bscan)
         if ismember(i, bscan)
            mask((1:n(i))+step) = 1;
         end

         step=step+n(i);
      end
   end

   mask2 = find(mask);
   mask3 = mask2(randperm(length(mask2)));
   reorder(mask2) = mask3;

   return;

