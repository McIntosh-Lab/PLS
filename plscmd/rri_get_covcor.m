%RRI_GET_COVCOR  Prepares covariance/correlation data to calculate SVD
%	or crossblock.
%
%  Usage: [datamatsvd, datamatsvd_unnorm, datamatcorrs_lst, stacked_smeanmat] = ...
%	rri_get_covcor(method, stacked_datamat, stacked_behavdata, num_groups, ...
%		num_subj_lst, num_cond, bscan, meancentering_type, cormode, ...
%		single_cond_lst, is_observation, num_boot, datamat_reorder, ...
%		behavdata_reorder, datamat_reorder_4beh)
%
%  Input:
%
%  method - same input as in pls_analysis
%  stacked_datamat - stacked from input datamat_lst in pls_analysis
%  stacked_behavdata - same input as pls_analysis
%  num_groups - number of groups for PLS calculation
%  num_subj_lst - same input as pls_analysis
%  num_cond - same input as pls_analysis
%  bscan - same input as pls_analysis
%  meancentering_type - same input as pls_analysis
%  cormode - same input as pls_analysis
%  single_cond_lst - when there is only one condition, the groups will
%		be treated as conditions.
%  is_observation - stacked_smeanmat is only calculated when
%		is_observation is 1.
%  num_boot - same input as pls_analysis. stacked_smeanmat is only 
%		calculated when num_boot is geater than 0.
%  datamat_reorder - reorder index for stacked_datamat
%  behavdata_reorder - reorder index for stacked_behavdata
%  datamat_reorder_4beh - reorder index for stacked_datamat in behavior block of multiblock analysis
%		( In multiblock PLS, behavior block can have less conditions, so it needs different
%		  reorder index. In addition, in multiblock permutation, only task block requires
%		  to be permuted)
%
%  Output:
%
%  datamatsvd - stacked covariance / correlation data
%  datamatsvd_unnorm - stacked covariance / correlation data in multiblock
%			PLS before normalize
%  datamatcorrs_lst - correlation cell array
%  stacked_smeanmat - matrix to calculate "Task PLS Brain Scores with CI"
%
function [datamatsvd, datamatsvd_unnorm, datamatcorrs_lst, stacked_smeanmat] = ...
	rri_get_covcor(method, stacked_datamat, stacked_behavdata, num_groups, ...
		num_subj_lst, num_cond, bscan, meancentering_type, cormode, ...
		single_cond_lst, is_observation, num_boot, datamat_reorder, ...
		behavdata_reorder, datamat_reorder_4beh)

   if ~exist('datamat_reorder_4beh','var')
      datamat_reorder_4beh = [1:size(stacked_datamat,1)]';
   end

   %  init variable for the following loop
   %
   datamatsvd = [];
   datamatsvd_unnorm = [];	% multiblock PLS before normalize
   datamatcorrs_lst = {};
   stacked_smeanmat = [];

   k = num_cond;

   if meancentering_type == 1

      grand_mean = zeros(num_cond, size(stacked_datamat,2));

      for g = 1:num_groups
         if ~iscell(num_subj_lst)
            n = num_subj_lst(g);
            span = sum(num_subj_lst(1:g-1)) * k;
            datamat = stacked_datamat(datamat_reorder,:);
            datamat = datamat(1+span:n*k+span,:);
            grand_mean = grand_mean + rri_task_mean(datamat,n);
         else
            n = num_subj_lst{g};
            span = sum([num_subj_lst{1:g-1}]);
            datamat = stacked_datamat(datamat_reorder,:);
            datamat = datamat(1+span:sum(n)+span,:);
            grand_mean = grand_mean + ssb_rri_task_mean(datamat,n);
         end
      end

      grand_mean = grand_mean / num_groups;

   elseif meancentering_type == 2

      grand_mean = [];

      for g = 1:num_groups
         if ~iscell(num_subj_lst)
            n = num_subj_lst(g);
            span = sum(num_subj_lst(1:g-1)) * k;
            datamat = stacked_datamat(datamat_reorder,:);
            datamat = datamat(1+span:n*k+span,:);
            grand_mean = [grand_mean ; datamat];
         else
            n = num_subj_lst{g};
            span = sum([num_subj_lst{1:g-1}]);
            datamat = stacked_datamat(datamat_reorder,:);
            datamat = datamat(1+span:sum(n)+span,:);
            grand_mean = [grand_mean ; datamat];
         end
      end

      grand_mean = mean(grand_mean, 1);

   elseif meancentering_type == 3

      cond_group_mean = zeros(num_cond, num_groups, size(stacked_datamat,2));

      for g = 1:num_groups
         if ~iscell(num_subj_lst)
            n = num_subj_lst(g);
            span = sum(num_subj_lst(1:g-1)) * k;
            datamat = stacked_datamat(datamat_reorder,:);
            datamat = datamat(1+span:n*k+span,:);
            cond_group_mean(:,g,:) = rri_task_mean(datamat,n);
         else
            n = num_subj_lst{g};
            span = sum([num_subj_lst{1:g-1}]);
            datamat = stacked_datamat(datamat_reorder,:);
            datamat = datamat(1+span:sum(n)+span,:);
            cond_group_mean(:,g,:) = ssb_rri_task_mean(datamat,n);
         end
      end

      cond_mean = mean(cond_group_mean,1);
      cond_mean = reshape(cond_mean, [size(cond_group_mean,2) size(cond_group_mean,3)]);
      group_mean = mean(cond_group_mean,2);
      group_mean = reshape(group_mean, [size(cond_group_mean,1) size(cond_group_mean,3)]);

      %  calculate grand mean over all groups and conditions
      %
      grand_mean = squeeze(mean(mean(cond_group_mean,1),2))';

   end

   %  loop accross the groups, and
   %  calculate datamatcorrs for each group
   %
   for g = 1:num_groups
      if ~iscell(num_subj_lst)

         n = num_subj_lst(g);
         span = sum(num_subj_lst(1:g-1)) * k;
         datamat = stacked_datamat(datamat_reorder,:);

         if isempty(single_cond_lst)
            datamat = datamat(1+span:n*k+span,:);
         end

         if ismember(method,[4 6])
            datamat_4beh = stacked_datamat(datamat_reorder_4beh,:);
            datamat_4beh = datamat_4beh(1+span:n*k+span,:);
         end

         if ismember(method,[3 4 5 6])
            behavdata = stacked_behavdata(behavdata_reorder,:);
            behavdata = behavdata(1+span:n*k+span,:);
         end

         %  calculate correlation or covariance
         %
         switch method
         case 1
            if ~isempty(single_cond_lst) & g==1
               datamat = single_cond_lst{1};
               datamatcorrs = ssb_rri_task_mean(datamat,num_subj_lst)-ones(num_groups,1)*mean(datamat);

               if is_observation & num_boot > 0
                  smeanmat = datamat-ones(size(datamat,1),1)*mean(datamat);	% calc orig_usc for boot CI
               end
            elseif isempty(single_cond_lst) & meancentering_type == 0
               datamatcorrs = rri_task_mean(datamat,n)-ones(k,1)*mean(datamat);	% pet, erp & multiblock style

               if is_observation & num_boot > 0
                  smeanmat = datamat-ones(size(datamat,1),1)*mean(datamat);	% calc orig_usc for boot CI
               end
            elseif isempty(single_cond_lst) & meancentering_type == 1
               datamatcorrs = rri_task_mean(datamat,n)-grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = [];

                  for cond_idx = 1:num_cond
                     tmp = datamat((cond_idx-1)*num_subj_lst(g)+(1:num_subj_lst(g)),:) ...
			-ones(num_subj_lst(g),1)*grand_mean(cond_idx,:);

                     smeanmat = [smeanmat ; tmp];
                  end
               end
            elseif isempty(single_cond_lst) & meancentering_type == 2
               datamatcorrs = rri_task_mean(datamat,n)-ones(k,1)*grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = datamat-ones(size(datamat,1),1)*grand_mean;
               end
            elseif isempty(single_cond_lst) & meancentering_type == 3
               datamatcorrs = rri_task_mean(datamat,n)-group_mean ...
			-ones(k,1)*cond_mean(g,:) +ones(k,1)*grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = [];

                  for cond_idx = 1:num_cond
                     tmp = datamat((cond_idx-1)*num_subj_lst(g)+(1:num_subj_lst(g)),:) ...
			-ones(num_subj_lst(g),1)*group_mean(cond_idx,:) ...
			-ones(num_subj_lst(g),1)*cond_mean(g,:) ...
			+ones(num_subj_lst(g),1)*grand_mean;

                     smeanmat = [smeanmat ; tmp];
                  end
               end
            end

            TBdatamatcorrs = [];
         case {2, 6}
            datamatcorrs = rri_task_mean(datamat,n);

            if is_observation & num_boot > 0
               if meancentering_type == 0
                  smeanmat = datamat-ones(size(datamat,1),1)*mean(datamat);	% calc orig_usc for boot CI
               elseif meancentering_type == 1
                  smeanmat = [];

                  for cond_idx = 1:num_cond
                     tmp = datamat((cond_idx-1)*num_subj_lst(g)+(1:num_subj_lst(g)),:) ...
			-ones(num_subj_lst(g),1)*grand_mean(cond_idx,:);

                     smeanmat = [smeanmat ; tmp];
                  end
               elseif meancentering_type == 2
                  smeanmat = datamat-ones(size(datamat,1),1)*grand_mean;
               elseif meancentering_type == 3
                  smeanmat = [];

                  for cond_idx = 1:num_cond
                     tmp = datamat((cond_idx-1)*num_subj_lst(g)+(1:num_subj_lst(g)),:) ...
			-ones(num_subj_lst(g),1)*group_mean(cond_idx,:) ...
			-ones(num_subj_lst(g),1)*cond_mean(g,:) ...
			+ones(num_subj_lst(g),1)*grand_mean;

                     smeanmat = [smeanmat ; tmp];
                  end	% for cond_idx
               end	% if meancentering_type
            end		% if num_boot

            if method == 6
               Tdatamatcorrs = datamatcorrs;
               Bdatamatcorrs = rri_corr_maps_notall(behavdata, datamat_4beh, n, bscan, cormode);
               datamatcorrs_lst = [datamatcorrs_lst, {Bdatamatcorrs}];

               %  stack task and behavior - keep un-normalize data that will be
               %  used to recover the normalized one
               %
               TBdatamatcorrs = [Tdatamatcorrs; Bdatamatcorrs];

               %  stack task and behavior - normalize to unit length to reduce
               %  scaling differences
               %
               datamatcorrs = [normalize(Tdatamatcorrs,2); normalize(Bdatamatcorrs,2)];
            else
               TBdatamatcorrs = [];
            end
         case {3, 5}
            datamatcorrs = rri_corr_maps(behavdata, datamat, n, k, cormode);
            datamatcorrs_lst = [datamatcorrs_lst, {datamatcorrs}];
            TBdatamatcorrs = [];
         case 4
            if meancentering_type == 0
               Tdatamatcorrs = rri_task_mean(datamat,n)-ones(k,1)*mean(datamat);	% pet, erp & multiblock style

               if is_observation & num_boot > 0
                  smeanmat = datamat-ones(size(datamat,1),1)*mean(datamat);	% calc orig_usc for boot CI
               end
            elseif meancentering_type == 1
               Tdatamatcorrs = rri_task_mean(datamat,n)-grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = [];

                  for cond_idx = 1:num_cond
                     tmp = datamat((cond_idx-1)*num_subj_lst(g)+(1:num_subj_lst(g)),:) ...
			-ones(num_subj_lst(g),1)*grand_mean(cond_idx,:);

                     smeanmat = [smeanmat ; tmp];
                  end
               end
            elseif meancentering_type == 2
               Tdatamatcorrs = rri_task_mean(datamat,n)-ones(k,1)*grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = datamat-ones(size(datamat,1),1)*grand_mean;
               end
            elseif meancentering_type == 3
               Tdatamatcorrs = rri_task_mean(datamat,n)-group_mean ...
			-ones(k,1)*cond_mean(g,:) +ones(k,1)*grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = [];

                  for cond_idx = 1:num_cond
                     tmp = datamat((cond_idx-1)*num_subj_lst(g)+(1:num_subj_lst(g)),:) ...
			-ones(num_subj_lst(g),1)*group_mean(cond_idx,:) ...
			-ones(num_subj_lst(g),1)*cond_mean(g,:) ...
			+ones(num_subj_lst(g),1)*grand_mean;

                     smeanmat = [smeanmat ; tmp];
                  end
               end
            end

            Bdatamatcorrs = rri_corr_maps_notall(behavdata, datamat_4beh, n, bscan, cormode);
            datamatcorrs_lst = [datamatcorrs_lst, {Bdatamatcorrs}];

            %  stack task and behavior - keep un-normalize data that will be
            %  used to recover the normalized one
            %
            TBdatamatcorrs = [Tdatamatcorrs; Bdatamatcorrs];

            %  stack task and behavior - normalize to unit length to reduce
            %  scaling differences
            %
            datamatcorrs = [normalize(Tdatamatcorrs,2); normalize(Bdatamatcorrs,2)];
         end	% switch

         if isempty(single_cond_lst) | g==1
            datamatsvd_unnorm = [datamatsvd_unnorm; TBdatamatcorrs];
            datamatsvd = [datamatsvd; datamatcorrs];

            if is_observation & num_boot > 0 & ismember(method,[1 2 4 6])
               stacked_smeanmat = [stacked_smeanmat; smeanmat];
            end
         end

      else

         n = num_subj_lst{g};
         span = sum([num_subj_lst{1:g-1}]);
         datamat = stacked_datamat(datamat_reorder,:);
         datamat = datamat(1+span:sum(n)+span,:);

         if ismember(method,[4 6])
            datamat_4beh = stacked_datamat(datamat_reorder_4beh,:);
            datamat_4beh = datamat_4beh(1+span:sum(n)+span,:);
         end

         if ismember(method,[3 4 5 6])
            behavdata = stacked_behavdata(behavdata_reorder,:);
            behavdata = behavdata(1+span:sum(n)+span,:);
         end

         %  calculate correlation or covariance
         %
         switch method
         case 1
            if ~isempty(single_cond_lst) & g==1
               error('You need more than one condition to run single subject analysis');
            elseif meancentering_type == 0
               datamatcorrs = ssb_rri_task_mean(datamat,n)-ones(k,1)*mean(datamat);	% pet, erp & multiblock style

               if is_observation & num_boot > 0
                  smeanmat = datamat-ones(size(datamat,1),1)*mean(datamat);	% calc orig_usc for boot CI
               end
            elseif meancentering_type == 1
               datamatcorrs = ssb_rri_task_mean(datamat,n)-grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = [];

                  step = 0;
                  n = num_subj_lst{g};

                  for cond_idx = 1:num_cond
                     tmp = datamat((1:n(cond_idx))+step,:) ...
			-ones(n(cond_idx),1)*grand_mean(cond_idx,:);

                     smeanmat = [smeanmat ; tmp];
                     step=step+n(cond_idx);
                  end
               end
            elseif meancentering_type == 2
               datamatcorrs = ssb_rri_task_mean(datamat,n)-ones(k,1)*grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = datamat-ones(size(datamat,1),1)*grand_mean;
               end
            elseif meancentering_type == 3
               datamatcorrs = ssb_rri_task_mean(datamat,n)-group_mean ...
			-ones(k,1)*cond_mean(g,:) +ones(k,1)*grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = [];

                  step = 0;
                  n = num_subj_lst{g};

                  for cond_idx = 1:num_cond
                     tmp = datamat((1:n(cond_idx))+step,:) ...
			-ones(n(cond_idx),1)*group_mean(cond_idx,:) ...
			-ones(n(cond_idx),1)*cond_mean(g,:) ...
			+ones(n(cond_idx),1)*grand_mean;

                     smeanmat = [smeanmat ; tmp];
                     step=step+n(cond_idx);
                  end
               end
            end

            TBdatamatcorrs = [];
         case {2, 6}
            datamatcorrs = ssb_rri_task_mean(datamat,n);

            if is_observation & num_boot > 0
               if meancentering_type == 0
                  smeanmat = datamat-ones(size(datamat,1),1)*mean(datamat);	% calc orig_usc for boot CI
               elseif meancentering_type == 1
                  smeanmat = [];

                  step = 0;
                  n = num_subj_lst{g};

                  for cond_idx = 1:num_cond
                     tmp = datamat((1:n(cond_idx))+step,:) ...
			-ones(n(cond_idx),1)*grand_mean(cond_idx,:);

                     smeanmat = [smeanmat ; tmp];
                     step=step+n(cond_idx);
                  end
               elseif meancentering_type == 2
                  smeanmat = datamat-ones(size(datamat,1),1)*grand_mean;
               elseif meancentering_type == 3
                  smeanmat = [];

                  step = 0;
                  n = num_subj_lst{g};

                  for cond_idx = 1:num_cond
                     tmp = datamat((1:n(cond_idx))+step,:) ...
			-ones(n(cond_idx),1)*group_mean(cond_idx,:) ...
			-ones(n(cond_idx),1)*cond_mean(g,:) ...
			+ones(n(cond_idx),1)*grand_mean;

                     smeanmat = [smeanmat ; tmp];
                     step=step+n(cond_idx);
                  end	% for cond_idx
               end	% if meancentering_type
            end		% if num_boot

            if method == 6
               Tdatamatcorrs = datamatcorrs;
               Bdatamatcorrs = ssb_rri_corr_maps_notall(behavdata, datamat_4beh, n, bscan, cormode);
               datamatcorrs_lst = [datamatcorrs_lst, {Bdatamatcorrs}];

               %  stack task and behavior - keep un-normalize data that will be
               %  used to recover the normalized one
               %
               TBdatamatcorrs = [Tdatamatcorrs; Bdatamatcorrs];

               %  stack task and behavior - normalize to unit length to reduce
               %  scaling differences
               %
               datamatcorrs = [normalize(Tdatamatcorrs,2); normalize(Bdatamatcorrs,2)];
            else
               TBdatamatcorrs = [];
            end
         case {3, 5}
            datamatcorrs = ssb_rri_corr_maps(behavdata, datamat, n, k, cormode);
            datamatcorrs_lst = [datamatcorrs_lst, {datamatcorrs}];
            TBdatamatcorrs = [];
         case 4
            if meancentering_type == 0
               Tdatamatcorrs = ssb_rri_task_mean(datamat,n)-ones(k,1)*mean(datamat);	% pet, erp & multiblock style

               if is_observation & num_boot > 0
                  smeanmat = datamat-ones(size(datamat,1),1)*mean(datamat);	% calc orig_usc for boot CI
               end
            elseif meancentering_type == 1
               Tdatamatcorrs = ssb_rri_task_mean(datamat,n)-grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = [];

                  step = 0;
                  n = num_subj_lst{g};

                  for cond_idx = 1:num_cond
                     tmp = datamat((1:n(cond_idx))+step,:) ...
			-ones(n(cond_idx),1)*grand_mean(cond_idx,:);

                     smeanmat = [smeanmat ; tmp];
                     step=step+n(cond_idx);
                  end
               end
            elseif meancentering_type == 2
               Tdatamatcorrs = ssb_rri_task_mean(datamat,n)-ones(k,1)*grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = datamat-ones(size(datamat,1),1)*grand_mean;
               end
            elseif meancentering_type == 3
               Tdatamatcorrs = ssb_rri_task_mean(datamat,n)-group_mean ...
			-ones(k,1)*cond_mean(g,:) +ones(k,1)*grand_mean;

               if is_observation & num_boot > 0
                  smeanmat = [];

                  step = 0;
                  n = num_subj_lst{g};

                  for cond_idx = 1:num_cond
                     tmp = datamat((1:n(cond_idx))+step,:) ...
			-ones(n(cond_idx),1)*group_mean(cond_idx,:) ...
			-ones(n(cond_idx),1)*cond_mean(g,:) ...
			+ones(n(cond_idx),1)*grand_mean;

                     smeanmat = [smeanmat ; tmp];
                     step=step+n(cond_idx);
                  end
               end
            end


            Bdatamatcorrs = ssb_rri_corr_maps_notall(behavdata, datamat_4beh, n, bscan, cormode);
            datamatcorrs_lst = [datamatcorrs_lst, {Bdatamatcorrs}];

            %  stack task and behavior - keep un-normalize data that will be
            %  used to recover the normalized one
            %
            TBdatamatcorrs = [Tdatamatcorrs; Bdatamatcorrs];

            %  stack task and behavior - normalize to unit length to reduce
            %  scaling differences
            %
            datamatcorrs = [normalize(Tdatamatcorrs,2); normalize(Bdatamatcorrs,2)];
         end	% switch

         if isempty(single_cond_lst) | g==1
            datamatsvd_unnorm = [datamatsvd_unnorm; TBdatamatcorrs];
            datamatsvd = [datamatsvd; datamatcorrs];

            if is_observation & num_boot > 0 & ismember(method,[1 2 4 6])
               stacked_smeanmat = [stacked_smeanmat; smeanmat];
            end
         end

      end	% if ~iscell(num_subj_lst)
   end		% for num_groups

   return					% rri_get_covcor

