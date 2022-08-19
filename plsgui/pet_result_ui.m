%PET_RESULT_UI Display the PLS analysis results
%
%   Usage: fig = pet_result_ui(action,varargin)
%
%   see also pet_result_ui
%

%   Called by plsgui
%
%   Modified on 04-OCT-2002 by Jimmy Shen
%   Modified on 17-JUN-2003 by Jimmy Shen, and add 'newcolor'
%   Modified on 24-SEP-2003, save background to img
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fig = pet_result_ui(action,varargin)

   if ~exist('action','var') | isempty(action)

      [PLSresultFile,PLSresultFilePath] =  ...
                        rri_selectfile('*PETresult.mat','Open PET Result');
      if (PLSresultFilePath == 0), return; end;

      cd(PLSresultFilePath);
      PLSResultFile = fullfile(PLSresultFilePath,PLSresultFile);

      if exist('plslog.m','file')
         plslog('Show PET Result');
      end

      try
         warning off;
         load(PLSResultFile, 'datamat_files', 'datamat_files_timestamp', 'singleprecision');
         warning on;
      catch
         msgbox('Can not open file','Error');
         return
      end

      rri_changepath('petresult');

      if 0 % exist('datamat_files_timestamp','var')
         datamat_files_timestamp_old = datamat_files_timestamp;
         change_timestamp = 0;

         for i = 1:length(datamat_files)
            if ~exist(datamat_files{i}, 'file')
               msgbox(['Error: File "', datamat_files{i}, '" is missing']);
               return
            end

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
%               save(PLSResultFile, '-append', 'datamat_files_timestamp');
               my_datamat_files_timestamp = datamat_files_timestamp;
               mystruct = load(PLSResultFile);
               mystr = fieldnames(mystruct);
               mystr = sprintf('%s ',mystr{:});
               mystruct = struct2cell(mystruct);
               eval(['[' mystr ']=deal(mystruct{:});']);
               datamat_files_timestamp = my_datamat_files_timestamp;
               eval(['save ' PLSResultFile ' ' mystr]);
            catch
               uiwait(msgbox('Can not save new timestamp','Error','modal'));
               return;
            end
         end
      end


      v7 = version;
      if exist('singleprecision','var') & singleprecision & str2num(v7(1))<7
         uiwait(msgbox('MATLAB Version 7 (R14) above must be used to show this result file','Error','modal'));
         return;
      end


      msg = 'Loading PLS results for PET data ...    Please wait!';
      h = rri_wait_box(msg,[0.5 0.1]);

      fig_h = init(PLSResultFile);

      setappdata(gcf,'CallingFigure',gcbf);
      set(gcbf,'visible','off','Pointer','arrow');

      rot_amount = load_pls_result;
      pet_result_ui('Rotation', rot_amount);

      if (nargout > 0),
        fig = fig_h;
      end;

      delete(h);

      dims = getappdata(gcf,'STDims');
      origin = getappdata(gcf,'STOrigin');
      if origin(1) < 1, origin(1) = 1; end
      if origin(2) < 1, origin(2) = 1; end
      if origin(3) < 1, origin(3) = 1; end
      if origin(1) > dims(1), origin(1) = dims(1); end
      if origin(2) > dims(2), origin(2) = dims(2); end
      if origin(3) > dims(4), origin(3) = dims(4); end
      h = findobj(gcf,'Tag','XYZVoxel');
      set(h, 'string', num2str(origin));
      h = findobj(gcf,'Tag','MessageLine');
      set(h,'String','');

      EditXYZ;

      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   if (strcmp(action,'PlotBnPress'))
     ShowResult(0,1);                % display brainlv inside the Plot BLV figure
   elseif (strcmp(action,'PlotOnNewFigure'))
     ShowResult(1,0);                % display brainlv in a new figure;
   elseif (strcmp(action,'crosshair'))
     xhair_on_state = get(gcbo,'Userdata');
     img_xhair = getappdata(gcbf,'img_xhair');
     if (xhair_on_state == 1)
        set(gcbo,'Userdata',0,'Label','Crosshair off');
        if ishandle(img_xhair.lx) & ishandle(img_xhair.ly)
           set(img_xhair.lx,'visible','on');
           set(img_xhair.ly,'visible','on');
        end
     else
        set(gcbo,'Userdata',1,'Label','Crosshair on');
        if ishandle(img_xhair.lx) & ishandle(img_xhair.ly)
           set(img_xhair.lx,'visible','off');
           set(img_xhair.ly,'visible','off');
        end
     end;
   elseif (strcmp(action,'set_xhair_color'))
      old_color = get(gcbo,'Userdata');
      new_color = uisetcolor(old_color);
      set(gcbo,'Userdata',new_color);
      img_xhair = getappdata(gcbf,'img_xhair');
      if ishandle(img_xhair.lx) & ishandle(img_xhair.ly)
         set(img_xhair.lx,'color',new_color);
         set(img_xhair.ly,'color',new_color);
      end
   elseif (strcmp(action,'Zooming'))
     zoom_on_state = get(gcbo,'Userdata');
     if (zoom_on_state == 1)
	zoom on;
        set(gcbo,'Userdata',0,'Label','&Zoom off');
        set(gcf,'pointer','crosshair');
     else
	zoom off;
        set(gcbo,'Userdata',1,'Label','&Zoom on');
        set(gcf,'pointer','arrow');
     end;
   elseif (strcmp(action,'ClusterMask'))
     cluster_mask_state = get(gcbo,'Userdata');

     isbsr = getappdata(gcbf,'ViewBootstrapRatio');
     if isbsr
        cluster_info = getappdata(gcbf, 'cluster_bsr');
     else
        cluster_info = getappdata(gcbf, 'cluster_blv');
     end

     curr_lv_idx = getappdata(gcbf,'CurrLVIdx');
     if length(cluster_info) < curr_lv_idx
        cluster_info = [];
     else
        cluster_info = cluster_info{curr_lv_idx};
     end

     if isempty(cluster_info)
        msgbox('Please either Load or Create a cluster report for this scenario');
        return;
     end

     if (cluster_mask_state == 1)
        set(gcbo,'Userdata',0,'check','on');
        ShowResult(0,1);
     else
        set(gcbo,'Userdata',1,'check','off');
        ShowResult(0,1);
     end;
   elseif (strcmp(action,'Toggle_View'))
     DeleteLinkedFigure;
     ToggleView;
     set(findobj(gcbf,'tag','ClusterMask'),'Userdata',1,'check','off');
     ShowResult(0,1);
   elseif (strcmp(action,'Rotation'))
     p_img = getappdata(gcf,'p_img');
     if ~isempty(p_img)
        p_img = [-1 -1];
        setappdata(gcf,'p_img',p_img);
     end
     setappdata(gcf,'img_xhair',[]);

     rot_amount = varargin{1};
     setappdata(gcf,'RotateAmount',rot_amount);
     switch mod(rot_amount,4)
        case {0},					% 0 degree
           h = findobj(gcf,'Tag','Rotate0Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate90Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate180Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate270Menu');
           set(h,'Checked','on');
        case {1},					% 90 degree by default
           h = findobj(gcf,'Tag','Rotate0Menu');
           set(h,'Checked','on');
           h = findobj(gcf,'Tag','Rotate90Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate180Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate270Menu');
           set(h,'Checked','off');
        case {2},					% 180 degree
           h = findobj(gcf,'Tag','Rotate0Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate90Menu');
           set(h,'Checked','on');
           h = findobj(gcf,'Tag','Rotate180Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate270Menu');
           set(h,'Checked','off');
        case {3},					% 270 degree
           h = findobj(gcf,'Tag','Rotate0Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate90Menu');
           set(h,'Checked','off');
           h = findobj(gcf,'Tag','Rotate180Menu');
           set(h,'Checked','on');
           h = findobj(gcf,'Tag','Rotate270Menu');
           set(h,'Checked','off');
     end;

     ShowResult(0,0);
     EditXYZ;
   elseif (strcmp(action,'EditLV'))
     EditLV;
     set(findobj(gcbf,'tag','ClusterMask'),'Userdata',1,'check','off');
     ShowResult(0,1);
   elseif (strcmp(action,'UpdatePValue'))
     UpdatePValue;
     set(findobj(gcbf,'tag','ClusterMask'),'Userdata',1,'check','off');
     isbsr = getappdata(gcbf,'ViewBootstrapRatio');
     if isappdata(gcbf,'cluster_blv') & ~isbsr
        rmappdata(gcbf,'cluster_blv');
     end
     if isappdata(gcbf,'cluster_bsr') & isbsr
        rmappdata(gcbf,'cluster_bsr');
     end
     ShowResult(0,1);
   elseif (strcmp(action,'EditThresh'))
     set(findobj(gcbf,'tag','ClusterMask'),'Userdata',1,'check','off');
     isbsr = getappdata(gcbf,'ViewBootstrapRatio');
     if isappdata(gcbf,'cluster_blv') & ~isbsr
        rmappdata(gcbf,'cluster_blv');
     end
     if isappdata(gcbf,'cluster_bsr') & isbsr
        rmappdata(gcbf,'cluster_bsr');
     end
     ShowResult(0,1);
   elseif (strcmp(action,'EditMin'))
     isbsr = getappdata(gcbf,'ViewBootstrapRatio');
     lv = getappdata(gcbf,'CurrLVIdx');
     if isbsr
        data = getappdata(gcbf,'BSRatio');
        thresh2 = getappdata(gcbf,'BSThreshold2');
        setting = getappdata(gcbf,'setting');
        old_data = setting.min_ratio;
     else
        data = getappdata(gcbf,'BLVData');
        thresh2 = getappdata(gcbf,'BLVThreshold2');
        setting = getappdata(gcbf,'setting');
        old_data = setting.min_blv;
     end
     if str2num(get(gco,'string')) < min(data(:,lv)) | str2num(get(gco,'string')) > thresh2
        msg = ['Valid number should be within [' num2str([min(data(:,lv)) thresh2]) ']'];
        set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
        set(gco,'string',num2str(old_data{lv}));
        return;
     end

     set(findobj(gcbf,'tag','ClusterMask'),'Userdata',1,'check','off');
     if isappdata(gcbf,'cluster_blv') & ~isbsr
        rmappdata(gcbf,'cluster_blv');
     end
     if isappdata(gcbf,'cluster_bsr') & isbsr
        rmappdata(gcbf,'cluster_bsr');
     end
     ShowResult(0,1);
   elseif (strcmp(action,'EditMax'))
     isbsr = getappdata(gcbf,'ViewBootstrapRatio');
     lv = getappdata(gcbf,'CurrLVIdx');
     if isbsr
        data = getappdata(gcbf,'BSRatio');
        thresh = getappdata(gcbf,'BSThreshold');
        setting = getappdata(gcbf,'setting');
        old_data = setting.max_ratio;
     else
        data = getappdata(gcbf,'BLVData');
        thresh = getappdata(gcbf,'BLVThreshold');
        setting = getappdata(gcbf,'setting');
        old_data = setting.max_blv;
     end
     if str2num(get(gco,'string')) > max(data(:,lv)) | str2num(get(gco,'string')) < thresh
        msg = ['Valid number should be within [' num2str([thresh max(data(:,lv))]) ']'];
        set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
        set(gco,'string',num2str(old_data{lv}));
        return;
     end

     set(findobj(gcbf,'tag','ClusterMask'),'Userdata',1,'check','off');
     if isappdata(gcbf,'cluster_blv') & ~isbsr
        rmappdata(gcbf,'cluster_blv');
     end
     if isappdata(gcbf,'cluster_bsr') & isbsr
        rmappdata(gcbf,'cluster_bsr');
     end
     ShowResult(0,1);
   elseif (strcmp(action,'SelectPixel'))
     SelectPixel;
   elseif (strcmp(action,'ResizeFigure'))
     ResizeFigure(varargin{1},varargin{2});
   elseif (strcmp(action,'DeleteNewFigure'))
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         pet_result_newfig_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'pet_result_newfig_pos');
      catch
      end
   elseif (strcmp(action,'DeleteFigure'))
     try
        load('pls_profile');
        pls_profile = which('pls_profile.mat');

        pet_result_pos = get(gcbf,'position');

        save(pls_profile, '-append', 'pet_result_pos');
     catch
     end

     old_setting = getappdata(gcbf,'old_setting');
     setting = getappdata(gcbf,'setting');


     save_display_status = 'off';
     try
        load('pls_profile');
     catch 
     end
     if strcmpi(save_display_status, 'off')
        setting = [];
     end


     if ~isequal(setting, old_setting) & strcmpi(save_display_status, 'on')
%        save_setting = ...
%           questdlg('Would you like to save the display setting?', ...
%			'Save current fields', 'yes', 'no', 'yes');
        if 1	% strcmp(save_setting, 'yes')
           try
%              PLSresultFile = get(findobj(gcbf,'Tag','ResultFile'),'UserData');
 %             setting1 = setting;
  %            save(PLSresultFile, '-append', 'setting1');
           catch
              msg = 'Cannot save setting information';
              msgbox(msg,'ERROR','modal');
           end
        end
     end

     DeleteLinkedFigure;
     calling_fig = getappdata(gcf,'CallingFigure');
     set(calling_fig,'visible','on');
   elseif (strcmp(action,'OpenBrainPlot'))
     OpenBrainPlot;
   elseif (strcmp(action,'OpenResponseFnPlot'))
     OpenResponseFnPlot;
   elseif (strcmp(action,'OpenCorrelationPlot'))
     OpenCorrelationPlot;
   elseif (strcmp(action,'OpenDatamatcorrsPlot'))
     OpenDatamatcorrsPlot;
   elseif (strcmp(action,'OpenScoresPlot'))
     OpenScoresPlot(varargin{1});
   elseif (strcmp(action,'OpenBrainScoresPlot'))
     OpenBrainScoresPlot;
   elseif (strcmp(action,'OpenEigenPlot'))
     OpenEigenPlot;
   elseif (strcmp(action,'OpenContrastWindow'))
     OpenContrastWindow;
   elseif (strcmp(action,'SetClusterReportOptions'))
     SetClusterReportOptions;
   elseif (strcmp(action,'LoadClusterReport'))
     cluster_hdl = getappdata(gcbf,'cluster_hdl');
     if ~isempty(cluster_hdl)
        msg = 'Please close any opening cluster report window';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        return;
     end;

     [tmp cluster_hdl] = pet_cluster_report('LoadClusterReport',gcbf);

     if ishandle(cluster_hdl)
        link_info.hdl = gcbf;
        link_info.name = 'cluster_hdl';
        setappdata(cluster_hdl,'LinkFigureInfo',link_info);
        setappdata(gcbf,'cluster_hdl',cluster_hdl);
     end
   elseif (strcmp(action,'OpenClusterReport'))
     OpenClusterReport;
   elseif (strcmp(action,'MENU_TogglePermResult'))
     TogglePermResultDisplay;
   elseif (strcmp(action,'LoadBackgroundImage'))
     LoadBackgroundImage;
   elseif (strcmp(action,'SaveBackgroundImage'))
     SaveBackgroundImage;
   elseif (strcmp(action,'LoadTemplateFile'))
     LoadTemplateFile;
   elseif (strcmp(action,'LoadResultFile'))
     LoadResultFile;
   elseif (strcmp(action,'SaveResultToIMG'))
     SaveResultToIMG(0);
   elseif (strcmp(action,'SaveDisplayToIMG'))
     SaveResultToIMG(1);
   elseif (strcmp(action,'DisplayIMG'))
     DisplayIMG;
   elseif (strcmp(action,'RescaleBnPress'))
     RescaleBnPress;
     ShowResult(0,1);
   elseif (strcmp(action,'MultipleVoxel'))
      MultipleVoxel;
   elseif (strcmp(action,'MultipleCorrs'))
      MultipleCorrs;
   elseif (strcmp(action,'PlotSagittalView'))
      PLSresultFile = get(findobj(gcf,'Tag','ResultFile'),'UserData');
      DeleteLinkedFigure;
      pet_result_sa_ui({PLSresultFile,1})
   elseif (strcmp(action,'PlotCoronalView'))
      PLSresultFile = get(findobj(gcf,'Tag','ResultFile'),'UserData');
      DeleteLinkedFigure;
      pet_result_sa_ui({PLSresultFile,0})
   elseif (strcmp(action,'Plot3View'))
      PLSresultFile = get(findobj(gcf,'Tag','ResultFile'),'UserData');
      DeleteLinkedFigure;
      pet_result_3v_ui({PLSresultFile,0})
   elseif (strcmp(action,'EditXYZ'))
      EditXYZ;
   elseif (strcmp(action,'EditXYZmm'))
      EditXYZmm;
   elseif (strcmp(action,'orient'))
      orient;
   elseif (strcmp(action,'XYZmmLabel'))
      XYZmmLabel;
   end;

   return;


%---------------------------------------------------------------------------
%
function h0 = init(PLSResultFile);

   setting1 = [];
   warning off;
   load(PLSResultFile, 'setting1');
   setting = setting1;
   warning on;


   save_display_status = 'off';
   try
      load('pls_profile');
   catch 
   end
   if strcmpi(save_display_status, 'off')
      setting = [];
   end


   save_setting_status = 'on';
   pet_result_pos = [];

   try
      load('pls_profile');
   catch 
   end

   if ~isempty(pet_result_pos) & strcmp(save_setting_status,'on')

      pos = pet_result_pos;

   else

      fig_w = 0.85;
      fig_h = 0.8;
      fig_x = (1 - fig_w)/2;
      fig_y = (1 - fig_h)/2;

      pos = [fig_x fig_y fig_w fig_h];

   end

   [r_path,r_file,r_ext] = fileparts(PLSResultFile);

   h0 = figure('Units','normal', ...
   	'Color',[0.8 0.8 0.8], ...
        'NumberTitle','off', ...
   	'DoubleBuffer','on', ...
   	'MenuBar','none',...
   	'Position',pos, ...
   	'DeleteFcn','pet_result_ui(''DeleteFigure'')', ...
   	'Tag','PlotBrainLV');

   if exist('isdeployed','builtin') & isdeployed
      set(h0,'Renderer','painters');
   end

   %

   x = .37;
   y = .1;
   w = .5;				% newcolor: was w = .5 + .08;
   h = .85;

   pos = [x y w h];

   axes_h = axes('Parent',h0, ...			% image axes
        'Units','normal', ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',[1 1 1], ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','BlvAxes');

   x = x+w+.02;				% newcolor: colorbar_h was commented
   w = .04;

   pos = [x y w h];

   colorbar_h = axes('Parent',h0, ...			% color axes
        'Units','normal', ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','Colorbar');
   %

   x = .03;
   y = .95;
   w = .09;
   h = .04;

   pos = [x y w h];

   fnt = 0.6;

   h1 = uicontrol('Parent',h0, ...			% result label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Result File:', ...
   	'Style','text', ...
   	'Tag','ResultFileLabel');

   x = x+w;
   w = .22;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% result text
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String',r_file, ...
   	'Style','text', ...
        'UserData', PLSResultFile, ...
   	'Tag','ResultFile');

   x = .05;
   y = y-h-.03;
   w = .08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv index label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','LV Index:', ...
   	'Style','text', ...
   	'Tag','LVIndexLabel');

   x = x+w;
   y = y+.01;
   w = .05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv index edit
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''EditLV'')', ...
   	'Tag','LVIndexEdit');

   x = x+w;
   y = y-.01;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv number label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','of', ...
   	'Style','text', ...
   	'Tag','LVNumberLabel');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv number text
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','LVNumberEdit');

   %  Brain LV

   x = .03;
   y = .52;
   w = .26;
   h = .34;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Brain LV frame
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','ThresholdFrame');

   x = .11;
   y = .83;
   w = .09;
   h = .04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Brain LV title
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Brain LV', ...
   	'Style','text', ...
   	'Tag','BLVTitle');

   x = .05;
   y = .78;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% threshold label
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Pos.Thresh:', ...
   	'Style','text', ...
   	'Tag','ThresholdLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% threshold edit
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''EditThresh'')', ...
   	'Tag','Threshold');

   x = .05;
   y = .74;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Neg.Thresh:', ...
   	'Style','text', ...
   	'Tag','ThresholdLabel2');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''EditThresh'')', ...
   	'Tag','Threshold2');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   % reserved label

   x = x+w;
   w = .1;

   pos = [x y w h];

   % reserved value

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   x = .05;
   y = y-h-.01;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Curr. Value label
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Curr. Value:', ...
   	'Style','text', ...
   	'Tag','BLVValueLabel');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Curr. Value text
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
   	'Style','text', ...
   	'Tag','BLVValue');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% min value label
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Max. Value:', ...
   	'Style','text', ...
   	'Tag','MaxValueLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% max value edit
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''EditMax'')', ...
   	'Tag','MaxValue');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% max value label
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Min. Value:', ...
   	'Style','text', ...
   	'Tag','MinValueLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% min value edit
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''EditMin'')', ...
   	'Tag','MinValue');

   %

   x = .09;
   y = .83;
   w = .15;
   h = .04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Bootstrap Ratio title
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Bootstrap Ratio', ...
   	'Style','text', ...
   	'Tag','BSRatioTitle');

   x = .05;
   y = .78;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Pos.Thresh:', ...
	'Tooltip','Default set to 95 percentile of Bootstrap ratio', ...
   	'Style','text', ...
   	'Tag','BSThresholdLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
	'Tooltip','Default set to 95 percentile of Bootstrap ratio', ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''UpdatePValue'')', ...
   	'Tag','BSThreshold');

   x = .05;
   y = .74;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Neg.Thresh:', ...
	'Tooltip','Default set to 95 percentile of Bootstrap ratio', ...
   	'Style','text', ...
   	'Tag','BSThresholdLabel2');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
	'Tooltip','Default set to 95 percentile of Bootstrap ratio', ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''UpdatePValue'')', ...
   	'Tag','BSThreshold2');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','approx. P Value:', ...
	'Tooltip','Always calculated from standard normal distribution', ...
   	'Style','text', ...
   	'Tag','PValueLabel');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
	'Tooltip','Always calculated from standard normal distribution', ...
   	'Style','text', ...
   	'Tag','PValue');

   x = .05;
   y = y-h-.01;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Curr. Ratio:', ...
   	'Style','text', ...
   	'Tag','BSValueLabel');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
   	'Style','text', ...
   	'Tag','BSValue');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Max. Ratio:', ...
   	'Style','text', ...
   	'Tag','MaxRatioLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''EditMax'')', ...
   	'Tag','MaxRatio');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Min. Ratio:', ...
   	'Style','text', ...
   	'Tag','MinRatioLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','off', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''EditMin'')', ...
   	'Tag','MinRatio');

   %  Voxel Location

   x = .03;
   y = .38;
   w = .26;
   h = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Voxel location frame
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','LocationFrame');

   x = .04;
   y = .44;
   w = .08;
   h = .04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Voxel coord. label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','XYZ:', ...
	'ToolTipString','Absolute coxel coordinates', ...
   	'Style','text', ...
   	'Tag','XYZVoxelLabel');

   x = x+w+0.01;
   y = y+.01;
   w = .04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','go', ...
	'ToolTipString','Click to select the XYZ you entered', ...
   	'Style','push', ...
   	'Callback','pet_result_ui(''EditXYZ'')');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Voxel coord. text
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
	'ToolTipString','Absolute voxel coordinates', ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''EditXYZ'')', ...
   	'Tag','XYZVoxel');

   x = .04;
   y = y-h-0.02;
   w = .08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Origin label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','XYZ(mm):', ...
	'ToolTipString','Voxel coordinates w.r.t. the origin', ...
   	'Style','text', ...
        'user', 1, ...
   	'Tag','XYZmmLabel');

%   	'BackgroundColor',[1 1 1], ...
%   	'String',{'MNI','Talairach'}, ...
%   	'Style','popupmenu', ...
%   	'Callback','pet_result_ui(''XYZmmLabel'')', ...

   x = x+w+0.01;
   w = .14;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Origin text
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','', ...
	'ToolTipString','Voxel coordinates w.r.t. the origin', ...
   	'Style','edit', ...
   	'Callback','pet_result_ui(''EditXYZmm'')', ...
   	'Tag','XYZmm');

   x = .05;
   y = .32;
   w = .22;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% rescale button
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
        'HorizontalAlignment', 'left', ...
   	'String','Scale by Singular Value', ...
	'Style','check', ...
	'Value',1, ...
	'Visible','off', ...
	'Callback','pet_result_ui(''RescaleBnPress'')', ...
   	'Tag','RESCALECheckbox');

%        'HorizontalAlignment', 'center', ...

%   h1 = uicontrol('Parent',h0, ...			% plot button
%   	'Units','pixels', ...
%   	'Callback','pet_result_ui(''PlotBnPress'')', ...
%   	'FontSize',10, ...
%   	'ListboxTop',0, ...
%   	'Position',[28 40 67 28], ...
%   	'String','PLOT', ...
%   	'Tag','PLOTButton');

   x = .1;
   y = .1;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% close button
   	'Units','normal', ...
   	'Callback','close(gcf)', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','CLOSE', ...
   	'Tag','CLOSEButton');

   x = 0.01;
   y = 0;
   w = .5;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Message Line
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ForegroundColor',[0.8 0.0 0.0], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Tag','MessageLine');


   %  File submenu
   %
   h_file = uimenu('Parent',h0, ...
   	   'Label','&File', ...
   	   'Tag','FileMenu', ...
   	   'Visible','on');

   % newcolor: just made invisible
   %
   h2 = uimenu(h_file, ...
           'Label','&Load Background Template File', ...
   	   'Tag','LoadTemplateFile', ...
		'visible','off', ...
           'Callback','pet_result_ui(''LoadTemplateFile'')');

   h2 = uimenu(h_file, ...
           'Label','&Load Background Image', ...
           'Tag','LoadBGImage', ...
           'Callback','pet_result_ui(''LoadBackgroundImage'')');
   h2 = uimenu(h_file, ...
           'Label','Save brain region to IMG file', ...
   	   'Tag','SaveBGImage', ...
           'Callback','pet_result_ui(''SaveBackgroundImage'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Load PLS Result', ...
   	   'Tag','LoadPETResult', ...
		'visible', 'off', ...
           'Callback','pet_result_ui(''LoadResultFile'')');
   h2 = uimenu(h_file, ...
           'Label','&Save Current Display to the IMG files', ...
   	   'Tag','SaveDisplayToIMG', ...
           'Callback','pet_result_ui(''SaveDisplayToIMG'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Save BLV to the IMG files', ...
   	   'Tag','SaveResultToIMG', ...
           'Callback','pet_result_ui(''SaveResultToIMG'')');

   rri_file_menu(h0, 0);

   h2 = uimenu(h_file, ...
           'Label','&Close', ...
           'separator', 'on', ...
   	   'Tag','CloseFigure', ...
   	   'Callback','close(gcbf)');

   % Xhair submenu
   %
   h_xhair = uimenu('Parent',h0, 'Label','Crosshair');
   h2 = uimenu('Parent',h_xhair, ...
   	   'Label','Crosshair off', ...
	   'Userdata', 0, ...
           'Callback','pet_result_ui(''crosshair'')', ...
   	   'Tag','XhairToggleMenu');
   h2 = uimenu('Parent',h_xhair, ...
   	   'Label','Color ...', ...
	   'Userdata', [1 0 0], ...
           'Callback','pet_result_ui(''set_xhair_color'')', ...
   	   'Tag','XhairColorMenu');

   % Zoom submenu
   %
   h2 = uimenu('Parent',h0, ...
   	   'Label','&Zoom on', ...
	   'Userdata', 1, ...
           'Callback','pet_result_ui(''Zooming'')', ...
   	   'Tag','ZoomToggleMenu');

   % Rotate submenu
   %
   h_rot = uimenu('Parent',h0, ...
   	   'Label','&Image Rotation', ...
   	   'Tag','RotationMenu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&none', ...			% rotate 90 by default
   	   'Checked','on', ...
           'Callback','pet_result_ui(''Rotation'',1)', ...
   	   'Tag','Rotate0Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&90 degree', ...		% another 90 degree
   	   'Checked','off', ...
           'Callback','pet_result_ui(''Rotation'',2)', ...
   	   'Tag','Rotate90Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&180 degree', ...		% now become 270 degree
   	   'Checked','off', ...
           'Callback','pet_result_ui(''Rotation'',3)', ...
   	   'Tag','Rotate180Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&270 degree', ...		% now completed 360 degree
   	   'Checked','off', ...
           'Callback','pet_result_ui(''Rotation'',0)', ...
   	   'Tag','Rotate270Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','Convert Orientation', ...
	   'separator', 'on', ...
           'Callback','pet_result_ui(''orient'',0)', ...
		'visible', 'off', ...
   	   'Tag','orient');

   %  View submenu
   %
   h_view = uimenu('Parent',h0, ...
   	   'Label','&View', ...
   	   'Tag','ViewMenu', ...
   	   'Visible','on');
   h2 = uimenu('Parent',h_view, ...
   	   'Label','&View Brain LV', ...
	   'Userdata', 1, ...
           'Callback','pet_result_ui(''Toggle_View'')', ...
   	   'Tag','ViewToggleMenu');

   %  Window submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Windows', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','on');
   h2 = uimenu(h_pls, ...
           'Label','&Singular Values Plot', ...
     	   'Tag','OpenEigenPlot', ...
           'Callback','pet_result_ui(''OpenEigenPlot'')');
   h2 = uimenu(h_pls, ...
           'Label','&Behavior LV and Behavior Scores Plot', ...
	   'Visible','off', ...
     	   'Tag','OpenBehavPlot', ...
           'Callback','pet_result_ui(''OpenScoresPlot'',0)');
   h2 = uimenu(h_pls, ...
           'Label','&Design LV and Design Scores Plot', ...
	   'Visible','off', ...
     	   'Tag','OpenDesignPlot', ...
           'Callback','pet_result_ui(''OpenScoresPlot'',1)');
   h2 = uimenu(h_pls, ...
           'Label','Task PLS Brain Scores with CI', ...
	   'Visible','off', ...
     	   'Tag','OpenBrainScoresPlot', ...
           'Callback','pet_result_ui(''OpenBrainScoresPlot'')');
   h2 = uimenu(h_pls, ...
           'Label','B&rain Scores vs. Behavior Data Plot', ...
     	   'Tag','OpenBrainPlot', ...
           'Callback','pet_result_ui(''OpenBrainPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Voxel Intensity Response', ...
     	   'Tag','OpenRFPlot', ...
           'Callback','pet_result_ui(''OpenResponseFnPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Datamat Correlations Response', ...
     	   'Tag','OpenRF1Plot', ...
           'Callback','pet_result_ui(''OpenCorrelationPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Datamat Correlations Plot', ...
     	   'Tag','OpenDatamatcorrsPlot', ...
           'Callback','pet_result_ui(''OpenDatamatcorrsPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Multiple Voxels Extraction', ...
     	   'Tag','MultipleVoxel', ...
           'Callback','pet_result_ui(''MultipleVoxel'')');
   h2 = uimenu(h_pls, ...
           'Label','&Multiple Corrs Extraction', ...
     	   'Tag','MultipleCorrs', ...
           'Callback','pet_result_ui(''MultipleCorrs'')');
   h2 = uimenu(h_pls, ...
           'Label','&Contrasts Information', ...
     	   'Tag','OpenContrastWindow', ...
           'Callback','pet_result_ui(''OpenContrastWindow'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Create Brain LV &Figure', ...
	   'separator', 'on', ...
   	   'Tag','PlotNewFigure', ...
           'Callback','pet_result_ui(''PlotOnNewFigure'')');
   h2 = uimenu('Parent',h_pls, ...
           'Label','Sagittal View Plot', ...
	   'separator', 'on', ...
   	   'Tag','PlotSagittalView', ...
           'Callback','pet_result_ui(''PlotSagittalView'')'); 
   h2 = uimenu('Parent',h_pls, ...
           'Label','Coronal View Plot', ...
   	   'Tag','PlotCoronalView', ...
           'Callback','pet_result_ui(''PlotCoronalView'')'); 
   h2 = uimenu('Parent',h_pls, ...
           'Label','3 Cardinal Plane View', ...
   	   'Tag','Plot3View', ...
           'Callback','pet_result_ui(''Plot3View'')'); 

   %  Report submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Report', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','on');
   h2 = uimenu(h_pls, ...
           'Label','&Set Cluster Report Options', ...
     	   'Tag','SetClusterReportOptions', ...
           'Callback','pet_result_ui(''SetClusterReportOptions'')');
   h2 = uimenu(h_pls, ...
           'Label','&Load Cluster Report', ...
     	   'Tag','LoadClsuterReport', ...
           'Callback','pet_result_ui(''LoadClusterReport'')');
   h2 = uimenu(h_pls, ...
           'Label','&Create Cluster Report', ...
     	   'Tag','OpenClusterReport', ...
           'Callback','pet_result_ui(''OpenClusterReport'')');
   h2 = uimenu(h_pls, ...
           'Label','Cluster Mask', ...
	   'separator', 'on', ...
           'check', 'off', ...
	   'Userdata', 1, ...
   	   'Tag','ClusterMask', ...
           'Callback','pet_result_ui(''ClusterMask'')'); 

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
           'Tag', 'Help');

%           'Callback','rri_helpfile_ui(''pet_result_hlp.txt'',''How to use PLS RESULT'');', ...
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','web([''file:///'', which(''UserGuide.htm''), ''#_Toc128820725'']);', ...
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

   set(gcf,'Name',sprintf('PET PLS Result: %s',PLSResultFile));
%   set(colorbar_h,'units','pixels');

   setappdata(gcf,'Colorbar',colorbar_h);		% newcolor: was commented
   setappdata(gcf,'BlvAxes',axes_h);

   setappdata(gcf,'ClusterMaskSize',4);
   setappdata(gcf,'ClusterMinSize',5);
   setappdata(gcf,'ClusterMinDist',10);
   setappdata(gcf,'template_file', []);
   setappdata(gcf,'img_xhair',[]);

   if isempty(setting) | ~isfield(setting,'rescale')
      set(findobj(gcf,'Tag','RESCALECheckbox'),'value',1);
   else
      set(findobj(gcf,'Tag','RESCALECheckbox'),'value',setting.rescale);
   end;

   setappdata(gcf,'setting',setting);
   setappdata(gcf,'old_setting',setting);
   setappdata(gcf,'actualHRF',1);

   return;						% init


%---------------------------------------------------------------------------
%
function ResizeFigure(fig_w,fig_h)

   fig_pos = get(gcbf,'Position');

   fig_width = fig_pos(3);
   fig_height = fig_pos(4);

   if (fig_width < fig_w),
      fig_pos(3) = fig_w;
      set(gcbf,'Position',fig_pos);
   end;

   if (fig_height < fig_h),
      fig_pos(2) = fig_pos(2)+fig_pos(4) - fig_h;	% temp solution for linux
      fig_pos(4) = fig_h;
      set(gcbf,'Position',fig_pos);
   end;

   h = getappdata(gcbf,'BlvAxes');
   set(h,'Units','pixels');
   axes_pos = get(h,'Position');
%   x_margin = 90; y_margin = 25;
   x_margin = 40; y_margin = 25;

   if fig_w == 440, x_margin = 25; end;

   axes_pos(3) = fig_pos(3) - axes_pos(1) - x_margin;
   axes_pos(4) = fig_pos(4) - axes_pos(2) - y_margin;
   set(h,'Position',axes_pos);
   set(h,'Units','pixels');

   if fig_w == 440, return; end;

%   h = getappdata(gcbf,'Colorbar');
%   set(h,'Units','pixels');
%   colorbar_pos = get(h,'Position');
%   x_margin = 80; y_margin = 25;
%   colorbar_pos(1) = fig_pos(3) - x_margin;
%   colorbar_pos(4) = fig_pos(4) - colorbar_pos(2) - y_margin;
%   set(h,'Position',colorbar_pos);
%   set(h,'Units','pixels');

   %  set all other objects' locations
   %
   if ~isequal(get(gcbf,'Userdata'),'Clone')
      SetObjPosition;
   end;

   return;						% ResizeFigure


%---------------------------------------------------------------------------
%
function DeleteLinkedFigure()

   brain_plot = getappdata(gcf,'brain_plot');
   if ~isempty(brain_plot) & ishandle(brain_plot)
     delete(brain_plot);
   end;

   rf_plot = getappdata(gcbf,'RFPlotHdl');
   if ~isempty(rf_plot) & ishandle(rf_plot)
     delete(rf_plot);
   end;

   rf1_plot = getappdata(gcbf,'RF1PlotHdl');
   if ~isempty(rf1_plot) & ishandle(rf1_plot)
     delete(rf1_plot);
   end;

   bscores_fig = getappdata(gcbf,'BSPlotHdl');
   if ~isempty(bscores_fig) & ishandle(bscores_fig)
     delete(bscores_fig);
   end;

   eigen_fig = getappdata(gcbf,'EigenPlotHdl');
   if ~isempty(eigen_fig) & ishandle(eigen_fig)
     delete(eigen_fig);
   end;

   score_fig = getappdata(gcbf,'ScorePlotHdl');
   if ~isempty(score_fig) & ishandle(score_fig)
     delete(score_fig);
   end;

   taskpls_fig = getappdata(gcbf,'taskplsHdl');
   if ~isempty(taskpls_fig) & ishandle(taskpls_fig)
     delete(taskpls_fig);
   end;

   datamatcorrs_fig = getappdata(gcbf,'DatamatcorrsPlotHdl');
   if ~isempty(datamatcorrs_fig) & ishandle(datamatcorrs_fig)
     delete(datamatcorrs_fig);
   end;

   brain_fig = getappdata(gcbf,'brain_plot');
   if ~isempty(brain_fig) & ishandle(brain_fig)
     delete(brain_fig);
   end;

   contrast_fig = getappdata(gcbf,'ContrastFigHdl');
   if ~isempty(contrast_fig) & ishandle(contrast_fig)
     delete(contrast_fig);
   end;

   cluster_hdl = getappdata(gcbf,'cluster_hdl');
   if ~isempty(cluster_hdl) & ishandle(cluster_hdl)
     delete(cluster_hdl);
   end;
   
   return;						% DeleteLinkedFigure


%---------------------------------------------------------------------------
%
function SetObjPosition(ObjName)

   f_pos = get(gcf,'Position');
   obj = getappdata(gcf,'ObjPosition');

   % set the positions for all objects
   %
   if ~exist('ObjName','var') | isempty(ObjName)
      for i=1:length(obj),
         obj_pos = obj(i).pos;
         obj_pos(2) = f_pos(4) - obj_pos(2);
	 set(findobj(gcf,'Tag',obj(i).name),'Position',obj_pos);
      end;
      return;
   end;

   % set the position for a specfic object
   %
   i = 1;
   while i < length(obj),
      if strcmp(ObjName,obj(i).name)
	 obj_pos = obj(i).pos;
         obj_pos(2) = f_pos(4) - obj_pos(2);
	 set(findobj(gcf,'Tag',obj(i).name),'Position',obj_pos);
         return;
      end;
      i = i + 1;
   end;

   return;						% SetObjPosition


%---------------------------------------------------------------------------
%
function CreateObjPosRecord()
%
%   set object location, notice that the y value is counted from the top
%   of the figure, instead of bottom as default
%

   obj(1).name   = 'ResultFileLabel';    obj(1).pos =  [19  40  70  16];
   obj(2).name   = 'ResultFile';         obj(2).pos =  [90  40  144 16];
   obj(3).name   = 'LVIndexLabel';       obj(3).pos =  [19  75  55  19];
   obj(4).name   = 'LVIndexEdit';        obj(4).pos =  [77  75  38  23];
   obj(5).name   = 'LVNumberLabel';      obj(5).pos =  [125 75  20  19];
   obj(6).name   = 'LVNumberEdit';       obj(6).pos =  [145 75  38  19];

   obj(7).name   = 'SliceFrame';         obj(7).pos =  [19  184 172 95];
   obj(8).name   = 'FirstSliceLabel';    obj(8).pos =  [40  133 67  19];
   obj(9).name   = 'FirstSlice';         obj(9).pos =  [115 133 57  22];

   obj(10).name  = 'LastSliceLabel';     obj(10).pos = [38  163 67  19];
   obj(11).name  = 'LastSlice';          obj(11).pos = [115 163 57  22];

   obj(12).name  = 'ThresholdFrame';     obj(12).pos = [19  325-111 172 125];
   obj(13).name  = 'BLVTitle';     	 obj(13).pos = [75  213-111 58  19];
   obj(14).name  = 'BLVValueLabel';      obj(14).pos = [28  240-111 76  19];
   obj(15).name  = 'BLVValue';           obj(15).pos = [110 240-111 67  19];
   obj(16).name  = 'ThresholdLabel';     obj(16).pos = [28  265-111 76  19];
   obj(17).name  = 'Threshold';          obj(17).pos = [110 265-111 67  22];
   obj(18).name  = 'MinValueLabel';      obj(18).pos = [28  290-111 76  19];
   obj(19).name  = 'MinValue';           obj(19).pos = [110 290-111 67  22];
   obj(20).name  = 'MaxValueLabel';      obj(20).pos = [28  315-111 76  19];
   obj(21).name  = 'MaxValue';           obj(21).pos = [110 315-111 67  22];

   obj(22).name  = 'BSRatioTitle';     	 obj(22).pos = [60  213-111 90  19];
   obj(23).name  = 'PValueLabel';        obj(23).pos = [30  240-111 105  19];
   obj(24).name  = 'PValue';             obj(24).pos = [132 240-111 56  19];
   obj(25).name  = 'BSThresholdLabel';   obj(25).pos = [28  260-111 76  19];
   obj(26).name  = 'BSThreshold';        obj(26).pos = [110 260-111 67  22];
   obj(27).name  = 'MinRatioLabel';      obj(27).pos = [28  290-111 76  19];
   obj(28).name  = 'MinRatio';           obj(28).pos = [110 290-111 67  22];
   obj(29).name  = 'MaxRatioLabel';      obj(29).pos = [28  315-111 76  19];
   obj(30).name  = 'MaxRatio';           obj(30).pos = [110 315-111 67  22];

   obj(31).name  = 'LocationFrame';      obj(31).pos = [19  420-111 172 85];
   obj(32).name  = 'XYZVoxelLabel';      obj(32).pos = [35  365-111  50 19];
   obj(33).name  = 'XYZVoxel';           obj(33).pos = [75  365-111 105 19];
   obj(34).name  = 'XYZmmLabel';         obj(34).pos = [35  390-111  70 19];
   obj(35).name  = 'XYZmm';              obj(35).pos = [35  408-111 145 19];

   obj(36).name  = 'RESCALECheckbox';    obj(36).pos = [19 347 172 28];
%   obj(37).name  = 'PLOTButton';         obj(37).pos = [50 410 110 40];
   obj(37).name  = 'CLOSEButton';        obj(37).pos = [19 460 172 40];
%   obj(38).name  = 'CLOSEButton';        obj(38).pos = [50 460 110 40];
%   obj(38).name  = 'CLOSEButton';        obj(38).pos = [115 460 67  28];

   setappdata(gcf,'ObjPosition',obj);

   return;						% CreateObjPosRecord



%---------------------------------------------------------------------------
%
function rot_amount = load_pls_result()

   cond_selection = [];

   %  wait message
   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   msg = 'Loading PLS result ... please wait';
   set(findobj(gcf,'Tag','MessageLine'),'String',msg);

   h = findobj(gcf,'Tag','ResultFile');
   PLSresultFile = get(h,'UserData');

   load(PLSresultFile);
   rri_changepath('petresult');

   setting = getappdata(gcf,'setting');



   if exist('result','var')
      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end

      if isfield(result,'perm_result')
         perm_result = result.perm_result;
      else
         perm_result = [];
      end

      if isfield(result,'datamatcorrs_lst')
         datamatcorrs_lst = result.datamatcorrs_lst;
      end

      if isfield(result,'stacked_designdata')
         design = result.stacked_designdata;
      end

      brainlv = result.u;
      s = result.s;

      if ismember(method, [1 2])
         designlv = result.v;
      end

      if ismember(method, [3 5])
         behavlv = result.v;
      end

      if ismember(method, [4 6])
         ismultiblock = 1;
      end
   end

   bsr = [];
   if exist('boot_result','var') & ~isempty(boot_result)
      bsr = boot_result.compare;
   end

   if ~isempty(setting) & isfield(setting,'orient')
      dims = setting.orient.dims;
      origin_pattern = setting.orient.pattern;

      old_coord = newcoords;
      new_coord = setting.orient.coords;

      if exist('datamatcorrs_lst','var') & ~isempty(datamatcorrs_lst)
         for i=1:length(datamatcorrs_lst)
            blv = [datamatcorrs_lst{i}]';
            blv = rri_xy_orient_data(blv,old_coord,new_coord,dims,origin_pattern);
            datamatcorrs_lst{i} = blv';
         end
      end

      brainlv =rri_xy_orient_data(brainlv,old_coord,new_coord,dims,origin_pattern);

      if ~isempty(bsr)
         bsr =rri_xy_orient_data(bsr,old_coord,new_coord,dims,origin_pattern);
      end

      set(findobj(gcf,'Tag','PlotSagittalView'),'enable','off');
      set(findobj(gcf,'Tag','PlotCoronalView'),'enable','off');
      set(findobj(gcf,'Tag','Plot3View'),'enable','off');
   end

%   brainlv = brainlv * diag(s);		% will be rescaled in 'set_blv_fields' below

   if isempty(setting)
      lv_idx = 1;
      rot_amount = 1;
   else
      lv_idx = setting.lv_idx;
      rot_amount = setting.rot_amount;
   end;

   num_lv = size(brainlv,2);

   if exist('ismultiblock','var')
      set(gcf,'Name', ...
	sprintf('PET Multiblock PLS Brain LV Plot: %s',PLSresultFile));
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenRFPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenRF1Plot'), 'Visible', 'On');
      set(findobj(gcf,'tag','OpenDatamatcorrsPlot'), 'visible', 'on');
      set(findobj(gcf,'tag','MultipleCorrs'), 'visible', 'off');
      setappdata(gcf,'ismultiblock',1);
      setappdata(gcf,'isbehav',1);
      setappdata(gcf,'datamatcorrs_lst',datamatcorrs_lst);
   elseif exist('behavlv','var')
      set(gcf,'Name', ...
	sprintf('PET Behavioral PLS Brain LV Plot: %s',PLSresultFile));
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenRFPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenRF1Plot'), 'Visible', 'On');
      set(findobj(gcf,'tag','OpenDatamatcorrsPlot'), 'visible', 'on');
      set(findobj(gcf,'tag','MultipleCorrs'), 'visible', 'on');
      setappdata(gcf,'isbehav',1);
      setappdata(gcf,'datamatcorrs_lst',datamatcorrs_lst);
   elseif exist('designlv','var')
      set(gcf,'Name', ...
	sprintf('PET Task PLS Brain LV Plot: %s',PLSresultFile));
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenRFPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenRF1Plot'), 'Visible', 'Off');
      set(findobj(gcf,'tag','OpenDatamatcorrsPlot'), 'visible', 'off');
      set(findobj(gcf,'tag','MultipleCorrs'), 'visible', 'off');
      setappdata(gcf,'isbehav',0);
   end

   h = findobj(gcf,'Tag','LVIndexEdit');
   set(h,'String',num2str(lv_idx),'Userdata',lv_idx);
   h = findobj(gcf,'Tag','LVNumberEdit');
   set(h,'String',num2str(num_lv),'Userdata',num_lv);

   setappdata(gcf,'brainlv',brainlv);
   setappdata(gcf, 's', s);
   set_blv_fields(lv_idx);

   if ~exist('boot_result','var') | isempty(boot_result)
      ToggleView(0);
      set(findobj(gcf,'Tag','ViewMenu'),'Visible','off');
      set(findobj(gcf,'Tag','OpenBrainScoresPlot'),'Visible','off');
   else					% show bootstrap ratio if exist
      ToggleView(1);
      set(findobj(gcf,'Tag','ViewMenu'),'Visible','on');

      if exist('method','var') & ( method == 1 | method == 2 | method == 4 | method == 6 )
         set(findobj(gcf,'Tag','OpenBrainScoresPlot'),'Visible','on');
      end

      % set the bootstrap ratio field values
      %
      setappdata(gcf,'BSRatio',bsr);
      set_bs_fields(lv_idx);
      UpdatePValue;
   end;

   h = findobj(gcf,'Tag','OpenContrastWindow');
%   if isequal(ContrastFile,'NONE') | isequal(ContrastFile,'BEHAV')
   if ~exist('design','var')
      set(h,'Visible','off');
   else
      set(h,'Visible','on');
   end;

   set(gcf,'Pointer',old_pointer);
   set(findobj(gcf,'Tag','MessageLine'),'String','');

   setappdata(gcf,'DatamatFileList', datamat_files);
   setappdata(gcf,'RotateAmount',rot_amount);
   setappdata(gcf,'CurrLVIdx',lv_idx);
%   setappdata(gcf,'Dims',dims);
   setappdata(gcf,'cond_selection',cond_selection);

   if exist('method','var')
      setappdata(gcf,'method',method);
   end

   return;						% load_pls_result


%-------------------------------------------------------------------------
%
function OpenBrainPlot()

  h = findobj(gcf,'Tag','ResultFile');
  PLSresultFile = get(h,'UserData');

  brain_plot = getappdata(gcf,'brain_plot');
  if ~isempty(brain_plot)
      msg = 'ERROR: Brain scores plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  brain_plot = pet_plot_brain_scores('STARTUP',PLSresultFile);
  link_info.hdl = gcbf;
  link_info.name = 'brain_plot';
  setappdata(brain_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'brain_plot',brain_plot);

  return;					% OpenBrainPlot


%-------------------------------------------------------------------------
%
function OpenResponseFnPlot()

  DatamatFileList = getappdata(gcbf,'DatamatFileList');
  setappdata(gcbf,'actualHRF',1);

  rf_plot = getappdata(gcbf,'RFPlotHdl');
  if ~isempty(rf_plot)
      msg = 'ERROR: Response function plot is already been opened';
      set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  rf_plot = pet_plot_rf_task('LINK',DatamatFileList);
  link_info.hdl = gcbf;
  link_info.name = 'RFPlotHdl';
  setappdata(rf_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'RFPlotHdl',rf_plot);

  %  make sure the Coord of the Response Function Plot contains
  %  the current point in the Response
  %
  cur_coord = getappdata(gcbf,'Coord');
  setappdata(rf_plot,'Coord',cur_coord);

  return;					% OpenResponseFnPlot


%-------------------------------------------------------------------------
%
function OpenCorrelationPlot

  DatamatFileList = getappdata(gcbf,'DatamatFileList');
  setappdata(gcbf,'actualHRF',0);

  rf1_plot = getappdata(gcbf,'RF1PlotHdl');
  if ~isempty(rf1_plot)
      msg = 'ERROR: Response function plot is already been opened';
      set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  rf1_plot = pet_plot_rf('LINK',DatamatFileList);
  link_info.hdl = gcbf;
  link_info.name = 'RF1PlotHdl';
  setappdata(rf1_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'RF1PlotHdl',rf1_plot);

  %  make sure the Coord of the Response Function Plot contains
  %  the current point in the Response
  %
  cur_coord = getappdata(gcbf,'Coord');
  setappdata(rf1_plot,'Coord',cur_coord);

  return;					% OpenCorrelationPlot


%-------------------------------------------------------------------------
%
function SetClusterReportOptions()

   st_origin = getappdata(gcbf,'Origin');
   dims = getappdata(gcbf,'Dims');

   setting = getappdata(gcf,'setting');

   if isempty(setting) | ~isfield(setting,'cluster_mask_size')
      cluster_mask_size = getappdata(gcbf,'ClusterMaskSize');
      cluster_min_size = getappdata(gcbf,'ClusterMinSize');
      cluster_min_dist = getappdata(gcbf,'ClusterMinDist');
   else
      cluster_mask_size = setting.cluster_mask_size;
      cluster_min_size = setting.cluster_min_size;
      cluster_min_dist = setting.cluster_min_dist;
   end;


   ViewBootstrapRatio = getappdata(gcf,'ViewBootstrapRatio');


   if ViewBootstrapRatio
      if isempty(setting) | ~isfield(setting,'ClusterBSThreshold')
         ClusterBSThreshold = getappdata(gcbf,'ClusterBSThreshold');

         if isempty(ClusterBSThreshold)
            ClusterBSThreshold = getappdata(gcbf,'BSThreshold');
         end
      else
         ClusterBSThreshold = setting.ClusterBSThreshold;
      end

      if isempty(setting) | ~isfield(setting,'ClusterBSThreshold2')
         ClusterBSThreshold2 = getappdata(gcbf,'ClusterBSThreshold2');

         if isempty(ClusterBSThreshold2)
            ClusterBSThreshold2 = getappdata(gcbf,'BSThreshold2');
         end
      else
         ClusterBSThreshold2 = setting.ClusterBSThreshold2;
      end
   else
      if isempty(setting) | ~isfield(setting,'ClusterBLVThreshold')
         ClusterBLVThreshold = getappdata(gcbf,'ClusterBLVThreshold');

         if isempty(ClusterBLVThreshold)
            ClusterBLVThreshold = getappdata(gcbf,'BLVThreshold');
         end
      else
         ClusterBLVThreshold = setting.ClusterBLVThreshold;
      end

      if isempty(setting) | ~isfield(setting,'ClusterBLVThreshold2')
         ClusterBLVThreshold2 = getappdata(gcbf,'ClusterBLVThreshold2');

         if isempty(ClusterBLVThreshold2)
            ClusterBLVThreshold2 = getappdata(gcbf,'BLVThreshold2');
         end
      else
         ClusterBLVThreshold2 = setting.ClusterBLVThreshold2;
      end
   end


   if isempty(st_origin) | all(st_origin == 0)

      st_voxel_size = getappdata(gcf,'STVoxelSize');

      if all(st_dims == [40 48 1 34]) & all(st_voxel_size == [4 4 4])
         st_origin = [20 29 12];
      elseif all(st_dims == [91 109 1 91]) & all(st_voxel_size == [2 2 2])
         st_origin = [46 64 37];
      else
         % according to SPM: if the origin field contains 0, then the origin is
         % assumed to be at the center of the volume.
         %
         st_origin = floor((dims([1 2 4])+1)/2);
         % st_origin = round(st_dims([1 2 4])/2);
      end;
   end;

   xyz = getappdata(gcf,'xyz');


   if(ViewBootstrapRatio)
      prompt = {'Minimum cluster size (in voxels)',  ...
	     'Minimum distance (in mm) between cluster peaks', ...
	     'Origin location (in voxels)', ...
	     'Positive peak BSR threshold', ...
	     'Negative peak BSR threshold' };
      defValues = { num2str(cluster_min_size), ...
		 num2str(cluster_min_dist), ...
		 num2str(st_origin), ...
		 sprintf('%8.5f',ClusterBSThreshold), ...
		 sprintf('%8.5f',ClusterBSThreshold2) };

      dlgTitle='Cluster Report Options';
      lineNo = 1;
      answer = inputdlg(prompt,dlgTitle,lineNo,defValues);

      if isempty(answer),
         return;
      end;

      invalid_options = 0;
      min_size = str2num(answer{1}); 
      min_dist = str2num(answer{2});
      origin_xyz = str2num(answer{3}); 
      ClusterBSThreshold = str2num(answer{4});
      ClusterBSThreshold2 = str2num(answer{5});
   else
      prompt = {'Minimum cluster size (in voxels)',  ...
	     'Minimum distance (in mm) between cluster peaks', ...
	     'Origin location (in voxels)', ...
	     'Positive peak BLV threshold', ...
	     'Negative peak BLV threshold' };
      defValues = { num2str(cluster_min_size), ...
		 num2str(cluster_min_dist), ...
		 num2str(st_origin), ...
		 sprintf('%8.5f',ClusterBLVThreshold), ...
		 sprintf('%8.5f',ClusterBLVThreshold2) };

      dlgTitle='Cluster Report Options';
      lineNo = 1;
      answer = inputdlg(prompt,dlgTitle,lineNo,defValues);

      if isempty(answer),
         return;
      end;

      invalid_options = 0;
      min_size = str2num(answer{1}); 
      min_dist = str2num(answer{2}); 
      origin_xyz = str2num(answer{3}); 
      ClusterBLVThreshold = str2num(answer{4});
      ClusterBLVThreshold2 = str2num(answer{5});
   end


%isempty(mask_size) | 		(mask_size <= 0) | 
   if isempty(min_size) | isempty(min_dist) | isempty(origin_xyz)
      invalid_options = 1;
   elseif (min_size <= 0) | (min_dist <= 0) | (sum(origin_xyz<= 0) ~= 0)
      invalid_options = 1;
   end;   

   if(ViewBootstrapRatio)
      if isempty(ClusterBSThreshold) | isempty(ClusterBSThreshold2) | ... 
	ClusterBSThreshold < getappdata(gcf,'BSThreshold') | ... 
	ClusterBSThreshold2 > getappdata(gcf,'BSThreshold2')

		invalid_options = 1;
      end
   else
      if isempty(ClusterBLVThreshold) | isempty(ClusterBLVThreshold2) | ... 
	ClusterBLVThreshold < getappdata(gcf,'BLVThreshold') | ... 
	ClusterBLVThreshold2 > getappdata(gcf,'BLVThreshold2') 

		invalid_options = 1;
      end
   end
   
   if (invalid_options)
	msg = 'Invalid cluster report options.  Options did not changed';
	set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
	return;
   end;

   setappdata(gcbf,'ClusterMaskSize',4); %mask_size);
   setappdata(gcbf,'ClusterMinSize',min_size);
   setappdata(gcbf,'ClusterMinDist',min_dist);
   setappdata(gcbf,'Origin',origin_xyz);
   setappdata(gcbf,'STOrigin',origin_xyz);

   setting.cluster_mask_size = 4; %mask_size;
   setting.cluster_min_size = min_size;
   setting.cluster_min_dist = min_dist;
   setting.origin = origin_xyz;

   if(ViewBootstrapRatio)
      setappdata(gcbf,'ClusterBSThreshold',ClusterBSThreshold);
      setappdata(gcbf,'ClusterBSThreshold2',ClusterBSThreshold2);
      setting.ClusterBSThreshold = ClusterBSThreshold;
      setting.ClusterBSThreshold2 = ClusterBSThreshold2;
   else
      setappdata(gcbf,'ClusterBLVThreshold',ClusterBLVThreshold);
      setappdata(gcbf,'ClusterBLVThreshold2',ClusterBLVThreshold2);
      setting.ClusterBLVThreshold = ClusterBLVThreshold;
      setting.ClusterBLVThreshold2 = ClusterBLVThreshold2;
   end

   setappdata(gcf,'setting',setting);

if 0
   if isempty(cur_xyz) | ~all(size(cur_xyz) ==  [1 3])
      msg = 'Please use 3 numbers for xyz.';
      set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
      return;
   else
      EditXYZ(cur_xyz);
   end
end

%   xyz = getappdata(gcf,'xyz');		% move ahead

if 0
   if ~isempty(xyz)
      EditXYZ;
   end
end

   if ~isempty(xyz)
      voxel_size = getappdata(gcf,'VoxelSize');
      xyz_offset = xyz - origin_xyz;
      xyz_mm = xyz_offset .* voxel_size;
      h = findobj(gcbf,'Tag','XYZmm');
      set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));
   end;

   return;					% SetClusterReportOptions


%-------------------------------------------------------------------------
%
function OpenClusterReport()

   %  wait message
   old_pointer = get(gcbf,'Pointer');
   set(gcbf,'Pointer','watch');

   msg = 'Generating Cluster Report ... please wait';
   h = rri_wait_box(msg,[0.5 0.1]);

   cluster_min_size = getappdata(gcbf,'ClusterMinSize');
   cluster_min_dist = getappdata(gcbf,'ClusterMinDist');
   peak_bs_thresh = getappdata(gcbf,'ClusterBSThreshold');
   peak_bs_thresh2 = getappdata(gcbf,'ClusterBSThreshold2');
   peak_blv_thresh = getappdata(gcbf,'ClusterBLVThreshold');
   peak_blv_thresh2 = getappdata(gcbf,'ClusterBLVThreshold2');

   cluster_hdl = getappdata(gcbf,'cluster_hdl');
   if ~isempty(cluster_hdl)
      msg = 'Please close any opening cluster report window';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   [tmp cluster_hdl] = pet_cluster_report(cluster_min_size, ...
	cluster_min_dist,peak_bs_thresh,peak_bs_thresh2, ...
	peak_blv_thresh,peak_blv_thresh2);

if ishandle(cluster_hdl)
   link_info.hdl = gcbf;
   link_info.name = 'cluster_hdl';
   setappdata(cluster_hdl,'LinkFigureInfo',link_info);
   setappdata(gcbf,'cluster_hdl',cluster_hdl);
   set(findobj(gcbf,'Tag','MessageLine'),'String','');
end

   set(gcbf,'Pointer',old_pointer);
   delete(h);

   return;					% OpenClusterReport


%-------------------------------------------------------------------------
function OpenContrastWindow()

   contrast_fig = getappdata(gcbf,'ContrastFigHdl');
   if ~isempty(contrast_fig)
      msg = 'ERROR: Constrasts information has already been dispalyed.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   h = findobj(gcbf,'Tag','ResultFile');
   PLSresultFile = get(h,'UserData');


%   load(PLSresultFile,'datamat_files','cond_selection','design');
   load(PLSresultFile);
   rri_changepath('petresult');

   pls_session = datamat_files{1};
   num_groups = length(getappdata(gcf,'DatamatFileList'));

   if exist('method','var') & method == 6
      nonrotatemultiblock = 'nonrotatemultiblock';
      bscan = result.bscan;
   else
      nonrotatemultiblock = [];
      bscan = [];
   end

   if ~exist('behavname','var')
      behavname = '';
   end

   if exist('result','var')
      ContrastMatrix = result.stacked_designdata;
   else
      ContrastMatrix = design;
   end

   contrast_fig = rri_input_contrast_ui({'PET'},pls_session,cond_selection,num_groups,nonrotatemultiblock,1,behavname,ContrastMatrix,bscan);


if 0
   load(datamat_files{1},'session_info');
   cond_name = session_info.condition(find(cond_selection));
   num_groups = length(getappdata(gcf,'DatamatFileList'));

%   if length(cond_name) == size(design, 1)
%      num_groups = 1;
%   end

   if num_groups * length(cond_name) ~= size(design, 1)
      design = repmat(design, [num_groups 1]);
   end

   contrast_fig = rri_input_contrast_ui({'PET'}, cond_name, [], num_groups, design, 1);


%if 0

   if isequal(contrast_file,'NONE'), 
      msg = 'No contrast was used for this PLS analysis.'; 
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   if isequal(contrast_file,'HELMERT'),   % using Helmert matrix for contrasts
      load(datamat_files{1});

      conditions = session_info.condition;
      num_conditions = length(conditions);
      helmert_contrasts = rri_helmert_matrix(num_conditions);

      for i=1:num_conditions-1,
         pls_contrasts(i).name = sprintf('Contrast #%d',i);
         pls_contrasts(i).value = helmert_contrasts(:,i)';
      end;
   else
      try
         load(contrast_file);
      catch 
         msg = sprintf('ERROR: Cannot open contrast file "%s".',contrast_file); 
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end;
   end;

end


%   contrast_fig = pls_input_contrast_ui(pls_contrasts,conditions,1);

   link_info.hdl = gcbf;
   link_info.name = 'ContrastFigHdl';
   setappdata(contrast_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'ContrastFigHdl',contrast_fig);

   return;					% OpenContrastWindow


%-------------------------------------------------------------------------
%
function plot_bs_ratio(PLSresultFile,lv_idx,slice_idx,thresh,range,new_fig)
%
  if (new_fig)
     bg_img = getappdata(gcbf,'BackgroundImg');
     rot_amount = getappdata(gcbf,'RotateAmount');
  else
     bg_img = getappdata(gcf,'BackgroundImg');
     rot_amount = getappdata(gcf,'RotateAmount');
  end;

%  load(PLSresultFile,'boot_result','dims','st_win_size','st_coords', ...
%		     'st_voxel_size','st_origin');
  load(PLSresultFile,'boot_result','dims','st_win_size','st_coords', ...
		     'st_voxel_size','st_origin');
  bs_ratio = boot_result.compare;

  if ~exist('slice_idx','var')
     slice_idx = [1:slices];
  end
  num_slices = length(slice_idx);

  num_lv = size(bs_ratio,2);

  min_ratio = min(bs_ratio(:,lv_idx));
  max_ratio = max(bs_ratio(:,lv_idx));
  if ~exist('range','var') | isempty(range)
     if (abs(min_ratio) > abs(max_ratio)),
       max_ratio = abs(min_ratio);
     else
       min_ratio = -1 * max_ratio;
     end
     range = [min_ratio max_ratio];
  else
     min_ratio = range(1);
     max_ratio = range(2);
  end

  if ~exist('thresh','var') | isempty(thresh)
     thresh = (abs(max_ratio) + abs(min_ratio)) / 6;
  end

  h = findobj(gcf,'Tag','BSThreshold');  set(h,'String',num2str(thresh));
  h = findobj(gcf,'Tag','MaxRatio');   set(h,'String',num2str(max_ratio));
  h = findobj(gcf,'Tag','MinRatio');   set(h,'String',num2str(min_ratio));

  win_size = st_win_size;

  if (mod(rot_amount,2) == 0)
    img_height = dims(1);		  % rows
    img_width  = dims(2);
  else
    img_height = dims(2);		  % rows - after 90 or 270 rotation
    img_width  = dims(1);
  end;

  mont_height = win_size * img_height;
  mont_width = num_slices * img_width;


  %  construct the bootstrap ratio images
  %
  ratio_imgs = zeros(win_size*img_height,mont_width);
  first_rows = 1; last_rows = img_height;
  for i=1:win_size,
     bsr = bs_ratio(i:win_size:end,lv_idx);

     [img,cmap,cbar] = fmri_plot_brainlv(bsr,st_coords,dims,slice_idx, ...
                                    thresh,range,rot_amount,bg_img);
     ratio_imgs(first_rows:last_rows,:) = reshape(img,[img_height, mont_width]);
     first_rows = last_rows + 1; last_rows = first_rows + img_height - 1;
  end;

  %  display the images
  %
  if (new_fig)
      [axes_hdl,colorbar_hdl] = create_new_blv_figure;
  else
      axes_hdl = getappdata(gcf,'BlvAxes');
%      colorbar_hdl = getappdata(gcf,'Colorbar');
  end;

  axes(axes_hdl);
  h_img = image(ratio_imgs);
  set(h_img,'Tag','BLVImg');
  colormap(cmap);

  set(gca,'tickdir','out','ticklength',[0.001 0.001]);
  set(gca,'xlabel',text('String','Slice','FontSize',10,'Interpreter','none'));
  set(gca,'xtick',[img_width/2:img_width:mont_width]);
  set(gca,'xticklabel',slice_idx);
  set(gca,'ylabel',text('String','Lag','FontSize',10,'Interpreter','none'));
  set(gca,'ytick',[img_height/2:img_height:mont_height]);
  set(gca,'yticklabel',[0:win_size-1]);

  if (new_fig)
%     pet_create_colorbar(colorbar_hdl,cbar,min_ratio,max_ratio);
     return;
  end;

  set(h_img,'ButtonDownFcn','pet_result_ui(''SelectPixel'')');
%  pet_create_colorbar( colorbar_hdl, cbar, min_ratio, max_ratio );


  %  save the attributes of the current image
  %
  setappdata(gcf,'Dims',dims);
  setappdata(gcf,'VoxelSize',st_voxel_size);
  setappdata(gcf,'Origin',st_origin);
  setappdata(gcf,'WinSize',win_size);
  setappdata(gcf,'SliceIdx',slice_idx);
  setappdata(gcf,'ImgHeight',img_height);
  setappdata(gcf,'ImgWidth',img_width);
  setappdata(gcf,'ImgRotateFlg',1);
  setappdata(gcf,'NumLVs',num_lv);
  setappdata(gcf,'BSRatio',bs_ratio);
  setappdata(gcf,'BSRatioCoords',st_coords);
  setappdata(gcf,'BSThreshold',thresh);
  setappdata(gcf,'RotateAmount',rot_amount);

  return;					% plot_bs_ratio

%-------------------------------------------------------------------------
%
function SaveResultToIMG(is_disp)
%

  h = findobj(gcf,'Tag','ResultFile'); PLSresultFile = get(h,'Userdata');

  try 				% load the dimension info of the st_datamat
     load(PLSresultFile,'dims'),
  catch
     msg =sprintf('ERROR: Cannot load the PET result file "%s".',PLSresultFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;

  h = findobj(gcf,'Tag','LVIndexEdit');
  lv_idx = get(h,'Userdata');
  curr_lv_idx = getappdata(gcf,'CurrLVIdx');
  if (lv_idx ~= curr_lv_idx)
     lv_idx = curr_lv_idx;
     set(h,'String',num2str(lv_idx));
  end

  old_pointer = get(gcf,'Pointer');
  fig_hdl = gcf;
  set(fig_hdl,'Pointer','watch');


   win_size = getappdata(gcf,'WinSize');

   cluster_mask_state = get(findobj(gcf,'tag','ClusterMask'),'Userdata');

   isbsr = getappdata(gcf,'ViewBootstrapRatio');
   if isbsr
      cluster_info = getappdata(gcf, 'cluster_bsr');
      coords = getappdata(gcf,'BSRatioCoords');
   else
      cluster_info = getappdata(gcf, 'cluster_blv');
      coords = getappdata(gcf,'BLVCoords');
   end

   if length(cluster_info) < curr_lv_idx
      cluster_info = [];
   else
      cluster_info = cluster_info{curr_lv_idx};
   end

   if cluster_mask_state
      cluster_info = [];
   end

   for i = 1:win_size
      if isempty(cluster_info)
         cluster_idx{i} = coords;
      else
         cluster_idx{i} = cluster_info.data{i}.idx;
      end

      if isequal(coords, cluster_idx{i})
         non_cluster_coords{i} = [];
      else
         [tmp cluster_coords] = intersect(coords,cluster_idx{i});
         non_cluster_coords{i} = ones(1,length(coords));
         non_cluster_coords{i}(cluster_coords) = 0;
         non_cluster_coords{i} = find(non_cluster_coords{i});
      end
   end


  if (getappdata(gcf,'ViewBootstrapRatio') == 0),	% save brain lv
     thresh = getappdata(gcf,'BLVThreshold');
     thresh2 = getappdata(gcf,'BLVThreshold2');  

     if is_disp
        create_brainlv_disp(PLSresultFile,lv_idx,thresh,thresh2,non_cluster_coords);
     else
        create_brainlv_img(PLSresultFile,lv_idx,thresh,thresh2,non_cluster_coords);
     end
  else							% save bootstrap ratio
     thresh_ratio = getappdata(gcf,'BSThreshold');
     thresh_ratio2 = getappdata(gcf,'BSThreshold2');  

     if is_disp
        create_bs_ratio_disp(PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2,non_cluster_coords);
     else
        create_bs_ratio_img(PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2,non_cluster_coords);
     end
  end;

  set(fig_hdl,'Pointer',old_pointer);

  return;					% SaveResultToIMG


%--------------------------------------------------------------------------
function create_brainlv_disp(PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2,non_cluster_coords);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-9);
  image_fn = [resultfile_prefix, sprintf('PETblv_disp_lv%d.img',lv_idx)];

  [filename, pathname] = rri_selectfile(image_fn,'Brain LV IMG file');

  img_file = fullfile(pathname, filename);

  if isequal(filename,0)
      return;
  end;

  %  load the result file
  %
%  load(PLSresultFile,'brainlv','dims','newcoords','voxel_size','origin','s');
  load(PLSresultFile);

   if exist('result','var')
      brainlv = result.u;
      s = result.s;
   end

   is_rescale = get(findobj(gcf,'Tag','RESCALECheckbox'),'value');

   if is_rescale
      for i=1:length(s)
         brainlv(:,i) = brainlv(:,i).*s(i);
      end
   end

  dims = dims([1 2 4]);

  %  save background to img
  %
  brainlv = brainlv(:,lv_idx);
  bg_img = getappdata(gcf,'BackgroundImg');
  cmap = getappdata(gcf,'cmap');
  num_blv_colors = 25;
  brain_region_color_idx = 51;
  first_lower_color_idx = 101;
  first_upper_color_idx = 126;
  h = findobj(gcf,'Tag','MaxValue'); max_blv = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','MinValue'); min_blv = str2num(get(h,'String'));

  brainlv(non_cluster_coords{1}) = 0;

  too_large = find(brainlv > max_blv); brainlv(too_large) = max_blv;
  too_small = find(brainlv < min_blv); brainlv(too_small) = min_blv;

  % Create the image slices in which voxels are set to be within certain range
  %
  lower_interval = (thresh_ratio2 - min_blv) / (num_blv_colors-1);
  upper_interval = (max_blv - thresh_ratio) / (num_blv_colors-1);

  blv = zeros(1,length(newcoords)) + brain_region_color_idx;
  lower_idx = find(brainlv < thresh_ratio2);
  blv_offset = brainlv(lower_idx) - min_blv; 
  lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
  blv(lower_idx) = lower_color_idx;

  upper_idx = find(brainlv > thresh_ratio);
  blv_offset = max_blv - brainlv(upper_idx); 
  upper_color_idx = num_blv_colors - round(blv_offset/upper_interval);
  upper_color_idx = upper_color_idx + first_upper_color_idx - 1;
  blv(upper_idx) = upper_color_idx;

  if isempty(bg_img)
     non_brain_region_color_idx = size(cmap,1);
     img = zeros(1,dims(1)*dims(2)*dims(3)) + non_brain_region_color_idx;
     img(newcoords) = blv;
     img = reshape(img,dims); 
  else
     max_bg = max(bg_img(:));
     min_bg = min(bg_img(:));
     img = (bg_img - min_bg) / (max_bg - min_bg) * 100;
     img(newcoords(lower_idx)) = blv(lower_idx);
     img(newcoords(upper_idx)) = blv(upper_idx);
     img = reshape(img,dims); 
  end

%  img = zeros(dims);

%  blv = brainlv(:,lv_idx); 
%  blv(abs(blv) < thresh_ratio) = 0;

%  img(newcoords) = blv;

  descrip = sprintf('BrainLV from %s, LV: %d, Pos.Thresh: %8.5f, Neg.Thresh: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2);
  rri_write_img(img_file,img,0,dims,voxel_size,16,origin,descrip);

  %  save background to img
  %
  [tmp filename] = fileparts(filename);
  filename = [filename '_cmap'];
  img_file = fullfile(pathname, filename);
  save(img_file,'cmap');

  return;					% create_brainlv_disp


%--------------------------------------------------------------------------
function create_bs_ratio_disp(PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2,non_cluster_coords);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-9);
  image_fn = [resultfile_prefix, sprintf('PETbsr_disp_lv%d.img',lv_idx)];

  [filename, pathname] = rri_selectfile(image_fn,'Bootstrap Result IMG file');

  img_file = fullfile(pathname, filename);

  if isequal(filename,0)
      return;
  end;

  %  load the result file
  %
%  load(PLSresultFile,'boot_result','dims','newcoords','voxel_size','origin');
  load(PLSresultFile);

   if exist('result','var')
      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end
   end

  bs_ratio = boot_result.compare;

  dims = dims([1 2 4]);

  %  save background to img
  %
  brainlv = bs_ratio(:,lv_idx);
  bg_img = getappdata(gcf,'BackgroundImg');
  cmap = getappdata(gcf,'cmap');
  num_blv_colors = 25;
  brain_region_color_idx = 51;
  first_lower_color_idx = 101;
  first_upper_color_idx = 126;

  h = findobj(gcf,'Tag','MaxRatio'); max_blv = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','MinRatio'); min_blv = str2num(get(h,'String'));

  brainlv(non_cluster_coords{1}) = 0;

  too_large = find(brainlv > max_blv); brainlv(too_large) = max_blv;
  too_small = find(brainlv < min_blv); brainlv(too_small) = min_blv;

  % Create the image slices in which voxels are set to be within certain range
  %
  lower_interval = (thresh_ratio2 - min_blv) / (num_blv_colors-1);
  upper_interval = (max_blv - thresh_ratio) / (num_blv_colors-1);

  blv = zeros(1,length(newcoords)) + brain_region_color_idx;
  lower_idx = find(brainlv < thresh_ratio2);
  blv_offset = brainlv(lower_idx) - min_blv; 
  lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
  blv(lower_idx) = lower_color_idx;

  upper_idx = find(brainlv > thresh_ratio);
  blv_offset = max_blv - brainlv(upper_idx); 
  upper_color_idx = num_blv_colors - round(blv_offset/upper_interval);
  upper_color_idx = upper_color_idx + first_upper_color_idx - 1;
  blv(upper_idx) = upper_color_idx;

  if isempty(bg_img)
     non_brain_region_color_idx = size(cmap,1);
     img = zeros(1,dims(1)*dims(2)*dims(3)) + non_brain_region_color_idx;
     img(newcoords) = blv;
     img = reshape(img,dims); 
  else
     max_bg = max(bg_img(:));
     min_bg = min(bg_img(:));
     img = (bg_img - min_bg) / (max_bg - min_bg) * 100;
     img(newcoords(lower_idx)) = blv(lower_idx);
     img(newcoords(upper_idx)) = blv(upper_idx);
     img = reshape(img,dims); 
  end

%  img = zeros(dims);

%  bsr = bs_ratio(:,lv_idx); 
%  bsr(abs(bsr) < thresh_ratio) = 0;

%  img(newcoords) = bsr;

  descrip = sprintf('Bootstrap ratio from %s, LV: %d, Pos.Thresh: %8.5f, Neg.Thresh: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2);
  rri_write_img(img_file,img,0,dims,voxel_size,16,origin,descrip);

  %  save background to img
  %
  [tmp filename] = fileparts(filename);
  filename = [filename '_cmap'];
  img_file = fullfile(pathname, filename);
  save(img_file,'cmap');

  return;					% create_bs_ratio_disp


%--------------------------------------------------------------------------
function create_brainlv_img(PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2,non_cluster_coords);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-9);
  image_fn = [resultfile_prefix, sprintf('PETblv_lv%d.img',lv_idx)];

  [filename, pathname] = rri_selectfile(image_fn,'Brain LV IMG file');

  img_file = fullfile(pathname, filename);

  if isequal(filename,0)
      return;
  end;

  %  load the result file
  %
%  load(PLSresultFile,'brainlv','dims','newcoords','voxel_size','origin','s');
  load(PLSresultFile);

   if exist('result','var')
      brainlv = result.u;
      s = result.s;
   end

   is_rescale = get(findobj(gcf,'Tag','RESCALECheckbox'),'value');

   if is_rescale
      for i=1:length(s)
         brainlv(:,i) = brainlv(:,i).*s(i);
      end
   end

  dims = dims([1 2 4]);
  img = zeros(dims);

  blv = brainlv(:,lv_idx); 
  blv( blv < thresh_ratio & blv > thresh_ratio2 ) = 0;

  img(newcoords) = blv;
  img(newcoords(non_cluster_coords{1})) = 0;

  descrip = sprintf('BrainLV from %s, LV: %d, Pos.Thresh: %8.5f, Neg.Thresh: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2);
  rri_write_img(img_file,img,0,dims,voxel_size,16,origin,descrip);

  return;					% create_brainlv_img


%--------------------------------------------------------------------------
function create_bs_ratio_img(PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2,non_cluster_coords);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-9);
  image_fn = [resultfile_prefix, sprintf('PETbsr_lv%d.img',lv_idx)];

  [filename, pathname] = rri_selectfile(image_fn,'Bootstrap Result IMG file');

  img_file = fullfile(pathname, filename);

  if isequal(filename,0)
      return;
  end;

  %  load the result file
  %
%  load(PLSresultFile,'boot_result','dims','newcoords','voxel_size','origin');
  load(PLSresultFile);

   if exist('result','var')
      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end
   end

  bs_ratio = boot_result.compare;

  dims = dims([1 2 4]);
  img = zeros(dims);

  bsr = bs_ratio(:,lv_idx); 
  bsr( bsr < thresh_ratio & bsr > thresh_ratio2 ) = 0;

  img(newcoords) = bsr;
  img(newcoords(non_cluster_coords{1})) = 0;

  descrip = sprintf('Bootstrap ratio from %s, LV: %d, Pos.Thresh: %8.5f, Neg.Thresh: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2);
  rri_write_img(img_file,img,0,dims,voxel_size,16,origin,descrip);

  return;					% create_bs_ratio_img


%--------------------------------------------------------------------------
%
function h0 = wait_box(Message,DiagWH);

   diag_w = DiagWH(1);
   diag_h = DiagWH(2);
   diag_x = (1 - diag_w) / 2;
   diag_y = (1 - diag_h) / 2;
   
   h0 = dialog( 'Parent',0, ...
		'Units','normal', ...
		'Pointer','watch', ...
	   	'Position', [diag_x diag_y diag_w diag_h], ...
   		'Tag', 'WaitDialog');

   x = 0.05;
   y = 0.1;
   w = 0.9;
   h = 0.6;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
		'unit','normal', ...
   		'Position', pos, ...
   		'Style', 'text', ...	
		'fontunit','normal', ...
   		'FontSize', 0.35, ...
   		'FontWeight', 'bold', ...
   		'String', Message);

  drawnow;
           
  return;					% wait_box


%--------------------------------------------------------------------------
%
function ToggleView(view_state)

   cluster_hdl = getappdata(gcf,'cluster_hdl');
   if ~isempty(cluster_hdl) & ishandle(cluster_hdl)
     delete(cluster_hdl);
   end;

   if ~exist('view_state','var') | isempty(view_state),
      view_state = ~(getappdata(gcf,'ViewBootstrapRatio'));
   end;

   PLSResultFile = get(findobj(gcf,'Tag','ResultFile'),'UserData');

   if (view_state == 0)			% view brain lv
      setappdata(gcf,'ViewBootstrapRatio',0);
      bs_visibility = 'off';
      blv_visibility = 'on';
      save_menu_label = '&Save the BLV result to the IMG files';
      view_menu_label = '&View Bootstrap Ratio';
      plot_menu_label = 'Create &Brain LV Figure';
      if(getappdata(gcf,'ismultiblock'))
         fig_title = sprintf('PET Multiblock PLS Brain LV Plot: %s',PLSResultFile);
      elseif(getappdata(gcf,'isbehav'))
         fig_title = sprintf('PET Behavioral PLS Brain LV Plot: %s',PLSResultFile);
      else
         fig_title = sprintf('PET Task PLS Brain LV Plot: %s',PLSResultFile);
      end
   else					% view bootstrap ratio
      setappdata(gcf,'ViewBootstrapRatio',1);
      bs_visibility = 'on';
      blv_visibility = 'off';
      save_menu_label = '&Save the BS ratio result to the IMG files';
      view_menu_label = '&View Brain LV';
      plot_menu_label = 'Create &Bootstrap Ratio Figure';
      if(getappdata(gcf,'ismultiblock'))
         fig_title = sprintf('PET Multiblock PLS Bootstrap Ratio Plot: %s',PLSResultFile);
      elseif(getappdata(gcf,'isbehav'))
         fig_title = sprintf('PET Behavioral PLS Bootstrap Ratio Plot: %s',PLSResultFile);
      else
         fig_title = sprintf('PET Task PLS Bootstrap Ratio Plot: %s',PLSResultFile);
      end
   end;


   %  set visibility of the brain LV fields
   %
   set(findobj(gcf,'Tag','BLVTitle'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','BLVValueLabel'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','BLVValue'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','ThresholdLabel'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','Threshold'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','ThresholdLabel2'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','Threshold2'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','MinValueLabel'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','MinValue'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','MaxValueLabel'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','MaxValue'),'Visible',blv_visibility);
   set(findobj(gcf,'Tag','RESCALECheckbox'),'Visible',blv_visibility);

   %  set visibility of the bootstrap fields
   %
   set(findobj(gcf,'Tag','BSRatioTitle'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','BSThresholdLabel'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','BSThreshold'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','BSThresholdLabel2'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','BSThreshold2'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','PValueLabel'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','PValue'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','BSValueLabel'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','BSValue'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','MinRatioLabel'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','MinRatio'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','MaxRatioLabel'),'Visible',bs_visibility);
   set(findobj(gcf,'Tag','MaxRatio'),'Visible',bs_visibility);

   %  update menu labels
   %
   set(gcf,'Name',fig_title);
   set(findobj(gcf,'Tag','ViewToggleMenu'),'Label',view_menu_label);
   set(findobj(gcf,'Tag','PlotNewFigure'),'Label',plot_menu_label);
   set(findobj(gcf,'Tag','SaveResultToIMG'),'Label',save_menu_label);

   EditXYZ;

   return;					% ToggleView


%--------------------------------------------------------------------------
function EditLV()

   old_lv_idx = getappdata(gcf,'CurrLVIdx');		% save old lv_idx
   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if isempty(lv_idx),
      msg = 'ERROR: Invalid input for the LV index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lv_idx_hdl,'String',num2str(old_lv_idx));
      return;
   end;

   if ( lv_idx == old_lv_idx)  % LV does not changed do nothing
      return;
   end;

   num_lv = getappdata(gcf,'NumLVs');
   if (lv_idx < 1 | lv_idx > num_lv)
      msg = 'ERROR: Input LV index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lv_idx_hdl,'String',num2str(old_lv_idx));
      return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   %  update the brainlv and bootstrap ratio fields
   %
   set_bs_fields(lv_idx);
   set_blv_fields(lv_idx);

   h = findobj(gcf,'Tag','Threshold');
   thresh = str2num(get(h,'String'));  
   h = findobj(gcf,'Tag','Threshold2');
   thresh2 = str2num(get(h,'String'));  
   set_blv_fields(lv_idx,thresh,thresh2);

   set(lv_idx_hdl,'Userdata',lv_idx);
   setappdata(gcf,'CurrLVIdx',lv_idx);

   if (getappdata(gcf,'ViewBootstrapRatio') == 1);
      UpdatePValue;
   end;

   set(gcf,'Pointer',old_pointer);

%   EditXYZ;

   return;					% EditLV

%--------------------------------------------------------------------------
function UpdatePValue()

   h = findobj(gcf,'Tag','BSThreshold');
   bootstrap_ratio = str2num(get(h,'String'));

   if isempty(bootstrap_ratio),
      msg = 'ERROR: Invalid input for bootstrap ratio.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;


   h = findobj(gcf,'Tag','LVIndexEdit');
   lv_idx = get(h,'Userdata');

   bs_ratio = getappdata(gcf,'BSRatio');
   curr_bs_ratio = bs_ratio(:,lv_idx);
   curr_bs_ratio = curr_bs_ratio(find(isnan(curr_bs_ratio) == 0));

   idx = find(abs(curr_bs_ratio) < std(curr_bs_ratio) * 5); % avoid the outliers
   std_ratio = std(curr_bs_ratio(idx));

   p_value = ratio2p(bootstrap_ratio,0,1);	%std_ratio);
   set(findobj(gcf,'Tag','PValue'), 'String',sprintf('%7.4f',p_value));

   return;					% UpdatePValue


%--------------------------------------------------------------------------
function LoadResultFile()

   [PLSresultFile,PLSresultFilePath] = ...
                         rri_selectfile('*PETresult.mat','Open PLS Result');
   if isequal(PLSresultFilePath,0), return; end;

   cd(PLSresultFilePath);
   PLSResultFile = [PLSresultFilePath,PLSresultFile];

   DeleteLinkedFigure;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','arrow');

   h = findobj(gcf,'Tag','ResultFile');
   [r_path, r_file, r_ext] = fileparts(PLSResultFile);
   set(h,'UserData', PLSResultFile,'String',r_file);

   % set(gcf,'Name',sprintf('PET PLS Brain Latent Variable Plot: %s',PLSResultFile));

   rot_amount = load_pls_result;
   pet_result_ui('Rotation', rot_amount);

   % reset 'Checked' mark for new result file
   %
   h = findobj(gcf,'Tag','Rotate0Menu');
   set(h,'Checked','on');
   h = findobj(gcf,'Tag','Rotate90Menu');
   set(h,'Checked','off');
   h = findobj(gcf,'Tag','Rotate180Menu');
   set(h,'Checked','off');
   h = findobj(gcf,'Tag','Rotate270Menu');
   set(h,'Checked','off');

   set(gcf,'Pointer',old_pointer);

   return;					% LoadResultFile


%--------------------------------------------------------------------------
function LoadTemplateFile()

   [fname, fpath] = rri_selectfile('*.mat','Load template file');
   if (fpath == 0), return; end;

   template_file = [fpath,fname];

   setappdata(gcf,'template_file',template_file);

   ShowResult(0,1);

   return;					% LoadTemplateFile


%--------------------------------------------------------------------------
function LoadBackgroundImage()

   [bg_img_file,bg_img_path] = ...
                         rri_selectfile('*.img','Load background image');
   if (bg_img_path == 0), return; end;

   BgImgFile = [bg_img_path,bg_img_file];

   %  make sure the dimension of the bg image is same as the raw images
   try 
     bg_dims = rri_imginfo(BgImgFile);
     bg_dims = [bg_dims(1) bg_dims(2) 1 bg_dims(3)];
   catch
     msg =sprintf('ERROR: Cannot load the background image "%s".',BgImgFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
   end;

   if ~isequal(bg_dims,getappdata(gcf,'Dims'))
     msg = 'The dimensions of the background and data images are not matched'; 
     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
     return;
   end;

   bg_img = load_nii(BgImgFile, 1);
   bg_img = reshape(double(bg_img.img), [bg_img.hdr.dime.dim(2:3) 1 bg_img.hdr.dime.dim(4)]);

   setappdata(gcf,'BackgroundImg',bg_img);

   ShowResult(0,1);

   return;					% LoadBackgroundImage


%--------------------------------------------------------------------------
function SaveBackgroundImage()
%

  h = findobj(gcf,'Tag','ResultFile'); PLSresultFile = get(h,'Userdata');

  try 				% load the dimension info of the datamat
     load(PLSresultFile,'dims','voxel_size','origin','newcoords'),
  catch
     msg =sprintf('ERROR: Cannot load the PLS result file "%s".',PLSresultFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;

  dims = dims([1 2 4]);
  img = zeros(dims);
  img = img(:);
  img(newcoords) = 1;
  img = reshape(img,dims);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-9);
  image_fn = [resultfile_prefix, 'background.img'];

  [filename,pathname] = rri_selectfile(image_fn,'Save brain region to IMG file');
  if isequal(filename,0)
      return;
  end;

  img_file = fullfile(pathname, filename);
  descrip = sprintf('Background Image from %s', PLSresultFile);
  rri_write_img(img_file,img,0,dims,voxel_size,16,origin,descrip);

  return;					% SaveBackgroundImage


%--------------------------------------------------------------------------
function [axes_h,colorbar_h] = DisplayIMG();

    %  get the IMG filename first
    %
    [filename, pathname] = rri_selectfile('PET*.img', ...
				'Load IMG file');
    if isequal(filename,0)
        return;
    end

    w = 0.46;
    h = 0.65;
    x = (1-w)/2;
    y = (1-h)/2;

    pos = [x y w h];

    fig_h = figure('Units','normal', ...
   	'Color',[0.8 0.8 0.8], ...
        'NumberTitle','off', ...
   	'DoubleBuffer','on', ...
   	'MenuBar','none', ...
   	'Position',pos, ...
	'PaperPositionMode', 'auto', ...
        'Userdata','Clone', ...
   	'Tag','PlotBrainLV2');
    %
    axes_h = axes('Parent',fig_h, ...				% axes
        'Units','normal', ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',[1 1 1], ...
  	'Position',[0.08 0.08 0.84 0.84], ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','BlvAxes');
%    colorbar_h = axes('Parent',fig_h, ...			% axes
%        'Units','pixels', ...
%   	'Position',[440 30 30 445], ...
%   	'XTick', [], ...
%   	'YTick', [], ...
%   	'Tag','Colorbar');

%    old_pointer = get(gcf,'Pointer');
%    fig_hdl = gcf;
%    set(fig_hdl,'Pointer','watch');

%    setappdata(gcf,'Colorbar',colorbar_h);
    setappdata(gcf,'BlvAxes',axes_h);

    load('pet_map');

    blv = load_nii(filename, 1);
    blv = reshape(double(blv.img), [blv.hdr.dime.dim(2:3) 1 blv.hdr.dime.dim(4)]);

    dims = size(blv);

    num_slices = dims(4);
    img_height = dims(2);
    img_width  = dims(1);

    blv = reshape(blv,[dims(1)*dims(2),dims(4)]);

    % save a cornor of the last slice as the background intensity
    %
    bg_intensity = blv(1, num_slices);

    % calculate how many slices to display for each row and column
    %
    if dims(1) > dims(2)
        siz = [dims(1), dims(2), dims(4)];
    else
        siz = [dims(2), dims(1), dims(4)];
    end

    cols_disp = sqrt(prod(siz))/siz(2);
    rows_disp = siz(3)/cols_disp;
    if (ceil(cols_disp)-cols_disp) < (ceil(rows_disp)-rows_disp),
        cols_disp = ceil(cols_disp); rows_disp = ceil(siz(3)/cols_disp);
    else
        rows_disp = ceil(rows_disp); cols_disp = ceil(siz(3)/rows_disp);
    end

    % for empty slice (27-30), filled them with background intensity
    %
    blv_filled = [blv, ...
	bg_intensity * ...
	ones(img_height*img_width,rows_disp*cols_disp-num_slices)];

    blv_disp = [];
    for(row = 0:rows_disp-1)

        % take 'cols_disp' amount of slices from blv_filled
        % and put into blv_row
        %
        blv_row = blv_filled(:,[row*cols_disp+1:row*cols_disp+cols_disp]);

        % reshape the slice to integrate the whole row together
        %
        blv_row = reshape(blv_row, [img_height, img_width*cols_disp]);
        blv_disp = [blv_disp; blv_row];

    end

    blv_disp = reshape(blv_disp, [rows_disp*img_height, cols_disp*img_width]);
    h_img = image(blv_disp,'CDataMapping','scaled');

    axis off;
    colormap(map);

%    set(fig_hdl,'Pointer',old_pointer);

    return; 						% DisplayIMG


%--------------------------------------------------------------------------
%
% initially set bs field at left panel
%
%--------------------------------------------------------------------------
function  [min_ratio, max_ratio, bs_thresh] = set_bs_fields(lv_idx),

   bs_ratio = getappdata(gcf,'BSRatio');
   if isempty(bs_ratio),		 % no bootstrap data -> return;
       return;
   end;

   if ~exist('lv_idx','var') | isempty(lv_idx),
      lv_idx = 1;
   end;

%   p_value = 0.05;		% two-tail 5%
%   cumulated_p = 1 - (p_value/2);
%
%   curr_bs_ratio = bs_ratio(:,lv_idx);
%   curr_bs_ratio(isnan(curr_bs_ratio)) = 0;
%   idx=find(abs(curr_bs_ratio) < std(curr_bs_ratio) * 5); % avoid the outliers
%
%   std_ratio = std(curr_bs_ratio(idx));
%   bs_thresh = cumulative_gaussian_inv(cumulated_p,0,std_ratio);

   bs95 = percentile(bs_ratio, 95);

   %  find 95 percentile as initial threshold
   %
   setting = getappdata(gcf,'setting');

   if ~isempty(setting) & isfield(setting,'bs_thresh') ...
	& length(setting.bs_thresh)>=lv_idx ...
	& ~isempty(setting.bs_thresh{lv_idx}) ...
	& isfield(setting,'bs_thresh2') ...
	& length(setting.bs_thresh2)>=lv_idx ...
	& ~isempty(setting.bs_thresh2{lv_idx})

      bs_thresh = setting.bs_thresh{lv_idx};
      bs_thresh2 = setting.bs_thresh2{lv_idx};
      min_ratio = setting.min_ratio{lv_idx};
      max_ratio = setting.max_ratio{lv_idx};
   else
      bs_thresh = abs(bs95(lv_idx));
      bs_thresh2 = -bs_thresh;
      min_ratio = min(bs_ratio(:,lv_idx));
      max_ratio = max(bs_ratio(:,lv_idx));

      if (max_ratio < bs_thresh)
         bs_thresh = max_ratio;
      end

      if (min_ratio > bs_thresh2)
         bs_thresh2 = min_ratio;
      end
   end;

   set(findobj(gcf,'Tag','BSThreshold'),'String',sprintf('%8.5f',bs_thresh));
   set(findobj(gcf,'Tag','BSThreshold2'),'String',sprintf('%8.5f',bs_thresh2));
%   set(findobj(gcf,'Tag','PValue'),'String',sprintf('%8.5f',p_value));
   set(findobj(gcf,'Tag','MinRatio'),'String',sprintf('%8.5f',min_ratio));
   set(findobj(gcf,'Tag','MaxRatio'),'String',sprintf('%8.5f',max_ratio));

   return; 						% set_bs_field


%--------------------------------------------------------------------------
%
% initially set blv field at left panel
%
%--------------------------------------------------------------------------
function  [min_blv, max_blv, thresh, thresh2] = set_blv_fields(lv_idx, thresh, thresh2),

   is_rescale = get(findobj(gcf,'Tag','RESCALECheckbox'),'value');

   if is_rescale
%      brainlv = getappdata(gcf, 'blv_s');
      brainlv = getappdata(gcf,'brainlv');
      s = getappdata(gcf,'s');
      for i=1:length(s)
         brainlv(:,i) = brainlv(:,i).*s(i);
      end
   else
      brainlv = getappdata(gcf,'brainlv');
   end

   setappdata(gcf,'BLVData',brainlv);

   if isempty(brainlv)				% no brain lv data -> return;
       return;
   end

   if ~exist('lv_idx','var') | isempty(lv_idx),
      lv_idx = 1;
   end;

   blv95 = percentile(brainlv, 95);

   %  find 95 percentile as initial threshold
   %
   setting = getappdata(gcf,'setting');

   if ~isempty(setting) & isfield(setting,'thresh') ...
	& length(setting.thresh)>=lv_idx ...
	& ~isempty(setting.thresh{lv_idx}) ...
	& isfield(setting,'thresh2') ...
	& length(setting.thresh2)>=lv_idx ...
	& ~isempty(setting.thresh2{lv_idx})

      thresh = setting.thresh{lv_idx};
      thresh2 = setting.thresh2{lv_idx};
      min_blv = setting.min_blv{lv_idx};
      max_blv = setting.max_blv{lv_idx};
   else
      min_blv = min(brainlv(:,lv_idx));
      max_blv = max(brainlv(:,lv_idx));
      thresh = (abs(max_blv) + abs(min_blv)) / 6;

      if max_blv < thresh
         thresh = max_blv;
      end
   end;

   if ~exist('thresh2','var') | isempty(thresh2),
      thresh2 = -thresh;

      if min_blv > thresh2
         thresh2 = min_blv;
      end
   end

   set(findobj(gcf,'Tag','Threshold'),'String',sprintf('%8.5f',thresh));
   set(findobj(gcf,'Tag','Threshold2'),'String',sprintf('%8.5f',thresh2));
   set(findobj(gcf,'Tag','MinValue'),'String',sprintf('%8.5f',min_blv));
   set(findobj(gcf,'Tag','MaxValue'),'String',sprintf('%8.5f',max_blv));

   return; 						% set_blv_field


%--------------------------------------------------------------------------
function  p_value = ratio2p(x,mu,sigma)

   p_value = (1 + erf( (x - mu) / (sqrt(2)*sigma))) / 2;
   p_value = (1 - p_value) * 2;

   return; 						% ratio2p


%-------------------------------------------------------------------------
%
function ShowResult(action,update,orient)
% action=0 - plot with the control figure
% action=1 - plot in a seperate figure
%

  mainfig = gcf;
  h = findobj(gcf,'Tag','ResultFile'); PLSresultFile = get(h,'Userdata');



  h = findobj(gcf,'Tag','LVIndexEdit');  lv_idx = get(h,'Userdata');
  curr_lv_idx = getappdata(gcf,'CurrLVIdx');
  if (lv_idx ~= curr_lv_idx),
     lv_idx = curr_lv_idx;
     set(h,'String',num2str(lv_idx));
  end;

  fig_hdl = gcf;
  old_pointer = get(fig_hdl,'Pointer');
  set(fig_hdl,'Pointer','watch');


   %%%%%%%%%%%%%%%%      take out cluster_info      %%%%%%%%%%%%%%%%

  cluster_mask_state = get(findobj(gcf,'tag','ClusterMask'),'Userdata');

  isbsr = getappdata(gcf,'ViewBootstrapRatio');
  if isbsr
     cluster_info = getappdata(gcf, 'cluster_bsr');
  else
     cluster_info = getappdata(gcf, 'cluster_blv');
  end

  if length(cluster_info) < curr_lv_idx
     cluster_info = [];
  else
     cluster_info = cluster_info{curr_lv_idx};
  end

%  if ~isempty(cluster_info) & ~cluster_mask_state
 %    pet_plot_cluster_mask(cluster_info);
  %end

  if cluster_mask_state
     cluster_info = [];
  end

  if (getappdata(gcf,'ViewBootstrapRatio') == 0),	% plot brain lv

     h = findobj(gcf,'Tag','Threshold');  thresh = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','Threshold2');  thresh2 = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MaxValue');   max_blv = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MinValue');   min_blv = str2num(get(h,'String'));

     if isempty(max_blv) | isempty(min_blv) | isempty(thresh) | isempty(thresh2) | ...
	   max_blv < thresh | min_blv > thresh2

        msg = 'ERROR: Invalid threshold.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        set(fig_hdl,'Pointer',old_pointer);
	return;
     end;

     switch action
       case {0}
          pet_plot_brainlv(0,PLSresultFile,0,lv_idx,0,[],cluster_info,update);
       case {1}
          pet_plot_brainlv(0,PLSresultFile,0,lv_idx,1,[],cluster_info,update);
     end

  else							% plot bootstrap ratio

     h = findobj(gcf,'Tag','BSThreshold');
     thresh_ratio = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','BSThreshold2'); 
     thresh_ratio2 = str2num(get(h,'String')); 
     h = findobj(gcf,'Tag','MaxRatio'); max_ratio = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MinRatio'); min_ratio = str2num(get(h,'String'));

     if isempty(max_ratio) | isempty(min_ratio) | isempty(thresh_ratio) | isempty(thresh_ratio2) | ...
	   max_ratio < thresh_ratio | min_ratio > thresh_ratio2

        msg = 'ERROR: Invalid threshold.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        set(fig_hdl,'Pointer',old_pointer);
	return;
     end;;

     range = [min_ratio max_ratio];
     switch action
       case {0}
          pet_plot_brainlv(1,PLSresultFile,0,lv_idx,0,[],cluster_info,update);
       case {1}
          pet_plot_brainlv(1,PLSresultFile,0,lv_idx,1,[],cluster_info,update);
     end;

  end;

  if ~action
     setting = getappdata(gcf,'setting');

     if exist('orient','var') | isempty(setting) | ~isfield(setting,'origin')
        setting.origin = getappdata(gcf,'STOrigin');
     else
        setappdata(gcf,'STOrigin',setting.origin);
        setappdata(gcf,'Origin',setting.origin);
     end;

     setting.lv_idx = lv_idx;
     setting.rot_amount = getappdata(gcf,'RotateAmount');
     setting.rescale = get(findobj(gcf,'Tag','RESCALECheckbox'),'value');  

     if (getappdata(gcf,'ViewBootstrapRatio') == 0),	% plot brain lv
        setting.thresh{lv_idx} = str2num(get(findobj(gcf,'Tag','Threshold'),'String'));
        setting.thresh2{lv_idx} = str2num(get(findobj(gcf,'Tag','Threshold2'),'String'));
        setting.min_blv{lv_idx} = min_blv;
        setting.max_blv{lv_idx} = max_blv;
     else							% plot bootstrap ratio
        setting.bs_thresh{lv_idx} = str2num(get(findobj(gcf,'Tag','BSThreshold'),'String'));
        setting.bs_thresh2{lv_idx} = str2num(get(findobj(gcf,'Tag','BSThreshold2'),'String'));
        setting.min_ratio{lv_idx} = min_ratio;
        setting.max_ratio{lv_idx} = max_ratio;
     end

     setappdata(gcf,'setting',setting);
  end

  %  create / or re-create xhair
  %
  ax = getappdata(gcf,'BlvAxes');
  p_img = getappdata(gcf,'p_img');

  if isempty(p_img)
     p_img = [-1 -1];
  end

  img_xhair = getappdata(gcf,'img_xhair');
  img_xhair = rri_xhair(p_img,img_xhair,ax);


      %%%%%%%%%%%     update xhair      %%%%%%%%%%%%

  h_img = findobj(gcf,'tag','BLVImg');
  img_xlim = get(h_img, 'xdata');
  img_ylim = get(h_img, 'ydata');
  img_lx = img_xhair.lx;
  img_ly = img_xhair.ly;

  set(img_lx,'xdata', img_xlim, 'ydata', [p_img(2) p_img(2)]);
  set(img_ly,'xdata', [p_img(1) p_img(1)], 'ydata', img_ylim);


  xhair_color = get(findobj(mainfig,'tag','XhairColorMenu'), 'user');
  set(img_xhair.lx, 'color', xhair_color);
  set(img_xhair.ly, 'color', xhair_color);

  setappdata(gcf,'img_xhair',img_xhair);


    %%%%%%%%%%%%%%%       moved before plot blv      %%%%%%%%%%%%%%%%%%

%  cluster_mask_state = get(findobj(gcf,'tag','ClusterMask'),'Userdata');

%  isbsr = getappdata(gcf,'ViewBootstrapRatio');
 % if isbsr
  %   cluster_info = getappdata(gcf, 'cluster_bsr');
%  else
 %    cluster_info = getappdata(gcf, 'cluster_blv');
  %end

%  if length(cluster_info) < curr_lv_idx
 %    cluster_info = [];
  %else
%     cluster_info = cluster_info{curr_lv_idx};
 % end

%  if ~isempty(cluster_info) & ~cluster_mask_state
 %    pet_plot_cluster_mask(cluster_info);
  %end

  % update the LV scores when needed

  scores_fig = getappdata(gcf,'ScorePlotHdl');

  if 1 % isempty(scores_fig)
      set(fig_hdl,'Pointer',old_pointer);
      return;
  else
      pet_plot_scores_ui('UPDATE_LV_SELECTION',scores_fig,lv_idx);
      set(scores_fig,'Pointer',old_pointer);
      set(fig_hdl,'Pointer',old_pointer);
  end;

  return;					% ShowResult


%--------------------------------------------------------------------------
function SelectPixel()

   h = findobj(gcbf,'Tag','LVIndexEdit');
   lv_idx = get(h,'Userdata');

   h = getappdata(gcbf,'BlvAxes');
   pos = round(get(h,'CurrentPoint'));
   pos_x = pos(1,1,1); pos_y = pos(1,2,1);

   slice_idx = getappdata(gcbf,'SliceIdx');
   img_width = getappdata(gcbf,'ImgWidth');
   img_height = getappdata(gcbf,'ImgHeight');
   rows_disp = getappdata(gcbf,'RowsDisp');
   cols_disp = getappdata(gcbf,'ColsDisp');
   rot_amount = getappdata(gcbf,'RotateAmount');
   origin = getappdata(gcbf,'Origin');
   voxel_size = getappdata(gcbf,'VoxelSize');

   col = floor((pos_x-1) / img_width) + 1;
   row = floor((pos_y-1) / img_height) + 1;
   if (col<1 | col>cols_disp | row<1 | row>rows_disp)
      return;
   end

   slice_num = slice_idx(col + (row-1)* cols_disp);

   slice_x = mod(pos_x, img_width);
   slice_y = mod(pos_y, img_height);
   if (slice_x==0), slice_x = img_width; end;
   if (slice_y==0), slice_y = img_height; end;

   %  Note:  Images are read row by row in MATLAB. The orientation of
   %         the image matrix is 90 degree different from the normal image
   %         orientation convention.
   %
   switch mod(rot_amount,4)
      case {0},					% 0 degree
         cur_x = slice_y;
         cur_y = img_width - slice_x + 1;
      case {1},					% 90 degree by default
         cur_x = slice_x;
         cur_y = slice_y;
      case {2},					% 180 degree
         cur_x = img_height - slice_y + 1;
         cur_y = slice_x;
      case {3},					% 270 degree
         cur_x = img_width - slice_x + 1;
         cur_y = img_height - slice_y + 1;
   end;

   if mod(rot_amount,2)
      coord_x = img_height - cur_y + 1;
      coord_y = cur_x;
      coord = (slice_num-1)*img_height*img_width + ...
		(coord_x-1)*img_width + coord_y;
   else
      coord_x = img_width - cur_y + 1;
      coord_y = cur_x;
      coord = (slice_num-1)*img_width*img_height + ...
		(coord_x-1)*img_height + coord_y;
   end

   setappdata(gcbf,'Coord',coord);

   %  update the brain LV value if needed
   %
   if (getappdata(gcbf,'ViewBootstrapRatio') == 0),

      brainlv = getappdata(gcbf,'BLVData');
      blv_coords = getappdata(gcbf,'BLVCoords');

      curr_blv = brainlv(:,lv_idx);
      coord_idx = find(blv_coords == coord);

      h = findobj(gcbf,'Tag','BLVValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         blv_value = curr_blv(coord_idx);
         set(h,'String',num2str(blv_value,'%9.6f'));
      end;

   else

      bs = getappdata(gcbf,'BSRatio');
      bs_coords = getappdata(gcbf,'BSRatioCoords');

      curr_bs = bs(:,lv_idx);
      coord_idx = find(bs_coords == coord);

      h = findobj(gcbf,'Tag','BSValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         bs_value = curr_bs(coord_idx);
         set(h,'String',num2str(bs_value,'%9.6f'));
      end;

   end;

    % display the current location.
    %
    if slice_num > 0

        if mod(rot_amount,2)
           cur_y = img_height - cur_y + 1;
        else
           cur_y = img_width - cur_y + 1;
        end

        xyz = [cur_x, cur_y, slice_num];
%        xyz_offset = [xyz(1)-origin(1) xyz(2)-origin(2) xyz(3)-origin(3)];
        xyz_offset = xyz - origin;
        xyz_mm = xyz_offset .* voxel_size;

%      if get(findobj(gcf, 'tag', 'XYZmmLabel'), 'value') == 2
 %        xyz_mm = mni2tal(xyz_mm);
  %    end

        h = findobj(gcbf,'Tag','XYZVoxel');
        set(h,'String',sprintf('%d %d %d',xyz));

        h = findobj(gcbf,'Tag','XYZmm');
        set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

    else

        xyz = [];

        h = findobj(gcbf,'Tag','XYZVoxel');
        set(h,'String','No slice here!');

        h = findobj(gcbf,'Tag','XYZmm');
        set(h,'String','');

        coord = -1;
        xyz = [-1 -1 -1];

    end

   setappdata(gcbf,'xyz',xyz);

   linkfig1 = getappdata(gcbf,'RF1PlotHdl');
   if ~isempty(linkfig1)			% do nothing as no response plot
      setappdata(gcbf,'actualHRF',0);
      set(findobj(linkfig1,'Tag','MessageLine'), 'string', '');
      figure(linkfig1); pet_plot_rf('NewCoord',coord,xyz);
   end;

   linkfig = getappdata(gcbf,'RFPlotHdl');
   if ~isempty(linkfig)			% do nothing as no response plot
      setappdata(gcbf,'actualHRF',1);
      set(findobj(linkfig,'Tag','MessageLine'), 'string', '');
      figure(linkfig); pet_plot_rf_task('NewCoord',coord,xyz);
   end;

   p_img = [pos_x pos_y];
   img_xhair = getappdata(gcbf,'img_xhair');
   img_xhair = rri_xhair(p_img,img_xhair);
   setappdata(gcbf,'img_xhair',img_xhair);
   setappdata(gcbf,'p_img',p_img);

   return; 					% SelectPixel


%--------------------------------------------------------------------------
function EditXYZ()

   fig = gcbf;
   img_xhair = getappdata(fig,'img_xhair');
   if isempty(img_xhair)
      fig = gcf;
   end

   xyz = str2num(get(findobj(fig,'tag','XYZVoxel'),'string'));

   if isempty(xyz) | ~isequal(size(xyz),[1 3])
      msg = 'XYZ should contain 3 numbers (X, Y, and Z)';
      set(findobj(fig,'Tag','MessageLine'),'String',msg);
      return;
   end

   st_dims = getappdata(fig,'STDims');

   rows_disp = getappdata(fig,'RowsDisp');
   cols_disp = getappdata(fig,'ColsDisp');
   img_width = getappdata(fig,'ImgWidth');
   img_height = getappdata(fig,'ImgHeight');
   rot_amount = getappdata(fig,'RotateAmount');

   switch mod(rot_amount,4)
      case {0,2},
         if ( xyz(1)<1 | xyz(2)<1 | xyz(2)>img_width | xyz(1)>img_height )
            msg = 'Invalid number in X, Y, or Z';
            set(findobj(fig,'Tag','MessageLine'),'String',msg);
            return;
         end
      case {1,3},
         if ( xyz(1)<1 | xyz(2)<1 | xyz(1)>img_width | xyz(2)>img_height )
            msg = 'Invalid number in X, Y, or Z';
            set(findobj(fig,'Tag','MessageLine'),'String',msg);
            return;
         end
   end

   org_z = xyz(3);
   org_y = ceil(org_z/cols_disp) - 1;
   org_x = org_z - org_y*cols_disp - 1;

   org_x = org_x * img_width;
   org_y = org_y * img_height;

   if ~isempty(org_x) & ~isempty(org_y)
      switch mod(rot_amount,4)
         case {0},
            cur_x = xyz(2) + org_x;
            cur_y = xyz(1) + org_y;
         case {1},
            cur_x = xyz(1) + org_x;
            cur_y = img_height - xyz(2) + 1 + org_y;
         case {2},
            cur_x = img_width - xyz(2) + 1 + org_x;
            cur_y = img_height - xyz(1) + 1 + org_y;
         case {3},
            cur_x = img_width - xyz(1) + 1 + org_x;
            cur_y = xyz(2) + org_y;
      end
   end


   pos_x = cur_x;
   pos_y = cur_y;


   h = findobj(fig,'Tag','LVIndexEdit');
   lv_idx = get(h,'Userdata');

   slice_idx = getappdata(fig,'SliceIdx');
   rot_amount = getappdata(fig,'RotateAmount');
   origin = getappdata(fig,'Origin');
   voxel_size = getappdata(fig,'VoxelSize');

   col = floor((pos_x-1) / img_width) + 1;
   row = floor((pos_y-1) / img_height) + 1;
   if (col<1 | col>cols_disp | row<1 | row>rows_disp)
      msg = 'Invalid number in X, Y, or Z';
      set(findobj(fig,'Tag','MessageLine'),'String',msg);
      return;
   end

   slice_num = slice_idx(col + (row-1)* cols_disp);

   slice_x = mod(pos_x, img_width);
   slice_y = mod(pos_y, img_height);
   if (slice_x==0), slice_x = img_width; end;
   if (slice_y==0), slice_y = img_height; end;

   %  Note:  Images are read row by row in MATLAB. The orientation of
   %         the image matrix is 90 degree different from the normal image
   %         orientation convention.
   %
   switch mod(rot_amount,4)
      case {0},					% 0 degree
         cur_x = slice_y;
         cur_y = img_width - slice_x + 1;
      case {1},					% 90 degree by default
         cur_x = slice_x;
         cur_y = slice_y;
      case {2},					% 180 degree
         cur_x = img_height - slice_y + 1;
         cur_y = slice_x;
      case {3},					% 270 degree
         cur_x = img_width - slice_x + 1;
         cur_y = img_height - slice_y + 1;
   end;

   if mod(rot_amount,2)
      coord_x = img_height - cur_y + 1;
      coord_y = cur_x;
      coord = (slice_num-1)*img_height*img_width + ...
		(coord_x-1)*img_width + coord_y;
   else
      coord_x = img_width - cur_y + 1;
      coord_y = cur_x;
      coord = (slice_num-1)*img_width*img_height + ...
		(coord_x-1)*img_height + coord_y;
   end

   setappdata(fig,'Coord',coord);

   %  update the brain LV value if needed
   %
   if (getappdata(fig,'ViewBootstrapRatio') == 0),

      brainlv = getappdata(fig,'BLVData');
      blv_coords = getappdata(fig,'BLVCoords');

      curr_blv = brainlv(:,lv_idx);
      coord_idx = find(blv_coords == coord);

      h = findobj(fig,'Tag','BLVValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         blv_value = curr_blv(coord_idx);
         set(h,'String',num2str(blv_value,'%9.6f'));
      end;

   else

      bs = getappdata(fig,'BSRatio');
      bs_coords = getappdata(fig,'BSRatioCoords');

      curr_bs = bs(:,lv_idx);
      coord_idx = find(bs_coords == coord);

      h = findobj(fig,'Tag','BSValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         bs_value = curr_bs(coord_idx);
         set(h,'String',num2str(bs_value,'%9.6f'));
      end;

   end;

    % display the current location.
    %
    if slice_num > 0

        if mod(rot_amount,2)
           cur_y = img_height - cur_y + 1;
        else
           cur_y = img_width - cur_y + 1;
        end

        xyz = [cur_x, cur_y, slice_num];
%        xyz_offset = [xyz(1)-origin(1) xyz(2)-origin(2) xyz(3)-origin(3)];
        xyz_offset = xyz - origin;
        xyz_mm = xyz_offset .* voxel_size;

%      if get(findobj(fig, 'tag', 'XYZmmLabel'), 'value') == 2
 %        xyz_mm = mni2tal(xyz_mm);
  %    end

        h = findobj(fig,'Tag','XYZVoxel');
        set(h,'String',sprintf('%d %d %d',xyz));

        h = findobj(fig,'Tag','XYZmm');
        set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

    else

        xyz = [];

        h = findobj(fig,'Tag','XYZVoxel');
        set(h,'String','No slice here!');

        h = findobj(fig,'Tag','XYZmm');
        set(h,'String','');

        coord = -1;
        xyz = [-1 -1 -1];

    end

   setappdata(fig,'xyz',xyz);

   linkfig1 = getappdata(fig,'RF1PlotHdl');
   if ~isempty(linkfig1)			% do nothing as no response plot
      setappdata(fig,'actualHRF',0);
      set(findobj(linkfig1,'Tag','MessageLine'), 'string', '');
      figure(linkfig1); pet_plot_rf('NewCoord',coord,xyz);
   end;

   linkfig = getappdata(fig,'RFPlotHdl');
   if ~isempty(linkfig)			% do nothing as no response plot
      setappdata(fig,'actualHRF',1);
      set(findobj(linkfig,'Tag','MessageLine'), 'string', '');
      figure(linkfig); pet_plot_rf_task('NewCoord',coord,xyz);
   end;

   p_img = [pos_x pos_y];
   img_xhair = getappdata(fig,'img_xhair');
   img_xhair = rri_xhair(p_img,img_xhair);
   setappdata(fig,'img_xhair',img_xhair);
   setappdata(fig,'p_img',p_img);

   return; 					% EditXYZ


%--------------------------------------------------------------------------
function RescaleBnPress()

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   set_blv_fields(lv_idx);
   EditXYZ;

   set(gcf,'Pointer',old_pointer);

   return;					% RescaleBnPress


%-------------------------------------------------------------------------
%
function OpenEigenPlot()

   num_lv = getappdata(gcf,'NumLVs');

   eigen_plot = getappdata(gcbf,'EigenPlotHdl');
   if ~isempty(eigen_plot) & ishandle(eigen_plot)
      msg = 'ERROR: Singular Values are already been plotted';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   h = findobj(gcbf,'Tag','ResultFile');
   PLSresultFile = get(h,'UserData');

   load(PLSresultFile);

   if exist('result','var')
      eigen.s = result.s;

      if isfield(result,'perm_result')
         eigen.perm_result = result.perm_result;
      else
         eigen.perm_result = '';
      end

      if isfield(result,'perm_splithalf')
         eigen.perm_splithalf = result.perm_splithalf;
      else
         eigen.perm_splithalf = '';
      end
   else
      eigen.s = s;
      eigen.perm_result = perm_result;
      eigen.perm_splithalf = '';
   end

   c = findobj(gcbf,'Tag','OpenContrastWindow');
   eigen_fig = ...
      rri_plot_eigen_ui({eigen.s, eigen.perm_result, eigen.perm_splithalf, strcmpi(get(c,'Visible'),'on')});

   link_info.hdl = gcbf;
   link_info.name = 'EigenPlotHdl';
   setappdata(eigen_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'EigenPlotHdl',eigen_fig);

   return;					% OpenEigenPlot


%-------------------------------------------------------------------------
%
function OpenScoresPlot(p)

   score_fig = pet_plot_scores_ui(p);

   link_info.hdl = gcbf;
   link_info.name = 'ScorePlotHdl';
   setappdata(score_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'ScorePlotHdl',score_fig);

   return;


%-------------------------------------------------------------------------
%
function OpenDatamatcorrsPlot

   datamatcorrs_fig = getappdata(gcbf,'DatamatcorrsPlotHdl');
   if ~isempty(datamatcorrs_fig) & ishandle(datamatcorrs_fig)
      msg = 'ERROR: Datamat Correlations Plot has already been plotted';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   datamatcorrs_fig = pet_plot_datamatcorrs;

   link_info.hdl = gcbf;
   link_info.name = 'DatamatcorrsPlotHdl';
   setappdata(datamatcorrs_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'DatamatcorrsPlotHdl',datamatcorrs_fig);

   return;


%-------------------------------------------------------------------------
%
function MultipleVoxel

   main_fig = gcf;
   PLSresultFile = get(findobj(main_fig,'Tag','ResultFile'),'userdata');
%   PLSbehavdataFile = strrep(PLSresultFile, 'result.mat', 'behavdata.txt');

   load(PLSresultFile);

   %  get input filename
   %
   [fn,pn] = rri_selectfile('*.*','Please select a voxel location file');
   if (pn == 0), return; end;
   voxel_file = fullfile(pn, fn);

   if ~exist(voxel_file,'file')
      msg = 'Voxel file does not exist';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   xyz = load(voxel_file);

   if isempty(xyz) | size(xyz,2) ~= 3
      msg = 'Voxel file should contain [X Y Z] for each row';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   %  get output filename
   %
   pattern = ...
      ['<ONLY INPUT PREFIX>*_PET_grp1_voxeldata.txt'];
   [fn,pn] = rri_selectfile(pattern,'Please enter a prefix of saving files');
   if (pn == 0), return; end;

   fn = strrep(fn,'_PET_grp1_voxeldata.txt','');

   [tmp fn] = fileparts(fn);


   msg = 'If you would like to use average intensity of the neighborhood voxels for intensity of voxels in the inputted voxel location file, please enter neighborhood size that is the number of voxels from inputted voxel: ';
   num_lv = str2num(get(findobj(gcf,'Tag','LVNumberEdit'),'string'));
   datamat_files = getappdata(gcf,'DatamatFileList');
   method = getappdata(gcf,'method');
   holdoffresidual = 1;

   if holdoffresidual
      tmp = inputdlg({msg}, 'Questions', 1, {'0'});
   elseif isempty(findstr(datamat_files{1}, 'sessiondata.mat')) | ...
	~exist('method','var')
      tmp = inputdlg({msg}, 'Questions', 1, {'0'});
   elseif isequal(method,2) | isequal(method,5) | isequal(method,6)
      tmp = inputdlg({msg}, 'Questions', 1, {'0'});
   elseif isequal(method,3) | isequal(method,4)
      tmp = inputdlg({msg}, 'Questions', 1, {'0'});
   else
      msg2 = 'If you also want to export Residualized Data, please enter 1 below. Otherwise, Residualized Data will not be exported. ';
      tmp = inputdlg({msg, msg2}, 'Questions', 1, {'0', '0'});
   end

   if isempty(tmp)
      neighbor_size = 0;
      export_resid = 0;
   elseif length(tmp) < 2
      neighbor_size = round(str2num(tmp{1}));
      export_resid = 0;
   else
      neighbor_size = round(str2num(tmp{1}));
      export_resid = round(str2num(tmp{2}));
   end

   if isempty(neighbor_size) | ~isnumeric(neighbor_size)
      neighbor_size = 0;
   end

   if isempty(export_resid) | ~isnumeric(export_resid)
      export_resid = 0;
   end


   old_pointer = get(main_fig,'Pointer');
   set(main_fig,'Pointer','watch');
   msg = 'Extracting voxel, please wait ...';
   h_wait = rri_wait_box(msg,[0.4 0.1]);

   result_file = get(findobj(gcbf,'tag','ResultFile'),'UserData');
   xyz = xyzmm2xyz(xyz, result_file);

   %  get datamat etc.
   %
   datamat_files = getappdata(main_fig,'DatamatFileList');
   load(datamat_files{1},'session_info')
   cond_selection = getappdata(main_fig,'cond_selection');

   if isempty(cond_selection)
      cond_selection = ones(1,session_info.num_conditions);
   end

   [tmp,newdata_lst,newcoords,dims] = ...
	pet_get_common(datamat_files, ones(1,session_info.num_conditions));

   [tmp,all_newdata_lst] = ...
	pet_get_common(datamat_files, cond_selection);

   dxyz=ones(size(xyz,1),1)*dims([1 2 4]);
   dxyz=dxyz-xyz;

   if any(xyz(:)<=0) | any(dxyz(:)<0)
      close(h_wait);
      set(main_fig,'Pointer',old_pointer);

      msg = '[X Y Z] in voxel file should be within dimension';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   %  get requested coords
   %
   coords = rri_xyz2coord(xyz, dims);	% length(coords) means num of voxel

   %  check up the requested coords
   %
   outbrain = [];
   coord_idx = [];

   for v = 1:length(coords)
      tmp = find(newcoords == coords(v));

      if isempty(tmp)
         outbrain = [outbrain v];
      else
         coord_idx = [coord_idx tmp];
      end
   end

   %  report all the voxels that are out of brain and quit
   %
   if ~isempty(outbrain)
      msg1='Please remove the following entry(s) of the voxel location file and try again, because they are out of the brain: ';
      msg2=num2str(outbrain);
      msg={msg1;'';msg2};
      msgbox(msg,'Error');
      close(h_wait);
      set(main_fig,'Pointer',old_pointer);
      return;
   end


      CurrLVIdx = getappdata(main_fig,'CurrLVIdx');


   all_behavdata = [];

   %  export data in those coords to output files
   %
   for g = 1:length(newdata_lst)
      behavdata = [];
      all_grp_behavdata = [];
      for v = 1:length(coords)
%         coord_idx = find(newcoords == coords(v));


            if neighbor_size > 0

               %  Get neighborhood XYZs
               %
               xyz = rri_coord2xyz(coords(v), dims);

               x1 = xyz(1) - neighbor_size;
               if x1 < 1, x1 = 1; end;

               x2 = xyz(1) + neighbor_size;
               if x2 > dims(1), x2 = dims(1); end;

               y1 = xyz(2) - neighbor_size;
               if y1 < 1, y1 = 1; end;

               y2 = xyz(2) + neighbor_size;
               if y2 > dims(2), y2 = dims(2); end;

               z1 = xyz(3) - neighbor_size;
               if z1 < 1, z1 = 1; end;

               z2 = xyz(3) + neighbor_size;
               if z2 > dims(4), z2 = dims(4); end;

               %  Get neighborhood coords relative to whole volume
               %
               neighbor_coord = [];

               for k = z1:z2
                  for j=y1:y2
                     for i=x1:x2
                        neighbor_coord = [neighbor_coord, rri_xyz2coord([i j k], dims)];
                     end
                  end
               end

               %  If "Cluster Mask" is checked, cluster masked voxels will be used
               %  as a criteria to select surrounding voxels
               %
               isbsr = getappdata(main_fig,'ViewBootstrapRatio');

               if isbsr
                  cluster_info = getappdata(main_fig, 'cluster_bsr');
               else
                  cluster_info = getappdata(main_fig, 'cluster_blv');
               end

               %  Get cluster voxels coords relative to whole volume
               %
               if length(cluster_info) < CurrLVIdx
                  cluster_info = [];
               else
                  cluster_info = cluster_info{CurrLVIdx};
                  cluster_info = cluster_info.data{1}.idx;
               end

               %  If "Bootstrap" is computed, voxels that meet the bootstrap ratio
               %  threshold will be used as a criteria to select surrounding voxels
               %
               BSThreshold = getappdata(main_fig,'BSThreshold');
               BSThreshold2 = getappdata(main_fig,'BSThreshold2');

               if ~isempty(BSThreshold)
                  BSRatio = getappdata(main_fig,'BSRatio');
                  BSRatio = BSRatio(:,CurrLVIdx);

                  all_voxel = zeros(1,prod(dims));
                  all_voxel(newcoords) = (BSRatio > BSThreshold) | (BSRatio < BSThreshold2);
                  bsridx = find(all_voxel);
               else
                  bsridx = [];
               end

               %  Only including surrounding voxels that meet the bootstrap ratio
               %  threshold, or are part of cluster masked voxels
               %
               bsr_cluster_coords = unique([cluster_info bsridx coords(v)]);

               %  Intersect of neighborhood coord "neighbor_coord" and 
               %  "bsr_cluster_coords"
               %
               neighbor_coord = intersect(neighbor_coord, bsr_cluster_coords);

            else

               neighbor_coord = coords(v);

            end;		% if neighbor_size > 0

            %  find out neighborhood indices in st_datamat
            %
            [tmp ncoord_idx{v}] = intersect(newcoords, neighbor_coord);


         tmp = mean(newdata_lst{g}(:,ncoord_idx{v}),2);
         all_tmp = mean(all_newdata_lst{g}(:,ncoord_idx{v}),2);
         behavdata = [behavdata tmp];
         all_grp_behavdata = [all_grp_behavdata all_tmp];
      end

      behavdata_file = fullfile(pn,sprintf('%s_PET_grp%d_voxeldata.txt',fn,g));
      behavdata = double(behavdata);
      save (behavdata_file, '-ascii', 'behavdata');

      all_behavdata = [all_behavdata; all_grp_behavdata];
   end

   behavdata = double(all_behavdata);

   if export_resid

      %  Calculate residual
      %
      dlv = result.v;
      num_subj_lst = result.num_subj_lst;
      num_cond = result.num_conditions;

      designlv_expanded = [];

      for g = 1:length(num_subj_lst)
         tmp = rri_expandvec(dlv(1:num_cond,:), num_subj_lst(g));
         designlv_expanded = [designlv_expanded; tmp];
         dlv(1:num_cond,:) = [];
      end

      for lv = 2:num_lv
         newdata = behavdata;

         for i = 1:lv-1
            newdata = residualize(designlv_expanded(:,i), newdata);
         end

         PLSbehavdataFile = fullfile(pn,sprintf('%s_PETvoxeldata_residLV%d.txt',fn,lv));
         save (PLSbehavdataFile, '-ascii', 'newdata');
      end

      PLSbehavdataFile = fullfile(pn,sprintf('%s_PETvoxeldata.txt',fn));
      save (PLSbehavdataFile, '-ascii', 'behavdata');
   else
      PLSbehavdataFile = fullfile(pn,sprintf('%s_PETvoxeldata.txt',fn));
      save (PLSbehavdataFile, '-ascii', 'behavdata');
   end

   close(h_wait);
   set(main_fig,'Pointer',old_pointer);

   return;						% MultipleVoxel


%-------------------------------------------------------------------------
%
function MultipleCorrs

   main_fig = gcf;
   PLSresultFile = get(findobj(main_fig,'Tag','ResultFile'),'userdata');

   %  get input filename
   %
   [fn,pn] = rri_selectfile('*.*','Please select a voxel location file');
   if (pn == 0), return; end;
   voxel_file = fullfile(pn, fn);

   if ~exist(voxel_file,'file')
      msg = 'Voxel file does not exist';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   xyz = load(voxel_file);

   if isempty(xyz) | size(xyz,2) ~= 3
      msg = 'Voxel file should contain [X Y Z] for each row';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   %  get output filename
   %
   pattern = ...
      ['<ONLY INPUT PREFIX>*_PET_grp1_corrsdata.txt'];
   [fn,pn] = rri_selectfile(pattern,'Please enter a prefix of saving files');
   if (pn == 0), return; end;

   fn = strrep(fn,'_PET_grp1_corrsdata.txt','');

   [tmp fn] = fileparts(fn);


   old_pointer = get(main_fig,'Pointer');
   set(main_fig,'Pointer','watch');
   msg = 'Extracting corrs, please wait ...';
   h_wait = rri_wait_box(msg,[0.4 0.1]);

   result_file = get(findobj(gcbf,'tag','ResultFile'),'UserData');
   xyz = xyzmm2xyz(xyz, result_file);

   %  get datamat etc.
   %
   datamat_files = getappdata(main_fig,'DatamatFileList');
   load(datamat_files{1},'session_info')
   cond_selection = getappdata(main_fig,'cond_selection');

   if isempty(cond_selection)
      cond_selection = ones(1,session_info.num_conditions);
   end


   load(result_file);

   if exist('result','var')
      newdata_lst = result.datamatcorrs_lst;
   else
      newdata_lst = datamatcorrs_lst;
   end

   dxyz=ones(size(xyz,1),1)*dims([1 2 4]);
   dxyz=dxyz-xyz;

   if any(xyz(:)<=0) | any(dxyz(:)<0)
      close(h_wait);
      set(main_fig,'Pointer',old_pointer);

      msg = '[X Y Z] in voxel file should be within dimension';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   %  get requested coords
   %
   coords = rri_xyz2coord(xyz, dims);	% length(coords) means num of voxel

   %  check up the requested coords
   %
   outbrain = [];
   coord_idx = [];

   for v = 1:length(coords)
      tmp = find(newcoords == coords(v));

      if isempty(tmp)
         outbrain = [outbrain v];
      else
         coord_idx = [coord_idx tmp];
      end
   end

   %  report all the voxels that are out of brain and quit
   %
   if ~isempty(outbrain)
      msg1='Please remove the following entry(s) of the voxel location file and try again, because they are out of the brain: ';
      msg2=num2str(outbrain);
      msg={msg1;'';msg2};
      msgbox(msg,'Error');
      close(h_wait);
      set(main_fig,'Pointer',old_pointer);
      return;
   end


      CurrLVIdx = getappdata(main_fig,'CurrLVIdx');


   all_behavdata = [];

   %  export data in those coords to output files
   %
   for g = 1:length(newdata_lst)
      behavdata = [];
      all_grp_behavdata = [];
      for v = 1:length(coord_idx)
         tmp = newdata_lst{g}(:, coord_idx(v));
         behavdata = [behavdata tmp];
      end

      behavdata_file = fullfile(pn,sprintf('%s_PET_grp%d_corrsdata.txt',fn,g));
      behavdata = double(behavdata);
      save (behavdata_file, '-ascii', 'behavdata');
   end

   close(h_wait);
   set(main_fig,'Pointer',old_pointer);

   return;						% MultipleCorrs


%-------------------------------------------------------------------------
%
function orient

   pet_result_ui('Rotation',1);
   DeleteLinkedFigure;

   old_pointer = get(gcbf,'Pointer');
   set(gcbf,'Pointer','watch');

   old_dims = getappdata(gcf, 'STDims');
   old_dims = old_dims([1 2 4]);
   old_voxel_size = getappdata(gcf, 'STVoxelSize');
   old_origin = getappdata(gcf, 'STOrigin');
   old_coord = getappdata(gcf, 'BLVCoords');

   [orient, new_dims, new_voxel_size, new_origin, new_coord, new_pattern] ...
     = rri_xy_orient(old_dims, old_voxel_size, old_origin, old_coord);

   if isequal(orient, [1 2])
      set(gcbf,'Pointer',old_pointer);
      return;
   end

   new_dims = new_dims([1 2 3 3]);
   new_dims(3) = 1;

   setappdata(gcf, 'BLVCoords', new_coord);

   if isappdata(gcf, 'BSRatioCoords')
      setappdata(gcf, 'BSRatioCoords', new_coord);
   end

   setappdata(gcf, 'STDims', new_dims);
   setappdata(gcf, 'STVoxelSize', new_voxel_size);
   setappdata(gcf, 'STOrigin', new_origin);

   setappdata(gcf, 'Dims', new_dims);
   setappdata(gcf, 'VoxelSize', new_voxel_size);
   setappdata(gcf, 'Origin', new_origin);

   set(gcbf,'Pointer',old_pointer);

   p_img = getappdata(gcf,'p_img');
   if ~isempty(p_img)
      p_img = [-1 -1];
      setappdata(gcf,'p_img',p_img);
   end
   setappdata(gcf,'img_xhair',[]);

   %  apply new_pattern here
   %
   blv = getappdata(gcbf,'brainlv');
   blvdata = getappdata(gcbf,'BLVData');
   bs = getappdata(gcbf,'BSRatio');
   dims = getappdata(gcf,'STDims');

   if ~isempty(blv)
      blv = rri_xy_orient_data(blv, old_coord, new_coord, dims, new_pattern);

      is_rescale = get(findobj(gcf,'Tag','RESCALECheckbox'),'value');

      if is_rescale
         s = getappdata(gcf,'s');
         for i=1:length(s)
            blvdata(:,i) = blv(:,i).*s(i);
         end
      else
         blvdata = blv;
      end

      setappdata(gcf,'brainlv',blv);
      setappdata(gcf,'BLVData',blvdata);
   end

   if ~isempty(bs)
      bs = rri_xy_orient_data(bs, old_coord, new_coord, dims, new_pattern);
      setappdata(gcf,'BSRatio',bs);
   end

   set(findobj(gcf,'Tag','PlotSagittalView'),'enable','off');
   set(findobj(gcf,'Tag','PlotCoronalView'),'enable','off');
   set(findobj(gcf,'Tag','Plot3View'),'enable','off');

   orient_pattern = getappdata(gcf,'orient_pattern');
   origin_pattern = getappdata(gcf,'origin_pattern');

   setappdata(gcf, 'orient_pattern', new_pattern);

   if isempty(origin_pattern)
      origin_pattern = new_pattern;
   else
      origin_pattern = origin_pattern(new_pattern);
   end

   setappdata(gcf, 'origin_pattern', origin_pattern);

   ShowResult(0,0,1);

   setting = getappdata(gcf,'setting');

   setting.origin = new_origin;
   setting.orient.dims = new_dims;
   setting.orient.voxel_size = new_voxel_size;
   setting.orient.coords = new_coord;
   setting.orient.pattern = origin_pattern;

   setappdata(gcf,'setting',setting);

   return;


%-------------------------------------------------------------------------
%
function EditXYZmm

      xyz_mm = str2num(get(findobj(gcbf,'tag','XYZmm'),'string'));

      if isempty(xyz_mm) | ~isequal(size(xyz_mm),[1 3])
         msg = 'XYZ(mm) should contain 3 numbers (X, Y, and Z)';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end

%   if get(findobj(gcf, 'tag', 'XYZmmLabel'), 'value') == 2
 %     xyz_mm = tal2mni(xyz_mm);
  % end

      origin = getappdata(gcf,'Origin');
      voxel_size = getappdata(gcf,'VoxelSize');

      xyz_offset = xyz_mm ./ voxel_size;
      xyz = round(xyz_offset + origin);

      set(findobj(gcbf,'tag','XYZVoxel'), 'string', num2str(xyz));
      EditXYZ;

   return;


%-------------------------------------------------------------------------
%
function XYZmmLabel

   xyz_mm = str2num(get(findobj(gcf, 'tag', 'XYZmm'), 'string'));

   if isempty(xyz_mm) | ~isequal(size(xyz_mm),[1 3])
      msg = 'XYZ(mm) should contain 3 numbers (X, Y, and Z)';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   status = get(findobj(gcf, 'tag', 'XYZmmLabel'), 'value');
   userdata = get(findobj(gcf, 'tag', 'XYZmmLabel'), 'user');

   if status == userdata
      return;
   end

   origin = getappdata(gcf,'Origin');
   voxel_size = getappdata(gcf,'VoxelSize');

   if status == 1		% tal2mni
      xyz_mm = tal2mni(xyz_mm);
      
      xyz_offset = round(xyz_mm ./ voxel_size);
      xyz = xyz_offset + origin;
      
      xyz_offset = xyz - origin;
      xyz_mm = xyz_offset .* voxel_size;
      set(findobj(gcf, 'tag', 'XYZmmLabel'), 'user', 1);
   elseif status == 2		% mni2tal
      xyz_mm = mni2tal(xyz_mm);
      set(findobj(gcf, 'tag', 'XYZmmLabel'), 'user', 2);
   end

   h = findobj(gcbf,'Tag','XYZmm');
   set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

   return;


%-------------------------------------------------------------------------
%
function OpenBrainScoresPlot()

   taskpls_fig = pet_plot_taskpls_bs;

   link_info.hdl = gcbf;
   link_info.name = 'taskplsHdl';

   if ishandle(taskpls_fig)
      setappdata(taskpls_fig,'LinkFigureInfo',link_info);
      setappdata(gcbf,'taskplsHdl',taskpls_fig);
   end

   return;					% OpenBrainScoresPlot

