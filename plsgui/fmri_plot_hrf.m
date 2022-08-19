%  Show Hemodynamic Response Function for PLS MRI session
%
%  Usage:
%	1.	fmri_plot_hrf(session_file);	% file name string
%	2. or:  fmri_plot_hrf(session_info);	% session_info struct
%	3. or:  fmri_plot_hrf(condition, evt_onsets);
%		where:	condition = session_info.condition;
%			evt_onsets = session_info.run(r).evt_onsets;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h01 = fmri_plot_hrf(varargin)

   if nargin == 0				% just for test usage
      load test_fmrisession;

      condition = session_info.condition;
      evt_onsets = session_info.run(1).evt_onsets;

      h01 = init(condition, evt_onsets);
      return;
   elseif nargin == 2 & iscell(varargin{1})
      h01 = init(varargin{1},varargin{2});
      return;
   elseif nargin == 1 & isstruct(varargin{1})
      session_info = varargin{1};
      condition = session_info.condition;
      run = session_info.run;

      for r = 1:length(run)
         evt_onsets = session_info.run(r).evt_onsets;
         h01 = fmri_plot_hrf(condition, evt_onsets);
         set(gcf, 'name', ['Run #', num2str(r)]);
      end

      return;
   elseif nargin == 1 & ischar(varargin{1})
      load(varargin{1});
      h01 = fmri_plot_hrf(session_info);
      return;
   end

  %  clear the message line,
  %
  h = findobj(gcf,'Tag','MessageLine');
  set(h,'String','');

   switch varargin{1}{1}
   case 'MOVE_COND_SLIDE'
      h = findobj(gcf,'Tag','ConditionSlider');
      start_cond = get(h,'Max') - round(get(h,'Value')) + 1; 
      plot_hrf(start_cond);
   case {'TR', 'win_size'}
      h = findobj(gcf, 'Tag', 'TR');
      TR = str2num(get(h, 'string'));

      if TR < 1
         TR = getappdata(gcf, 'TR');
         set(h, 'string', num2str(TR));

         msg = 'Please select an integer between 1 and 5';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end

      h = findobj(gcf, 'Tag', 'win_size');
      win_size = str2num(get(h, 'string'));

      if win_size < 1
         win_size = getappdata(gcf, 'win_size');
         set(h, 'string', num2str(win_size));

         msg = 'Please select an integer between 1 and 5';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end

      setappdata(gcf,'TR',TR);
      setappdata(gcf,'win_size',win_size);

      evt_onsets = getappdata(gcf,'evt_onsets');
      condition = getappdata(gcf,'condition');

      [x1 y1 x2 y2 y22] = fmri_hrf_data(evt_onsets, condition, TR, win_size);
      setappdata(gcf,'x1',x1);
      setappdata(gcf,'y1',y1);
      setappdata(gcf,'x2',x2);
      setappdata(gcf,'y2',y2);
      setappdata(gcf,'y22',y22);

      start_cond = getappdata(gcf,'start_cond');
      plot_hrf(start_cond);
   case 'NumRows'
      h = findobj(gcf, 'Tag', 'NumRows');
      disp_num_conditions = str2num(get(h, 'string'));

      if disp_num_conditions > 5 | disp_num_conditions < 1
         plot_dims = getappdata(gcf, 'PlotDims');
         set(h, 'string', num2str(plot_dims(1)));

         msg = 'Please select an integer between 1 and 5';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end

      plot_dims = [disp_num_conditions, 1];
      setappdata(gcf, 'PlotDims', plot_dims);

      axes_margin = getappdata(gcf,'AxesMargin');
      set_cond_axes(plot_dims(1),plot_dims(2),axes_margin);	% set up axes

      plot_hrf(1);
      setup_sliders;
   case 'zoom'
      zoom_on_state = get(gcbo,'Userdata');
      if (zoom_on_state == 1)			% zoom on
         zoom on;
         set(gcbo,'Userdata',0,'Label','&Zoom off');
         set(gcf,'pointer','crosshair');
      else					% zoom off
         zoom off;
         set(gcbo,'Userdata',1,'Label','&Zoom on');
         set(gcf,'pointer','arrow');
      end
   case 'TOGGLE_SHOW_AVERAGE'
      h = findobj(gcf,'Tag','ToggleShowAvgMenu');
      switch (getappdata(gcf,'ShowAverage'))
         case {0},
	     setappdata(gcf,'ShowAverage',1);
	     set(h,'Label','Hide average');
         case {1},
	     setappdata(gcf,'ShowAverage',0);
	     set(h,'Label','Plot average');
      end;

      start_cond = getappdata(gcf,'start_cond');

      h = findobj(gcf, 'Tag', 'NumRows');
      plot_dims = [str2num(get(h, 'string')), 1];
      setappdata(gcf, 'PlotDims', plot_dims);

      axes_margin = getappdata(gcf,'AxesMargin');
      set_cond_axes(plot_dims(1),plot_dims(2),axes_margin);	% set up axes

      plot_hrf(start_cond);
   case 'TOGGLE_SHOW_COMBINED'
      h = findobj(gcf,'Tag','ToggleShowCombinedMenu');
      switch (getappdata(gcf,'CombinedPlots'))
         case {0},
	     setappdata(gcf,'CombinedPlots',1);
	     set(h,'Label','Plot individual condition');
         case {1},
	     setappdata(gcf,'CombinedPlots',0);
	     set(h,'Label','Plot combined condition');
      end;

      start_cond = getappdata(gcf,'start_cond');
      plot_hrf(start_cond);
   case 'delete_fig'
      delete_fig;
   end

   return;						% fmri_plot_hrf


%--------------------------------------------------------------------------
%
function hh = init(condition, evt_onsets)

   for i = 1:length(evt_onsets)
      evt_onsets{i} = evt_onsets{i}(:);
   end

   num_conditions = length(condition);

   if num_conditions > 5
      disp_num_conditions = 5;
   else
      disp_num_conditions = num_conditions;
   end

   save_setting_status = 'on';
   fmri_plot_hrf_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_plot_hrf_pos) & strcmp(save_setting_status,'on')

      pos = fmri_plot_hrf_pos;

   else

      w = 0.9;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   hh = figure('Units','normal', ...
	   'Name','Hemodynamic Response Function Plot', ...	
	   'NumberTitle','off', ...
	   'Color', [0.8 0.8 0.8], ...
 	   'DoubleBuffer','on', ...
	   'Menubar', 'none', ...
	   'DeleteFcn', 'fmri_plot_hrf({''delete_fig''});', ...
	   'Position',pos, ...
	   'Tag','PlotHRFFig');

   x = 0.05;
   y = 0.08;
   w = 0.11;
   h = 0.05;

   pos = [x y w h];

   h1 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontSize', 12, ...
          'Style', 'text', ...
	  'Position', pos, ...
          'background', [.8 .8 .8], ...
          'String', 'Window Size:');

   x = x + w;
   w = 0.04;

   pos = [x y w h];

   h1 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontSize', 12, ...
          'Style', 'edit', ...
	  'Position', pos, ...
          'background', [1 1 1], ...
          'String', '8', ...
          'Callback','fmri_plot_hrf({''win_size''});', ...
	  'Tag', 'win_size');

   x = x + w;
   w = 0.1;

   pos = [x y w h];

   h1 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontSize', 12, ...
          'Style', 'text', ...
	  'Position', pos, ...
          'background', [.8 .8 .8], ...
          'String', '(TimePoints)');

   x = x + w + 0.01;
   w = 0.05;

   pos = [x y w h];

   h1 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontSize', 12, ...
          'Style', 'text', ...
	  'Position', pos, ...
          'background', [.8 .8 .8], ...
          'String', 'TR:');

   x = x + w;
   w = 0.04;

   pos = [x y w h];

   h1 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontSize', 12, ...
          'Style', 'edit', ...
	  'Position', pos, ...
          'background', [1 1 1], ...
          'String', '2', ...
          'Callback','fmri_plot_hrf({''TR''});', ...
	  'Tag', 'TR');

   x = x + w;
   w = 0.08;

   pos = [x y w h];

   h1 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontSize', 12, ...
          'Style', 'text', ...
	  'Position', pos, ...
          'background', [.8 .8 .8], ...
          'String', '(Seconds)');

   x = x + w + 0.01;
   w = 0.25;

   pos = [x y w h];

   h1 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontSize', 12, ...
          'Style', 'text', ...
	  'Position', pos, ...
          'background', [.8 .8 .8], ...
          'String', 'Number of conditions per display:');

   x = x + w;
   w = 0.04;

   pos = [x y w h];

   h1 = uicontrol('Parent',hh, ...
          'Units','normal', ...
          'FontSize', 12, ...
          'Style', 'edit', ...
	  'Position', pos, ...
          'background', [1 1 1], ...
          'String', num2str(disp_num_conditions), ...
          'Callback','fmri_plot_hrf({''NumRows''});', ...
	  'Tag', 'NumRows');

   x = 0.01;
   y = 0;
   w = 1;
   h = 0.05;

   pos = [x y w h];

   h1 = uicontrol('Parent',hh, ...		% Message Line
   	'Style','text', ...
   	'Units','normal', ...
        'FontSize', 12, ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'ForegroundColor',[0.8 0.0 0.0], ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','', ...
   	'Tag','MessageLine');

   %  file menu
   %
   rri_file_menu(hh);

   %  zoom
   %
   h1 = uimenu('parent',hh, ...
        'userdata', 1, ...
        'callback','fmri_plot_hrf({''zoom''});', ...
        'label','&Zoom on');

   %  show/hide avg
   %
   h1 = uimenu('Parent',hh, ...
	     'Label','Hide average', ...
	     'Tag','ToggleShowAvgMenu', ...
	     'Callback','fmri_plot_hrf({''TOGGLE_SHOW_AVERAGE''});');

   %  show/hide combined
   %
   h1 = uimenu('Parent',hh, ...
	     'Label','Plot combined condition', ...
	     'Tag','ToggleShowCombinedMenu', ...
	     'Callback','fmri_plot_hrf({''TOGGLE_SHOW_COMBINED''});');

   %  Help submenu
   %
   Hm_topHelp = uimenu('Parent',hh, ...
           'Label', '&Help', ...
           'Tag', 'Help');
   Hm_how = uimenu('Parent',Hm_topHelp, ...
           'Label', '&How to use this window?', ...
           'Callback','rri_helpfile_ui(''fmri_plot_hrf_hlp.txt'',''How to use it'');', ...
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

   setappdata(gcf,'evt_onsets', evt_onsets);
   setappdata(gcf,'condition', condition);
   setappdata(gcf,'ShowAverage',1);
   setappdata(gcf,'CombinedPlots',0);

   TR = 2;				% init. value for user guessing
   setappdata(gcf,'TR',TR);

   win_size = 8;			% init. value for user guessing
   setappdata(gcf,'win_size',win_size);

   cond_idx = [1:num_conditions];
   setappdata(gcf,'PlotCondIdx',cond_idx);

   plot_dims = [disp_num_conditions 1];
   setappdata(gcf,'PlotDims',plot_dims);

   [x1 y1 x2 y2 y22] = fmri_hrf_data(evt_onsets, condition, TR, win_size);
   setappdata(gcf,'x1',x1);
   setappdata(gcf,'y1',y1);
   setappdata(gcf,'x2',x2);
   setappdata(gcf,'y2',y2);
   setappdata(gcf,'y22',y22);

   % set up axes, and the values of 'AxesMargin', 'AxesHlds' and 'AxesPos'
   %
   axes_margin = [.1 .1 .2 .03];
   setappdata(gcf,'AxesMargin',axes_margin);

   set_cond_axes(plot_dims(1),plot_dims(2),axes_margin);	% set up axes

   % plot the data and set the values of 'start_cond'
   %
   plot_hrf(1);					

   setup_sliders; 		% set up the scroll bars 

   return;						% init


%--------------------------------------------------------------------------
%
function   set_cond_axes(num_rows,num_cols,axes_margin)
%
%   Define the axes for the response functions of different conditions
%
%   axes_margin: [left right bottom top], which specified in terms of 
%                  normal unit respect to the figure;
% 

  show_avg = getappdata(gcf,'ShowAverage');
  if (show_avg == 1),
     num_cols = num_cols + 1;
  end;

  %  clear up the old handles
  %
  old_hdls = getappdata(gcf,'AxesHdls');
  if ~isempty(old_hdls)
     for i=1:length(old_hdls(:))
	 if ishandle(old_hdls{i}), delete(old_hdls{i}); end
     end; 
  end;

  old_hdls = getappdata(gcf,'AxesCombineHdls');
  if ~isempty(old_hdls)
     for i=1:length(old_hdls(:))
	 if ishandle(old_hdls{i}), delete(old_hdls{i}); end
     end; 
  end;

  f_pos = get(gcf,'Position');
  axes_boundary(1) = axes_margin(1);
  axes_boundary(2) = 1 - axes_margin(2);
  axes_boundary(3) = axes_margin(3);
  axes_boundary(4) = 1 - axes_margin(4);

  %  plot data in each axis
  %
  ax_hdls = cell(num_rows,num_cols);
  ax_pos = cell(num_rows,num_cols);
  ax_combine_hdls = cell(num_rows,1);
  ax_combine_pos = cell(num_rows,1);

  plot_width2 = 0.2;

  if (show_avg == 1),
     plot_width  = (axes_boundary(2) - axes_boundary(1)) - plot_width2 - 0.01;
  else
     plot_width  = (axes_boundary(2) - axes_boundary(1));
  end

  plot_height = (axes_boundary(4) - axes_boundary(3)) / num_rows - 0.06;
  axes_min_x = axes_boundary(1);
  axes_min_y = axes_boundary(3);

  for row=1:num_rows, 

    axes_y = axes_min_y + (plot_height + 0.06) * (num_rows - row);

    %  determine the position of the figure
    %
    axes_x = axes_min_x;
    axes_pos = [axes_x, axes_y, plot_width, plot_height];
    
    ax = axes('units','normal','Position',axes_pos);
    set(ax,'units',get(gcf,'defaultaxesunits'));
    set(ax,'visible','off');
   
    ax_hdls{row,1} = ax;  
    ax_pos{row,1} = axes_pos;

    if (show_avg == 1),
       axes_x = axes_min_x + plot_width + 0.01;
       axes_pos = [axes_x, axes_y, plot_width2, plot_height];

       ax = axes('units','normal','Position',axes_pos);
       set(ax,'units',get(gcf,'defaultaxesunits'));
       set(ax,'visible','off');

       ax_hdls{row,2} = ax;  
       ax_pos{row,2} = axes_pos;
    end

    % for combine plots within each condition 
    %
    combine_axes_x = axes_min_x;
    combine_axes_y = axes_y;
    combine_axes_w = plot_width;
    combine_axes_h = plot_height;

    axes_pos = [combine_axes_x combine_axes_y combine_axes_w combine_axes_h];
    ax = axes('units','normal','Position',axes_pos);

    set(ax,'units',get(gcf,'defaultaxesunits'));
    set(ax,'visible','off');
   
    ax_combine_hdls{row} = ax;  
    ax_combine_pos{row} = axes_pos;

  end;
  
  setappdata(gcf,'AxesHdls',ax_hdls);
  setappdata(gcf,'AxesPos',ax_pos);
  setappdata(gcf,'AxesCombineHdls',ax_combine_hdls);
  setappdata(gcf,'AxesCombinePos',ax_combine_pos);

  return; 					% set_cond_axes


%--------------------------------------------------------------------------
%
function setup_sliders()
%
  %  remove the old sliders first
  %
  h = findobj(gcf,'Tag','ConditionSlider'); 
  if ~isempty(h), delete(h); end;

  %  set up sliders when needed
  %
  plot_dims = getappdata(gcf,'PlotDims');
  cond_idx = getappdata(gcf,'PlotCondIdx');

  if ( plot_dims(1) < length(cond_idx) )
     set_cond_slider;
  end;

  return; 					% setup_sliders


%--------------------------------------------------------------------------
%
function set_cond_slider()
%
   ax_pos = getappdata(gcf,'AxesPos');
   [rows cols] = size(ax_pos);

   pos = ax_pos{rows,cols};
   pos_h = ax_pos{1,cols};

   x = pos(1)+pos(3)+0.05;
   y = pos(2);
   w = 0.02;
%   h = pos(4)*rows;
   h = pos_h(2)+pos_h(4)-pos(2);

   pos = [x y w h];

   cond_idx = getappdata(gcf,'PlotCondIdx');

   max_value = length(cond_idx) - rows + 1;
   value = max_value; 

   small_advance = 1/(max_value-1);

   big_advance = rows * small_advance;
   if (big_advance > 1), big_advance = 1; end;

   if (small_advance == big_advance)
      small_advance = small_advance - 0.00001; 
   end;
   slider_step = [small_advance big_advance];

   cb_fn=['fmri_plot_hrf({''MOVE_COND_SLIDE''})'];

   h_cond_bar = uicontrol('Parent',gcf, ... 
		   'Style', 'slider', ...
		   'Units', 'normal', ...
                   'Position', pos, ...
		   'Value', value, ...
		   'SliderStep', slider_step, ...
		   'Min', 1,  ...
		   'Max', max_value, ...
		   'Tag', 'ConditionSlider', ...
		   'Callback',cb_fn);
   
   return; 						% set_cond_slicer


%--------------------------------------------------------------------------
%
function plot_hrf(start_cond)

  combine_plots = getappdata(gcf,'CombinedPlots');

  evt_onsets = getappdata(gcf,'evt_onsets');
  win_size = getappdata(gcf,'win_size');

  x1 = getappdata(gcf,'x1');
  y1 = getappdata(gcf,'y1');
  x2 = getappdata(gcf,'x2');
  y2 = getappdata(gcf,'y2');
  y22 = getappdata(gcf,'y22');

  ax_hdls = getappdata(gcf,'AxesHdls');
  ax_combine_hdls = getappdata(gcf,'AxesCombineHdls');
  show_avg = getappdata(gcf,'ShowAverage');
  condition = getappdata(gcf,'condition');
  plot_dims = getappdata(gcf,'PlotDims');
  cond_idx = getappdata(gcf,'PlotCondIdx');

  rows = plot_dims(1);
  cols = plot_dims(2);

  end_cond = start_cond+rows-1;
  if (end_cond > length(cond_idx))
    end_cond = length(cond_idx);
  end;

  cond_idx = cond_idx(start_cond:end_cond);

  for i=1:rows,
    for j=1:length(ax_hdls(i,:)),
       ax = ax_hdls{i,j};
       delete(get(ax,'Children'));
       set(ax,'Visible','off');
    end;
    ax = ax_combine_hdls{i};
    delete(get(ax,'Children'));
    set(ax,'Visible','off');
  end;

  curr_row = 1;
  num_conds = length(cond_idx);

  for i=1:rows,

     if (i > num_conds) 
        break;
     end;

     curr_cond_idx = cond_idx(i);
     curr_cond_name = condition{curr_cond_idx};

     load('rri_color_code');

     %  plot the data within the current window 
     %
     if (combine_plots),	% plot same condition data in a single axes

        axes(ax_hdls{curr_row,1});
        set(ax_hdls{curr_row,1},'Visible','off');

        axes(ax_combine_hdls{curr_row});
        set(ax_combine_hdls{curr_row},'Visible','on');

        cdata = y1;
        y_range = [min(cdata(:)), max(cdata(:))];
        x_range = [min(x1(:)), max(x1(:))];

        hold on;
        for j=1:size(cdata,1)
           h = plot(x1,cdata(j,:));
           set(h,'color',color_code(j,:));
        end
        h = plot(x1,cdata(curr_cond_idx,:));
        set(h,'color',color_code(curr_cond_idx,:));
        hold off;

        axis([x_range(1) x_range(2) y_range(1) y_range(2)]);

        onsets = [];

        for j = 1:length(evt_onsets)
           onsets = [onsets evt_onsets{j}'];
        end

        onsets2 = []; % onsets + win_size - 1;
        onsets = unique(sort([onsets(:); onsets2(:)]));
        set(gca,'XTick',onsets,'ytick',[]);

        ylabel(curr_cond_name); 

        if (i == 1)
           title('Hemodynamic response for combined conditions');
        end

        set(get(gca,'title'),'fontsize',12)

     else

        axes(ax_combine_hdls{curr_row});
        set(ax_combine_hdls{curr_row},'Visible','off');

        axes(ax_hdls{curr_row,1});
        set(ax_hdls{curr_row,1},'Visible','on');

        cdata = y1(curr_cond_idx,:);
        y_range = [min(cdata(:)), max(cdata(:))];
        x_range = [min(x1(:)), max(x1(:))];

        if y_range(1) == y_range(2)
           y_range(1) = y_range(1) - 0.00001;
           y_range(2) = y_range(2) + 0.00001;
        end

        hold on;
        h = plot(x1,cdata);
        set(h,'color',color_code(curr_cond_idx,:));
        hold off;

        axis([x_range(1) x_range(2) y_range(1) y_range(2)]);

        onsets = evt_onsets{curr_cond_idx};
        onsets2 = []; % onsets + win_size - 1;
        onsets = unique(sort([onsets(:); onsets2(:)]));
        set(gca,'XTick',onsets,'ytick',[]);

        ylabel(curr_cond_name); 

        if (i == 1)
           title('Hemodynamic response for individual condition');
        end

        set(get(gca,'title'),'fontsize',12)

     end

     %  plot the average data for the condition in the last column
     %
     if (show_avg == 1),

        avg_col = cols + 1;

        axes(ax_hdls{curr_row,avg_col});
        set(ax_hdls{curr_row,avg_col},'Visible','on');

        cdata = [y2(curr_cond_idx,:); y22(curr_cond_idx,:)];
        y_range = [min(cdata(:)), max(cdata(:))];
        x_range = [min(x2(:)), max(x2(:))];

        if y_range(1) == y_range(2)
           y_range(1) = y_range(1) - 0.00001;
           y_range(2) = y_range(2) + 0.00001;
        end

        hold on;
        plot(x2, cdata(1,:), 'b--');

        if (combine_plots)
           plot(x2, cdata(2,:), 'r:');
        end
        hold off;

        axis([x_range(1) x_range(2) y_range(1) y_range(2)]);
        set(gca,'YAxisLocation','right','XTick',[1:2:x_range(end)],'ytick',[]);

        if (i == 1)
           title('Average');
        end

        set(get(gca,'title'),'fontsize',12)

     end

     curr_row = curr_row+1;

  end;

  setappdata(gcf,'start_cond',start_cond);

  return; 						% plot_hrf


%--------------------------------------------------------------

function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      fmri_plot_hrf_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'fmri_plot_hrf_pos');
   catch
   end

   return;						% delete_fig

