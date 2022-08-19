function fig = fmri_result_3v_ui(action,varargin)

   if ~exist('action','var') | isempty(action)

      [PLSresultFile,PLSresultFilePath] =  ...
                        rri_selectfile('*_fMRIresult.mat','Open PLS Result');
      if (PLSresultFilePath == 0), return; end;

      PLSResultFile = fullfile(PLSresultFilePath,PLSresultFile);

   elseif exist('action','var') & iscell(action)

      PLSResultFile = action{1};

   end

   if ~exist('action','var') | ~ischar(action)

      msg = 'Loading PLS results ...    Please wait!';
      h = rri_wait_box(msg, [0.5 0.1]);

      fig_h = init(PLSResultFile);

      setappdata(gcf,'CallingFigure',gcbf); 
      set(gcbf,'visible','off');

      rot_amount = load_pls_result;
%      fmri_result_3v_ui('Rotation', rot_amount);
      ShowResult(0,0);

      if (nargout > 0),
        fig = fig_h;
      end;

      delete(h);

      EditXYZ;

      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   if (strcmp(action,'PlotBnPress'))
     p_img = getappdata(gcf,'p_img');
     if ~isempty(p_img)
        p_img = [-1 -1];
        setappdata(gcf,'p_img',p_img);
     end
     setappdata(gcf,'img_xhair',[]);

     ShowResult(0,0);                % display brainlv inside the Plot BLV figure
%     EditXYZ;
   elseif (strcmp(action,'EditFirstSlice'))
     p_img = getappdata(gcf,'p_img');
     if ~isempty(p_img)
        p_img = [-1 -1];
        setappdata(gcf,'p_img',p_img);
     end
     setappdata(gcf,'img_xhair',[]);

     ShowResult(0,0);
   elseif (strcmp(action,'EditStep'))
     p_img = getappdata(gcf,'p_img');
     if ~isempty(p_img)
        p_img = [-1 -1];
        setappdata(gcf,'p_img',p_img);
     end
     setappdata(gcf,'img_xhair',[]);

     ShowResult(0,0);
   elseif (strcmp(action,'EditLastSlice'))
     p_img = getappdata(gcf,'p_img');
     if ~isempty(p_img)
        p_img = [-1 -1];
        setappdata(gcf,'p_img',p_img);
     end
     setappdata(gcf,'img_xhair',[]);

     ShowResult(0,0);
   elseif (strcmp(action,'PlotOnNewFigure'))
     ShowResult(1,0);                % display brainlv in a new figure;
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
   elseif (strcmp(action,'EditLV'))
     EditLV;
     set(findobj(gcbf,'tag','ClusterMask'),'Userdata',1,'check','off');
   elseif (strcmp(action,'EditLag'))
     EditLag;
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
   elseif (strcmp(action,'EditThresh'))
     set(findobj(gcbf,'tag','ClusterMask'),'Userdata',1,'check','off');
     isbsr = getappdata(gcbf,'ViewBootstrapRatio');
     if isappdata(gcbf,'cluster_blv') & ~isbsr
        rmappdata(gcbf,'cluster_blv');
     end
     if isappdata(gcbf,'cluster_bsr') & isbsr
        rmappdata(gcbf,'cluster_bsr');
     end
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
   elseif (strcmp(action,'SelectPixel'))
     SelectPixel;
   elseif (strcmp(action,'DeleteNewFigure'))
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         fmri_result_newfig_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'fmri_result_newfig_pos');
      catch
      end
   elseif (strcmp(action,'DeleteFigure'))
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         fmri_result_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'fmri_result_pos');
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
%               PLSresultFile = get(findobj(gcbf,'Tag','ResultFile'),'UserData');
 %              setting5 = setting;
  %             save(PLSresultFile, '-append', 'setting5');
            catch
               msg = 'Cannot save setting information';
               msgbox(msg,'ERROR','modal');
            end
         end
      end

      DeleteLinkedFigure;
      calling_fig = getappdata(gcf,'CallingFigure');
      set(calling_fig,'visible','on');
   elseif (strcmp(action,'OpenResponseFnPlot'))
     OpenResponseFnPlot;
   elseif (strcmp(action,'OpenCorrelationPlot'))
     OpenCorrelationPlot;
   elseif (strcmp(action,'OpenDatamatcorrsPlot'))
     OpenDatamatcorrsPlot;
   elseif (strcmp(action,'OpenScoresPlot'))
     bfm_plot_scores_ui(varargin{1});
   elseif (strcmp(action,'OpenDesignPlot'))
     OpenDesignPlot;
   elseif (strcmp(action,'OpenBrainScoresPlot'))
     OpenBrainScoresPlot;
   elseif (strcmp(action,'OpenTBrainScoresPlot'))
     OpenTBrainScoresPlot;
   elseif (strcmp(action,'OpenBrainCorrelationPlot'))
     OpenBrainCorrelationPlot;
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

     [tmp cluster_hdl] = fmri_cluster_report('LoadClusterReport',gcbf);

     if ishandle(cluster_hdl)
        link_info.hdl = gcbf;
        link_info.name = 'cluster_hdl';
        setappdata(cluster_hdl,'LinkFigureInfo',link_info);
        setappdata(gcbf,'cluster_hdl',cluster_hdl);
     end
   elseif (strcmp(action,'OpenClusterReport')) 
     OpenClusterReport;
   elseif (strcmp(action,'LoadBackgroundImage'))
     LoadBackgroundImage;
   elseif (strcmp(action,'SaveBackgroundImage'))
     SaveBackgroundImage;
   elseif (strcmp(action,'LoadResultFile'))
     LoadResultFile;
   elseif (strcmp(action,'SaveResultToIMG'))
     SaveResultToIMG(0);
   elseif (strcmp(action,'SaveDisplayToIMG'))
     SaveResultToIMG(1);
   elseif (strcmp(action,'PlotSagittalView'))
      PLSresultFile = get(findobj(gcf,'Tag','ResultFile'),'UserData');
      DeleteLinkedFigure;
      fmri_result_sa_ui({PLSresultFile,1})
   elseif (strcmp(action,'PlotCoronalView'))
      PLSresultFile = get(findobj(gcf,'Tag','ResultFile'),'UserData');
      DeleteLinkedFigure;
      fmri_result_sa_ui({PLSresultFile,0})
   elseif (strcmp(action,'CloseFigure'))
      CloseFigure;
   elseif (strcmp(action,'EditXYZ'))
      EditXYZ;
%      ShowResult(0,1);
   elseif (strcmp(action,'EditXYZmm'))
      EditXYZmm;
   elseif (strcmp(action,'XYZmmLabel'))
      XYZmmLabel;
   elseif (strcmp(action,'RescaleBnPress'))
     RescaleBnPress;
     ShowResult(0,1);
     EditXYZ;
   end;

   return;


%---------------------------------------------------------------------------
%
function h0 = init(PLSResultFile);

   setting5 = [];
   warning off;
   load(PLSResultFile, 'setting5');
   setting = setting5;
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
   fmri_result_pos = [];

   try
      load('pls_profile');
   catch 
   end

   if ~isempty(fmri_result_pos) & strcmp(save_setting_status,'on')

      pos = fmri_result_pos;

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
        'Name','fMRI BLV Plot', ...
        'NumberTitle','off', ...
   	'DoubleBuffer','on', ...
   	'MenuBar','none',...
   	'Position',pos, ...
   	'DeleteFcn','fmri_result_3v_ui(''DeleteFigure'')', ...
   	'Tag','PlotBrainLV');
   %

   x = .37;
   y = .1;
   w = .5;
   h = .85;

   pos = [x y w h];
   
   axes_h = axes('Parent',h0, ...				% axes
        'Units','normal', ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',[1 1 1], ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
	'visible', 'off', ...
   	'Tag','BlvAxes');

   x = x+w+.02;
   w = .04;

   pos = [x y w h];
   
   colorbar_h = axes('Parent',h0, ...				% c axes
        'Units','normal', ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','Colorbar');
   %

   x = .37;
   y = .95;
   w = .5;
   h = .04;

   pos = [x y w h];

   fnt = 0.6;

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','', ...
   	'Style','text', ...
   	'Tag','StructuralMapLabel');
%	'foregroundcolor',[1 0 0], ...

   %

   x = .03;
   y = .95;
   w = .09;
   h = .04;

   pos = [x y w h];

   fnt = 0.6;

   h1 = uicontrol('Parent',h0, ...
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
   w = .2;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
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

   h1 = uicontrol('Parent',h0, ...	
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

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','fmri_result_3v_ui(''EditLV'')', ...
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


   x = .05;
   y = y-h-.01;
   w = .08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lag index label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Lag Index:', ...
   	'Style','text', ...
   	'Tag','LagIndexLabel');

   x = x+w;
   y = y+.01;
   w = .05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lag index edit
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','fmri_result_3v_ui(''EditLag'')', ...
   	'Tag','LagIndexEdit');

   x = x+w;
   y = y-.01;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lag number label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','of', ...
   	'Style','text', ...
   	'Tag','LagNumberLabel');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lag number number text
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','LagNumberEdit');


   %  Slice Selection

   x = .03;
   y = .63;
   w = .26;
   h = .19;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
	'visible','off', ...
   	'Tag','SliceFrame');

   x = .05;
   y = .75;
   w = .12;
   h = .04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','First Slice:', ...
   	'Style','text', ...
	'visible','off', ...
   	'Tag','FirstSliceLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
	'visible','off', ...
   	'Tag','FirstSlice');
%   	'Callback','fmri_result_3v_ui(''EditFirstSlice'')', ...

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Step:', ...
   	'Style','text', ...
	'visible','off', ...
   	'Tag','StepLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
	'visible','off', ...
   	'Tag','SliceStep');
%   	'Callback','fmri_result_3v_ui(''EditStep'')', ...

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Last Slice:', ...
   	'Style','text', ...
	'visible','off', ...
   	'Tag','LastSliceLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
	'visible','off', ...
   	'Tag','LastSlice');
%   	'Callback','fmri_result_3v_ui(''EditLastSlice'')', ...


   slice_frame_h = 0.16;

   %  Brain LV

   x = .03;
   y = .3;
   w = .26;
   h = .34;

   y = y + slice_frame_h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','ThresholdFrame');

   x = .11;
   y = .61;
   w = .09;
   h = .04;

   y = y + slice_frame_h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
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
   y = .56;
   w = .12;

   y = y + slice_frame_h;

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
   	'String','Pos.Thresh:', ...
   	'Style','text', ...
   	'Tag','ThresholdLabel');

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
   	'Callback','fmri_result_3v_ui(''EditThresh'')', ...
   	'Tag','Threshold');

   x = .05;
   y = .52;
   w = .12;

   y = y + slice_frame_h;

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
   	'Callback','fmri_result_3v_ui(''EditThresh'')', ...
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

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
	'Visible','on', ...
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
   	'Tag','BLVValue');

   x = .05;
   y = y-h-.02;
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
   	'String','Max. Value:', ...
   	'Style','text', ...
   	'Tag','MaxValueLabel');

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
   	'Callback','fmri_result_3v_ui(''EditMax'')', ...
   	'Tag','MaxValue');

   x = .05;
   y = y-h-.02;
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
   	'String','Min. Value:', ...
   	'Style','text', ...
   	'Tag','MinValueLabel');

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
   	'Callback','fmri_result_3v_ui(''EditMin'')', ...
   	'Tag','MinValue');

   %

   x = .09;
   y = .61;
   w = .15;
   h = .04;

   y = y + slice_frame_h;

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
   	'String','Bootstrap Ratio', ...
   	'Style','text', ...
   	'Tag','BSRatioTitle');

   x = .05;
   y = .56;
   w = .12;

   y = y + slice_frame_h;

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
   	'Callback','fmri_result_3v_ui(''UpdatePValue'')', ...
   	'Tag','BSThreshold');

   x = .05;
   y = .52;
   w = .12;

   y = y + slice_frame_h;

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
   	'Callback','fmri_result_3v_ui(''UpdatePValue'')', ...
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
   	'Callback','fmri_result_3v_ui(''EditMax'')', ...
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
   	'Callback','fmri_result_3v_ui(''EditMin'')', ...
   	'Tag','MinRatio');

   %  Voxel Location

   x = .03;
   y = .16;
   w = .26;
   h = .12;

   y = y + slice_frame_h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','LocationFrame');

   x = .04;
   y = .22;
   w = .08;
   h = .04;

   y = y + slice_frame_h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','LagXYZ:', ...
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
   	'Callback','fmri_result_3v_ui(''EditXYZ'')');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
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
   	'Callback','fmri_result_3v_ui(''EditXYZ'')', ...
   	'Tag','XYZVoxel');

   x = .04;
   y = y-h-0.02;
   w = .08;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
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
%   	'Callback','fmri_result_3v_ui(''XYZmmLabel'')', ...

   x = x+w+0.01;
   w = .14;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
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
   	'Callback','fmri_result_3v_ui(''EditXYZmm'')', ...
   	'Tag','XYZmm');

   x = .05;
   y = .1;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'Callback','fmri_result_3v_ui(''PlotBnPress'')', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','PLOT', ...
   	'Tag','PLOTButton');

   x = .17;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'Callback','close(gcf);', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','AXIAL', ...
   	'Tag','EXITButton');

%   	'Callback','fmri_result_3v_ui(''CloseFigure'');', ...


   x = .05;
   y = .05;
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
	'Style','Check', ...
	'Value', 0, ...
	'Visible','Off', ...
   	'Callback','fmri_result_3v_ui(''RescaleBnPress'')', ...
   	'Tag','RESCALECheckbox');


   x = 0.01;
   y = 0;
   w = .5;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% Message Line
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
   h2 = uimenu(h_file, ...
           'Label','&Load Background Image', ...
   	   'Tag','LoadBGImage', ...
           'Callback','fmri_result_3v_ui(''LoadBackgroundImage'')'); 
   h2 = uimenu(h_file, ...
           'Label','Save brain region to IMG file', ...
   	   'Tag','SaveBGImage', ...
           'Callback','fmri_result_3v_ui(''SaveBackgroundImage'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Load PLS Result', ...
   	   'Tag','LoadPLSResult', ...
		'visible', 'off', ...
           'Callback','fmri_result_3v_ui(''LoadResultFile'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Save Current Display to the IMG files', ...
   	   'Tag','SaveDisplayToIMG', ...
           'Callback','fmri_result_3v_ui(''SaveDisplayToIMG'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Save BLV to the IMG files', ...
   	   'Tag','SaveResultToIMG', ...
           'Callback','fmri_result_3v_ui(''SaveResultToIMG'')'); 

   rri_file_menu(h0, 0);

   h2 = uimenu(h_file, ...
           'Label','&Close', ...
           'separator', 'on', ...
   	   'Tag','CloseFigure', ...
   	   'Callback','fmri_result_3v_ui(''CloseFigure'');');

   % Xhair submenu
   %
   h_xhair = uimenu('Parent',h0, 'Label','Crosshair');
   h2 = uimenu('Parent',h_xhair, ...
   	   'Label','Crosshair off', ...
	   'Userdata', 0, ...
           'Callback','pet_result_3v_ui(''crosshair'')', ...
   	   'Tag','XhairToggleMenu');
   h2 = uimenu('Parent',h_xhair, ...
   	   'Label','Color ...', ...
	   'Userdata', [1 0 0], ...
           'Callback','pet_result_3v_ui(''set_xhair_color'')', ...
   	   'Tag','XhairColorMenu');

   % Zoom submenu
   %
   h2 = uimenu('Parent',h0, ...
   	   'Label','&Zoom on', ...
	   'Userdata', 1, ...
           'Callback','fmri_result_3v_ui(''Zooming'')', ...
   	   'Tag','ZoomToggleMenu');

   % Rotate submenu
   %
   h_rot = uimenu('Parent',h0, ...
   	   'Label','&Image Rotation', ...
		'visible', 'off', ...
   	   'Tag','RotationMenu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&none', ...
   	   'Checked','on', ...
           'Callback','fmri_result_3v_ui(''Rotation'',1)', ...
   	   'Tag','Rotate0Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&90 degree', ...
   	   'Checked','off', ...
           'Callback','fmri_result_3v_ui(''Rotation'',2)', ...
   	   'Tag','Rotate90Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&180 degree', ...
   	   'Checked','off', ...
           'Callback','fmri_result_3v_ui(''Rotation'',3)', ...
   	   'Tag','Rotate180Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&270 degree', ...
   	   'Checked','off', ...
           'Callback','fmri_result_3v_ui(''Rotation'',0)', ...
   	   'Tag','Rotate270Menu');

   %  View submenu
   %
   h_view = uimenu('Parent',h0, ...
   	   'Label','&View', ...
   	   'Tag','ViewMenu', ...
   	   'Visible','on');
   h2 = uimenu('Parent',h_view, ...
           'visible','off', ...
   	   'Label','&View Brain LV', ...
	   'Userdata', 1, ...
           'Callback','fmri_result_3v_ui(''Toggle_View'')', ...
   	   'Tag','ViewToggleMenu');

   h2 = uimenu('Parent',h_view, ...
           'visible','off', ...
   	   'Label','View 41x48x35 Structural Label', ...
	   'Userdata', 0, ...
	   'check', 'off', ...
           'Callback','fmri_result_ui(''Toggle_Label'')', ...
   	   'Tag','LabelToggleMenu');

   load(PLSResultFile,'st_dims','st_origin','st_voxel_size');

   if isequal(st_dims,[41 48 1 35]) & isequal(st_origin,[21 29 14]) & isequal(st_voxel_size,[4 4 4])
      set(findobj(gcf,'Tag','LabelToggleMenu'),'visible','on');
   else
      set(findobj(gcf,'Tag','LabelToggleMenu'),'visible','off');
   end

   %  Window submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Windows', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','on');
   h2 = uimenu(h_pls, ...
           'Label','&Singular Values Plot', ...
     	   'Tag','OpenEigenPlot', ...
           'Callback','fmri_result_3v_ui(''OpenEigenPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Behavior LV and Behavior Scores Plot', ...
     	   'Tag','OpenBehavPlot', ...
           'Visible', 'off', ...
           'Callback','bfm_result_ui(''OpenScoresPlot'',0)');
   h2 = uimenu(h_pls, ...
           'Label','&Design Scores and LVs Plot', ...
     	   'Tag','OpenDesignPlot', ...
           'Visible', 'off', ...
           'Callback','fmri_result_3v_ui(''OpenDesignPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Task PLS Brain Scores with CI', ...
	   'Visible','off', ...
     	   'Tag','OpenTBrainScoresPlot', ...
           'Callback','fmri_result_3v_ui(''OpenTBrainScoresPlot'')');
   h2 = uimenu(h_pls, ...
           'Label','B&rain Scores vs. Behavior Data Plot', ...
     	   'Tag','OpenBrainPlot', ...
           'Visible', 'off', ...
           'Callback','bfm_result_ui(''OpenBrainPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Temporal Brain Scores Plot', ...
     	   'Tag','OpenBrainScoresPlot', ...
           'Callback','fmri_result_3v_ui(''OpenBrainScoresPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Temporal Brain Correlation Plot', ...
     	   'Tag','OpenBrainCorrelationPlot', ...
	   'visible','on', ...
           'Callback','fmri_result_3v_ui(''OpenBrainCorrelationPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Response Function Plot', ...
     	   'Tag','OpenRFPlot', ...
           'Callback','fmri_result_3v_ui(''OpenResponseFnPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Datamat Correlations Response', ...
     	   'Tag','OpenRF1Plot', ...
           'Callback','fmri_result_3v_ui(''OpenCorrelationPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Datamat Correlations Plot', ...
     	   'Tag','OpenDatamatcorrsPlot', ...
           'Callback','fmri_result_3v_ui(''OpenDatamatcorrsPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Multiple Voxels Extraction', ...
     	   'Tag','MultipleVoxel', ...
           'Callback','fmri_result_ui(''MultipleVoxel'')');
   h2 = uimenu(h_pls, ...
           'Label','&Contrasts Information', ...
     	   'Tag','OpenContrastWindow', ...
           'Callback','fmri_result_3v_ui(''OpenContrastWindow'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Create Brain LV &Figure', ...
	   'separator', 'on', ...
   	   'Tag','PlotNewFigure', ...
		'visible', 'off', ...
           'Callback','fmri_result_3v_ui(''PlotOnNewFigure'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Create Figure', ...
	   'separator', 'on', ...
           'Callback','rri_create_fig_3v'); 
   h2 = uimenu(h_pls, ...
           'Label','Axial View Plot', ...
	   'separator', 'on', ...
   	   'Tag','PlotAxialView', ...
           'Callback','close(gcf);'); 

   %  Report submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Report', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','on');
   h2 = uimenu(h_pls, ...
           'Label','&Set Cluster Report Options', ...
     	   'Tag','SetClusterReportOptions', ...
           'Callback','fmri_result_3v_ui(''SetClusterReportOptions'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Load Cluster Report', ...
     	   'Tag','LoadClsuterReport', ...
           'Callback','fmri_result_3v_ui(''LoadClusterReport'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Create Cluster Report', ...
     	   'Tag','OpenClusterReport', ...
           'Callback','fmri_result_3v_ui(''OpenClusterReport'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Cluster Mask', ...
	   'separator', 'on', ...
           'check', 'off', ...
	   'Userdata', 1, ...
   	   'Tag','ClusterMask', ...
           'Callback','fmri_result_3v_ui(''ClusterMask'')'); 

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
           'Tag', 'Help');
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','rri_helpfile_ui(''fmri_result_hlp.txt'',''How to use PLS RESULT'');', ...
	   'visible', 'off', ...
           'Tag', 'How');
   Hm_new = uimenu('Parent',Hm_topHelp, ...
           'Label', '&What''s new', ...
	   'Callback','rri_helpfile_ui(''whatsnew.txt'',''What''''s new'');', ...
           'Tag', 'New');
   Hm_about = uimenu('Parent',Hm_topHelp, ...
           'Label', '&About this program', ...
           'Tag', 'About', ...
           'CallBack', 'plsgui_version');

   set(gcf,'Name',sprintf('fMRI BLV Plot: %s',PLSResultFile));
   set(colorbar_h,'units','normal');

   setappdata(gcf,'Colorbar',colorbar_h);
   setappdata(gcf,'BlvAxes',axes_h);

   setappdata(gcf,'ClusterMaskSize',4);
   setappdata(gcf,'ClusterMinSize',5);
   setappdata(gcf,'ClusterMinDist',10);
   setappdata(gcf,'img_xhair',[]);

   if isempty(setting) | ~isfield(setting,'rescale')
      set(findobj(gcf,'Tag','RESCALECheckbox'),'value',0);
   else
      set(findobj(gcf,'Tag','RESCALECheckbox'),'value',setting.rescale);
   end;

   setappdata(gcf,'setting',setting);
   setappdata(gcf,'old_setting',setting);
   setappdata(gcf,'actualHRF',1);

   return;						% init


%---------------------------------------------------------------------------
%
function DeleteLinkedFigure()

   rf_plot = getappdata(gcbf,'RFPlotHdl');
   if ~isempty(rf_plot) & ishandle(rf_plot)
     delete(rf_plot);
   end;

   rf1_plot = getappdata(gcbf,'RF1PlotHdl');
   if ~isempty(rf1_plot) & ishandle(rf1_plot)
     delete(rf1_plot);
   end;

   rf_corr = getappdata(gcbf,'RFCorrPlotHdl');
   if ~isempty(rf_corr) & ishandle(rf_corr)
     delete(rf_corr);
   end;

   scores_fig = getappdata(gcbf,'ScorePlotHdl');
   if ~isempty(scores_fig)
     delete(scores_fig);
   end;

   bscores_fig = getappdata(gcbf,'BSPlotHdl');
   if ~isempty(bscores_fig) & ishandle(bscores_fig)
     delete(bscores_fig);
   end;

   taskpls_fig = getappdata(gcbf,'taskplsHdl');
   if ~isempty(taskpls_fig) & ishandle(taskpls_fig)
     delete(taskpls_fig);
   end;

   bcor_fig = getappdata(gcbf,'BcorPlotHdl');
   if ~isempty(bcor_fig) & ishandle(bcor_fig)
     delete(bcor_fig);
   end;

   eigen_fig = getappdata(gcbf,'EigenPlotHdl');
   if ~isempty(eigen_fig) & ishandle(eigen_fig)
     delete(eigen_fig);
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
   rri_changepath('fmriresult');

   if exist('result','var')
      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end

      if isfield(result,'perm_result')
         perm_result = result.perm_result;
         perm_result.s_prob = perm_result.sprob;
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
      subj_group = result.num_subj_lst;

      if ismember(method, [1 2])
         designlv = result.v;
      end

      if ismember(method, [3 5])
         behavlv = result.v;
      end

      if ismember(method, [4 6])
         ismultiblock = 1;
         designlv = result.TBv{1};
         behavlv = result.TBv{2};
      end
   end

   if exist('datamatcorrs_lst','var')
      setappdata(gcf,'isbehav',1);
      set(findobj(gcf,'tag','OpenRFPlot'), 'visible', 'on');
      set(findobj(gcf,'tag','OpenRF1Plot'), 'visible', 'on');
      set(findobj(gcf,'tag','OpenDatamatcorrsPlot'), 'visible', 'on');
      set(findobj(gcf,'tag','OpenBrainScoresPlot'), 'visible', 'off');
      set(findobj(gcf,'tag','OpenBrainCorrelationPlot'), 'visible', 'on');

      if exist('ismultiblock','var')
         set(findobj(gcf,'tag','OpenBrainScoresPlot'), 'visible', 'on');
      end
   else
      setappdata(gcf,'isbehav',0);
      set(findobj(gcf,'tag','OpenRFPlot'), 'visible', 'on');
      set(findobj(gcf,'tag','OpenRF1Plot'), 'visible', 'off');
      set(findobj(gcf,'tag','OpenDatamatcorrsPlot'), 'visible', 'off');
      set(findobj(gcf,'tag','OpenBrainScoresPlot'), 'visible', 'on');
      set(findobj(gcf,'tag','OpenBrainCorrelationPlot'), 'visible', 'off');
   end

   if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
   end

   num_slices = st_dims(4);
   if (num_slices > 10)
      slice_step = ceil(num_slices / 10);
   else
      slice_step = 1;
   end;

   setting = getappdata(gcf,'setting');

   if isempty(setting) | ~isfield(setting,'lag_idx')
      lag_idx = 0;
   else
      lag_idx = setting.lag_idx;
   end;

   if isempty(setting)
      lv_idx = 1;
      rot_amount = 1;
      first_slice = 1;
      last_slice = num_slices;
   else
      lv_idx = setting.lv_idx;
      rot_amount = setting.rot_amount;
      first_slice = setting.first_slice;
      slice_step = setting.slice_step;
      last_slice = setting.last_slice;
   end;

   num_lv = size(brainlv,2);
   num_lag = st_win_size - 1;

   if exist('behavlv','var') & exist('ismultiblock','var')
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'On');
   elseif exist('behavlv','var')
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'On');
   elseif exist('designlv','var')
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'Off');
   end

   h = findobj(gcf,'Tag','LVIndexEdit');
   set(h,'String',num2str(lv_idx),'Userdata',lv_idx);
   h = findobj(gcf,'Tag','LVNumberEdit');
   set(h,'String',num2str(num_lv),'Userdata',num_lv);
   h = findobj(gcf,'Tag','LagIndexEdit');
   set(h,'String',num2str(lag_idx),'Userdata',lag_idx);
   h = findobj(gcf,'Tag','LagNumberEdit');
   set(h,'String',num2str(num_lag),'Userdata',num_lag);
   h = findobj(gcf,'Tag','FirstSlice');
   set(h,'String',num2str(first_slice),'Userdata',num_slices);
   h = findobj(gcf,'Tag','SliceStep');
   set(h,'String',num2str(slice_step),'Userdata',num_slices);
   h = findobj(gcf,'Tag','LastSlice');
   set(h,'String',num2str(last_slice),'Userdata',num_slices);

   setappdata(gcf,'BLVData',brainlv);
   set_blv_fields(lv_idx);

   if ~exist('boot_result','var') | isempty(boot_result)
      ToggleView(0);
      set(findobj(gcf,'Tag','ViewToggleMenu'),'Visible','off');
      set(findobj(gcf,'Tag','OpenTBrainScoresPlot'),'Visible','off');
   else					% show bootstrap ratio if exist
      ToggleView(1);
      set(findobj(gcf,'Tag','ViewToggleMenu'),'Visible','on');

      if exist('method','var') & ( method == 1 | method == 2 | method == 4 | method == 6 )
         set(findobj(gcf,'Tag','OpenTBrainScoresPlot'),'Visible','on');
      end

      % set the bootstrap ratio field values
      %
      setappdata(gcf,'BSRatio',boot_result.compare_brain);
      set_bs_fields(lv_idx,0.05);
      UpdatePValue;
   end;

   h = findobj(gcf,'Tag','OpenContrastWindow');

%   if isequal(ContrastFile,'NONE') | isequal(ContrastFile,'BEHAV') | isequal(ContrastFile,'MULTIBLOCK')
   if method == 1 | method == 3 | method == 4
      set(h,'Visible','off');
   else
      set(h,'Visible','on');
   end;

   set(gcf,'Pointer',old_pointer);
   set(findobj(gcf,'Tag','MessageLine'),'String','');

   setappdata(gcf,'SessionFileList', SessionProfiles);
   setappdata(gcf,'RotateAmount',rot_amount);
   setappdata(gcf,'CurrLVIdx',lv_idx);
   setappdata(gcf,'CurrLagIdx',lag_idx);
   setappdata(gcf,'STDims',st_dims);
   setappdata(gcf,'cond_selection',cond_selection);
   setappdata(gcf,'subj_group',subj_group);

   return;						% load_pls_result


%-------------------------------------------------------------------------
%
function OpenResponseFnPlot()

  sessionFileList = getappdata(gcbf,'SessionFileList');
  setappdata(gcbf,'actualHRF',1);

  rf_plot = getappdata(gcbf,'RFPlotHdl');
  if ~isempty(rf_plot)
      msg = 'ERROR: Response function plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  subj_group = getappdata(gcbf,'subj_group');

  if iscell(subj_group)
     rf_plot = ssb_fmri_plot_rf('LINK',sessionFileList);
  else
     rf_plot = fmri_plot_rf('LINK',sessionFileList);
  end

  link_info.hdl = gcbf;
  link_info.name = 'RFPlotHdl';
  setappdata(rf_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'RFPlotHdl',rf_plot);

  %  make sure the Coord of the Response Function Plot contains 
  %  the current point in the Response
  %
  cur_coord = getappdata(gcbf,'Coord');
  setappdata(rf_plot,'Coord',cur_coord);

  return;					% PlotResponseFn


%-------------------------------------------------------------------------
%
function OpenBrainScoresPlot()


  bs_plot = getappdata(gcf,'BSPlotHdl');
  if ~isempty(bs_plot)
      msg = 'ERROR: Brain score plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  sessionFileList = getappdata(gcbf,'SessionFileList');

  h = findobj(gcbf,'Tag','ResultFile');
  PLSresultFile = get(h,'UserData');


  bs_plot = fmri_plot_brain_scores('LINK',sessionFileList,PLSresultFile);
  link_info.hdl = gcbf;
  link_info.name = 'BSPlotHdl';
  setappdata(bs_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'BSPlotHdl',bs_plot);

  return;					% OpenBrainScoresPlot


%-------------------------------------------------------------------------
%
function OpenDesignPlot()


   scores_fig = getappdata(gcbf,'ScorePlotHdl');
   if ~isempty(scores_fig)
      msg = 'ERROR: Design Scores Plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   h = findobj(gcbf,'Tag','ResultFile');
   PLSresultFile = get(h,'UserData');

   scores_fig = fmri_plot_scores('LINK',PLSresultFile);

   lv_idx = getappdata(gcbf,'CurrLVIdx');
   if (lv_idx ~= 1)
      fmri_plot_scores('UPDATE_LV_SELECTION',scores_fig,lv_idx);
   end;

   link_info.hdl = gcbf;
   link_info.name = 'ScorePlotHdl';
   setappdata(scores_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'ScorePlotHdl',scores_fig);

   return;					% OpenDesignPlot


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
function SetClusterReportOptions()

   st_origin = getappdata(gcbf,'STOrigin');
   st_dims = getappdata(gcbf,'STDims');

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
         st_origin = floor((st_dims([1 2 4])+1)/2);
         % st_origin = round(st_dims([1 2 4])/2);
      end;
   end;


   xyz = getappdata(gcf,'xyz');
   lag = getappdata(gcbf,'lag');


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

   nii_view = getappdata(gcf,'nii_view');
   nii_view.origin = origin_xyz;
   setappdata(gcf,'nii_view',nii_view);

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
   if ~isempty(cur_xyz) | ~isempty(cur_lag)
      if isempty(cur_xyz) | ~all(size(cur_xyz) ==  [1 3])
         msg = 'Please use 3 numbers for xyz.';
         set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
         return;
      elseif isempty(cur_lag) | ~all(size(cur_lag) ==  [1 1])
         msg = 'Please use 1 number for lag number.';
         set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
         return;
      end

      EditXYZ(cur_xyz, cur_lag + 1);
   end
end

%   xyz = getappdata(gcf,'xyz');		% move ahead

if 0
   if ~isempty(xyz)
      EditXYZ;
   end
end

   if ~isempty(xyz)
      voxel_size = getappdata(gcf,'STVoxelSize');
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
   h = rri_wait_box(msg, [0.5 0.1]);

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

   [tmp cluster_hdl] = fmri_cluster_report(cluster_min_size, ...
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

if 0
   load(PLSresultFile,'cond_name','design');
   num_groups = length(getappdata(gcf,'SessionFileList'));

   if num_groups * length(cond_name) ~= size(design, 1)
      design = repmat(design, [num_groups 1]);
   end

   contrast_fig = rri_input_contrast_ui({'fMRI'}, cond_name, [], num_groups, design, 1);


%if 0

   if isequal(ContrastFile,'NONE'), 
      msg = 'No contrast was used for this PLS analysis.'; 
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   if isequal(ContrastFile,'HELMERT'),   % using Helmert matrix for contrasts
      load(SessionProfiles{1}{1});

      conditions = session_info.condition;
      num_conditions = length(conditions);
      helmert_contrasts = rri_helmert_matrix(num_conditions);

      for i=1:num_conditions-1,
         pls_contrasts(i).name = sprintf('Contrast #%d',i);
         pls_contrasts(i).value = helmert_contrasts(:,i)';
      end;
   else
      try
         load(ContrastFile);
      catch 
         msg = sprintf('ERROR: Cannot open contrast file "%s".',ContrastFile); 
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end;
   end;

end

   load(PLSresultFile);
   rri_changepath('fmriresult');

   pls_session = SessionProfiles{1}{1};
   num_groups = length(getappdata(gcf,'SessionFileList'));

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

   contrast_fig = rri_input_contrast_ui({'fMRI'},pls_session,cond_selection,num_groups,nonrotatemultiblock,1,behavname,ContrastMatrix,bscan);

%   contrast_fig = fmri_input_contrast_ui(pls_contrasts,conditions,1);

   link_info.hdl = gcbf;
   link_info.name = 'ContrastFigHdl';
   setappdata(contrast_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'ContrastFigHdl',contrast_fig);

   return;					% OpenContrastWindow


%-------------------------------------------------------------------------
%
function ShowResult(action,update)
% action=0 - plot with the control figure
% action=1 - plot in a seperate figure
%

  mainfig = gcf;
  h = findobj(gcf,'Tag','ResultFile'); PLSresultFile = get(h,'Userdata');

  try 				% load the dimension info of the st_datamat
     load(PLSresultFile,'st_dims'),
  catch
     msg =sprintf('ERROR: Cannot load the PLS result file "%s".',PLSresultFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;


  h = findobj(gcf,'Tag','LVIndexEdit');  lv_idx = get(h,'Userdata');
  curr_lv_idx = getappdata(gcf,'CurrLVIdx');
  if (lv_idx ~= curr_lv_idx),
     lv_idx = curr_lv_idx;
     set(h,'String',num2str(lv_idx));
  end;

  h = findobj(gcf,'Tag','LagIndexEdit');  lag_idx = get(h,'Userdata');
  curr_lag_idx = getappdata(gcf,'CurrLagIdx');
  if (lag_idx ~= curr_lag_idx),
     lag_idx = curr_lag_idx;
     set(h,'String',num2str(lag_idx));
  end;

  h = findobj(gcf,'Tag','FirstSlice'); first_slice = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','SliceStep');  step = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','LastSlice');  last_slice = str2num(get(h,'String'));

  if (first_slice < 1) | (first_slice > st_dims(4))
     msg =sprintf('ERROR: The first slice must be between 1 and %d.',st_dims(4));
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;

  if (last_slice < 1) | (last_slice > st_dims(4))
     msg =sprintf('ERROR: The last slice must be between 1 and %d.',st_dims(4));
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;

  slice_idx = [first_slice:step:last_slice];
  if isempty(slice_idx),
     msg = 'ERROR: Invalid slice range.';
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;


  old_pointer = get(gcf,'Pointer');
  fig_hdl = gcf;
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
 %    fmri_plot_cluster_mask(cluster_info);
  %end

  if cluster_mask_state
     cluster_info = [];
  end

  if ~action
     setting = getappdata(gcf,'setting');

     if isempty(setting) | ~isfield(setting,'origin')
        setting.origin = getappdata(gcf,'STOrigin');
     else
        setappdata(gcf,'STOrigin',setting.origin);
        setappdata(gcf,'Origin',setting.origin);
     end;
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

     range = [min_blv max_blv];
     switch action 
       case {0}
          plot_st_brainlv(PLSresultFile,lv_idx,lag_idx,[],thresh,thresh2,range,0,cluster_info,update);
       case {1}
          plot_st_brainlv(PLSresultFile,lv_idx,lag_idx,[],thresh,thresh2,range,1,cluster_info,update);
     end;

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
          plot_bs_ratio(PLSresultFile,lv_idx,lag_idx,[],thresh_ratio,thresh_ratio2,range,0,cluster_info,update);
       case {1}
          plot_bs_ratio(PLSresultFile,lv_idx,lag_idx,[],thresh_ratio,thresh_ratio2,range,1,cluster_info,update);
     end;

  end;

  set(fig_hdl,'Pointer',old_pointer);

  if ~action
     setting = getappdata(gcf,'setting');

     if isempty(setting) | ~isfield(setting,'origin')
        setting.origin = getappdata(gcf,'STOrigin');
     else
        setappdata(gcf,'STOrigin',setting.origin);
        setappdata(gcf,'Origin',setting.origin);
     end;

     setting.lv_idx = lv_idx;
     setting.lag_idx = lag_idx;
     setting.rot_amount = getappdata(gcf,'RotateAmount');
     setting.rescale = get(findobj(gcf,'Tag','RESCALECheckbox'),'value');  

     setting.first_slice = first_slice;
     setting.slice_step = step;
     setting.last_slice = last_slice;

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

if 0
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
end

    %%%%%%%%%%%%%%%       moved before plot blv      %%%%%%%%%%%%%%%%%%

%  cluster_mask_state = get(findobj(gcf,'tag','ClusterMask'),'Userdata');

  %isbsr = getappdata(gcf,'ViewBootstrapRatio');
 % if isbsr
%     cluster_info = getappdata(gcf, 'cluster_bsr');
  %else
 %    cluster_info = getappdata(gcf, 'cluster_blv');
%  end

 % if length(cluster_info) < curr_lv_idx
%     cluster_info = [];
  %else
 %    cluster_info = cluster_info{curr_lv_idx};
%  end

  %if ~isempty(cluster_info) & ~cluster_mask_state
 %    fmri_plot_cluster_mask(cluster_info);
%  end

  % update the LV scores when needed
  %
  scores_fig = getappdata(gcf,'ScorePlotHdl'); 
  if isempty(scores_fig)		
      return;
  else
      fmri_plot_scores('UPDATE_LV_SELECTION',scores_fig,lv_idx);
  end;

  return;					% ShowResult


%-------------------------------------------------------------------------
%   
function plot_st_brainlv(PLSresultFile,lv_idx,lag_idx,slice_idx,thresh,thresh2,range,new_fig,cluster_info,update)
% 
%  USAGE:  plot_st_brainlv(PLSresultFile,lv_idx,slice_idx,thresh,range,new_fig)
%
%
%  INPUT: 
%     PLSresultFile - file contains the PLS results
%     lv_idx - the index of brainlv to be displayed
%     slice_idx - (optional) the indices of the slices to be display
%     thresh - (optional) set up the cutoff value to be display in colour.
%               To show everything, set thresh = 0. 
%               [DEFAULT = 0.5 * (range of brainlv values)]  
%     range - (optional) 1x2 vector specifies the range of brainlv to be 
%             display, anything higher or lower will be clipped
%     new_fig - show images on a new figure
%                           
%  Example:
%
%      slice_idx = [50:70];
%      thresh = 0.01;
%      range = [-0.8 0.8];
%      plot_st_brainlv('PLSresult',slice_idx,0.4,range);
%
  if (new_fig)
     bg_img = getappdata(gcbf,'BackgroundImg');
     rot_amount = getappdata(gcbf,'RotateAmount');
  else
     bg_img = getappdata(gcf,'BackgroundImg');
     rot_amount = getappdata(gcf,'RotateAmount');
  end;

  rot_amount = 4;

if 0
  load(PLSresultFile,'brainlv','s','st_dims','st_win_size','st_coords', ...
		     'st_voxel_size','st_origin');
end

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

   setappdata(gcf,'BLVData',brainlv);

%  if ~exist('slice_idx','var')
  if isempty(slice_idx)
     slice_idx = [1:st_dims(4)];
  end
  num_slices = length(slice_idx);

  num_lv = size(brainlv,2);
  num_lag = st_win_size - 1;

  if ~exist('thresh','var') 
     thresh = [];
  end;

  if ~exist('thresh2','var') 
     thresh2 = [];
  end;

  h = findobj(gcf,'Tag','Threshold');  thresh = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','Threshold2');  thresh2 = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','MaxValue');   max_blv = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','MinValue');   min_blv = str2num(get(h,'String'));

  if ~exist('range','var') | isempty(range)
     if min_blv == max_blv
         if abs(min_blv) < 1e-6
            max_blv = min_blv + eps;
         else
            max_blv = min_blv + abs(min_blv)*1e-9;
         end
     end

     range = [min_blv max_blv];  
  else
     min_blv = range(1);
     max_blv = range(2);

     if min_blv == max_blv
         if abs(min_blv) < 1e-6
            max_blv = min_blv + eps;
         else
            max_blv = min_blv + abs(min_blv)*1e-9;
         end

         range(2) = max_blv;
     end
  end

  win_size = st_win_size;

  if (mod(rot_amount,2) == 0) 
    img_height = st_dims(1);		  % rows 
    img_width  = st_dims(2);
  else
    img_height = st_dims(2);		  % rows - after 90 or 270 rotation
    img_width  = st_dims(1);
  end;

  mont_height = win_size * img_height;    
  mont_width = num_slices * img_width;     


  %  construct the brainlv images
  %
%  blv_imgs = zeros(win_size*img_height,mont_width);
  first_rows = 1; last_rows = img_height;
%  for i=1:win_size,
     i = lag_idx + 1;
     blv = brainlv(i:win_size:end,lv_idx);

     if isempty(cluster_info)
        cluster_idx = st_coords;
     else
        cluster_idx = cluster_info.data{i}.idx;
     end

     [img,cmap,cbar] = fmri_plot_brainlv(blv,st_coords,st_dims,slice_idx, ...
		thresh,thresh2,range,rot_amount,bg_img,cluster_idx);

     blv_imgs = img;
%     blv_imgs(first_rows:last_rows,:) = reshape(img,[img_height, mont_width]);
     first_rows = last_rows + 1; last_rows = first_rows + img_height - 1;
%  end;

  %  display the images
  %
  if (new_fig)
      [axes_hdl,colorbar_hdl] = create_new_blv_figure;
  else 
%      axes_hdl = getappdata(gcf,'BlvAxes');
      colorbar_hdl = getappdata(gcf,'Colorbar');
  end;

%  axes(axes_hdl);			

if 0
  if update
     h_img = findobj(gcf,'tag','BLVImg');
     set(h_img,'CData',blv_imgs);
  else
     h_img = image(blv_imgs); 

     set(gca,'tickdir','out','ticklength',[0.001 0.001]);
     set(gca,'xlabel',text('String','Slice','FontSize',10,'Interpreter','none'));
     set(gca,'xtick',[img_width/2:img_width:mont_width]);
     set(gca,'xticklabel',slice_idx);
     set(gca,'ylabel',text('String','Lag','FontSize',10,'Interpreter','none'));
     set(gca,'ytick',[img_height/2:img_height:mont_height]);
     set(gca,'yticklabel',[0:win_size-1]); 
  end

  set(h_img,'Tag','BLVImg');
  colormap(cmap); 

  if (new_fig)
     create_colorbar(colorbar_hdl,cbar,min_blv,max_blv);
     return;
  end;

  set(h_img,'ButtonDownFcn','fmri_result_3v_ui(''SelectPixel'')');
end


    st_origin1 = getappdata(gcf,'STOrigin');
    if ~isempty(st_origin1)
       st_origin = st_origin1;
    end

    nii = make_nii(single(squeeze(img)), st_voxel_size, st_origin);

    gui3view.figure = gcf;
    gui3view.area = [0.32 0.1 0.55 0.85];

    if update

        opt.command = 'updateimg';
        opt.usecolorbar = 0;
        view_nii(gcf,nii.img,opt);
        opt1.setcolormap = cmap;
        view_nii(gcf,opt1);

    else

        opt.setbuttondown = 'fmri_result_3v_ui(''SelectPixel'');';
        opt.setarea = [0.32 0.1 0.55 0.85];
        opt.setcolormap = cmap;
        opt.useimagesc = 0;
        opt.usepanel = 0;
        opt.usecolorbar = 0;
        tstfig = getappdata(gcf,'nii_view');
        if isempty(tstfig)
           opt.command = 'init';
        else
           opt.command = 'updatenii';
        end
        view_nii(gcf,nii,opt);

    end

    xyz = getappdata(gcf, 'xyz');
    if ~isempty(xyz)
       opt2.setunit = 'voxel';
       opt2.setviewpoint = xyz;
       view_nii(gcf,opt2);
    end

    nii_view = getappdata(gcf,'nii_view');

    h = findobj(gcf,'Tag','XYZVoxel');
    set(h,'String',sprintf('%d %d %d %d',lag_idx,nii_view.imgXYZ.vox));

    h = findobj(gcf,'Tag','XYZmm');
    set(h,'String',sprintf('%2.1f %2.1f %2.1f',nii_view.imgXYZ.mm));

    setappdata(gcf,'xyz',nii_view.imgXYZ.vox);

  create_colorbar( colorbar_hdl, cbar, min_blv, max_blv );

  %  save background to img
  %
  setappdata(gcf,'cmap',cmap);

  %  save the attributes of the current image
  %
  setappdata(gcf,'STDims',st_dims);
  setappdata(gcf,'STVoxelSize',st_voxel_size);
  setappdata(gcf,'STOrigin',st_origin);
  setappdata(gcf,'WinSize',win_size);
  setappdata(gcf,'SliceIdx',slice_idx);
  setappdata(gcf,'ImgHeight',img_height);
  setappdata(gcf,'ImgWidth',img_width);
  setappdata(gcf,'ImgRotateFlg',1);
  setappdata(gcf,'NumLVs',num_lv);
  setappdata(gcf,'NumLags',num_lag);
  setappdata(gcf,'BLVData',brainlv);
  setappdata(gcf,'BLVCoords',st_coords);
  setappdata(gcf,'BLVThreshold',thresh);  
  setappdata(gcf,'BLVThreshold2',thresh2);  
  setappdata(gcf,'RotateAmount',rot_amount);

  return;					% plot_st_brainlv


%-------------------------------------------------------------------------
%   
function plot_bs_ratio(PLSresultFile,lv_idx,lag_idx,slice_idx,thresh,thresh2,range,new_fig,cluster_info,update)
% 
  if (new_fig)
     bg_img = getappdata(gcbf,'BackgroundImg');
     rot_amount = getappdata(gcbf,'RotateAmount');
  else
     bg_img = getappdata(gcf,'BackgroundImg');
     rot_amount = getappdata(gcf,'RotateAmount');
  end;

  rot_amount = 4;

if 0
  load(PLSresultFile,'boot_result','st_dims','st_win_size','st_coords', ...
		     'st_voxel_size','st_origin');
end

   load(PLSresultFile);

   if exist('result','var')
      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end
   end

  if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
  end

  bs_ratio = boot_result.compare_brain;

%  if ~exist('slice_idx','var')
  if isempty(slice_idx)
     slice_idx = [1:st_dims(4)];
  end
  num_slices = length(slice_idx);

  num_lv = size(bs_ratio,2);
  num_lag = st_win_size - 1;

  min_ratio = min(bs_ratio(:,lv_idx));
  max_ratio = max(bs_ratio(:,lv_idx));
  if ~exist('range','var') | isempty(range)
     if min_ratio == max_ratio
         if abs(min_ratio) < 1e-6
            max_ratio = min_ratio + eps;
         else
            max_ratio = min_ratio + abs(min_ratio)*1e-9;
         end
     end

%     if (abs(min_ratio) > abs(max_ratio)),
 %      max_ratio = abs(min_ratio);
  %   else
   %    min_ratio = -1 * max_ratio;
    % end
     range = [min_ratio max_ratio];  
  else
     min_ratio = range(1);
     max_ratio = range(2);

     if min_ratio==max_ratio
         if abs(min_ratio) < 1e-6
            max_ratio = min_ratio + eps;
         else
            max_ratio = min_ratio + abs(min_ratio)*1e-9;
         end

         range(2) = max_ratio;
     end
  end

  if ~exist('thresh','var') | isempty(thresh)
     thresh = max_ratio; % (abs(max_ratio) + abs(min_ratio)) / 6;
  end  

  if ~exist('thresh2','var') | isempty(thresh2)
     thresh2 = min_ratio; % -thresh;
  end

  h = findobj(gcf,'Tag','BSThreshold');  set(h,'String',sprintf('%8.5f',thresh));
  h = findobj(gcf,'Tag','BSThreshold2');  set(h,'String',sprintf('%8.5f',thresh2));
  h = findobj(gcf,'Tag','MaxRatio');   set(h,'String',sprintf('%8.5f',max_ratio));
  h = findobj(gcf,'Tag','MinRatio');   set(h,'String',sprintf('%8.5f',min_ratio));

  win_size = st_win_size;

  if (mod(rot_amount,2) == 0) 
    img_height = st_dims(1);		  % rows 
    img_width  = st_dims(2);
  else
    img_height = st_dims(2);		  % rows - after 90 or 270 rotation
    img_width  = st_dims(1);
  end;

  mont_height = win_size * img_height;    
  mont_width = num_slices * img_width;     


  %  construct the bootstrap ratio images
  %
%  ratio_imgs = zeros(win_size*img_height,mont_width);
  first_rows = 1; last_rows = img_height;
%  for i=1:win_size,
     i = lag_idx + 1;
     bsr = bs_ratio(i:win_size:end,lv_idx);

     if isempty(cluster_info)
        cluster_idx = st_coords;
     else
        cluster_idx = cluster_info.data{i}.idx;
     end

     [img,cmap,cbar] = fmri_plot_brainlv(bsr,st_coords,st_dims,slice_idx, ...
		thresh,thresh2,range,rot_amount,bg_img,cluster_idx);
     ratio_imgs = img;
%     ratio_imgs(first_rows:last_rows,:) = reshape(img,[img_height, mont_width]);
     first_rows = last_rows + 1; last_rows = first_rows + img_height - 1;
%  end;

  %  display the images
  %
  if (new_fig)
      [axes_hdl,colorbar_hdl] = create_new_blv_figure;
  else 
%      axes_hdl = getappdata(gcf,'BlvAxes');
      colorbar_hdl = getappdata(gcf,'Colorbar');
  end;

%  axes(axes_hdl);			

if 0
  if update
     h_img = findobj(gcf,'tag','BLVImg');
     set(h_img,'CData',ratio_imgs);
  else
     h_img = image(ratio_imgs); 

     set(gca,'tickdir','out','ticklength',[0.001 0.001]);
     set(gca,'xlabel',text('String','Slice','FontSize',10,'Interpreter','none'));
     set(gca,'xtick',[img_width/2:img_width:mont_width]);
     set(gca,'xticklabel',slice_idx);
     set(gca,'ylabel',text('String','Lag','FontSize',10,'Interpreter','none'));
     set(gca,'ytick',[img_height/2:img_height:mont_height]);
     set(gca,'yticklabel',[0:win_size-1]); 
  end

  set(h_img,'Tag','BLVImg');
  colormap(cmap); 

  if (new_fig)
     create_colorbar(colorbar_hdl,cbar,min_ratio,max_ratio);
     return;
  end;

  set(h_img,'ButtonDownFcn','fmri_result_3v_ui(''SelectPixel'')');
end


    st_origin1 = getappdata(gcf,'STOrigin');
    if ~isempty(st_origin1)
       st_origin = st_origin1;
    end

    nii = make_nii(single(squeeze(img)), st_voxel_size, st_origin);

    gui3view.figure = gcf;
    gui3view.area = [0.32 0.1 0.55 0.85];

    if update

        opt.command = 'updateimg';
        opt.usecolorbar = 0;
        view_nii(gcf,nii.img,opt);
        opt1.setcolormap = cmap;
        view_nii(gcf,opt1);

    else

        opt.setbuttondown = 'fmri_result_3v_ui(''SelectPixel'');';
        opt.setarea = [0.32 0.1 0.55 0.85];
        opt.setcolormap = cmap;
        opt.useimagesc = 0;
        opt.usepanel = 0;
        opt.usecolorbar = 0;
        tstfig = getappdata(gcf,'nii_view');
        if isempty(tstfig)
           opt.command = 'init';
        else
           opt.command = 'updatenii';
        end
        view_nii(gcf,nii,opt);

    end

    xyz = getappdata(gcf, 'xyz');
    if ~isempty(xyz)
       opt2.setunit = 'voxel';
       opt2.setviewpoint = xyz;
       view_nii(gcf,opt2);
    end

    nii_view = getappdata(gcf,'nii_view');

    h = findobj(gcf,'Tag','XYZVoxel');
    set(h,'String',sprintf('%d %d %d %d',lag_idx,nii_view.imgXYZ.vox));

    h = findobj(gcf,'Tag','XYZmm');
    set(h,'String',sprintf('%2.1f %2.1f %2.1f',nii_view.imgXYZ.mm));

    setappdata(gcf,'xyz',nii_view.imgXYZ.vox);


  create_colorbar( colorbar_hdl, cbar, min_ratio, max_ratio );

  %  save background to img
  %
  setappdata(gcf,'cmap',cmap);

  %  save the attributes of the current image
  %
  setappdata(gcf,'STDims',st_dims);
  setappdata(gcf,'STVoxelSize',st_voxel_size);
  setappdata(gcf,'STOrigin',st_origin);
  setappdata(gcf,'WinSize',win_size);
  setappdata(gcf,'SliceIdx',slice_idx);
  setappdata(gcf,'ImgHeight',img_height);
  setappdata(gcf,'ImgWidth',img_width);
  setappdata(gcf,'ImgRotateFlg',1);
  setappdata(gcf,'NumLVs',num_lv);
  setappdata(gcf,'NumLags',num_lag);
  setappdata(gcf,'BSRatio',bs_ratio);
  setappdata(gcf,'BSRatioCoords',st_coords);
  setappdata(gcf,'BSThreshold',thresh);  
  setappdata(gcf,'BSThreshold2',thresh2);  
  setappdata(gcf,'RotateAmount',rot_amount);

  return;					% plot_bs_ratio


%-------------------------------------------------------------------------
%
function SaveResultToIMG(is_disp)
%

  h = findobj(gcf,'Tag','ResultFile'); PLSresultFile = get(h,'Userdata');

  try 				% load the dimension info of the st_datamat
     load(PLSresultFile,'st_dims'),
  catch
     msg =sprintf('ERROR: Cannot load the PLS result file "%s".',PLSresultFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;

  h = findobj(gcf,'Tag','LVIndexEdit');  lv_idx = get(h,'Userdata');
  curr_lv_idx = getappdata(gcf,'CurrLVIdx');
  if (lv_idx ~= curr_lv_idx),
     lv_idx = curr_lv_idx;
     set(h,'String',num2str(lv_idx));
  end;


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
        create_st_brainlv_disp(PLSresultFile,lv_idx,thresh,thresh2,non_cluster_coords);
     else
        create_st_brainlv_img(PLSresultFile,lv_idx,thresh,thresh2,non_cluster_coords);
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
function create_st_brainlv_disp(PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2,non_cluster_coords);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-10);
  image_fn = [resultfile_prefix, 'fMRIblv_lag0.img'];

  [filename, pathname] = rri_selectfile('<ONLY INPUT PREFIX>*_blv_disp_lv_lag.img', ...
				'Brain LV IMG file Prefix');
  if isequal(filename,0)
      return;
  end;

  filename = strrep(filename,'_blv_disp_lv_lag.img','');

  [tmp filename] = fileparts(filename);

  %  load the result file
  %
%  load(PLSresultFile,'brainlv','s','st_dims','st_win_size','st_coords', ...
%		     'st_voxel_size','st_origin');

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

  dims = st_dims([1 2 4]);
%  img = zeros(dims);

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

  brainlv = reshape(brainlv, [st_win_size, length(brainlv)/st_win_size]);

  for i=1:st_win_size,
     brainlv(i,non_cluster_coords{i}) = 0;

     too_large = find(brainlv(i,:) > max_blv); brainlv(i,too_large) = max_blv;
     too_small = find(brainlv(i,:) < min_blv); brainlv(i,too_small) = min_blv;

     % Create the image slices in which voxels are set to be within certain range
     %
     lower_interval = (thresh_ratio2 - min_blv) / (num_blv_colors-1);
     upper_interval = (max_blv - thresh_ratio) / (num_blv_colors-1);

     blv = zeros(1,length(st_coords)) + brain_region_color_idx;
     lower_idx = find(brainlv(i,:) < thresh_ratio2);
     blv_offset = brainlv(i,lower_idx) - min_blv; 
     lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
     blv(lower_idx) = lower_color_idx;

     upper_idx = find(brainlv(i,:) > thresh_ratio);
     blv_offset = max_blv - brainlv(i,upper_idx); 
     upper_color_idx = num_blv_colors - round(blv_offset/upper_interval);
     upper_color_idx = upper_color_idx + first_upper_color_idx - 1;
     blv(upper_idx) = upper_color_idx;

     if isempty(bg_img)
        non_brain_region_color_idx = size(cmap,1);
        img = zeros(1,dims(1)*dims(2)*dims(3)) + non_brain_region_color_idx;
        img(st_coords) = blv;
        % img = reshape(img,dims); 
     else
        max_bg = max(bg_img(:));
        min_bg = min(bg_img(:));
        img = (bg_img - min_bg) / (max_bg - min_bg) * 100;
        img(st_coords(lower_idx)) = blv(lower_idx);
        img(st_coords(upper_idx)) = blv(upper_idx);
        % img = reshape(img,dims); 
     end

     img_file = fullfile(pathname,sprintf('%s_blv_disp_lv%d_lag%d',filename,lv_idx,i-1));
%     blv = brainlv(i:st_win_size:end,lv_idx); 
%     blv(abs(blv) < thresh_ratio) = 0;

%     img(st_coords) = blv;
     
     descrip = sprintf('BrainLV from %s, LV: %d, Pos.Thresh: %8.5f, Neg.Thresh: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2);
     rri_write_img(img_file,img,0,dims,st_voxel_size,16,st_origin,descrip);
  end;

  %  save background to img
  %
  filename = fullfile(pathname,sprintf('%s_blv_disp_lv%d',filename,lv_idx));
  filename = [filename '_cmap'];
  save(filename,'cmap');

  return;					% create_st_brainlv_disp


%--------------------------------------------------------------------------
function create_bs_ratio_disp(PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2,non_cluster_coords);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-1);
  image_fn = [resultfile_prefix, 'lag0_fMRIbsr.img'];

  [filename, pathname] = rri_selectfile('<ONLY INPUT PREFIX>*_bsr_disp_lv_lag.img', ...
				'Bootstrap Result IMG file Prefix');
  if isequal(filename,0)
      return;
  end;

  filename = strrep(filename,'_bsr_disp_lv_lag.img','');

  [tmp filename] = fileparts(filename);

  %  load the result file
  %
%  load(PLSresultFile,'boot_result','st_dims','st_win_size','st_coords', ...
%		     'st_voxel_size','st_origin');

  load(PLSresultFile);

   if exist('result','var')
      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end
   end

  if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
  end

  bs_ratio = boot_result.compare_brain;

  dims = st_dims([1 2 4]);
%  img = zeros(dims);

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

  brainlv = reshape(brainlv, [st_win_size, length(brainlv)/st_win_size]);

  for i=1:st_win_size,
     brainlv(i,non_cluster_coords{i}) = 0;

     too_large = find(brainlv(i,:) > max_blv); brainlv(i,too_large) = max_blv;
     too_small = find(brainlv(i,:) < min_blv); brainlv(i,too_small) = min_blv;

     % Create the image slices in which voxels are set to be within certain range
     %
     lower_interval = (thresh_ratio2 - min_blv) / (num_blv_colors-1);
     upper_interval = (max_blv - thresh_ratio) / (num_blv_colors-1);

     blv = zeros(1,length(st_coords)) + brain_region_color_idx;
     lower_idx = find(brainlv(i,:) < thresh_ratio2);
     blv_offset = brainlv(i,lower_idx) - min_blv; 
     lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
     blv(lower_idx) = lower_color_idx;

     upper_idx = find(brainlv(i,:) > thresh_ratio);
     blv_offset = max_blv - brainlv(i,upper_idx); 
     upper_color_idx = num_blv_colors - round(blv_offset/upper_interval);
     upper_color_idx = upper_color_idx + first_upper_color_idx - 1;
     blv(upper_idx) = upper_color_idx;

     if isempty(bg_img)
        non_brain_region_color_idx = size(cmap,1);
        img = zeros(1,dims(1)*dims(2)*dims(3)) + non_brain_region_color_idx;
        img(st_coords) = blv;
        img = reshape(img,dims); 
     else
        max_bg = max(bg_img(:));
        min_bg = min(bg_img(:));
        img = (bg_img - min_bg) / (max_bg - min_bg) * 100;
        img(st_coords(lower_idx)) = blv(lower_idx);
        img(st_coords(upper_idx)) = blv(upper_idx);
        img = reshape(img,dims); 
     end

     img_file = fullfile(pathname,sprintf('%s_bsr_disp_lv%d_lag%d',filename,lv_idx,i-1));
%     bsr = bs_ratio(i:st_win_size:end,lv_idx); 
%     bsr(abs(bsr) < thresh_ratio) = 0;

%     img(st_coords) = bsr;
     
     descrip = sprintf('Bootstrap ratio from %s, LV: %d, Pos.Thresh: %8.5f, Neg.Thresh: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2);
     rri_write_img(img_file,img,0,dims,st_voxel_size,16,st_origin,descrip);
  end;

  %  save background to img
  %
  filename = fullfile(pathname,sprintf('%s_bsr_disp_lv%d',filename,lv_idx));
  filename = [filename '_cmap'];
  save(filename,'cmap');

  return;					% create_bs_ratio_disp


%--------------------------------------------------------------------------
function create_st_brainlv_img(PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2,non_cluster_coords);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-10);
  image_fn = [resultfile_prefix, 'fMRIblv_lag0.img'];

  [filename, pathname] = rri_selectfile('<ONLY INPUT PREFIX>*_blv_lv_lag.img', ...
				'Brain LV IMG file Prefix');
  if isequal(filename,0)
      return;
  end;

  filename = strrep(filename,'_blv_lv_lag.img','');

  [tmp filename] = fileparts(filename);

  %  load the result file
  %
%  load(PLSresultFile,'brainlv','s','st_dims','st_win_size','st_coords', ...
%		     'st_voxel_size','st_origin');

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

  dims = st_dims([1 2 4]);
  img = zeros(dims);

  for i=1:st_win_size,
     img_file = fullfile(pathname,sprintf('%s_blv_lv%d_lag%d',filename,lv_idx,i-1));
     blv = brainlv(i:st_win_size:end,lv_idx); 
     blv( blv < thresh_ratio & blv > thresh_ratio2 ) = 0;

     img(st_coords) = blv;
     img(st_coords(non_cluster_coords{i})) = 0;

     descrip = sprintf('BrainLV from %s, LV: %d, Pos.Thresh: %8.5f, Neg.Thresh: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2);
     rri_write_img(img_file,img,0,dims,st_voxel_size,16,st_origin,descrip);
  end;

  return;					% create_st_brainlv_img


%--------------------------------------------------------------------------
function create_bs_ratio_img(PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2,non_cluster_coords);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-1);
  image_fn = [resultfile_prefix, 'lag0_fMRIbsr.img'];

  [filename, pathname] = rri_selectfile('<ONLY INPUT PREFIX>*_bsr_lv_lag.img', ...
				'Bootstrap Result IMG file Prefix');
  if isequal(filename,0)
      return;
  end;

  filename = strrep(filename,'_bsr_lv_lag.img','');

  [tmp filename] = fileparts(filename);

  %  load the result file
  %
%  load(PLSresultFile,'boot_result','st_dims','st_win_size','st_coords', ...
%		     'st_voxel_size','st_origin');

  load(PLSresultFile);

   if exist('result','var')
      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end
   end

  if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
  end

  bs_ratio = boot_result.compare_brain;

  dims = st_dims([1 2 4]);
  img = zeros(dims);

  for i=1:st_win_size,
     img_file = fullfile(pathname,sprintf('%s_bsr_lv%d_lag%d',filename,lv_idx,i-1));
     bsr = bs_ratio(i:st_win_size:end,lv_idx); 
     bsr( bsr < thresh_ratio & bsr > thresh_ratio2 ) = 0;

     img(st_coords) = bsr;
     img(st_coords(non_cluster_coords{i})) = 0;
     
     descrip = sprintf('Bootstrap ratio from %s, LV: %d, Pos.Thresh: %8.5f, Neg.Thresh: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio,thresh_ratio2);
     rri_write_img(img_file,img,0,dims,st_voxel_size,16,st_origin,descrip);
  end;

  return;					% create_bs_ratio_img


%--------------------------------------------------------------------------
function [st_filename] = get_st_datamat_filename(sessionFileList,with_path)
%
%   INPUT:
%       sessionFileList - vector of cell structure, each element contains
%                         the full path of a session file.
%       with_path - whether including path in the constructed the filename 
%                   of the st_datamat. 
%		    with_path = 0 : no path 
%		    with_path = 1 : including path
%
  num_files = length(sessionFileList);
  st_filename = cell(1,num_files);

  for i=1:num_files,
     load( sessionFileList{i} );
     if with_path,
       st_filename{i} = sprintf('%s/%s_fMRIdatamat.mat', ...
                     session_info.pls_data_path, session_info.datamat_prefix);
     else
       st_filename{i} = sprintf('%s_fMRIdatamat.mat', ...
                                                 session_info.datamat_prefix);
     end;
  end;

  return;					% get_st_datamat_name


%--------------------------------------------------------------------------
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
      fig_title = sprintf('fMRI BLV Plot: %s',PLSResultFile);
   else					% view bootstrap ratio
      setappdata(gcf,'ViewBootstrapRatio',1);
      bs_visibility = 'on';
      blv_visibility = 'off';
      save_menu_label = '&Save the BS ratio result to the IMG files';
      view_menu_label = '&View Brain LV';
      plot_menu_label = 'Create &Bootstrap Ratio Figure';
      fig_title = sprintf('fMRI Bootstrap Ratio Plot: %s',PLSResultFile);
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

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if isempty(lv_idx),
      msg = 'ERROR: Invalid input for the LV index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lv_idx_hdl,'String',num2str(getappdata(gcf,'CurrLVIdx')));
      return;
   end;

   if (getappdata(gcf,'CurrLVIdx') == lv_idx)  % LV does not changed do nothing
      return;
   end;

   num_lv = getappdata(gcf,'NumLVs');
   if (lv_idx < 1 | lv_idx > num_lv)
      msg = 'ERROR: Input LV index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lv_idx_hdl,'String',num2str(getappdata(gcf,'CurrLVIdx')));
      return;
   end;


   %  update the brainlv and bootstrap ratio fields
   %
   set_bs_fields(lv_idx,0.05);
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

%   EditXYZ;

   return;					% EditLV


%--------------------------------------------------------------------------
function EditLag()

   lag_idx_hdl = findobj(gcf,'Tag','LagIndexEdit');    
   lag_idx = str2num(get(lag_idx_hdl,'String'));

   if (getappdata(gcf,'CurrLagIdx') == lag_idx)  % LV does not changed do nothing
      return;
   end;

   if isempty(lag_idx),
      msg = 'ERROR: Invalid input for the Lag index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   num_lag = getappdata(gcf,'NumLags');
   if (lag_idx < 0 | lag_idx > num_lag)
      msg = 'ERROR: Input Lag index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   set(lag_idx_hdl,'Userdata',lag_idx);
   setappdata(gcf,'CurrLagIdx',lag_idx)

   return;					% EditLag


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
function SelectPixel()

   h = findobj(gcf,'Tag','StructuralMapLabel');
   set(h,'String','');

   nii_view = getappdata(gcbf,'nii_view');

   if ~isstruct(nii_view)
      return;
   end

   xyz = nii_view.imgXYZ.vox;
   xyz_mm = nii_view.imgXYZ.mm;
   setappdata(gcbf,'xyz',xyz);

   st_dims = getappdata(gcbf, 'STDims');
   coord = rri_xyz2coord(xyz, st_dims);
   setappdata(gcbf,'Coord',coord);

   if get(findobj(gcf,'Tag','LabelToggleMenu'), 'userdata')
      mapvalue = getappdata(gcf, 'mapvalue');
      maplabel = getappdata(gcf, 'maplabel');
      mapimg = getappdata(gcf, 'mapimg');

      if ~isempty(mapvalue) & ~isempty(maplabel) & ~isempty(mapimg) & ~isempty(coord) & coord>0
         label_id = find(mapvalue==mapimg(coord));

         if ~isempty(label_id)
            h = findobj(gcf,'Tag','StructuralMapLabel');
            set(h,'String',maplabel{label_id});
         end
      end
   end

   win_size = getappdata(gcbf,'WinSize');
   lag = getappdata(gcbf,'CurrLagIdx');
   row = lag + 1;

   h = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = get(h,'Userdata');

   %  update the brain LV value if needed
   %
   if (getappdata(gcbf,'ViewBootstrapRatio') == 0),

      brainlv = getappdata(gcbf,'BLVData');
      blv_coords = getappdata(gcbf,'BLVCoords');

      if isempty(blv_coords)
         blv_coords = getappdata(gcf,'BSRatioCoords');
      end

      curr_blv = brainlv(:,lv_idx);
      curr_blv = reshape(curr_blv,[win_size,length(blv_coords)]);
      coord_idx = find(blv_coords == coord);

      h = findobj(gcbf,'Tag','BLVValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         blv_value = curr_blv(row,coord_idx);
         set(h,'String',num2str(blv_value,'%9.6f'));
      end;

   else

      bs = getappdata(gcbf,'BSRatio');
      bs_coords = getappdata(gcbf,'BSRatioCoords');

      curr_bs = bs(:,lv_idx);
      curr_bs = reshape(curr_bs,[win_size,length(bs_coords)]);
      coord_idx = find(bs_coords == coord);

      h = findobj(gcbf,'Tag','BSValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         bs_value = curr_bs(row,coord_idx);
         set(h,'String',num2str(bs_value,'%9.6f'));
      end;
   end;

   h = findobj(gcbf,'Tag','XYZVoxel');
   set(h,'String',sprintf('%d %d %d %d', lag, xyz));

%   if get(findobj(gcf, 'tag', 'XYZmmLabel'), 'value') == 2
 %     xyz_mm = mni2tal(xyz_mm);
  % end

   h = findobj(gcbf,'Tag','XYZmm');
   set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

   linkfig = getappdata(gcbf,'RFPlotHdl');
   linkcorrfig = getappdata(gcbf,'RFCorrPlotHdl');

   if isempty(linkfig) & isempty(linkcorrfig)	% do nothing as no response plot
       return;
   end;

   if ~isempty(linkcorrfig)	%getappdata(gcbf,'isbehav')
      set(findobj(linkcorrfig,'Tag','MessageLine'), 'string', '');
      figure(linkcorrfig); fmri_plot_corr('NewCoord',coord,xyz,lag);
   end

   if ~isempty(linkfig)
      set(findobj(linkfig,'Tag','MessageLine'), 'string', '');

      subj_group = getappdata(gcbf,'subj_group');

      if iscell(subj_group)
         figure(linkfig); ssb_fmri_plot_rf('NewCoord',coord,xyz,lag);
      else
         figure(linkfig); fmri_plot_rf('NewCoord',coord,xyz,lag);
      end
   end

   return; 					% SelectPixel


%--------------------------------------------------------------------------
function EditXYZ()

   fig = gcf;

   h = findobj(fig,'Tag','StructuralMapLabel');
   set(h,'String','');

   xyz = str2num(get(findobj(fig,'tag','XYZVoxel'),'string'));

   if isempty(xyz) | ~isequal(size(xyz),[1 4])
      msg = 'LagXYZ should contain 4 numbers (Lag, X, Y, and Z)';
      set(findobj(fig,'Tag','MessageLine'),'String',msg);
      return;
   end

   j = xyz(1) + 1;
   xyz = xyz([2:4]);

   if ( j<1 | j>getappdata(fig,'WinSize') )
      msg = 'Invalid lag number';
      set(findobj(fig,'Tag','MessageLine'),'String',msg);
      return;
   end

   lag_idx_hdl = findobj(fig,'Tag','LagIndexEdit');    
   set(lag_idx_hdl,'String',num2str(j-1));
   EditLag;

   opt.setunit = 'voxel';
   opt.setviewpoint = xyz;
   view_nii(fig,opt);

   nii_view = getappdata(fig,'nii_view');
   xyz = nii_view.imgXYZ.vox;
   xyz_mm = nii_view.imgXYZ.mm;
   setappdata(fig,'xyz',xyz);

   st_dims = getappdata(fig, 'STDims');
   coord = rri_xyz2coord(xyz, st_dims);
   setappdata(fig,'Coord',coord);

   if get(findobj(gcf,'Tag','LabelToggleMenu'), 'userdata')
      mapvalue = getappdata(gcf, 'mapvalue');
      maplabel = getappdata(gcf, 'maplabel');
      mapimg = getappdata(gcf, 'mapimg');

      if ~isempty(mapvalue) & ~isempty(maplabel) & ~isempty(mapimg) & ~isempty(coord) & coord>0
         label_id = find(mapvalue==mapimg(coord));

         if ~isempty(label_id)
            h = findobj(gcf,'Tag','StructuralMapLabel');
            set(h,'String',maplabel{label_id});
         end
      end
   end

   win_size = getappdata(fig,'WinSize');
   lag = getappdata(fig,'CurrLagIdx');
   row = lag + 1;

   h = findobj(fig,'Tag','LVIndexEdit');    
   lv_idx = get(h,'Userdata');

   %  update the brain LV value if needed
   %
   if (getappdata(fig,'ViewBootstrapRatio') == 0),

      brainlv = getappdata(fig,'BLVData');
      blv_coords = getappdata(fig,'BLVCoords');

      if isempty(blv_coords)
         blv_coords = getappdata(fig,'BSRatioCoords');
      end

      curr_blv = brainlv(:,lv_idx);
      curr_blv = reshape(curr_blv,[win_size,length(blv_coords)]);
      coord_idx = find(blv_coords == coord);

      h = findobj(fig,'Tag','BLVValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         blv_value = curr_blv(row,coord_idx);
         set(h,'String',num2str(blv_value,'%9.6f'));
      end;

   else

      bs = getappdata(fig,'BSRatio');
      bs_coords = getappdata(fig,'BSRatioCoords');

      curr_bs = bs(:,lv_idx);
      curr_bs = reshape(curr_bs,[win_size,length(bs_coords)]);
      coord_idx = find(bs_coords == coord);

      h = findobj(fig,'Tag','BSValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         bs_value = curr_bs(row,coord_idx);
         set(h,'String',num2str(bs_value,'%9.6f'));
      end;
   end;

   h = findobj(fig,'Tag','XYZVoxel');
   set(h,'String',sprintf('%d %d %d %d', lag, xyz));

%   if get(findobj(fig, 'tag', 'XYZmmLabel'), 'value') == 2
 %     xyz_mm = mni2tal(xyz_mm);
  % end

   h = findobj(fig,'Tag','XYZmm');
   set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

   linkfig = getappdata(fig,'RFPlotHdl');
   linkcorrfig = getappdata(fig,'RFCorrPlotHdl');

   if isempty(linkfig) & isempty(linkcorrfig)	% do nothing as no response plot
       return;
   end;

   if ~isempty(linkcorrfig)	%getappdata(fig,'isbehav')
      set(findobj(linkcorrfig,'Tag','MessageLine'), 'string', '');
      figure(linkcorrfig); fmri_plot_corr('NewCoord',coord,xyz,lag);
   end

   if ~isempty(linkfig)
      set(findobj(linkfig,'Tag','MessageLine'), 'string', '');

      subj_group = getappdata(gcbf,'subj_group');

      if iscell(subj_group)
         figure(linkfig); ssb_fmri_plot_rf('NewCoord',coord,xyz,lag);
      else
         figure(linkfig); fmri_plot_rf('NewCoord',coord,xyz,lag);
      end
   end

   return; 					% EditXYZ


%--------------------------------------------------------------------------
function LoadResultFile()

   [PLSresultFile,PLSresultFilePath] = ...
                         rri_selectfile('*_fMRIresult.mat','Open PLS Result');
   if isequal(PLSresultFilePath,0), return; end;

   PLSResultFile = [PLSresultFilePath,PLSresultFile];

   DeleteLinkedFigure;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','arrow');

   h = findobj(gcf,'Tag','ResultFile');
   [r_path, r_file, r_ext] = fileparts(PLSResultFile);
   set(h,'UserData', PLSResultFile,'String',r_file);

   set(gcf,'Name',sprintf('PLS Brain Latent Variable Plot: %s',PLSResultFile));

   rot_amount = load_pls_result;
   fmri_result_3v_ui('Rotation', rot_amount);

   set(gcf,'Pointer',old_pointer);

   return;					% LoadResultFile


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

   if ~isequal(bg_dims,getappdata(gcf,'STDims'))
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

  try 				% load the dimension info of the st_datamat
     load(PLSresultFile,'st_dims','st_voxel_size','st_origin','st_coords'),
  catch
     msg =sprintf('ERROR: Cannot load the PLS result file "%s".',PLSresultFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;

  dims = st_dims([1 2 4]);
  img = zeros(dims);
  img = img(:);
  img(st_coords) = 1;
  img = reshape(img,dims);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-10);
  image_fn = [resultfile_prefix, 'background.img'];

  [filename,pathname] = rri_selectfile(image_fn,'Save brain region to IMG file');
  if isequal(filename,0)
      return;
  end;

  img_file = fullfile(pathname, filename);
  descrip = sprintf('Background Image from %s', PLSresultFile);
  rri_write_img(img_file,img,0,dims,st_voxel_size,16,st_origin,descrip);

  return;					% SaveBackgroundImage


%--------------------------------------------------------------------------
function [range, bar_data] = create_colorbar(axes_hdl,cmap,min_range,max_range)

   tick_steps = (max_range - min_range) / (size(cmap,1) - 1);
   y_range = [min_range:tick_steps:max_range];
   range = [max_range:-tick_steps:min_range];
   
   axes(axes_hdl);
   img_h = image([0,1],[min_range max_range],[1:size(cmap,1)]');

   %  use true colour for the colour bar to make sure change of colormap
   %  won't affect it
   %
   bar_data = get(img_h,'CData');
   len = length(bar_data);
   cdata = zeros(len,1,3);
   for i=1:len,
     cdata(i,1,:) = cmap(bar_data(i),:);
   end;
   set(img_h,'CData',cdata);

   %  setup the axes property
%   set(axes_hdl, 'XTick',[],'XLim',[0 1], ...
%            'YLim',[min_range max_range], ...
%	    'YDir','normal', ...
%            'YAxisLocation','right');
   set(axes_hdl, 'XTick',[], ...
            'YLim',[min_range max_range], ...
	    'YDir','normal', ...
            'YAxisLocation','right');

   return;


%--------------------------------------------------------------------------
function [axes_h,colorbar_h] = create_new_blv_figure();

   save_setting_status = 'on';
   fmri_result_newfig_pos = [];

   try
      load('pls_profile');
   catch 
   end

   if ~isempty(fmri_result_newfig_pos) & strcmp(save_setting_status,'on')

      pos = fmri_result_newfig_pos;

   else

      fig_w = 0.6;
      fig_h = 0.8;
      fig_x = (1 - fig_w)/2;
      fig_y = (1 - fig_h)/2;

      pos = [fig_x fig_y fig_w fig_h];

   end

   tit = get(gcbf,'name');

   fig_h = figure('Units','normal', ...
   	'Color',[0.8 0.8 0.8], ...
        'Name',tit, ...
        'NumberTitle','off', ...
   	'DoubleBuffer','on', ...
   	'Position',pos, ...
   	'DeleteFcn','fmri_result_3v_ui(''DeleteNewFigure'')', ...
	'InvertHardcopy','off', ...
	'PaperPositionMode', 'auto', ...
        'Userdata','Clone', ...
   	'Tag','PlotBrainLV2');

   rri_file_menu(fig_h);

   %

   x = .1;
   y = .1;
   w = .7;
   h = .85;

   pos = [x y w h];
   
   axes_h = axes('Parent',fig_h, ...				% axes
        'Units','normal', ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',[1 1 1], ...
  	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','BlvAxes');

   x = x+w+.03;
   w = .055;

   pos = [x y w h];

   colorbar_h = axes('Parent',fig_h, ...			% c axes
        'Units','normal', ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','Colorbar');

   setappdata(gcf,'Colorbar',colorbar_h);
   setappdata(gcf,'BlvAxes',axes_h);

   return; 						% create_new_blv_figure

%--------------------------------------------------------------------------
function  [min_ratio, max_ratio, bs_thresh, bs_thresh2] = set_bs_fields(lv_idx,p_value),

   bs_ratio = getappdata(gcf,'BSRatio');
   if isempty(bs_ratio),		 % no bootstrap data -> return;
       return;
   end;

   if ~exist('lv_idx','var') | isempty(lv_idx),
      lv_idx = 1;
   end;

%   if ~exist('p_value','var') | isempty(p_value),
%      p_value = 0.05;		% two-tail 5%
%   end;
%
%   cumulated_p = 1 - (p_value/2);
%
%   curr_bs_ratio = bs_ratio(:,lv_idx);
%   curr_bs_ratio(isnan(curr_bs_ratio)) = 0;
%   idx = find(abs(curr_bs_ratio) < std(curr_bs_ratio) * 5); % avoid the outliers
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

   setting.bs_thresh{lv_idx} = bs_thresh;
   setting.bs_thresh2{lv_idx} = bs_thresh2;
   setting.min_ratio{lv_idx} = min_ratio;
   setting.max_ratio{lv_idx} = max_ratio;
   setappdata(gcf,'setting',setting);

   set(findobj(gcf,'Tag','BSThreshold'),'String',sprintf('%8.5f',bs_thresh));
   set(findobj(gcf,'Tag','BSThreshold2'),'String',sprintf('%8.5f',bs_thresh2));
%   set(findobj(gcf,'Tag','PValue'),'String',sprintf('%8.5f',p_value));
   set(findobj(gcf,'Tag','MinRatio'),'String',sprintf('%8.5f',min_ratio));
   set(findobj(gcf,'Tag','MaxRatio'),'String',sprintf('%8.5f',max_ratio));

   return; 						% set_bs_field


%--------------------------------------------------------------------------
function  [min_blv, max_blv, thresh, thresh2] = set_blv_fields(lv_idx, thresh, thresh2),

   brainlv = getappdata(gcf,'BLVData');
   if isempty(brainlv),		 	% no brain lv data -> return;
       return;
   end;

   if ~exist('lv_idx','var') | isempty(lv_idx),
      lv_idx = 1;
   end;

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

      if ~exist('thresh','var') | isempty(thresh),
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
   end;

   setting.thresh{lv_idx} = thresh;
   setting.thresh2{lv_idx} = thresh2;
   setting.min_blv{lv_idx} = min_blv;
   setting.max_blv{lv_idx} = max_blv;
   setappdata(gcf,'setting',setting);

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
function OpenCorrelationPlot

  h = findobj(gcbf,'Tag','ResultFile');
  PLSresultFile = get(h,'UserData');
%  setappdata(gcbf,'actualHRF',0);		% for rf1_plot = bfm_plot_rf

%  load(PLSresultFile);

%  rf1_plot = getappdata(gcbf,'RF1PlotHdl');	% for rf1_plot = bfm_plot_rf
  rf1_plot = getappdata(gcbf,'RFCorrPlotHdl');
  if ~isempty(rf1_plot)
      msg = 'ERROR: Response function plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

%  rf1_plot = bfm_plot_rf('LINK',PLSresultFile);
  rf1_plot = fmri_plot_corr('LINK',PLSresultFile);
  link_info.hdl = gcbf;
%  link_info.name = 'RF1PlotHdl';		% for rf1_plot = bfm_plot_rf
  link_info.name = 'RFCorrPlotHdl';
  setappdata(rf1_plot,'LinkFigureInfo',link_info);
%  setappdata(gcbf,'RF1PlotHdl',rf1_plot);	% for rf1_plot = bfm_plot_rf
  setappdata(gcbf,'RFCorrPlotHdl',rf1_plot);

  %  make sure the Coord of the Response Function Plot contains
  %  the current point in the Response
  %
  cur_coord = getappdata(gcbf,'Coord');
  setappdata(rf1_plot,'Coord',cur_coord);

  return;					% OpenCorrelationPlot


%-------------------------------------------------------------------------
%
function OpenBrainCorrelationPlot()

  h = findobj(gcf,'Tag','ResultFile');
  PLSresultFile = get(h,'UserData');

  bcor_plot = getappdata(gcf,'BcorPlotHdl');
  if ~isempty(bcor_plot)
      msg = 'ERROR: Brain correlation plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  sessionFileList = getappdata(gcbf,'SessionFileList');

  bcor_plot = fmri_plot_brain_corr('LINK',sessionFileList,PLSresultFile);
  link_info.hdl = gcbf;
  link_info.name = 'BcorPlotHdl';
  setappdata(bcor_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'BcorPlotHdl',bcor_plot);

  return;					% OpenBrainCorrelationPlot


%-------------------------------------------------------------------------
%
function OpenDatamatcorrsPlot

   datamatcorrs_fig = getappdata(gcbf,'DatamatcorrsPlotHdl');
   if ~isempty(datamatcorrs_fig) & ishandle(datamatcorrs_fig)
      msg = 'ERROR: Datamat Correlations Plot has already been plotted';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   datamatcorrs_fig = fmri_plot_datamatcorrs_3v;

   link_info.hdl = gcbf;
   link_info.name = 'DatamatcorrsPlotHdl';
   setappdata(datamatcorrs_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'DatamatcorrsPlotHdl',datamatcorrs_fig);

   return;


%-------------------------------------------------------------------------
%
function CloseFigure

   splash_fig = getappdata(getappdata(gcf,'CallingFigure'),'CallingFigure');
   close(getappdata(gcf,'CallingFigure'));
   close(gcbf);

   if ishandle(splash_fig)
      set(splash_fig,'visible','on');
   end

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

      st_origin = getappdata(gcf,'STOrigin');
      st_voxel_size = getappdata(gcf,'STVoxelSize');

      xyz_offset = xyz_mm ./ st_voxel_size;
      xyz = round(xyz_offset + st_origin);

      lag = get(findobj(gcbf,'tag','XYZVoxel'), 'string');

      if isempty(lag)
         lag = 0;
      else
         lag = str2num(lag);
         lag = lag(1);
      end

      xyz = [lag xyz];
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

   origin = getappdata(gcf,'STOrigin');
   voxel_size = getappdata(gcf,'STVoxelSize');

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


%--------------------------------------------------------------------------
function RescaleBnPress()

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');
   lv_idx = str2num(get(lv_idx_hdl,'String'));
   set_blv_fields(lv_idx);

   set(gcf,'Pointer',old_pointer);

   return;					% RescaleBnPress


%-------------------------------------------------------------------------
%
function OpenTBrainScoresPlot()

   taskpls_fig = getappdata(gcbf,'taskplsHdl');
   if ~isempty(taskpls_fig)
      msg = 'ERROR: Brain Scores Plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   h = findobj(gcbf,'Tag','ResultFile');
   PLSresultFile = get(h,'UserData');

   taskpls_fig = fmri_plot_taskpls_bs('LINK',PLSresultFile);

   lv_idx = getappdata(gcbf,'CurrLVIdx');
   if (lv_idx ~= 1)
      fmri_plot_taskpls_bs('UPDATE_LV_SELECTION',taskpls_fig,lv_idx);
   end;

   link_info.hdl = gcbf;
   link_info.name = 'taskplsHdl';

   if ishandle(taskpls_fig)
      setappdata(taskpls_fig,'LinkFigureInfo',link_info);
      setappdata(gcbf,'taskplsHdl',taskpls_fig);
   end

   return;					% OpenTBrainScoresPlot

