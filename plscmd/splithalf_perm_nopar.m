%  Split half permutation loop.
%
%  nopar:  parfor is not used
%  par:    parfor is used
%
function [sop, ucorr_distrib, vcorr_distrib] = splithalf_perm(sop, ...
	ucorr_distrib, vcorr_distrib, num_perm, num_split, num_lvs, ...
	num_groups, num_cond, num_subj_lst, num_subj_lst1, num_subj_lst2, ...
	rows1, rows2, meancentering_type, cormode, single_cond_lst, ...
	method, s, org_s, org_v, bscan, stacked_datamat, opt)

      if isfield(opt,'progress_hdl')
         progress_hdl = opt.progress_hdl;
      end

      if isfield(opt,'Treorder') & ismember(method, [4 6])
         Treorder = opt.Treorder;
      else
         Treorder = opt.reorder;
      end

      if isfield(opt,'Breorder') & ismember(method, [4 6])
         Breorder = opt.Breorder;
      else
         Breorder = opt.reorder;
      end

      if isfield(opt,'reorder')
         reorder = opt.reorder;
      end

      if isfield(opt,'stacked_behavdata')
         stacked_behavdata = opt.stacked_behavdata;
      end

      if isfield(opt,'stacked_designdata')
         stacked_designdata = opt.stacked_designdata;
      end

      %  outer perm loop
      %
      for op = 1:num_perm

         if 1 % isempty(progress_hdl)
            disp(['op = ' num2str(op)]);
%            fprintf(' %d\n', op);
%            pcntacc = 0;
         end

         % get permuted datamatsvd in outer permutation, and
         % perform usual analysis (svd or contrast)
         %
         if ismember(method, [4 6])
            datamat_reorder = Treorder(:,op);
            behavdata_reorder = [1:size(stacked_behavdata,1)]';
            datamat_reorder_4beh = Breorder(:,op);
         elseif ismember(method, [3 5])
%            datamat_reorder = [1:size(stacked_datamat,1)]';
%            behavdata_reorder = reorder(:,op);
            datamat_reorder = reorder(:,op);
            behavdata_reorder = [1:size(stacked_behavdata,1)]';
            datamat_reorder_4beh = [];
         else
            datamat_reorder = reorder(:,op);
            behavdata_reorder = [];
            datamat_reorder_4beh = [];
         end

         [datamatsvd_op datamatsvd_unnorm_op] = missnk_rri_get_covcor(method, ...
		stacked_datamat, stacked_behavdata, num_groups, num_subj_lst, ...
		num_cond, bscan, meancentering_type, cormode, single_cond_lst, ...
		0, 0, datamat_reorder, behavdata_reorder, datamat_reorder_4beh);

         if ismember(method, [2 5 6])	% non-rotated PLS

            v_op = stacked_designdata;
            crossblock = normalize(stacked_designdata)' * datamatsvd_op;
            u_op = crossblock';
            sperm = sqrt(sum(crossblock.^2, 2));

            %  exclude the first unpermuted sample
            %
%            if op > 1
 %              sop = sop + (sperm >= s);
  %          end

         else				% SVD, observed

            %  Singular Value Decomposition, permuted
            %
            [r c] = size(datamatsvd_op);
            if r <= c
               [u_op, sperm, v_op] = misssvd(datamatsvd_op',0);
            else
               [v_op, sperm, u_op] = misssvd(datamatsvd_op,0);
            end

            %  rotate v_op to align with the original v
            %
%            rotatemat = rri_bootprocrust(v, v_op);

            %  rescale the vectors
            %
%            v_op = v_op * sperm * rotatemat;

%            sperm = sqrt(sum(v_op.^2));

            sperm = diag(sperm);

         end			% ismember(method, [2 5 6])

         %  update sop count, but override s_op for multiblockPLS
         %
         if op > 1
            if ismember(method,[4 6])
               ptotal_s = sum(datamatsvd_unnorm_op(:).^2);
               per = (sperm).^2 / sum((sperm).^2);
               sperm = sqrt(per * ptotal_s);
            end			% if method 4

            sop = sop + (sperm >= org_s);
         end

         %  inner perm loop
         %
         %  estimate reliability of v_op through splihalf resampling
         %
         for p = 1:num_split

            if 1 % isempty(progress_hdl)
%               disp(['p = ' num2str(p)]);;
%               pcntacc = pcntacc + fprintf(' %d', p);
            else
               msg = ['Working on outer permutation ',num2str(op),' of ',num2str(num_perm)];
               msg = [msg ', with splits ',num2str(p),' of ',num2str(num_split)];
               rri_progress_ui(progress_hdl, 'Run Permutation Test', msg);
               rri_progress_ui(progress_hdl,'', ...
		(op-1)/num_perm + p/(num_perm*num_split) );
            end

            %  Create split half by randomly permuting subjects within
            %  each group, then splitting into 1st and 2nd half.
            %
            %  Replicate same permutation and splitting acrosss all 
            %  conditions 
            %
            in_reorder = [];

            for g = 1:num_groups
               gperm = randperm(num_subj_lst(g))';

               %  same perm of subjects is used for splithalving 
               %  both brain and behav
               %
               offset = sum(num_subj_lst(1:(g-1)))*num_cond;

               %  in_reorder randomize subj within each cond
               %
               for cond = 1:num_cond
                  in_reorder = ...
			[in_reorder; offset+num_subj_lst(g)*(cond-1)+gperm];
               end
            end		% for g

            %  calculate datmatsvd for each half
            %
            if ismember(method, [4 6])
               datamat_reorder1 = datamat_reorder(in_reorder(rows1));
               datamat_reorder2 = datamat_reorder(in_reorder(rows2));
               behavdata_reorder1 = behavdata_reorder(in_reorder(rows1));
               behavdata_reorder2 = behavdata_reorder(in_reorder(rows2));
               datamat_reorder_4beh1 = datamat_reorder_4beh(in_reorder(rows1));
               datamat_reorder_4beh2 = datamat_reorder_4beh(in_reorder(rows2));
            elseif ismember(method, [3 5])
               datamat_reorder1 = datamat_reorder(in_reorder(rows1));
               datamat_reorder2 = datamat_reorder(in_reorder(rows2));
               behavdata_reorder1 = behavdata_reorder(in_reorder(rows1));
               behavdata_reorder2 = behavdata_reorder(in_reorder(rows2));
               datamat_reorder_4beh1 = [];
               datamat_reorder_4beh2 = [];
            else
               datamat_reorder1 = datamat_reorder(in_reorder(rows1));
               datamat_reorder2 = datamat_reorder(in_reorder(rows2));
               behavdata_reorder1 = [];
               behavdata_reorder2 = [];
               datamat_reorder_4beh1 = [];
               datamat_reorder_4beh2 = [];
            end

            datamatsvd_p1 = missnk_rri_get_covcor(method, ...
		stacked_datamat, stacked_behavdata, ...
		num_groups, num_subj_lst1, num_cond, bscan, ...
		meancentering_type, cormode, single_cond_lst, 0, 0, ...
		datamat_reorder1, behavdata_reorder1, ...
		datamat_reorder_4beh1);

            datamatsvd_p2 = missnk_rri_get_covcor(method, ...
		stacked_datamat, stacked_behavdata, ...
		num_groups, num_subj_lst2, num_cond, bscan, ...
		meancentering_type, cormode, single_cond_lst, 0, 0, ...
		datamat_reorder2, behavdata_reorder2, ...
		datamat_reorder_4beh2);

            %  project design (v_op) onto both halves
            %
            u_p1 = datamatsvd_p1' * v_op;	% brain factor score
            u_p2 = datamatsvd_p2' * v_op;

            %  project brain pattern (u_op) onto both halves
            %
            v_p1 =  datamatsvd_p1 * u_op;		% effect factor score
            v_p2 =  datamatsvd_p2 * u_op;

            %  correlate brain and effect factor scores and update mean correlations
            %
            for lv = 1:num_lvs
               ucorr_distrib(op,lv) = ucorr_distrib(op,lv) + rri_xcor(u_p1(:,lv),u_p2(:,lv),cormode);
               vcorr_distrib(op,lv) = vcorr_distrib(op,lv) + rri_xcor(v_p1(:,lv),v_p2(:,lv),cormode);
            end

            if 0 % isempty(progress_hdl)
               if pcntacc > 70
                  fprintf('\n');
                  pcntacc = 0;
               end
            end
         end		% for num_split

         if 0 % isempty(progress_hdl)
            fprintf('\n');
         end
      end		% for num_perm

   return;					% splithalf_perm

