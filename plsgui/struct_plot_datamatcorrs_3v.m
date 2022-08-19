
function fig = struct_plot_datamatcorrs_3v(action,varargin)

   if ~exist('action','var') | isempty(action)

%      [PLSresultFile,PLSresultFilePath] =  ...
%                        rri_selectfile('*PETresult.mat','Open PET Result');
%      if (PLSresultFilePath == 0), return; end;

%      PLSResultFile = fullfile(PLSresultFilePath,PLSresultFile);

      h = findobj(gcbf,'Tag','ResultFile');
      PLSResultFile = get(h,'UserData');

      msg = 'Loading Datamat Correlations Data ...    Please wait!';
      hb = rri_wait_box(msg,[0.5 0.1]);

      fig_h = init(PLSResultFile);

      setappdata(gcf,'CallingFigure',gcbf);
%      set(gcbf,'visible','on');

      rot_amount = load_pls_result;
%      struct_plot_datamatcorrs_3v('Rotation', rot_amount);
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
     ShowResult(0,1);
   elseif (strcmp(action,'EditBehav'))
     EditBehav;
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

         struct_plot_datamatcorrs_3v_newfig_pos = get(gcbf,'position');

         save(pls_profile, '-append', 'struct_plot_datamatcorrs_3v_newfig_pos');
      catch
      end
   elseif (strcmp(action,'DeleteFigure'))
     try
        load('pls_profile');
        pls_profile = which('pls_profile.mat');

        struct_plot_datamatcorrs_3v_pos = get(gcbf,'position');

        save(pls_profile, '-append', 'struct_plot_datamatcorrs_3v_pos');
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
 %             setting6 = setting;
  %            save(PLSresultFile, '-append', 'setting6');
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
   elseif (strcmp(action,'OpenDatamatcorrsPlot'))
     OpenDatamatcorrsPlot;
   elseif (strcmp(action,'OpenScoresPlot'))
     pet_plot_scores_ui(varargin{1});
   elseif (strcmp(action,'OpenEigenPlot'))
     OpenEigenPlot;
   elseif (strcmp(action,'SetClusterReportOptions'))
     SetClusterReportOptions;
   elseif (strcmp(action,'LoadClusterReport'))
     struct_cluster_report('LoadClusterReport',gcbf);
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
   elseif (strcmp(action,'EditXYZ'))
      EditXYZ;
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
   struct_plot_datamatcorrs_3v_pos = [];

   try
      load('pls_profile');
   catch 
   end

   if ~isempty(struct_plot_datamatcorrs_3v_pos) & strcmp(save_setting_status,'on')

      pos = struct_plot_datamatcorrs_3v_pos;

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
   	'DeleteFcn','struct_plot_datamatcorrs_3v(''DeleteFigure'')', ...
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
	'visible', 'off', ...
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
   	'Callback','struct_plot_datamatcorrs_3v(''EditGroup'')', ...
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
   	'Callback','struct_plot_datamatcorrs_3v(''EditLV'')', ...
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
   	'String','Behavior Index:', ...
   	'Style','text', ...
   	'Tag','BehavIndexLabel');

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
   	'Callback','struct_plot_datamatcorrs_3v(''EditBehav'')', ...
   	'Tag','BehavIndexEdit');

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



   %  Brain LV

   x = .03;
   y = .3;
   w = .26;
   h = .45;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Brain LV frame
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','frame', ...
   	'Tag','ThresholdFrame');

   x = .08;
   y = .72;
   w = .16;
   h = .04;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% Brain LV title
   	'Units','normal', ...
	'Visible','on', ...
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
   y = .67;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% threshold label
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

   h1 = uicontrol('Parent',h0, ...			% threshold edit
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
        'Callback','struct_plot_datamatcorrs_3v(''PlotBnPress'')', ...
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

   h1 = uicontrol('Parent',h0, ...			% min value edit
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
        'Callback','struct_plot_datamatcorrs_3v(''PlotBnPress'')', ...
   	'Tag','MinValue');

   x = .05;
   y = y-h-.02;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...			% max value label
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

   h1 = uicontrol('Parent',h0, ...			% max value edit
   	'Units','normal', ...
	'Visible','on', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'ListboxTop',0, ...
   	'Position',pos, ...
   	'Style','edit', ...
        'Callback','struct_plot_datamatcorrs_3v(''PlotBnPress'')', ...
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
   	'Callback','struct_plot_datamatcorrs_3v(''EditBSLV'')', ...
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
   	'Callback','struct_plot_datamatcorrs_3v(''UpdatePValue'')', ...
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
        'Callback','struct_plot_datamatcorrs_3v(''PlotBnPress'')', ...
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
        'Callback','struct_plot_datamatcorrs_3v(''PlotBnPress'')', ...
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
   	'Callback','struct_plot_datamatcorrs_3v(''EditXYZ'')');

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
   	'Callback','struct_plot_datamatcorrs_3v(''EditXYZ'')', ...
   	'Tag','XYZVoxel');

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
   	'Callback','struct_plot_datamatcorrs_3v(''EditXYZmm'')', ...
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
           'Callback','struct_plot_datamatcorrs_3v(''LoadBackgroundImage'')');
   h2 = uimenu(h_file, ...
           'Label','Save brain region to IMG file', ...
   	   'Tag','SaveBGImage', ...
           'Callback','struct_plot_datamatcorrs_3v(''SaveBackgroundImage'')');
   h2 = uimenu(h_file, ...
           'Label','&Load PLS Result', ...
   	   'Tag','LoadPETResult', ...
		'visible', 'off', ...
           'Callback','struct_plot_datamatcorrs_3v(''LoadResultFile'')');
   h2 = uimenu(h_file, ...
           'Label','&Save Current Display to the IMG files', ...
   	   'Tag','SaveDisplayToIMG', ...
           'Callback','struct_plot_datamatcorrs_3v(''SaveDisplayToIMG'')'); 
   h2 = uimenu(h_file, ...
           'Label','&Save DatamatCorrelation to IMG file', ...
   	   'Tag','SaveResultToIMG', ...
           'Callback','struct_plot_datamatcorrs_3v(''SaveResultToIMG'')');
   h2 = uimenu(h_file, ...
           'Label','Create Datamat Correlations &Figure', ...
   	   'Tag','PlotNewFigure', ...
           'Callback','struct_plot_datamatcorrs_3v(''PlotOnNewFigure'')');

   rri_file_menu(h0);

   % Xhair submenu
   %
   h_xhair = uimenu('Parent',h0, 'Label','Crosshair');
   h2 = uimenu('Parent',h_xhair, ...
   	   'Label','Crosshair off', ...
	   'Userdata', 0, ...
           'Callback','struct_result_ui(''crosshair'')', ...
   	   'Tag','XhairToggleMenu');
   h2 = uimenu('Parent',h_xhair, ...
   	   'Label','Color ...', ...
	   'Userdata', [1 0 0], ...
           'Callback','struct_result_ui(''set_xhair_color'')', ...
   	   'Tag','XhairColorMenu');

   % Zoom submenu
   %
   h2 = uimenu('Parent',h0, ...
   	   'Label','&Zoom on', ...
	   'Userdata', 1, ...
           'Callback','struct_plot_datamatcorrs_3v(''Zooming'')', ...
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
           'Callback','struct_plot_datamatcorrs_3v(''Rotation'',1)', ...
   	   'Tag','Rotate0Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&90 degree', ...		% another 90 degree
   	   'Checked','off', ...
           'Callback','struct_plot_datamatcorrs_3v(''Rotation'',2)', ...
   	   'Tag','Rotate90Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&180 degree', ...		% now become 270 degree
   	   'Checked','off', ...
           'Callback','struct_plot_datamatcorrs_3v(''Rotation'',3)', ...
   	   'Tag','Rotate180Menu');
   h2 = uimenu('Parent',h_rot, ...
   	   'Label','&270 degree', ...		% now completed 360 degree
   	   'Checked','off', ...
           'Callback','struct_plot_datamatcorrs_3v(''Rotation'',0)', ...
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
           'Callback','struct_plot_datamatcorrs_3v(''OpenEigenPlot'')');
   h2 = uimenu(h_pls, ...
           'Label','&Behavior LV and Behavior Scores Plot', ...
	   'Visible','off', ...
     	   'Tag','OpenBehavPlot', ...
           'Callback','struct_plot_datamatcorrs_3v(''OpenScoresPlot'',0)');
   h2 = uimenu(h_pls, ...
           'Label','&Design LV and Design Scores Plot', ...
	   'Visible','off', ...
     	   'Tag','OpenDesignPlot', ...
           'Callback','struct_plot_datamatcorrs_3v(''OpenScoresPlot'',1)');
   h2 = uimenu(h_pls, ...
           'Label','B&rain Scores vs. Behavior Data Plot', ...
     	   'Tag','OpenBrainPlot', ...
           'Callback','struct_plot_datamatcorrs_3v(''OpenBrainPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Voxel Intensity Response', ...
     	   'Tag','OpenRFPlot', ...
           'Callback','struct_plot_datamatcorrs_3v(''OpenResponseFnPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Datamat Correlations Response', ...
     	   'Tag','OpenRF1Plot', ...
           'Callback','struct_plot_datamatcorrs_3v(''OpenResponseFnPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','&Datamat Correlations Plot', ...
     	   'Tag','OpenDatamatcorrsPlot', ...
           'Callback','struct_plot_datamatcorrs_3v(''OpenDatamatcorrsPlot'')'); 
   h2 = uimenu(h_pls, ...
           'Label','Create Brain LV &Figure', ...
	   'separator', 'on', ...
   	   'Tag','PlotNewFigure', ...
           'Callback','struct_plot_datamatcorrs_3v(''PlotOnNewFigure'')');

   %  Report submenu
   %
   h_pls = uimenu('Parent',h0, ...
   	   'Label','&Report', ...
   	   'Tag','WindowsMenu', ...
   	   'Visible','off');
   h2 = uimenu(h_pls, ...
           'Label','&Set Cluster Report Options', ...
     	   'Tag','SetClusterReportOptions', ...
           'Callback','struct_plot_datamatcorrs_3v(''SetClusterReportOptions'')');
   h2 = uimenu(h_pls, ...
           'Label','&Load Cluster Report', ...
     	   'Tag','LoadClsuterReport', ...
           'Callback','struct_plot_datamatcorrs_3v(''LoadClusterReport'')');
   h2 = uimenu(h_pls, ...
           'Label','&Create Cluster Report', ...
     	   'Tag','OpenClusterReport', ...
           'Callback','struct_plot_datamatcorrs_3v(''OpenClusterReport'')');

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',h0, ...
           'Label', '&Help', ...
		'visible', 'off', ...
           'Tag', 'Help');
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','rri_helpfile_ui(''struct_result_hlp.txt'',''How to use PLS RESULT'');', ...
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


   set(gcf,'Name',sprintf('PET PLS Result: %s',PLSResultFile));
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

   datamatcorrs_fig = getappdata(gcbf,'DatamatcorrsPlotHdl');
   if ~isempty(datamatcorrs_fig) & ishandle(datamatcorrs_fig)
     close(datamatcorrs_fig);
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

%   brainlv = brainlv * diag(s);		% already RESCALED

   setting = getappdata(gcf,'setting');
   if isempty(setting)
      grp_idx = 1;					% group idx
      lv_idx = 1;					% condition idx
      bs_lv_idx = 1;
      behav_idx = 1;					% behavior idx
      rot_amount = 1;
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
   end;

   num_grp = length(num_subj_lst);
   num_lv = num_conditions;
   bs_num_lv = size(brainlv,2);

   brainlv = datamatcorrs_lst{grp_idx};
   num_behav = size(brainlv, 1) / num_conditions;

   if exist('behavlv','var')
      set(gcf,'Name', ...
	sprintf('PET Behavioral PLS Brain LV Plot: %s',PLSresultFile));
      set(findobj(gcf,'Tag','OpenBrainPlot'), 'Visible', 'On');
      set(findobj(gcf,'Tag','OpenBehavPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenDesignPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenRFPlot'), 'Visible', 'Off');
      set(findobj(gcf,'Tag','OpenRF1Plot'), 'Visible', 'On');
      set(findobj(gcf,'tag','OpenDatamatcorrsPlot'), 'visible', 'on');
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

   h = findobj(gcf,'Tag','BSLVIndexEdit');
   set(h,'String',num2str(bs_lv_idx),'Userdata',bs_lv_idx);
   h = findobj(gcf,'Tag','BSLVNumberEdit');
   set(h,'String',num2str(bs_num_lv),'Userdata',bs_num_lv);

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

%      for i = 1:num_conditions
%         tmp{i} = brainlv(r*(i-1)+1:r*i, :);
%      end  
%
%      brainlv = ones(num_conditions, c);
%
%      for i = 1:num_conditions
%         brainlv(i,:) = mean(tmp{i},1);
%      end
%
%      brainlv = brainlv';
%      brainlv_lst{g} = brainlv;

      end
   end


   setappdata(gcf,'brainlv',brainlv_lst);
   setappdata(gcf, 's', s);
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
      set_bs_fields(bs_lv_idx);
      UpdatePValue;
   end;

   set(gcf,'Pointer',old_pointer);
   set(findobj(gcf,'Tag','MessageLine'),'String','');

   setappdata(gcf,'DatamatFileList', datamat_files);
   setappdata(gcf,'RotateAmount',rot_amount);
   setappdata(gcf,'CurrGroupIdx',grp_idx);
   setappdata(gcf,'CurrBehavIdx',behav_idx);
   setappdata(gcf,'NumGroup',num_grp);
   setappdata(gcf,'CurrLVIdx',lv_idx);
   setappdata(gcf,'CurrBSLVIdx',bs_lv_idx);
   setappdata(gcf,'Dims',dims);
   setappdata(gcf,'NumBSLVs',bs_num_lv)

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

  brain_plot = struct_plot_brain_scores('STARTUP',PLSresultFile);
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

  rf_plot = struct_plot_rf('LINK',DatamatFileList);
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

   struct_cluster_report(cluster_min_size,cluster_min_dist);

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
%     struct_create_colorbar(colorbar_hdl,cbar,min_ratio,max_ratio);
     return;
  end;

  set(h_img,'ButtonDownFcn','struct_plot_datamatcorrs_3v(''SelectPixel'')');
%  struct_create_colorbar( colorbar_hdl, cbar, min_ratio, max_ratio );


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

  image_fn = sprintf('%sPETdatcorr_disp_grp%d_cond%d_beh%d.img',resultfile_prefix,grp_idx,lv_idx,behav_idx);

  [filename, pathname] = rri_selectfile(image_fn,'Datamat Correlation IMG file');

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

  descrip = sprintf('DatamatCorrelation from %s, Group: %d, Condition: %d, Behavior: %d, Threshold: %8.5f', ...
		PLSresultFile,grp_idx,lv_idx,behav_idx,thresh_ratio);
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

  image_fn = sprintf('%sPETdatcorr_grp%d_cond%d_beh%d.img',resultfile_prefix,grp_idx,lv_idx,behav_idx);

  [filename, pathname] = rri_selectfile(image_fn,'Datamat Correlation IMG file');

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

  descrip = sprintf('DatamatCorrelation from %s, Group: %d, Condition: %d, Behavior: %d, Threshold: %8.5f', ...
		PLSresultFile,grp_idx,lv_idx,behav_idx,thresh_ratio);
  rri_write_img(filename,img,0,dims,voxel_size,16,origin,descrip);

  return;					% create_brainlv_img


%--------------------------------------------------------------------------
function create_bs_ratio_img(PLSresultFile,lv_idx,thresh_ratio);

  %  get the output IMG filename first  
  %
  [pn fn] = fileparts(PLSresultFile);
  resultfile_prefix = fn(1:end-9);
  image_fn = [resultfile_prefix, 'PETbsr.img'];

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
function [st_filename] = get_st_datamat_filename(DatamatFileList,with_path)
%
%   INPUT:
%       DatamatFileList - vector of cell structure, each element contains
%                         the full path of a session file.
%       with_path - whether including path in the constructed the filename
%                   of the st_datamat. 
%		    with_path = 0 : no path 
%		    with_path = 1 : including path
%
  num_files = length(DatamatFileList);
  st_filename = cell(1,num_files);

  for i=1:num_files,
     load( DatamatFileList{i} );
     if with_path,
       st_filename{i} = sprintf('%s/%s_st_datamat.mat', ...
                     session_info.pls_data_path, session_info.datamat_prefix);
     else
       st_filename{i} = sprintf('%s_st_datamat.mat', ...
                                                 session_info.datamat_prefix);
     end;
  end;

  return;					% get_st_datamat_name


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
   fig_title = sprintf('PET Datamat Correlations Plot: %s',PLSResultFile);
   set(gcf,'Name',fig_title);

   EditXYZ;

   return;					% ToggleView


%--------------------------------------------------------------------------
function EditGroup()

   old_grp_idx = getappdata(gcf,'CurrGroupIdx');	% save old grp_idx
   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   behav_idx_hdl = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = str2num(get(behav_idx_hdl,'String'));

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
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   set(grp_idx_hdl,'Userdata',grp_idx);
   setappdata(gcf,'CurrGroupIdx',grp_idx);

   set(gcf,'Pointer',old_pointer);

   EditXYZ;

   return;					% EditGroup


%--------------------------------------------------------------------------
function EditBehav()

   old_behav_idx = getappdata(gcf,'CurrBehavIdx');	% save old behav_idx
   behav_idx_hdl = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = str2num(get(behav_idx_hdl,'String'));

   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   lv_idx_hdl = findobj(gcbf,'Tag','LVIndexEdit');    
   lv_idx = str2num(get(lv_idx_hdl,'String'));

   if isempty(behav_idx),
      msg = 'ERROR: Invalid input for the Behavior index.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(behav_idx_hdl,'String',num2str(old_behav_idx));
      return;
   end;

   if ( behav_idx == old_behav_idx)
      return;
   end;

   num_behav = getappdata(gcf,'NumBehav');
   if (behav_idx < 1 | behav_idx > num_behav)
      msg = 'ERROR: Input Behavior index is out of range.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(behav_idx_hdl,'String',num2str(old_behav_idx));
      return;
   end;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   %  update the brainlv and bootstrap ratio fields
   %
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   set(behav_idx_hdl,'Userdata',behav_idx);
   setappdata(gcf,'CurrBehavIdx',behav_idx);

   set(gcf,'Pointer',old_pointer);

   EditXYZ;

   return;					% EditBehav


%--------------------------------------------------------------------------
function EditLV()

   grp_idx_hdl = findobj(gcbf,'Tag','GroupIndexEdit');    
   grp_idx = str2num(get(grp_idx_hdl,'String'));

   behav_idx_hdl = findobj(gcbf,'Tag','BehavIndexEdit');    
   behav_idx = str2num(get(behav_idx_hdl,'String'));

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
   set_blv_fields(grp_idx,behav_idx,lv_idx);

   set(lv_idx_hdl,'Userdata',lv_idx);
   setappdata(gcf,'CurrLVIdx',lv_idx);

   set(gcf,'Pointer',old_pointer);

   EditXYZ;

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
                         rri_selectfile('*PETresult.mat','Open PLS Result');
   if isequal(PLSresultFilePath,0), return; end;

   PLSResultFile = [PLSresultFilePath,PLSresultFile];

   DeleteLinkedFigure;

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','arrow');

   h = findobj(gcf,'Tag','ResultFile');
   [r_path, r_file, r_ext] = fileparts(PLSResultFile);
   set(h,'UserData', PLSResultFile,'String',r_file);

   % set(gcf,'Name',sprintf('PET PLS Brain Latent Variable Plot: %s',PLSResultFile));

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

    load('struct_map');

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
function  [min_blv, max_blv, thresh] = set_blv_fields(grp_idx, behav_idx, lv_idx),

if(0)
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
end

   brainlv_lst = getappdata(gcf,'brainlv');
   setappdata(gcf,'BLVData',brainlv_lst);

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

   brainlv = brainlv_lst{grp_idx, behav_idx};

if(0)
      brainlv = getappdata(gcf,'brainlv');

   if isempty(brainlv),		 	% no brain lv data -> return;
       return;
   end;

   if ~exist('lv_idx','var') | isempty(lv_idx),
      lv_idx = 1;
   end;
end

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

  h = findobj(gcf,'Tag','ResultFile'); PLSresultFile = get(h,'Userdata');

  try 				% load the dimension info of the datamat
     load(PLSresultFile,'dims'),
  catch
     msg =sprintf('ERROR: Cannot load the PET result file "%s".',PLSresultFile);
     set(findobj(gcf,'Tag','MessageLine'),'String',msg);
     return;
  end;

  h = findobj(gcf,'Tag','LVIndexEdit');  lv_idx = get(h,'Userdata');
  curr_lv_idx = getappdata(gcf,'CurrLVIdx');
  if (lv_idx ~= curr_lv_idx),
     lv_idx = curr_lv_idx;
     set(h,'String',num2str(lv_idx));
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

  fig_hdl = gcf;
  old_pointer = get(fig_hdl,'Pointer');
  set(fig_hdl,'Pointer','watch');

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

     switch action
       case {0}
          pet_plot_brainlv_3v(0,PLSresultFile,grp_idx,lv_idx,0,behav_idx,[],update,1);
       case {1}
          pet_plot_brainlv_3v(0,PLSresultFile,grp_idx,lv_idx,1,behav_idx,[],update,1);
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
        h = findobj(gcf,'Tag','Threshold');  set(h,'String','0');
        thresh = 0;
     end;

     h = findobj(gcf,'Tag','BSThreshold');
     thresh_ratio = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MaxRatio'); max_ratio = str2num(get(h,'String'));
     h = findobj(gcf,'Tag','MinRatio'); min_ratio = str2num(get(h,'String'));

     if (abs(max_ratio) < thresh_ratio) | (abs(min_ratio) < thresh_ratio)
        thresh_ratio = 0;
        h = findobj(gcf,'Tag','BSThreshold');
        set(h,'String',num2str(thresh_ratio));
     end

     if isempty(max_ratio) | isempty(min_ratio) | isempty(thresh_ratio) | ...
	   (abs(max_ratio) < thresh_ratio) | (abs(min_ratio) < thresh_ratio)
        msg = 'ERROR: Invalid threshold, minimum or maxinum ratio setting.';
        set(findobj(gcf,'Tag','MessageLine'),'String',msg);
        set(fig_hdl,'Pointer',old_pointer);
        h = findobj(gcf,'Tag','BSThreshold');  set(h,'String','0');
        thresh_ratio = 0;
     end;;

     switch action
       case {0}
          pet_plot_brainlv_3v(2,PLSresultFile,grp_idx,lv_idx,0,behav_idx,[],update,1);
       case {1}
          pet_plot_brainlv_3v(2,PLSresultFile,grp_idx,lv_idx,1,behav_idx,[],update,1);
     end;

  end;

  if ~action
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

  scores_fig = getappdata(gcf,'ScorePlotHdl');

  if isempty(scores_fig)
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
      coord_idx = find(blv_coords == coord);

      h = findobj(gcbf,'Tag','BLVValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         blv_value = curr_blv(coord_idx);
         set(h,'String',num2str(blv_value,'%9.6f'));
      end;

   end;


   h = findobj(gcbf,'Tag','XYZVoxel');
   set(h,'String',sprintf('%d %d %d',xyz));

   h = findobj(gcbf,'Tag','XYZmm');
   set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

   return; 					% SelectPixel


%--------------------------------------------------------------------------
function EditXYZ()

   xyz = str2num(get(findobj(gcf,'tag','XYZVoxel'),'string'));

   if isempty(xyz) | ~isequal(size(xyz),[1 3])
      msg = 'XYZ should contain 3 numbers (X, Y, and Z)';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end

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
      coord_idx = find(blv_coords == coord);

      h = findobj(gcf,'Tag','BLVValue');
      if isempty(coord_idx)
         set(h,'String','n/a');
      else
         blv_value = curr_blv(coord_idx);
         set(h,'String',num2str(blv_value,'%9.6f'));
      end;

   end;

   h = findobj(gcf,'Tag','XYZVoxel');
   set(h,'String',sprintf('%d %d %d',xyz));

   h = findobj(gcf,'Tag','XYZmm');
   set(h,'String',sprintf('%2.1f %2.1f %2.1f',xyz_mm));

   return; 					% EditXYZ


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
function OpenDatamatcorrsPlot

   datamatcorrs_fig = getappdata(gcbf,'DatamatcorrsPlotHdl');
   if ~isempty(datamatcorrs_fig) & ishandle(datamatcorrs_fig)
      msg = 'ERROR: Datamat Correlations Plot has already been plotted';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end  

   datamatcorrs_fig = struct_plot_datamatcorrs_3v;

   link_info.hdl = gcbf;
   link_info.name = 'DatamatcorrsPlotHdl';
   setappdata(datamatcorrs_fig,'LinkFigureInfo',link_info);
   setappdata(gcbf,'DatamatcorrsPlotHdl',datamatcorrs_fig);

   return;

