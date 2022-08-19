%
% syntax [scores, fscores] = ...
%	rri_get_designscores(stacked_datamat, stacked_contrastdata, ...
%	brainlv, designlv, k, num_subj_lst)
%
% compute LV scores from PLS design analysis
%
% OUTPUT:  'scores' are the brain scores;
%          'fscores' are the design scores;
%
% See also RRI_GET_BEHAVSCORES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [scores, fscores] = ...
	rri_get_designscores(stacked_datamat, stacked_contrastdata, ...
	brainlv, designlv, k, num_subj_lst)

    scores = stacked_datamat * brainlv;
    fscores = [];

    num_groups = length(num_subj_lst);

    for g = 1:num_groups

	n = num_subj_lst(g);
	t = size(stacked_contrastdata, 2);		% number of contrasts
	tmp = [];

        %  the length of previous group
        %
	span = sum(num_subj_lst(1:g-1)) * k;


        %  traverse each condition, and perform score design score
        %  computation
        %
	for i = 1:k
	    tmp_k = stacked_contrastdata([1+n*(i-1)+span:n*i+span],:) * ...
		designlv([1+(g-1)*t:t+(g-1)*t],:);
	    tmp = [tmp; tmp_k];
	end

	fscores = [fscores; tmp];

    end

    return;


