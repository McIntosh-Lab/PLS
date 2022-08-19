function [new_chan_order_str, new_system] = erp_select_chan(varargin)
%
% usage: [new_chan_order_str, new_system = ...
%		erp_select_chan(old_chan_order_str, old_system, title, view_system)
%

   if nargin == 0 | ischar(varargin{1}) 	% create figure

      old_chan_order_str = '';
      old_system.class = 1;
      old_system.type = 1;
      tit_nam = 'Edit';
      view_system = 'on';

      new_chan_order_str = '';

      if (nargin >= 1), old_chan_order_str = varargin{1}; end;
      if (nargin >= 2), old_system = varargin{2}; end;
      if (nargin >= 3), tit_nam = varargin{3}; end;

      if (nargin >= 4)
         if varargin{4}
            view_system = 'on';
         else
            view_system = 'off';
         end
      end;

      init(old_chan_order_str, old_system, tit_nam, view_system);
      uiwait;                           % wait for user finish

      new_chan_order_str = getappdata(gcf,'new_chan_order_str');
      new_system = getappdata(gcf,'new_system');

      close(gcf);
      return;
   end;

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   set(h,'String','');

   action = upper(varargin{1}{1});

   if strcmp(action,'CREATE_EDIT_FILTER'),
      filter_pattern = getappdata(gcf,'FilterPattern');
      dir_name = pwd;
      if isempty(dir_name),
         dir_name = filesep;
      end;

      set(gcbo,'String',fullfile(dir_name,filter_pattern));
   elseif strcmp(action,'EDIT_FILTER'),
      EditFilter;
   elseif strcmp(action,'RESIZE_FIGURE'),
      SetObjectPositions;
   elseif strcmp(action,'ADD_SESSION_PROFILE'),
      AddSessionProfile;
   elseif strcmp(action,'REMOVE_SESSION_PROFILE'),
      RemoveSessionProfile;
   elseif strcmp(action,'MOVE_UP_PROFILE'),
      MoveUpSessionProfile;
   elseif strcmp(action,'MOVE_DOWN_PROFILE'),
      MoveDownSessionProfile;
   elseif strcmp(action,'TOGGLE_FULL_PATH'),
      SwitchFullPath;
   elseif strcmp(action,'DELETE_FIG')
      delete_fig;
   elseif strcmp(action,'LOAD_TXT')
      load_txt;
   elseif strcmp(action,'SAVE_TXT')
      save_txt;
   elseif strcmp(action,'CLASS_BUTTON_PRESSED'),
      select_class;
   elseif strcmp(action,'TYPE_BUTTON_PRESSED'),
      select_type;
   elseif strcmp(action,'DONE_BUTTON_PRESSED'),
      SelectedChannelList = get(findobj(gcf,'Tag','SelectedChannelList'),'Userdata');
      setappdata(gcf,'new_chan_order_str', num2str(SelectedChannelList));
      setappdata(gcf,'new_system',getappdata(gcf,'new_system'));
      uiresume;
   elseif strcmp(action,'CANCEL_BUTTON_PRESSED'),
      setappdata(gcf,'new_chan_order_str',getappdata(gcf,'old_chan_order_str'));
      setappdata(gcf,'new_system',getappdata(gcf,'old_system'));
      uiresume;
   end;

   return;


% --------------------------------------------------------------------
function init(old_chan_order_str, old_system, tit_nam, view_system)

   switch old_system.class
      case 1
         type_str = 'BESAThetaPhi|EGI128|EGI256|EGI128_v2';

         switch old_system.type
            case 1
               load('erp_loc_besa148');
            case 2
               load('erp_loc_egi128');
            case 3
               load('erp_loc_egi256');
            case 4
               load('erp_loc_egi128_v2');
         end
      case 2
         type_str = 'CTF-150';

         switch old_system.type
            case 1
               load('erp_loc_ctf150');
         end
   end

   chan_num = size(chan_loc, 1);

   save_setting_status = 'on';
   erp_select_chan_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(erp_select_chan_pos) & strcmp(save_setting_status,'on')

      pos = erp_select_chan_pos;

   else

      w = 0.7;
      h = 0.7;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   h0 = figure('Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name',tit_nam, ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Position',pos, ...
        'DeleteFcn','erp_select_chan({''DELETE_FIG''});', ...
        'WindowStyle', 'normal', ...
        'Tag','GetFilesFigure', ...
        'ToolBar','none');

   left_margin = .05;
   text_height = .05;

   x = left_margin;
   y = .9;
   w = .34;
   h = text_height;

   pos = [x y w h];

   fnt = 0.5;

   h1 = uicontrol('Parent',h0, ...            % Channel Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',['Channels: ', num2str(chan_num)], ...
        'Tag','ChannelLabel');

   x = left_margin+.44;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Selected Channel Label
        'Style','text', ...
        'Units','normal', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'HorizontalAlignment','left', ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','Selected Channels: 0', ...
        'Tag','SelectedChannelLabel');

   h = y - 0.18;
   x = left_margin;
   y = 0.18;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Channel Listbox
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',0.04, ...
        'BackgroundColor',[1 1 1], ...
        'HorizontalAlignment','left', ...
        'Interruptible', 'off', ...
 	'Min',1, ...
 	'Max',10, ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', '', ...
        'Tag','ChannelList');

   x = left_margin+.44;
   w = .34;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...            % Selected Channel Listbox
        'Style','listbox', ...
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',0.04, ...
        'BackgroundColor',[1 1 1], ...
        'HorizontalAlignment','left', ...
        'Interruptible', 'off', ...
 	'Min',1, ...
 	'Max',10, ...
        'ListboxTop',1, ...
        'Position',pos, ...
        'String', '', ...
        'Tag','SelectedChannelList');

   x = left_margin + .34 + .01;
   y = .5;
   w = .08;
   h = text_height;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% ">>" Button
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','>>', ...
        'Callback','erp_select_chan({''ADD_SESSION_PROFILE''});', ...
        'Tag','>>Button');

   x = left_margin + .78 + .01;
   y = .65;
   w = 1-left_margin-x;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% UP Button
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','UP', ...
        'Callback','erp_select_chan({''MOVE_UP_PROFILE''});', ...
        'Tag','UPButton');

   y = y - h;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% DOWN Button
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','DOWN', ...
        'Callback','erp_select_chan({''MOVE_DOWN_PROFILE''});', ...
        'Tag','DOWNButton');

   y = .3;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...		% REMOVE Button
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','REMOVE', ...
        'Callback','erp_select_chan({''REMOVE_SESSION_PROFILE''});', ...
        'Tag','REMOVEButton');

   x = left_margin;
   y = .08;
   w = .1;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % CLASS
	'style','popupmenu', ...
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String','ERP|MEG', ...
	'value',old_system.class, ...
        'Callback','erp_select_chan({''CLASS_BUTTON_PRESSED''});', ...
	'visible', view_system, ...
        'Tag','CLASSButton');

   w = .2;
   x = left_margin+.34-w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % TYPE
	'style','popupmenu', ...
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',type_str, ...
	'value',old_system.type, ...
        'Callback','erp_select_chan({''TYPE_BUTTON_PRESSED''});', ...
	'visible', view_system, ...
        'Tag','TYPEButton');

   x = left_margin+.44;
   y = .08;
   w = .12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % DONE
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','DONE', ...
        'Callback','erp_select_chan({''DONE_BUTTON_PRESSED''});', ...
        'Tag','DONEButton');

   x = left_margin+.44+.34-w;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...                      % CANCEL
        'Units','normal', ...
	'fontunit','normal', ...
   	'FontSize',fnt, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'HorizontalAlignment','center', ...
        'String','CANCEL', ...
        'Callback','erp_select_chan({''CANCEL_BUTTON_PRESSED''});', ...
        'Tag','CANCELButton');

   x = .01;
   y = 0;
   w = 1;

   pos = [x y w h];

   c = uicontrol('Parent',h0, ...		% Message Line
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


      %--------------------------- menu ----------------------

      %  file
      %
      h_file = uimenu('parent',h0, ...
           'label','&File', ...
	   'tag','menu_file');
      h2 = uimenu('parent', h_file, ...
           'callback','erp_select_chan({''LOAD_TXT''});', ...
           'label','&Load from a text file', ...
   	   'tag', 'menu_load');
      h2 = uimenu('parent', h_file, ...
           'callback','erp_select_chan({''SAVE_TXT''});', ...
           'label','&Save to a text file', ...
	   'tag', 'menu_save');
      h2 = uimenu('parent', h_file, ...
           'callback','close(gcbf);', ...
           'label','&Close', ...
           'visible','off', ...	
	   'tag', 'menu_close');

   pause(0.01)

   h1 = findobj(gcf,'tag','ChannelList');
   set(h1,'string',chan_nam);

   selected_chan_nam = chan_nam(str2num(old_chan_order_str),:);
   h1 = findobj(gcf,'tag','SelectedChannelList');
   set(h1,'string',selected_chan_nam);

   set(h1, 'user', str2num(old_chan_order_str));
   set(findobj(gcf,'tag','SelectedChannelLabel'),'string', ...
	['Selected Channels: ', ...
	num2str(length(str2num(old_chan_order_str)))]);

   setappdata(gcf,'old_chan_order_str',old_chan_order_str);
   setappdata(gcf,'old_system',old_system);
   setappdata(gcf,'new_system',old_system);

   return;					% Init


% --------------------------------------------------------------------
function AddSessionProfile()

   h = findobj(gcf,'Tag','ChannelList');    % get the selected file
   selected_chan_idx = get(h,'Value')';

   %  update selected channel list
   %
   h = findobj(gcf,'Tag','SelectedChannelList');	   
   selected_chan_order_str = get(h,'String');

   old_chan_order = get(h,'Userdata');

   % check for duplication
   %
   if ~isempty(intersect(selected_chan_idx, old_chan_order))
      msg = 'ERROR: Duplicate channel is not allowed.';
      set(findobj(gcf,'Tag','MessageLine'),'String',msg);
      return;
   end; 

   chan_order = [old_chan_order; selected_chan_idx];

   % if isempty(old_chan_order)
   if isempty(get(h, 'string'))
      set(h, 'value', 1);
   end

   update_chan_order(chan_order);

   return;					% AddSessionProfile


% --------------------------------------------------------------------
function MoveUpSessionProfile()

   %  update the session profile list
   %
   h = findobj(gcf,'Tag','SelectedChannelList');	   
   list_top = get(h,'ListboxTop');
   move_idx = get(h,'Value');
   chan_list = get(h,'String');
   chan_order = get(h,'user');

   if (move_idx == 1),			% already on the top of list
      return;
   end;

   temp_buffer = chan_list(move_idx-1,:);
   chan_list(move_idx-1,:) = chan_list(move_idx,:);
   chan_list(move_idx,:) = temp_buffer;

   temp_buffer = chan_order(move_idx-1);
   chan_order(move_idx-1) = chan_order(move_idx);
   chan_order(move_idx) = temp_buffer;

   curr_value = move_idx - 1;

   set(h,'String',chan_list,'Userdata',chan_order, ...
         'Value',curr_value);

   if (curr_value < list_top)
      set(h,'ListBoxTop',curr_value);
   else
      set(h,'ListBoxTop',list_top);
   end;

   return;					% MoveUpSessionProfile


% --------------------------------------------------------------------
function MoveDownSessionProfile()

   %  update the session profile list
   %
   h = findobj(gcf,'Tag','SelectedChannelList');	   
   list_top = get(h,'ListboxTop');
   move_idx = get(h,'Value');
   chan_list = get(h,'String');
   chan_order = get(h,'user');

   if (move_idx == size(chan_list,1)),		% already on the bottom of list
      return;
   end;
   
   temp_buffer = chan_list(move_idx+1,:);
   chan_list(move_idx+1,:) = chan_list(move_idx,:);
   chan_list(move_idx,:) = temp_buffer;

   temp_buffer = chan_order(move_idx+1);
   chan_order(move_idx+1) = chan_order(move_idx);
   chan_order(move_idx) = temp_buffer;

   curr_value = move_idx + 1;

   set(h,'String',chan_list,'Userdata',chan_order, ...
         'Value',curr_value);

   set(h,'ListBoxTop',list_top);

   return;					% MoveDownSessionProfile


% --------------------------------------------------------------------
function RemoveSessionProfile()

   %  update the session profile list
   %
   h = findobj(gcf,'Tag','SelectedChannelList');	   
   remove_idx = get(h,'Value');
   chan_list = get(h,'String');
   chan_order = get(h,'Userdata');

   if isempty(chan_order)
      return;
   end

   mask = zeros(1,size(chan_list,1));
   mask(remove_idx) = 1;
   chan_order = chan_order(find(mask == 0));

   if length(remove_idx) > 1
      set(h, 'value', 1);
   elseif remove_idx == size(chan_list,1)
      set(h, 'value', remove_idx-1);
   end

   update_chan_order(chan_order);

   return;					% RemoveSessionProfile


%----------------------------------------------------------------------------
function update_chan_order(chan_order)

   new_system = getappdata(gcf,'new_system');

   switch new_system.class
      case 1
         type_str = 'BESAThetaPhi|EGI128|EGI256|EGI128_v2';

         switch new_system.type
            case 1
               load('erp_loc_besa148');
            case 2
               load('erp_loc_egi128');
            case 3
               load('erp_loc_egi256');
            case 4
               load('erp_loc_egi128_v2');
         end
      case 2
         type_str = 'CTF-150';

         switch new_system.type
            case 1
               load('erp_loc_ctf150');
         end
   end

   selected_chan_nam = chan_nam(chan_order,:);

   h1 = findobj(gcf,'tag','SelectedChannelList');

   set(h1, 'string',selected_chan_nam, 'user', chan_order);
   set(findobj(gcf,'tag','SelectedChannelLabel'),'string', ...
	['Selected Channels: ', num2str(length(chan_order))]);

   return;


%----------------------------------------------------------------------------
function delete_fig

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       erp_select_chan_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'erp_select_chan_pos');
    catch
    end

   return;


%----------------------------------------------------------------------------
function load_txt

   [fn, pn] = rri_selectfile('*.txt','Open Electrode Order File');

   if isequal(fn,0) | isequal(pn,0)
      return;
   end

   chan_file = fullfile(pn, fn);

   try
      chan_order = load('-ascii', chan_file);
   catch
      msg = 'Invalid electrode order file';
      uiwait(msgbox(msg,'Error','modal'));
      return;
   end

   if   sum(size(chan_order))~=(size(chan_order,1)+1) | ...
	size(chan_order,1)~=size(unique(chan_order),1) | ...
	all(chan_order~=round(chan_order)) | ...
	min(chan_order)<1

      msg = 'Invalid electrode order file';
      uiwait(msgbox(msg,'Error','modal'));
      return;

   end

   h = findobj(gcf,'Tag','SelectedChannelList');	   

   if isempty(get(h, 'string'))
      set(h, 'value', 1);
   end

   update_chan_order(chan_order);

   return


%----------------------------------------------------------------------------
function save_txt

   SelectedChannelList = get(findobj(gcf,'Tag','SelectedChannelList'),'Userdata');

   [fn, pn] = rri_selectfile('*.txt','Save Electrode Order File');
   chan_file = [pn filesep fn];

   if ~fn
%      msg = 'WARNING: No file is saved.';
%      uiwait(msgbox(msg,'Uncomplete','modal'));

      return;
   else
      try
         save(chan_file,'-ascii','SelectedChannelList')
      catch
         msg = 'ERROR: Cannot save file';
         set(findobj(gcf,'Tag','MessageLine'),'String',msg);
         return;
      end
   end

   return


%----------------------------------------------------------------------------
function select_class

   h_class = findobj(gcf,'tag','CLASSButton');
   h_type = findobj(gcf,'tag','TYPEButton');
   new_system = getappdata(gcf,'new_system');
   class_val = get(h_class,'value');

   if  class_val == new_system.class
      return;
   end

   switch class_val
      case 1
         type_str = 'BESAThetaPhi|EGI128|EGI256|EGI128_v2';
         load('erp_loc_besa148');
      case 2
         type_str = 'CTF-150';
         load('erp_loc_ctf150');
   end

   chan_num = size(chan_loc, 1);

   new_system.type = 1;
   set(h_type,'string',type_str,'value',1);

   new_system.class = class_val;

   h1 = findobj(gcf,'tag','ChannelLabel');
   set(h1,'string',['Channels: ', num2str(chan_num)]);

   h1 = findobj(gcf,'tag','ChannelList');
   set(h1,'string',chan_nam,'value',1);

   h1 = findobj(gcf,'tag','SelectedChannelList');
   set(h1,'string','');

   set(h1, 'user', []);

   set(findobj(gcf,'tag','SelectedChannelLabel'),'string','Selected Channels: 0');

   setappdata(gcf,'new_system',new_system');

   return


%----------------------------------------------------------------------------
function select_type

   h_class = findobj(gcf,'tag','CLASSButton');
   h_type = findobj(gcf,'tag','TYPEButton');
   new_system = getappdata(gcf,'new_system');
   type_val = get(h_type,'value');

   if  type_val == new_system.type
      return;
   end

   switch type_val
      case 1
         switch new_system.class
            case 1				% BESA
               load('erp_loc_besa148');
            case 2				% MEG1
               load('erp_loc_ctf150');
         end
      case 2
         switch new_system.class
            case 1				% EGI128
               load('erp_loc_egi128');
         end
      case 3
         switch new_system.class
            case 1				% EGI256
               load('erp_loc_egi256');
         end
      case 4
         switch new_system.class
            case 1				% EGI128_v2
               load('erp_loc_egi128_v2');
         end
   end

   chan_num = size(chan_loc, 1);

   new_system.type = type_val;

   h1 = findobj(gcf,'tag','ChannelLabel');
   set(h1,'string',['Channels: ', num2str(chan_num)]);

   h1 = findobj(gcf,'tag','ChannelList');
   set(h1,'string',chan_nam,'value',1);

   h1 = findobj(gcf,'tag','SelectedChannelList');
   set(h1,'string','');

   set(h1, 'user', []);

   set(findobj(gcf,'tag','SelectedChannelLabel'),'string','Selected Channels: 0');

   setappdata(gcf,'new_system',new_system');

   return

