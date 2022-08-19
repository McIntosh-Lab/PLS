function fig = rri_plot_splithalf(varargin)

   if nargin == 0 | ~ischar(varargin{1})	% input is not action

      h = findobj(gcbf,'Tag','ResultFile');
      PLSResultFile = get(h,'UserData');

      fig_h = init(PLSResultFile);

      setappdata(gcf,'CallingFigure',gcbf);

      DisplaySplitHalf;

      if (nargout > 0),
        fig = fig_h;
      end;

      return;
   end

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = varargin{1};

   if (strcmp(action,'delete_fig'))
4
   elseif (strcmp(action,'EditLV'))
      num_lv = getappdata(gcf,'NumLVs');
      curr_lv_idx = getappdata(gcf,'CurrLVIdx');

      lv_idx = str2num(get(findobj(gcf,'tag','LVIndexEdit'),'string'));

      if lv_idx < 1 | lv_idx > num_lv
         msg = 'Wrong LV index';
         set(findobj(gcbf,'Tag','MessageLine'),'String',msg);
      else
         setappdata(gcf,'CurrLVIdx',lv_idx);
      end

      DisplaySplitHalf;
   end

   return;


%-------------------------------------------------------------------------

function h0 = init(PLSResultFile)

%   tit = ['Split Half Plot'];
   tit = 'Ucorr and Vcorr Null distributions';

   save_setting_status = 'on';
   rri_plot_splithalf_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(rri_plot_splithalf_pos) & strcmp(save_setting_status,'on')

      pos = rri_plot_splithalf_pos;

   else

      w = 0.9;
      h = 0.7;

      pos = [(1-w)/2 (1-h)/2 w h];

   end

   xp = 0.0227273;
   yp = 0.0294118;
   wp = 1-2*xp;
   hp = 1-2*yp;

   pos_p = [xp yp wp hp];

   h0 = figure('unit','normal', ...
        'paperunit','normal', ...
        'paperorient','land', ...
        'paperposition',pos_p, ...
        'papertype','usletter', ...
	'numberTitle','off', ...
	'menubar', 'none', ...
	'toolbar', 'none', ...
	'user','PLS Singular Value Plot', ...
	'name',tit, ...
	'deleteFcn', 'rri_plot_splithalf(''delete_fig'');', ...
	'position', pos);

   h = .05;
   fnt = 0.6;

   x = .05;
   y = .88;
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
   	'Callback','rri_plot_splithalf(''EditLV'')', ...
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

   x = .8;
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

   x = .05;
   y = .1;
   w = .43;
   h = .7;

   pos = [x y w h];

   axes1 = axes('Parent',h0, ...
        'Units','normal', ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',[1 1 1], ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','Axes1');

   x = .52;
   y = .1;

   pos = [x y w h];

   axes2 = axes('Parent',h0, ...
        'Units','normal', ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',[1 1 1], ...
   	'Position',pos, ...
   	'XTick', [], ...
   	'YTick', [], ...
   	'Tag','Axes2');

   x = 0.01;
   y = 0;
   w = .5;
   h = .05;

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

   %  file menu
   %
   rri_file_menu(h0);

   load(PLSResultFile);

   num_lv = size(result.u,2);
   lv_idx = 1;

   set(findobj(gcf,'tag','LVIndexEdit'),'string',num2str(lv_idx));
   set(findobj(gcf,'tag','LVNumberEdit'),'string',num2str(num_lv));

   setappdata(gcf,'NumLVs',num_lv);
   setappdata(gcf,'CurrLVIdx',lv_idx);
   setappdata(gcf, 'splithalf', result.splithalf);

   return					% init


%-------------------------------------------------------------------------

function delete_fig()

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      rri_plot_splithalf_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'rri_plot_splithalf_pos');
   catch
   end

   h0 = getappdata(gcbf,'main_fig');
   if isempty(h0), return; end;

   hm_eigen = getappdata(h0,'hm_eigen');
   set(hm_eigen, 'userdata',0, 'check','off');

   return;					% delete_fig


%-------------------------------------------------------------------------

function DisplaySplitHalf()

   lv_idx = getappdata(gcf,'CurrLVIdx');
   splithalf = getappdata(gcf, 'splithalf');

   mean_ucorr_distrib = squeeze(mean(splithalf.ucorr_distrib(:,:,lv_idx),2));
   mean_vcorr_distrib = squeeze(mean(splithalf.vcorr_distrib(:,:,lv_idx),2));
   np = size(mean_ucorr_distrib,1); % numebr of outer permutations
   orig_ucorr = mean_ucorr_distrib(1); % first value corresponds to original unpermuted data

   axes(findobj(gcf,'tag','Axes1'));
   cla;
   hold on;
   [h,bins] = hist(mean_ucorr_distrib,20);
   hb1 = bar(bins,h);
   set(hb1,'facecolor',[0.5 0.9 0.9]);
   scatter(orig_ucorr,0,'r','filled');
   cnt = find(mean_ucorr_distrib(2:end)<=orig_ucorr);
   cnt = length(cnt(:));
   lvperc = round(100 * cnt/(np-1));
   title(['LV ' num2str(lv_idx) '  Ucorr percentile: ' num2str(lvperc) '%']);
   hold off;

   axes(findobj(gcf,'tag','Axes2'));
   cla;
   hold on;
   orig_vcorr = mean_vcorr_distrib(1); % first value corresponds to original unpermuted data
   [h,bins] = hist(mean_vcorr_distrib,20);
   hb2 = bar(bins,h);
   set(hb2,'facecolor',[0.5 0.9 0.9]);
   scatter(orig_vcorr,0,'r','filled');
   cnt = find(mean_vcorr_distrib(2:end)<=orig_vcorr);
   cnt = length(cnt(:));
   lvperc = round(100 * cnt/(np-1));
   title(['LV ' num2str(lv_idx) '  Vcorr percentile: ' num2str(lvperc) '%']);
   hold off;

   return;

