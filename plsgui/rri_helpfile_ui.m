%RRI_HELPFILE_UI Display helpfile window
%
%   Usage: rri_helpfile_ui('help_file_name') or
%          rri_helpfile_ui('help_file_name', 'title')
%

%   I (help_file_name):  filename string, e.g. 'helpfile_main.txt'
%   I (title):	title for the helpfile window
%   O (hdl):  handle for the helpfile window 
%
%   Created on 12-NOV-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h = rri_helpfile_ui(help_file_name, title)

    h = [];				% initialize output handle

    if ~exist('title','var')
	title = 'Help File';
    end

    if ~exist('help_file_name','var')
	error('please indicate the filename of your helpfile to be displayed.');
	return;
    end

    if ischar(help_file_name)

	try
            fid = fopen(help_file_name);
            helpfile = fscanf(fid,'%c');
            fclose(fid);

            h = init(helpfile, title);
	catch
	    msg = ['Could not find file ', help_file_name];
	    error(msg);
	    return;
	end

    end

    if help_file_name			% nonzero
	go_to_page(help_file_name);	% borrow this var for action
    else
%	resize_fig;
        delete_fig
    end

    return;				%  rri_helpfile_ui


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	initialize the helpfile window
%
%	I (helpfile):	the whole helpfile matrix
%	I (title):	title for the window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h0 = init(helpfile, title)

    %%%%%%%%%%%%%%%%%%
    %
    % preparing pages
    %
    %%%%%%%%%%%%%%%%%%

    helpfile(find(helpfile == 13)) = [];	% remove carriage 0x0d
    idx_row = find(helpfile == 10);		% find linefeed 0x0a
    num_row = length(idx_row);			% number of lines in file
    tot_line = 20;				% total number of lines per page
    num_page = ceil(num_row/tot_line);		% each page contain tot_line rows
    curr_page = 1;				% display 1st page first
    text = ['Page ', num2str(curr_page), ' of ', num2str(num_page)];

    helpfile_lst = [];
    sep1 = 1;					% start row

    for i=1:num_page-1
	sep2 = idx_row(tot_line*i);			% end row
	helppage = helpfile(sep1:sep2);		% page for display
	helpfile_lst = [helpfile_lst, {helppage}];
	sep1 = sep2+1;
    end

    if length(helpfile) ~= sep1
	helpfile_lst = [helpfile_lst, {helpfile(sep1:end)}];
    end

    %%%%%%%%%%%%%%%%%%
    %
    % drawing window
    %
    %%%%%%%%%%%%%%%%%%

    line_height = 0.8/tot_line;			% height for each line in percentage

    save_setting_status = 'on';
    rri_helpfile_pos = [];

    try
       load('pls_profile');
    catch
    end

    try
       load('rri_pos_profile');
    catch
    end

    if ~isempty(rri_helpfile_pos) & strcmp(save_setting_status,'on')

       pos = rri_helpfile_pos;

    else

       w = 0.7;
       h = 0.7;
       x = (1-w)/2;
       y = (1-h)/2;

       pos = [x y w h];

    end

    h0 = figure('Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name',title, ...
        'NumberTitle','off', ...
        'Menubar', 'none', ...
        'Position', pos, ...
	'DeleteFcn','rri_helpfile_ui(0);', ...
        'ToolBar','none');

%   	'ResizeFcn','rri_helpfile_ui(0);', ...


%    h_txt0 = uicontrol(h0, 'style','text', 'back',[1 1 1], ...
%	'unit','normal', 'position',[0.05 0.15 0.9 0.8], ...
%	'fontunit','normal', 'fontsize',0.03, 'fontname','courier', ...
%	'hor','left', 'string','');

    for i = 1:tot_line

        x = 0.05;
        y = 0.15 + line_height*(i-1);
        w = 0.9;
        h = line_height;

        pos = [x y w h];

        fnt = 0.65;

        h_txt(i) = uicontrol(h0, ...
            'style','text', ...
            'back',[1 1 1], ...
            'unit','normal', ...
            'position',pos, ...
            'fontunit','normal', ...
            'fontsize',fnt, ...
            'fontname','courier', ...
            'hor','left', ...
            'string','');

    end

    y = 0.05;
    w = 0.1;
    h = 0.05;

    pos = [x y w h];

    fnt = 0.5;

    h_leftleft = uicontrol(h0, ...
	'unit','normal', ...
	'back',[0.7 0.7 0.7], ...
	'position',pos, ...
	'string','<<', ...
	'fontweight', 'bold',...
        'fontunit','normal', ...
	'fontsize',fnt, ...
	'fontname','courier', ...
	'callback','rri_helpfile_ui(-2);', ...
	'enable', 'off');

    x = 0.15;

    pos = [x y w h];

    h_left = uicontrol(h0, ...
	'unit','normal', ...
	'back',[0.7 0.7 0.7], ...
	'position',pos, ...
	'string','<', ...
	'fontweight', 'bold',...
        'fontunit','normal', ...
	'fontsize',fnt, ...
	'fontname','courier', ...
	'callback','rri_helpfile_ui(-1);', ...
	'enable', 'off');

    x = 0.75;

    pos = [x y w h];

    h_right = uicontrol(h0, ...
	'unit','normal', ...
	'back',[0.7 0.7 0.7], ...
	'position',pos, ...
	'string','>', ...
	'fontweight', 'bold',...
        'fontunit','normal', ...
	'fontsize',fnt, ...
	'fontname','courier', ...
	'callback','rri_helpfile_ui(1);', ...
	'enable', 'off');

    x = 0.85;

    pos = [x y w h];

    h_rightright = uicontrol(h0, ...
	'unit','normal', ...
	'back',[0.7 0.7 0.7], ...
	'position',pos, ...
	'string','>>', ...
	'fontweight', 'bold',...
        'fontunit','normal', ...
	'fontsize',fnt, ...
	'fontname','courier', ...
	'callback','rri_helpfile_ui(2);', ...
	'enable', 'off');


    x = 0.3;
    y = 0.04;
    w = 0.4;

    pos = [x y w h];

    h_mid = uicontrol(h0, ...
	'style','text', ...
	'back',[0.8 0.8 0.8], ...
	'unit','normal', ...
	'position',pos, ...
        'fontunit','normal', ...
	'fontsize',fnt, ...
	'fontname','courier', ...
	'buttondown','close(gcf);', ...
	'enable','inactive', ...
        'tooltipstring','Close Help Window', ...
	'string',text);

    setappdata(h0, 'num_page', num_page);
    setappdata(h0, 'tot_line', tot_line);
    setappdata(h0, 'helpfile_lst', helpfile_lst);
    setappdata(h0, 'h_txt', h_txt);
    setappdata(h0, 'h_leftleft', h_leftleft);
    setappdata(h0, 'h_left', h_left);
    setappdata(h0, 'h_right', h_right);
    setappdata(h0, 'h_rightright', h_rightright);
    setappdata(h0, 'h_mid', h_mid);
    setappdata(h0, 'curr_page', curr_page);

%    set(h_txt0, 'string', helpfile_lst{curr_page});

    helppage = helpfile_lst{curr_page};		% display 1st page

    idx_row = find(helppage == 10);		% find linefeed 0x0a
    num_row = length(idx_row);			% lines per page
    sep1 = 1;					% start row

    for i=1:num_row
	sep2 = idx_row(i);			% end row
	row = helppage(sep1:sep2);		% row for display
	set(h_txt(tot_line-i+1), 'string', row);
	sep1 = sep2+1;
    end

    if num_page>1
        set(h_right, 'enable', 'on');
        set(h_rightright, 'enable', 'on');
    end

    return;					% init


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	direct to different helpfile page
%
%	I (direction):	direction to search the help file
%
%		-2:	go to beginning page
%		-1:	go to previous page
%		1:	go to next page
%		2:	go to ending page
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function go_to_page(direction)

    num_page = getappdata(gcf, 'num_page');
    tot_line = getappdata(gcf, 'tot_line');
    helpfile_lst = getappdata(gcf, 'helpfile_lst');
    h_txt = getappdata(gcf, 'h_txt');
    h_leftleft = getappdata(gcf, 'h_leftleft');
    h_left = getappdata(gcf, 'h_left');
    h_right = getappdata(gcf, 'h_right');
    h_rightright = getappdata(gcf, 'h_rightright');
    h_mid = getappdata(gcf, 'h_mid');
    curr_page = getappdata(gcf, 'curr_page');

    switch direction
	case {-2}
	    curr_page = 1;

	    helppage = helpfile_lst{curr_page};

	    idx_row = find(helppage == 10);		% find linefeed 0x0a
	    num_row = length(idx_row);			% lines per page
	    sep1 = 1;					% start row

	    for i=1:num_row
		sep2 = idx_row(i);			% end row
		row = helppage(sep1:sep2);		% row for display
		set(h_txt(tot_line-i+1), 'string', row);
		sep1 = sep2+1;
	    end

	    if num_row ~= tot_line
		for i=num_row+1:tot_line
		    set(h_txt(tot_line-i+1), 'string', '');	% rm junk
		end
	    end

	    text = ['Page ', num2str(curr_page), ' of ', num2str(num_page)];
%    	    set(h_txt, 'string', helpfile_lst{curr_page});
            set(h_leftleft, 'enable', 'off');
            set(h_left, 'enable', 'off');
            set(h_right, 'enable', 'on');
            set(h_rightright, 'enable', 'on');
	    set(h_mid, 'string', text);
	case {-1}
	    curr_page = curr_page - 1;

	    helppage = helpfile_lst{curr_page};

	    idx_row = find(helppage == 10);		% find linefeed 0x0a
	    num_row = length(idx_row);			% lines per page
	    sep1 = 1;					% start row

	    for i=1:num_row
		sep2 = idx_row(i);			% end row
		row = helppage(sep1:sep2);		% row for display
		set(h_txt(tot_line-i+1), 'string', row);
		sep1 = sep2+1;
	    end

	    if num_row ~= tot_line
		for i=num_row+1:tot_line
		    set(h_txt(tot_line-i+1), 'string', '');	% rm junk
		end
	    end

	    text = ['Page ', num2str(curr_page), ' of ', num2str(num_page)];
%    	    set(h_txt, 'string', helpfile_lst{curr_page});
	    if curr_page == 1
                set(h_leftleft, 'enable', 'off');
                set(h_left, 'enable', 'off');
	    end
            set(h_right, 'enable', 'on');
            set(h_rightright, 'enable', 'on');
	    set(h_mid, 'string', text);
	case {1}
	    curr_page = curr_page + 1;

	    helppage = helpfile_lst{curr_page};

	    idx_row = find(helppage == 10);		% find linefeed 0x0a
	    num_row = length(idx_row);			% lines per page
	    sep1 = 1;					% start row

	    for i=1:num_row
		sep2 = idx_row(i);			% end row
		row = helppage(sep1:sep2);		% row for display
		set(h_txt(tot_line-i+1), 'string', row);
		sep1 = sep2+1;
	    end

	    if num_row ~= tot_line
		for i=num_row+1:tot_line
		    set(h_txt(tot_line-i+1), 'string', '');	% rm junk
		end
	    end

	    text = ['Page ', num2str(curr_page), ' of ', num2str(num_page)];
%    	    set(h_txt, 'string', helpfile_lst{curr_page});
            set(h_leftleft, 'enable', 'on');
            set(h_left, 'enable', 'on');
	    if curr_page == num_page
                set(h_right, 'enable', 'off');
                set(h_rightright, 'enable', 'off');
	    end
	    set(h_mid, 'string', text);
	case {2}
	    curr_page = num_page;

	    helppage = helpfile_lst{curr_page};

	    idx_row = find(helppage == 10);		% find linefeed 0x0a
	    num_row = length(idx_row);			% lines per page
	    sep1 = 1;					% start row

	    for i=1:num_row
		sep2 = idx_row(i);			% end row
		row = helppage(sep1:sep2);		% row for display
		set(h_txt(tot_line-i+1), 'string', row);
		sep1 = sep2+1;
	    end

	    if num_row ~= tot_line
		for i=num_row+1:tot_line
		    set(h_txt(tot_line-i+1), 'string', '');	% rm junk
		end
	    end

	    text = ['Page ', num2str(curr_page), ' of ', num2str(num_page)];
%    	    set(h_txt, 'string', helpfile_lst{curr_page});
            set(h_leftleft, 'enable', 'on');
            set(h_left, 'enable', 'on');
            set(h_right, 'enable', 'off');
            set(h_rightright, 'enable', 'off');
	    set(h_mid, 'string', text);
    end

    setappdata(gcf, 'curr_page', curr_page);

    return;							% go_to_page


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	resize helpfile window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function resize_fig()

    w = 0.7;
    h = 0.8;
    x = (1-w)/2;
    y = (1-h)/2;

    pos = [x y w h];

    fig_pos = get(gcbf,'Position');	% get new position
%    fig_pos(4) = h;
    if(fig_pos(4) ~= h)			% temp solution for linux
	fig_pos(2) = fig_pos(2)+fig_pos(4) - h;
	fig_pos(4) = h;
    end

    if(fig_pos(3) < w)
	fig_pos(3) = w;
    end

    set(gcbf,'Position',fig_pos);	% no change for h, can't reduce w

    return;				% resize_fig


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	delete helpfile window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function delete_fig()

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       rri_helpfile_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'rri_helpfile_pos');
    catch
    end

    try
       load('rri_pos_profile');
       rri_pos_profile = which('rri_pos_profile.mat');

       rri_helpfile_pos = get(gcbf,'position');

       save(rri_pos_profile, '-append', 'rri_helpfile_pos');
    catch
    end

    return;				% delete_fig

