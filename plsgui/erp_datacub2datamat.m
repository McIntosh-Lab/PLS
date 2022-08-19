%ERP_DATACUB2DATAMAT
%
% Transform from 4 dimensional data cubic 'datacub':
%	timepoints x channels x subjects x conditions
% to 2 dimensional data matrix 'datamat':
%	subjects*conditions x timepoints*channels
% which will be used for the analysis
%
% Usage: [datamat, behavdata, contrastdata] = erp_datacub2datamat( ...
%	datacub, time_info, session_info, ...
%	selected_channels, selected_subjects, selected_conditions)
%
% See also ERP_DATAMAT2DATACUB
 
% variable name convention:
%
%	datamat:			subject data matrix for analyses
%	behavdata:			data matrix for behavior analysis
%	contrastdata:			data matrix for task analysis
%	datacub:			data cubic which contains everything
%	session_info.condition:		list of conditions name
%	session_info.subj_name:		list of subjects name
%	session_info.num_conditions:	total number of conditions
%	session_info.num_subjects:	total number of subjects
%	session_info.chan_order:	list of channel order
%	time_info:			orig time information
%	selected_channels: (mask)	after unselect certain chan
%	selected_subjects: (mask)	after unselect certain subj
%	selected_conditions: (mask)	after unselect certain cond
%	selected_subj_name:		after unselect certain subj
%	selected_cond_name:		after unselect certain cond
%
% Created by Jimmy Shen, 2002-12-24
%
%-----------------------------------------------------------------------

function [datamat, behavdata, contrastdata] = erp_datacub2datamat( ...
	datacub, time_info, session_info, ...
	selected_channels, selected_subjects, selected_conditions)

   % get upper & lower limit of timepoints
   %
   start_timepoint = floor((time_info.start_time - ...
	time_info.prestim) / time_info.digit_interval +1);
   end_timepoint = start_timepoint + time_info.timepoint -1;

   % chop datacub to what user selected
   %
   datacub = datacub(start_timepoint:end_timepoint, ...
			find(selected_channels), ...
			find(selected_subjects), ...
			find(selected_conditions));

   [ti ch s c] = size(datacub);

   % ti: number of timepoints
   % ch: number of channels
   % s: number of subjects
   % c: number of conditions

   % reshape it to datamat
   %
   datamat = reshape(datacub, [ti*ch, s*c]);
   datamat = datamat';

   num_cond = session_info.num_conditions;	% num of all cond
   num_subj = session_info.num_subjects;	% num of all subj
   behavdata = session_info.behavdata;		% all behavior data
   contrastdata = session_info.contrastdata;	% all contrast data

   %  only rows that corresponded to selected_conditions should be selected
   %
   if ~isempty(behavdata) | ~isempty(contrastdata)
      cond_mask = repmat(selected_conditions, [num_subj, 1]);
      subj_mask = repmat(selected_subjects', [1, num_cond]);
      mask = cond_mask.*subj_mask;

      % remember: reshape start by columnwise (1st dim), then 2nd, 3rd, ...
      %
      mask = reshape(mask, [1, num_cond*num_subj]);
      mask = find(mask);

      if ~isempty(behavdata)
         behavdata = behavdata(mask,:);
      end

      if ~isempty(contrastdata)
         contrastdata = contrastdata(mask,:);
      end

   else
      behavdata = [];
      contrastdata = [];
   end

   return;

