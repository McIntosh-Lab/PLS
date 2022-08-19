%READ_EEG_FORMAT  First, choose a vendor name of the EEG system, from which
%  the EEG data was acquired. Second, choose a file format that corresponds
%  to this specific vendor.
%
%  Usage: EEG_format = read_eeg_format
%
%  EEG_format - structure containing 'vendor' and 'machineformat'
%
%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%
function EEG_format = read_eeg_format(varargin)

   if nargin < 1 | isempty(varargin{1}) | isstruct(varargin{1})

      if nargin < 1 | isempty(varargin{1})
         init([]);
      else
         init(varargin{1});
      end

      uiwait;

      EEG_format = getappdata(gcf, 'EEG_format');

      close(gcf);
      return;
   end

   action = varargin{1};

   if strcmp(action, 'delete_fig')
      delete_fig;
   elseif strcmp(action, 'select_vendor')
      select_vendor;
   elseif strcmp(action, 'select_machineformat')
      select_machineformat;
   elseif strcmp(action, 'select_ok')
      uiresume;
   elseif strcmp(action, 'select_cancel')
      setappdata(gcf,'EEG_format',[]);
      uiresume;
   end

   return;					% read_eeg_format


%---------------------------------------------------------------------
function data = init(eeg_format)

   save_setting_status = 'on';
   read_eeg_format_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(read_eeg_format_pos) & strcmp(save_setting_status,'on')

      pos = read_eeg_format_pos;

   else

      w = 0.4;
      h = 0.2;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   hdl.fig = figure('Color',[0.8 0.8 0.8], ...
        'Units','normal', ...
        'Name','Select an EEG format', ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Position',pos, ...
        'DeleteFcn','read_eeg_format(''delete_fig'');', ...
        'WindowStyle', 'normal', ...
        'ToolBar','none');

   x = 0.08;
   y = 0.65;
   w = 0.4;
   h = 0.2;

   pos = [x y w h];

   hdl.vendor_txt = uicontrol('Parent',hdl.fig, ...
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','point', ...
   	'FontSize',12, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','VENDOR NAME    ');

   x = x + w + 0.04;

   pos = [x y w h];

   hdl.machineformat_txt = uicontrol('Parent',hdl.fig, ...
   	'Style','text', ...
   	'Units','normal', ...
   	'BackgroundColor',[0.8 0.8 0.8], ...
   	'FontUnits','point', ...
   	'FontSize',12, ...
   	'HorizontalAlignment','center', ...
   	'Position',pos, ...
   	'String','MACHINE FORMAT ');

   x = 0.08;
   y = 0.5;
   w = 0.4;
   h = 0.2;

   pos = [x y w h];

   hdl.vendor = uicontrol('Parent',hdl.fig, ...
   	'Style','popupmenu', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','point', ...
   	'FontSize',12, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String',{'BESA','NeuroScan','ANT','EGI'}, ...
   	'Callback','read_eeg_format(''select_vendor'');');

   x = x + w + 0.04;

   pos = [x y w h];

   hdl.machineformat = uicontrol('Parent',hdl.fig, ...
   	'Style','popupmenu', ...
   	'Units','normal', ...
   	'BackgroundColor',[1 1 1], ...
   	'FontUnits','point', ...
   	'FontSize',12, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'Enable','off', ...
   	'String',{'ieee-le','ieee-be','vaxd','vaxg','cray','ieee-le.l64','ieee-be.l64'}, ...
   	'Callback','read_eeg_format(''select_machineformat'');');

   x = 0.12;
   y = 0.2;
   w = .32;
   h = 0.18;

   pos = [x y w h];

   hdl.cancel = uicontrol('Parent',hdl.fig, ...
   	'Units','normal', ...
   	'FontUnits','point', ...
   	'FontSize',12, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','Cancel', ...
   	'Callback','read_eeg_format(''select_cancel'');');

   x = x + w + 0.12;

   pos = [x y w h];

   hdl.ok = uicontrol('Parent',hdl.fig, ...
   	'Units','normal', ...
   	'FontUnits','point', ...
   	'FontSize',12, ...
   	'HorizontalAlignment','left', ...
   	'Position',pos, ...
   	'String','OK', ...
   	'Callback','read_eeg_format(''select_ok'');');

   if ~isempty(eeg_format) & strcmpi(eeg_format.vendor, 'neuroscan')
      set(hdl.machineformat, 'enable', 'on');
      set(hdl.vendor, 'value', 2);
      EEG_format.vendor = 'NeuroScan';
   elseif ~isempty(eeg_format) & strcmpi(eeg_format.vendor, 'ant')
      set(hdl.machineformat, 'enable', 'on');
      set(hdl.vendor, 'value', 3);
      EEG_format.vendor = 'ANT';
   elseif ~isempty(eeg_format) & strcmpi(eeg_format.vendor, 'egi')
      set(hdl.machineformat, 'enable', 'on');
      set(hdl.vendor, 'value', 4);
      EEG_format.vendor = 'EGI';
   else
      set(hdl.machineformat, 'enable', 'off');
      set(hdl.vendor, 'value', 1);
      EEG_format.vendor = 'BESA';
   end

   if ~isempty(eeg_format) & strcmpi(eeg_format.machineformat, 'ieee-be')
      set(hdl.machineformat, 'value', 2);
      EEG_format.machineformat = 'ieee-be';
   elseif ~isempty(eeg_format) & strcmpi(eeg_format.machineformat, 'vaxd')
      set(hdl.machineformat, 'value', 3);
      EEG_format.machineformat = 'vaxd';
   elseif ~isempty(eeg_format) & strcmpi(eeg_format.machineformat, 'vaxg')
      set(hdl.machineformat, 'value', 4);
      EEG_format.machineformat = 'vaxg';
   elseif ~isempty(eeg_format) & strcmpi(eeg_format.machineformat, 'cray')
      set(hdl.machineformat, 'value', 5);
      EEG_format.machineformat = 'cray';
   elseif ~isempty(eeg_format) & strcmpi(eeg_format.machineformat, 'ieee-le.l64')
      set(hdl.machineformat, 'value', 6);
      EEG_format.machineformat = 'ieee-le.l64';
   elseif ~isempty(eeg_format) & strcmpi(eeg_format.machineformat, 'ieee-be.l64')
      set(hdl.machineformat, 'value', 7);
      EEG_format.machineformat = 'ieee-be.l64';
   else
      set(hdl.machineformat, 'value', 1);
      EEG_format.machineformat = 'ieee-le';
   end

   setappdata(hdl.fig, 'hdl', hdl);
   setappdata(hdl.fig, 'EEG_format', EEG_format);

   return;					% init


%----------------------------------------------------------------------------
function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      read_eeg_format_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'read_eeg_format_pos');
   catch
   end

   return;					% delete_fig


%----------------------------------------------------------------------------
function select_vendor

   hdl = getappdata(gcbf,'hdl');
   EEG_format = getappdata(gcbf,'EEG_format');

   vendor_cell = get(hdl.vendor,'string');
   EEG_format.vendor = vendor_cell{ get(hdl.vendor,'value') };

   if strcmp(EEG_format.vendor, 'BESA')
      set(hdl.machineformat, 'enable', 'off');
   else
      set(hdl.machineformat, 'enable', 'on');
   end

   setappdata(gcbf,'EEG_format',EEG_format);

   return;					% select_vendor


%----------------------------------------------------------------------------
function select_machineformat

   hdl = getappdata(gcbf,'hdl');
   EEG_format = getappdata(gcbf,'EEG_format');

   machineformat_cell = get(hdl.machineformat,'string');

   EEG_format.machineformat = machineformat_cell{ get(hdl.machineformat,'value') };
   setappdata(gcbf,'EEG_format',EEG_format);

   return;					% select_machineformat

