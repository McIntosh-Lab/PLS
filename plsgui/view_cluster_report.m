function view_cluster_report(varargin)
%
% USAGE:  view_cluster_report(report_file)
%
%   Input:  
%	report_file - report file name, e.g. abc_fMRIcluster.mat
%

   if (nargin == 0) | ~ischar(varargin{1})
      error('USAGE:  view_cluster_report(report_file)');
   end;

   report_file = varargin{1};

   p = which('plsgui');
   [p f] = fileparts(p); [p f] = fileparts(p);
   cmdloc = fullfile(p, 'plscmd');
   addpath(cmdloc);

   if ~isempty(findstr(report_file, 'fMRIcluster.mat'))
      show_cluster_info_fmri(report_file);
   elseif ~isempty(findstr(report_file, 'PETcluster.mat'))
      show_cluster_info_pet(report_file);
   elseif ~isempty(findstr(report_file, 'STRUCTcluster.mat'))
      show_cluster_info_struct(report_file);
   else
      error('Please check the cluster file name.');
   end

   return;					% view_cluster_report

