function rri_create_fig_3v

   old_fig = gcf;
   nii_view = getappdata(old_fig, 'nii_view');

   s=view_nii(gcf);
   nii=nii_view.nii;
   opt.command='init';
   opt.usepanel=0;
   opt.useimagesc=0;
   opt.setcolormap=s.colormap;
   opt.setviewpoint=s.viewpoint;
   opt.usecrosshair = 0;
   s=view_nii(nii,opt);
   opt2.enabledirlabel=0;
   opt2.enableslider=0;
   view_nii(s.fig,opt2);

   nii_view = getappdata(s.fig, 'nii_view');
   set(nii_view.handles.axial_image, 'buttondown', '');
   set(nii_view.handles.coronal_image, 'buttondown', '');
   set(nii_view.handles.sagittal_image, 'buttondown', '');
   set(nii_view.handles.cbarminmax_axes, 'visible', 'off');
   set(nii_view.handles.cbar_axes, 'visible', 'off');

   cbar_hdl = copyobj_legacy(getappdata(old_fig,'Colorbar'), s.fig);
   set(cbar_hdl,'pos',get(nii_view.handles.cbar_axes,'pos'));

   return;


%----------------------------------------------------------------------

   axial_axes = get(nii_view.handles.axial_axes, 'position');
   coronal_axes = get(nii_view.handles.coronal_axes, 'position');
   sagittal_axes = get(nii_view.handles.sagittal_axes, 'position');
   axial_slider = get(nii_view.handles.axial_slider, 'position');
   coronal_slider = get(nii_view.handles.coronal_slider, 'position');

   old_gap_w = axial_slider(3);
   old_gap_h = coronal_slider(4);
   
   old_x = coronal_axes(1);
   old_y = axial_axes(2);
   old_w = sagittal_axes(1) + sagittal_axes(3) - old_x;
   old_h = coronal_axes(2) + coronal_axes(4) - old_y;
   old_fig_pos = get(old_fig, 'position');

   new_w = 0.9;
   new_h = 0.9;
   new_fig_w = old_w * old_fig_pos(3) / new_w;
   new_fig_h = old_h * old_fig_pos(4) / new_h;
   new_fig_x = (1 - new_fig_w) / 2;
   new_fig_y = (1 - new_fig_h) / 2;

   pos = [new_fig_x new_fig_y new_fig_w new_fig_h];

   axial_ax_pos = [0.05, 0.05, axial_axes(3)*new_w/old_w, ...
			axial_axes(4)*new_h/old_h];

   coronal_ax_pos = [0.05, 0.05 + old_gap_h*new_h/old_h + axial_ax_pos(4), ...
			coronal_axes(3)*new_w/old_w, ...
			coronal_axes(4)*new_h/old_h];

   sagittal_ax_pos = [0.05 + old_gap_w*new_w/old_w + coronal_ax_pos(3), ...
			0.05 + old_gap_h*new_h/old_h + axial_ax_pos(4), ...
			sagittal_axes(3)*new_w/old_w, ...
			sagittal_axes(4)*new_h/old_h];

   new_fig = figure('units','normal', ...
	'position', pos, ...
	'colormap', get(old_fig, 'colormap'), ...
	'name', get(old_fig, 'name'));

   ax_hdl = copyobj_legacy([nii_view.handles.axial_axes, nii_view.handles.coronal_axes, ...
	nii_view.handles.sagittal_axes], new_fig);

   set(ax_hdl(1), 'position', axial_ax_pos);
   set(ax_hdl(2), 'position', coronal_ax_pos);
   set(ax_hdl(3), 'position', sagittal_ax_pos);

   img_hdl = findobj(new_fig, 'type', 'image');

   for i=1:length(img_hdl)
      set(img_hdl(i), 'buttondown', '');
   end

   line_hdl = findobj(new_fig, 'type', 'line');

   for i=1:length(line_hdl)
      set(line_hdl(i), 'visible', 'off');
   end

   return;

