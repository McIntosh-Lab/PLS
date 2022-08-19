function [boot_order, new_num_boot] ...
   = rri_boot_order(num_subj_lst, num_cond, num_boot, bscan, incl_seq)

%  ssb_rri_boot_order.m  is modified based on  rri_boot_order.m.
%  Because the number of subjects (i.e. fMRI onsets) can be different
%  in different conditions, the bootstrap pattern can no longer be
%  propagated to all conditions for that group.

   if ~exist('bscan','var')
      bscan = 1:num_cond;
   end

   if ~exist('incl_seq','var')
      incl_seq = 0;
   end

   num_subj_lst0 = num_subj_lst;
   num_subj_lst = [];
   start_subj0 = 1;
   start_subj = [];
   k = 1;

   for i=1:length(num_subj_lst0)
      for j=1:length(num_subj_lst0{i})
         if ismember(j, bscan)
            start_subj = [start_subj start_subj0(k)];
         end

         tmp = num_subj_lst0{i}(j) + start_subj0(end);
         start_subj0 = [start_subj0 tmp];
         k = k + 1;
      end

      num_subj_lst = [num_subj_lst {num_subj_lst0{i}(bscan)}];
   end

   total_subj0 = [num_subj_lst0{:}];
   total_subj = [num_subj_lst{:}];
   num_group0 = length(total_subj0);
   num_group = length(total_subj);
   num_cond0 = num_cond;
   num_cond = length(bscan);
   total_rows0 = sum(total_subj0);
   total_rows = sum(total_subj);
   boot_order = [];
   new_num_boot = num_boot;

   %  if num_subj <=8 for all groups then create all theoretically possible
   %  boot samples
   %
   [min_subj_per_group, is_boot_samples, boot_samples, new_num_boot] = ...
	ssb_rri_boot_check(num_subj_lst, num_cond, num_boot, incl_seq);

   %
   boot_order = zeros(total_rows, new_num_boot);

   for p=1:new_num_boot,

      subj_order = cell(1,num_group);
      not_done = 1;
      cnt = 0;

      while (not_done)
         for g = 1:num_group
            num_subj = total_subj(g);

            %  reorder tasks for the current group.
            all_samples_are_same = 1;

            while (all_samples_are_same)
               not_done = 1;

               new_subj_order = floor(rand(1,num_subj)*num_subj) + 1;
               test=length(unique(new_subj_order));

               % check to make sure there are at lease min_subj_per_group people
               %
               if (test >= min_subj_per_group)
                  all_samples_are_same = 0;
               end;
            end;

            subj_order{g} = new_subj_order + start_subj(g) - 1;
         end;

         %  make sure the order is not a repeated one
         not_done = 0;
         for i=1:p-1,
            if isequal(squeeze(boot_order(:,i)),subj_order)
               not_done = 1;
               break;
            end;
         end;

        %  treat sequential order as duplicated one
        %
        if ~incl_seq & isequal([1:total_rows], [subj_order{:}])
           not_done = 1;
        end

         %  discard if all elements are the same
         cnt = cnt+1;
         if (cnt > 500),
            not_done = 0;
            disp('ERROR:  Duplicated bootstrap orders are used!');
         end;
      end;		% while (not_done)

      boot_order(:,p) = [subj_order{:}]';

   end;  % for new_num_boot

   template = mask4bscan(num_subj_lst0, num_cond0, bscan);
   boot_order0 = repmat([1:total_rows0]', [1 new_num_boot]);
   boot_order0(template,:) = boot_order;
   boot_order = boot_order0;

   return;

