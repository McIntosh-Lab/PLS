function [mask, st_evt_list, evt_length] = fmri_mask_evt_list(st_evt_list, cond_selection)

%   cond_selection = getappdata(gcf,'cond_selection');

   if isempty(cond_selection) | isempty(find(cond_selection == 0))

      evt_length = length(st_evt_list);
      mask = 1:evt_length;
      return;

   end;

   deselected_cond = find(cond_selection == 0);
   matched_cond = deselected_cond;

   tmp_evt_list = st_evt_list;
   mask = ones(1, length(tmp_evt_list));

   for j = 1:length(deselected_cond)
      mask(find(tmp_evt_list == deselected_cond(j))) = 0;
      st_evt_list(find(tmp_evt_list == deselected_cond(j))) = 0;

      for k = 1:length(st_evt_list)
         if st_evt_list(k) > matched_cond(j)
            st_evt_list(k) = st_evt_list(k) - 1;
         end
      end

      matched_cond = matched_cond - 1;
   end

   mask = find(mask);
   st_evt_list = st_evt_list(mask);
   evt_length = length(st_evt_list);

   return;

