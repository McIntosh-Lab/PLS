%PLSGUI Splash screen to run PLS programs with Graphical User Interface.
%	It allow user to choose PET, ERP, Event Related fMRI, Blocked
%	fMRI, and Structure Module.
%
%   Usage: plsgui
%

%   Starting function.  Called by nothing.
%
%   I - none
%   O - handle to the splash screen
%
%   Modified on 12-SEP-2002 by Jimmy Shen
%   Modified on 23-oct-2002 to add ERP option
%   Modifyed on 12-feb-2003 to add format choose button
%   Modified on 08-jul-2004 to remove the prompt dialog box (%jul08)
%   Modified on 19-jan-2007 to add structure module
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fig = plsgui(action)

   %  limit recursion to 100 because:
   %
   %  1. set RecursionLimit too high can cause unnecessary
   %     combination of 2 or more clusters.
   %  2. all older version of MATLAB has a RecursionLimit
   %     set to 100 by default.
   %
   set(0,'RecursionLimit',100);

   if get(0,'ScreenDepth') == 0
	disp('ERROR: Cannot open figure window. ');
        disp('ERROR: Make sure the DISPLAY environment has been set.'); 
	return;
   end;

   v = '';
   r = version;
   [t r] = strtok(r,'.');
   v = [v t '.'];
   [t r] = strtok(r,'.');
   v = [v t '.'];
   v = str2num(v(1:end-1));

   if v >= 7.2
      feature accel off;
   end;

   if ~exist('action','var') | isempty(action) | isnumeric(action)

      pls = [];

      if nargin > 0
         pls = action;
      end

      f_hdl = init(pls);

      if (nargout >= 1),
         fig = f_hdl;
      end;

      return
   end

   switch action
      case {'ChoosePET'}
        ChoosePET;
      case {'ChooseERP'}
        ChooseERP;
      case {'ChoosefMRI'}
        ChoosefMRI;
      case {'ChooseBfMRI'}
	ChooseBfMRI;
      case {'ChooseSTRUCT'}
        ChooseSTRUCT;
      case {'toggle_save_setting'}
	toggle_save_setting;
      case {'toggle_save_display'}
	toggle_save_display;
      case {'change_pwd'}
	new_pwd = rri_getdirectory;

        if isempty(new_pwd)
           return;
        end

	try
	   cd(new_pwd);
	catch
	   msg = ['Can''t access directory: ', new_pwd];
	   msgbox(msg,'Error','modal');
        end
      case {'delete_fig'}
        delete_fig;
   end

   return;						% plsgui


%--------------------------------------------------------------------------
function fig = init(pls)

   save_setting_status = 'off';		% 'on';		%jul08
   save_display_status = 'off';
   plsgui_pos = [];

   curr_dir = pwd;
   if isempty(curr_dir)
      curr_dir = filesep;
   end

   try
     if ~exist('isdeployed','builtin') | ~isdeployed
      addpath(curr_dir);
     end
      load('pls_profile');
      pls_profile = which('pls_profile.mat');
%      save(pls_profile, '-append', 'save_setting_status');		%jul08
   catch
      msg = {'The program could not locate file "pls_profile.mat", '};
      msg = [msg; {'which can keep your GUI window positions.'}];
      msg = [msg;{[]}; {'You may want to create one if this is the first time you'}];
      msg = [msg; {'use this program. You can also open an existing one'}];
      msg = [msg; {'that you saved before.'}];
      tit = 'PLS position profile';
%      response = questdlg(msg,tit,'Create','Open','Cancel','Create');	%jul08

if 1									%jul08
                  pls_profile = fullfile(curr_dir,'pls_profile.mat');
                  try
                     save_setting_status = 'off';
                     save_display_status = 'off';
                     save(pls_profile, 'save_setting_status', 'save_display_status');
                    if ~exist('isdeployed','builtin') | ~isdeployed
                     addpath(curr_dir);
                    end
                  catch
                           pls_profile = [];
                           save_setting_status = 'off';
                           save_display_status = 'off';
                  end
else
      switch response
         case 'Create'
            msg = ['Do you want to put it under directory "',curr_dir,'"?'];
            tit = 'Confirm directory';
            response = questdlg(msg,tit,'Yes','No','Yes');

            switch response
               case 'Yes'
                  pls_profile = fullfile(curr_dir,'pls_profile.mat');
                  try
                     save_setting_status = 'on';
                     save_display_status = 'on';
                     save(pls_profile, 'save_setting_status', 'save_display_status');
                    if ~exist('isdeployed','builtin') | ~isdeployed
                     addpath(curr_dir);
                    end
                  catch
                     msg = ['Can not save "pls_profile.mat" under "',curr_dir,'"'];
                     msg = [msg, ', Do you want to try another directory?'];
                     tit = 'Save Error';
                     pls_profile = [];

                     response = questdlg(msg,tit,'Yes','No','Yes');

                     switch response
                        case 'Yes'
                           pls_profile = try_new_dir(curr_dir);
                        case 'No'
                           pls_profile = [];
                           save_setting_status = 'off';
                           save_display_status = 'off';
                     end
                  end
               case 'No'
                  pls_profile = try_new_dir(curr_dir);
            end
         case 'Open'
            [fn, new_dir] = rri_selectfile('pls_profile.mat', ...
		'PLS position profile');

            if new_dir == 0
               pls_profile = [];
               save_setting_status = 'off';
               save_display_status = 'off';
            else
               try
                 if ~exist('isdeployed','builtin') | ~isdeployed
                  addpath(new_dir);
                 end
                  load('pls_profile');
                  pls_profile=which('pls_profile.mat');
                  save(pls_profile, 'save_setting_status', 'save_display_status');
               catch
                  msg = ['Can not save "pls_profile.mat" under ',new_dir];
                  msg = [msg, ', Do you want to try another directory?'];
                  tit = 'Save Error';
                  pls_profile = [];

                  response = questdlg(msg,tit,'Yes','No','Yes');

                  switch response
                     case 'Yes'
                        pls_profile = try_new_dir(new_dir);
                     case 'No'
                        pls_profile = [];
                        save_setting_status = 'off';
                        save_display_status = 'off';
                  end
               end
            end
         case 'Cancel'
            pls_profile = [];
            save_setting_status = 'off';
            save_display_status = 'off';
      end
end
   end

   if isempty(pls_profile)
      save_setting_status = 'off';
      save_display_status = 'off';
   end

   if ~isempty(plsgui_pos) & strcmp(save_setting_status,'on')

      pos = plsgui_pos;

   else

      w = 0.7;
      h = 0.6;

      pos = [(1-w)/2 (1-h)/2 w h];

   end

   % create figure
   %
   h0 = figure('Units','normal', ...
        'Color',[0.8 0.8 0.8], ...
   	'Name','PLS for PET data', ...
        'NumberTitle','off', ...
   	'Position',pos, ...
   	'Menubar','none', ...
   	'Tag','RunPLSFigure', ...
        'deletefcn','plsgui(''delete_fig'');', ...
   	'ToolBar','none');

   % create frame
   %
   margin = 0.06;

   x = margin;
   y = margin;
   w = 1-2*x;
   h = 1-2*y;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'ListboxTop',0, ...
	'position',pos, ...
   	'Style','frame', ...
   	'Tag','PLSFrame');

   % several sets of buttons. PETs' are visible, others are invisible.
   %
   w = 0.82;
   x = (1-w)/2;
   y = 0.78;
   h = 0.1;

   pos = [x y w h];

   Hc_textPET = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'position',pos, ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.4, ...
   	'FontWeight','bold', ...
   	'String','PLS Analysis for:', ...
   	'Style','text', ...
	'Visible', 'on', ...
   	'Tag','PETLabel');
%   	'FontAngle','italic', ...
%        'FontName', 'FixedWidth', ... 

   Hc_textBfMRI = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.4, ...
   	'FontWeight','bold', ...
	'position',pos, ...
   	'String','PLS Analysis for:', ...
   	'Style','text', ...
	'Visible', 'off', ...
   	'Tag','BfMRILabel');
   
   Hc_textfMRI = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.4, ...
   	'FontWeight','bold', ...
	'position',pos, ...
   	'String','PLS Analysis for:', ...
   	'Style','text', ...
	'Visible', 'off', ...
   	'Tag','fMRILabel');
   
   Hc_textERP = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.4, ...
   	'FontWeight','bold', ...
	'position',pos, ...
   	'String','PLS Analysis for:', ...
   	'Style','text', ...
	'Visible', 'off', ...
   	'Tag','ERPLabel');

   Hc_textSTRUCT = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
   	'FontUnits','normal', ...
   	'FontSize',0.4, ...
   	'FontWeight','bold', ...
	'position',pos, ...
   	'String','PLS Analysis for:', ...
   	'Style','text', ...
	'Visible', 'off', ...
   	'Tag','STRUCTLabel');

   x = margin+0.01;
   w = (1-2*x)/5;
   y = y - 0.1;

   pos = [x y w h];

   h_pet = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'Position',pos, ...
   	'back',[0 0 0], ...
	'fore',[1 1 1], ...
        'CallBack', 'plsgui(''ChoosePET'');', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'String','PET', ...
	'Visible', 'on', ...
   	'Tag','PETButton');

   x = x+w;

   pos = [x y w h];

   h_erp = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'Position',pos, ...
   	'back',[0.7 0.7 0.7], ...
	'fore',[0 0 0], ...
        'CallBack', 'plsgui(''ChooseERP'');', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'String','ERP', ...
	'Visible', 'on', ...
   	'Tag','ERPButton');

   x = x+w;

   pos = [x y w h];

   h_fmri = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'Position',pos, ...
   	'back',[0.7 0.7 0.7], ...
	'fore',[0 0 0], ...
        'CallBack', 'plsgui(''ChoosefMRI'');', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'String','E.R. fMRI', ...
	'Visible', 'on', ...
   	'Tag','fMRIButton');

   x = x+w;

   pos = [x y w h];

   h_bfmri = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'Position',pos, ...
   	'back',[0.7 0.7 0.7], ...
	'fore',[0 0 0], ...
        'CallBack', 'plsgui(''ChooseBfMRI'');', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'String','Blocked fMRI', ...
	'Visible', 'on', ...
   	'Tag','BfMRIButton');

   x = x+w;

   pos = [x y w h];

   h_struct = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'Position',pos, ...
   	'back',[0.7 0.7 0.7], ...
	'fore',[0 0 0], ...
        'CallBack', 'plsgui(''ChooseSTRUCT'');', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'String','Structural', ...
	'Visible', 'on', ...
   	'Tag','STRUCTButton');

   button_gap = 0.14;

   w = 0.7;
   x = (1-w)/2;
   y = y - button_gap;

   button_pos = [x y w h];

   Hc_pushPETsession = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'Position',button_pos, ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','pet_session_profile_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'String','Session Profile for PET data', ...
	'Visible', 'on', ...
   	'Tag','PETSessionProfileButton');

   Hc_pushBfMRIsession = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','bfm_session_profile_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Session Profile for Block fMRI data', ...
	'Visible', 'off', ...
   	'Tag','BfMRISessionProfileButton');
   
   Hc_pushfMRIsession = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','fmri_session_profile_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Session Profile for E.R. fMRI data', ...
	'Visible', 'off', ...
   	'Tag','SessionProfileButton');
   
   Hc_pushERPsession = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','erp_session_profile_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Session Profile for ERP data', ...
	'Visible', 'off', ...
   	'Tag','ERPSessionProfileButton');

   Hc_pushSTRUCTsession = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','struct_session_profile_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Session Profile for Structural data', ...
	'Visible', 'off', ...
   	'Tag','STRUCTSessionProfileButton');

   button_pos(2) = button_pos(2) - button_gap;

   Hc_pushPETanalysis = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','pet_analysis_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Run PLS Analysis on PET data', ...
	'Visible', 'on', ...
   	'Tag','PETAnalysisButton');

   Hc_pushBfMRIanalysis = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','bfm_analysis_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Run PLS Analysis on Block fMRI data', ...
	'Visible', 'off', ...
   	'Tag','BfMRIAnalysisButton');
   
   Hc_pushfMRIanalysis = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','fmri_analysis_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Run PLS Analysis on E.R. fMRI data', ...
	'Visible', 'off', ...
   	'Tag','PLSAnalysisButton');
   
   Hc_pushERPanalysis = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','erp_analysis_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Run PLS Analysis on ERP data', ...
	'Visible', 'off', ...
   	'Tag','ERPAnalysisButton');

   Hc_pushSTRUCTanalysis = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','struct_analysis_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Run PLS Analysis on Structural data', ...
	'Visible', 'off', ...
   	'Tag','STRUCTAnalysisButton');

   button_pos(2) = button_pos(2) - button_gap;

   Hc_pushPETresult = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','pet_result_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Show PLS Result for PET data', ...
	'Visible', 'on', ...
   	'Tag','PETResultButton');

   Hc_pushBfMRIresult = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','bfm_result_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Show PLS Result for Block fMRI data', ...
	'Visible', 'off', ...
   	'Tag','BfMRIResultButton');
   
   Hc_pushfMRIresult = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','fmri_result_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Show PLS Result for E.R. fMRI data', ...
	'Visible', 'off', ...
   	'Tag','PLSResultButton');
   
   Hc_pushERPresult = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','erp_result_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Show PLS Result for ERP data', ...
	'Visible', 'off', ...
   	'Tag','ERPResultButton');

   Hc_pushSTRUCTresult = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','struct_result_ui;', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','Show PLS Result for Structural data', ...
	'Visible', 'off', ...
   	'Tag','STRUCTResultButton');

   button_pos(2) = button_pos(2) - button_gap;

   Hc_pushPETdone = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
   	'Callback','close(gcf);', ...
   	'FontUnits','normal', ...
   	'FontSize',0.3, ...
   	'FontWeight','bold', ...
   	'Position',button_pos, ...
   	'String','CLOSE', ...
	'Visible', 'on', ...
   	'Tag','PETDoneButton');

   h1 = uimenu('Parent',h0, ...
	   'Visible','off', ...
           'Label', '&Tools');

   h_save_setting = uimenu('Parent', h1, ...
           'Label', 'Save GUI &Positions', ...
           'check', save_setting_status, ...
           'CallBack', 'plsgui(''toggle_save_setting'');');

   h_save_display = uimenu('Parent', h1, ...
           'Label', 'Save &Display Setting for PET/MRI', ...
           'check', save_display_status, ...
           'CallBack', 'plsgui(''toggle_save_display'');');

   h_change_pwd = uimenu('Parent', h1, ...
           'Label', '&Change Current Working Directory', ...
           'Separator', 'on', ...
	   'visible', 'off', ...
           'CallBack', 'plsgui(''change_pwd'');');

   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
           'Tag', 'Help');

   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
	   'Callback','web([''file:///'', which(''UserGuide.htm'')]);', ...
	   'visible', 'on', ...
           'Tag', 'How');

   Hm_new = uimenu('Parent',Hm_topHelp, ...
           'Label', '&What''s new', ...
	   'Callback','rri_helpfile_ui(''whatsnew.txt'',''What''''s new'');', ...
           'Tag', 'New');

   Hm_about = uimenu('Parent',Hm_topHelp, ...
           'Label', '&About this program', ...
           'Tag', 'About', ...
           'CallBack', 'plsgui_version');

   setappdata(h0, 'save_setting_status', save_setting_status);
   setappdata(h0, 'save_display_status', save_display_status);
   setappdata(h0, 'h_save_setting', h_save_setting);
   setappdata(h0, 'h_save_display', h_save_display);
   fig = h0;

   p = which('plsgui');
   [p f] = fileparts(p); [p f] = fileparts(p);
   cmdloc = fullfile(p, 'plscmd');
   addpath(cmdloc);

   if ~isempty(pls)
      switch(pls)
         case {1}
            plsgui('ChoosePET');
         case {2}
            plsgui('ChoosefMRI');
         case {3}
            plsgui('ChooseERP');
         case {4}
            plsgui('ChooseBfMRI');
         case {5}
            plsgui('ChooseSTRUCT');
      end
   end
   
   return;						% init


%------------------------------------------------------------------------------------
function ChoosePET()

   Hc_textPET=findobj(gcf,'Tag','PETLabel');
   Hc_textBfMRI=findobj(gcf,'Tag','BfMRILabel');
   Hc_textfMRI=findobj(gcf,'Tag','fMRILabel');
   Hc_textERP=findobj(gcf,'Tag','ERPLabel');
   Hc_textSTRUCT=findobj(gcf,'Tag','STRUCTLabel');
   Hc_pushPETsession=findobj(gcf,'Tag','PETSessionProfileButton');
   Hc_pushBfMRIsession=findobj(gcf,'Tag','BfMRISessionProfileButton');
   Hc_pushfMRIsession=findobj(gcf,'Tag','SessionProfileButton');
   Hc_pushERPsession=findobj(gcf,'Tag','ERPSessionProfileButton');
   Hc_pushSTRUCTsession=findobj(gcf,'Tag','STRUCTSessionProfileButton');
   Hc_pushPETanalysis=findobj(gcf,'Tag','PETAnalysisButton');
   Hc_pushBfMRIanalysis=findobj(gcf,'Tag','BfMRIAnalysisButton');
   Hc_pushfMRIanalysis=findobj(gcf,'Tag','PLSAnalysisButton');
   Hc_pushERPanalysis=findobj(gcf,'Tag','ERPAnalysisButton');
   Hc_pushSTRUCTanalysis=findobj(gcf,'Tag','STRUCTAnalysisButton');
   Hc_pushPETresult=findobj(gcf,'Tag','PETResultButton');
   Hc_pushBfMRIresult=findobj(gcf,'Tag','BfMRIResultButton');
   Hc_pushfMRIresult=findobj(gcf,'Tag','PLSResultButton');
   Hc_pushERPresult=findobj(gcf,'Tag','ERPResultButton');
   Hc_pushSTRUCTresult=findobj(gcf,'Tag','STRUCTResultButton');
   h_pet = findobj(gcf,'tag','PETButton');
   h_bfmri = findobj(gcf,'tag','BfMRIButton');
   h_fmri = findobj(gcf,'tag','fMRIButton');
   h_erp = findobj(gcf,'tag','ERPButton');
   h_struct = findobj(gcf,'tag','STRUCTButton');

   set(gcf,'Name','PLS for PET data');
   set(Hc_textPET,'Visible','on');
   set(Hc_textBfMRI,'Visible','off');
   set(Hc_textfMRI,'Visible','off');
   set(Hc_textERP,'Visible','off');
   set(Hc_textSTRUCT,'Visible','off');
   set(Hc_pushPETsession,'Visible','on');
   set(Hc_pushBfMRIsession,'Visible','off');
   set(Hc_pushfMRIsession,'Visible','off');
   set(Hc_pushERPsession,'Visible','off');
   set(Hc_pushSTRUCTsession,'Visible','off');
   set(Hc_pushPETanalysis,'Visible','on');
   set(Hc_pushBfMRIanalysis,'Visible','off');
   set(Hc_pushfMRIanalysis,'Visible','off');
   set(Hc_pushERPanalysis,'Visible','off');
   set(Hc_pushSTRUCTanalysis,'Visible','off');
   set(Hc_pushPETresult,'Visible','on');
   set(Hc_pushBfMRIresult,'Visible','off');
   set(Hc_pushfMRIresult,'Visible','off');
   set(Hc_pushERPresult,'Visible','off');
   set(Hc_pushSTRUCTresult,'Visible','off');

   set(h_pet,'back',[0 0 0],'fore',[1 1 1]);
   set(h_bfmri,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_fmri,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_erp,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_struct,'back',[0.7 0.7 0.7],'fore',[0 0 0]);

   return;


%------------------------------------------------------------------------------------
function ChooseBfMRI()

   Hc_textPET=findobj(gcf,'Tag','PETLabel');
   Hc_textBfMRI=findobj(gcf,'Tag','BfMRILabel');
   Hc_textfMRI=findobj(gcf,'Tag','fMRILabel');
   Hc_textERP=findobj(gcf,'Tag','ERPLabel');
   Hc_textSTRUCT=findobj(gcf,'Tag','STRUCTLabel');
   Hc_pushPETsession=findobj(gcf,'Tag','PETSessionProfileButton');
   Hc_pushBfMRIsession=findobj(gcf,'Tag','BfMRISessionProfileButton');
   Hc_pushfMRIsession=findobj(gcf,'Tag','SessionProfileButton');
   Hc_pushERPsession=findobj(gcf,'Tag','ERPSessionProfileButton');
   Hc_pushSTRUCTsession=findobj(gcf,'Tag','STRUCTSessionProfileButton');
   Hc_pushPETanalysis=findobj(gcf,'Tag','PETAnalysisButton');
   Hc_pushBfMRIanalysis=findobj(gcf,'Tag','BfMRIAnalysisButton');
   Hc_pushfMRIanalysis=findobj(gcf,'Tag','PLSAnalysisButton');
   Hc_pushERPanalysis=findobj(gcf,'Tag','ERPAnalysisButton');
   Hc_pushSTRUCTanalysis=findobj(gcf,'Tag','STRUCTAnalysisButton');
   Hc_pushPETresult=findobj(gcf,'Tag','PETResultButton');
   Hc_pushBfMRIresult=findobj(gcf,'Tag','BfMRIResultButton');
   Hc_pushfMRIresult=findobj(gcf,'Tag','PLSResultButton');
   Hc_pushERPresult=findobj(gcf,'Tag','ERPResultButton');
   Hc_pushSTRUCTresult=findobj(gcf,'Tag','STRUCTResultButton');
   h_pet = findobj(gcf,'tag','PETButton');
   h_bfmri = findobj(gcf,'tag','BfMRIButton');
   h_fmri = findobj(gcf,'tag','fMRIButton');
   h_erp = findobj(gcf,'tag','ERPButton');
   h_struct = findobj(gcf,'tag','STRUCTButton');

   set(gcf,'Name','PLS for Block fMRI data');
   set(Hc_textPET,'Visible','off');
   set(Hc_textBfMRI,'Visible','on');
   set(Hc_textfMRI,'Visible','off');
   set(Hc_textERP,'Visible','off');
   set(Hc_textSTRUCT,'Visible','off');
   set(Hc_pushPETsession,'Visible','off');
   set(Hc_pushBfMRIsession,'Visible','on');
   set(Hc_pushfMRIsession,'Visible','off');
   set(Hc_pushERPsession,'Visible','off');
   set(Hc_pushSTRUCTsession,'Visible','off');
   set(Hc_pushPETanalysis,'Visible','off');
   set(Hc_pushBfMRIanalysis,'Visible','on');
   set(Hc_pushfMRIanalysis,'Visible','off');
   set(Hc_pushERPanalysis,'Visible','off');
   set(Hc_pushSTRUCTanalysis,'Visible','off');
   set(Hc_pushPETresult,'Visible','off');
   set(Hc_pushBfMRIresult,'Visible','on');
   set(Hc_pushfMRIresult,'Visible','off');
   set(Hc_pushERPresult,'Visible','off');
   set(Hc_pushSTRUCTresult,'Visible','off');

   set(h_pet,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_bfmri,'back',[0 0 0],'fore',[1 1 1]);
   set(h_fmri,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_erp,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_struct,'back',[0.7 0.7 0.7],'fore',[0 0 0]);

   return;


%------------------------------------------------------------------------------------
function ChoosefMRI()

   Hc_textPET=findobj(gcf,'Tag','PETLabel');
   Hc_textBfMRI=findobj(gcf,'Tag','BfMRILabel');
   Hc_textfMRI=findobj(gcf,'Tag','fMRILabel');
   Hc_textERP=findobj(gcf,'Tag','ERPLabel');
   Hc_textSTRUCT=findobj(gcf,'Tag','STRUCTLabel');
   Hc_pushPETsession=findobj(gcf,'Tag','PETSessionProfileButton');
   Hc_pushBfMRIsession=findobj(gcf,'Tag','BfMRISessionProfileButton');
   Hc_pushfMRIsession=findobj(gcf,'Tag','SessionProfileButton');
   Hc_pushERPsession=findobj(gcf,'Tag','ERPSessionProfileButton');
   Hc_pushSTRUCTsession=findobj(gcf,'Tag','STRUCTSessionProfileButton');
   Hc_pushPETanalysis=findobj(gcf,'Tag','PETAnalysisButton');
   Hc_pushBfMRIanalysis=findobj(gcf,'Tag','BfMRIAnalysisButton');
   Hc_pushfMRIanalysis=findobj(gcf,'Tag','PLSAnalysisButton');
   Hc_pushERPanalysis=findobj(gcf,'Tag','ERPAnalysisButton');
   Hc_pushSTRUCTanalysis=findobj(gcf,'Tag','STRUCTAnalysisButton');
   Hc_pushPETresult=findobj(gcf,'Tag','PETResultButton');
   Hc_pushBfMRIresult=findobj(gcf,'Tag','BfMRIResultButton');
   Hc_pushfMRIresult=findobj(gcf,'Tag','PLSResultButton');
   Hc_pushERPresult=findobj(gcf,'Tag','ERPResultButton');
   Hc_pushSTRUCTresult=findobj(gcf,'Tag','STRUCTResultButton');
   h_pet = findobj(gcf,'tag','PETButton');
   h_bfmri = findobj(gcf,'tag','BfMRIButton');
   h_fmri = findobj(gcf,'tag','fMRIButton');
   h_erp = findobj(gcf,'tag','ERPButton');
   h_struct = findobj(gcf,'tag','STRUCTButton');

   set(gcf,'Name','PLS for E.R. fMRI data');
   set(Hc_textPET,'Visible','off');
   set(Hc_textBfMRI,'Visible','off');
   set(Hc_textfMRI,'Visible','on');
   set(Hc_textERP,'Visible','off');
   set(Hc_textSTRUCT,'Visible','off');
   set(Hc_pushPETsession,'Visible','off');
   set(Hc_pushBfMRIsession,'Visible','off');
   set(Hc_pushfMRIsession,'Visible','on');
   set(Hc_pushERPsession,'Visible','off');
   set(Hc_pushSTRUCTsession,'Visible','off');
   set(Hc_pushPETanalysis,'Visible','off');
   set(Hc_pushBfMRIanalysis,'Visible','off');
   set(Hc_pushfMRIanalysis,'Visible','on');
   set(Hc_pushERPanalysis,'Visible','off');
   set(Hc_pushSTRUCTanalysis,'Visible','off');
   set(Hc_pushPETresult,'Visible','off');
   set(Hc_pushBfMRIresult,'Visible','off');
   set(Hc_pushfMRIresult,'Visible','on');
   set(Hc_pushERPresult,'Visible','off');
   set(Hc_pushSTRUCTresult,'Visible','off');

   set(h_pet,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_bfmri,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_fmri,'back',[0 0 0],'fore',[1 1 1]);
   set(h_erp,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_struct,'back',[0.7 0.7 0.7],'fore',[0 0 0]);

   return;


%------------------------------------------------------------------------------------
function ChooseERP()

   Hc_textPET=findobj(gcf,'Tag','PETLabel');
   Hc_textBfMRI=findobj(gcf,'Tag','BfMRILabel');
   Hc_textfMRI=findobj(gcf,'Tag','fMRILabel');
   Hc_textERP=findobj(gcf,'Tag','ERPLabel');
   Hc_textSTRUCT=findobj(gcf,'Tag','STRUCTLabel');
   Hc_pushPETsession=findobj(gcf,'Tag','PETSessionProfileButton');
   Hc_pushBfMRIsession=findobj(gcf,'Tag','BfMRISessionProfileButton');
   Hc_pushfMRIsession=findobj(gcf,'Tag','SessionProfileButton');
   Hc_pushERPsession=findobj(gcf,'Tag','ERPSessionProfileButton');
   Hc_pushSTRUCTsession=findobj(gcf,'Tag','STRUCTSessionProfileButton');
   Hc_pushPETanalysis=findobj(gcf,'Tag','PETAnalysisButton');
   Hc_pushBfMRIanalysis=findobj(gcf,'Tag','BfMRIAnalysisButton');
   Hc_pushfMRIanalysis=findobj(gcf,'Tag','PLSAnalysisButton');
   Hc_pushERPanalysis=findobj(gcf,'Tag','ERPAnalysisButton');
   Hc_pushSTRUCTanalysis=findobj(gcf,'Tag','STRUCTAnalysisButton');
   Hc_pushPETresult=findobj(gcf,'Tag','PETResultButton');
   Hc_pushBfMRIresult=findobj(gcf,'Tag','BfMRIResultButton');
   Hc_pushfMRIresult=findobj(gcf,'Tag','PLSResultButton');
   Hc_pushERPresult=findobj(gcf,'Tag','ERPResultButton');
   Hc_pushSTRUCTresult=findobj(gcf,'Tag','STRUCTResultButton');
   h_pet = findobj(gcf,'tag','PETButton');
   h_bfmri = findobj(gcf,'tag','BfMRIButton');
   h_fmri = findobj(gcf,'tag','fMRIButton');
   h_erp = findobj(gcf,'tag','ERPButton');
   h_struct = findobj(gcf,'tag','STRUCTButton');

   set(gcf,'Name','PLS for ERP data');
   set(Hc_textPET,'Visible','off');
   set(Hc_textBfMRI,'Visible','off');
   set(Hc_textfMRI,'Visible','off');
   set(Hc_textERP,'Visible','on');
   set(Hc_textSTRUCT,'Visible','off');
   set(Hc_pushPETsession,'Visible','off');
   set(Hc_pushBfMRIsession,'Visible','off');
   set(Hc_pushfMRIsession,'Visible','off');
   set(Hc_pushERPsession,'Visible','on');
   set(Hc_pushSTRUCTsession,'Visible','off');
   set(Hc_pushPETanalysis,'Visible','off');
   set(Hc_pushBfMRIanalysis,'Visible','off');
   set(Hc_pushfMRIanalysis,'Visible','off');
   set(Hc_pushERPanalysis,'Visible','on');
   set(Hc_pushSTRUCTanalysis,'Visible','off');
   set(Hc_pushPETresult,'Visible','off');
   set(Hc_pushBfMRIresult,'Visible','off');
   set(Hc_pushfMRIresult,'Visible','off');
   set(Hc_pushERPresult,'Visible','on');
   set(Hc_pushSTRUCTresult,'Visible','off');

   set(h_pet,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_bfmri,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_fmri,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_erp,'back',[0 0 0],'fore',[1 1 1]);
   set(h_struct,'back',[0.7 0.7 0.7],'fore',[0 0 0]);

   return;


%------------------------------------------------------------------------------------
function ChooseSTRUCT()

   Hc_textPET=findobj(gcf,'Tag','PETLabel');
   Hc_textBfMRI=findobj(gcf,'Tag','BfMRILabel');
   Hc_textfMRI=findobj(gcf,'Tag','fMRILabel');
   Hc_textERP=findobj(gcf,'Tag','ERPLabel');
   Hc_textSTRUCT=findobj(gcf,'Tag','STRUCTLabel');
   Hc_pushPETsession=findobj(gcf,'Tag','PETSessionProfileButton');
   Hc_pushBfMRIsession=findobj(gcf,'Tag','BfMRISessionProfileButton');
   Hc_pushfMRIsession=findobj(gcf,'Tag','SessionProfileButton');
   Hc_pushERPsession=findobj(gcf,'Tag','ERPSessionProfileButton');
   Hc_pushSTRUCTsession=findobj(gcf,'Tag','STRUCTSessionProfileButton');
   Hc_pushPETanalysis=findobj(gcf,'Tag','PETAnalysisButton');
   Hc_pushBfMRIanalysis=findobj(gcf,'Tag','BfMRIAnalysisButton');
   Hc_pushfMRIanalysis=findobj(gcf,'Tag','PLSAnalysisButton');
   Hc_pushERPanalysis=findobj(gcf,'Tag','ERPAnalysisButton');
   Hc_pushSTRUCTanalysis=findobj(gcf,'Tag','STRUCTAnalysisButton');
   Hc_pushPETresult=findobj(gcf,'Tag','PETResultButton');
   Hc_pushBfMRIresult=findobj(gcf,'Tag','BfMRIResultButton');
   Hc_pushfMRIresult=findobj(gcf,'Tag','PLSResultButton');
   Hc_pushERPresult=findobj(gcf,'Tag','ERPResultButton');
   Hc_pushSTRUCTresult=findobj(gcf,'Tag','STRUCTResultButton');
   h_pet = findobj(gcf,'tag','PETButton');
   h_bfmri = findobj(gcf,'tag','BfMRIButton');
   h_fmri = findobj(gcf,'tag','fMRIButton');
   h_erp = findobj(gcf,'tag','ERPButton');
   h_struct = findobj(gcf,'tag','STRUCTButton');

   set(gcf,'Name','PLS for Structural data');
   set(Hc_textPET,'Visible','off');
   set(Hc_textBfMRI,'Visible','off');
   set(Hc_textfMRI,'Visible','off');
   set(Hc_textERP,'Visible','off');
   set(Hc_textSTRUCT,'Visible','on');
   set(Hc_pushPETsession,'Visible','off');
   set(Hc_pushBfMRIsession,'Visible','off');
   set(Hc_pushfMRIsession,'Visible','off');
   set(Hc_pushERPsession,'Visible','off');
   set(Hc_pushSTRUCTsession,'Visible','on');
   set(Hc_pushPETanalysis,'Visible','off');
   set(Hc_pushBfMRIanalysis,'Visible','off');
   set(Hc_pushfMRIanalysis,'Visible','off');
   set(Hc_pushERPanalysis,'Visible','off');
   set(Hc_pushSTRUCTanalysis,'Visible','on');
   set(Hc_pushPETresult,'Visible','off');
   set(Hc_pushBfMRIresult,'Visible','off');
   set(Hc_pushfMRIresult,'Visible','off');
   set(Hc_pushERPresult,'Visible','off');
   set(Hc_pushSTRUCTresult,'Visible','on');

   set(h_pet,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_bfmri,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_fmri,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_erp,'back',[0.7 0.7 0.7],'fore',[0 0 0]);
   set(h_struct,'back',[0 0 0],'fore',[1 1 1]);

   return;


%-----------------------------------------------------------------------------
function toggle_save_setting

   h_save_setting = getappdata(gcf, 'h_save_setting');
   save_setting_status = 'off';

   curr_dir = pwd;
   if isempty(curr_dir)
      curr_dir = filesep;
   end

   try
      load('pls_profile');

      if strcmp(get(h_save_setting, 'check'), 'on')
         save_setting_status = 'off';
         set(h_save_setting, 'check', 'off');
      else
         save_setting_status = 'on';
         set(h_save_setting, 'check', 'on');
      end

      setappdata(gcf, 'save_setting_status', save_setting_status);
      pls_profile = which('pls_profile.mat');
      save(pls_profile,'-append','save_setting_status');
   catch
      msg = {'PLS position profile does not exist, do you want to:'};
      tit = 'PLS position profile';
      response = questdlg(msg,tit,'Create','Open','Cancel','Create');
      switch response
         case 'Create'
            msg = ['Do you want to put it under directory "',curr_dir,'"?'];
            tit = 'Confirm directory';
            response = questdlg(msg,tit,'Yes','No','Yes');

            switch response
               case 'Yes'
                  pls_profile = fullfile(curr_dir,'pls_profile.mat');
                  try
                     save_setting_status = 'on';
                     save(pls_profile, 'save_setting_status');
                    if ~exist('isdeployed','builtin') | ~isdeployed
                     addpath(curr_dir);
                    end
                     set(h_save_setting, 'check', 'on');
                     setappdata(gcf, 'save_setting_status', save_setting_status);
                  catch
                     msg = ['Can not save "pls_profile.mat" under "',curr_dir,'"'];
                     msg = [msg, ', Do you want to try another directory?'];
                     tit = 'Save Error';
                     pls_profile = [];

                     response = questdlg(msg,tit,'Yes','No','Yes');

                     switch response
                        case 'Yes'
                           pls_profile = try_new_dir(curr_dir);
                           if ~isempty(pls_profile)
                              set(h_save_setting, 'check', 'on');
                              save_setting_status = 'on';
                           else
                              set(h_save_setting, 'check', 'off');
                              save_setting_status = 'off';
                           end
                        case 'No'
                           pls_profile = [];
                           save_setting_status = 'off';
                     end
                  end
               case 'No'
                  pls_profile = try_new_dir(curr_dir);
                  if ~isempty(pls_profile)
                     set(h_save_setting, 'check', 'on');
                     save_setting_status = 'on';
                  else
                     set(h_save_setting, 'check', 'off');
                     save_setting_status = 'off';
                  end
            end
         case 'Open'
            [fn, new_dir] = rri_selectfile('pls_profile.mat', ...
		'Open "pls_profile.mat"');

            if new_dir == 0
               pls_profile = [];
               save_setting_status = 'off';
            else
               try
                 if ~exist('isdeployed','builtin') | ~isdeployed
                  addpath(new_dir);
                 end
                  load('pls_profile');
                  pls_profile=which('pls_profile.mat');
                  save(pls_profile, '-append', 'save_setting_status');
                  set(h_save_setting, 'check', 'on');
                  save_setting_status = 'on';
               catch
                  msg = ['Can not save "pls_profile.mat" under ',new_dir];
                  msg = [msg, ', Do you want to try another directory?'];
                  tit = 'Save Error';
                  pls_profile = [];

                  response = questdlg(msg,tit,'Yes','No','Yes');

                  switch response
                     case 'Yes'
                        pls_profile = try_new_dir(new_dir);
                        if ~isempty(pls_profile)
                           set(h_save_setting, 'check', 'on');
                           save_setting_status = 'on';
                        end
                      case 'No'
                        pls_profile = [];
                        save_setting_status = 'off';
                  end
               end
            end
         case 'Cancel'
            pls_profile = [];
            save_setting_status = 'off';
      end
   end

   setappdata(gcf, 'save_setting_status', save_setting_status);
   save(pls_profile, '-append', 'save_setting_status');

   return;					% toggle_save_setting


%-----------------------------------------------------------------------------
function toggle_save_display

   h_save_display = getappdata(gcf, 'h_save_display');
   save_display_status = 'off';

   curr_dir = pwd;
   if isempty(curr_dir)
      curr_dir = filesep;
   end

   try
      load('pls_profile');

      if strcmp(get(h_save_display, 'check'), 'on')
         save_display_status = 'off';
         set(h_save_display, 'check', 'off');
      else
         save_display_status = 'on';
         set(h_save_display, 'check', 'on');
      end

      setappdata(gcf, 'save_display_status', save_display_status);
      pls_profile = which('pls_profile.mat');
      save(pls_profile,'-append','save_display_status');
   catch
      msg = {'PLS position profile does not exist, do you want to:'};
      tit = 'PLS position profile';
      response = questdlg(msg,tit,'Create','Open','Cancel','Create');
      switch response
         case 'Create'
            msg = ['Do you want to put it under directory "',curr_dir,'"?'];
            tit = 'Confirm directory';
            response = questdlg(msg,tit,'Yes','No','Yes');

            switch response
               case 'Yes'
                  pls_profile = fullfile(curr_dir,'pls_profile.mat');
                  try
                     save_display_status = 'on';
                     save(pls_profile, 'save_display_status');
                    if ~exist('isdeployed','builtin') | ~isdeployed
                     addpath(curr_dir);
                    end
                     set(h_save_display, 'check', 'on');
                     setappdata(gcf, 'save_display_status', save_display_status);
                  catch
                     msg = ['Can not save "pls_profile.mat" under "',curr_dir,'"'];
                     msg = [msg, ', Do you want to try another directory?'];
                     tit = 'Save Error';
                     pls_profile = [];

                     response = questdlg(msg,tit,'Yes','No','Yes');

                     switch response
                        case 'Yes'
                           pls_profile = try_new_dir(curr_dir);
                           if ~isempty(pls_profile)
                              set(h_save_display, 'check', 'on');
                              save_display_status = 'on';
                           else
                              set(h_save_display, 'check', 'off');
                              save_display_status = 'off';
                           end
                        case 'No'
                           pls_profile = [];
                           save_display_status = 'off';
                     end
                  end
               case 'No'
                  pls_profile = try_new_dir(curr_dir);
                  if ~isempty(pls_profile)
                     set(h_save_display, 'check', 'on');
                     save_display_status = 'on';
                  else
                     set(h_save_display, 'check', 'off');
                     save_display_status = 'off';
                  end
            end
         case 'Open'
            [fn, new_dir] = rri_selectfile('pls_profile.mat', ...
		'Open "pls_profile.mat"');

            if new_dir == 0
               pls_profile = [];
               save_display_status = 'off';
            else
               try
                 if ~exist('isdeployed','builtin') | ~isdeployed
                  addpath(new_dir);
                 end
                  load('pls_profile');
                  pls_profile=which('pls_profile.mat');
                  save(pls_profile, '-append', 'save_display_status');
                  set(h_save_display, 'check', 'on');
                  save_display_status = 'on';
               catch
                  msg = ['Can not save "pls_profile.mat" under ',new_dir];
                  msg = [msg, ', Do you want to try another directory?'];
                  tit = 'Save Error';
                  pls_profile = [];

                  response = questdlg(msg,tit,'Yes','No','Yes');

                  switch response
                     case 'Yes'
                        pls_profile = try_new_dir(new_dir);
                        if ~isempty(pls_profile)
                           set(h_save_display, 'check', 'on');
                           save_display_status = 'on';
                        end
                      case 'No'
                        pls_profile = [];
                        save_display_status = 'off';
                  end
               end
            end
         case 'Cancel'
            pls_profile = [];
            save_display_status = 'off';
      end
   end

   setappdata(gcf, 'save_display_status', save_display_status);
   save(pls_profile, '-append', 'save_display_status');

   return;					% toggle_save_display


%-----------------------------------------------------------------------------
function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      save_setting_status = getappdata(gcbf,'save_setting_status');
      plsgui_pos = get(gcbf,'position');

      if ~isempty(save_setting_status) & ~isempty(plsgui_pos)
         save(pls_profile,'-append','save_setting_status','plsgui_pos');
      end

   catch
   end

   return;					% delete_fig


%-----------------------------------------------------------------------------
function pls_profile = try_new_dir(old_dir)

   new_dir = rri_getdirectory({old_dir});

   if isempty(new_dir)
      pls_profile = [];
      return;
   end

   pls_profile = fullfile(new_dir,'pls_profile.mat');

   try
      save_setting_status = 'off';
      save_display_status = 'off';
      save(pls_profile, 'save_setting_status', 'save_display_status');
     if ~exist('isdeployed','builtin') | ~isdeployed
      addpath(new_dir);
     end
   catch
      msg = ['Can not save "pls_profile.mat" under "',new_dir,'"'];
      msg = [msg, ', Do you want to try another directory?'];
      tit = 'Save Error';
      pls_profile = [];

      response = questdlg(msg,tit,'Yes','No','Yes');

      switch response
         case 'Yes'
            pls_profile = try_new_dir(new_dir);
         case 'No'
      end
   end

   return;					% try_new_dir

