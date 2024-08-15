function pet_plot_cond_stim_ui(action,varargin)
%
%  USAGE: pet_plot_cond_stim_ui(action,varargin)
%
%      pet_plot_cond_stim_ui('STARTUP',st_data,condition, ...
%                                          axes_margin,plot_dims,cond_idx)
%
%      pet_plot_cond_stim_ui('PLOT_STIM', start_cond, start_stim)
%      pet_plot_cond_stim_ui('SET_AXES', rows, cols, axes_margin)
%      pet_plot_cond_stim_ui('SET_COND_SLIDER')
%      pet_plot_cond_stim_ui('SET_STIM_SLIDER')
%      pet_plot_cond_stim_ui('UPDATE_DATA',st_data)
%      pet_plot_cond_stim_ui('UPDATE_COND_IDX')
%      pet_plot_cond_stim_ui('CHANGE_PLOT_DIMS')
%      pet_plot_cond_stim_ui('COMBINE_PLOTS')
%      pet_plot_cond_stim_ui('NORMALIZE_PLOTS')
%      pet_plot_cond_stim_ui('TOGGLE_SHOW_AVERAGE')
%      pet_plot_cond_stim_ui('MOVE_COND_SLIDE')
%      pet_plot_cond_stim_ui('MOVE_STIM_SLIDE')
%

%  Application Data: 
%	ST_data, ST_condition
%	PlotDims, PlotCondIdx, PlotStimCnts
%	AxesMargin, AxesHdls, AxesPos
%	FirstCondition, FirstStimulus
%

  if strcmp(action, 'STARTUP')
      init(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5});
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
      set_cond_axes(plot_dims(1),plot_dims(2),axes_margin);     % set up axes
      set_stim_slider_pos;
      plot_stims(start_cond,start_stim);
      
  elseif strcmp(action,'CHANGE_PLOT_DIMS')
      h = gcf;
      old_dims = getappdata(gcf,'PlotDims');
      if isempty(old_dims), 
         def = {'1','1'};
      else
         def = {num2str(old_dims(1)), num2str(old_dims(2))};
      end;

      prompt  = {'Number of Rows:','Number of Columns:'};
      title   = 'Change Plot Dimension';
      lines= 1;
      row_col  = inputdlg(prompt,title,lines,def);

      if isempty(row_col), return; end;
      new_dims = [str2num(row_col{1}) str2num(row_col{2})];
      % if (new_dims(2) < 2), new_dims(2) = 2; end;

      setappdata(h,'PlotDims',new_dims);

      axes_margin = getappdata(gcf,'AxesMargin');
      set_cond_axes(new_dims(1),new_dims(2),axes_margin);     % set up axes
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
  elseif strcmp(action, 'TOGGLELEGEND')
      ToggleLegend;
  elseif strcmp(action, 'fig_bt_dn')
      fig_bt_dn;
  elseif strcmp(action, 'select_subj')
      select_subj;
  end;

  return;


%--------------------------------------------------------------------------
%
function init(st_data,condition,axes_margin,plot_dims,cond_idx)

  setappdata(gcf,'ST_data',st_data);
  setappdata(gcf,'ST_condition',condition);
  setappdata(gcf,'PlotCondIdx',cond_idx);
  setappdata(gcf,'PlotDims',plot_dims);

%  if isempty(getappdata(gcf,'CombinePlots'))
     setappdata(gcf,'CombinePlots',0);
%  end;

%  if isempty(getappdata(gcf,'ShowAverage'))
     setappdata(gcf,'ShowAverage',0);
%  end;

  % set up axes, and the values of 'AxesMargin', 'AxesHlds' and 'AxesPos'
  %

  setappdata(gcf,'AxesMargin',axes_margin);
  set_cond_axes(plot_dims(1),plot_dims(2),axes_margin);     % set up axes

%  stim_cnt_list = [];
 % for i=1:length(condition),
  %   stim_cnt_list = [stim_cnt_list condition{i}.num_stim];   
%  end;
 % setappdata(gcf,'PlotStimCnts',stim_cnt_list);

  % plot the data and set the values of 'FirstCondition' and 'FirstStimulus'
  %
  plot_stims(1,1);					

  setup_sliders; 		% set up the scroll bars 

  return;						% init


%--------------------------------------------------------------------------
%
function plot_stims(start_cond,start_stim)

   try
      txtbox_hdl = getappdata(gcf,'txtbox_hdl');
      delete(txtbox_hdl);				% clear rri_txtbox
   catch
   end

  %  load the information using getappdata
  %
  ax_hdls = getappdata(gcf,'AxesHdls');
  st_data = getappdata(gcf,'ST_data');
  condition = getappdata(gcf,'ST_condition');
  plot_dims = getappdata(gcf,'PlotDims');
  cond_idx1 = getappdata(gcf,'PlotCondIdx');
  curr_fig = gcf;

  rows = plot_dims(1);
  cols = plot_dims(2);

  end_cond = start_cond+rows-1;
  if (end_cond > length(cond_idx1))
    end_cond = length(cond_idx1);
  end;

  cond_idx = cond_idx1(start_cond:end_cond);
   
  for i=1:rows,
    for j=1:length(ax_hdls(i,:)),
       ax = ax_hdls{i,j};
       delete(get(ax,'Children'));
       set(ax,'Visible','off');
    end;
  end;

  end_stim = start_stim + cols - 1;

  curr_row = 1;

  cond_name = condition.cond_name;
  subj_name = condition.subj_name;

  plotmarkercolour=[
    'bo';'rd';'g<';'m>';'bs';'rv';'g^';'mp';'bh';'rx';'g+';'m*';
    'ro';'gd';'m<';'b>';'rs';'gv';'m^';'bp';'rh';'gx';'m+';'b*';
    'go';'md';'b<';'r>';'gs';'mv';'b^';'rp';'gh';'mx';'b+';'r*';
    'mo';'bd';'r<';'g>';'ms';'bv';'r^';'gp';'mh';'bx';'r+';'g*'];

  if length([condition.subj_name{:}])>length(plotmarkercolour)  % need more color

     tmp = [];

     for i=1:ceil( length([condition.subj_name{:}])/length(plotmarkercolour) )
        tmp = [tmp; plotmarkercolour];
     end

     plotmarkercolour = tmp;

  end

  linc_wave = st_data.linc_wave;
  brain_wave = st_data.brain_wave;
  behav_wave = st_data.behav_wave;
  behavname = st_data.behavname;
  strong_r = st_data.strong_r;

  brainscores = getappdata(gcf, 'brainscores');
  behavdata = getappdata(gcf, 'behavdata');
%  min_x = min(behavdata(:));		max_x = max(behavdata(:));
  min_y = min(brainscores(:));		max_y = max(brainscores(:));
%  margin_x = abs((max_x - min_x) / 20);
  margin_y = abs((max_y - min_y) / 20);

  numbehav = size(behav_wave, 2);
  num_conds = size(behav_wave, 3);

  brain_state = getappdata(gcf,'PlotBrainState');  

  if(brain_state)				%  plot brain scores

     err_ax = getappdata(gcf,'ErrHdls');
     set(err_ax,'visible','off');

     for i = 1:rows

        if (i > num_conds) 
           break;
        end;

        if (end_stim > numbehav)
           end_stim = numbehav;
        end;

        curr_col = 1;

        numsubj = length(condition.subj_name{cond_idx(i)});
        subj_name = condition.subj_name{cond_idx(i)};

        for j=start_stim:end_stim,

           axes(ax_hdls{curr_row,curr_col});
           set(ax_hdls{curr_row,curr_col},'Visible','on');
           set(ax_hdls{curr_row,curr_col}, ...
		'buttondown','ssb_pet_plot_cond_stim_ui(''fig_bt_dn'');');
     
           if (start_stim <= numbehav)

              cla;grid off;box off;hold on;

              plot(behav_wave(1:numsubj,j,cond_idx(i)), linc_wave(1:numsubj,j,cond_idx(i)));

              for n=1:length(subj_name)

                 score_hdl(i,j,n) = plot(behav_wave(n,j,cond_idx(i)), ...
			brain_wave(n,1,cond_idx(i)),plotmarkercolour(n,:), ...
			'MarkerSize',10, 'userdata', [n cond_idx(i)], 'buttondown', ...
			'ssb_pet_plot_cond_stim_ui(''select_subj'');');

              end

              per_behav = behav_wave(1:numsubj,j,:);
              min_x = min(per_behav(:));		max_x = max(per_behav(:));
              margin_x = abs((max_x - min_x) / 20);

              axis([min_x-margin_x,max_x+margin_x, ...
		    min_y-margin_y,max_y+margin_y]);
              % axis([0 st_win_size-1 y_range(1) y_range(2)]);
              % set(gca,'XTick',[1:2:x_range(end)]);
           end;		% enf if
     
           if (curr_col == 1), 
%               ylabel(sprintf('Cond. #%d',cond_idx(i))); 
		ylabel(cond_name{cond_idx(i)});
           else
               % set(gca,'YTickLabel',{}); 
           end;
   
           if (i == length(cond_idx)),
%               xlabel(sprintf('Behav. #%d',j));
		xlabel(behavname{j});
           else
               % set(gca,'XTickLabel',{});
           end;

           if (curr_col == 1) & (i == 1)
               % [l_hdl o_hdl] = legend(subj_name);
               % legend_txt(o_hdl);
           end

           LV = num2str(find(getappdata(gcf, 'CurrLVState')));

           title(['LV=',LV,',  r=',num2str(strong_r(1,j,cond_idx(i)),2)]);
           get(gca,'xlabel');


if(0)
           txtbox(i,j)=rri_txtbox(gca, 'LV', LV, ...
		'r', num2str(strong_r(1,j,cond_idx(i)),2));

           pos_a = get(gca,'position');
           pos = get(txtbox(i,j),'position');
           pos(1) = pos_a(1) + .005;
           pos(2) = pos_a(2) + .005;
           set(txtbox(i,j),'position',pos);
           set(txtbox(i,j),'tag','tmp');
end


           curr_col = curr_col+1;
        end;	% end for j

        curr_row = curr_row+1;

     end	% enf for i

     setappdata(gcf, 'score_hdl', score_hdl);

     for i = 1:rows

        if (i > num_conds) 
           break;
        end;

        if (end_stim > numbehav)
           end_stim = numbehav;
        end;

if(0)
        for j=start_stim:end_stim,
           set(txtbox(i,j),'tag','rri_txtbox');
        end
end

     end

     % remove the old legend to avoid the bug in the MATLAB5
     old_legend = getappdata(gcf,'LegendHdl');
     if ~isempty(old_legend),
       try
         delete(old_legend{1});
       catch
       end;
     end;

     % create a new legend, and save the handles
%     [l_hdl, o_hdl] = legend(subj_name, 'Location', 'northeast');
 %    legend_txt(o_hdl);
  %   set(l_hdl,'color',[0.9 1 0.9]);
%     setappdata(gcf,'LegendHdl',[{l_hdl} {o_hdl}]);
     setappdata(gcf,'LegendHdl',[]);
%     setappdata(gcf,'txtbox',txtbox);

%     legend_state = get(findobj(gcf,'Tag','LegendMenu'),'Userdata');
 %    if (legend_state == 1),
  %      DisplayLegend('on');
   %  else
    %    DisplayLegend('off');
     %end;

     setappdata(gcf,'FirstCondition',start_cond);
     setappdata(gcf,'FirstStimulus',start_stim);

  else						%  plot errorbar

     mask = [];

     for i=1:numbehav
        for j=1:num_conds
           mask = [mask (j-1)*numbehav+i];
        end
     end

     orig_corr = st_data.orig_corr;

     if isempty(st_data.ulcorr)
        llcorr = st_data.llcorr - st_data.orig_corr;
        ulcorr = [];
     else
        llcorr = st_data.llcorr - st_data.orig_corr;
        ulcorr = st_data.ulcorr - st_data.orig_corr;
     end

     ax_hdls = getappdata(gcf,'AxesHdls');
     [r c] = size(ax_hdls);

     for i = 1:r
        for j = 1:c
           set(ax_hdls{i,j},'Visible','off');
        end
     end

     txtbox = getappdata(gcf,'txtbox');
     [r c] = size(txtbox);

     for i = 1:r
        for j = 1:c
           try
             delete(txtbox(i,j));
           catch
           end;
        end
     end

     old_legend = getappdata(gcf,'LegendHdl');
     if ~isempty(old_legend),
       try
         delete(old_legend{1});
       catch
       end;
     end;

     err_ax = getappdata(gcf,'ErrHdls');
     set(err_ax,'visible','on');

     cla;grid on;box on;hold on;

%     h1 = bar(orig_corr(mask));
%     set(h1, 'facecolor', 'none');

     load('rri_color_code');

     for i=1:numbehav
        for j=1:num_conds
           k = (i-1)*num_conds + j;
           bar_hdl = bar(k, orig_corr(mask(k)));
           set(bar_hdl,'facecolor',color_code(j,:));
        end
     end

     if ~isempty(cond_name),

        % remove the old legend to avoid the bug in the MATLAB5
        old_legend = getappdata(gcf,'LegendHdl');
        if ~isempty(old_legend),
          try
            delete(old_legend{1});
          catch
          end;
        end;

        % create a new legend, and save the handles
        [l_hdl, o_hdl] = legend(cond_name, 'Location', 'northeast');
        legend_txt(o_hdl);
        set(l_hdl,'color',[0.9 1 0.9]);
        setappdata(gcf,'LegendHdl',[{l_hdl} {o_hdl}]);

        legend_state = get(findobj(gcf,'Tag','LegendMenu'),'Userdata');

        if (legend_state == 1),
           DisplayLegend('on');
        else
           DisplayLegend('off');
        end;

     else

        setappdata(gcf,'LegendHdl',[]);

     end;

     if ~isempty(st_data.ulcorr)
        h2=errorbar(1:length(llcorr), orig_corr(mask), abs(llcorr(mask)), ulcorr(mask), 'ok');
     end

     hold off;

     min_x = 0.5;		max_x = num_conds * numbehav + 0.5;
     min_y =-1;		max_y = 1;
     margin_x = abs((max_x - min_x) / 20);
     margin_y = abs((max_y - min_y) / 20);

     axis([min_x-margin_x,max_x+margin_x,min_y-margin_y,max_y+margin_y]);

     set(err_ax,'xtick',[0.5:num_conds:length(llcorr)]);
%     set(err_ax,'xticklabel',[1:num_conds:length(llcorr)]);
     set(err_ax,'xticklabel',behavname);

     %xlabel(sprintf('Conditions',j)); 
%     set(gca,'XTick',[1:length(llcorr)])

     %ylabel(sprintf('Correlations',cond_idx(i))); 

  end;

  figure (curr_fig);

  return; 


%---------------------------------------------------------------------------
%
function DisplayLegend(on_off)

   l_hdls = getappdata(gcf,'LegendHdl');
   txtbox = getappdata(gcf, 'txtbox');

   if ~isempty(l_hdls) & ishandle(l_hdls{1})
      set(l_hdls{1},'Visible',on_off);
      num_obj = length(l_hdls{2});
      for i=1:num_obj,
         set(l_hdls{2}(i),'Visible',on_off);
      end;
   end

   if ~isempty(txtbox) & ishandle(txtbox)
      [r c] = size(txtbox);
      for i=1:r
         for j=1:c
            set(txtbox(i,j),'visible',on_off);
            txt = get(txtbox(i,j),'child');
            for k=1:length(txt);
               set(txt(k),'visible',on_off);
            end
         end
      end
   end

   return;                                              % DisplayLegend


%---------------------------------------------------------------------------

function ToggleLegend

   h = findobj(gcf,'Tag','LegendMenu');
   l_hdls = getappdata(gcf,'LegendHdl');

   legend_state = get(h,'Userdata');
   switch (legend_state)
     case {0},
	set(h,'Userdata',1,'Label','&Hide Legend');
        DisplayLegend('on');
     case {1},
	set(h,'Userdata',0,'Label','&Show Legend');
        DisplayLegend('off');
   end;

   return;                                              % ToggleLegend


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

  %  clear up the old handles
  %
  old_hdls = getappdata(gcf,'AxesHdls');
  if ~isempty(old_hdls)
     for i=1:length(old_hdls(:))
	 if ishandle(old_hdls{i}), delete(old_hdls{i}); end
     end; 
  end;

  % also clear up other axes handle, if available
  err_ax = getappdata(gcf,'ErrHdls');
  if ~isempty(err_ax)
     delete(err_ax);
  end

  f_pos = get(gcf,'Position');
  axes_boundary(1) = axes_margin(1);
  axes_boundary(2) = 1 - axes_margin(2);
  axes_boundary(3) = axes_margin(3);
  axes_boundary(4) = 1 - axes_margin(4);

  %  plot data in each axis
  %
  ax_hdls = cell(num_rows,num_cols);
  ax_pos = cell(num_rows,num_cols);

  plot_width  = (axes_boundary(2) - axes_boundary(1)) / num_cols;
  plot_height = (axes_boundary(4) - axes_boundary(3) + 0.03) / num_rows;
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
      
      axes_pos = [axes_x  axes_y plot_width-0.09 plot_height-0.09];
    
      ax = axes('units','normal','Position',axes_pos);
      set(ax,'units',get(gcf,'defaultaxesunits'));
      set(ax,'visible','off');
   
      ax_hdls{row,col} = ax;  
      ax_pos{row,col} = axes_pos;
    end,
  end;

  err_ax_pos = [axes_min_x, axes_min_y-0.04, ...
	 axes_boundary(2)-axes_boundary(1), ...
	 axes_boundary(4)-axes_boundary(3)+0.02];
  err_ax = axes('units','normal','Position',err_ax_pos);
  set(err_ax,'visible','off');

  setappdata(gcf,'ErrHdls',err_ax);  
  setappdata(gcf,'AxesHdls',ax_hdls);
  setappdata(gcf,'AxesPos',ax_pos);


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

  %  return if draw error bar
  %
  error_state = getappdata(gcf,'PlotErrorState');
  if error_state, return; end;

  %  set up sliders when needed
  %
  plot_dims = getappdata(gcf,'PlotDims');
  cond_idx = getappdata(gcf,'PlotCondIdx');
  behavdata = getappdata(gcf,'behavdata');

  if ( plot_dims(1) < length(cond_idx) )
     set_cond_slider;
  end;

  if ( (plot_dims(2)) < size(behavdata,2) )
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

   x = pos(1)+pos(3)+0.03;
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

   cb_fn=['ssb_pet_plot_cond_stim_ui(''MOVE_COND_SLIDE'')'];

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
   ax_pos = getappdata(gcf,'AxesPos');
   [rows cols] = size(ax_pos);
 
   pos = ax_pos{rows,1};   	% [x y width height]
   pos_w = ax_pos{rows,cols};   	% [x y width height]

   x = pos(1);
   y = pos(2)-0.1;
%   w = pos(3)*cols;
   w = pos_w(1)+pos_w(3)-pos(1);
   h = 0.03;

   pos = [x y w h];

   behavdata = getappdata(gcf,'behavdata');

   max_value = size(behavdata,2) - cols + 1; 
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

   cb_fn=['ssb_pet_plot_cond_stim_ui(''MOVE_STIM_SLIDE'')'];

   h_stim_bar = uicontrol('Parent',gcf, ... 
		   'Style', 'slider', ...
		   'Units', 'normal', ...
                   'Position', pos, ...
		   'Value', value, ...
		   'SliderStep', slider_step, ...
		   'Min', 1,  ...
		   'Max', max_value, ...
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


%-----------------------------------------------------------
%
function fig_bt_dn()

   score_hdl = getappdata(gcf,'score_hdl');

   for i=1:length(score_hdl(:))
      set(score_hdl(i), 'selected', 'off');		% remove selection
   end

   try
      txtbox_hdl = getappdata(gcf,'txtbox_hdl');
      delete(txtbox_hdl);				% clear rri_txtbox
   catch
   end

   return;						% fig_bt_dn


%-----------------------------------------------------------
%
function select_subj

   % don't do anything if we're supposed to be zooming
   tmp = zoom(gcf,'getmode');
   if (isequal(tmp,'in') | isequal(tmp,'on')), return; end

   score_hdl = getappdata(gcf,'score_hdl');

   start_cond = getappdata(gcf,'FirstCondition');
   start_stim = getappdata(gcf,'FirstStimulus');


  %  load the information using getappdata
  %
  ax_hdls = getappdata(gcf,'AxesHdls');
  st_data = getappdata(gcf,'ST_data');
  condition = getappdata(gcf,'ST_condition');
  plot_dims = getappdata(gcf,'PlotDims');
  cond_idx1 = getappdata(gcf,'PlotCondIdx');
  curr_fig = gcf;

  rows = plot_dims(1);
  cols = plot_dims(2);

  end_cond = start_cond+rows-1;
  if (end_cond > length(cond_idx1))
    end_cond = length(cond_idx1);
  end;

  cond_idx = cond_idx1(start_cond:end_cond);
  end_stim = start_stim + cols - 1;

  subj_name = condition.subj_name;

  behav_wave = st_data.behav_wave;
  numbehav = size(behav_wave, 2);
  num_conds = size(behav_wave, 3);

     for i = 1:rows

        if (i > num_conds) 
           break;
        end;

        if (end_stim > numbehav)
           end_stim = numbehav;
        end;

        for j=start_stim:end_stim,     
           if (start_stim <= numbehav)
              for n=1:length(subj_name{cond_idx(i)})
                 set(score_hdl(i,j,n),'selected','off');
              end
           end
        end
     end


   n = get(gco, 'userdata');
   c = n(2);
   n = n(1);
   cond_idx2 = cond_idx1(c-start_cond+1);


     for i = 1:rows

        if (i > num_conds) 
           break;
        end;

        if (end_stim > numbehav)
           end_stim = numbehav;
        end;

        for j=start_stim:end_stim,     
           if (start_stim <= numbehav)
                 set(score_hdl(cond_idx2,j,n),'selected','on');
           end
        end
     end

   txtbox_hdl = rri_txtbox(gca, 'Subject Name', subj_name{c}{n});
   setappdata(gcf, 'txtbox_hdl', txtbox_hdl);


   return;					% select_subj

