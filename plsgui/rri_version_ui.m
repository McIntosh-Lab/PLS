%RRI_VERSION_UI Display helpfile window
%
%   Usage: rri_version_ui('version_file_name') or
%          rri_version_ui('version_file_name', 'title')
%

%   I (version_file_name):  filename string, e.g. 'plsgui_version.txt'
%   I (title):  title for the version dialogbox
%
%   Created on 14-NOV-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rri_version_ui(version_file_name, version_title)

    if ~exist('version_file_name', 'var')
        error('Please indicate the Version file name.');
    end

    if ~exist('version_title', 'var')
        version_title = 'About';
    end

    fid=fopen(version_file_name);
    gui_version=fscanf(fid,'%c');
    fclose(fid);
    gui_version(find(gui_version == 13)) = '';	% remove carriage 0x0d
    msgbox(gui_version, version_title);

    return;

