function [new_run_info, num_runs] = bfm_hrf_input_run_ui(varargin) 
% 
%  USAGE:  new_run_info = bfm_hrf_input_run_ui(run_info,num_runs,conditions) 
% 
%  bfm_hrf_input_run_ui - create input condition GUI 
%  bfm_hrf_input_run_ui('SAVE_BUTTON_PRESSED') - save session information
%  bfm_hrf_input_run_ui('CANCEL_BUTTON_PRESSED') - cancel all changes
% 

   if (nargin == 0) | ~ischar(varargin{1})
      run_info = varargin{1};
      num_runs = varargin{2};
      conditions = varargin{3};


      %  add duration
      %
      if ~isempty(run_info) & ...
	~isfield(run_info(1),'blk_length') & isfield(run_info(1),'evt_onsets')

         for i = 1:length(run_info)
            dur = run_info(i).evt_onsets;

            for j = 1:length(dur)
               dur{j}=zeros(size(dur{j}));
            end

            run_info(i).blk_length = dur;
         end

      end


      init(run_info,num_runs,conditions);
      uiwait(gcf);				% wait for user finish 

      new_run_info = getappdata(gcf,'SessionRunInfo');
      num_runs = getappdata(gcf,'TotalRuns');
      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1});

   if strcmp(action,'SELECT_DATA_FILE'),
      SelectDataFile;
   elseif strcmp(action,'EDIT_DATA_DIRECTORY');
      EditDataDirectory;	
   elseif strcmp(action,'EDIT_ONSETS'),
      EditOnsets;
   elseif strcmp(action,'EDIT_LENGTH'),
      EditLength;
   elseif strcmp(action,'EDIT_REPLICATE'),
      EditReplicate;
   elseif strcmp(action,'EDIT_NUM_SCANS'),
      EditNumScans;
   elseif strcmp(action,'EDIT_NUM_SCANS_SKIPPED'),
      EditNumScansSkipped;
   elseif strcmp(action,'MOVE_SLIDER'),
      MoveSlider;
   elseif strcmp(action,'RESIZE_FIGURE'),
      SetObjectPositions;
   elseif strcmp(action,'LOAD_TXT'),
      LoadTxt;
   elseif strcmp(action,'SAVE_TXT'),
      SaveTxt;
   elseif strcmp(action,'CLEAR_RUN'),
      ClearRunInfo;
   elseif strcmp(action,'DELETE_RUN'),
      DeleteRunInfo;
   elseif strcmp(action,'RUN_EDIT'),
      ShowRunInfo(str2num(get(findobj(gcf,'Tag','NumRunEdit'),'String')));
   elseif strcmp(action,'PREVIOUS_BUTTON_PRESSED'),
      if CheckRunInfo
         ShowRunInfo(str2num(get(findobj(gcf,'Tag','NumRunEdit'),'String')) - 1);
      end
   elseif strcmp(action,'NEXT_BUTTON_PRESSED'),
      if CheckRunInfo
         ShowRunInfo(str2num(get(findobj(gcf,'Tag','NumRunEdit'),'String')) + 1);
      end
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      setappdata(gcf,'SessionRunInfo',[]);
      uiresume(gcbf);
   elseif strcmp(action,'DONE_BUTTON_PRESSED'),
      if ~CheckRunInfo
         return;
      end

      curr_run = getappdata(gcf,'CurrRun');	% save the current run info
%      SaveRunInfo(curr_run, 'uiresume');
      SaveRunInfo(curr_run);

      if(check_run_ok)
         uiresume(gcbf);
      end
   elseif strcmp(action,'DELETE_FIG'),
      delete_fig;
   elseif strcmp(action,'PLOT_HRF'),
      plot_hrf;
   elseif strcmp(action,'PLOT_ONSET'),
      plot_onset;
   end;
   
   return;


%----------------------------------------------------------------------------
function init(run_info,num_runs,conditions),

   save_setting_status = 'on';
   bfm_input_run_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(bfm_input_run_pos) & strcmp(save_setting_status,'on')

      pos = bfm_input_run_pos;

   else

      w = 0.8;
      h = 0.8;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
   	'Units','normal', ...
        'Menubar','none', ...
        'Name','Run Information', ...
        'NumberTitle','off', ...
   	'Position', pos, ...
	'deletefcn','bfm_hrf_input_run_ui(''DELETE_FIG'');', ...
        'WindowStyle', 'normal', ...
   	'Tag','InputRunFigure', ...
   	'ToolBar','none');

   left_margin = .08;
   text_height = .05;

   x = left_margin - .02;
   y = .94;
   w = 1-2*left_margin;
   h = text_height;

   pos = [x y w h];

   fnt = 0.6;

   c = uicontrol('Parent',h0, ...		% Run Index
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontName', 'FixedWidth', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'FontAngle','italic', ...
   	'FontWeight','bold', ...
   	'HorizontalAlignment','left', ...
   	'Position', pos, ...
   	'String','Run #1', ...
   	'Tag','RunIndex');

   x = left_margin;
   y = y-.05;
   w = .25;

   pos = [x y w h];

   fnt = fnt-0.1;

   c = uicontrol('Parent',h0, ...		% Number of Scans Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Number of Scans:', ...
   	'Tag','NumScansLabel');

   x = x+w+.01+0.10;
   w = .1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of Scans Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','0', ...
   	'Callback','bfm_hrf_input_run_ui(''EDIT_NUM_SCANS'');', ...
   	'Tag','NumScansEdit');

   x = left_margin;
   y = y-.06;
   w = .35;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of scans to be skipped
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Number of scans to be skipped:', ...
        'TooltipString','The number of first few scans that have unstable magnetic signals.', ...
   	'Tag','NumScansSkippedLabel');

   x = x+w+.01;
   w = .1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number of skipped scans edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','0', ...
        'TooltipString','Enter a positive integer.', ...
   	'Callback','bfm_hrf_input_run_ui(''EDIT_NUM_SCANS_SKIPPED'');', ...
   	'Tag','NumScansSkippedEdit');

   x = x+w+.05;
   w = .3;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% (Must be the same across all runs)
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','(Same for all runs)', ...
	'visible','off',...
   	'Tag','NumScansSkippedLabel');

   x = left_margin;
   y = y-.06;
   w = .2;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Data Directory Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Data Directory:', ...
   	'Tag','DataDirectoryLabel');

   x = x+w+.01;
   w = 1-left_margin - x;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Data Directory Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position', pos, ...
        'Enable','on', ...
   	'String','', ...
   	'Callback','bfm_hrf_input_run_ui(''EDIT_DATA_DIRECTORY'');', ...
   	'Tag','DataDirectoryEdit');

   x = left_margin;
   y = y-.06;
   w = .15;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Data File Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit', 'normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Data Files:', ...
   	'Tag','DataFileLabel');

   x = x+w+.01;
   w = 1-left_margin - x -.16;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Data File Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.9 0.9 0.9], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
        'Enable','inactive', ...
   	'String','', ...
   	'Tag','DataFileEdit');

   x = x+w+.01;
   w = .15;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Data File Button
   	'Style','pushbutton', ...
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','Browse ...', ...
   	'Callback','bfm_hrf_input_run_ui(''SELECT_DATA_FILE'');', ...
   	'Tag','DataFileButton');

   x = 0;
   y = .64;
   w = 1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Block Onsets Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'FontWeight','bold', ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','Event (or Epoch) Onsets (TR)', ...
   	'Tag','BlockOnsetsLabel');

   x = left_margin;
   y = .2;
   w = 1-left_margin - x;
   h = .45;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Block Onset Frame
   	'Style','frame', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal', ...
   	'Position',pos, ...
   	'Tag','BlockOnsetFrame');

   w = .03;
   x = 1 - left_margin - w - 0.001;
   y = y + 0.001;
   h = h - 0.002;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Onset Slider
   	'Style','slider', ...
   	'Units','normal', ...
        'Min', 0, ...
        'Max', 1, ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'Position',pos, ...
   	'Callback','bfm_hrf_input_run_ui(''MOVE_SLIDER'');', ...
   	'Tag','BlockOnsetSlider');

   x = left_margin+.02;
   y = .58;
   w = 1-x*2-0.05;
   h = text_height;

   pos = [x y w h];

   t1 = uicontrol('Parent',h0, ...		% Condition Name Label
   	'Style','text', ...
   	'Units','normal', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Condition #1', ...
   	'Tag','ConditionNameLabel');

   x = left_margin+.05;
   y = y-0.05;
   w = 0.1;

   pos = [x y w h];

   t4 = uicontrol('Parent',h0, ...		% Onset Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Onsets:', ...
        'visible', 'off', ...
   	'Tag','BlockOnsetLabel');

   x = x+w+0.01;
   w = 1-x-left_margin-0.08;

   pos = [x y w h];

   t2 = uicontrol('Parent',h0, ...		% Onset Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','... onsets ...', ...
   	'Callback','bfm_hrf_input_run_ui(''EDIT_ONSETS'');', ...
   	'Tag','BlockOnsetEdit');

   x = left_margin+.05;
   y = y-0.05;
   w = 0.1;

   pos = [x y w h];

   t5 = uicontrol('Parent',h0, ...		% Length Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.7 0.7 0.7], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Duration:', ...
        'visible', 'off', ...
   	'Tag','BlockLengthLabel');

   x = x+w+0.01;
   w = 1-x-left_margin-0.08;

   pos = [x y w h];

   t3 = uicontrol('Parent',h0, ...		% Length Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','... length ...', ...
   	'Callback','bfm_hrf_input_run_ui(''EDIT_LENGTH'');', ...
   	'Tag','BlockLengthEdit');

   x = left_margin;
   y = .14;
   w = .65;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Replicate Label
   	'Style','check', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'FontWeight','normal', ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Replicate trial Information across run', ...
	'value',1, ...
   	'Callback','bfm_hrf_input_run_ui(''EDIT_REPLICATE'');', ...
   	'Tag','ReplicateLabel');

   x = 1 - left_margin - .15;
   y = .12;
   w = .1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Run Edit Label
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal',...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','Run', ...
   	'Tag','RunEditLabel');

   x = 1 - left_margin - .2;
   y = y-.05;
   w = .05;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...			% Previous 
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','<<', ...
        'Enable','off', ...
   	'Callback','bfm_hrf_input_run_ui(''PREVIOUS_BUTTON_PRESSED'');', ...
        'Tag','PREVIOUSButton');

   x = 1 - left_margin - .15;
   w = .1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Number Run Edit
   	'Style','edit', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','1',...
   	'Callback','bfm_hrf_input_run_ui(''RUN_EDIT'');', ...
   	'Tag','NumRunEdit');

   x = 1 - left_margin - .05;
   w = .05;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...			% Next 
        'Units','normal', ...
	'fontunit','normal',...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','>>', ...
        'Enable','off', ...
   	'Callback','bfm_hrf_input_run_ui(''NEXT_BUTTON_PRESSED'');', ...
        'Tag','NEXTButton');

   x = left_margin;
   w = .15;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...			% DONE
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','DONE', ...
   	'Callback','bfm_hrf_input_run_ui(''DONE_BUTTON_PRESSED'');', ...
        'Tag','DONEButton');

   x = left_margin+.2;
   w = .15;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...			% CANCEL
        'Units','normal', ...
	'fontunit','normal', ...
        'FontSize',fnt, ...
        'Position',pos, ...
        'String','CANCEL', ...
   	'Callback','bfm_hrf_input_run_ui(''CANCEL_BUTTON_PRESSED'');', ...
        'Tag','CANCELButton');

   x = .01;
   y = 0;
   w = 1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% MessageLine
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

   h_file = uimenu('Parent',h0, ...
        'Label', 'Edit', ...
        'Tag', 'EditMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Load Onsets from a text file for this run', ...
        'Callback','bfm_hrf_input_run_ui(''LOAD_TXT'');', ...
        'Tag', 'LoadTxtMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Save Onsets to a text file for this run', ...
        'Callback','bfm_hrf_input_run_ui(''SAVE_TXT'');', ...
        'Tag', 'SaveTxtMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Clear', ...
        'separator', 'on', ...
        'Callback','bfm_hrf_input_run_ui(''CLEAR_RUN'');', ...
        'Tag', 'ClearRunsMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Delete', ...
        'Enable', 'on', ...
        'Callback','bfm_hrf_input_run_ui(''DELETE_RUN'');', ...
        'Tag', 'DeleteRunsMenu');

   h_file = uimenu('Parent',h0, ...
        'Label', 'Plot', ...
	'visible','off',...
        'Tag', 'PlotMenu');
   m1 = uimenu(h_file, ...
        'Label', 'HRF Plots in time points', ...
        'Callback','bfm_hrf_input_run_ui(''PLOT_HRF'');', ...
        'Tag', 'PlotHRFMenu');
   m1 = uimenu(h_file, ...
        'Label', 'Onset Timing Plot in seconds', ...
        'Callback','bfm_hrf_input_run_ui(''PLOT_ONSET'');', ...
	'visible','off',...
        'Tag', 'PlotOnsetMenu');

   %  set up the data directory 
   %
   curr = pwd;
   if isempty(curr)
      curr = filesep;
   end

   setappdata(gcf,'DataDirectory',curr);
  
   onset_template = copyobj_legacy([t1 t2 t3 t4 t5],h0);
   set(onset_template(1),'Tag','ConditionNameLabelTemplate','Visible','off');
   set(onset_template(2),'Tag','BlockOnsetEditTemplate','Visible','off');
   set(onset_template(3),'Tag','BlockLengthEditTemplate','Visible','off');
   set(onset_template(2),'Tag','BlockOnsetLabelTemplate','Visible','off');
   set(onset_template(3),'Tag','BlockLengthLabelTemplate','Visible','off');

   setappdata(gcf,'OnsetRowHeight',.18);
   setappdata(gcf,'Onset_hlist',[t1 t2 t3 t4 t5]);
   setappdata(gcf,'OnsetTemplate',onset_template);
   setappdata(gcf,'TopOnsetIdx',1);

   LoadSessionInfo(run_info,num_runs,conditions); 
   SetupBlockOnsetRows;
   DisplayBlockOnsets;
   SetupSlider;

   return;						% init


% --------------------------------------------------------------------
function  SetupBlockOnsetRows()

   onset_hdls = getappdata(gcf,'Onset_hlist');
   onset_template = getappdata(gcf,'OnsetTemplate');

   row_height = getappdata(gcf,'OnsetRowHeight');
   frame_pos = get(findobj(gcf,'Tag','BlockOnsetFrame'),'Position');
   clabel_pos = get(findobj(gcf,'Tag','ConditionNameLabel'),'Position');

   top_frame_pos = frame_pos(2) + frame_pos(4);
   margin = top_frame_pos - (clabel_pos(2) + clabel_pos(4));
   rows = floor((frame_pos(4) - margin*2) / row_height);

   v_pos = (top_frame_pos - margin) - [1:rows]*row_height;

   nr = size(onset_hdls,1);
   if (rows < nr)				% too many rows
      for i=rows+1:nr,
         delete(onset_hdls(i,:));
      end;
      onset_hdls = onset_hdls(1:rows,:);
   else						% add more rows
      for i=nr+1:rows,
        new_s_hdls = copyobj_legacy(onset_template,gcf);
        onset_hdls = [onset_hdls; new_s_hdls'];
      end;
   end;

   first_onset_pos = get(onset_hdls(1,3),'Position'); 
   width = first_onset_pos(3);

   v = 'on';
   for i=1:rows,

      %  Condition Label
      new_s_hdls = onset_hdls(i,:);
      pos = get(new_s_hdls(1),'Position'); pos(2) = v_pos(i)+0.11;
      set(new_s_hdls(1),'String','','Position',pos,'Visible',v,'UserData',i);

      %  Onset Label
      pos = get(new_s_hdls(4),'Position');
      pos(2) = v_pos(i)+0.06;
      set(new_s_hdls(4),'Position',pos,'Visible',v,'UserData',i);

      %  Onsets 
      pos = get(new_s_hdls(2),'Position');
      pos(2) = v_pos(i)+0.06;  pos(3) = width;
      set(new_s_hdls(2),'String','','Position',pos,'Visible',v,'UserData',i);

      %  Length Label
      pos = get(new_s_hdls(5),'Position');
      pos(2) = v_pos(i);
      set(new_s_hdls(5),'Position',pos,'Visible',v,'UserData',i);

      %  Length
      pos = get(new_s_hdls(3),'Position');
      pos(2) = v_pos(i);  pos(3) = width;
      set(new_s_hdls(3),'String','','Position',pos,'Visible',v,'UserData',i);

   end;

   setappdata(gcf,'Onset_hlist',onset_hdls);
   setappdata(gcf,'NumOnsetRows',rows);

   return;						% SetupBlockOnsetRows


% --------------------------------------------------------------------
function  DisplayBlockOnsets()

   cond = getappdata(gcf,'SessionConditions');
   curr_onsets = getappdata(gcf,'CurrOnsets');
   curr_length = getappdata(gcf,'CurrLength');
   top_onset_idx = getappdata(gcf,'TopOnsetIdx');
   onset_hdls = getappdata(gcf,'Onset_hlist');
   rows = getappdata(gcf,'NumOnsetRows');

   num_onsets = length(cond);

   onset_idx = top_onset_idx;
   for i=1:rows,
       o_hdls = onset_hdls(i,:);
       if (onset_idx <= num_onsets),
          set(o_hdls(1),'String',cond{onset_idx},'Visible','on');

          set(o_hdls(4),'String','Onsets:','Visible','on');

          output_onset = Number2String(curr_onsets{onset_idx}); % edit
          set(o_hdls(2),'String',output_onset,'Visible','on');

          set(o_hdls(5),'String','Duration:','Visible','on');

          output_onset = Number2String(curr_length{onset_idx}); % length
          set(o_hdls(3),'String',output_onset,'Visible','on');

          onset_idx = onset_idx + 1;
       else
          set(o_hdls(1),'String','','Visible','off');
          set(o_hdls(2),'String','','Visible','off');
          set(o_hdls(3),'String','','Visible','off');
          set(o_hdls(4),'String','','Visible','off');
          set(o_hdls(5),'String','','Visible','off');
       end
   end;

   if (top_onset_idx ~= 1) | (num_onsets > rows)
      set(findobj(gcf,'Tag','BlockOnsetSlider'),'Visible','on');
   else
      set(findobj(gcf,'Tag','BlockOnsetSlider'),'Visible','off');
   end;

   return;						% DisplayBlockOnsets


% --------------------------------------------------------------------
function  LoadSessionInfo(run_info,total_runs,conditions)

   setappdata(gcf,'SessionRunInfo',run_info);

   if is_same_across_run
      set(findobj('tag','ReplicateLabel'),'value',1);

      if (length(run_info) < total_runs)
         for i=(length(run_info)+1):total_runs

            run_info(i).num_scans = '';

            if ~isempty(run_info) & isfield(run_info(1),'num_scans_skipped')
               run_info(i).num_scans_skipped = run_info(i-1).num_scans_skipped;
            else
               run_info(i).num_scans_skipped = 0;
            end

            run_info(i).data_path = [];
            run_info(i).data_files = [];
            run_info(i).file_pattern = [];

            if isfield(run_info(1), 'evt_onsets') & isfield(run_info(1), 'blk_length') ...
		& ( ~isempty(run_info(1).evt_onsets) | ~isempty(run_info(1).blk_length) )

               run_info(i).evt_onsets = run_info(1).evt_onsets;
               run_info(i).blk_length = run_info(1).blk_length;

            else

               for j=1:length(conditions)
                  run_info(i).evt_onsets{j} = [];
                  run_info(i).blk_length{j} = [];
               end

            end;

         end
      end;
   else
      set(findobj('tag','ReplicateLabel'),'value',0);

      if (length(run_info) < total_runs)
         for i=(length(run_info)+1):total_runs

            run_info(i).num_scans = '';

            if ~isempty(run_info) & isfield(run_info(1),'num_scans_skipped')
               run_info(i).num_scans_skipped = run_info(i-1).num_scans_skipped;
            else
               run_info(i).num_scans_skipped = 0;
            end

            run_info(i).data_path = [];
            run_info(i).data_files = [];
            run_info(i).file_pattern = [];

            for j=1:length(conditions)
               run_info(i).evt_onsets{j} = [];
               run_info(i).blk_length{j} = [];
            end
         end
      end

   end;

   for i=1:total_runs
      if ~isfield(run_info(i),'num_scans_skipped')
         run_info(i).num_scans_skipped = 0;
      end
   end

   setappdata(gcf,'SessionConditions',conditions);
   setappdata(gcf,'SessionRunInfo',run_info);
   setappdata(gcf,'TotalRuns',total_runs);

   LoadRunInfo(1);

   return;						% LoadSessionInfo


% --------------------------------------------------------------------
function  LoadRunInfo(run_idx)

   run_info = getappdata(gcf,'SessionRunInfo');
   total_runs = getappdata(gcf,'TotalRuns');

   if (run_idx == total_runs)
      set(findobj(gcf,'Tag','NEXTButton'),'Enable','off');
   else
      set(findobj(gcf,'Tag','NEXTButton'),'Enable','on');
   end;

   set(findobj(gcf,'Tag','RunIndex'),'String',sprintf('Run #%d',run_idx));
   if (run_idx == 1);
      set(findobj(gcf,'Tag','PREVIOUSButton'),'Enable','off');
   else
      set(findobj(gcf,'Tag','PREVIOUSButton'),'Enable','on');
   end;

   curr_num_scans = run_info(run_idx).num_scans;
   curr_num_scans_skipped = run_info(run_idx).num_scans_skipped;
   curr_data_path = run_info(run_idx).data_path;
   curr_data_files = run_info(run_idx).data_files;
   curr_file_pattern = run_info(run_idx).file_pattern;
   curr_onsets = run_info(run_idx).evt_onsets;

   if isfield(run_info(run_idx),'blk_length') & ...
         ~isempty(run_info(run_idx).blk_length)
      curr_length = run_info(run_idx).blk_length;
   else
      for i=1:length(curr_onsets)
         curr_length{i} = ones(length(curr_onsets{i}),1);
      end
   end

   if get(findobj('tag','ReplicateLabel'),'value')
      curr_onsets = run_info(1).evt_onsets;
      curr_length = run_info(1).blk_length;
   end


   % ------- set up the field values ------------------------------------
   %

   % assume the number of scans same as previous run when it is empty
   if isempty(curr_num_scans) & (run_idx > 1)   
      curr_num_scans = run_info(run_idx-1).num_scans;
   end
   set(findobj(gcf,'Tag','NumScansEdit'),'String',num2str(curr_num_scans));

   if isempty(curr_num_scans_skipped) & (run_idx > 1)   
      curr_num_scans_skipped = run_info(run_idx-1).num_scans_skipped;
   end
   set(findobj(gcf,'Tag','NumScansSkippedEdit'),'String',num2str(curr_num_scans_skipped));

   fname = [];
   for i=1:length(curr_data_files),
      fname = [fname ' ' curr_data_files{i}];
   end;

   set(findobj(gcf,'Tag','DataDirectoryEdit'),'String',curr_data_path);

   data_info = { curr_data_path, curr_data_files, curr_file_pattern };
   set(findobj(gcf,'Tag','DataFileEdit'),'String',fname, ...
                                         'Userdata',data_info);
   set(findobj(gcf,'Tag','NumRunEdit'),'String',num2str(run_idx));

   setappdata(gcf,'CurrRun',run_idx);
   setappdata(gcf,'CurrNumScans',curr_num_scans);
   setappdata(gcf,'CurrNumScansSkipped',curr_num_scans_skipped);
   setappdata(gcf,'CurrDataPath',curr_data_path);
   setappdata(gcf,'CurrDataFiles',curr_data_files);
   setappdata(gcf,'CurrDataPattern',curr_file_pattern);
   setappdata(gcf,'CurrOnsets',curr_onsets);
   setappdata(gcf,'CurrLength',curr_length);

   return;						% LoadRunInfo


% --------------------------------------------------------------------
function  is_ok = CheckRunInfo

   data_path = getappdata(gcf,'CurrDataPath');
   data_files = getappdata(gcf,'CurrDataFiles');

   if isempty(data_path) | isempty(data_files) 
      errmsg = 'ERROR: Data Directory and Data Files must be selected';
      set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
      is_ok = 0;
      return;      
   end

   is_ok = 1;

   return;						% CheckRunInfo


% --------------------------------------------------------------------
function  SaveRunInfo(run_idx, done)

   run_info = getappdata(gcf,'SessionRunInfo');

   run_info(run_idx).num_scans = getappdata(gcf,'CurrNumScans');
   run_info(run_idx).num_scans_skipped = getappdata(gcf,'CurrNumScansSkipped');
   run_info(run_idx).data_path = getappdata(gcf,'CurrDataPath');
   run_info(run_idx).data_files = getappdata(gcf,'CurrDataFiles');
   run_info(run_idx).file_pattern = getappdata(gcf,'CurrDataPattern');
   run_info(run_idx).evt_onsets = getappdata(gcf,'CurrOnsets');
   run_info(run_idx).blk_length = getappdata(gcf,'CurrLength');

   setappdata(gcf,'SessionRunInfo',run_info);

   if exist('done','var')
      uiresume(gcbf);
   end

   return;						% SaveRunInfo


%----------------------------------------------------------------------------
function SelectDataFile

   old_pointer = get(gcf,'Pointer');
   set(gcf,'Pointer','watch');

   h = findobj(gcf,'Tag','DataFileEdit');
   previous_selected_files = get(h,'Userdata');
  
   if isempty(previous_selected_files{1}),
      data_path = getappdata(gcf,'DataDirectory');
      curr_files = [];
      fpattern = getappdata(gcf,'FilterPattern');
      if isempty(fpattern), fpattern = '*.img'; end;
   else
      data_path = previous_selected_files{1};
      curr_files = previous_selected_files{2};
      fpattern = previous_selected_files{3};
      if isempty(fpattern), fpattern = '*.img'; end;
   end;


   fig_title = 'Select Data Files';
   [num_scans, selected_path, selected_files, filter_pattern] = ...
                        fmri_getfiles(fig_title,data_path,fpattern,curr_files);


   if ~isempty(selected_files),
      num_files  = length(selected_files);
      if (num_scans ~= getappdata(gcf,'CurrNumScans')),
         errmsg = 'ERROR: The # of selected scans does not match the # of scans';
         set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
      else
         img_files = [];
         for i=1:num_files,
            img_files = [img_files ' ' selected_files{i}];
         end;
         set(h,'String',img_files); 
         set(h,'Userdata',{selected_path, selected_files, filter_pattern}); 

         setappdata(gcf,'CurrDataPath', selected_path);
         setappdata(gcf,'CurrDataFiles', selected_files);
         setappdata(gcf,'CurrDataPattern', filter_pattern);

         h = findobj(gcf,'Tag','DataDirectoryEdit');
         set(h,'String',selected_path,'TooltipString',selected_path);

         data_path = fileparts(selected_path);
         setappdata(gcf,'DataDirectory',data_path);
         setappdata(gcf,'FilterPattern',filter_pattern);
      end;
   end;

   set(gcf,'Pointer',old_pointer);

   return;						% SelectDataFile



%----------------------------------------------------------------------------
function SaveButtonPressed()

   return;						% SaveButtonPressed


%----------------------------------------------------------------------------
function status = EditOnsets(h_onset)

   status = 0;

   if ~exist('h_onset', 'var')
      h_onset = gcbo;
   end

   num_scans = str2num(get(findobj(gcf,'Tag','NumScansEdit'),'String'));
   num_scans_skipped = str2num(get(findobj(gcf,'Tag','NumScansSkippedEdit'),'String'));

   if isempty(num_scans),
      errmsg = 'ERROR: Number of scans must be specified first';
      set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
      return;
   end;

   curr_run = getappdata(gcf,'CurrRun');
   curr_onsets = getappdata(gcf,'CurrOnsets');
   top_onset_idx = getappdata(gcf,'TopOnsetIdx');
   row_idx = get(h_onset,'Userdata');
   onset_idx = top_onset_idx + row_idx - 1;

   blk_onset = deblank(strjust(get(h_onset,'String'),'left'));

   % evaluate the matlab statement if the first character is '@'
   % '@@' - last matlab statement
   %
   if ~isempty(blk_onset) & (blk_onset(1) == '@')	% matlab statement
      cmd_str = blk_onset(2:end);

      if isequal(cmd_str,'@'),           % display the last matlab statement
         cmd_str = getappdata(gcf,'LastCommand');	
         set(h_onset,'String', cmd_str);			
         return;					
      else
         setappdata(gcf,'LastCommand',blk_onset);
         cmd_str = strrep(cmd_str,'{run#}',num2str(curr_run));
         cmd_str = strrep(cmd_str,'{cond#}',num2str(onset_idx));
         onset_list = eval(cmd_str,'[]')';
	 if isempty(onset_list),
            errmsg = 'ERROR: Invalid MATLAB statement to generate the onsets.';
            set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
         end;
      end;
      set(h_onset,'String', Number2String(onset_list));
   else
      onset_list = str2num(blk_onset)';
   end;

   if (length(blk_onset) > 0) & isempty(onset_list) 
      errmsg = 'ERROR: Invalid input onsets';
      set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
      return;
   end;

%   if (length(find(onset_list >= (num_scans+num_scans_skipped))) ~= 0),
 %     errmsg = ['Largest onset is ' num2str(num_scans+num_scans_skipped-1)];
  %    set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
   %   return;
   %end;

   curr_onsets{onset_idx} = onset_list;

   setappdata(gcf,'CurrOnsets',curr_onsets);

   if get(findobj('tag','ReplicateLabel'),'value')
      run_info = getappdata(gcf,'SessionRunInfo');
      SaveRunInfo(curr_run);

      for i = 1:length(run_info)
         LoadRunInfo(i);
         setappdata(gcf,'CurrOnsets',curr_onsets);
         SaveRunInfo(i);
      end

      ShowRunInfo(curr_run);
   end

   status = 1;

   return;						% EditOnsets


%----------------------------------------------------------------------------
function MoveSlider()

   slider_hdl = findobj(gcf,'Tag','BlockOnsetSlider');
   curr_value = round(get(slider_hdl,'Value'));
   total_rows = round(get(slider_hdl,'Max'));

   top_onset_idx = total_rows - curr_value + 1;

   setappdata(gcf,'TopOnsetIdx',top_onset_idx);

   DisplayBlockOnsets;

   return;                                              % MoveSlider


%----------------------------------------------------------------------------
function SetupSlider()

   top_onset_idx = getappdata(gcf,'TopOnsetIdx');
   rows = getappdata(gcf,'NumOnsetRows');

   curr_onsets = getappdata(gcf,'CurrOnsets');
   num_onset = length(curr_onsets);

   total_rows = num_onset;
   slider_hdl = findobj(gcf,'Tag','BlockOnsetSlider');

   if (total_rows > 1)           % don't need to update when no condition
      set(slider_hdl,'Min',1,'Max',total_rows, ...
                  'Value',total_rows-top_onset_idx+1, ...
                  'Sliderstep',[1/(total_rows-1)-0.00001 1/(total_rows-1)]);
   end;

   return;                                              % UpdateSlider


%----------------------------------------------------------------------------
function  ClearRunInfo()

   run_info = getappdata(gcf,'SessionRunInfo');
   conditions = getappdata(gcf,'SessionConditions');
   curr_run = getappdata(gcf,'CurrRun');
   total_runs = getappdata(gcf,'TotalRuns');

   run_info(curr_run).num_scans = [];
%   run_info(curr_run).num_scans_skipped = 0;
   run_info(curr_run).data_path = [];
   run_info(curr_run).data_files = [];
   run_info(curr_run).file_pattern = '*.img';

   for j=1:length(conditions)
      run_info(curr_run).evt_onsets{j} = [];
      run_info(curr_run).blk_length{j} = [];
   end
   
   setappdata(gcf,'SessionRunInfo',run_info);

   LoadRunInfo(curr_run);
   DisplayBlockOnsets; 

   return;                                              % ClearRunInfo


%----------------------------------------------------------------------------
function  ShowRunInfo(run_idx)

   curr_run = getappdata(gcf,'CurrRun');
   total_runs = getappdata(gcf,'TotalRuns');

   if (run_idx < 1)  | (run_idx > total_runs)
      errmsg = 'The run index is out of range';
      set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);

      set(findobj(gcf,'Tag','NumRunEdit'),'String',num2str(curr_run));
      return;
   else
      SaveRunInfo(curr_run);
   end;

   LoadRunInfo(run_idx);
   DisplayBlockOnsets; 

   return;                                              % ShowRunInfo



%----------------------------------------------------------------------------
function  DeleteRunInfo()

   run_info = getappdata(gcf,'SessionRunInfo');
   total_runs = getappdata(gcf,'TotalRuns');
   curr_run = getappdata(gcf,'CurrRun');

   if (total_runs == 1),		% it is the only run
      ClearRunInfo;
      return;
   end;

   mask = zeros(1,total_runs);
   mask(curr_run) = 1;
   run_idx = find(mask == 0);

   run_info  = run_info(run_idx);


   setappdata(gcf,'TotalRuns',total_runs-1);
   setappdata(gcf,'SessionRunInfo',run_info);

   if (curr_run == total_runs), 
      curr_run = curr_run - 1;
   end;

   LoadRunInfo(curr_run);
   DisplayBlockOnsets; 

   return;                                              % DeleteRunInfo



%----------------------------------------------------------------------------
function  EditDataDirectory

   data_dir = get(gcbo,'String');

   if (exist(data_dir,'dir') ~= 7)
      msg = 'ERROR: Invalid directory.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   elseif (strcmp(data_dir,getappdata(gcf,'CurrDataPath')) == 1)  
      return;				%directory has not been changed
   else
      % update the data directory, and clear the field of the data files 
      % after changing directory
      %
      h = findobj(gcf,'Tag','DataFileEdit');
      curr_selected_files = get(h,'Userdata');
      curr_selected_files{1} = data_dir;
      curr_selected_files{2} = [];
      set(h,'String','','Userdata',curr_selected_files);
      setappdata(gcf,'CurrDataPath',data_dir);
      setappdata(gcf,'CurrDataFiles',[]);
   end;

   return;                                              % EditDataDirectory


%----------------------------------------------------------------------------
function num_str = Number2String(numbers)

   if isempty(numbers),
      num_str = '';
      return;
   end;

   len = length(numbers);
   num = numbers(:);            % make sure it is a column vector;

   tmp_str = strjust(num2str(num),'left');
   num_str = deblank(tmp_str(1,:));
   for i=2:len,
      num_str = [num_str ' ' deblank(tmp_str(i,:))];
   end;

   return;                                              % Number2String


%----------------------------------------------------------------------------
function delete_fig

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       bfm_input_run_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'bfm_input_run_pos');
    catch
    end

   try
      plot_hrf_fig = getappdata(gcbf,'plot_hrf_fig');
      close(plot_hrf_fig);
   catch
   end

   try
      plot_onset_fig = getappdata(gcbf,'plot_onset_fig');
      close(plot_onset_fig);
   catch
   end

   return;


%----------------------------------------------------------------------------
function status = EditLength(h_onset)

   status = 0;

   if ~exist('h_onset', 'var')
      h_onset = gcbo;
   end

   num_scans = str2num(get(findobj(gcf,'Tag','NumScansEdit'),'String'));
   num_scans_skipped = str2num(get(findobj(gcf,'Tag','NumScansSkippedEdit'),'String'));

   if isempty(num_scans)
      errmsg = 'ERROR: Number of scans must be specified first';
      set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
      return;
   end;

   curr_run = getappdata(gcf,'CurrRun');
   curr_onsets = getappdata(gcf,'CurrOnsets');
   curr_length = getappdata(gcf,'CurrLength');
   top_onset_idx = getappdata(gcf,'TopOnsetIdx');
   row_idx = get(h_onset,'Userdata');
   onset_idx = top_onset_idx + row_idx - 1;
   onset_list = curr_onsets{onset_idx};

   if isempty(onset_list)
      set(h_onset,'String', '');
      length_list = [];
      errmsg = 'ERROR: Onsets must be specified first';
      set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
%      return;
   end

   blk_length = deblank(strjust(get(h_onset,'String'),'left'));

   % evaluate the matlab statement if the first character is '@'
   % '@@' - last matlab statement
   %
   if ~isempty(blk_length) & (blk_length(1) == '@')	% matlab statement
      cmd_str = blk_length(2:end);

      if isequal(cmd_str,'@'),           % display the last matlab statement
         cmd_str = getappdata(gcf,'LastCommand');	
         set(h_onset,'String', cmd_str);
         return;					
      else
         setappdata(gcf,'LastCommand',blk_length);
         cmd_str = strrep(cmd_str,'{run#}',num2str(curr_run));
         cmd_str = strrep(cmd_str,'{cond#}',num2str(onset_idx));
         length_list = eval(cmd_str,'[]')';
	 if isempty(length_list),
            errmsg = 'ERROR: Invalid MATLAB statement to generate the length.';
            set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
         end;
      end;
      set(h_onset,'String', Number2String(length_list));
   else
      length_list = str2num(blk_length)';
   end;

   if (length(blk_length) > 0) & isempty(length_list) 
      errmsg = 'ERROR: Invalid input length';
      set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
      return;
   end;

%   if (length(find(length_list >= (num_scans+num_scans_skipped))) ~= 0),
 %     errmsg = ['Largest length is ' num2str(num_scans+num_scans_skipped-1)];
  %    set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
   %   return;
   %end;

   if ~isequal(length(length_list), length(onset_list))
      if length(length_list) == 1
         length_list = repmat(length_list,[length(onset_list),1]);
         set(h_onset,'String', Number2String(length_list));
      else
         set(h_onset,'String','');
         length_list = [];
         errmsg = 'ERROR: Number of block length should match number of block onsets';
         set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
%         return;
      end
   end

   curr_length{onset_idx} = length_list;

   setappdata(gcf,'CurrLength',curr_length);

   if get(findobj('tag','ReplicateLabel'),'value')
      run_info = getappdata(gcf,'SessionRunInfo');
      SaveRunInfo(curr_run);

      for i = 1:length(run_info)
         LoadRunInfo(i);
         setappdata(gcf,'CurrLength',curr_length);
         SaveRunInfo(i);
      end

      ShowRunInfo(curr_run);
   end

   status = 1;

   return;						% EditLength


%----------------------------------------------------------------------------
function status = is_same_across_run

   status = 1;

   run_info = getappdata(gcf,'SessionRunInfo');

   for i = 2:length(run_info)
      if ~isequal(run_info(1).evt_onsets, run_info(i).evt_onsets) | ...
	 ~isequal(run_info(1).blk_length, run_info(i).blk_length)

         status = 0;
         return;

      end
   end
   
   return;						% is_same_across_run


%----------------------------------------------------------------------------
function plot_hrf

   CurrOnsets = getappdata(gcf,'CurrOnsets');
   SessionConditions = getappdata(gcf,'SessionConditions');
   NumConditions = length(SessionConditions);

   h0 = gcf;
   plot_hrf_fig_name = [];

   try
      plot_hrf_fig_name = get(getappdata(h0,'plot_hrf_fig'),'name');
   catch
   end

   if ~isempty(plot_hrf_fig_name) & ...
	strcmp(plot_hrf_fig_name,'Hemodynamic Response Function Plot')
      msg = 'ERROR: HRF Plot window has already been opened.';
      msgbox(msg,'ERROR','modal');
   else
      h01 = fmri_plot_hrf(SessionConditions, CurrOnsets);
      if ~isempty(h01)
         setappdata(h0,'plot_hrf_fig',h01);
      end
   end

   return;						% plot_hrf


%----------------------------------------------------------------------------
function EditReplicate

   replicate_status = get(findobj('tag','ReplicateLabel'),'value');

   if replicate_status
      run_info = getappdata(gcf,'SessionRunInfo');
      curr_run = getappdata(gcf,'CurrRun');

      for i = 1:length(run_info)
         LoadRunInfo(i);
         setappdata(gcf,'CurrOnsets',run_info(curr_run).evt_onsets);
         setappdata(gcf,'CurrLength',run_info(curr_run).blk_length);
         SaveRunInfo(i);
      end

      ShowRunInfo(curr_run);
   end

   return;


%----------------------------------------------------------------------------
function plot_onset

   CurrOnsets = getappdata(gcf,'CurrOnsets');
   SessionConditions = getappdata(gcf,'SessionConditions');

   h0 = gcf;
   plot_onset_fig_name = [];

   try
      plot_onset_fig_name = get(getappdata(h0,'plot_onset_fig'),'name');
   catch
   end

   if ~isempty(plot_onset_fig_name) & ...
	strcmp(plot_onset_fig_name,'Onset Timing Plot')
      msg = 'ERROR: Onset Timing Plot window has already been opened.';
      msgbox(msg,'ERROR','modal');
   else
      h01 = fmri_plot_onset(SessionConditions, CurrOnsets);
      if ~isempty(h01)
         setappdata(h0,'plot_onset_fig',h01);
      end
   end

   return;


%----------------------------------------------------------------------------
function result = check_run_ok

   result=1;

   run_info = getappdata(gcf,'SessionRunInfo');

   for i=1:length(run_info)
      curr_run = run_info(i);

%      if i~=1
 %        run_info(i).num_scans_skipped = run_info(1).num_scans_skipped;
  %    end

      if isempty(curr_run.data_path) | isempty(curr_run.data_files)
         result=0;
         errmsg = 'Data Directory and Data Files for all runs must be selected';
         set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
      end

      for j=1:length(curr_run.evt_onsets)
         if isempty(curr_run.evt_onsets{j})
            result=0;
            errmsg = 'All the Onsets field must be filled out';
            set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
         elseif isempty(curr_run.blk_length{j})
            result=0;
            errmsg = 'Duration field must be filled. Enter 0 for Event Onsets.';
            set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
         elseif ~isequal(length(curr_run.evt_onsets{j}),length(curr_run.blk_length{j}))
            result=0;
            errmsg = 'Number of onsets and length are not match';
            set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
         end
      end
   end

   %  just because we set all run to run_info(1).num_scans_skipped
   %
%   setappdata(gcf,'SessionRunInfo',run_info);

   return;


%----------------------------------------------------------------------------
function LoadTxt

   [fn, pn] = rri_selectfile('*.txt', 'Load Onsets for this run');

   if isequal(fn, 0) | isequal(pn, 0)
      return;
   end;

   onset_file = fullfile(pn, fn);

   if ~CheckRunInfo
      return;
   end

   slider_hdl = findobj(gcf,'Tag','BlockOnsetSlider');
   curr_value = round(get(slider_hdl,'Max'));

   fid = fopen(onset_file, 'rt');
   app = getappdata(gcf);
   num_onset_disp = size(app.Onset_hlist,1);
   remain_cond = length(app.SessionConditions);

   breakwhile = 0;

   while remain_cond > num_onset_disp
      set(slider_hdl,'Value',curr_value);
      MoveSlider;

      for i=1:num_onset_disp
         onset = fgetl(fid);
         set(app.Onset_hlist(i,2), 'string', onset);

         if ~EditOnsets(app.Onset_hlist(i,2))
            breakwhile = 1;
            break;
         end

         onset = fgetl(fid);
         set(app.Onset_hlist(i,3), 'string', onset);

         if ~EditLength(app.Onset_hlist(i,3))
            breakwhile = 1;
            break;
         end
      end

      if breakwhile
         break;
      end

      remain_cond = remain_cond - num_onset_disp;
      curr_value = curr_value - num_onset_disp;
   end

   if remain_cond <= num_onset_disp
      set(slider_hdl,'Value',curr_value);
      MoveSlider;

      for i=1:remain_cond
         onset = fgetl(fid);
         set(app.Onset_hlist(i,2), 'string', onset);

         if ~EditOnsets(app.Onset_hlist(i,2))
            break;
         end

         onset = fgetl(fid);
         set(app.Onset_hlist(i,3), 'string', onset);

         if ~EditLength(app.Onset_hlist(i,3))
            break;
         end
      end
   end

   fclose(fid);

   return;


%----------------------------------------------------------------------------
function SaveTxt

   [fn, pn] = rri_selectfile('*.txt', 'Save Onsets for this run');

   if isequal(fn, 0) | isequal(pn, 0)
      return;
   end;

   onset_file = fullfile(pn, fn);

   if ~CheckRunInfo
      return;
   end

   slider_hdl = findobj(gcf,'Tag','BlockOnsetSlider');
   curr_value = round(get(slider_hdl,'Max'));

   fid = fopen(onset_file, 'wt');
   app = getappdata(gcf);
   num_onset_disp = size(app.Onset_hlist,1);
   remain_cond = length(app.SessionConditions);

   breakwhile = 0;

   while remain_cond > num_onset_disp
      set(slider_hdl,'Value',curr_value);
      MoveSlider;

      for i=1:num_onset_disp
         onset = get(app.Onset_hlist(i,2), 'string');
         fprintf(fid, '%s\n', onset);
         onset = get(app.Onset_hlist(i,3), 'string');
         fprintf(fid, '%s\n', onset);
      end

      remain_cond = remain_cond - num_onset_disp;
      curr_value = curr_value - num_onset_disp;
   end

   if remain_cond <= num_onset_disp
      set(slider_hdl,'Value',curr_value);
      MoveSlider;

      for i=1:remain_cond
         onset = get(app.Onset_hlist(i,2), 'string');
         fprintf(fid, '%s\n', onset);
         onset = get(app.Onset_hlist(i,3), 'string');
         fprintf(fid, '%s\n', onset);
      end
   end

   fclose(fid);

   return;


%----------------------------------------------------------------------------
function EditNumScans()

   num_scans = str2num(get(findobj(gcf,'Tag','NumScansEdit'),'String'));

   if isempty(num_scans) | (length(num_scans) > 1),
      errmsg = 'The input of number of scans is invalid';
      set(findobj(gcf,'Tag','MessageLine'),'String',errmsg);
      set(findobj(gcf,'Tag','NumScansEdit'),'String',num2str(getappdata(gcf,'CurrNumScans')));
      return;
   end;

   setappdata(gcf,'CurrNumScans',num_scans);

   return;						% EditNumScans


%----------------------------------------------------------------------------
function EditNumScansSkipped()
   
   num_scans_skipped = str2num(get(findobj(gcf,'Tag','NumScansSkippedEdit'),'String'));

   if isempty(num_scans_skipped) | (num_scans_skipped < 0)
      msg = 'ERROR: Invalid value for the number of skipped scans.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      set(findobj(gcf,'Tag','NumScansSkippedEdit'),'String',num2str(getappdata(gcf,'CurrNumScansSkipped')));
      return;
   end;

   setappdata(gcf,'CurrNumScansSkipped',num_scans_skipped);

   return;					% EditNumScansSkipped

