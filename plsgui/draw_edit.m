%  "draw_edit" let you edit the plotted 1-D data by picking any point
%  on the curve and moving the mouse freely. The data can be either a
%  1-D matrix, or obtained by load a 1-D text file, or the result of
%  a matlab function.
%
%  Usage:  draw_edit(y, [ax_hdl])
%
%	y:	A 1-D matrix, or obtained by load a 1-D text file, or
%		the result of a matlab function.
%
%	ax_hdl:	Optional. The handle of axis that you want to plot. By
%		default, it will create a new one.
%
%  Example:	draw_edit([1 3 2 7 9])
%		draw_edit(load('my_1D_data.txt'))
%		draw_edit(log(1:10), gca)
%
%  jimmy@rotman-baycrest.on.ca
%
%----------------------------------------------------------------------

function draw_edit(action, ax_hdl)

   if ~exist('action', 'var')
      action = 'log(1:10)';
   end

   if ~exist('ax_hdl','var') & ...
	( ~exist('action', 'var') | ~iscell(action) )
      figure;
      ax_hdl = gca;
   end

   if ~iscell(action)
      y = action;
      init(y, ax_hdl);
      return;
   end;

   if iscell(action) & strcmp(action{1}, 'dragpt')
      dragpt;
   elseif strcmp(action, 'startdragpt')
      startdragpt;
   elseif strcmp(action, 'stopdragpt')
      stopdragpt;
   end

   return;						% draw_edit

%----------------------------------------------------------------------

function init(y, ax_hdl)

   if ischar(y)
      y = str2num(y);
      y = y(:);
   else
      y = y(:);
   end

   fig_hdl = get(ax_hdl,'parent');
   set(fig_hdl, 'windowbuttonup', 'draw_edit({''stopdragpt''})');

   axes(ax_hdl);
   line_hdl = plot(y);
   set(line_hdl, 'buttondown', 'draw_edit({''startdragpt''})');

   setappdata(gcf, 'draw_edit_line_hdl', line_hdl);
   setappdata(gcf, 'draw_edit_org_y', y(:));
   setappdata(gcf, 'draw_edit_old_y', y(:));
   setappdata(gcf, 'draw_edit_new_y', y(:));
   setappdata(gcf, 'draw_edit_lockx', 0);

   return;						% init

%----------------------------------------------------------------------

function startdragpt()

   set(gcf, 'windowbuttonmotion', 'draw_edit({''dragpt''})');

   return;

%----------------------------------------------------------------------

function stopdragpt()

   y = get(getappdata(gcf,'draw_edit_line_hdl'),'ydata');
   setappdata(gcf, 'draw_edit_old_y', getappdata(gcf, 'draw_edit_new_y'));
   setappdata(gcf, 'draw_edit_new_y', y(:));
   setappdata(gcf, 'draw_edit_lockx', 0);
   point_hdl = getappdata(gcf, 'draw_edit_point_hdl');
   
   if ~isempty(point_hdl) & ishandle(point_hdl)
      delete(point_hdl);
   end

   set(gcf, 'windowbuttonmotion', '');

   return;

%----------------------------------------------------------------------

function dragpt()

   point_hdl = getappdata(gcf, 'draw_edit_point_hdl');
   
   if ~isempty(point_hdl) & ishandle(point_hdl)
      delete(point_hdl);
   end

   pt = get(gca, 'current');
   x = pt(1,1);
   y = pt(1,2);

   line_hdl = getappdata(gcf, 'draw_edit_line_hdl');

   if(~getappdata(gcf, 'draw_edit_lockx'))
      xdata = get(line_hdl, 'xdata');
      locatex = abs(xdata-x);
      locatex = find(locatex==min(locatex));

      setappdata(gcf, 'draw_edit_lockx', 1);   
      setappdata(gcf, 'draw_edit_locatex', locatex);   
   else
      locatex = getappdata(gcf, 'draw_edit_locatex');   
   end

   ydata = get(line_hdl, 'ydata');
   ydata(locatex) = y;

   set(line_hdl, 'ydata', ydata);

   hold on;
   xdata = get(line_hdl, 'xdata');
   x = xdata(locatex);
   point_hdl = plot(x,y,'o','linewidth',2,'markerface','r','markeredge','r','markersize',5);
   setappdata(gcf, 'draw_edit_point_hdl', point_hdl);
   hold off;

   return;

