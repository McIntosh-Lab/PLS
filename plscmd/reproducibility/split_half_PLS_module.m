function [pls_repro,splitflag]=split_half_PLS(X,y,n_con,numsplits,lv,CI,null_flag,option)
% [pls_repro,splitflag]=split_half_PLS(x,y,n_con,numsplits,lv,CI, option)
%
% computes the cosines between singular vectors U and V from numsplit
% random splits of X and Y data
% n_con= number of conditions
% nsplits: number of split half samples
% lv: largest number of LV to be evaluated - e.g. lv=3 means 1,2,3 are
% assesed
% CI: confidence interval percentile
% 
%
%OUTPUT
% pls_repro.pls_rep_mean_u  average of cosines for u distribution from split-half
% pls_repro.pls_rep_mean_v average of cosines for v distribution from split-half
% pls_repro.pls_rep_z_u  Z-value for v distribition (mean_u/std_u)
% pls_repro.pls_rep_z_v  Z-value for v distribition (mean_v/std_v)
% pls_repro.pls_rep_ul_u=pls_rep_ul_u upper bound of u distribution  
% pls_repro.pls_rep_ll_u=pls_rep_ll_u lower bound of u distribution 
% pls_repro.pls_rep_ul_v=pls_rep_ul_v upper bound of v distribution 
% pls_repro.pls_rep_ll_v=pls_rep_ll_v upper bound of v distribution  
% pls_repro.pls_null_mean_u=pls_null_mean_u average of null u distribution
% created by permutation 
% pls_repro.pls_null_mean_v=pls_null_mean_v average of null v distribution
% pls_repro.pls_null_z_u=pls_null_u_z Z-value for null u distribition 
% pls_repro.pls_null_z_v=pls_null_v_z Z-value for null v distribition 
% pls_repro.pls_null_ul_u=pls_null_ul_u upper bound of null u distribution
% pls_repro.pls_null_ll_u=pls_null_ll_u; lower bound of null u distribution
% pls_repro.pls_null_ul_v=pls_null_ul_v; upper bound of null v distribution
% pls_repro.pls_null_ll_v=pls_null_ll_v lower bound of null u distribution
% pls_repro.pls_dist_u  full distribution of u cosines if dist_flag=1
% pls_repro.pls_dist_v  full distribution of v cosines if dist_flag=1
% pls_repro.pls_dist_null_u full distribution of null_u cosines if dist_flag=1
% pls_repro.pls_dist_null_v full distribution of null_v cosines if dist_flag=1
%
% Dependencies: calls pls_analysis
%
% Written ARMcIntosh December 2020
% REVISED 23Dec-2022 for PLS only analyses
% Modified by LRokos 2025 to handle different pls versions

%% Initialize
disp("Working on split-half resampling ...")
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
option.silencerepro = 1;% Set to prevent display of PLS steps on every loop
% Set bscan if needed
 if isfield(option,'bscan')
   bscan = option.bscan;
  %if option.method ~= 4 && option.method ~= 6
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

pls_u_repro=zeros(d,d,numsplits);
pls_v_repro=zeros(d,d,numsplits);

pls_u_null=zeros(d,d,numsplits);
pls_v_null=zeros(d,d,numsplits);

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
% add variable that saves out split indices
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

    % Set behaviour data if appropriate for pls1
    if ismember(option.method,[3 4 5 6])
        y1=y(idx_1_all,:);
        option.stacked_behavdata = y1;
    end
    % Run PLS for first split
    [pls1] = pls_analysis(x1_cell,num_subj_lst1,n_con,option);

    % Set behaviour data if appropriate for pls2
    if ismember(option.method,[3 4 5 6])
        y2=y(idx_2_all,:);
        option.stacked_behavdata = y2;
    end
    % Run PLS for second split
    [pls2] = pls_analysis(x2_cell,num_subj_lst2,n_con,option);

    % Append
     pls_u_repro(:,:,i)=pls1.u'*pls2.u;
     pls_v_repro(:,:,i)=pls1.v'*pls2.v;

end
%% Null testing
if null_flag==1
null_idx_all_splits = [];
for i=1:numsplits %create a null distribution
    nsplit = sum(num_subj_lst1); % Set split to same size as non-null split
    idx=randperm(n); % n=n_total/n_con; -> number of subjects
    tmp_idx_subj=idx_subj(idx,:); % Permute indices

    % Select first half of subjects for split 1
     idx_1=tmp_idx_subj(1:nsplit,:); 
     idx_1=idx_1(:);

    % Select second half of subjects for split 2
     idx_2=tmp_idx_subj(nsplit+1:n,:);
     idx_2=idx_2(:);

    % Permute task portion of the data & split
    if ismember(option.method,[1 2 4 6]) % task & multiblock PLS
        idx_permx = randperm(n*n_con);
        xperm = x(idx_permx,:); % scramble x
        x1_null = xperm(idx_1,:);
        x2_null = xperm(idx_2,:);
    end

   % Multiblock PLS - behavioural portion
    if ismember(option.method,[4 6]) % multiblock PLS
        y1_null = y(idx_1,:); % don't scramble y
        y2_null = y(idx_2,:);
    end

    % Behavioural PLS - permute behaviour portion of the data & split
    if ismember(option.method,[3 5]) % behavioural PLS
         permy=y(randperm(n*n_con),:); % scramble y
         y1_null=permy(idx_1,:);
         y2_null=permy(idx_2,:);
         x1_null = x(idx_1,:); % don't scramble x
         x2_null = x(idx_2,:);
    end

    % Reshape x data as a cell arrays
    current_idx1 = 1;
    current_idx2 = 1;
    for g = 1:numel(X)
        % Get the number of subjects for the current group
        n_subj1 = size(x1_cell{g},1);
        n_subj2 = size(x2_cell{g},1);
        % Reshape x data to match the group sizes in x_cell
        x1_cell_null{g} = x1_null(current_idx1:current_idx1 + n_subj1 - 1, :);
        x2_cell_null{g} = x2_null(current_idx2:current_idx2 + n_subj2 - 1, :);
        % Move the index forward by the number of subjects processed
        current_idx1 = current_idx1 + n_subj1;
        current_idx2 = current_idx2 + n_subj2;
    end

    % Set behaviour data if appropriate
    if ismember(option.method,[3 4 5 6])
        option.stacked_behavdata = y1_null;
    end
    % Run PLS for first split
    [pls1] = pls_analysis(x1_cell_null,num_subj_lst1,n_con,option);
    
    % Set behaviour data if appropriate
    if ismember(option.method,[3 4 5 6])
        option.stacked_behavdata = y2_null;
    end

    % Run PLS for second split
    [pls2] = pls_analysis(x2_cell_null,num_subj_lst2,n_con,option); 
    
    % Append
     pls_u_null(:,:,i)=pls1.u'*pls2.u;
     pls_v_null(:,:,i)=pls1.v'*pls2.v;    
    % Append indices for current null split
    null_idx_all_splits = [null_idx_all_splits, tmp_idx_subj(:)]; 
end

end
%% Save out results
for i=1:lv
    pls_rep_mean_u(i)=mean(abs(pls_u_repro(i,i,:)));
    pls_rep_std_u(i)=std(abs(pls_u_repro(i,i,:)));
    pls_rep_u_z(i)=pls_rep_mean_u(i)/pls_rep_std_u(i);
    pls_rep_ul_u(i)=prctile(abs(pls_u_repro(i,i,:)),CI);
    pls_rep_ll_u(i)=prctile(abs(pls_u_repro(i,i,:)),100-CI);
    pls_rep_mean_v(i)=mean(abs(pls_v_repro(i,i,:)));
    pls_rep_std_v(i)=std(abs(pls_v_repro(i,i,:)));
    pls_rep_v_z(i)=pls_rep_mean_v(i)/pls_rep_std_v(i);
    pls_rep_ul_v(i)=prctile(abs(pls_v_repro(i,i,:)),CI);
    pls_rep_ll_v(i)=prctile(abs(pls_v_repro(i,i,:)),100-CI);
end
 
for i=1:lv
    pls_null_mean_u(i)=mean(abs(pls_u_null(i,i,:)));
    pls_null_std_u(i)=std(abs(pls_u_null(i,i,:)));
    pls_null_u_z(i)=pls_null_mean_u(i)/pls_null_std_u(i);
    pls_null_ul_u(i)=prctile(abs(pls_u_null(i,i,:)),CI);
    pls_null_ll_u(i)=prctile(abs(pls_u_null(i,i,:)),100-CI);
    pls_null_mean_v(i)=mean(abs(pls_v_null(i,i,:)));
    pls_null_std_v(i)=std(abs(pls_v_null(i,i,:)));
    pls_null_v_z(i)=pls_null_mean_v(i)/pls_null_std_v(i);
    pls_null_ul_v(i)=prctile(abs(pls_v_null(i,i,:)),CI);
    pls_null_ll_v(i)=prctile(abs(pls_v_null(i,i,:)),100-CI);
end
 
pls_repro.pls_rep_mean_u=pls_rep_mean_u;
pls_repro.pls_rep_mean_v=pls_rep_mean_v;
pls_repro.pls_rep_z_u=pls_rep_u_z;
pls_repro.pls_rep_z_v=pls_rep_v_z;
pls_repro.pls_rep_ul_u=pls_rep_ul_u; 
pls_repro.pls_rep_ll_u=pls_rep_ll_u;
pls_repro.pls_rep_ul_v=pls_rep_ul_v; 
pls_repro.pls_rep_ll_v=pls_rep_ll_v; 
pls_repro.pls_null_mean_u=pls_null_mean_u;
pls_repro.pls_null_mean_v=pls_null_mean_v;
pls_repro.pls_null_z_u=pls_null_u_z;
pls_repro.pls_null_z_v=pls_null_v_z;
pls_repro.pls_null_ul_u=pls_null_ul_u; 
pls_repro.pls_null_ll_u=pls_null_ll_u;
pls_repro.pls_null_ul_v=pls_null_ul_v; 
pls_repro.pls_null_ll_v=pls_null_ll_v;
%if dist_flag==1
    pls_repro.pls_dist_u=pls_u_repro;
    pls_repro.pls_dist_v=pls_v_repro;
    pls_repro.pls_dist_null_u=pls_u_null;
    pls_repro.pls_dist_null_v=pls_v_null;
%end
pls_repro.idx_all_splits = idx_all_splits;
pls_repro.null_idx_all_splits = null_idx_all_splits;
