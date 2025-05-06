function stacked_datamat = stacking_datamat(datamat_lst, single_cond_lst, progress_hdl,silencerepro)

   if ~exist('single_cond_lst','var')
      single_cond_lst = [];
   end

   if ~exist('progress_hdl','var')
      progress_hdl = [];
   end

   if ~exist('silencerepro','var')
      silencerepro = 0;
   end
   num_groups = length(datamat_lst);

   %  init variable for the following loop
   %
   stacked_datamat = [];

   %  loop accross the groups, and
   %  calculate datamatcorrs for each group
   %
   if isempty(progress_hdl) && silencerepro==0
        fprintf('Stacking datamat from group:');
   end

   for g = 1:num_groups

      if isempty(progress_hdl) && silencerepro ==0
         fprintf(' %d', g);
      end

      if isempty(single_cond_lst)
         datamat = datamat_lst{g};
         stacked_datamat = [stacked_datamat; datamat];
      elseif g==1
         datamat = single_cond_lst{1};
         stacked_datamat = [stacked_datamat; datamat];	% only do once
      end
   end

   if isempty(progress_hdl) && silencerepro==0
      fprintf('\n');
   end

   return					% stacking_datamat

