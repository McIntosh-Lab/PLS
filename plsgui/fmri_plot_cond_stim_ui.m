function fmri_plot_cond_stim_ui(action,varargin)
%
%  USAGE: fmri_plot_cond_stim_ui(action,varargin)
%
%      fmri_plot_cond_stim_ui('STARTUP',st_data,condition, ...
%                                          axes_margin,plot_dims,cond_idx)
%
%      fmri_plot_cond_stim_ui('PLOT_STIM', start_cond, start_stim)
%      fmri_plot_cond_stim_ui('SET_AXES', rows, cols, axes_margin)
%      fmri_plot_cond_stim_ui('SET_COND_SLIDER')
%      fmri_plot_cond_stim_ui('SET_STIM_SLIDER')
%      fmri_plot_cond_stim_ui('UPDATE_DATA',st_data)
%      fmri_plot_cond_stim_ui('UPDATE_COND_IDX')
%      fmri_plot_cond_stim_ui('CHANGE_PLOT_DIMS')
%      fmri_plot_cond_stim_ui('COMBINE_PLOTS')
%      fmri_plot_cond_stim_ui('NORMALIZE_PLOTS')
%      fmri_plot_cond_stim_ui('TOGGLE_SHOW_AVERAGE')
%      fmri_plot_cond_stim_ui('MOVE_COND_SLIDE')
%      fmri_plot_cond_stim_ui('MOVE_STIM_SLIDE')
%

%  Application Data: 
%	ST_data, ST_condition
%	PlotDims, PlotCondIdx, PlotStimCnts
%	AxesMargin, AxesHdls, AxesPos
%	FirstCondition, FirstStimulus
%

  if strcmp(action, 'STARTUP')
      if nargin > 6
         init(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5}, ...
		varargin{6},varargin{7},varargin{8});
      else
         init(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},[],[],[]);
      end;
  elseif strcmp(action, 'PLOT_STIM')
      start_cond = varargin{1};
      start_stim = varargin{2};
      plot_stims(start_cond,start_stim);
  elseif strcmp(action, 'SET_AXES')
      num_rows = varargin{1};
      num_cols = varargin{2};

      axes_margin = varargin{3};
      set_cond_axes(num_rows,num_cols,axes_margin);
  elseif strcmp(action, 'SET_COND_SLIDER')
      set_cond_slider;
  elseif strcmp(action, 'SET_STIM_SLIDER')
      set_stim_slider;
  elseif strcmp(action, 'UPDATE_DATA')
      st_data = varargin{1};
      setappdata(gcf,'ST_data',st_data);
      h = findobj(gcf,'Tag','ConditionSlider');
      start_cond = get(h,'Max') - round(get(h,'Value')) + 1; 
      h = findobj(gcf,'Tag','StimulusSlider');
      start_stim = round(get(h,'Value')); 
      plot_stims(start_cond,start_stim);
  elseif strcmp(action,'UPDATE_COND_IDX')
      setappdata(gcf,'PlotCondIdx',varargin{1});
      plot_stims(1,1);
      setup_sliders;
  elseif strcmp(action,'COMBINE_PLOTS')
      combine_state =  varargin{1};
      combining_plots(combine_state);
  elseif strcmp(action,'TOGGLE_SHOW_AVERAGE')
      h = findobj(gcf,'Tag','ToggleShowAvgMenu');
      switch (getappdata(gcf,'ShowAverage'))
         case {0},
	     setappdata(gcf,'ShowAverage',1);
	     set(h,'Label','Hide Average Plot');
         case {1},
	     setappdata(gcf,'ShowAverage',0);
	     set(h,'Label','Show Average Plot');
      end;

      start_cond = getappdata(gcf,'FirstCondition');
      start_stim = getappdata(gcf,'FirstStimulus');
      plot_dims = getappdata(gcf,'PlotDims');

      axes_margin = getappdata(gcf,'AxesMargin');
      set_cond_axes(plot_dims(1),plot_dims(2),axes_margin); % set up axes
      set_stim_slider_pos;
      plot_stims(start_cond,start_stim);
      
  elseif strcmp(action,'CHANGE_PLOT_DIMS')
      h = gcf;
      old_dims = getappdata(gcf,'PlotDims');
      if isempty(old_dims), 
         def = {'5','4'};
      else
         def = {num2str(old_dims(1)), num2str(old_dims(2))};
      end;
      prompt  = {'Number of Rows:','Number of Columns:'};
      title   = 'Change Plot Dimension';
      lines= 1;
      row_col  = inputdlg(prompt,title,lines,def);
      if isempty(row_col), return; end;
      new_dims = [str2num(row_col{1}) str2num(row_col{2})];
      if (new_dims(2) < 2), new_dims(2) = 2; end;

      setappdata(h,'PlotDims',new_dims);

      axes_margin = getappdata(gcf,'AxesMargin');
      set_cond_axes(new_dims(1),new_dims(2),axes_margin); % set up axes
      plot_stims(1,1);
      setup_sliders;
  elseif strcmp(action, 'MOVE_COND_SLIDE')
      h = findobj(gcf,'Tag','ConditionSlider');
      start_cond = get(h,'Max') - round(get(h,'Value')) + 1; 
      if (start_cond ~= getappdata(gcf,'FirstCondition'))
         start_stim = getappdata(gcf,'FirstStimulus');
         plot_stims(start_cond,start_stim);
      end;
  elseif strcmp(action, 'MOVE_STIM_SLIDE')
      h = findobj(gcf,'Tag','StimulusSlider');
      start_stim = round(get(h,'Value')); 
      if (start_stim ~= getappdata(gcf,'FirstStimulus'))
          start_cond = getappdata(gcf,'FirstCondition');
          plot_stims(start_cond,start_stim);
      end;
  elseif strcmp(action, 'RESIZE')
      resize_axes;
  end;

  return;

%--------------------------------------------------------------------------
%
function init(st_data,condition,axes_margin,plot_dims,cond_idx,bsr,bs_thresh,bs_thresh2) 

  setappdata(gcf,'bs_thresh',bs_thresh);
  setappdata(gcf,'bs_thresh2',bs_thresh2);
  setappdata(gcf,'bsr',bsr);
  setappdata(gcf,'ST_data',st_data);
  setappdata(gcf,'ST_condition',condition);
  setappdata(gcf,'PlotCondIdx',cond_idx);
  setappdata(gcf,'PlotDims',plot_dims);

  if isempty(getappdata(gcf,'CombinePlots'))
     setappdata(gcf,'CombinePlots',0);
  end;

  if isempty(getappdata(gcf,'ShowAverage'))
     setappdata(gcf,'ShowAverage',1);
  end;

  % set up axes, and the values of 'AxesMargin', 'AxesHlds' and 'AxesPos'
  %
  setappdata(gcf,'AxesMargin',axes_margin);
  set_cond_axes(plot_dims(1),plot_dims(2),axes_margin);     % set up axes

  if isempty(st_data)
     return;
  end

  stim_cnt_list = [];
  for i=1:length(condition),
     stim_cnt_list = [stim_cnt_list condition{i}.num_stim];   
  end;
  setappdata(gcf,'PlotStimCnts',stim_cnt_list);

  % plot the data and set the values of 'FirstCondition' and 'FirstStimulus'
  %
  plot_stims(1,1);					

  setup_sliders; 		% set up the scroll bars 

  return;						% init


%--------------------------------------------------------------------------
%
function plot_stims(start_cond,start_stim)

  %  load the information using getappdata
  %
  ax_hdls = getappdata(gcf,'AxesHdls');
  ax_combine_hdls = getappdata(gcf,'AxesCombineHdls');
  show_avg = getappdata(gcf,'ShowAverage');

  combine_plots = getappdata(gcf,'CombinePlots');
  bs_thresh = getappdata(gcf,'bs_thresh');
  bs_thresh2 = getappdata(gcf,'bs_thresh2');
  bsr = getappdata(gcf,'bsr');
  st_data = getappdata(gcf,'ST_data');
  st_win_size = size(st_data,2);
  condition = getappdata(gcf,'ST_condition');
  plot_dims = getappdata(gcf,'PlotDims');
  cond_idx = getappdata(gcf,'PlotCondIdx');

  ylim = [min(st_data(:)), max(st_data(:))];

  mean_st_data = ones(length(condition), st_win_size);

  for i = 1:length(condition)
     mean_st_data(i,:) = mean(st_data(condition{i}.st_row_idx,:),1);
  end

  mean_ylim = [min(mean_st_data(:)), max(mean_st_data(:))];

   bs_color_code =[
       'bo';'rd';'m<';'g>';'bs';'rv';'m^';'gp';'bh';'rx';'m+';'g*';
       'ro';'gd';'m<';'b>';'rs';'gv';'m^';'bp';'rh';'gx';'m+';'b*';
       'go';'md';'b<';'r>';'gs';'mv';'b^';'rp';'gh';'mx';'b+';'r*';
       'mo';'bd';'r<';'g>';'ms';'bv';'r^';'gp';'mh';'bx';'r+';'g*'];

  bs_y_amplitude = [max(ylim)-0.1*diff(ylim) min(ylim)+0.1*diff(ylim)];
  mean_bs_y_amplitude = ...
	[max(mean_ylim)-0.1*diff(mean_ylim) min(mean_ylim)+0.1*diff(mean_ylim)];

  bs1 = [];
  bs2 = [];
  bs3 = [];
  bs4 = [];

  rows = plot_dims(1);
  cols = plot_dims(2);

  end_cond = start_cond+rows-1;
  if (end_cond > length(cond_idx))
    end_cond = length(cond_idx);
  end;

  %  suppress average plot if all conditions have at most 1 stim
  only_one_stim = 1;
  for i=1:length(condition),
     if (condition{i}.num_stim > 1),
        only_one_stim = 0;
     end;
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

  end_stim = start_stim + cols - 1;

  curr_row = 1;
  x_range = [0:st_win_size-1];

  if ~isempty(bsr)
     lv1_x = x_range;
     lv1_x = lv1_x(find((bsr(:,1) > bs_thresh) | (bsr(:,1) < bs_thresh2)));
     lv1_y = repmat(bs_y_amplitude(1), [1, length(lv1_x)]);
     mean_lv1_y = repmat(mean_bs_y_amplitude(1), [1, length(lv1_x)]);

     if size(bsr,2)>1
        lv2_x = x_range;
        lv2_x = lv2_x(find((bsr(:,2) > bs_thresh) | (bsr(:,2) < bs_thresh2)));
        lv2_y = repmat(bs_y_amplitude(2), [1, length(lv2_x)]);
        mean_lv2_y = repmat(mean_bs_y_amplitude(2), [1, length(lv2_x)]);
     else
        lv2_x = [];
     end
  else
     lv1_x = [];
     lv2_x = [];
  end

  num_conds = length(cond_idx);
  
  for i=1:rows,

     if (i > num_conds) 
        break;
     end;

     curr_cond = condition{cond_idx(i)};

     cdata = st_data(curr_cond.st_row_idx,:);
     y_range = [min(cdata(:)), max(cdata(:))];

     if (end_stim > curr_cond.num_stim)
        end_stim = curr_cond.num_stim;
     end;

     %  plot the data within the current window 
     %
     if (combine_plots),	% plot same condition data in a single axes

        curr_col = 1;
        for j=start_stim:end_stim,
           axes(ax_hdls{curr_row,curr_col});
           set(ax_hdls{curr_row,curr_col},'Visible','off');
           curr_col = curr_col+1;
        end;

        axes(ax_combine_hdls{curr_row});
        set(ax_combine_hdls{curr_row},'Visible','on');

        j=[start_stim:end_stim];
        plot(x_range,st_data(curr_cond.st_row_idx,:)');

        hold on;
        if ~isempty(lv1_x)
           bs1(i) = plot(lv1_x, lv1_y, bs_color_code(1,:));
        end

        if ~isempty(lv2_x)
           bs2(i) = plot(lv2_x, lv2_y, bs_color_code(2,:));
        end
        hold off;

        axis([0 st_win_size-1 y_range(1) y_range(2)]);
        set(gca,'ylim',ylim);

        if (i ~= rows), 
           set(gca,'XTickLabel',{}); 
        else
           set(gca,'XTick',x_range);
        end;

%        ylabel(sprintf('Cond. #%d',cond_idx(i))); 
        ylabel(curr_cond.name); 

     else
        axes(ax_combine_hdls{curr_row});
        set(ax_combine_hdls{curr_row},'Visible','off');

        curr_col = 1;
        for j=start_stim:end_stim,
           axes(ax_hdls{curr_row,curr_col});
           set(ax_hdls{curr_row,curr_col},'Visible','on');
     
           st_row = curr_cond.st_row_idx(j);
           if (start_stim <= curr_cond.num_stim)	
              plot(x_range,st_data(st_row,:));

        hold on;
        if ~isempty(lv1_x)
           bs1(i,j) = plot(lv1_x, lv1_y, bs_color_code(1,:));
        end

        if ~isempty(lv2_x)
           bs2(i,j) = plot(lv2_x, lv2_y, bs_color_code(2,:));
        end
        hold off;

              axis([0 st_win_size-1 y_range(1) y_range(2)]);
              set(gca,'XTick',[1:2:x_range(end)]);
           end;

           set(gca,'ylim',ylim);
     
           if (curr_col == 1), 
%               ylabel(sprintf('Cond. #%d',cond_idx(i))); 
               ylabel(curr_cond.name); 
           else
               set(gca,'YTickLabel',{}); 
           end;
   
           if (i == 1), 
	      if strcmp(get(gcf,'user'),'datamatcorrs')
                 set(gca,'Title', text('String',sprintf('Behav. #%d',j),'Interpreter','none')); 
	      else
                 set(gca,'Title', text('String',sprintf('Avg. Subj. #%d',j),'Interpreter','none')); 
	      end

	      get(gca,'xlabel');
           end;
           if (i ~= length(cond_idx)), set(gca,'XTickLabel',{}); end;
   
           curr_col = curr_col+1;
        end;
     end;

     set(gca,'ylim',ylim);
  
     %  plot the average data for the condition in the last column
     %
     if (show_avg == 1),
        avg_col = cols + 1;
        axes(ax_hdls{curr_row,avg_col});

        if (only_one_stim == 0)
           set(ax_hdls{curr_row,avg_col},'Visible','on');
	   mean_cdata = mean(cdata,1);

           plot(x_range,mean_cdata,'r');

        hold on;
        if ~isempty(lv1_x)
           bs3(i) = plot(lv1_x, mean_lv1_y, bs_color_code(1,:));
        end

        if ~isempty(lv2_x)
           bs4(i) = plot(lv2_x, mean_lv2_y, bs_color_code(2,:));
        end
        hold off;

           axis([0 st_win_size-1 min(mean_cdata) max(mean_cdata)]);
           set(gca,'YAxisLocation','right','XTick',[1:2:x_range(end)]);

           if (i == 1)
		set(gca,'Title', text('String','Average','Interpreter','none'));
		get(gca,'xlabel');
	   end

           if (i ~= length(cond_idx)), set(gca,'XTickLabel',{}); end;
        else
           set(ax_hdls{curr_row,avg_col},'Visible','off');
        end;

        set(gca,'ylim',mean_ylim);
     end;

%     set(gca,'ylim',ylim);		% moved before 'show_avg' block

     curr_row = curr_row+1;
  end;

  setappdata(gcf,'FirstCondition',start_cond);
  setappdata(gcf,'FirstStimulus',start_stim);
  setappdata(gcf,'bs1',bs1);
  setappdata(gcf,'bs2',bs2);
  setappdata(gcf,'bs3',bs3);
  setappdata(gcf,'bs4',bs4);

  return; 


%--------------------------------------------------------------------------
%
function  combining_plots(combine_toggle)

  combine_plots = getappdata(gcf,'CombinePlots');
  if (combine_plots == combine_toggle)		% do nothing 
     return;
  end;

  h = findobj(gcf,'Tag','StimulusSlider');

  switch (combine_toggle),
    case 0,
        if ~isempty(h), set(h,'Visible','on');  end;
    case 1,
        if ~isempty(h), set(h,'Visible','off'); end;
  end;

  setappdata(gcf,'CombinePlots',combine_toggle);

  start_cond = getappdata(gcf,'FirstCondition');
  start_stim = getappdata(gcf,'FirstStimulus');
  plot_stims(start_cond,start_stim);

  return; 					% combine_plots


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
  if ~isempty(show_avg) & (show_avg == 1),
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

  plot_width  = (axes_boundary(2) - axes_boundary(1)) / num_cols;
  plot_height = (axes_boundary(4) - axes_boundary(3)) / num_rows;
  axes_min_x = axes_boundary(1);
  axes_min_y = axes_boundary(3);

  for row=1:num_rows, 

    axes_y = axes_min_y + plot_height*(num_rows-row); 

    % for separate plots within each condition 
    %
    for col=1:num_cols,

      %  determine the position of the figure
      %
      axes_x = axes_min_x + plot_width*(col-1); 
      
      if (col == num_cols & ~isempty(show_avg) & show_avg == 1)
         axes_pos = [axes_x+0.02 axes_y plot_width-0.01 plot_height-0.03];
      else 
         axes_pos = [axes_x      axes_y plot_width-0.01 plot_height-0.03];
      end;
    
      ax = axes('units','normal','Position',axes_pos);
      set(ax,'units',get(gcf,'defaultaxesunits'));
      set(ax,'visible','off');
   
      ax_hdls{row,col} = ax;  
      ax_pos{row,col} = axes_pos;
    end,

    % for combine plots within each condition 
    %
    combine_axes_x = axes_min_x;
    combine_axes_y = axes_y;
    if (~isempty(show_avg) & show_avg == 1)
       combine_axes_w = plot_width*(num_cols-1)-0.01;
    else
       combine_axes_w = plot_width*num_cols-0.01;
    end;
    combine_axes_h = plot_height-0.03;
    
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

  h = findobj(gcf,'Tag','StimulusSlider');
  if ~isempty(h), delete(h); end;


  %  set up sliders when needed
  %
  plot_dims = getappdata(gcf,'PlotDims');
  cond_idx = getappdata(gcf,'PlotCondIdx');
  stim_cnts = getappdata(gcf,'PlotStimCnts');

  if ( plot_dims(1) < length(cond_idx) )
     set_cond_slider;
  end;

  max_num_stim = max(stim_cnts(cond_idx));
  if ( (plot_dims(2)-1) < max_num_stim )
     set_stim_slider;
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

   cb_fn=['fmri_plot_cond_stim_ui(''MOVE_COND_SLIDE'')'];

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
function set_stim_slider()
%
   show_avg = getappdata(gcf,'ShowAverage');
   combine_plots =  getappdata(gcf,'CombinePlots');

   ax_pos = getappdata(gcf,'AxesPos');
   [rows cols] = size(ax_pos);

   if (show_avg == 1),
      cols = cols - 1; 
   end;
 
   pos = ax_pos{rows,1};   	% [x y width height]
   pos_w = ax_pos{rows,cols};   	% [x y width height]

   x = pos(1);
   y = pos(2)-0.08;
%   w = pos(3)*cols;
   w = pos_w(1)+pos_w(3)-pos(1);
   h = 0.03;

   pos = [x y w h];

   stim_cnt_list = getappdata(gcf,'PlotStimCnts');

   max_value = max(stim_cnt_list) - cols + 1; 
   value = 1;

   if (max_value < 2),
      return;
   end;

   small_advance = 1/(max_value-1);
   big_advance = cols * small_advance;
   if (big_advance > 1), big_advance = 1; end;

   if (small_advance == big_advance)
      small_advance = small_advance - 0.00001; 
   end;
   slider_step = [small_advance big_advance];

   cb_fn=['fmri_plot_cond_stim_ui(''MOVE_STIM_SLIDE'')'];
   if (combine_plots)
      visible_state = 'off';
   else
      visible_state = 'on';
   end;

   h_stim_bar = uicontrol('Parent',gcf, ... 
		   'Style', 'slider', ...
		   'Units', 'normal', ...
                   'Position', pos, ...
		   'Value', value, ...
		   'SliderStep', slider_step, ...
		   'Min', 1,  ...
		   'Max', max_value, ...
		   'Visible', visible_state, ...
		   'Tag', 'StimulusSlider', ...
		   'Callback',cb_fn);

   set(h_stim_bar,'position',pos);
   
   return; 						% set_stim_slicer
    
%--------------------------------------------------------------------------
%
function set_stim_slider_pos()
%
   hh = findobj(gcf,'Tag','StimulusSlider');
   if isempty(hh),
       return;
   end;

   show_avg = getappdata(gcf,'ShowAverage');
   combine_plots =  getappdata(gcf,'CombinePlots');

   ax_pos = getappdata(gcf,'AxesPos');
   [rows cols] = size(ax_pos);

   if (show_avg == 1),
      cols = cols - 1; 
   end;
 
   pos = ax_pos{rows,1};   	% [x y width height]
   pos_w = ax_pos{rows,cols};   	% [x y width height]

   x = pos(1);
   y = pos(2)-0.08;
%   w = pos(3)*cols;
   w = pos_w(1)+pos_w(3)-pos(1);
   h = 0.03;

   pos = [x y w h];

   set(hh, 'Position', pos);

   return; 						% set_stim_slicer_pos

