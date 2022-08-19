%ERP_GET_COMMON it will stack the datamat in all the groups together, get
%	the common channels , common conditions, common analysis time,
%	and return other information. Assuming all the groups have the same
%	digitization intervals.
%
%   Usage: [newdata_lst, behavdata_lst, helmertdata_lst, ...
%	contrastdata_lst, subj_name_lst, ...
%	num_cond_lst, num_subj_lst, ...
%	common_channels, common_conditions, common_time_info, ...
%	chan_order, cond_name] = erp_get_common(varargin)
%
%   See also PET_GET_COMMON
%

%   Called by erp_analysis
%
%   O (newdata_lst) - trimmed datamats.
%   O (behavdata_lst) - list of behavior data for behavior analysis
%   O (contrastdata_lst) - list of contrast data for task analysis
%   O (helmertdata_lst) - list of helmert data for task analysis
%   O (subj_name_lst) - subject names.
%   O (num_cond_lst) - an array contains number of conditions in each group
%   O (num_subj_lst) - an array contains number of subjects in each group
%   O (common_channels) - common channels among groups
%   O (common_conditions) - common conditions (selection) among groups
%   O (common_time_info) - common analysis time among groups
%   O (chan_order) - channel order data from session file
%   O (cond_name) - condition name data from session file
%
%   I (datamat_files) - list of datamat files.
%   I (behavdata_col) - Selected column mask for Behavior Data;
%   I (contrastdata_col) - Selected column mask for Contrast Data;
%   I (cond_selection) - additional condition selection in PLS run window;
%   I (progress_hdl) - handle to update the rri progross bar.
%
%   Created on 27-DEC-2002 by Jimmy Shen
%   Modified on Jan 10, 2003 to add contrast data & helmert data
%   Modified on Aug 16, 2004 to add additional cond_selection
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [newdata_lst, behavdata_lst, helmertdata_lst, ...
	contrastdata_lst, subj_name_lst, ...
        num_cond_lst, num_subj_lst, common_behav, ...
        common_channels, common_conditions, common_time_info, ...
	chan_order, cond_name, behavname] = erp_get_common(varargin)

   if(nargin > 0)
      datamat_files = varargin{1};
      behavdata_col = varargin{2};
      contrastdata_col = varargin{3};
      cond_selection = varargin{4};
      if(nargin > 4), progress_hdl = varargin{4}; end;
   else
      error('Check input arguments');
   end

   if(nargin > 4)
      progress_hdl = rri_progress_ui('initialize', 'Stacking datamat');
      msg = 'Stacking datamats ...';
      rri_progress_ui(progress_hdl, '', msg);
   end

   %  initial output variable
   %
   behavdata_lst = [];
   contrastdata_lst = [];
   helmertdata_lst = [];
   newdata_lst = [];
   subj_name_lst = [];
   common_channels = [];
   common_conditions = [];
   common_behav = [];

   common_time_info.prestim = -999999;
   common_time_info.digit_interval = 0;
   common_time_info.end_epoch = 999999;
   common_time_info.timepoint = 0;
   common_time_info.start_timepoint = 0;
   common_time_info.start_time = -999999;
   common_time_info.end_time = 999999;

   num_files = length(datamat_files);

   %  find common channels & common_time_info first
   %
   for i=1:num_files

      load(datamat_files{i}, 'time_info', 'session_info', ...
	'selected_channels', 'selected_conditions', 'selected_behav');

      if ~exist('selected_behav','var')
         selected_behav = ones(1, size(session_info.behavdata, 2));
      end

      %  initially, common_channels is empty, init it with zero array
      %
      if isempty(common_channels)
         common_channels = zeros(1,length(selected_channels));
      end

      %  initially, common_conditions is empty, init it with zero array
      %
      if isempty(common_conditions)
         common_conditions = zeros(1,length(selected_conditions));
      end

      %  initially, common_behav is empty, init it with zero array
      %
      if isempty(common_behav)
         common_behav = zeros(1,length(selected_behav));
      end

      %  find the common channels & common conditions & common behav that will be the
      %  maximum value in the array
      %
      common_channels = common_channels + selected_channels;
      common_conditions = common_conditions + selected_conditions;

      if isempty(selected_behav) | length(common_behav) ~= length(selected_behav)
         common_behav = [];
      else
         common_behav = common_behav + selected_behav;
      end

      %  find max_start_time
      %
      if time_info.prestim > common_time_info.prestim
         common_time_info.prestim = time_info.prestim;
      end

      if time_info.end_epoch < common_time_info.end_epoch
         common_time_info.end_epoch = time_info.end_epoch;
      end

      if time_info.start_time > common_time_info.start_time
         common_time_info.start_time = time_info.start_time;
      end

      if time_info.end_time < common_time_info.end_time
         common_time_info.end_time = time_info.end_time;
      end

   end						% for num_files 1

   common_time_info.digit_interval = time_info.digit_interval;
   common_time_info.timepoint = round((common_time_info.end_time - common_time_info.start_time) / time_info.digit_interval +1);
   common_time_info.start_timepoint = floor(common_time_info.start_time / time_info.digit_interval);

   %  find only the overlap parts of common channels
   %
   idx = find(common_channels == num_files);
   common_channels = zeros(1,length(selected_channels));
   common_channels(idx) = 1;

   %  find only the overlap parts of common conditions
   %
   idx = find(common_conditions == num_files);
   common_conditions = zeros(1,length(selected_conditions));
   common_conditions(idx) = 1;

   old_selected_conditions = common_conditions;
   selected_conditions_idx = find(old_selected_conditions);
   new_cond_selection = zeros(1, length(old_selected_conditions));
   new_cond_selection(selected_conditions_idx(find(cond_selection))) = 1;
   common_conditions = new_cond_selection;

   %  find only the overlap parts of common behav
   %
   if ~isempty(common_behav)
      idx = find(common_behav == num_files);
      common_behav = zeros(1,length(selected_behav));
      common_behav(idx) = 1;
   end

   %  find common datamat
   %
   for i=1:num_files

      warning off;
      load(datamat_files{i}, 'datamat', 'datafile', 'session_info', ...
	'session_file', 'selected_subjects');
      warning on;

      rri_changepath('erpdatamat');

      if exist('datafile','var')
         rri_changepath('erpdata');
         load(datafile);
      end

      [datamat, behavdata, contrastdata] = erp_datacub2datamat( ...
         datamat, common_time_info, session_info, ...
         common_channels, selected_subjects, common_conditions);

      num_cond_lst(i) = sum(common_conditions);
      num_subj_lst(i) = sum(selected_subjects);

%      helmertdata_lst{i} = rri_mkhelmert(num_cond_lst(i), num_subj_lst(i));


%      behavmask = selected_subjects'*common_conditions;
%      behavmask = find(behavmask(:));

      if ~isempty(behavdata)
%         behavdata_lst{i} = behavdata(behavmask,behavdata_col);
         behavdata_lst{i} = behavdata(:,find(common_behav));
      end

      if ~isempty(contrastdata)
         design = contrastdata(:,contrastdata_col);
         [r c]=size(design);
         orthocheck=sum(sum(design.^2));

         if round(orthocheck)~=c
            design=normalize(design);
         end

         contrastdata_lst{i} = design;
      end

      if(nargin > 4)
         rri_progress_ui(progress_hdl,'',i/num_files);
      end

      newdata_lst{i} = datamat;
      subj_name_lst{i} = session_info.subj_name(find(selected_subjects));

   end						% for num_files 2

   chan_order = session_info.chan_order;	% channel mask
   cond_name = session_info.condition;		% condition name

   if ~isfield(session_info, 'behavname')
      session_info.behavname = {};
      for i=1:size(session_info.behavdata,2)
         session_info.behavname = [session_info.behavname, {['behav', num2str(i)]}];
      end
   end

   behavname = session_info.behavname;		% behavior column name

   behavname = behavname(find(common_behav));

   return					% erp_get_common

