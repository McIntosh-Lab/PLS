function [pls_repro_tt,splitflag]=split_half_PLS_TestTrain_module(X,y,n_con,numsplits,null_flag,option)
%n_con= number of conditions
%numsplits: number of split half samples
%null_flag: save distributions 1=true default=0
%
% Uses a test-train loop where data are split and singular vectors from
% train set are applied to test and generate the corresponding singular
% value Zscore distribution for the test singular values is calculated,
% which is the figure of merit for reproducibility A null distribution can
% be generated using a permuation approach to get an idea of the expected
% value for the test distribution.
% Dependencies: calls pls_analysis
% Modified by LRokos 2025 to handle different pls versions
%% Initialize
disp("Working on split-half test-train resampling ...")
    if ~iscell(X)
         X = {X};
    end
    x = cell2mat(X');
    [n_total,p]=size(x);
    n=n_total/n_con; % number of subjects
    [~,bv]=size(y); % number of behavioural variables
    num_groups = numel(X); % number of groups

    %% Overwrite option information
    option.num_boot=0; % No bootstrapping
    option.num_perm=0; % No permutation testing
    option.repro_splithalf=0; % No split half resampling
    option.silencerepro= 1; % Set to prevent display of PLS steps on every loop
    % Set bscan if needed
     if isfield(option,'bscan')
       bscan = option.bscan;
     else
         bscan = 1:n_con;
     end

     % Cormode option
      cormode = 0;
      if isfield(option,'cormode')
         cormode = option.cormode;
      end

    %% Allocate Dimensions
    if ismember(option.method,1) % regular mcPLS
        d=min(p,n_con*num_groups);
    elseif ismember(option.method,[2,5,6]) %contrasts
        d=min(p,size(option.stacked_designdata,2));
    elseif ismember(option.method,3) % regular bPLS (3)
        d=min(p,bv*n_con*num_groups);
    else % regular multiblock (4)
        d=min(p,(n_con*num_groups + bv*length(bscan)*num_groups));
    end

    %% Build index matrices for each group
    start = 1;
    last = 0 ;
    idx_subj = [];

    for g = 1:numel(X)
        [g_subs, ~] = size(X{g}); % Number of subjects in group g
    
        % Calculate the last index for the current group
        last = last + g_subs;
        group_idxs = start:last;
        idx_subj_split{g} = reshape(group_idxs,g_subs/n_con, n_con); 
    
        % Append the indices for this group to the main matrix
        idx_subj = [idx_subj; idx_subj_split{g}];
        start = last + 1;
    end

    %% Loop over the number of splits
    splitflag=[];
    idx_all_splits = [];
    for i=1:numsplits
        % Initialize empty arrays to collect indices for each split
        idx_1_all = [];
        idx_2_all = [];

        % Initialize cell arrays to store split data for each group
        x1_cell = cell(numel(X),1);
        x2_cell = cell(numel(X),1);

       % Loop over each group
       for g = 1:numel(X)
             idx_subj_group = idx_subj_split{g}; % Group-specific subject indices
             [n_per_g,~] = size(idx_subj_group); % Number of subjects per group
             nsplit=floor(n_per_g/2); % Split size (half the group)
            
             % Permute subject indices
             idx=randperm(n_per_g);
             tmp_idx_subj=idx_subj_group(idx,:); % Apply permutation to the subject indices
            
             % Select first half of subjects for split 1
             idx_1=tmp_idx_subj(1:nsplit,:);
             idx_1=idx_1(:); % Ensure column vector
            
             % Select remaining subjects for split 2
             idx_2=tmp_idx_subj(nsplit+1:n_per_g,:);
             idx_2=idx_2(:); % Ensure column vector

             % Accumulate indices across groups
             idx_1_all =[idx_1_all;idx_1];
             idx_2_all =[idx_2_all;idx_2];
            
             % Extract data corresponding to each split for group g
             x1_cell{g} = x(idx_1,:);
             x2_cell{g} = x(idx_2,:);

             % Get number of subjects per group for each split
              num_subj_lst1(g) = size(x1_cell{g},1) / n_con;
              num_subj_lst2(g) = size(x2_cell{g},1) / n_con;
       end
    % Append indices for current split
    idx_all_splits = [idx_all_splits, [idx_1_all ; idx_2_all]];     
    % Extract data as stacked matrices
    x2=x(idx_2_all,:);
    % Set behaviour data if appropriate
    if ismember(option.method,[3 4 5 6])
        y1=y(idx_1_all,:);
        option.stacked_behavdata = y1;
        y2=y(idx_2_all,:);
    end
  
    % Run PLS analysis on split 1
    [pls1] = pls_analysis(x1_cell,num_subj_lst1,n_con,option);

    %  Calculate Covariance / Correlation data
    single_cond_lst = {};
    datamat_reorder = [1:size(x2,1)]';

    if ismember(option.method,[3 4 5 6])
        behavdata_reorder = [1:size(y2,1)]';
    else
        behavdata_reorder = [];
        y2=[];
    end
    
    [datamat2,~ ,~ ,~ ] = rri_get_covcor(option.method, x2, y2, numel(X), ...
        num_subj_lst2, n_con, bscan, option.meancentering_type, cormode, ...
        single_cond_lst, 0, 0, datamat_reorder, behavdata_reorder);

    % Save singular values from training
    pls_s_train(:,:,i)=pls1.s;
    % Calculate implied singular values for testing
    pls_s_test(:,:,i)=pls1.u'*datamat2'*pls1.v; %implied singular value
               
    end

 %% Null testing   
  if null_flag==1
    null_idx_all_splits = [];
    for i=1:numsplits %create a null distribution

        nsplit = sum(num_subj_lst1); % Set split to same size as non-null split
        idx=randperm(n); 
        tmp_idx_subj=idx_subj(idx,:); % Permute indices

        % Select first half of subjects for split 1
         idx_1=tmp_idx_subj(1:nsplit,:); 
         idx_1=idx_1(:);

        % Select second half of subjects for split 2
         idx_2=tmp_idx_subj(nsplit+1:n,:);
         idx_2=idx_2(:);
         
        % Permute task portion of the data & split
        if ismember(option.method,[1 2 4 6])
            idx_permx = randperm(n*n_con);
            xperm = x(idx_permx,:); %scramble x
            x1_null = xperm(idx_1,:);
            x2_null = xperm(idx_2,:);
        end

       % Multiblock PLS - behavioural portion
        if ismember(option.method,[4 6])
            y1_null = y(idx_1,:);
            y2_null = y(idx_2,:);
        end

        % Behavioural PLS - permute behaviour portion of the data & split
        if ismember(option.method,[3 5]) % behavioural PLS
             permy=y(randperm(n*n_con),:); %scramble y
             y1_null=permy(idx_1,:);
             y2_null=permy(idx_2,:);
             x1_null = x(idx_1,:);
             x2_null = x(idx_2,:);
        end

        % Reshape x1 as a cell array
        current_idx1 = 1;
        for g = 1:numel(X)
            % Get the number of subjects for the current group
            n_subj1 = size(x1_cell{g},1);

            % Reshape x1 to match the group sizes in x1_cell
            x1_cell_null{g} = x1_null(current_idx1:current_idx1 + n_subj1 - 1, :);

            % Move the index forward by the number of subjects processed
            current_idx1 = current_idx1 + n_subj1;
        end

        % Set behaviour data if appropriate
        if ismember(option.method,[3 4 5 6])
            option.stacked_behavdata = y1_null;
        else
            y2_null =[];
        end
       
        % Run PLS analysis on split 1
        [pls1_null] = pls_analysis(x1_cell_null,num_subj_lst1,n_con,option);

        % Calculate Covariance / Correlation data
        [datamat2_null,~ ,~ ,~ ] = rri_get_covcor(option.method, x2_null, y2_null, numel(X), ...
            num_subj_lst2, n_con, bscan, option.meancentering_type, cormode, ...
            single_cond_lst, 0, 0, datamat_reorder, behavdata_reorder);

        % Save null singular values from training
        pls_s_train_null(:,:,i)=pls1_null.s;
        % Calculate implied null singular values for testing
        pls_s_test_null(:,:,i)=pls1_null.u'*datamat2_null'*pls1_null.v;
        % Append indices for current null split
        null_idx_all_splits = [null_idx_all_splits, tmp_idx_subj(:)]; 
    end
    
    end
    %% Save out results 
    pls_repro_tt.pls_s_train=pls_s_train;
    pls_repro_tt.pls_s_test=pls_s_test;
    
    for i =1:d
        pls_repro_tt.z(i)=mean(pls_repro_tt.pls_s_test(i,i,:),'omitnan')/std(pls_repro_tt.pls_s_test(i,i,:),'omitnan');
    end
    
    if null_flag==1
    pls_repro_tt.pls_s_train_null=pls_s_train_null;
    pls_repro_tt.pls_s_test_null=pls_s_test_null;

        for i=1:d
            pls_repro_tt.z_null(i)=mean(pls_repro_tt.pls_s_test_null(i,i,:),'omitnan')/std(pls_repro_tt.pls_s_test_null(i,i,:),'omitnan');   
        end
    end
pls_repro_tt.idx_all_splits = idx_all_splits;
pls_repro_tt.null_idx_all_splits = null_idx_all_splits;
