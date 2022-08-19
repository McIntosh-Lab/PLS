%ERP_RESULT_UI Display the PLS analysis results for ERP scan
%
%   Usage: fig = erp_result_ui(action,varargin)
%
%   see also pet_result_ui
%

%   Called by plsgui
%
%   Created on 31-DEC-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fig = erp_result_ui(action,varargin)

   [PLSresultFile,PLSresultFilePath] =  ...
		rri_selectfile('*ERPresult.mat','Open ERP Result');
   if (PLSresultFilePath == 0), return; end;

   cd(PLSresultFilePath);
   PLSResultFile = fullfile(PLSresultFilePath,PLSresultFile);

   try
      warning off;
      load(PLSResultFile, 'datamat_files', 'datamat_files_timestamp');
      warning on;
   catch
      msgbox('Can not open file','Error');
      return
   end

   if exist('plslog.m','file')
      plslog('Show ERP Result');
   end

   rri_changepath('erpresult');

   if 0 % exist('datamat_files_timestamp','var')

      datamat_files_timestamp_old = datamat_files_timestamp;
      change_timestamp = 0;

      for i = 1:length(datamat_files)
         tmp = dir(datamat_files{i});

         if datenum(tmp.date) > datenum(datamat_files_timestamp{i})
            change_timestamp = 1;
         end
      end

      if change_timestamp
         msg1 = ['One or more datamat files are newer than their '];
         msg1 = [msg1, 'timestamp stored in the result file.'];
         msg2 = 'If you believe that the datamat files are just touched (e.g. due to copy) but not modified, you can click "Proceed All".';
         msg3 = 'Otherwise, please click "Stop", and re-create the result file.';

         quest = questdlg({msg1 '' msg2 '' msg3 ''}, 'Choose','Proceed All','Stop','Stop');

         if strcmp(quest,'Stop')
            return;
         end

         set(gcbf,'Pointer','watch');

         for i = 1:length(datamat_files)
            tmp = dir(datamat_files{i});
            datamat_files_timestamp{i} = tmp.date;
         end
      end

      if ~isequal(datamat_files_timestamp, datamat_files_timestamp_old)
         try
            save(PLSResultFile, '-append', 'datamat_files_timestamp');
         catch
            uiwait(msgbox('Can not save new timestamp','Error','modal'));
         end
      end
   end

   close(gcbf);
   fig = erp_plot_ui({PLSResultFile, 3});

   return;

