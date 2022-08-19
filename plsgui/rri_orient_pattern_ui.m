%  Test orientation conversion before creating datamat
%
%  Usage: [dims, voxel_size, origin, nii, orient_pattern] = ...
%		rri_orient_pattern_ui(imgfile, nii, orient_pattern);

%  Jimmy Shen, 28-OCT-04
%___________________________________________________________________

function [dims, voxel_size, origin, nii, orient_pattern] = ...
	rri_orient_pattern_ui(varargin)

   if ~iscell(varargin{1})
      imgfile = varargin{1};
      nii = varargin{2};
      orient_pattern = varargin{3};

      if isempty(orient_pattern)
         nii = load_nii(imgfile);
      end

      init(nii, orient_pattern);
      uiwait;

      dims = getappdata(gcf, 'dims');
      voxel_size = getappdata(gcf, 'voxel_size');
      origin = getappdata(gcf, 'origin');
      nii = getappdata(gcf, 'nii');
      orient_pattern = getappdata(gcf, 'orient_pattern');

      savfig = getappdata(gcf,'savfig');
      close(gcf);

      if ~isempty(savfig)
         set(savfig,'windowstyle','modal');
      end

      return;
   end

   switch(varargin{1}{1})
   case 'delete_fig'
      delete_fig;
   case 'modify'
      modify;
   case 'done'
      uiresume;
   case 'cancel'
      cancel;
   end

   return;

%___________________________________________________________________

function init(nii, orient_pattern)

   savfig = [];
   if strcmpi(get(gcf,'windowstyle'),'modal')
      savfig = gcf;
      set(gcf,'windowstyle','normal');
   end

   fig_w = 0.75;
   fig_h = 0.8;
   fig_x = (1 - fig_w)/2;
   fig_y = (1 - fig_h)/2;

   pos = [fig_x fig_y fig_w fig_h];

   h0 = figure('Units','normal', ...
      'Color',[0.8 0.8 0.8], ...
      'Name','Change Image Orientation', ...
      'NumberTitle','off', ...
      'DoubleBuffer','on', ...
      'MenuBar','none',...
      'Units','normal', ...
      'Position',pos, ...
      'DeleteFcn','rri_orient_pattern_ui({''delete_fig''})', ...
      'Tag','mainfig');

   x = .05;
   y = .27;
   w = .1;
   h = 0.05;
   fnt = 12;

   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
      'Units','normal', ...
      'fontunit','point', ...
      'FontSize',fnt, ...
      'ListboxTop',0, ...
      'Position',pos, ...
      'String','Re-orient', ...
      'callback','rri_orient_pattern_ui({''modify''})', ...
      'Tag','modify');

   y = y - 0.1;
   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
      'Units','normal', ...
      'fontunit','point', ...
      'FontSize',fnt, ...
      'ListboxTop',0, ...
      'Position',pos, ...
      'String','Done', ...
      'callback','rri_orient_pattern_ui({''done''})', ...
      'Tag','done');

   y = y - 0.1;
   pos = [x y w h];

   h1 = uicontrol('Parent',h0, ...
      'Units','normal', ...
      'fontunit','point', ...
      'FontSize',fnt, ...
      'ListboxTop',0, ...
      'Position',pos, ...
      'String','Cancel', ...
      'callback','rri_orient_pattern_ui({''cancel''})', ...
      'Tag','cancel');

   gui3view.figure = h0;
   gui3view.area = [0.2 0.07 0.73 0.86];

   opt.command = 'init';
   opt.setarea = [0.2 0.07 0.73 0.86];
   opt.usecolorbar = 0;
   view_nii(h0, nii, opt);

   setappdata(h0, 'gui3view', gui3view);
   setappdata(h0, 'savfig', savfig);

   setappdata(h0, 'dims', double(nii.hdr.dime.dim(2:4)));
   setappdata(h0, 'voxel_size', double(nii.hdr.dime.pixdim(2:4)));
   setappdata(h0, 'origin', double(nii.hdr.hist.originator(1:3)));
   setappdata(h0, 'nii', nii);
   setappdata(h0, 'orient_pattern', orient_pattern);

   setappdata(h0, 'old_dims', double(nii.hdr.dime.dim(2:4)));
   setappdata(h0, 'old_voxel_size', double(nii.hdr.dime.pixdim(2:4)));
   setappdata(h0, 'old_origin', double(nii.hdr.hist.originator(1:3)));
   setappdata(h0, 'old_nii', nii);
   setappdata(h0, 'old_orient_pattern', orient_pattern);

   return;

%___________________________________________________________________

function delete_fig

   return;

%___________________________________________________________________

function modify

   nii = getappdata(gcf, 'nii');
   orient_pattern = getappdata(gcf, 'orient_pattern');
   gui3view = getappdata(gcf, 'gui3view');

   [nii, orient, orient_pattern] = rri_orient(nii, orient_pattern);

   if isequal(orient, [1 2 3])
      return;
   end

   s=view_nii(gcf);
   opt.command='updatenii';
   opt.setarea=s.area;
   opt.usecolorbar = 0;
   view_nii(gcf, nii, opt);

   setappdata(gcf, 'dims', double(nii.hdr.dime.dim(2:4)));
   setappdata(gcf, 'voxel_size', double(nii.hdr.dime.pixdim(2:4)));
   setappdata(gcf, 'origin', double(nii.hdr.hist.originator(1:3)));
   setappdata(gcf, 'nii', nii);
   setappdata(gcf, 'orient_pattern', orient_pattern);

   return;

%___________________________________________________________________

function cancel

   dims = getappdata(gcf, 'old_dims');
   voxel_size = getappdata(gcf, 'old_voxel_size');
   origin = getappdata(gcf, 'old_origin');
   nii = getappdata(gcf, 'old_nii');
   orient_pattern = getappdata(gcf, 'old_orient_pattern');

   setappdata(gcf, 'dims', dims);
   setappdata(gcf, 'voxel_size', voxel_size);
   setappdata(gcf, 'origin', origin);
   setappdata(gcf, 'nii', nii);
   setappdata(gcf, 'orient_pattern', orient_pattern);

   uiresume;

   return;

