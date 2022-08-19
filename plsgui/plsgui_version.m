function plsgui_version()

%    fid=fopen('plsgui_version.txt');
%    gui_version=fscanf(fid,'%c');
%    fclose(fid);

%    gui_version(find(gui_version == 13)) = '';	% remove carriage 0x0d

    [tmp ver_num] = textread('whatsnew.txt','%s%s',1);

    msg0 = ['                            '];
    msg0 = [msg0, 'PLS Application        Version  ', ver_num{1}];

    msg1 = ['This application is developped for Rotman Research Inistitute. '];
    msg1 = [msg1 'Since it is still under developing, please report us any '];
    msg1 = [msg1 'problem in detail with the version number to: '];
    msg1 = [msg1 'jshen@research.baycrest.org '];

    msg2 = ['Please also check for any newer release from: '];
    msg2 = [msg2 'http://research.baycrest.org/pls/UserGuide.htm '];

    gui_version = {'', msg0, '', msg1, '', msg2, ''};

    msgbox(gui_version, 'About PLS Application');

    return;

