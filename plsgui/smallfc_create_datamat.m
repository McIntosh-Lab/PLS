function smallfc_create_datamat(varargin)

   if nargin == 0 | ~ischar(varargin{1})
      session_file = varargin{1}{1};
      init(session_file);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = varargin{1};

   if strcmp(action,'filename_edit')
      filename_hdl = getappdata(gcf, 'filename_hdl');
      filename = get(filename_hdl, 'string');
      setappdata(gcf,'filename',filename);
   elseif strcmp(action,'create_bn_pressed')
      CreateDatamat;
   elseif strcmp(action,'merge_conditions')
      MergeConditions;
   elseif strcmp(action,'close_bn_pressed')
      close(gcf);
      plsgui(3);
   end

   return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function init(session_file)

   session_info = session_file;

   datamat_prefix = session_info.datamat_prefix;
   num_subjects = session_info.num_subjects;
   num_conditions = session_info.num_conditions;

   subject = session_info.subject;
   subj_files = session_info.subj_files;

   subj_name = session_info.subj_name;
   cond_name = session_info.condition;

   pls_data_path = session_info.pls_data_path;

   progress_hdl = rri_progress_ui('initialize', 'Creating Datamat');
   factor = 1/(num_subjects*num_conditions);
   rri_progress_ui(progress_hdl, '', 0.5*factor);

   datamat = [];

   for k = 1:num_conditions
      for n = 1:num_subjects
         message=['Loading condition ',num2str(k),', subject ',num2str(n),'.'];
         rri_progress_ui(progress_hdl,'Loading Subjects',message);

         subj = fullfile(subject{n}, subj_files{k,n});

         try
            tmp = load(subj);
         catch
             close(progress_hdl);
             msg =  ['ERROR: "' subj '" does not exist.'];
             error(msg);
         end

         if length(tmp) ~= prod(session_info.dims)
             close(progress_hdl);
             msg =  ['ERROR: "' subj '" does not match data dimension.'];
             set(findobj(gcf,'Tag','MessageLine'),'String',msg);
             return;
         end

         datamat = [datamat; tmp(:)'];
      end

      rri_progress_ui(progress_hdl, '', ((k-1)*num_subjects+n)*factor);
   end

   filename = [session_info.datamat_prefix, '_SmallFCsessiondata.mat'];



   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   savepwd = curr;

   message = 'Saving to the disk ...';
   rri_progress_ui(progress_hdl,'Save',message);

   %  save to disk
   %
   datamatfile = fullfile(curr, filename);

   %  check if exist datamat file
   %
   if(exist(datamatfile,'file')==2)  % datamat file with same filename exist
      dlg_title = 'Confirm File Overwrite';
      msg = ['File ',filename,' exist. Are you sure you want to overwrite it?'];
      response = questdlg(msg,dlg_title,'Yes','No','Yes');

      if(strcmp(response,'No'))
           close(progress_hdl);
           msg1 = ['WARNING: Datamat file is not saved.'];
           set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
           return;
      end
   end

   create_ver = plsgui_vernum;

%   selected_conditions = ones(1, session_info.num_conditions);
 %  selected_subjects = ones(1, session_info.num_subjects);

   v7 = version;
   if str2num(v7(1))<7
      singleprecision = 0;
   else
      singleprecision = 1;
   end

   savfig = [];
   if strcmpi(get(gcf,'windowstyle'),'modal')
      savfig = gcf;
      set(gcf,'windowstyle','normal');
   end

   %  save datamat file
   %
   done = 0;

   while ~done
      try
         save(datamatfile, 'create_ver', 'datamat', ...
		'session_info', 'singleprecision');

%		'selected_conditions', 'selected_subjects', ...

         done = 1;
      catch
          close(progress_hdl);
          msg1 = ['ERROR: Unable to write datamat file.'];
          set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
          return;
      end
   end

   if ~isempty(savfig)
      set(savfig,'windowstyle','modal');
   end

   cd(savepwd);
   close(progress_hdl);


    [filepath filename] = rri_fileparts(datamatfile);
    set(gcf,'Name',['Session File: ' filename]);


%   h_createdatamat = gcf;
 %  smallfc_plot_ui({datamatfile, 1});
  % close(h_createdatamat);

   msg1 = ['WARNING: Do not change file name manually in command window.'];
   uiwait(msgbox(msg1,'File has been saved'));

   return;					% CreateDatamat

