function [progress_hdl] =  rri_progress_status(varargin),
%
%   progress_hdl = rri_progress_status('Create',fig_title);
%   progress_hdl = rri_progress_status(fig_hdl,'Create',fig_title);
%
%   rri_progress_status(progress_hdl,'Update_bar',amount);
%   rri_progress_status(progress_hdl,'Show_message',message);
%   rri_progress_status(progress_hdl,'Clear_bar');
%   rri_progress_status(progress_hdl,'Clear_message');
%
%   Note: if 'fig_hdl' is specified in 'Create' operation, the figure   
%         with handle 'fig_hdl' will be converted to the progress figure;
%         otherwise, a new figure is created.
%

   %  Create a new figure for the progress figure
   %
   if ischar(varargin{1}) & strcmp(upper(varargin{1}),'CREATE') 
       fig_title = varargin{2};	
       progress_hdl = create_progress_figure([], fig_title, 0);
       return; 
   end;

   if ~ishandle(varargin{1})
       disp('ERROR: Syntax error for calling "rri_progress_status".');
       return; 
   end;

   fig_hdl = varargin{1};

   action = upper(varargin{2});
   switch upper(action)
     case {'CREATE'}		    % make 'fig_hdl' as the progress figure
        fig_title = varargin{3};

        if nargin > 3
          cancel_bn = 1;
        else
          cancel_bn = 0;
        end

        progress_hdl = create_progress_figure(fig_hdl, fig_title, cancel_bn);
     case {'UPDATE_BAR'}
        amount = varargin{3};
        progress_hdl = show_progress_bar(fig_hdl,amount);
     case {'SHOW_MESSAGE'}
        message = varargin{3};
        progress_hdl = show_progress_message(fig_hdl,message);
     case {'CLEAR_BAR'}
        progress_hdl = show_progress_bar(fig_hdl,[]);
     case {'CLEAR_MESSAGE'}
        progress_hdl = show_progress_message(fig_hdl,'');
   end;  

   return				% rri_progress_status


%-----------------------------------------------------------------------------
function fig_hdl = create_progress_figure(fig_hdl, f_name, cancel_bn),

   screen_size = get(0,'ScreenSize');
   fig_w = 0.5;
   fig_h = 0.15;

   if ~isempty(fig_hdl),
      child_hdls = get(fig_hdl,'Child');
      delete(child_hdls);
      set(fig_hdl,'Units','normal');
      fig_pos = get(fig_hdl,'Position');
      fig_pos(3) = fig_w; fig_pos(4) = fig_h;
   else
%      fig_x = (screen_size(3) - fig_w)/2;
 %     fig_y = (screen_size(4) - fig_h)/2;
      fig_x = (1 - fig_w)/2;
      fig_y = (1 - fig_h)/2;
      fig_pos = [fig_x fig_y fig_w fig_h];
      fig_hdl = figure;
   end;

   if isempty(f_name),
      f_name = 'Progress Status';
   end;

   set(fig_hdl,'ResizeFcn','');

   set(fig_hdl, ...
	'Units','normal', ...
        'Color',[0.8 0.8 0.8], ...
	'Colormap', jet, ...
	'Doublebuffer','on', ...
	'Menubar', 'none', ...
	'Resize', 'off', ...
	'ResizeFcn', '', ...
        'Position', fig_pos, ...
	'NumberTitle', 'off', ...
	'Name', f_name, ...
	'user', 0, ...
        'Tag', 'ProgressFigure');

%	'Windowstyle','modal', ...

%   ax_pos = [40 65 fig_pos(3)-100 50];
%   ax_pos = [40 65 fig_pos(3)-150 50];

   if cancel_bn
      ax_pos = [.07 .5 .67 .3];
      ax_hdl = axes('Parent',fig_hdl, ...
             'units','normal', ...
             'Position',ax_pos, ...
             'XLim',[0 1], 'YLim',[0 1], 'ZLim',[0 1], ...
             'YTick',[], 'XTick',[0:0.2:1], ...
             'XTickLabel',{'0%';'20%';'40%';'60%';'80%';'100%'});

      bn_pos = [.8 .4 .13 .4];
      cancel_bn = uicontrol('Parent',fig_hdl, ...
		'units','normal', ...
		'position',bn_pos, ...
		'visible','on', ...
		'callback', 'rri_progress_ui(''cancel_progress'');', ...
		'string','CANCEL');
   else
      ax_pos = [.07 .5 .86 .3];
      ax_hdl = axes('Parent',fig_hdl, ...
             'units','normal', ...
             'Position',ax_pos, ...
             'XLim',[0 1], 'YLim',[0 1], 'ZLim',[0 1], ...
             'YTick',[], 'XTick',[0:0.2:1], ...
             'XTickLabel',{'0%';'20%';'40%';'60%';'80%';'100%'});
   end

   rectangle('Position',[0 0 1 1],'FaceColor','none');		% bar boundary

   progress_bar = rectangle('Position',[0 0 1 1], ...		% progress bar
                            'FaceColor',[0 0 1], ...
                            'Visible', 'off');

   message_line = uicontrol('Parent',fig_hdl, ...               % Message Line
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ForegroundColor',[0.0 0.0 0.8], ...
        'FontSize',12, ...
        'HorizontalAlignment','left', ...
        'Position',[0.01 0 1 0.2], ...
        'String','', ...
        'Tag','MessageLine');
   
   setappdata(fig_hdl,'ProgressAxes',ax_hdl);
   setappdata(fig_hdl,'ProgressBar',progress_bar);
   setappdata(fig_hdl,'MessageLine',message_line);
   setappdata(fig_hdl,'ProgressStart',0);
   setappdata(fig_hdl,'ProgressScale',1);

   drawnow;
   
   return;				% create_progress_figure;


%-----------------------------------------------------------------------------
function fig_hdl = show_progress_bar(fig_hdl,amount),

   progress_axes = getappdata(fig_hdl,'ProgressAxes');
   progress_bar = getappdata(fig_hdl,'ProgressBar');
   progress_start = getappdata(fig_hdl,'ProgressStart');
   progress_scale = getappdata(fig_hdl,'ProgressScale');

   if isempty(amount),				% reset
      set(progress_bar,'Position',[0 0 1 1],'Visible','off');
      drawnow;
      return;
   end;

   curr_progress = amount*progress_scale + progress_start;

%   axes(progress_axes);
   set(progress_bar,'Position',[0 0 curr_progress 1],'Visible','on');

   drawnow;

   return;				% show_progress_bar


%-----------------------------------------------------------------------------
function fig_hdl = show_progress_message(fig_hdl,message),

   message_line = getappdata(fig_hdl,'MessageLine');
   set(message_line,'String',message);
   drawnow;

   return;				% show_progress_message

