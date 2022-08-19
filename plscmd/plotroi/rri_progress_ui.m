%RRI_PROGRESS_UI Use rri_progress_status to render the progress bar
%
%   Usage: rri_progress_ui('initialize') or
%          rri_progress_ui('initialize', title) or
%          rri_progress_ui(progress_hdl, title, info)
%
%   See also RRI_PROGRESS_STATUS
%

%   I (progress_hdl) - must be the string 'initialize', or a handle that
%		was created by rri_progress_ui or rri_progress_status.
%   I (title) - title of the progress bar. If empty, title is not changed.
%   I (info) - If it is a string, it is a message shown on the message line,
%		if it is a number, it is the amount in the progress bar.
%   O (hdl) - If progress_hdl is 'initialize', hdl is the handle to the
%		progress bar that rri_progress_ui was created.
%
%   Modified on 05-OCT-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hdl = rri_progress_ui(progress_hdl, title, info)

    if nargin < 1
        error('Check input arguments');
        return;
    end

    %  'initialize' - return progress handle if any
    %
    if ischar(progress_hdl) & strcmp(lower(progress_hdl),'initialize')

	% if progress bar exist, simply return its handle
	%
        if ~isempty(gcf) & isequal(get(gcf,'Tag'),'ProgressFigure')
            hdl = gcf;
            if nargin > 1, set(hdl, 'Name', title); end;

	% if progress bar does not exist, create one
	%
        else
            if nargin == 1
                title = '';
            end

            hdl = rri_progress_status([], 'Create', title);
        end
        return;

    elseif ischar(progress_hdl) & strcmp(lower(progress_hdl),'init')

	% if progress bar exist, simply return its handle
	%
        if ~isempty(gcf) & isequal(get(gcf,'Tag'),'ProgressFigure')
            hdl = gcf;
            if nargin > 1, set(hdl, 'Name', title); end;

	% if progress bar does not exist, create one
	%
        else
            if nargin == 1
                title = '';
            end

            hdl = rri_progress_status([], 'Create', title, 1);
        end
        return;

    elseif ischar(progress_hdl) & strcmp(lower(progress_hdl),'cancel_progress')

        set(gcbf, 'user', 1);
        return;

    end

    % update progress bar
    %
    if ~isempty(progress_hdl)
        if nargin < 3
            error('Check input arguments');
            return;
        end

	% update message line
	%
        if ischar(info)
            if ~isempty(title), set(progress_hdl, 'Name', title); end;
            hdl = rri_progress_status(progress_hdl,'Show_message',info);

	% update amount
	%
        else
            if(info <= 0)
                if ~isempty(title), set(progress_hdl, 'Name', title); end;
                hdl = rri_progress_status(progress_hdl,'Clear_bar');
            else
                if ~isempty(title), set(progress_hdl, 'Name', title); end;
                hdl = rri_progress_status(progress_hdl,'Update_bar',info);
            end
        end
        return;
    end

    return;					% rri_progress_ui

