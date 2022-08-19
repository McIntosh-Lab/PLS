function fig = smallfc_plot_condmean(action,varargin)

   if ~exist('action','var') | isempty(action)

      h = findobj(gcbf,'Tag','ResultFile');
      PLSResultFile = get(h,'UserData');

      msg = 'Loading Condition Mean Data ...    Please wait!';
      hb = rri_wait_box(msg,[0.5 0.1]);

      fig_h = init(PLSResultFile);

      setappdata(gcf,'CallingFigure',gcbf);

      load_pls_result;


     p_img = getappdata(gcf,'p_img');
     if ~isempty(p_img)
        p_img = [-1 -1];
        setappdata(gcf,'p_img',p_img);
     end
     setappdata(gcf,'img_xhair',[]);

      ShowResult(0,0);

      if (nargout > 0),
        fig = fig_h;
      end;

      delete(hb);

      h = findobj(gcf,'Tag','XYVoxel');
      set(h, 'string', '1 1');
      h = findobj(gcf,'Tag','MessageLine');
      set(h,'String','');

      EditXY;

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
     EditXY;
   elseif (strcmp(action,'EditGroup'))
     EditGroup;
     ShowResult(0,1);
   elseif (strcmp(action,'EditLag'))
     EditLag;
     ShowResult(0,1);
   elseif (strcmp(action,'EditLV'))
     EditLV;
     ShowResult(0,1);
   elseif (strcmp(action,'EditBSLV'))
     EditBSLV;
     ShowResult(0,1);
   elseif (strcmp(action,'UpdatePValue'))
     UpdatePValue;
     ShowResult(0,1);
   elseif (strcmp(action,'SelectPixel'))
     SelectPixel;
   elseif (strcmp(action,'DeleteNewFigure'))
      try
         load('pls_profile');
         pls_profile = which('pls_profile.mat');

         smallfc_plot_condmean_newfig_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'smallfc_plot_condmean_newfig_pos');
      catch
      end
   elseif (strcmp(action,'DeleteFigure'))
     try
        load('pls_profile');
        pls_profile = which('pls_profile.mat');

        smallfc_plot_condmean_pos = get(gcbf,'position');

        save(pls_profile, '-append', 'smallfc_plot_condmean_pos');
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
 %             setting4 = setting;
  %            save(PLSresultFile, '-append', 'setting4');
           catch
              msg = 'Cannot save setting information';
              msgbox(msg,'ERROR','modal');
           end
        end
     end

%     DeleteLinkedFigure;
%     calling_fig = getappdata(gcf,'CallingFigure');
%     set(calling_fig,'visible','on');
   elseif (strcmp(action,'OpenBrainPlot'))
     OpenBrainPlot;
   elseif (strcmp(action,'OpenResponseFnPlot'))
     OpenResponseFnPlot;
   elseif (strcmp(action,'OpenCondMeanPlot'))
     OpenCondMeanPlot;
   elseif (strcmp(action,'OpenScoresPlot'))
     smallfc_plot_scores_ui(varargin{1});
   elseif (strcmp(action,'OpenEigenPlot'))
     OpenEigenPlot;
   elseif (strcmp(action,'SetClusterReportOptions'))
     SetClusterReportOptions;
   elseif (strcmp(action,'LoadClusterReport'))
     smallfc_cluster_report('LoadClusterReport',gcbf);
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
   elseif (strcmp(action,'EditXY'))
      EditXY;
   elseif (strcmp(action,'EditXYZmm'))
      xyz_mm = str2num(get(findobj(gcbf,'tag','XYZmm'),'string'));

      if isempty(xyz_mm) | ~isequal(size(xyz_mm),[1 3])
         msg = 'XYZ(mm) should contain 3 numbers (X, Y, and Z)';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end

      origin = getappdata(gcf,'Origin');
      voxel_size = getappdata(gcf,'STVoxelSize');

      xyz_offset = xyz_mm ./ voxel_size;
      xyz = round(xyz_offset + origin);

      set(findobj(gcbf,'tag','XYVoxel'), 'string', num2str(xyz));
      EditXY;
   elseif (strcmp(action,'orient'))
      orient;
   end;

   return;


%---------------------------------------------------------------------------
%
function h0 = init(PLSResultFile);

   setting4 = [];
   warning off;
   load(PLSResultFile, 'setting4');
   setting = setting4;
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
   smallfc_plot_condmean_pos = [];

   try
      load('pls_profile');
   catch 
   end

   if ~isempty(smallfc_plot_condmean_pos) & strcmp(save_setting_status,'on')

      pos = smallfc_plot_condmean_pos;

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
        'NumberTitle','off', ...
   	'DoubleBuffer','on', ...
   	'MenuBar','none',...
   	'Position',pos, ...
   	'DeleteFcn','smallfc_plot_condmean(''DeleteFigure'')', ...
   	'Tag','PlotBrainLV');
   %

   x = .37;
   y = .1;
   w = .5;
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

   x = x+w+.02;
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
   y = .91;
   w = .14;
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
   	'String','Group Index:', ...
   	'Style','text', ...
   	'Tag','ResultFileLabel');

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
   	'Callback','smallfc_plot_condmean(''EditGroup'')', ...
   	'Tag','GroupIndexEdit');

   x = x+w;
   y = y-.01;

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
   y = y-h-.03;
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
   	'Callback','smallfc_plot_condmean(''EditLV'')', ...
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

   x = .03;
   y = y-h-.03;
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
   	'String','Lag Index:', ...
   	'Style','text', ...
   	'Tag','LagIndexLabel');

   x = x+w;
   y = y+.01;
   w = .05;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% behav index edit
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
   	'Callback','smallfc_plot_condmean(''EditLag'')', ...
   	'Tag','LagIndexEdit');

   x = x+w;
   y = y-.01;

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
   	'Tag','LagNumberLabel');

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
   	'Tag','LagNumberEdit');



   %  Brain LV

   x = .03;
   y = .3;
   w = .26;
   h = .45;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Brain LV frame
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
		'visible','off', ...
   	'Tag','ThresholdFrame');

   x = .08;
   y = .72;
   w = .16;
   h = .04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Brain LV title
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Condition Mean', ...
   	'Style','text', ...
		'visible','off', ...
   	'Tag','BLVTitle');

   x = .05;
   y = .67;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% threshold label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Threshold:', ...
   	'Style','text', ...
		'visible','off', ...
   	'Tag','ThresholdLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% threshold edit
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
        'Callback','smallfc_plot_condmean(''PlotBnPress'')', ...
		'visible','off', ...
   	'Tag','Threshold');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Curr. Value label
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

   h1 = uicontrol('Parent',h0, ...			% Curr. Value text
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

   h1 = uicontrol('Parent',h0, ...			% min value label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Min. Value:', ...
   	'Style','text', ...
		'visible','off', ...
   	'Tag','MinValueLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% min value edit
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
        'Callback','smallfc_plot_condmean(''PlotBnPress'')', ...
		'visible','off', ...
   	'Tag','MinValue');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% max value label
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'String','Max. Value:', ...
   	'Style','text', ...
		'visible','off', ...
   	'Tag','MaxValueLabel');

   x = x+w;
   y = y+.01;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% max value edit
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
        'Callback','smallfc_plot_condmean(''PlotBnPress'')', ...
		'visible','off', ...
   	'Tag','MaxValue');

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
   	'String','LV Index:', ...
   	'Style','text', ...
		'visible','off', ...
   	'Tag','BSLVIndexLabel');

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
   	'Callback','smallfc_plot_condmean(''EditBSLV'')', ...
		'visible','off', ...
   	'Tag','BSLVIndexEdit');


   x = x+w;
   y = y-.01;
   w = .03;

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
		'visible','off', ...
   	'Tag','BSLVNumberLabel');

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
		'visible','off', ...
   	'Tag','BSLVNumberEdit');

   x = .05;
   y = y-h-.01;
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
   	'String','BS Threshold:', ...
   	'Style','text', ...
		'visible','off', ...
   	'Tag','BSThresholdLabel');

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
   	'Callback','smallfc_plot_condmean(''UpdatePValue'')', ...
		'visible','off', ...
   	'Tag','BSThreshold');

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
   	'String','Min. Ratio:', ...
   	'Style','text', ...
		'visible','off', ...
   	'Tag','MinRatioLabel');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
        'Callback','smallfc_plot_condmean(''PlotBnPress'')', ...
		'visible','off', ...
   	'Tag','MinRatio');

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
   	'String','Max. Ratio:', ...
   	'Style','text', ...
		'visible','off', ...
   	'Tag','MaxRatioLabel');

   x = x+w;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','text', ...
        'Callback','smallfc_plot_condmean(''PlotBnPress'')', ...
		'visible','off', ...
   	'Tag','MaxRatio');


   %  Voxel Location

   x = .03;
   y = .16;
   w = .26;
   h = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Voxel location frame
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
		'visible','off', ...
   	'Tag','LocationFrame');

   x = .05;
   y = .22;
   w = .07;
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
   	'String','XY:', ...
	'ToolTipString','Absolute coxel coordinates', ...
   	'Style','text', ...
   	'Tag','XYVoxelLabel');

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
   	'Callback','smallfc_plot_condmean(''EditXY'')');

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
   	'Callback','smallfc_plot_condmean(''EditXY'')', ...
   	'Tag','XYVoxel');

   x = .05;
   y = y-h-0.02;
   w = .07;

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
		'visible','off', ...
   	'Tag','XYZmmLabel');

   x = x+w;
   w = .15;

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
   	'Callback','smallfc_plot_condmean(''EditXYZmm'')', ...
		'visible','off', ...
   	'Tag','XYZmm');


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
   h2 = uimenu(h_file, ...
           'Label','&Load Background Image', ...
           'Tag','LoadBGImage', ...
           'Callback','smallfc_plot_condmean(''LoadBackgroundImage'')');
   h2 = uimenu(h_file, ...
           'Label','Save brain region to IMG file', ...
   	   'Tag','SaveBGImage', ...
           'Callback','smallfc_plot_condmean(''SaveBackgroundImage'')');
   h2 = uimenu(h_file, ...
           'Label','&Load PLS Result', ...
   	   'Tag','LoadSmallFCResult', ...
		'visible', 'off', ...
           'Callback','smallfc_plot_condmean(''LoadResultFile'')');
   h2 = uimenu(h_file, ...
           'Label','&Save Current Display to the IMG files', ...
   	   'Tag','SaveDisplayToIMG', ...
           'Callback','smallfc_plot_condmean(''SaveDisplayToIMG'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Save Condition Mean to IMG file', ...
   	   'Tag','SaveResultToIMG', ...
           'Callback','smallfc_plot_condmean(''SaveResultToIMG'')');
   h2 = uimenu(h_file, ...
           'Label','Create Condition Mean &Figure', ...
   	   'Tag','PlotNewFigure', ...
           'Callback','smallfc_plot_condmean(''PlotOnNewFigure'')');

   rri_file_menu(h0);

   % Xhair submenu
   %
   h_xhair = uimenu('Parent',h0, 'Label','Crosshair');
   h2 = uimenu('Parent',h_xhair, ...
   	   'Label','Crosshair off', ...
	   'Userdata', 0, ...
           'Callback','smallfc_result_ui(''crosshair'')', ...
   	   'Tag','XhairToggleMenu');
   h2 = uimenu('Parent',h_xhair, ...
   	   'Label','Color ...', ...
	   'Userdata', [1 0 0], ...
           'Callback','smallfc_result_ui(''set_xhair_color'')', ...
   	   'Tag','XhairColorMenu');

   % Zoom submenu
   %
   h2 = uimenu('Parent',h0, ...
   	   'Label','&Zoom on', ...
	   'Userdata', 1, ...
           'Callback','smallfc_plot_condmean(''Zooming'')', ...
   	   'Tag','ZoomToggleMenu');

   % Rotate submenu
   %
   h_rot = uimenu('Parent',h0, ...
   	   'Label','&Image Rotation', ...
		'visible', 'off', ...
   	   'Tag','RotationMenu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&none', ...			% rotate 90 by default
   	   'Checked','on', ...
           'Callback','smallfc_plot_condmean(''Rotation'',1)', ...
   	   'Tag','Rotate0Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&90 degree', ...		% another 90 degree
   	   'Checked','off', ...
           'Callback','smallfc_plot_condmean(''Rotation'',2)', ...
   	   'Tag','Rotate90Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&180 degree', ...		% now become 270 degree
   	   'Checked','off', ...
           'Callback','smallfc_plot_condmean(''Rotation'',3)', ...
   	   'Tag','Rotate180Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&270 degree', ...		% now completed 360 degree
   	   'Checked','off', ...
           'Callback','smallfc_plot_condmean(''Rotation'',0)', ...
   	   'Tag','Rotate270Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','Convert Orientation', ...
	   'separator', 'on', ...
           'Callback','smallfc_plot_condmean(''orient'',0)', ...
		'visible', 'off', ...
   	   'Tag','orient');

   %  Window submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Windows', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','off');
   h2 = uimenu(h_pls, ...
           'Label','&Singular Values Plot', ...
     	   'Tag','OpenEigenPlot', ...
           'Callback','smallfc_plot_condmean(''OpenEigenPlot'')');
   h2 = uimenu(h_pls, ...
           'Label','&Behavior LV and Behavior Scores Plot', ...
	   'Visible','off', ...
     	   'Tag','OpenBehavPlot', ...
           'Callback','smallfc_plot_condmean(''OpenScoresPlot'',0)');
   h2 = uimenu(h_pls, ...
           'Label','&Design LV and Design Scores Plot', ...
	   'Visible','off', ...
     	   'Tag','OpenDesignPlot', ...
           'Callback','smallfc_plot_condmean(''OpenScoresPlot'',1)');
   h2 = uimenu(h_pls, ...
           'Label','B&rain Scores vs. Behavior Data Plot', ...
     	   'Tag','OpenBrainPlot', ...
           'Callback','smallfc_plot_condmean(''OpenBrainPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Voxel Intensity Response', ...
     	   'Tag','OpenRFPlot', ...
           'Callback','smallfc_plot_condmean(''OpenResponseFnPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Condition Mean Response', ...
     	   'Tag','OpenRF1Plot', ...
           'Callback','smallfc_plot_condmean(''OpenResponseFnPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Condition Mean Plot', ...
     	   'Tag','OpenCondMeanPlot', ...
           'Callback','smallfc_plot_condmean(''OpenCondMeanPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Create Brain LV &Figure', ...
	   'separator', 'on', ...
   	   'Tag','PlotNewFigure', ...
           'Callback','smallfc_plot_condmean(''PlotOnNewFigure'')');

   %  Report submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Report', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','off');
   h2 = uimenu(h_pls, ...
           'Label','&Set Cluster Report Options', ...
     	   'Tag','SetClusterReportOptions', ...
           'Callback','smallfc_plot_condmean(''SetClusterReportOptions'')');
   h2 = uimenu(h_pls, ...
           'Label','&Load Cluster Report', ...
     	   'Tag','LoadClsuterReport', ...
           'Callback','smallfc_plot_condmean(''LoadClusterReport'')');
   h2 = uimenu(h_pls, ...
           'Label','&Create Cluster Report', ...
     	   'Tag','OpenClusterReport', ...
           'Callback','smallfc_plot_condmean(''OpenClusterReport'')');

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
		'visible', 'off', ...
           'Tag', 'Help');
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','rri_helpfile_ui(''smallfc_result_hlp.txt'',''How to use PLS RESULT'');', ...
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


   set(gcf,'Name',sprintf('SmallFC PLS Result: %s',PLSResultFile));
%   set(colorbar_h,'units','pixels');

   setappdata(gcf,'Colorbar',colorbar_h);
   setappdata(gcf,'BlvAxes',axes_h);

   setappdata(gcf,'ClusterMinSize',5);
   setappdata(gcf,'ClusterMinDist',10);
   setappdata(gcf,'template_file', []);
   setappdata(gcf,'img_xhair',[]);

   setappdata(gcf,'setting',setting);
   setappdata(gcf,'old_setting',setting);

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
     close(brain_plot);
   end;

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

   condmean_fig = getappdata(gcbf,'CondMeanPlotHdl');
   if ~isempty(condmean_fig) & ishandle(condmean_fig)
     close(condmean_fig);
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
   obj(32).name  = 'XYVoxelLabel';      obj(32).pos = [35  365-111  50 19];
   obj(33).name  = 'XYVoxel';           obj(33).pos = [75  365-111 105 19];
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
   else
      num_conditions = num_cond_lst(1);
   end

   grp_idx = 1;					% group idx
   lv_idx = 1;					% condition idx
   lag_idx = 1;

   behav_idx = 1;	% "smallfc_plot_brainlv" will know it's not real blv
   num_behav = 1;

   num_grp = length(num_subj_lst);
   num_lv = num_conditions;

   if length(dims) < 2
      error('Wrong dimension');
   elseif length(dims) < 3
      dims = [dims(:)' 1];
   end

   setappdata(gcf,'Dims',dims);

   num_lag = dims(3);

   datasvd = result.u *  diag(result.s) * result.v';
   datasvd = reshape(datasvd, dims(1), dims(2), num_lag, num_lv, num_grp);
%   brainlv = squeeze(datasvd(:, :, :, lv_idx, grp_idx));

   if exist('behavlv','var')
      set(gcf,'Name', ...
	sprintf('SmallFC Behavioral PLS Brain LV Plot: %s',PLSresultFile));
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenRFPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenRF1Plot'), 'Visible', 'Off');
      set(findobj(gcf,'tag','OpenCondMeanPlot'), 'visible', 'off');
      setappdata(gcf,'isbehav',1);
      setappdata(gcf,'datamatcorrs_lst',datamatcorrs_lst);
   elseif exist('designlv','var')
      set(gcf,'Name', ...
	sprintf('SmallFC Task PLS Brain LV Plot: %s',PLSresultFile));
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenRFPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenRF1Plot'), 'Visible', 'Off');
      set(findobj(gcf,'tag','OpenCondMeanPlot'), 'visible', 'off');
      setappdata(gcf,'isbehav',0);
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

   brainlv_lst = {};

   for g = 1:num_grp

      brainlv = squeeze(datasvd(:, :, :, :, g));
      brainlv_lst{g,1} = reshape(brainlv, prod(dims), num_lv);

   end

   setappdata(gcf,'brainlv',brainlv_lst);
   setappdata(gcf, 's', result.s);
   set_blv_fields(grp_idx,lag_idx,lv_idx);

   ToggleView(0);
   set(findobj(gcf,'Tag','ViewMenu'),'Visible','off');

   set(gcf,'Pointer',old_pointer);
   set(findobj(gcf,'Tag','MessageLine'),'String','');

   setappdata(gcf,'DatamatFileList', datamat_files);
   setappdata(gcf,'CurrGroupIdx',grp_idx);
   setappdata(gcf,'CurrLagIdx',behav_idx);
   setappdata(gcf,'NumGroup',num_grp);
   setappdata(gcf,'CurrLVIdx',lv_idx);
   setappdata(gcf,'CurrLagIdx',lag_idx);

   setappdata(gcf,'NumLVs',num_lv);
   setappdata(gcf,'NumLags',num_lag);

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

  brain_plot = smallfc_plot_brain_scores('STARTUP',PLSresultFile);
  link_info.hdl = gcbf;
  link_info.name = 'brain_plot';
  setappdata(brain_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'brain_plot',brain_plot);

  return;					% OpenBrainPlot


%-------------------------------------------------------------------------
%
function OpenResponseFnPlot()

  DatamatFileList = getappdata(gcbf,'DatamatFileList');

  rf_plot = getappdata(gcf,'RFPlotHdl');
  if ~isempty(rf_plot)
      msg = 'ERROR: Response function plot is already been opened';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
  end;

  rf_plot = smallfc_plot_rf('LINK',DatamatFileList);
  link_info.hdl = gcbf;
  link_info.name = 'RFPlotHdl';
  setappdata(rf_plot,'LinkFigureInfo',link_info);
  setappdata(gcbf,'RFPlotHdl',rf_plot);

  %  make sure the Coord of the Response Function Plot contains
  %  the current point in the Response
  %
  cur_coord = getappdata(gcf,'Coord');
  setappdata(rf_plot,'Coord',cur_coord);

  return;					% OpenResponseFnPlot


%-------------------------------------------------------------------------
%
function SetClusterReportOptions()

   st_origin = getappdata(gcbf,'Origin');
   dims = getappdata(gcbf,'Dims');
   cluster_min_size = getappdata(gcbf,'ClusterMinSize');
   cluster_min_dist = getappdata(gcbf,'ClusterMinDist');

   if isempty(st_origin)
      st_origin = round(dims([1 2 4])/2);
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

   setappdata(gcbf,'Origin',origin_xyz);
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
   h = rri_wait_box(msg,[0.5 0.1]);

   cluster_min_size = getappdata(gcbf,'ClusterMinSize');
   cluster_min_dist = getappdata(gcbf,'ClusterMinDist');

   smallfc_cluster_report(cluster_min_size,cluster_min_dist);

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

   load(PLSresultFile,'contrast_file','datamat_files');

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

   contrast_fig = pls_input_contrast_ui(pls_contrasts,conditions,1);

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
%     smallfc_create_colorbar(colorbar_hdl,cbar,min_ratio,max_ratio);
     return;
  end;

  set(h_img,'ButtonDownFcn','smallfc_plot_condmean(''SelectPixel'')');
%  smallfc_create_colorbar( colorbar_hdl, cbar, min_ratio, max_ratio );


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
     msg =sprintf('ERROR: Cannot load the SmallFC result file "%s".',PLSresultFile);
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

  h = findobj(gcf,'Tag','LagIndexEdit');  behav_idx = get(h,'Userdata');
  curr_behav_idx = getappdata(gcf,'CurrLagIdx');
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
        create_brainlv_disp(PLSresultFile,lv_idx,thresh,grp_idx,behav_idx);
     else
        create_brainlv_img(PLSresultFile,lv_idx,thresh,grp_idx,behav_idx);
     end

  else							% save bootstrap ratio
     thresh_ratio = getappdata(gcf,'BSThreshold');
     create_bs_ratio_img(PLSresultFile,lv_idx,thresh_ratio);
  end;

  set(fig_hdl,'Pointer',old_pointer);

  return;					% SaveResultToIMG


%--------------------------------------------------------------------------
function create_brainlv_disp(PLSresultFile,lv_idx,thresh_ratio,grp_idx,behav_idx);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-9);

  image_fn = sprintf('%sSmallFCcondmean_disp_grp%d_cond%d.img',resultfile_prefix,grp_idx,lv_idx);

  [filename, pathname] = rri_selectfile(image_fn,'Condition Mean IMG file');

  img_file = [pathname, filesep, filename];

  if isequal(filename,0)
      return;
  end;

  %  load the result file
  %
  load(PLSresultFile,'dims','newcoords','voxel_size','origin');

  dims = dims([1 2 4]);

  blv = getappdata(gcbf,'BLVData');
  brainlv = blv{grp_idx, behav_idx};

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
  too_large = find(brainlv > max_blv); brainlv(too_large) = max_blv;
  too_small = find(brainlv < min_blv); brainlv(too_small) = min_blv;

  % Create the image slices in which voxels are set to be within certain range
  %
  lower_interval = (abs(min_blv) - thresh_ratio) / (num_blv_colors-1);
  upper_interval = (max_blv - thresh_ratio) / (num_blv_colors-1);

  blv = zeros(1,length(newcoords)) + brain_region_color_idx;
  lower_idx = find(brainlv <= -thresh_ratio);
  blv_offset = brainlv(lower_idx) - min_blv; 
  lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
  blv(lower_idx) = lower_color_idx;

  upper_idx = find(brainlv >= thresh_ratio);
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

%  blv = brainlv(1,lv_idx); 
%  blv(abs(blv) < thresh_ratio) = 0;

%  img(newcoords) = blv;

  descrip = sprintf('Condition Mean from %s, Group: %d, Condition: %d', ...
		PLSresultFile,grp_idx,lv_idx);
  rri_write_img(filename,img,0,dims,voxel_size,16,origin,descrip);

  %  save background to img
  %
  [tmp filename] = fileparts(filename);
  filename = [filename '_cmap'];
  save(filename,'cmap');

  return;					% create_brainlv_disp


%--------------------------------------------------------------------------
function create_brainlv_img(PLSresultFile,lv_idx,thresh_ratio,grp_idx,behav_idx);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-9);

  image_fn = sprintf('%sSmallFCcondmean_grp%d_cond%d.img',resultfile_prefix,grp_idx,lv_idx);

  [filename, pathname] = rri_selectfile(image_fn,'Condition Mean IMG file');

  img_file = [pathname, filesep, filename];

  if isequal(filename,0)
      return;
  end;

  %  load the result file
  %
  load(PLSresultFile,'dims','newcoords','voxel_size','origin');

  dims = dims([1 2 4]);
  img = zeros(dims);

  blv = getappdata(gcbf,'BLVData');
  brainlv = blv{grp_idx, behav_idx};

  blv = brainlv(:,lv_idx); 


   bs = getappdata(gcbf,'BSRatio');
   h = findobj(gcf,'Tag','BSLVIndexEdit'); bs_lv_idx = str2num(get(h,'String'));
   h = findobj(gcf,'Tag','BSThreshold'); bs_thresh = str2num(get(h,'String'));
   bs = bs(:, bs_lv_idx);
   bs_strong = zeros(size(bs));
   bs_idx = [find(bs <=- bs_thresh); find(bs >= bs_thresh)];
   bs_strong(bs_idx) = 1;
   blv = blv .* bs_strong;


  blv(abs(blv) < thresh_ratio) = 0;

  img(newcoords) = blv;

  descrip = sprintf('Condition Mean from %s, Group: %d, Condition: %d', ...
		PLSresultFile,grp_idx,lv_idx);
  rri_write_img(filename,img,0,dims,voxel_size,16,origin,descrip);

  return;					% create_brainlv_img


%--------------------------------------------------------------------------
function create_bs_ratio_img(PLSresultFile,lv_idx,thresh_ratio);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-9);
  image_fn = [resultfile_prefix, 'SmallFCbsr.img'];

  [filename, pathname] = rri_selectfile(image_fn,'Bootstrap Result IMG file');

  img_file = [pathname, filesep, filename];

  if isequal(filename,0)
      return;
  end;

  %  load the result file
  %
  load(PLSresultFile,'boot_result','dims','newcoords','voxel_size','origin');

  bs_ratio = boot_result.compare;

  dims = dims([1 2 4]);
  img = zeros(dims);

  bsr = bs_ratio(1,lv_idx); 
  bsr(abs(bsr) < thresh_ratio) = 0;

  img(newcoords) = bsr;

  descrip = sprintf('Bootstrap Ratio from %s, LV: %d, Threshold: %8.5f', ...
				           PLSresultFile,lv_idx,thresh_ratio);
  rri_write_img(filename,img,0,dims,voxel_size,16,origin,descrip);

  return;					% create_bs_ratio_img


%--------------------------------------------------------------------------
%
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
   fig_title = sprintf('SmallFC Condition Mean: %s',PLSResultFile);
   set(gcf,'Name',fig_title);

   EditXY;

   return;					% ToggleView


%--------------------------------------------------------------------------
function EditGroup()

   old_grp_idx = getappdata(gcf,'CurrGroupIdx');	% save old grp_idx
   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   lag_idx_hdl = findobj(gcbf,'Tag','LagIndexEdit');    
   lag_idx = str2num(get(lag_idx_hdl,'String'));

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if isempty(grp_idx),
      msg = 'ERROR: Invalid input for the Group index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(grp_idx_hdl,'String',num2str(old_grp_idx));
      return;
   end;

   if ( grp_idx == old_grp_idx)  % LV does not changed do nothing
      return;
   end;

   num_grp = getappdata(gcf,'NumGroup');
   if (grp_idx < 1 | grp_idx > num_grp)
      msg = 'ERROR: Input Group index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(grp_idx_hdl,'String',num2str(old_grp_idx));
      return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   %  update the brainlv and bootstrap ratio fields
   %
   set_blv_fields(grp_idx,lag_idx,lv_idx);

   set(grp_idx_hdl,'Userdata',grp_idx);
   setappdata(gcf,'CurrGroupIdx',grp_idx);

   set(gcf,'Pointer',old_pointer);

   EditXY;

   return;					% EditGroup


%--------------------------------------------------------------------------
function EditLag()

   old_lag_idx = getappdata(gcf,'CurrLagIdx');	% save old lag_idx
   lag_idx_hdl = findobj(gcbf,'Tag','LagIndexEdit');    
   lag_idx = str2num(get(lag_idx_hdl,'String'));

   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if isempty(lag_idx),
      msg = 'ERROR: Invalid input for the Lag index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lag_idx_hdl,'String',num2str(old_lag_idx));
      return;
   end;

   if ( lag_idx == old_lag_idx)
      return;
   end;

   num_lag = getappdata(gcf,'NumLags');
   if (lag_idx < 1 | lag_idx > num_lag)
      msg = 'ERROR: Input Lag index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lag_idx_hdl,'String',num2str(old_lag_idx));
      return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   %  update the brainlv and bootstrap ratio fields
   %
   set_blv_fields(grp_idx,lag_idx,lv_idx);

   set(lag_idx_hdl,'Userdata',lag_idx);
   setappdata(gcf,'CurrLagIdx',lag_idx);

   set(gcf,'Pointer',old_pointer);

   EditXY;

   return;					% EditLag


%--------------------------------------------------------------------------
function EditLV()

   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   lag_idx_hdl = findobj(gcbf,'Tag','LagIndexEdit');    
   lag_idx = str2num(get(lag_idx_hdl,'String'));

   old_lv_idx = getappdata(gcf,'CurrLVIdx');		% save old lv_idx
   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if isempty(lv_idx),
      msg = 'ERROR: Invalid input for the Condition index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lv_idx_hdl,'String',num2str(old_lv_idx));
      return;
   end;

   if ( lv_idx == old_lv_idx)  % LV does not changed do nothing
      return;
   end;

   num_lv = getappdata(gcf,'NumLVs');
   if (lv_idx < 1 | lv_idx > num_lv)
      msg = 'ERROR: Input Condition index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(lv_idx_hdl,'String',num2str(old_lv_idx));
      return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   %  update the brainlv and bootstrap ratio fields
   %
   set_blv_fields(grp_idx,lag_idx,lv_idx);

   set(lv_idx_hdl,'Userdata',lv_idx);
   setappdata(gcf,'CurrLVIdx',lv_idx);

   set(gcf,'Pointer',old_pointer);

   EditXY;

   return;					% EditLV


%--------------------------------------------------------------------------
function EditBSLV()

   old_lv_idx = getappdata(gcf,'CurrBSLVIdx');		% save old lv_idx
   lv_idx_hdl = findobj(gcbf,'Tag','BSLVIndexEdit');
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

   num_lv = getappdata(gcf,'NumBSLVs');
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


   set(lv_idx_hdl,'Userdata',lv_idx);
   setappdata(gcf,'CurrBSLVIdx',lv_idx);

   set(gcf,'Pointer',old_pointer);
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
function LoadResultFile()

   [PLSresultFile,PLSresultFilePath] = ...
                         rri_selectfile('*SmallFCresult.mat','Open PLS Result');
   if isequal(PLSresultFilePath,0), return; end;

   PLSResultFile = [PLSresultFilePath,PLSresultFile];

   DeleteLinkedFigure;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','arrow');

   h = findobj(gcf,'Tag','ResultFile');
   [r_path, r_file, r_ext] = fileparts(PLSResultFile);
   set(h,'UserData', PLSResultFile,'String',r_file);

   % set(gcf,'Name',sprintf('SmallFC PLS Brain Latent Variable Plot: %s',PLSResultFile));

   load_pls_result;
   ShowResult(0,1);

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
    [filename, pathname] = rri_selectfile('SmallFC*.img', ...
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

    load('smallfc_map');

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

%   curr_bs_ratio = bs_ratio(:,lv_idx);
%   curr_bs_ratio(isnan(curr_bs_ratio)) = 0;
%   idx=find(abs(curr_bs_ratio) < std(curr_bs_ratio) * 5); % avoid the outliers

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
%
% initially set blv field at left panel
%
%--------------------------------------------------------------------------
function  [min_blv, max_blv, thresh] = set_blv_fields(grp_idx, lag_idx, lv_idx),

   brainlv_lst = getappdata(gcf,'brainlv');
   setappdata(gcf,'BLVData',brainlv_lst);

   if isempty(brainlv_lst)		 	% no brain lv data -> return;
       return;
   end;

   if ~exist('grp_idx','var') | isempty(grp_idx),
      grp_idx = 1;
   end;

   if ~exist('lag_idx','var') | isempty(lag_idx),
      lag_idx = 1;
   end;

   if ~exist('lv_idx','var') | isempty(lv_idx),
      lv_idx = 1;
   end;

if 0
   brainlv = brainlv_lst{grp_idx, 1};


   blv95 = percentile(brainlv, 95);

   %  find 95 percentile as initial threshold
   %
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
      thresh = blv95(lv_idx);
      min_blv = min(brainlv(:,lv_idx));
      max_blv = max(brainlv(:,lv_idx));
   end

   set(findobj(gcf,'Tag','Threshold'),'String',sprintf('%8.5f',thresh));
   set(findobj(gcf,'Tag','MinValue'),'String',sprintf('%8.5f',min_blv));
   set(findobj(gcf,'Tag','MaxValue'),'String',sprintf('%8.5f',max_blv));
end

   return; 						% set_blv_field


%--------------------------------------------------------------------------
function  p_value = ratio2p(x,mu,sigma)

   p_value = (1 + erf( (x - mu) / (sqrt(2)*sigma))) / 2;
   p_value = (1 - p_value) * 2;

   return; 						% ratio2p


%-------------------------------------------------------------------------
%
function ShowResult(action,update)
% action=0 - plot with the control figure
% action=1 - plot in a seperate figure
%

  mainfig = gcf;
  h = findobj(gcf,'Tag','ResultFile'); PLSresultFile = get(h,'Userdata');
  h = findobj(gcf,'Tag','LVIndexEdit');  lv_idx = get(h,'Userdata');
  h = findobj(gcf,'Tag','GroupIndexEdit');  grp_idx = get(h,'Userdata');
  h = findobj(gcf,'Tag','LagIndexEdit');  lag_idx = get(h,'Userdata');

  curr_lv_idx = getappdata(gcf,'CurrLVIdx');
  if (lv_idx ~= curr_lv_idx),
     lv_idx = curr_lv_idx;
     set(h,'String',num2str(lv_idx));
  end;

  curr_grp_idx = getappdata(gcf,'CurrGroupIdx');
  if (grp_idx ~= curr_grp_idx),
     grp_idx = curr_grp_idx;
     set(h,'String',num2str(grp_idx));
  end;

  curr_lag_idx = getappdata(gcf,'CurrLagIdx');
  if (lag_idx ~= curr_lag_idx),
     lag_idx = curr_lag_idx;
     set(h,'String',num2str(lag_idx));
  end;

  behav_idx = -1;

  fig_hdl = gcf;
  old_pointer = get(fig_hdl,'Pointer');
  set(fig_hdl,'Pointer','watch');

  if 1

     switch action
       case {0}
          smallfc_plot_brainlv(2,PLSresultFile,grp_idx,lv_idx,0,behav_idx,[],update,lag_idx);
       case {1}
          smallfc_plot_brainlv(2,PLSresultFile,grp_idx,lv_idx,1,behav_idx,[],update,lag_idx);
     end

  else							% plot bootstrap ratio

     h = findobj(gcf,'Tag','Threshold');  thresh = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MaxValue');   max_blv = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MinValue');   min_blv = str2num(get(h,'String'));

     if isempty(max_blv) | isempty(min_blv) | isempty(thresh) | ...
	   (abs(max_blv) < thresh) | (abs(min_blv) < thresh)
        msg = 'ERROR: Invalid threshold, minimum or maxinum value setting.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        set(fig_hdl,'Pointer',old_pointer);
	return;
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
	return;
     end;;

     switch action
       case {0}
          smallfc_plot_brainlv(2,PLSresultFile,grp_idx,lv_idx,0,behav_idx,[],update);
       case {1}
          smallfc_plot_brainlv(2,PLSresultFile,grp_idx,lv_idx,1,behav_idx,[],update);
     end;

  end;

  if 0 %~action
     setting = getappdata(gcf,'setting');

     if isempty(setting) | ~isfield(setting,'origin')
        setting.origin = getappdata(gcf,'STOrigin');
     else
        setappdata(gcf,'STOrigin',setting.origin);
        setappdata(gcf,'Origin',setting.origin);
     end;

     setting.grp_idx = grp_idx;
     setting.lv_idx = lv_idx;
     setting.bs_lv_idx = bs_lv_idx;
     setting.behav_idx = behav_idx;
     setting.rot_amount = getappdata(gcf,'RotateAmount');

     setting.thresh{grp_idx,lv_idx,behav_idx} = thresh;
     setting.min_blv{grp_idx,lv_idx,behav_idx} = min_blv;
     setting.max_blv{grp_idx,lv_idx,behav_idx} = max_blv;

     if getappdata(gcf,'ViewBootstrapRatio')		% plot bsr
        setting.bs_thresh{bs_lv_idx} = str2num(get(findobj(gcf,'Tag','BSThreshold'),'String'));
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

%  h_img = findobj(gcf,'tag','BLVImg');
 % img_xlim = get(h_img, 'xdata');
  %img_ylim = get(h_img, 'ydata');
%  img_lx = img_xhair.lx;
 % img_ly = img_xhair.ly;

%  set(img_lx,'xdata', img_xlim, 'ydata', [p_img(2) p_img(2)]);
 % set(img_ly,'xdata', [p_img(1) p_img(1)], 'ydata', img_ylim);


  xhair_color = get(findobj(mainfig,'tag','XhairColorMenu'), 'user');
  set(img_xhair.lx, 'color', xhair_color);
  set(img_xhair.ly, 'color', xhair_color);

  setappdata(gcf,'img_xhair',img_xhair);

  % update the LV scores when needed

  scores_fig = getappdata(gcf,'ScorePlotHdl');

  if isempty(scores_fig)
      set(fig_hdl,'Pointer',old_pointer);
      return;
  else
      smallfc_plot_scores_ui('UPDATE_LV_SELECTION',scores_fig,lv_idx);
      set(scores_fig,'Pointer',old_pointer);
      set(fig_hdl,'Pointer',old_pointer);
  end;

  return;					% ShowResult


%--------------------------------------------------------------------------
function SelectPixel()

   h = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = get(h,'Userdata');

   h = findobj(gcbf,'Tag','LagIndexEdit');    
   lag_idx = get(h,'Userdata');
   
   h = findobj(gcbf,'Tag','LVIndexEdit');
   lv_idx = get(h,'Userdata');

   dims = getappdata(gcbf,'Dims');

   h = getappdata(gcbf,'BlvAxes');
   pos = round(get(h,'CurrentPoint'));
   pos_x = pos(1,1,1); pos_y = pos(1,2,1);

   if (pos_x<1 | pos_x>dims(2) | pos_y<1 | pos_y>dims(1))
      return;
   end

   cur_x = pos_x;
   cur_y = pos_y;
%   coord = (lag_idx-1)*dims(1)*dims(2) + (pos_x-1)*dims(1) + pos_y;
   coord = (pos_x-1)*dims(1) + pos_y;

   setappdata(gcbf,'Coord',coord);

   %  update the brain LV value if needed
   %
   if 1		%(getappdata(gcbf,'ViewBootstrapRatio') == 0),

      brainlv_lst = getappdata(gcbf,'BLVData');
      brainlv = brainlv_lst{grp_idx,1};
%      blv_coords = getappdata(gcbf,'BLVCoords');

      curr_blv = brainlv(:,lv_idx);
%      coord_idx = find(blv_coords == coord);

      h = findobj(gcbf,'Tag','BLVValue');
      blv_value = curr_blv(coord);
      set(h,'String',num2str(blv_value,'%9.6f'));

   end;

    % display the current location.
    %
        xy = [cur_x, cur_y];

        h = findobj(gcbf,'Tag','XYVoxel');
        set(h,'String',sprintf('%d %d',xy));

   setappdata(gcbf,'xy',xy);

   p_img = [pos_x pos_y];
   img_xhair = getappdata(gcbf,'img_xhair');
   img_xhair = rri_xhair(p_img,img_xhair);
   setappdata(gcbf,'img_xhair',img_xhair);
   setappdata(gcbf,'p_img',p_img);

   return; 					% SelectPixel


%--------------------------------------------------------------------------
function EditXY()

   fig = gcbf;
   img_xhair = getappdata(fig,'img_xhair');
   if isempty(img_xhair)
      fig = gcf;
   end

   xy = str2num(get(findobj(gcf,'tag','XYVoxel'),'string'));

   if isempty(xy) | ~isequal(size(xy),[1 2])
      msg = 'XY should contain 2 numbers (X Y)';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

   dims = getappdata(fig,'Dims');

   if ( xy(1)<1 | xy(2)<1 | xy(1)>dims(2) | xy(2)>dims(1) )
      msg = 'Invalid number in X Y';
      set(findobj(fig,'Tag','MessageLine'),'String',msg);
      return;
   end

   pos_x = xy(1);
   pos_y = xy(2);

   setappdata(fig,'xy',xy);

   p_img = [pos_x pos_y];
   img_xhair = getappdata(gcf,'img_xhair');
   img_xhair = rri_xhair(p_img,img_xhair);
   setappdata(gcf,'img_xhair',img_xhair);
   setappdata(gcf,'p_img',p_img);

   return; 					% EditXY


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

   eigen_fig = rri_plot_eigen_ui({eigen.s, eigen.perm_result, eigen.perm_splithalf});

   link_info.hdl = gcbf;
   link_info.name = 'EigenPlotHdl';
   setappdata(eigen_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'EigenPlotHdl',eigen_fig);

   return;					% OpenEigenPlot


%-------------------------------------------------------------------------
%
function OpenCondMeanPlot

   condmean_fig = getappdata(gcbf,'CondMeanPlotHdl');
   if ~isempty(condmean_fig) & ishandle(condmean_fig)
      msg = 'ERROR: Condition Mean Plot has already been plotted';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   condmean_fig = smallfc_plot_condmean;

   link_info.hdl = gcbf;
   link_info.name = 'CondMeanPlotHdl';
   setappdata(condmean_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'CondMeanPlotHdl',condmean_fig);

   return;

