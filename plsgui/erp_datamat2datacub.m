% ERP_DATAMAT2DATACUB
%
% Transform from a list of 2 dimensional data matrix 'datamat':
%	subjects*conditions x timepoints*channels
% to 4 dimensional data cubic 'datacub':
%	timepoints x channels x subjects x conditions
% to be easily taken by plotting program
%
% Also do average for all subjects
% 
% Usage: datacub = erp_datamat2datacub(newdata_lst, ...
%		common_channels, common_conditions)
%
% See also ERP_DATACUB2DATAMAT
 
% Created by Jimmy Shen, 2002-12-30
% modified by jimmy 6/11/03, to seperate condition in different groups
%
%-----------------------------------------------------------------------

function [datacub, datacub_subj] = erp_datamat2datacub(newdata_lst, ...
		common_channels, common_conditions, mean_wave_list)

   datacub = [];				%  average (num_row = num_cond)
   datacub_subj = [];
   subj_row = 0;				%  num_subj*num_cond for all grp

   num_group = length(newdata_lst);

   for i = 1:num_group

      datamat = newdata_lst{i};
      [r c] = size(datamat);

      num_cond = sum(common_conditions);
      num_chan = sum(common_channels);
      num_subj = r/num_cond;
      timepoint = round(c/num_chan);

      datacub_subj = [datacub_subj; datamat];
      subj_row = subj_row + r;

      datamat = reshape(datamat, [num_subj, num_cond*c]);
      datamat = mean(datamat);			% 1 row, rep. all subj in group i
      datamat = reshape(datamat, [num_cond,c]);	% reshape out cond for each group

      datacub = [datacub; datamat];

   end

   num_cond = num_cond * num_group;

%   datacub = mean(datacub);			% here datacub become a row vector
%   datacub = reshape(datacub, [num_cond, c]);	% reshape out condition first

   for i = 1:length(mean_wave_list)
      new_cond = mean(datacub(mean_wave_list{i},:),1);
      datacub = [datacub; new_cond];
   end

   num_cond = num_cond + length(mean_wave_list);

   datacub = reshape(datacub', [timepoint, num_chan, num_cond]);  % reshape all
   datacub_subj = reshape(datacub_subj', [timepoint, num_chan, subj_row]);

   return;

