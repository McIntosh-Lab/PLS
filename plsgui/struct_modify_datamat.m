%STRUCT_MODIFY_DATAMAT
%
%   USAGE: struct_modify_datamat(modifier, datamat_file)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h01 = struct_modify_datamat(varargin)

   if nargin == 0 | ~ischar(varargin{1})
      modifier = varargin{1};
      datamat_file = varargin{2};
      h01 = init(modifier, datamat_file);
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
      setappdata(gcf, 'filename', filename);
   elseif strcmp(action,'select_all_subj')
      select_all_subj;
   elseif strcmp(action,'click_modify')
      click_modify;
   elseif strcmp(action,'delete_fig')
      delete_fig;
   end

   return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   init: Initialize the GUI layout
%
%   I (datamat_file) - Matlab data file that contains a structure array
%			containing the session information for the study
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h01 = init(modifier, datamat_file)

   load(datamat_file);

   old_selected_subjects = selected_subjects;
   selected_subjects = modifier.selected_subjects;

   subj_name = session_info.subj_name;
   cond_name = session_info.condition;

   h01 = struct_create_modify_ui(1);
   set(h01, 'name', 'Modify Datamat');

   subj_lst_hdl = getappdata(h01,'subj_lst_hdl');
   filename_hdl = getappdata(h01,'filename_hdl');

   set(subj_lst_hdl, 'string', subj_name);

   setappdata(h01,'old_selected_subjects',old_selected_subjects);
   setappdata(h01,'selected_subjects', selected_subjects);

   if ~exist('create_ver','var')
      create_ver = plsgui_vernum;
   end
   setappdata(h01,'create_ver',create_ver);

   if ~exist('datafile','var')
      datafile = datamat_file;
   end
   setappdata(h01,'datafile',datafile);
%   setappdata(h01,'session_file',session_file);

   [filepath filename] = rri_fileparts(datamat_file);
   setappdata(h01,'filepath', filepath);
   setappdata(h01,'filename', filename);
   setappdata(h01,'old_filename', filename);
   set(filename_hdl, 'string', filename);

   setappdata(h01,'session_info', session_info);

   selected_lst = find(selected_subjects);
   if isempty(selected_lst)
      msgbox('No subject was selected, the first one is now selected.','modal');
      selected_subjects(1) = 1;
      selected_lst = 1;
   end
   set(subj_lst_hdl,'value',selected_lst,'list',selected_lst(1));

   return;					% init


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   select_all_subj: select all the subjects
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_all_subj

   subj_lst_hdl = getappdata(gcf, 'subj_lst_hdl');
   subj_selection = 1 : size(get(subj_lst_hdl, 'string'), 1);
   set(subj_lst_hdl, 'value', subj_selection, 'list', 1);

   return                                               % select_all_subj


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   click_modify
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function click_modify

   subj_lst_hdl = getappdata(gcf,'subj_lst_hdl');

   %  old_ is the one before modified
   %
   old_selected_subjects = getappdata(gcf,'old_selected_subjects');

   %  final selected_subjects
   %
   selected_subjects = zeros(1,length(old_selected_subjects));
   selected_subjects(get(subj_lst_hdl,'value')) = 1;
   new_selected_subjects = selected_subjects;

   old_filename = getappdata(gcf,'old_filename');
   filename = getappdata(gcf,'filename');
   filepath = getappdata(gcf,'filepath');

   old_datamat_file = fullfile(filepath, old_filename);
   datamat_file = fullfile(filepath, filename);

   if isequal(selected_subjects, old_selected_subjects) & ...
	isequal(filename, old_filename)

      close(gcf);
      return;

   end

   if ~rri_chkfname(filename, 'STRUCT', 'sessiondata')
      msg = 'File name must be ended with _STRUCTsessiondata.mat';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      
      return;
   end

   session_info = getappdata(gcf,'session_info');

   if isequal(filename, old_filename)
      try
         save(datamat_file, '-append', 'selected_subjects', 'session_info');
      catch
         datamat_file = [];
         msg1 = ['ERROR: Unable to write datamat file.'];
         set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
         return;
      end
   else

     load(old_datamat_file);

     selected_subjects = new_selected_subjects;

%     session_file = getappdata(gcf,'session_file');
     datafile = getappdata(gcf,'datafile');
     create_ver = getappdata(gcf,'create_ver');

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
         save(datamat_file, 'datafile', ...
		'coords','behavdata','behavname', ...
		'bad_coords', 'selected_subjects', ...
		'dims','voxel_size','origin','session_info', ...
		'create_ver','create_datamat_info','singleprecision');
         done = 1;
       catch
         datamat_file = [];
         msg1 = ['ERROR: Unable to write datamat file.'];
         set(findobj(gcf,'Tag','MessageLine'),'String',msg1);
         return;
       end
     end

     if ~isempty(savfig)
        set(savfig,'windowstyle','modal');
     end

   end

   close(gcf);

   return;                                      % click_modify


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   delete_fig
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      struct_create_modify_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'struct_create_modify_pos');
   catch
   end

   return;

