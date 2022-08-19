%  Usage: session2sessiondata(session)
%	where session can be a session filename (e.g. a_PETsession.mat)
%	or a folder name containing all the session files.
%
%  Example:	session2sessiondata('.')
%	will convert all the old session / datamat files in the current
%	folder to new sessiondata files. Note: old session / datamat
%	files will NOT be removed or modified.
%
function session2sessiondata(session)

   if ~exist(session,'dir')
      p = fileparts(session);
      session2sessiondata1(session, p);
   else
      fn_lst = dir(fullfile(session, '*session.mat'));

      for j=1:length(fn_lst)
         session_fn = fullfile(session, fn_lst(j).name);
         session2sessiondata1(session_fn, session);
      end
   end

   return;


%--------------------------------------------------------------------------
function session2sessiondata1(session_fn, session)

   load(session_fn);

   if ~isempty(findstr(session_fn, '_BfMRIsession.mat'))
      datamat_fn = [session_info.datamat_prefix '_BfMRIdatamat.mat'];
      sessiondata = strrep(session_fn, '_BfMRIsession.mat', '_BfMRIsessiondata.mat');
   elseif ~isempty(findstr(session_fn, '_fMRIsession.mat'))
      datamat_fn = [session_info.datamat_prefix '_fMRIdatamat.mat'];
      sessiondata = strrep(session_fn, '_fMRIsession.mat', '_fMRIsessiondata.mat');
   elseif ~isempty(findstr(session_fn, '_PETsession.mat'))
      datamat_fn = [session_info.datamat_prefix '_PETdatamat.mat'];
      sessiondata = strrep(session_fn, '_PETsession.mat', '_PETsessiondata.mat');
   elseif ~isempty(findstr(session_fn, '_ERPsession.mat'))
      datamat_fn = [session_info.datamat_prefix '_ERPdatamat.mat'];
      sessiondata = strrep(session_fn, '_ERPsession.mat', '_ERPsessiondata.mat');
   elseif ~isempty(findstr(session_fn, '_STRUCTsession.mat'))
      datamat_fn = [session_info.datamat_prefix '_STRUCTdatamat.mat'];
      sessiondata = strrep(session_fn, '_STRUCTsession.mat', '_STRUCTsessiondata.mat');
   end

   datamat_fn = fullfile(session, datamat_fn);
   load(datamat_fn);
   clear session session_fn datamat_fn
   save(sessiondata);

   return;

