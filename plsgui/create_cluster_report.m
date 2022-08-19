function create_cluster_report(varargin)
%
% USAGE:  create_cluster_report(report_prefix, result_file, ...
%		is_bs, LV, min_size, min_dist, thresh, thresh2, ...
%		peak_thresh, peak_thresh2)
%
%   Input:  
%	report_prefix - report file prefix, the rest should be _fMRIcluster.mat
%	result_file - result file name, e.g. abc_fMRIresult.mat
%	is_bs - 0 for BLV report; 1 for Bootstrap Ratio report
%	LV - which LV to report (default = 1)
%	min_size - minimum number of voxels within a cluster (default = 5)
%	min_dist - minimum distant (in mm) between the peaks of any two
%                  clusters (default = 4mm)
%	threshold - Positive threshold
%	threshold2 - Negative threshold
%	peak_thresh - Positive peak threshold
%	peak_thresh2 - Negative peak threshold
%

%   if (nargin == 0) | ~ischar(varargin{1})
       if (nargin >= 2)
          report_prefix = varargin{1};
          result_file = varargin{2};
       else
          error('USAGE:  create_cluster_report(report_prefix, result_file, [is_bs, LV, min_size, min_dist, thresh, thresh2, peak_thresh, peak_thresh2])');
       end;

       if (nargin >= 3)
          is_bs = varargin{3};
       else
          is_bs = 0;
       end;

       if (nargin >= 4)
          LV = varargin{4};
       else
          LV = 1;
       end;

       if (nargin >= 5)
          min_size = varargin{5};
       else
          min_size = 5;
       end;

       if (nargin >= 6)
          min_dist = varargin{6};
       else
          min_dist = 10;
       end;

       if (nargin >= 7)
          threshold = varargin{7};
       else
          threshold = [];
       end;

       if (nargin >= 8)
          threshold2 = varargin{8};
       else
          threshold2 = [];
       end;

       if (nargin >= 9)
          peak_thresh = varargin{9};
       else
          peak_thresh = [];
       end;

       if (nargin >= 10)
          peak_thresh2 = varargin{10};
       else
          peak_thresh2 = [];
       end;

       p = which('plsgui');
       [p f] = fileparts(p); [p f] = fileparts(p);
       cmdloc = fullfile(p, 'plscmd');
       addpath(cmdloc);

       if ~isempty(findstr(result_file, 'fMRIresult.mat'))
           get_cluster_info_fmri(report_prefix, result_file, ...
		is_bs, LV, min_size, min_dist, threshold, threshold2, ...
		peak_thresh, peak_thresh2);
       elseif ~isempty(findstr(result_file, 'PETresult.mat'))
           get_cluster_info_pet(report_prefix, result_file, ...
		is_bs, LV, min_size, min_dist, threshold, threshold2, ...
		peak_thresh, peak_thresh2);
       elseif ~isempty(findstr(result_file, 'STRUCTresult.mat'))
           get_cluster_info_struct(report_prefix, result_file, ...
		is_bs, LV, min_size, min_dist, threshold, threshold2, ...
		peak_thresh, peak_thresh2);
       else
          error('Please check the result file name.');
       end

       return;
%   end;

   action = varargin{1};

   switch (action),
     case {'initialize'}
	 cluster_info = varargin{2};
	 header_type = varargin{3};
         show_cluster_report(cluster_info,header_type,[]);
     case {'PrevPage'}
         curr_page = getappdata(gcbf,'CurrPage');
         show_report_page(curr_page-1);
     case {'NextPage'}
         curr_page = getappdata(gcbf,'CurrPage');
         show_report_page(curr_page+1);
      case {'LoadClusterReport'}
	 cluster_fig = load_cluster_report(varargin{2});
      case {'SaveClusterReport'}
	 save_cluster_report;
      case {'SaveClusterTXT'}
	 save_cluster_txt;
      case {'SaveAllLocation'}
         save_all_location;
      case {'SavePeakLocation'}
         save_peak_location;
      case {'delete_fig'}
         delete_fig;
   end;  

   return;					% find_active_cluster

