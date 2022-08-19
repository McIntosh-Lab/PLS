function fig = fmri_plot_datamatcorrs_3v(action,varargin)

   if ~exist('action','var') | isempty(action)

%      [PLSresultFile,PLSresultFilePath] =  ...
%                        rri_selectfile('*_fMRIresult.mat','Open PLS Result');
%      if (PLSresultFilePath == 0), return; end;
%      PLSResultFile = fullfile(PLSresultFilePath,PLSresultFile);

      h = findobj(gcbf,'Tag','ResultFile');
      PLSResultFile = get(h,'UserData');
%      PLSResultFile = 'C:\m_data\plsdata\fmrisubj\t2_BfMRIresult.mat';

      msg = 'Loading Datamat Correlations Data ...    Please wait!';
      hb = rri_wait_box(msg, [0.5 0.1]);

      fig_h = init(PLSResultFile);

      setappdata(gcf,'CallingFigure',gcbf); 
%      set(gcbf,'visible','off');

      rot_amount = load_pls_result;
%      fmri_plot_datamatcorrs_3v('Rotation', rot_amount);
      ShowResult(0,0);


      EditXYZ;


	%  this has to be put at the bottom. otherwise
	%  program will fail on new MATLAB
	%
      if (nargout > 0),
        fig = fig_h;
      end;

      delete(hb);


      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   if (strcmp(action,'PlotBnPress'))
     ShowResult(0,1);                % display brainlv inside the Plot BLV figure
     EditXYZ;
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
   elseif (strcmp(action,'Toggle_View'))
     ToggleView;
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
   elseif (strcmp(action,'EditGroup'))
     EditGroup;
   elseif (strcmp(action,'EditBehav'))
     EditBehav;
   elseif (strcmp(action,'EditLV'))
     EditLV;
   elseif (strcmp(action,'EditLag'))
     EditLag;
   elseif (strcmp(action,'EditBSLV'))
     EditBSLV;
   elseif (strcmp(action,'UpdatePValue'))
     UpdatePValue;   
   elseif (strcmp(action,'SelectPixel'))
     SelectPixel;
   elseif (strcmp(action,'DeleteNewFigure'))
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         fmri_plot_datamatcorrs_3v_newfig_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'fmri_plot_datamatcorrs_3v_newfig_pos');
      catch
      end
   elseif (strcmp(action,'DeleteFigure'))
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         fmri_plot_datamatcorrs_3v_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'fmri_plot_datamatcorrs_3v_pos');
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
 %              setting6 = setting;
  %             save(PLSresultFile, '-append', 'setting6');
            catch
               msg = 'Cannot save setting information';
               msgbox(msg,'ERROR','modal');
            end
         end
      end

%      DeleteLinkedFigure;
%      calling_fig = getappdata(gcf,'CallingFigure');
%      set(calling_fig,'visible','on');
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
   elseif (strcmp(action,'OpenEigenPlot'))
     OpenEigenPlot;
   elseif (strcmp(action,'OpenContrastWindow'))
     OpenContrastWindow;
   elseif (strcmp(action,'SetClusterReportOptions')) 
     SetClusterReportOptions;
   elseif (strcmp(action,'LoadClusterReport')) 
     fmri_cluster_report('LoadClusterReport',gcbf);
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
   elseif (strcmp(action,'EditXYZ'))
      EditXYZ;
      ShowResult(0,1);
   elseif (strcmp(action,'EditXYZmm'))
      xyz_mm = str2num(get(findobj(gcbf,'tag','XYZmm'),'string'));

      if isempty(xyz_mm) | ~isequal(size(xyz_mm),[1 3])
         msg = 'XYZ(mm) should contain 3 numbers (X, Y, and Z)';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end

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
   end;

   return;


%---------------------------------------------------------------------------
%
function h0 = init(PLSResultFile);

   setting6 = [];
   warning off;
   load(PLSResultFile, 'setting6');
   setting = setting6;
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
   fmri_plot_datamatcorrs_3v_pos = [];

   try
      load('pls_profile');
   catch 
   end

   if ~isempty(fmri_plot_datamatcorrs_3v_pos) & strcmp(save_setting_status,'on')

      pos = fmri_plot_datamatcorrs_3v_pos;

   else

      fig_w = 0.85;
      fig_h = 0.8;
      fig_x = (1 - fig_w)/2;
      fig_y = (1 - fig_h)/2;

      pos = [fig_x fig_y fig_w fig_h];

   end

%   [r_path,r_file,r_ext] = fileparts(PLSResultFile);

   h0 = figure('Units','normal', ...
   	'Color',[0.8 0.8 0.8], ...
        'Name','fMRI BLV Plot', ...
        'NumberTitle','off', ...
   	'DoubleBuffer','on', ...
   	'MenuBar','none',...
   	'Position',pos, ...
   	'DeleteFcn','fmri_plot_datamatcorrs_3v(''DeleteFigure'')', ...
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

   x = .03;
   y = .95;
   w = .14;
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
   	'String','Group Index:', ...
   	'Style','text', ...
   	'Tag','ResultFileLabel');

   x = x+w;
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
   	'Callback','fmri_plot_datamatcorrs_3v(''EditGroup'')', ...
   	'Tag','GroupIndexEdit');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','of', ...
   	'Style','text', ...
        'UserData', PLSResultFile, ...
   	'Tag','ResultFile');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','GroupNumberEdit');

   x = .03;
   y = y-h;
   w = .14;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Condition Index:', ...
   	'Style','text', ...
   	'Tag','LVIndexLabel');

   x = x+w;
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
   	'Callback','fmri_plot_datamatcorrs_3v(''EditLV'')', ...
   	'Tag','LVIndexEdit');

   x = x+w;

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

   x = .03;
   y = y-h;
   w = .14;

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

   x = .03;
   y = y-h;
   w = .14;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...	
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Behavior Index:', ...
   	'Style','text', ...
   	'Tag','BehavIndexLabel');

   x = x+w;
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
   	'Callback','fmri_plot_datamatcorrs_3v(''EditBehav'')', ...
   	'Tag','BehavIndexEdit');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% behav number label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','of', ...
   	'Style','text', ...
   	'Tag','BehavNumberLabel');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% behav number text
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','BehavNumberEdit');

   %  Slice Selection

   x = .03;
   y = .7;
   w = .26;
   h = .16;

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
   y = .8;
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
   	'Callback','fmri_plot_datamatcorrs_3v(''EditFirstSlice'')', ...
	'visible','off', ...
   	'Tag','FirstSlice');

   x = .05;
   y = y-h;
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
   	'Callback','fmri_plot_datamatcorrs_3v(''EditStep'')', ...
	'visible','off', ...
   	'Tag','SliceStep');

   x = .05;
   y = y-h;
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
   	'Callback','fmri_plot_datamatcorrs_3v(''EditLastSlice'')', ...
	'visible','off', ...
   	'Tag','LastSlice');

   slice_frame_h = 0.12;

   %  Brain LV

   x = .03;
   y = .23;
   w = .26;
   h = .45;

   y = y + slice_frame_h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','ThresholdFrame');

   x = .08;
   y = .65;
   w = .16;
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
   	'String','Datamat Correlations', ...
   	'Style','text', ...
   	'Tag','BLVTitle');

   x = .05;
   y = .6;
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
   	'String','Threshold:', ...
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
   	'Tag','Threshold');

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
   	'Tag','MinValue');

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
   	'String','LV Index:', ...
   	'Style','text', ...
   	'Tag','BSLVIndexLabel');

   x = x+w;
   y = y+.01;
   w = .05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv index edit
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','fmri_plot_datamatcorrs_3v(''EditBSLV'')', ...
   	'Tag','BSLVIndexEdit');

   x = x+w;
   y = y-.01;
   w = .03;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv number label
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','of', ...
   	'Style','text', ...
   	'Tag','BSLVNumberLabel');

   x = x+w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% lv number text
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','BSLVNumberEdit');

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
   	'String','BS Threshold:', ...
   	'Style','text', ...
   	'Tag','BSThresholdLabel');

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
   	'Callback','fmri_plot_datamatcorrs_3v(''UpdatePValue'')', ...
   	'Tag','BSThreshold');

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
   	'String','Min. Ratio:', ...
   	'Style','text', ...
   	'Tag','MinRatioLabel');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','MinRatio');

   x = .05;
   y = y-h;
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
   	'String','Max. Ratio:', ...
   	'Style','text', ...
   	'Tag','MaxRatioLabel');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
   	'Tag','MaxRatio');


   %  Voxel Location

   x = .03;
   y = .1;
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

   x = .05;
   y = .16;
   w = .07;
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
   	'Callback','fmri_plot_datamatcorrs_3v(''EditXYZ'')');

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
   	'Callback','fmri_plot_datamatcorrs_3v(''EditXYZ'')', ...
   	'Tag','XYZVoxel');

   x = .05;
   y = y-h-0.02;
   w = .07;

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
   	'Tag','XYZmmLabel');

   x = x+w;
   w = .15;

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
   	'Callback','fmri_plot_datamatcorrs_3v(''EditXYZmm'')', ...
   	'Tag','XYZmm');

   x = .05;
   y = .05;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'Callback','fmri_plot_datamatcorrs_3v(''PlotBnPress'')', ...
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
   	'Callback','close(gcf)', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','CLOSE', ...
   	'Tag','EXITButton');

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
           'Callback','fmri_plot_datamatcorrs_3v(''LoadBackgroundImage'')'); 
   h2 = uimenu(h_file, ...
           'Label','Save brain region to IMG file', ...
   	   'Tag','SaveBGImage', ...
           'Callback','fmri_plot_datamatcorrs_3v(''SaveBackgroundImage'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Load PLS Result', ...
   	   'Tag','LoadPLSResult', ...
		'visible', 'off', ...
           'Callback','fmri_plot_datamatcorrs_3v(''LoadResultFile'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Save Current Display to the IMG files', ...
   	   'Tag','SaveDisplayToIMG', ...
           'Callback','fmri_plot_datamatcorrs_3v(''SaveDisplayToIMG'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Save DatamatCorrelation to IMG file', ...
   	   'Tag','SaveResultToIMG', ...
           'Callback','fmri_plot_datamatcorrs_3v(''SaveResultToIMG'')'); 
   h2 = uimenu(h_file, ...
           'Label','Create Datamat Correlations &Figure', ...
   	   'Tag','PlotNewFigure', ...
           'Callback','fmri_plot_datamatcorrs_3v(''PlotOnNewFigure'')'); 

   rri_file_menu(h0);

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
           'Callback','fmri_plot_datamatcorrs_3v(''Zooming'')', ...
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
           'Callback','fmri_plot_datamatcorrs_3v(''Rotation'',1)', ...
   	   'Tag','Rotate0Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&90 degree', ...
   	   'Checked','off', ...
           'Callback','fmri_plot_datamatcorrs_3v(''Rotation'',2)', ...
   	   'Tag','Rotate90Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&180 degree', ...
   	   'Checked','off', ...
           'Callback','fmri_plot_datamatcorrs_3v(''Rotation'',3)', ...
   	   'Tag','Rotate180Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&270 degree', ...
   	   'Checked','off', ...
           'Callback','fmri_plot_datamatcorrs_3v(''Rotation'',0)', ...
   	   'Tag','Rotate270Menu');

   %  Window submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Windows', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','off');
   h2 = uimenu(h_pls, ...
           'Label','&Singular Values Plot', ...
     	   'Tag','OpenEigenPlot', ...
           'Callback','fmri_plot_datamatcorrs_3v(''OpenEigenPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Behavior LV and Behavior Scores Plot', ...
     	   'Tag','OpenBehavPlot', ...
           'Visible', 'off', ...
           'Callback','bfm_result_ui(''OpenScoresPlot'',0)');
   h2 = uimenu(h_pls, ...
           'Label','&Design Scores and LVs Plot', ...
     	   'Tag','OpenDesignPlot', ...
           'Visible', 'off', ...
           'Callback','fmri_plot_datamatcorrs_3v(''OpenDesignPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','B&rain Scores vs. Behavior Data Plot', ...
     	   'Tag','OpenBrainPlot', ...
           'Visible', 'off', ...
           'Callback','bfm_result_ui(''OpenBrainPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Canonical Brain Scores Plot', ...
     	   'Tag','OpenBrainScoresPlot', ...
           'Callback','fmri_plot_datamatcorrs_3v(''OpenBrainScoresPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Response Function Plot', ...
     	   'Tag','OpenRFPlot', ...
           'Callback','fmri_plot_datamatcorrs_3v(''OpenResponseFnPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Datamat Correlations Response', ...
     	   'Tag','OpenRF1Plot', ...
           'Callback','fmri_plot_datamatcorrs_3v(''OpenCorrelationPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Datamat Correlations Plot', ...
     	   'Tag','OpenDatamatcorrsPlot', ...
           'Callback','fmri_plot_datamatcorrs_3v(''OpenDatamatcorrsPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Contrasts Information', ...
     	   'Tag','OpenContrastWindow', ...
           'Callback','fmri_plot_datamatcorrs_3v(''OpenContrastWindow'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Create Brain LV &Figure', ...
	   'separator', 'on', ...
   	   'Tag','PlotNewFigure', ...
           'Callback','fmri_plot_datamatcorrs_3v(''PlotOnNewFigure'')'); 


   %  Report submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Report', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','off');
   h2 = uimenu(h_pls, ...
           'Label','&Set Cluster Report Options', ...
     	   'Tag','SetClusterReportOptions', ...
           'Callback','fmri_plot_datamatcorrs_3v(''SetClusterReportOptions'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Load Cluster Report', ...
     	   'Tag','LoadClsuterReport', ...
           'Callback','fmri_plot_datamatcorrs_3v(''LoadClusterReport'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Create Cluster Report', ...
     	   'Tag','OpenClusterReport', ...
           'Callback','fmri_plot_datamatcorrs_3v(''OpenClusterReport'')'); 

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
		'visible', 'off', ...
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

   setappdata(gcf,'ClusterMinSize',5);
   setappdata(gcf,'ClusterMinDist',10);

   setappdata(gcf,'setting',setting);
   setappdata(gcf,'old_setting',setting);

   setappdata(gcf,'img_xhair',[]);

   return;						% init


%---------------------------------------------------------------------------
%
function DeleteLinkedFigure()

   rf_plot = getappdata(gcbf,'RFPlotHdl');
   if ~isempty(rf_plot) & ishandle(rf_plot)
     close(rf_plot);
   end;

   scores_fig = getappdata(gcbf,'ScorePlotHdl');
   if ~isempty(scores_fig)
     close(scores_fig);
   end;

   bscores_fig = getappdata(gcbf,'BSPlotHdl');
   if ~isempty(bscores_fig) & ishandle(bscores_fig)
     close(bscores_fig);
   end;

   eigen_fig = getappdata(gcbf,'EigenPlotHdl');
   if ~isempty(eigen_fig) & ishandle(eigen_fig)
     close(eigen_fig);
   end;

   brain_fig = getappdata(gcbf,'brain_plot');
   if ~isempty(brain_fig) & ishandle(brain_fig)
     close(brain_fig);
   end;

   contrast_fig = getappdata(gcbf,'ContrastFigHdl');
   if ~isempty(contrast_fig) & ishandle(contrast_fig)
     close(contrast_fig);
   end;
   
   return;						% DeleteLinkedFigure


%---------------------------------------------------------------------------
%
function rot_amount = load_pls_result()

   %  wait message
   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   msg = 'Loading PLS result ... please wait';
   set(findobj(gcf,'Tag','MessageLine'),'String',msg);

   h = findobj(gcf,'Tag','ResultFile');
   PLSresultFile = get(h,'UserData');

   load(PLSresultFile);

   if exist('bscan','var') & ~isempty(bscan)
      num_conditions = length(bscan);
   end

if(0)
   if exist('datamatcorrs_lst','var')
      setappdata(gcf,'isbehav',1);
      set(findobj(gcf,'tag','OpenRFPlot'), 'visible', 'off');
   else
      setappdata(gcf,'isbehav',0);
      set(findobj(gcf,'tag','OpenRF1Plot'), 'visible', 'off');
   end

   if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
   end
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
      grp_idx = 1;					% group idx
      lv_idx = 1;					% condition idx
      bs_lv_idx = 1;
      behav_idx = 1;					% behavior idx
      rot_amount = 1;
      first_slice = 1;
      last_slice = num_slices;
   else
      grp_idx = setting.grp_idx;
      lv_idx = setting.lv_idx;
      if isfield(setting, 'bs_lv_idx')
         bs_lv_idx = setting.bs_lv_idx;
      else
         bs_lv_idx = 1;
      end
      behav_idx = setting.behav_idx;
      rot_amount = setting.rot_amount;
      first_slice = setting.first_slice;
      slice_step = setting.slice_step;
      last_slice = setting.last_slice;
   end;

   num_grp = length(num_subj_lst);
   num_lv = num_conditions;
   num_lag = st_win_size - 1;
   bs_num_lv = size(brainlv,2);

   brainlv = datamatcorrs_lst{grp_idx};
   num_behav = size(brainlv, 1) / num_conditions;

   if exist('behavlv','var')
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'On');
   elseif exist('designlv','var')
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'Off');
   end

   h = findobj(gcf,'Tag','GroupIndexEdit');
   set(h,'String',num2str(grp_idx),'Userdata',grp_idx);
   h = findobj(gcf,'Tag','GroupNumberEdit');
   set(h,'String',num2str(num_grp),'Userdata',num_grp);
   h = findobj(gcf,'Tag','LVIndexEdit');
   set(h,'String',num2str(lv_idx),'Userdata',lv_idx);
   h = findobj(gcf,'Tag','LVNumberEdit');
   set(h,'String',num2str(num_lv),'Userdata',num_lv);
   h = findobj(gcf,'Tag','LagIndexEdit');
   set(h,'String',num2str(lag_idx),'Userdata',lag_idx);
   h = findobj(gcf,'Tag','LagNumberEdit');
   set(h,'String',num2str(num_lag),'Userdata',num_lag);

   h = findobj(gcf,'Tag','BSLVIndexEdit');
   set(h,'String',num2str(bs_lv_idx),'Userdata',bs_lv_idx);
   h = findobj(gcf,'Tag','BSLVNumberEdit');
   set(h,'String',num2str(bs_num_lv),'Userdata',bs_num_lv);

   h = findobj(gcf,'Tag','FirstSlice');
   set(h,'String',num2str(first_slice),'Userdata',num_slices);
   h = findobj(gcf,'Tag','SliceStep');
   set(h,'String',num2str(slice_step),'Userdata',num_slices);
   h = findobj(gcf,'Tag','LastSlice');
   set(h,'String',num2str(last_slice),'Userdata',num_slices);

   h = findobj(gcf,'Tag','BehavIndexEdit');
   set(h,'String',num2str(behav_idx),'Userdata',behav_idx);
   h = findobj(gcf,'Tag','BehavNumberEdit');
   set(h,'String',num2str(num_behav),'Userdata',num_behav);

   brainlv_lst = {};

   for g = 1:num_grp

      brainlv = datamatcorrs_lst{g};		% borrow 'blv' name to reuse code

      r = size(brainlv, 1) / num_conditions;
      c = size(brainlv, 2);

      for b = 1:num_behav

         mask = [0:(num_conditions-1)]*num_behav + b;
         tmp = brainlv(mask, :);
         tmp = tmp';
         brainlv_lst{g,b} = tmp;

%         for i = 1:num_conditions
%            tmp{i} = brainlv(r*(i-1)+1:r*i, :);
%         end  
%
%         brainlv = ones(num_conditions, c);
%
%         for i = 1:num_conditions
%            brainlv(i,:) = mean(tmp{i},1);
%         end
%
%         brainlv = brainlv';
%         brainlv_lst{g} = brainlv;

      end
   end


   setappdata(gcf,'BLVData',brainlv_lst);
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   if ~exist('boot_result','var') | isempty(boot_result)
      ToggleView(0);
      set(findobj(gcf,'Tag','ViewMenu'),'Visible','off');
   else					% show bootstrap ratio if exist
      ToggleView(1);
      set(findobj(gcf,'Tag','ViewMenu'),'Visible','on');

      % set the bootstrap ratio field values
      %
      setappdata(gcf,'BSRatio',boot_result.compare);
      set_bs_fields(bs_lv_idx, 0.05);
      UpdatePValue;
   end;

   h = findobj(gcf,'Tag','OpenContrastWindow');
   if 1 % isequal(ContrastFile,'NONE') | isequal(ContrastFile,'BEHAV')
      set(h,'Visible','off');
   else
      set(h,'Visible','on');
   end;

   set(gcf,'Pointer',old_pointer);
   set(findobj(gcf,'Tag','MessageLine'),'String','');

   setappdata(gcf,'SessionFileList', SessionProfiles);
   setappdata(gcf,'RotateAmount',rot_amount);
   setappdata(gcf,'CurrGroupIdx',grp_idx);
   setappdata(gcf,'CurrBehavIdx',behav_idx);
   setappdata(gcf,'NumGroup',num_grp);
   setappdata(gcf,'CurrLVIdx',lv_idx);
   setappdata(gcf,'CurrLagIdx',lag_idx);
   setappdata(gcf,'CurrBSLVIdx',bs_lv_idx);
   setappdata(gcf,'STDims',st_dims);
   setappdata(gcf,'NumBSLVs',bs_num_lv)

   return;						% load_pls_result


%-------------------------------------------------------------------------
%
function OpenResponseFnPlot()

  sessionFileList = getappdata(gcbf,'SessionFileList');

  rf_plot = getappdata(gcf,'RFPlotHdl');
  if ~isempty(rf_plot)
      msg = 'ERROR: Response function plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  rf_plot = fmri_plot_rf('LINK',sessionFileList);
  link_info.hdl = gcbf;
  link_info.name = 'RFPlotHdl';
  setappdata(rf_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'RFPlotHdl',rf_plot);

  %  make sure the Coord of the Response Function Plot contains 
  %  the current point in the Response
  %
  cur_coord = getappdata(gcf,'Coord');
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

   eigen = load(PLSresultFile,'s','perm_result');
   eigen_fig = rri_plot_eigen_ui({eigen.s, eigen.perm_result});

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
   cluster_min_size = getappdata(gcbf,'ClusterMinSize');
   cluster_min_dist = getappdata(gcbf,'ClusterMinDist');

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

   prompt = {'Minimum cluster size (in voxels)',  ...
	     'Minimum distance (in mm) between cluster peaks', ...
	     'Origin location (in voxels)' };
   defValues = { num2str(cluster_min_size), ...
		 num2str(cluster_min_dist), ...
		 num2str(st_origin)};
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

   if isempty(min_size) | isempty(min_dist) | isempty(origin_xyz)
      invalid_options = 1;
   elseif (min_size <= 0) | (min_dist <= 0) | (sum(origin_xyz<= 0) ~= 0)
      invalid_options = 1;
   end;   
   
   if (invalid_options)
	msg = 'Invalid cluster report options.  Options do not changed';
	set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
	return;
   end;

   setappdata(gcbf,'STOrigin',origin_xyz);
   setappdata(gcbf,'ClusterMinSize',min_size);
   setappdata(gcbf,'ClusterMinDist',min_dist);

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

   fmri_cluster_report(cluster_min_size,cluster_min_dist);


   set(gcbf,'Pointer',old_pointer);
   set(findobj(gcbf,'Tag','MessageLine'),'String','');

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

   load(PLSresultFile,'ContrastFile','SessionProfiles');

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

   contrast_fig = fmri_input_contrast_ui(pls_contrasts,conditions,1);

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

  h = findobj(gcf,'Tag','BSLVIndexEdit');  bs_lv_idx = get(h,'Userdata');
  curr_bs_lv_idx = getappdata(gcf,'CurrBSLVIdx');
  if (bs_lv_idx ~= curr_bs_lv_idx),
     bs_lv_idx = curr_bs_lv_idx;
     set(h,'String',num2str(bs_lv_idx));
  end;

  h = findobj(gcf,'Tag','GroupIndexEdit');  grp_idx = get(h,'Userdata');
  curr_grp_idx = getappdata(gcf,'CurrGroupIdx');
  if (grp_idx ~= curr_grp_idx),
     grp_idx = curr_grp_idx;
     set(h,'String',num2str(grp_idx));
  end;

  h = findobj(gcf,'Tag','BehavIndexEdit');  behav_idx = get(h,'Userdata');
  curr_behav_idx = getappdata(gcf,'CurrBehavIdx');
  if (behav_idx ~= curr_behav_idx),
     behav_idx = curr_behav_idx;
     set(h,'String',num2str(behav_idx));
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

  setting = getappdata(gcf,'setting');

  if isempty(setting) | ~isfield(setting,'origin')
     setting.origin = getappdata(gcf,'STOrigin');
  else
     setappdata(gcf,'STOrigin',setting.origin);
     setappdata(gcf,'Origin',setting.origin);
  end;

  if (getappdata(gcf,'ViewBootstrapRatio') == 0),	% plot brain lv 

     h = findobj(gcf,'Tag','Threshold');  thresh = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MaxValue');   max_blv = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MinValue');   min_blv = str2num(get(h,'String'));

     if isempty(max_blv) | isempty(min_blv) | isempty(thresh) | ...
	   (abs(max_blv) < thresh) | (abs(min_blv) < thresh)
        msg = 'ERROR: Invalid threshold, minimum or maxinum value setting.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        set(fig_hdl,'Pointer',old_pointer);
        h = findobj(gcf,'Tag','Threshold');  set(h,'String','0');
        thresh = 0;
     end;

     range = [min_blv max_blv];
     switch action 
       case {0}
          plot_st_brainlv(PLSresultFile,grp_idx,behav_idx,lv_idx,lag_idx,[],thresh,range,0,[],update);
       case {1}
          plot_st_brainlv(PLSresultFile,grp_idx,behav_idx,lv_idx,lag_idx,[],thresh,range,1,[],update);
     end;

  else							% plot bootstrap ratio

     h = findobj(gcf,'Tag','Threshold');  thresh = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MaxValue');   max_blv = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MinValue');   min_blv = str2num(get(h,'String'));

     if isempty(max_blv) | isempty(min_blv) | isempty(thresh) | ...
	   (abs(max_blv) < thresh) | (abs(min_blv) < thresh)
        msg = 'ERROR: Invalid threshold, minimum or maxinum value setting.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        set(fig_hdl,'Pointer',old_pointer);
        h = findobj(gcf,'Tag','Threshold');  set(h,'String','0');
        thresh = 0;
     end;

     h = findobj(gcf,'Tag','BSThreshold'); 
     thresh_ratio = str2num(get(h,'String')); 
     h = findobj(gcf,'Tag','MaxRatio'); max_ratio = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MinRatio'); min_ratio = str2num(get(h,'String'));

     if isempty(max_ratio) | isempty(min_ratio) | isempty(thresh_ratio) | ...
	   (abs(max_ratio) < thresh_ratio) | (abs(min_ratio) < thresh_ratio)
        msg = 'ERROR: Invalid threshold, minimum or maxinum ratio setting.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        set(fig_hdl,'Pointer',old_pointer);
        h = findobj(gcf,'Tag','BSThreshold');  set(h,'String','0');
        thresh_ratio = 0;
     end;;

     range = [min_ratio max_ratio];
     switch action 
       case {0}
          plot_bs_ratio(PLSresultFile,grp_idx,behav_idx,lv_idx,lag_idx,[],thresh,range,0,[],update);
       case {1}
          plot_bs_ratio(PLSresultFile,grp_idx,behav_idx,lv_idx,lag_idx,[],thresh,range,1,[],update);
     end;

  end;

  set(fig_hdl,'Pointer',old_pointer);

  setting = getappdata(gcf,'setting');

  if isempty(setting) | ~isfield(setting,'origin')
     setting.origin = getappdata(gcf,'STOrigin');
  else
     setappdata(gcf,'STOrigin',setting.origin);
     setappdata(gcf,'Origin',setting.origin);
  end;

  setting.grp_idx = grp_idx;
  setting.lv_idx = lv_idx;
  setting.lag_idx = lag_idx;
  setting.bs_lv_idx = bs_lv_idx;
  setting.behav_idx = behav_idx;
  setting.rot_amount = getappdata(gcf,'RotateAmount');

  setting.first_slice = first_slice;
  setting.slice_step = step;
  setting.last_slice = last_slice;

  setting.thresh{grp_idx,lv_idx,behav_idx} = thresh;
  setting.min_blv{grp_idx,lv_idx,behav_idx} = min_blv;
  setting.max_blv{grp_idx,lv_idx,behav_idx} = max_blv;

  if getappdata(gcf,'ViewBootstrapRatio')		% plot bsr
     setting.bs_thresh{bs_lv_idx} = str2num(get(findobj(gcf,'Tag','BSThreshold'),'String'));
  end

  setappdata(gcf,'setting',setting);

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


  xhair_color = get(findobj(gcf,'tag','XhairColorMenu'), 'user');
  set(img_xhair.lx, 'color', xhair_color);
  set(img_xhair.ly, 'color', xhair_color);

  setappdata(gcf,'img_xhair',img_xhair);
end

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
function plot_st_brainlv(PLSresultFile,grp_idx,behav_idx,lv_idx,lag_idx,slice_idx,thresh,range,new_fig,cluster_info,update)
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

  load(PLSresultFile,'st_dims','st_win_size','st_coords','st_voxel_size', ...
		'st_origin','num_conditions','behavdata');

%  if ~exist('slice_idx','var')
  if isempty(slice_idx)
     slice_idx = [1:st_dims(4)];
  end
  num_slices = length(slice_idx);

  num_lv = num_conditions;
  num_lag = st_win_size - 1;
  num_behav = size(behavdata,2);

  if ~exist('thresh','var') 
     thresh = [];
  end;

  h = findobj(gcf,'Tag','Threshold');  thresh = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','MaxValue');   max_blv = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','MinValue');   min_blv = str2num(get(h,'String'));

  if ~exist('range','var') | isempty(range)
     range = [min_blv max_blv];  
  else
     min_blv = range(1);
     max_blv = range(2);
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

  brainlv_lst = getappdata(gcf,'BLVData');
  brainlv = brainlv_lst{grp_idx,behav_idx};

  %  construct the brainlv images
  %
%  blv_imgs = zeros(win_size*img_height,mont_width);
  first_rows = 1; last_rows = img_height;

%  for i=1:win_size,
     i = lag_idx + 1;
     blv = brainlv(i:win_size:end,lv_idx);

        cluster_idx = st_coords;

     [img,cmap,cbar] = fmri_plot_brainlv(blv,st_coords,st_dims,slice_idx, ...
		abs(thresh),-1*abs(thresh),range,rot_amount,bg_img,cluster_idx);

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

  set(h_img,'ButtonDownFcn','fmri_plot_datamatcorrs_3v(''SelectPixel'')');
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

        opt.setbuttondown = 'fmri_plot_datamatcorrs_3v(''SelectPixel'');';
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

    nii_view = getappdata(gcf,'nii_view');

    h = findobj(gcf,'Tag','XYZVoxel');
    set(h,'String',sprintf('%d %d %d %d',lag_idx,nii_view.imgXYZ.vox));

    h = findobj(gcf,'Tag','XYZmm');
    set(h,'String',sprintf('%2.1f %2.1f %2.1f',nii_view.imgXYZ.mm));

    setappdata(gcf,'xyz',nii_view.imgXYZ.vox);


  create_colorbar( colorbar_hdl, cbar, min_blv, max_blv );

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
  setappdata(gcf,'NumBehav',num_behav);
%  setappdata(gcf,'BLVData',brainlv);
  setappdata(gcf,'BLVCoords',st_coords);
  setappdata(gcf,'BLVThreshold',thresh);  
  setappdata(gcf,'RotateAmount',rot_amount);
  setappdata(gcf,'cmap',cmap);

  return;					% plot_st_brainlv


%-------------------------------------------------------------------------
%   
function plot_bs_ratio(PLSresultFile,grp_idx,behav_idx,lv_idx,lag_idx,slice_idx,thresh,range,new_fig,cluster_info,update)
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

  load(PLSresultFile,'st_dims','st_win_size','st_coords','st_voxel_size', ...
		'st_origin','num_conditions','behavdata','boot_result');

  if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
  end

  bs_ratio = boot_result.compare_brain;

%  if ~exist('slice_idx','var')
  if isempty(slice_idx)
     slice_idx = [1:st_dims(4)];
  end
  num_slices = length(slice_idx);

  num_lv = num_conditions;
  num_lag = st_win_size - 1;
  num_behav = size(behavdata,2);

  if ~exist('thresh','var') 
     thresh = [];
  end;

  h = findobj(gcf,'Tag','Threshold');  thresh = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','MaxValue');   max_blv = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','MinValue');   min_blv = str2num(get(h,'String'));

  h = findobj(gcf,'Tag','BSLVIndexEdit'); bs_lv_idx = str2num(get(h,'String'));
  h = findobj(gcf,'Tag','BSThreshold'); bs_thresh = str2num(get(h,'String'));

  bs = bs_ratio(:, bs_lv_idx);
  bs_strong = zeros(size(bs));
  bs_idx = [find(bs <=- bs_thresh); find(bs >= bs_thresh)];
  bs_strong(bs_idx) = 1;

  if 1 % ~exist('range','var') | isempty(range)
     range = [min_blv max_blv];  
  else
     min_blv = range(1);
     max_blv = range(2);
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

  brainlv_lst = getappdata(gcf,'BLVData');
  brainlv = brainlv_lst{grp_idx,behav_idx};
  brainlv = brainlv(:,lv_idx).* bs_strong;

  %  construct the brainlv images
  %
%  blv_imgs = zeros(win_size*img_height,mont_width);
  first_rows = 1; last_rows = img_height;

%  for i=1:win_size,
     i = lag_idx + 1;
     blv = brainlv(i:win_size:end);

        cluster_idx = st_coords;

     [img,cmap,cbar] = fmri_plot_brainlv(blv,st_coords,st_dims,slice_idx, ...
		abs(thresh),-1*abs(thresh),range,rot_amount,bg_img,cluster_idx);

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

  set(h_img,'ButtonDownFcn','fmri_plot_datamatcorrs_3v(''SelectPixel'')');
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

        opt.setbuttondown = 'fmri_plot_datamatcorrs_3v(''SelectPixel'');';
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

    nii_view = getappdata(gcf,'nii_view');

    h = findobj(gcf,'Tag','XYZVoxel');
    set(h,'String',sprintf('%d %d %d %d',lag_idx,nii_view.imgXYZ.vox));

    h = findobj(gcf,'Tag','XYZmm');
    set(h,'String',sprintf('%2.1f %2.1f %2.1f',nii_view.imgXYZ.mm));

    setappdata(gcf,'xyz',nii_view.imgXYZ.vox);


  create_colorbar( colorbar_hdl, cbar, min_blv, max_blv );

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
  setappdata(gcf,'NumBehav',num_behav);
%  setappdata(gcf,'BLVData',brainlv);
  setappdata(gcf,'BLVCoords',st_coords);
  setappdata(gcf,'BLVThreshold',thresh);  
  setappdata(gcf,'RotateAmount',rot_amount);
  setappdata(gcf,'cmap',cmap);

  return;					% plot_bs_ratio


%-------------------------------------------------------------------------
%   
function ppplot_bs_ratio(PLSresultFile,lv_idx,slice_idx,thresh,range,new_fig)
% 
  if (new_fig)
     bg_img = getappdata(gcbf,'BackgroundImg');
     rot_amount = getappdata(gcbf,'RotateAmount');
  else
     bg_img = getappdata(gcf,'BackgroundImg');
     rot_amount = getappdata(gcf,'RotateAmount');
  end;

  load(PLSresultFile,'boot_result','st_dims','st_win_size','st_coords', ...
		     'st_voxel_size','st_origin');

  if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
  end

  bs_ratio = boot_result.compare_brain;

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
  ratio_imgs = zeros(win_size*img_height,mont_width);
  first_rows = 1; last_rows = img_height;
  for i=1:win_size,
     bsr = bs_ratio(i:win_size:end,lv_idx);

     [img,cmap,cbar] = fmri_plot_brainlv(bsr,st_coords,st_dims,slice_idx, ...
                                    abs(thresh),-1*abs(thresh),range,rot_amount,bg_img);
     ratio_imgs(first_rows:last_rows,:) = reshape(img,[img_height, mont_width]);
     first_rows = last_rows + 1; last_rows = first_rows + img_height - 1;
  end;

  %  display the images
  %
  if (new_fig)
      [axes_hdl,colorbar_hdl] = create_new_blv_figure;
  else 
      axes_hdl = getappdata(gcf,'BlvAxes');
      colorbar_hdl = getappdata(gcf,'Colorbar');
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
     create_colorbar(colorbar_hdl,cbar,min_ratio,max_ratio);
     return;
  end;

  set(h_img,'ButtonDownFcn','fmri_plot_datamatcorrs_3v(''SelectPixel'')');
  create_colorbar( colorbar_hdl, cbar, min_ratio, max_ratio );


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
  setappdata(gcf,'BSRatio',bs_ratio);
  setappdata(gcf,'BSRatioCoords',st_coords);
  setappdata(gcf,'BSThreshold',thresh);  
  setappdata(gcf,'RotateAmount',rot_amount);

  return;					% ppplot_bs_ratio

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

  h = findobj(gcf,'Tag','GroupIndexEdit');  grp_idx = get(h,'Userdata');
  curr_grp_idx = getappdata(gcf,'CurrGroupIdx');
  if (grp_idx ~= curr_grp_idx),
     grp_idx = curr_grp_idx;
     set(h,'String',num2str(grp_idx));
  end;

  h = findobj(gcf,'Tag','BehavIndexEdit');  behav_idx = get(h,'Userdata');
  curr_behav_idx = getappdata(gcf,'CurrBehavIdx');
  if (behav_idx ~= curr_behav_idx),
     behav_idx = curr_behav_idx;
     set(h,'String',num2str(behav_idx));
  end;

  old_pointer = get(gcf,'Pointer');
  fig_hdl = gcf;
  set(fig_hdl,'Pointer','watch');

  if 1 % (getappdata(gcf,'ViewBootstrapRatio') == 0),	% save brain lv 
     thresh = getappdata(gcf,'BLVThreshold');  
     if is_disp
        create_st_brainlv_disp(PLSresultFile,lv_idx,thresh,grp_idx,behav_idx);
     else
        create_st_brainlv_img(PLSresultFile,lv_idx,thresh,grp_idx,behav_idx);
     end
  else							% save bootstrap ratio
     thresh_ratio = getappdata(gcf,'BSThreshold');  
     create_bs_ratio_img(PLSresultFile,lv_idx,thresh_ratio);
  end;

  set(fig_hdl,'Pointer',old_pointer);

  return;					% SaveResultToIMG


%--------------------------------------------------------------------------
function create_st_brainlv_disp(PLSresultFile,lv_idx,thresh_ratio,grp_idx,behav_idx);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-10);

  [filename, pathname] = rri_selectfile('<ONLY INPUT PREFIX>*_datcorr_disp_grp_cond_beh_lag.img', ...
				'Datamat Correlation IMG file Prefix');
  if isequal(filename,0)
      return;
  end;

  filename = strrep(filename,'_datcorr_disp_grp_cond_beh_lag.img','');

  [tmp filename] = fileparts(filename);

  %  load the result file
  %
  load(PLSresultFile,'st_dims','st_win_size','st_coords', ...
		     'st_voxel_size','st_origin');

  dims = st_dims([1 2 4]);
%  img = zeros(dims);

  brainlv_lst = getappdata(gcf,'BLVData');
  brainlv = brainlv_lst{grp_idx,behav_idx};

  %  save background to img
  %
  brainlv = brainlv(:,lv_idx);


   bs = getappdata(gcbf,'BSRatio');
   h = findobj(gcf,'Tag','BSLVIndexEdit'); bs_lv_idx = str2num(get(h,'String'));
   h = findobj(gcf,'Tag','BSThreshold'); bs_thresh = str2num(get(h,'String'));
   bs = bs(:, bs_lv_idx);
   bs_strong = zeros(size(bs));
   bs_idx = [find(bs <=- bs_thresh); find(bs >= bs_thresh)];
   bs_strong(bs_idx) = 1;
   brainlv = brainlv .* bs_strong;


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
     too_large = find(brainlv(i,:) > max_blv); brainlv(i,too_large) = max_blv;
     too_small = find(brainlv(i,:) < min_blv); brainlv(i,too_small) = min_blv;

     % Create the image slices in which voxels are set to be within certain range
     %
     lower_interval = (abs(min_blv) - thresh_ratio) / (num_blv_colors-1);
     upper_interval = (max_blv - thresh_ratio) / (num_blv_colors-1);

     blv = zeros(1,length(st_coords)) + brain_region_color_idx;
     lower_idx = find(brainlv(i,:) <= -thresh_ratio);
     blv_offset = brainlv(i,lower_idx) - min_blv; 
     lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
     blv(lower_idx) = lower_color_idx;

     upper_idx = find(brainlv(i,:) >= thresh_ratio);
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

     img_file = fullfile(pathname,sprintf('%s_datcorr_disp_grp%d_cond%d_beh%d_lag%d',filename,grp_idx,lv_idx,behav_idx,i-1));
%     blv = brainlv(i:st_win_size:end,lv_idx); 
%     blv(abs(blv) < thresh_ratio) = 0;

%     img(st_coords) = blv;
     
     descrip = sprintf('DatamatCorrelation from %s, Group: %d, Condition: %d, Behavior: %d, Threshold: %8.5f', ...
		PLSresultFile,grp_idx,lv_idx,behav_idx,thresh_ratio);
     rri_write_img(img_file,img,0,dims,st_voxel_size,16,st_origin,descrip);
  end;

  %  save background to img
  %
  filename = fullfile(pathname,sprintf('%s_datcorr_disp_grp%d_cond%d_beh%d',filename,grp_idx,lv_idx,behav_idx));
  filename = [filename '_cmap'];
  save(filename,'cmap');

  return;					% create_st_brainlv_disp


%--------------------------------------------------------------------------
function create_st_brainlv_img(PLSresultFile,lv_idx,thresh_ratio,grp_idx,behav_idx);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-10);

  [filename, pathname] = rri_selectfile('<ONLY INPUT PREFIX>*_datcorr_grp_cond_beh_lag.img', ...
				'Datamat Correlation IMG file Prefix');
  if isequal(filename,0)
      return;
  end;

  filename = strrep(filename,'_datcorr_grp_cond_beh_lag.img','');

  [tmp filename] = fileparts(filename);

  %  load the result file
  %
  load(PLSresultFile,'st_dims','st_win_size','st_coords', ...
		     'st_voxel_size','st_origin');

  dims = st_dims([1 2 4]);
  img = zeros(dims);

  brainlv_lst = getappdata(gcf,'BLVData');
  brainlv = brainlv_lst{grp_idx,behav_idx};


   brainlv = brainlv(:,lv_idx); 

   bs = getappdata(gcbf,'BSRatio');
   h = findobj(gcf,'Tag','BSLVIndexEdit'); bs_lv_idx = str2num(get(h,'String'));
   h = findobj(gcf,'Tag','BSThreshold'); bs_thresh = str2num(get(h,'String'));
   bs = bs(:, bs_lv_idx);
   bs_strong = zeros(size(bs));
   bs_idx = [find(bs <=- bs_thresh); find(bs >= bs_thresh)];
   bs_strong(bs_idx) = 1;
   brainlv = brainlv .* bs_strong;

   brainlv = reshape(brainlv, [st_win_size, length(brainlv)/st_win_size]);


  for i=1:st_win_size,
     img_file = fullfile(pathname,sprintf('%s_datcorr_grp%d_cond%d_beh%d_lag%d',filename,grp_idx,lv_idx,behav_idx,i-1));
%     blv = brainlv(i:st_win_size:end,lv_idx); 
      blv = brainlv(i,:);

     blv(abs(blv) < thresh_ratio) = 0;

     img(st_coords) = blv;
     
     descrip = sprintf('DatamatCorrelation from %s, Group: %d, Condition: %d, Behavior: %d, Threshold: %8.5f', ...
		PLSresultFile,grp_idx,lv_idx,behav_idx,thresh_ratio);
     rri_write_img(img_file,img,0,dims,st_voxel_size,16,st_origin,descrip);
  end;

  return;					% create_st_brainlv_img


%--------------------------------------------------------------------------
function create_bs_ratio_img(PLSresultFile,lv_idx,thresh_ratio);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-1);
  image_fn = [resultfile_prefix, 'lag0_fMRIbsr.img'];

  [filename, pathname] = rri_selectfile('<ONLY INPUT PREFIX>*_bsr_lv1_lag0.img', ...
				'Bootstrap Result IMG file Prefix');
  if isequal(filename,0)
      return;
  end;

  filename = strrep(filename,'_bsr_lv1_lag0.img','');

  [tmp filename] = fileparts(filename);

  %  load the result file
  %
  load(PLSresultFile,'boot_result','st_dims','st_win_size','st_coords', ...
		     'st_voxel_size','st_origin');

  if isfield(boot_result,'compare')
      boot_result.compare_brain = boot_result.compare;
  end

  bs_ratio = boot_result.compare_brain;

  dims = st_dims([1 2 4]);
  img = zeros(dims);

  for i=1:st_win_size,
     img_file = fullfile(pathname,sprintf('%s_bsr_lv%d_lag%d',filename,lv_idx,i-1));
     bsr = bs_ratio(i:st_win_size:end,lv_idx); 
     bsr(abs(bsr) < thresh_ratio) = 0;

     img(st_coords) = bsr;
     
     descrip = sprintf('Bootstrap ratio from %s, LV: %d, Threshold: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio);
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

   if ~exist('view_state','var') | isempty(view_state),
      view_state = ~(getappdata(gcf,'ViewBootstrapRatio'));
   end;

   if (view_state == 0)			% view brain lv
      setappdata(gcf,'ViewBootstrapRatio',0);
      bs_visibility = 'off';
   else					% view bootstrap ratio
      setappdata(gcf,'ViewBootstrapRatio',1);
      bs_visibility = 'on';
   end;

   %  set visibility of the bootstrap fields
   %
   set(findobj(gcf,'Tag','BSLVIndexLabel'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','BSLVIndexEdit'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','BSLVNumberLabel'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','BSLVNumberEdit'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','BSThresholdLabel'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','BSThreshold'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','MinRatioLabel'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','MinRatio'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','MaxRatioLabel'),'enable',bs_visibility);
   set(findobj(gcf,'Tag','MaxRatio'),'enable',bs_visibility);

   %  update menu labels
   %
   PLSResultFile = get(findobj(gcf,'Tag','ResultFile'),'UserData');
   fig_title = sprintf('fMRI Datamat Correlations Plot: %s',PLSResultFile);
   set(gcf,'Name',fig_title);

   EditXYZ;

   return;					% ToggleView


%--------------------------------------------------------------------------
function EditGroup()

   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   behav_idx_hdl = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = str2num(get(behav_idx_hdl,'String'));

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if (getappdata(gcf,'CurrGroupIdx') == grp_idx)  % LV does not changed do nothing
      return;
   end;

   if isempty(grp_idx),
      msg = 'ERROR: Invalid input for the Group index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   num_grp = getappdata(gcf,'NumGroup');
   if (grp_idx < 1 | grp_idx > num_grp)
      msg = 'ERROR: Input Group index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   %  update the brainlv and bootstrap ratio fields
   %
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   h = findobj(gcf,'Tag','Threshold');
   thresh = str2num(get(h,'String'));  
   set_blv_fields(grp_idx,behav_idx,lv_idx,thresh);

   set(grp_idx_hdl,'Userdata',grp_idx);
   setappdata(gcf,'CurrGroupIdx',grp_idx);

   EditXYZ;

   return;					% EditGroup


%--------------------------------------------------------------------------
function EditBehav()

   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   behav_idx_hdl = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = str2num(get(behav_idx_hdl,'String'));

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if (getappdata(gcf,'CurrBehavIdx') == behav_idx)
      return;
   end;

   if isempty(behav_idx),
      msg = 'ERROR: Invalid input for the Behavior index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   num_behav = getappdata(gcf,'NumBehav');
   if (behav_idx < 1 | behav_idx > num_behav)
      msg = 'ERROR: Input Behavior index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   %  update the brainlv and bootstrap ratio fields
   %
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   h = findobj(gcf,'Tag','Threshold');
   thresh = str2num(get(h,'String'));  
   set_blv_fields(grp_idx,behav_idx,lv_idx,thresh);

   set(behav_idx_hdl,'Userdata',behav_idx);
   setappdata(gcf,'CurrBehavIdx',behav_idx);

   EditXYZ;

   return;					% EditBehav


%--------------------------------------------------------------------------
function EditLV()

   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   behav_idx_hdl = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = str2num(get(behav_idx_hdl,'String'));

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if (getappdata(gcf,'CurrLVIdx') == lv_idx)  % LV does not changed do nothing
      return;
   end;

   if isempty(lv_idx),
      msg = 'ERROR: Invalid input for the Condition index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   num_lv = getappdata(gcf,'NumLVs');
   if (lv_idx < 1 | lv_idx > num_lv)
      msg = 'ERROR: Input Condition index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;


   %  update the brainlv and bootstrap ratio fields
   %
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   h = findobj(gcf,'Tag','Threshold');
   thresh = str2num(get(h,'String'));  
   set_blv_fields(grp_idx,behav_idx,lv_idx,thresh);

   set(lv_idx_hdl,'Userdata',lv_idx);
   setappdata(gcf,'CurrLVIdx',lv_idx);

   if (getappdata(gcf,'ViewBootstrapRatio') == 1);
      UpdatePValue;
   end;

   EditXYZ;

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
function EditBSLV()

   lv_idx_hdl = findobj(gcbf,'Tag','BSLVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if (getappdata(gcf,'CurrBSLVIdx') == lv_idx)  % LV does not changed do nothing
      return;
   end;

   if isempty(lv_idx),
      msg = 'ERROR: Invalid input for the LV index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   num_lv = getappdata(gcf,'NumBSLVs');
   if (lv_idx < 1 | lv_idx > num_lv)
      msg = 'ERROR: Input LV index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;

   %  update the brainlv and bootstrap ratio fields
   %
   set_bs_fields(lv_idx, 0.05);


   set(lv_idx_hdl,'Userdata',lv_idx);
   setappdata(gcf,'CurrBSLVIdx',lv_idx);

   UpdatePValue;

   return;					% EditBSLV


%--------------------------------------------------------------------------
function UpdatePValue()

   h = findobj(gcf,'Tag','BSThreshold');    
   bootstrap_ratio = str2num(get(h,'String'));

   if isempty(bootstrap_ratio),
      msg = 'ERROR: Invalid input for bootstrap ratio.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end;


   h = findobj(gcf,'Tag','BSLVIndexEdit');  
   bs_lv_idx = get(h,'Userdata');

   bs_ratio = getappdata(gcf,'BSRatio');
   curr_bs_ratio = bs_ratio(:,bs_lv_idx);
   curr_bs_ratio = curr_bs_ratio(find(isnan(curr_bs_ratio) == 0));

   idx = find(abs(curr_bs_ratio) < std(curr_bs_ratio) * 5); % avoid the outliers
   std_ratio = std(curr_bs_ratio(idx));

   p_value = ratio2p(bootstrap_ratio,0,1);	%std_ratio);
   set(findobj(gcf,'Tag','PValue'), 'String',sprintf('%7.4f',p_value));

   return;					% UpdatePValue


%--------------------------------------------------------------------------
function SelectPixel()

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

   win_size = getappdata(gcbf,'WinSize');
   lag = getappdata(gcbf,'CurrLagIdx');
   row = lag + 1;

   h = findobj(gcbf,'Tag','GroupIndexEdit');    

   if isempty(h)
      return;
   end

   grp_idx = get(h,'Userdata');

   h = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = get(h,'Userdata');
   
   h = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = get(h,'Userdata');

   %  update the brain LV value if needed
   %
   if 1		%(getappdata(gcbf,'ViewBootstrapRatio') == 0),
      brainlv_lst = getappdata(gcbf,'BLVData');
      brainlv = brainlv_lst{grp_idx,behav_idx};
      blv_coords = getappdata(gcbf,'BLVCoords');

      curr_blv = brainlv(:,lv_idx);
      curr_blv = reshape(curr_blv,[win_size,length(blv_coords)]);

      h = findobj(gcbf,'Tag','BLVValue');
      coord_idx = find(blv_coords == coord);
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         blv_value = curr_blv(row,coord_idx);
         set(h,'String',num2str(blv_value,'%9.6f'));
      end;
   end;
 
   h = findobj(gcbf,'Tag','XYZVoxel');
   set(h,'String',sprintf('%d %d %d %d', lag, xyz));

   h = findobj(gcbf,'Tag','XYZmm');
   set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

   return; 					% SelectPixel


%--------------------------------------------------------------------------
function EditXYZ()

   xyz = str2num(get(findobj(gcf,'tag','XYZVoxel'),'string'));

   if isempty(xyz) | ~isequal(size(xyz),[1 4])
      msg = 'LagXYZ should contain 4 numbers (Lag, X, Y, and Z)';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   j = xyz(1) + 1;
   xyz = xyz([2:4]);

   if ( j<1 | j>getappdata(gcf,'WinSize') )
      msg = 'Invalid lag number';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   lag_idx_hdl = findobj(gcf,'Tag','LagIndexEdit');    
   set(lag_idx_hdl,'String',num2str(j-1));
   EditLag;

   opt.setunit = 'voxel';
   opt.setviewpoint = xyz;
   view_nii(gcf,opt);

   nii_view = getappdata(gcf,'nii_view');
   xyz = nii_view.imgXYZ.vox;
   xyz_mm = nii_view.imgXYZ.mm;
   setappdata(gcf,'xyz',xyz);

   st_dims = getappdata(gcf, 'STDims');
   coord = rri_xyz2coord(xyz, st_dims);
   setappdata(gcf,'Coord',coord);

   win_size = getappdata(gcf,'WinSize');
   lag = getappdata(gcf,'CurrLagIdx');
   row = lag + 1;

   h = findobj(gcf,'Tag','GroupIndexEdit');    
   grp_idx = get(h,'Userdata');

   h = findobj(gcf,'Tag','BehavIndexEdit');    
   behav_idx = get(h,'Userdata');
   
   h = findobj(gcf,'Tag','LVIndexEdit');    
   lv_idx = get(h,'Userdata');

   %  update the brain LV value if needed
   %
   if 1		%(getappdata(gcf,'ViewBootstrapRatio') == 0),
      brainlv_lst = getappdata(gcf,'BLVData');
      brainlv = brainlv_lst{grp_idx,behav_idx};
      blv_coords = getappdata(gcf,'BLVCoords');

      curr_blv = brainlv(:,lv_idx);
      curr_blv = reshape(curr_blv,[win_size,length(blv_coords)]);

      h = findobj(gcf,'Tag','BLVValue');
      coord_idx = find(blv_coords == coord);
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         blv_value = curr_blv(row,coord_idx);
         set(h,'String',num2str(blv_value,'%9.6f'));
      end;
   end;
  
   h = findobj(gcf,'Tag','XYZVoxel');
   set(h,'String',sprintf('%d %d %d %d', lag, xyz));

   h = findobj(gcf,'Tag','XYZmm');
   set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

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

   load_pls_result;
   ShowResult(0,1);
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

  try 				% load the dimension info of the datamat
     load(PLSresultFile,'st_dims','st_voxel_size','st_origin','st_coords'),
  catch
     msg =sprintf('ERROR: Cannot load the PLS result file "%s".',PLSresultFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;

  newcoords = st_coords;
  voxel_size = st_voxel_size;
  origin = st_origin;

  dims = st_dims([1 2 4]);
  img = zeros(dims);
  img = img(:);
  img(newcoords) = 1;
  img = reshape(img,dims);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-11);
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
   fmri_plot_datamatcorrs_3v_newfig_pos = [];

   try
      load('pls_profile');
   catch 
   end

   if ~isempty(fmri_plot_datamatcorrs_3v_newfig_pos) & strcmp(save_setting_status,'on')

      pos = fmri_plot_datamatcorrs_3v_newfig_pos;

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
   	'DeleteFcn','fmri_plot_datamatcorrs_3v(''DeleteNewFigure'')', ...
	'PaperPositionMode', 'auto', ...
        'Userdata','Clone', ...
   	'Tag','PlotBrainLV2');
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
function  [min_ratio, max_ratio, bs_thresh] = set_bs_fields(lv_idx,p_value),

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
	& ~isempty(setting.bs_thresh{lv_idx})
      bs_thresh = setting.bs_thresh{lv_idx};
   else
      bs_thresh = bs95(lv_idx);
   end;

   min_ratio = min(bs_ratio(:,lv_idx));
   max_ratio = max(bs_ratio(:,lv_idx));

   set(findobj(gcf,'Tag','BSThreshold'),'String',sprintf('%8.5f',bs_thresh));
%   set(findobj(gcf,'Tag','PValue'),'String',sprintf('%8.5f',p_value));
   set(findobj(gcf,'Tag','MinRatio'),'String',sprintf('%8.5f',min_ratio));
   set(findobj(gcf,'Tag','MaxRatio'),'String',sprintf('%8.5f',max_ratio));


   return; 						% set_bs_field


%--------------------------------------------------------------------------
function  [min_blv,max_blv,thresh] = set_blv_fields(grp_idx,behav_idx,lv_idx,thresh)

   brainlv_lst = getappdata(gcf,'BLVData');

   if isempty(brainlv_lst)		 	% no brain lv data -> return;
       return;
   end;

   if ~exist('grp_idx','var') | isempty(grp_idx),
      grp_idx = 1;
   end;

   if ~exist('behav_idx','var') | isempty(behav_idx),
      behav_idx = 1;
   end;

   if ~exist('lv_idx','var') | isempty(lv_idx),
      lv_idx = 1;
   end;

   setting = getappdata(gcf,'setting');

   if ~isempty(setting) & isfield(setting,'thresh') ...
	& size(setting.thresh,1)>=grp_idx ...
	& size(setting.thresh,2)>=lv_idx ...
	& size(setting.thresh,3)>=behav_idx ...
	& ~isempty(setting.thresh{grp_idx,lv_idx,behav_idx})
      thresh = setting.thresh{grp_idx,lv_idx,behav_idx};
      min_blv = setting.min_blv{grp_idx,lv_idx,behav_idx};
      max_blv = setting.max_blv{grp_idx,lv_idx,behav_idx};
   else
      min_blv = min(brainlv_lst{grp_idx,behav_idx}(:,lv_idx));
      max_blv = max(brainlv_lst{grp_idx,behav_idx}(:,lv_idx));

      if ~exist('thresh','var') | isempty(thresh),
         thresh = (abs(max_blv) + abs(min_blv)) / 6;
      end;
   end;

   set(findobj(gcf,'Tag','Threshold'),'String',sprintf('%8.5f',thresh));
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

  h = findobj(gcf,'Tag','ResultFile');
  PLSresultFile = get(h,'UserData');

%  load(PLSresultFile);

  rf_plot = getappdata(gcf,'RFPlotHdl');
  if ~isempty(rf_plot)
      msg = 'ERROR: Response function plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  rf_plot = fmri_plot_corr('LINK',PLSresultFile);
  link_info.hdl = gcbf;
  link_info.name = 'RFPlotHdl';
  setappdata(rf_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'RFPlotHdl',rf_plot);

  %  make sure the Coord of the Response Function Plot contains
  %  the current point in the Response
  %
  cur_coord = getappdata(gcf,'Coord');
  setappdata(rf_plot,'Coord',cur_coord);

  return;					% OpenCorrelationPlot


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

