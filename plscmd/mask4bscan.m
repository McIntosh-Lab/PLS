function mask = mask4bscan(num_subj_lst, num_cond, bscan)

   if ~exist('bscan','var')
      bscan = 1:num_cond;
   end

   mask = [];

   if ~iscell(num_subj_lst)
      start_subj = 0;

      for g=1:length(num_subj_lst)
         n = num_subj_lst(g);
         mat = zeros(n, num_cond);
         mat(:,bscan) = 1;
         mask = [mask; start_subj + find(mat(:))];
         start_subj = start_subj + length(mat(:));
      end
   else
      for g=1:length(num_subj_lst)
         n = num_subj_lst{g};

         for i=1:length(n)
            if ismember(i,bscan)
               mask = [mask; ones(n(i),1)];
            else
               mask = [mask; zeros(n(i),1)];
            end
         end
      end

      mask = find(mask);
   end

   return;

