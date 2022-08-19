function rri_changepath_ui(type)
%
% usage: rri_changepath_ui('petresult')
%
% 'petresult' is type, and it can also be:
%
%	'petresult'
%	'petdatamat'
%	'erpresult'
%	'erpdatamat'
%	'erpdata'
%	'structresult'
%	'structdatamat'
%	'structdata'
%	'bfmriresult'
%	'bfmridatamat'
%	'bfmrisession'
%	'fmriresult'
%	'fmridatamat'
%	'fmrisession'
%
   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   switch type
   case {'petresult', 'erpresult', 'structresult', 'smallfcresult'}
      datamat_files = evalin('caller', 'datamat_files');
      datamat_files = change_petresult(curr,datamat_files);
      assignin('caller', 'datamat_files', datamat_files);
   case {'petdatamat', 'erpdatamat', 'structdatamat'}
      session_info = evalin('caller', 'session_info');
      session_info = change_petdatamat(curr, session_info);
      assignin('caller', 'session_info', session_info);
   case {'erpdata', 'structdata'}
      datafile = evalin('caller', 'datafile');
      datafile = change_erpdata(curr,datafile);
      assignin('caller', 'datafile', datafile);
   case {'fmriresult', 'bfmriresult'}
      SessionProfiles = evalin('caller', 'SessionProfiles');
      SessionProfiles = change_fmriresult(curr,SessionProfiles);
      assignin('caller', 'SessionProfiles', SessionProfiles);
   case {'fmridatamat', 'bfmridatamat'}
      st_sessionFile = evalin('caller', 'st_sessionFile');
      st_sessionFile = change_fmridatamat(curr,st_sessionFile);
      assignin('caller', 'st_sessionFile', st_sessionFile);
   case {'fmrisession', 'bfmrisession'}
      session_info = evalin('caller', 'session_info');
      session_info = change_fmrisession(curr,session_info);
      assignin('caller', 'session_info', session_info);
   end

   return;					% rri_changepath


%---------------------------------------------------------------------------
%
function datamat_files = change_petresult(curr,datamat_files)

   for i = 1:length(datamat_files)
      [tmp fn] = rri_fileparts(datamat_files{i});
      datamat_files{i} = fullfile(curr, fn);
   end

   return;					% change_petresult


%---------------------------------------------------------------------------
%
function session_info = change_petdatamat(curr, session_info)

   session_info.pls_data_path = curr;

   return;					% change_petdatamat


%---------------------------------------------------------------------------
%
function datafile = change_erpdata(curr,datafile)

   [tmp fn] = rri_fileparts(datafile);
   datafile = fullfile(curr, fn);

   return;					% change_erpdatamat


%---------------------------------------------------------------------------
%
function SessionProfiles = change_fmriresult(curr,SessionProfiles)

   for i = 1:length(SessionProfiles)
      for j = 1:length(SessionProfiles{i})
         [tmp fn] = rri_fileparts(SessionProfiles{i}{j});
         SessionProfiles{i}{j} = fullfile(curr, fn);
      end
   end

   return;					% change_fmriresult


%---------------------------------------------------------------------------
%
function st_sessionFile = change_fmridatamat(curr,st_sessionFile)

   [tmp fn] = rri_fileparts(st_sessionFile);
   st_sessionFile = fullfile(curr, fn);

   return;					% change_fmridatamat


%---------------------------------------------------------------------------
%
function session_info = change_fmrisession(curr,session_info)

   session_info.pls_data_path = curr;

   return;					% change_fmrisession

