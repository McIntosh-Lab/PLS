%RRI_TXTBOX Display a text box for your plot
%	RRI_TXTBOX puts a text box on the current plot using the
%	specified name/value string pairs.
%
%	Usage: rri_txtbox(ha,nam_str1,val_str1,name_str2,val_str2)
%
%	ha: handle of the axis where you are going to put rri_txtbox
%	nam_str#,val_str#, ...:	any number of pairs you want to display
%

%   Created on 20-NOV-2002 by Jimmy Shen
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function txtbox_hdl = rri_txtbox(varargin)

   txtbox_hdl = [];

   % input is action or simply invalid
   %
   if nargin ==0 | (~ishandle(varargin{1}) & ~ischar(varargin{1}))
      if nargin ~=0 & iscell(varargin{1})
         mov_txtbox(varargin{1}{1});
      else
         msgbox('Input argument can only be accepted strings.','modal');
      end
      return;
   end

   % input is not in pair
   %
   if (mod(nargin,2) & ~ishandle(varargin{1})) | ...
      (~mod(nargin,2) & ishandle(varargin{1}))
      msgbox('Input argument can only be accepted in pairs.','modal');
      return;
   end

   % did not input handle, and first variable is not a string
   %
   if ~ishandle(varargin{1})
      if ~ischar(varargin{1})
         msgbox('Input argument can only be accepted strings.','modal');
         return;
      end
   end

   % input is not a string
   for i=2:nargin
      if ~ischar(varargin{i})
         msgbox('Input argument can only be accepted strings.','modal');
         return;
      end
   end

   % decide CurrentAxes
   %
   if ishandle(varargin{1})
      CurrentAxes = varargin{1};
   else
      CurrentAxes = gca;
   end

   % decide parent figure CurrentFigure
   %
   CurrentFigure = get(CurrentAxes, 'parent');

   % make CurrentAxes current axis
   %
%   axes(CurrentAxes);

   % remove existing rri_txtbox
   %
   try
      txtbox_hdl = findobj(CurrentFigure, 'tag', 'rri_txtbox');
      if txtbox_hdl, delete(txtbox_hdl); end;
   catch
   end

   % get position from parent axes
   %
   old_unit = get(CurrentAxes,'unit');
   set(CurrentAxes,'unit','normal');
   pos = get(CurrentAxes,'position');
   curr = get(CurrentAxes,'currentpoint');
   xlim = get(CurrentAxes,'xlim');
   ylim = get(CurrentAxes,'ylim');

   % try to keep txtbox inside axes
   %
   if curr(1,1) < xlim(1) +0.01
      curr(1,1) = xlim(1) +0.01;
   end

   if curr(1,2) < ylim(1) +0.01
      curr(1,2) = ylim(1) +0.01;
   end

   x_offset = (curr(1,1)-xlim(1)) / (xlim(2) - xlim(1));
   y_offset = (curr(1,2)-ylim(1)) / (ylim(2) - ylim(1));
   set(CurrentAxes,'unit',old_unit);

   fntangle = get(CurrentAxes,'fontangle');
   fntname = get(CurrentAxes,'fontname');
   fntunit = get(CurrentAxes,'fontunit');
   fntweight = get(CurrentAxes,'fontweight');
   fnt = get(CurrentAxes,'fontsize');

   % create rri_txtbox axes, and save CurrentAxes in userdata field.
   %
   txtbox_hdl = axes('parent',CurrentFigure, ...
        'unit','normal', ...
        'color',[1 0.9 0.9], ...
	'FontAngle', fntangle, ...
	'FontName', fntname, ...
        'FontUnits', fntunit, ...
        'FontWeight', fntweight, ...
        'FontSize', fnt, ...
	'box','on', ...
	'nextplot','add', ...
        'xtick', [-1], ...
        'ytick', [-1], ...
	'buttondown','rri_txtbox({''ButtonDown''});', ...
	'user',CurrentAxes, ...
	'tag','rri_txtbox', ...
        'position', pos);

   % to avoid "The DrawMode property will be removed in a future release" warning in R2014b
   if verLessThan('matlab', '8.4.0') % R2014b
     set(txtbox_hdl,'drawmode', 'fast');
   else
     set(txtbox_hdl,'sortmethod', 'childorder');
   end

   if ishandle(varargin{1})
      items = (nargin-1)/2;
      for i=1:items
         txtbox_txt{i} = [' ', deblank(varargin{i*2}), ': ', ...
			deblank(varargin{i*2+1}), ' '];
      end
   else
      items = nargin/2;
      for i=1:items
         txtbox_txt{i} = [' ', deblank(varargin{i*2-1}), ': ', ...
			deblank(varargin{i*2}), ' '];
      end
   end

   % make a typical charactor 'johny' to test the size text_ext
   %
   text_hdl = text(0, 0.5, ...
	'johny', ...
	'fontangle', fntangle, ...
	'fontname', fntname, ...
	'fontunit', fntunit, ...
	'fontweight', fntweight, ...
	'fontsize', fnt, ...
	'unit', 'normal','Interpreter','none');

%	'fontunit', 'point', ...
%	'fontsize',11, ...

   text_ext = get(text_hdl, 'extent');
   delete(text_hdl);
   ext_h = text_ext(4);		% get height of text_exh

   txtbox_pos = get(txtbox_hdl,'position');
   txtbox_pos(1) = pos(1) + pos(3)*x_offset;
   txtbox_pos(2) = pos(2) + pos(4)*y_offset;
   txtbox_pos(4) = txtbox_pos(4) * ext_h * (items+1);

   for i=1:items
      txtbox_txt_hdl(i) = text(0, double((items+1-i)/(items+1)), ...
	txtbox_txt{i}, ...
	'fontangle', fntangle, ...
	'fontname', fntname, ...
	'fontunit', fntunit, ...
	'fontweight', fntweight, ...
	'fontsize', fnt, ...
	'unit','normal', ...
	'interpreter','none','Interpreter','none', ...
        'buttondown','rri_txtbox({''ButtonDown''});');

%	'fontunit', 'point', ...
%	'fontsize',11, ...

      ext(i,:)=get(txtbox_txt_hdl(i),'extent');
   end

   max_ext = max(ext(:,3));				% max text width

   txtbox_pos(3) = txtbox_pos(3) * max_ext;

   % try to keep txtbox inside axes
   %
   if txtbox_pos(1) + txtbox_pos(3) > pos(1) + pos(3)
      txtbox_pos(1) = pos(1) + pos(3) - txtbox_pos(3) - 0.01;
   end

   if txtbox_pos(2) + txtbox_pos(4) > pos(2) + pos(4)
      txtbox_pos(2) = pos(2) + pos(4) - txtbox_pos(4) - 0.01;
   end

   set(txtbox_hdl, 'position', txtbox_pos);

   % make CurrentAxes current, and make txtbox_hdl not CurrentAxes
   %
   set(CurrentFigure, 'CurrentAxes', CurrentAxes);

   return					% rri_txtbox


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   MOV_TXTBOX let you drag and move the text box created by RRI_TXTBOX
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mov_txtbox(action)

   CallingFigure = gcbf;

   if isempty(CallingFigure)
      return;
   else
      ZoomMode = zoom(CallingFigure,'getmode');
      if (isequal(ZoomMode,'in') | isequal(ZoomMode,'on'))
         return;
      end
   end

   switch(action)
      case {'ButtonDown'}	% called by button down function

         txtbox_hdl = get_boxhdl(gcbo);

         % create txtbox_obj, and store old data
         %
         txtbox_obj.txtbox_hdl = txtbox_hdl;
         txtbox_obj.old_txt_unit = get(txtbox_hdl,'unit');
         txtbox_obj.old_fig_unit = get(CallingFigure,'unit');
         txtbox_obj.old_pointer = get(CallingFigure,'pointer');

         % set new data
         %
         set(txtbox_hdl,'unit','pixel');
         set(CallingFigure,'unit','pixel');
         set(CallingFigure,'pointer','fleur');
         set(CallingFigure,'windowbuttonmotion','rri_txtbox({''MouseMove''});');
         set(CallingFigure,'windowbuttonup','rri_txtbox({''ButtonUp''});');

         % get position in pixel
         %
         lastclick_pos = get(CallingFigure,'currentpoint');
         txtbox_pos = get(txtbox_hdl,'position');
         txtbox_obj.offset = txtbox_pos([1 2]) - lastclick_pos;

         % save txtbox_obj
         %
         setappdata(CallingFigure,'txtbox_obj',txtbox_obj);

      case {'MouseMove'}	% called by Window Button Motion function

         % update obj new data
         %
         lastclick_pos = get(CallingFigure,'currentpoint');
         txtbox_obj = getappdata(CallingFigure,'txtbox_obj');
         txtbox_hdl = txtbox_obj.txtbox_hdl;
         txtbox_pos = get(txtbox_hdl,'position');
         txtbox_pos([1 2]) = lastclick_pos + txtbox_obj.offset;
         set(txtbox_hdl, 'position', txtbox_pos);

      case {'ButtonUp'}		% called by Window Button Up function

         txtbox_obj = getappdata(CallingFigure,'txtbox_obj');

         % restore saved old_data
         %
         set(txtbox_obj.txtbox_hdl, 'unit', txtbox_obj.old_txt_unit);
         set(CallingFigure, ...
		'windowbuttonmotion','', ...
		'windowbuttonup','',...
		'pointer', txtbox_obj.old_pointer, ...
		'units', txtbox_obj.old_fig_unit);

         % make CurrentAxes current, and make txtbox_hdl not CurrentAxes
         %
         CurrentAxes = get(txtbox_obj.txtbox_hdl, 'user');
         set(CallingFigure, 'CurrentAxes', CurrentAxes);

         rmappdata(CallingFigure,'txtbox_obj');

   end

   return					% mov_txtbox


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   GET_BOXHDL will search and return txtbox handle along parent objs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function txtbox_hdl = get_boxhdl(child)

   txtbox_hdl = [];

   while ~isempty(child)
      if strcmp(get(child,'type'),'axes') & ...
	 strcmp(get(child,'tag'),'rri_txtbox')
         txtbox_hdl = child;
         break;
      end

      child = get(child, 'parent');
   end

   return					% get_boxhdl

