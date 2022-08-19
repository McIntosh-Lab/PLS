%RRI_DESELECT_COND_UI Deselect some conditions from condition list
%
%  USAGE: cond_selection = rri_deselect_cond_ui(condition, old_cond_selection)
%

%   Called by analysis_ui
%
%   created on July 24, 2003
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cond_selection = rri_deselect_cond_ui(condition, old_cond_selection)

    if iscell(condition)
       init(condition, old_cond_selection);
       uiwait;
       cond_selection = getappdata(gcf,'cond_selection');
       close(gcf);
       return;
    end

    if strcmp(condition, 'delete_fig')
       delete_fig;
    elseif strcmp(condition, 'click_ok')
       cond_selection = getappdata(gcf,'old_cond_selection');
       cond_selection = zeros(1, length(cond_selection));
       selected_conditions = get(findobj(gcf,'tag','condition'),'value');
       cond_selection(selected_conditions) = 1;
       setappdata(gcf,'cond_selection',cond_selection);
       uiresume;
    elseif strcmp(condition, 'click_cancel')
       cond_selection = getappdata(gcf,'old_cond_selection');
       setappdata(gcf,'cond_selection',cond_selection);
       uiresume;
    end

    return;


%----------------------------------------------------------------------------

function init(condition, old_cond_selection)

    save_setting_status = 'on';
    rri_deselect_cond_pos = [];

    try
       load('pls_profile');
    catch
    end

    if ~isempty(rri_deselect_cond_pos) & strcmp(save_setting_status,'on')

       pos = rri_deselect_cond_pos;

    else

       w = 0.5;
       h = 0.7;
       x = (1-w)/2;
       y = (1-h)/2;

       pos = [x y w h];

    end

    h0 = figure('Color',[0.8 0.8 0.8], ...
	'Units','normal', ...
        'Name','Select Conditions', ...
        'MenuBar','none', ...
        'NumberTitle','off', ...
        'deletefcn','rri_deselect_cond_ui(''delete_fig'');', ...
   	'Position',pos, ...
        'WindowStyle', 'modal', ...
   	'ToolBar','none');

    x = 0.01;
    y = 0;
    w = 1;
    h = 0.06;

    pos = [x y w h];

    fnt = 0.5;

    h1 = uicontrol('Parent',h0, ...		% Message Line Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ForegroundColor',[0.8 0.0 0.0], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String','', ...
        'Tag','MessageLine');

    x = 0.2;
    y = 0.1;
    w = 0.2;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% OK
	'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','Ok', ...
        'Callback','rri_deselect_cond_ui(''click_ok'');', ...
	'Tag','click_ok');

    x = 1-0.2-w;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% CANCEL
	'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','Cancel', ...
        'Callback','rri_deselect_cond_ui(''click_cancel'');', ...
	'Tag','click_cancel');

    w = 1;
    x = 0;
    y = 0.88;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% condition label
	'Units','normal', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','normal', ...
   	'FontSize',fnt, ...
	'HorizontalAlignment','center', ...
	'ListboxTop',0, ...
	'Position',pos, ...
	'String','Highlight Conditions to Select', ...
	'Style','text');

    x = 0.08;
    y = 0.2;
    w = 1-2*x;
    h = 0.68;

    pos = [x y w h];

    h1 = uicontrol('Parent',h0, ...		% Condition Listbox
	'Style','list', ...
	'Units','normal', ...
   	'FontUnits','normal', ...
   	'FontSize',0.04, ...
	'BackgroundColor',[0.9 0.9 0.9], ...
	'Position',pos, ...
	'Max',2, ...
	'String',condition, ...
	'Value', find(old_cond_selection), ...
	'Tag','condition');

    setappdata(h0,'old_cond_selection',old_cond_selection);

    return;					% init


%----------------------------------------------------------------------------

function delete_fig

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       rri_deselect_cond_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'rri_deselect_cond_pos');
    catch
    end

    return;

