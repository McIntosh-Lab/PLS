%
% syntax [scores, fscores, lvcorrs] = ...
%	rri_get_behavscores(stacked_datamat, stacked_behavdata, ...
%	brainlv, behavlv, k, num_subj_lst)
%
% compute LV scores from PLS analysis
% To be used for behavioural analysis only - assumes only 
% 1 column in behav matrix
%
% INPUT: the same variables used for behav_pls 
%
% OUTPUT:  'scores' are the brain scores;
%          'fscores' are the behavior scores;
%          'lvcorrs' are orig_corr;
%
% See also PLS_SCORES_B
%
% Written 12-95 by ARM

% Some modifications made by KMK 12-96 for 1 or 2 groups of unequal size
% Modified on 27-OCT-2002 by Jimmy Shen to allow any number of groups
%                               with different number of subjects
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [scores, fscores, lvcorrs] = ...
	rri_get_behavscores(stacked_datamat, stacked_behavdata, ...
	brainlv, behavlv, k, num_subj_lst, cormode)

    scores = stacked_datamat * brainlv;
    fscores = [];
    lvcorrs = [];

    num_groups = length(num_subj_lst);

    for g = 1:num_groups

	n = num_subj_lst(g);
	t = size(stacked_behavdata, 2);			% number of contrasts
	tmp = [];

	span = sum(num_subj_lst(1:g-1)) * k;

	for i = 1:k
	    tmp_k = stacked_behavdata([1 + n*(i-1) + span : n*i + span], :) * ...
		behavlv([1 + t*(i-1) + (g-1)*t*k : t*i + (g-1)*t*k],:);
	    tmp = [tmp; tmp_k];
	end

	fscores = [fscores; tmp];

	tmp = rri_corr_maps(stacked_behavdata(1 + span : n*k + span, :), ...
				scores(1 + span : n*k + span, :), n, k, cormode);
	lvcorrs = [lvcorrs; tmp];

    end

    return;

