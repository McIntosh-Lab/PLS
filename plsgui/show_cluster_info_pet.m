function  show_cluster_info(varargin)

   switch (varargin{1}),
     case {'PrevPage'}
         curr_page = getappdata(gcbf,'CurrPage');
         show_report_page(curr_page-1);
     case {'NextPage'}
         curr_page = getappdata(gcbf,'CurrPage');
         show_report_page(curr_page+1);
      case {'LoadClusterReport'}
	 cluster_fig = load_cluster_report(varargin{2});
      case {'SaveClusterReport'}
	 save_cluster_report;
      case {'SaveClusterTXT'}
	 save_cluster_txt;
      case {'SaveAllLocation'}
         save_all_location;
      case {'SavePeakLocation'}
         save_peak_location;
      case {'delete_fig'}
         delete_fig;
      otherwise
         try
            load(varargin{1});
         catch
            error(['Cannot open the cluster report file.']);
         end;

         if ~isfield(cluster_info,'peak_thresh')
            cluster_info.peak_thresh = cluster_info.threshold;
            cluster_info.peak_thresh2 = cluster_info.threshold2;
         end

         create_report_figure(report_type);
         setup_cluster_data_idx(cluster_info, report_type);

         setup_header;
         setup_footer;

         show_report_page(1);
   end;

   return; 					% show_cluster_info
   

%-------------------------------------------------------------------------
function show_report_page(page_num),
%
   report_type = getappdata(gcf,'ReportType');
   num_rows = getappdata(gcf,'NumRows');
   top_margin = getappdata(gcf,'TopMargin');
   line_height = getappdata(gcf,'LineHeight');
   cluster_info = getappdata(gcf,'ClusterInfo');
   cluster_data_idx = getappdata(gcf,'ClusterDataIdx');
   standard_text_obj = getappdata(gcf,'StandardTextObj');
   h_list = getappdata(gcf,'HdlList');

   axes_h = findobj(gcf,'Tag','ClusterReportAxes');
   axes_pos = get(axes_h,'Position');
   first_row_pos = 1 - top_margin;
   last_row_pos = first_row_pos - (num_rows-1)*line_height;

   if isempty(cluster_data_idx)
      return;
   end;

   show_page_keys(page_num);

   %  display the cluster information for the current page
   %
   start_row = num_rows * (page_num - 1) + 1;
   if (cluster_data_idx(1,start_row) == 0),	% the first row is empty
	start_row = start_row - 1;		
	num_rows = num_rows - 1;
   end;

   v_pos = [first_row_pos:-line_height:last_row_pos];

   if (report_type == 0)		% BLV value report
      h_pos = [0.06 0.18 0.28 0.44 0.71 0.88];
      h_pvalue_pos = 0;
   else					% Bootstrap ratio report
      h_pos = [0.06 0.18 0.28 0.44 0.67 0.88];
      h_pvalue_pos = 0.75;
   end;

   delete(h_list);
   h_list = [];
   last_row = min(size(cluster_data_idx,2),start_row+num_rows-1);
   for idx=start_row:last_row,

      v_idx = idx-start_row+1;
      cluster_id  = cluster_data_idx(1,idx);
      if (cluster_id ~= 0),
         cluster_lag = cluster_data_idx(2,idx);
         cluster_idx = cluster_data_idx(3,idx);
         c_data = cluster_info.data{cluster_lag};

         h = copyobj_legacy(standard_text_obj,axes_h);			% cluster # 
         cluster_num = sprintf('%3d',cluster_id);
         set(h, 'String',cluster_num, ...
		'Position',[h_pos(1) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];

         h = copyobj_legacy(standard_text_obj,axes_h);			% voxel mean
         voxel_mean_str = sprintf('%6.2f',cluster_info.voxel_means_avg(cluster_idx));
         set(h, 'String',voxel_mean_str, ...
		'Position',[h_pos(2) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];

	 h = copyobj_legacy(standard_text_obj,axes_h);			% peak xyz
         peak_xyz_str = sprintf('[%3d %3d %3d]',c_data.peak_xyz(cluster_idx,:));
	 set(h, 'String',peak_xyz_str, ...
		'Position',[h_pos(3) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];

	 h = copyobj_legacy(standard_text_obj,axes_h);			% peak loc
         peak_loc_str = sprintf('[%6.1f %6.1f %6.1f]', ...
					c_data.peak_loc(cluster_idx,:));
	 set(h, 'String',peak_loc_str, ...
		'Position',[h_pos(4) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];

	 h = copyobj_legacy(standard_text_obj,axes_h);			% peak value
         peak_value_str = sprintf('%8.4f',c_data.peak_values(cluster_idx));
	 set(h, 'String',peak_value_str, ...
		'Position',[h_pos(5) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];

	 if (h_pvalue_pos ~= 0)
	    h = copyobj_legacy(standard_text_obj,axes_h);		% P value
	    p_value = ratio2p(abs(c_data.peak_values(cluster_idx)), ...
						0,1 );
            p_value_str = sprintf('(%6.4f)',p_value);
	    set(h, 'String',p_value_str, ...
		'Position',[h_pvalue_pos v_pos(v_idx) 0], ...
		'Visible','on'); 
	    h_list = [h_list h];
         end;

	 h = copyobj_legacy(standard_text_obj,axes_h);			% cluster size
         size_str = sprintf('%4d',c_data.size(cluster_idx));
	 set(h, 'String',size_str, ...
		'Position',[h_pos(6) v_pos(v_idx) 0], ...
		'Visible','on'); 
	 h_list = [h_list h];
      end;
	
   end;

   setappdata(gcf,'CurrPage',page_num);
   setappdata(gcf,'HdlList',h_list);

   return; 					% show_report_page


%--------------------------------------------------------------------------
function  save_cluster_report()

   report_type = getappdata(gcf,'ReportType');
   cluster_info = getappdata(gcf,'ClusterInfo');

   if (report_type == 0)		% BLV value report
      cluster_info.type = 'BLV Report';
   else
      cluster_info.type = 'Bootstrap Ratio Report';
   end;

   result_name = getappdata(gcbf, 'ResultName');

   [filename, pathname] = ...
           rri_selectfile('*_PETcluster.mat','Save to .mat file');

   if ischar(filename) & (length(filename)<9 | isempty(findstr(lower(filename),'_petcluster')))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_PETcluster.mat'];
   end
   
   if isequal(filename,0)
         status = 0;
         return;
   end;
   report_file = fullfile(pathname,filename);

   try
      save (report_file, 'cluster_info', 'report_type' );
      msg = ['File ', filename, ' has been saved'];
      msgbox(msg, 'Info');
   catch
      msg = ['File ', filename, ' can not be open to write'];
      msgbox(msg, 'Error');
%      msg = sprintf('Cannot save cluster report to %s',report_file),
 %     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      status = 0;
      return;
   end;

   return; 					% save_cluster_report


%--------------------------------------------------------------------------
function  save_cluster_txt()

   [filename, pathname] = ...
           rri_selectfile('*_PETcluster.txt','Save to .txt file');

   if ischar(filename) & (length(filename)<9 | isempty(findstr(lower(filename),'_petcluster.txt')))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_PETcluster.txt'];
   end
   
   if isequal(filename,0)
         status = 0;
         return;
   end;
   report_file = fullfile(pathname,filename);

   fid = fopen(report_file, 'wt');

   if fid == -1
      msg = ['File ', filename, ' can not be open to write'];
      msgbox(msg, 'Error');
      return;
   end

   cluster_info = getappdata(gcf,'ClusterInfo');
   cluster_data_idx = getappdata(gcf, 'ClusterDataIdx');
   report_type = getappdata(gcf,'ReportType');

   str = sprintf('Clu#\tV_Mean\tX\tY\tZ\tX(mm)\tY(mm)\tZ(mm)\t');

   if report_type
      str = [str sprintf('BSR\tAppro.P\tClu_Size(voxels)\n')];
      str = [str '--------------------------------------------------------'];
      str = [str '----------------------------------------'];
   else
      str = [str sprintf('BLV\tClu_Size(voxels)\n')];
      str = [str '--------------------------------------------------------'];
      str = [str '--------------------------------'];
   end

   fprintf(fid, '\n%s\n\n', str);

   for idx = 1 : size(cluster_data_idx, 2)
      cluster_id = cluster_data_idx(1, idx);

      if cluster_id ~= 0
         cluster_lag = cluster_data_idx(2, idx);
         cluster_idx = cluster_data_idx(3, idx);
         c_data = cluster_info.data{cluster_lag};

         cluster_num = sprintf('%d\t', cluster_id);
         voxel_mean_str = ...
		sprintf('%.2f\t',cluster_info.voxel_means_avg(cluster_idx));
         peak_xyz_str = ...
		sprintf('%d\t%d\t%d\t',c_data.peak_xyz(cluster_idx,:));
         peak_loc_str = ...
		sprintf('%.1f\t%.1f\t%.1f\t',c_data.peak_loc(cluster_idx,:));
         peak_value_str = sprintf('%.4f\t',c_data.peak_values(cluster_idx));

         if report_type
            p_value = ...
		ratio2p(abs(c_data.peak_values(cluster_idx)), 0, ...
			1);
            p_value_str = sprintf('%.4f\t',p_value);
         else
            p_value_str = '';
         end

         size_str = sprintf('%d\n',c_data.size(cluster_idx));

         str = [cluster_num,voxel_mean_str,peak_xyz_str,peak_loc_str];
         str = [str peak_value_str,p_value_str,size_str];
         fprintf(fid, '%s', str);
      end
   end

   %  display the footer
   %
   source_file = cluster_info.source;
   source_line = sprintf('Source: %s',source_file);

   lv_str = sprintf('LV Idx: %d',cluster_info.lv_idx);
   thresh_str = sprintf('Pos.Thresh: %2.4f',cluster_info.threshold);
   thresh_str2 = sprintf('Neg.Thresh: %2.4f',cluster_info.threshold2);
   peak_thresh_str = sprintf('Pos.Peak Thresh: %2.4f',cluster_info.peak_thresh);
   peak_thresh_str2 = sprintf('Neg.Peak Thresh: %2.4f',cluster_info.peak_thresh2);

   min_size_str = sprintf('Min Size: %d(voxels)',cluster_info.min_size);
   min_dist_str = sprintf('Min Distance: %3.1fmm ',cluster_info.min_dist);
   parameters_line = sprintf('%s, %s, %s, %s\n%s, %s, %s', ...
				lv_str,thresh_str,thresh_str2,min_size_str,peak_thresh_str,peak_thresh_str2,min_dist_str);

   if report_type
      str = ['--------------------------------------------------------'];
      str = [str '----------------------------------------'];
      str = [str sprintf('\n%s\n%s',source_line,parameters_line)];
   else
      str = ['--------------------------------------------------------'];
      str = [str '--------------------------------'];
      str = [str sprintf('\n%s\n%s',source_line,parameters_line)];
   end

   fprintf(fid, '\n%s\n\n', str);

   fclose(fid);

   msg = ['File ', filename, ' has been saved'];
   msgbox(msg, 'Info');

   return; 					% save_cluster_txt


%--------------------------------------------------------------------------
function  save_peak_location()

   result_file = getappdata(gcbf, 'ResultName');
   cluster_info = getappdata(gcf,'ClusterInfo');

   xyz = cluster_info.data{1}.peak_xyz;
   xyz = double(xyz2xyzmm(xyz, result_file));

   [filename, pathname] = ...
           rri_selectfile('*_PETcluster_peak.txt','Export Peak Location');

   if ischar(filename) & (length(filename)<9 | isempty(findstr(lower(filename),'_petcluster_peak.txt')))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_PETcluster_peak.txt'];
   end
   
   if isequal(filename,0)
         status = 0;
         return;
   end;
   report_file = fullfile(pathname,filename);

   try
      save (report_file, '-ascii', 'xyz' );
      msg = ['File ', filename, ' has been saved'];
      msgbox(msg, 'Info');
   catch
      msg = ['File ', filename, ' can not be open to write'];
      msgbox(msg, 'Error');
%      msg = sprintf('Cannot export peak location to %s',report_file),
 %     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      status = 0;
      return;
   end;

   return; 					% save_peak_location


%--------------------------------------------------------------------------
function  save_all_location()

   result_file = getappdata(gcbf, 'ResultName');
   dims = getappdata(gcbf,'Dims');
   cluster_info = getappdata(gcf,'ClusterInfo');

   xyz = cluster_info.data{1}.idx;
   xyz = rri_coord2xyz(xyz, dims);

   cnum = cluster_info.data{1}.mask;
   for i=1:length(cluster_info.data{1}.id)
      cnum(find(cluster_info.data{1}.mask==cluster_info.data{1}.id(i)))=i; 
   end;

   coord = getappdata(gcbf,'BSRatioCoords');

   if isempty(coord)
      coord = getappdata(gcbf,'BLVCoords');
   end

   if getappdata(gcf,'ReportType')
      data = getappdata(gcbf, 'BSRatio');
   else
      data = getappdata(gcbf, 'BLVData');
   end

   data = data(:, cluster_info.lv_idx);

   coord_idx = ones(size(cluster_info.data{1}.idx));

   for i=1:length(coord_idx)
      coord_idx(i) = find(coord==cluster_info.data{1}.idx(i));
   end

   data = data(coord_idx);

   xyz = double(xyz2xyzmm(xyz, result_file));
   xyz2 = double([cnum' double(data) xyz]);

   [filename, pathname] = ...
           rri_selectfile('*_PETcluster_all.txt','Export All Location');

   if ischar(filename) & (length(filename)<9 | isempty(findstr(lower(filename),'_petcluster_all.txt')))
      [tmp filename] = fileparts(filename);
      filename = [filename, '_PETcluster_all.txt'];
   end
   
   if isequal(filename,0)
         status = 0;
         return;
   end;

   report_file = fullfile(pathname,filename);

   try
      save (report_file, '-ascii', 'xyz' );
      msg = ['File ', filename, ' has been saved'];
      msgbox(msg, 'Info');
   catch
      msg = ['File ', filename, ' can not be open to write'];
      msgbox(msg, 'Error');
%      msg = sprintf('Cannot export all location to %s',report_file),
 %     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      status = 0;
      return;
   end;

   filename2 = strrep(filename,'_PETcluster_all.txt','_PETcluster_num.txt');
   report_file2 = fullfile(pathname,filename2);

   try
      save (report_file2, '-ascii', 'xyz2' );
      msg = ['File ', filename2, ' has been saved'];
      msgbox(msg, 'Info');
   catch
      msg = ['File ', filename2, ' can not be open to write'];
      msgbox(msg, 'Error');
%      msg = sprintf('Cannot export all location to %s',report_file),
 %     set(findobj(gcf,'Tag','MessageLine'),'String',['ERROR: ', msg]);
      status = 0;
      return;
   end;

   return; 					% save_all_location


%--------------------------------------------------------------------------
function fig_h = create_report_figure(report_type)
%

   save_setting_status = 'on';
   pet_cluster_report_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(pet_cluster_report_pos) & strcmp(save_setting_status,'on')

      pos = pet_cluster_report_pos;

   else

      w = 0.9;
      h = 0.85;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   if isequal(get(gcbf,'Tag'),'ClusterReportFigure'),
       fig_h = gcbf;
       setappdata(gcf,'HdlList',[]);
       clf(fig_h);
   else
       fig_h = figure('Color',[0.8 0.8 0.8], ...
  	  'Units','normal', ...
	  'Name','PLS Active Clusters Report', ...
	  'NumberTitle', 'off', ...
   	  'DoubleBuffer','on', ...
   	  'MenuBar','none',...
   	  'Position',pos, ...
          'DeleteFcn','pet_cluster_report(''delete_fig'');', ...
	  'PaperPositionMode','auto', ...
   	  'Tag','ClusterReportFigure', ...
   	  'ToolBar','none');
   end;

   w = 0.94;
   h = 0.94;
   x = (1-w)/2;
   y = (1-h)/2;

   pos = [x y w h];

   axes_h = axes('Parent',fig_h, ...
        'Units','normal', ...
        'Box','on', ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',[1 1 1], ...
  	'Position',pos, ...
   	'XTick', [], ...
   	'XLim', [0 1], ...
   	'YTick', [], ...
   	'YLim', [0 1], ...
   	'Tag','ClusterReportAxes');
	
   standard_text = text('Fontname','courier', ...
	'FontWeight','Normal', ...
	'FontAngle','Normal', ...
	'FontUnit','point', ...
	'FontSize',10, ...
	'Units','normal', ...
	'Color',[0 0 0], ...
	'Visible','off','Interpreter','none');

   %  File submenu
   %
   h_file = uimenu('Parent',fig_h, ...
   	   'Label','&File', ...
   	   'Tag','FileMenu', ...
   	   'Visible','on');
   h2 = uimenu(h_file, ...
           'Label','&Load', ...
   	   'Tag','MenuLoad', ...
   	   'Visible','off', ...
           'Callback','pet_cluster_report(''LoadClusterReport'');'); 
   h2 = uimenu(h_file, ...
           'Label','Save to .mat file', ...
   	   'Tag','MenuSave', ...
           'Callback','pet_cluster_report(''SaveClusterReport'');'); 
   h2 = uimenu(h_file, ...
           'Label','Save to .txt file', ...
   	   'Tag','MenuSaveTxt', ...
           'Callback','pet_cluster_report(''SaveClusterTXT'');'); 
   h2 = uimenu(h_file, ...
           'Label','Export All Location', ...
   	   'Tag','MenuSaveAllLocation', ...
           'Callback','pet_cluster_report(''SaveAllLocation'');'); 
   h2 = uimenu(h_file, ...
           'Label','Export Peak Location', ...
   	   'Tag','MenuSavePeakLocation', ...
           'Callback','pet_cluster_report(''SavePeakLocation'');'); 
   h2 = uimenu(h_file, ...
	   'Separator', 'on', ...
           'Label','&Print...', ...
   	   'Tag','MenuPrint', ...
	'visible', 'off', ...
           'Callback','printdlg'); 
   h2 = uimenu(h_file, ...
           'Label','Print Pre&view...', ...
   	   'Tag','MenuPrintPreview', ...
	'visible', 'off', ...
           'Callback','printpreview(gcbf)'); 
   h2 = uimenu(h_file, ...
           'Label','Print Set&up...', ...
   	   'Tag','MenuPrintSetup', ...
	'visible', 'off', ...
           'Callback','filemenufcn(gcbf,''FilePrintSetup'')'); 
   h2 = uimenu(h_file, ...
           'Label','Pa&ge Setup...', ...
   	   'Tag','MenuPageSetup', ...
	'visible', 'off', ...
           'Callback','pagesetupdlg(gcbf)'); 

   rri_file_menu(fig_h);

   setappdata(gcf,'ResultName', get(gcbf,'name'));
   setappdata(gcf,'LineHeight', 0.03);
   setappdata(gcf,'TopMargin', 0.14);
   setappdata(gcf,'BottomMargin', 0.11);
   setappdata(gcf,'StandardTextObj', standard_text);
   setappdata(gcf,'ReportType', report_type);

   return; 					% create_figure;


%--------------------------------------------------------------------------
function setup_header();

   standard_text_obj = getappdata(gcf,'StandardTextObj');
   report_type = getappdata(gcf,'ReportType');

   axes_h = findobj(gcf,'Tag','ClusterReportAxes');
   axes_pos = get(axes_h,'Position');
   total_height = 1;

   header_text = { ...   % {label, [x y z], type}, where y is counted from top
	{ 'Cluster #',  	     [0.05 0.08 0], -1 }, ...
	{ 'Voxel Mean',	    	     [0.17 0.08 0], -1 }, ...
	{ 'Peak Location',  	     [0.39 0.05 0], -1 }, ...
	{ 'XYZ',		     [0.33 0.08 0], -1 }, ...
	{ 'XYZ(mm)',		     [0.52 0.08 0], -1 }, ...
	{ 'Brain LV',		     [0.71 0.05 0],  0 }, ...
	{ 'Value',	     	     [0.73 0.08 0],  0 }, ...
	{ 'Bootstrap',		     [0.71 0.05 0],  1 }, ...
	{ 'Ratio',	     	     [0.69 0.08 0],  1 }, ...
	{ 'Appro.P',	     	     [0.76 0.08 0],  1 }, ...
	{ 'Cluster Size',	     [0.85 0.05 0], -1 }, ...
	{ '(voxels)',    	     [0.87 0.08 0], -1 }};

   str_field = 1; pos_field = 2; type_field = 3;
   for i=1:length(header_text),
     if (header_text{i}{type_field}<0 | report_type==header_text{i}{type_field})
 	 h = copyobj_legacy(standard_text_obj,axes_h);
	 text_pos = header_text{i}{pos_field}; 
	 text_pos(2) = total_height - text_pos(2);    % text pos=[x height-y z]
	 set(h,'String', header_text{i}{str_field},  ...
	       'Position', text_pos, ...
	       'Visible','on');
     end;
   end;

   % line is located at the 0.08 from top
   % 
   y_pos = 1 -  0.11;
   line_hdl = line( ...
	'XData', [0.040 0.960], ...
	'YData', [y_pos y_pos], ...
	'LineStyle', '-', ...	
	'LineWidth', 1, ...	
	'Color', [0 0 0], ...
	'Marker', 'none');

   return; 					% setup_header;


%--------------------------------------------------------------------------
function setup_footer(),

   axes_h = findobj(gcf,'Tag','ClusterReportAxes');
   standard_text_obj = getappdata(gcf,'StandardTextObj');
   cluster_info = getappdata(gcf,'ClusterInfo');

   key_text = { ...
	{ '<<prev.',  	     [0.80 0.06 0], 'PrevPage'}, ...
	{ 'next>>',	     [0.90 0.06 0], 'NextPage'}};

   str_field = 1; pos_field = 2; tag_field = 3; 
   for i=1:length(key_text),
      h = copyobj_legacy(standard_text_obj,axes_h);
      bd_fn = sprintf('pet_cluster_report(''%s'');',key_text{i}{tag_field});
      set(h,'String', key_text{i}{str_field},  ...
	    'Position',key_text{i}{pos_field}, ...
	    'ButtonDownFcn',bd_fn, ...
	    'Tag',key_text{i}{tag_field}, ...
	    'Visible','off');
   end;


   %  display the footer
   %
   source_file = cluster_info.source;
   len_str = length(source_file);
   if (len_str > 80) 
	source_file = [ '...' source_file(len_str-76:end)];
   end;

   source_line = sprintf('Source: %s',source_file);

   h = copyobj_legacy(standard_text_obj,axes_h);

   x = 0.03;
   y = 0.08;

   pos = [x y 0];

   set(h,'String', source_line, ...
	 'Interpreter','none', ...
         'Fontname','courier', ...
         'FontWeight','Normal', ...
         'FontAngle','Normal', ...
         'FontUnit','point', ...
         'FontSize',10, ...
         'Position',pos, ...
         'Visible','on');

   lv_str = sprintf('LV Idx: %d',cluster_info.lv_idx);
   thresh_str = sprintf('Pos.Thresh: %2.4f',cluster_info.threshold);
   thresh_str2 = sprintf('Neg.Thresh: %2.4f',cluster_info.threshold2);

   peak_thresh_str = sprintf('Pos.Peak Thresh: %2.4f',cluster_info.peak_thresh);
   peak_thresh_str2 = sprintf('Neg.Peak Thresh: %2.4f',cluster_info.peak_thresh2);

   min_size_str = sprintf('Min Size: %d(voxels)', ...
						cluster_info.min_size);
   min_dist_str = sprintf('Min Distance: %3.1fmm ', ...
						cluster_info.min_dist);
   parameters_line = sprintf('%s, %s, %s, %s\n%s, %s, %s', ...
				lv_str,thresh_str,thresh_str2,min_size_str,peak_thresh_str,peak_thresh_str2,min_dist_str);

   h = copyobj_legacy(standard_text_obj,axes_h);

   y = 0.05;

   pos = [x y 0];

   set(h,'String', parameters_line, ...
	 'Position',pos, ...
         'Fontname','courier', ...
         'FontWeight','Normal', ...
         'FontAngle','Normal', ...
         'FontUnit','point', ...
         'FontSize',10, ...
	 'Visible','on');

   return; 					% setup_footer;


%--------------------------------------------------------------------------
function show_page_keys(page_num),

   total_pages = getappdata(gcf,'TotalPages');

   h = findobj(gcf,'Tag','PrevPage');
   if (page_num ~= 1),
	set(h,'Visible','on');
   else
	set(h,'Visible','off');
   end;

   h = findobj(gcf,'Tag','NextPage');
   if (page_num ~= total_pages)
	set(h,'Visible','on');
   else
	set(h,'Visible','off');
   end;


   return; 					% show_page_keys;


%--------------------------------------------------------------------------
function setup_cluster_data_idx(cluster_info, is_bs)
%
   standard_text_obj = getappdata(gcf,'StandardTextObj');
   line_height = getappdata(gcf,'LineHeight');
   top_margin = getappdata(gcf,'TopMargin');
   bottom_margin = getappdata(gcf,'BottomMargin');

   axes_h = findobj(gcf,'Tag','ClusterReportAxes');
   axes_pos = get(axes_h,'Position');
   total_height = 1;
   num_rows = floor((total_height - top_margin - bottom_margin) / line_height);

   lag_idx = [];
   cluster_id = [];
   cluster_idx = [];
   start_cluster_id = 1;
   cluster_data = cluster_info.data;
   for i=1:length(cluster_data),
      num_clusters = length(cluster_data{i}.id);
      if (num_clusters ~= 0)
         lag_idx = [lag_idx repmat(i,1,num_clusters+1)];
         cluster_idx = [cluster_idx [1:num_clusters 0]];

         last_cluster_id = start_cluster_id+num_clusters-1;
         cluster_id = [cluster_id [start_cluster_id:last_cluster_id 0]];
         start_cluster_id = last_cluster_id+1;
      end;
   end;
   cluster_data_idx = [cluster_id; lag_idx; cluster_idx];
   cluster_data_idx = cluster_data_idx(:,1:end-1);

   total_clusters = size(cluster_data_idx,2);
   total_pages = ceil(total_clusters / num_rows);

   setappdata(gcf,'ClusterInfo',cluster_info);
   setappdata(gcf,'ClusterDataIdx',cluster_data_idx);
   setappdata(gcf,'TotalPages',total_pages);
   setappdata(gcf,'NumRows',num_rows);

   result_file = cluster_info.source;
   [p f] = rri_fileparts(result_file);
   load(f);

   if exist('result','var')
      if isfield(result,'boot_result')
         boot_result = result.boot_result;
         boot_result.compare = boot_result.compare_u;
      else
         boot_result = [];
      end

      brainlv = result.u * diag(result.s);
   else
      brainlv = brainlv * diag(s);
   end

   if (~is_bs)
      data = brainlv;
      setappdata(gcf,'BLVData',data);
   else
      data = boot_result.compare;
      setappdata(gcf,'BSRatio',data);
   end

   setappdata(gcf,'ResultName',f);
   setappdata(gcf,'Dims',dims);
   setappdata(gcf,'BSRatioCoords',newcoords);
   setappdata(gcf,'BLVCoords',newcoords);
   setappdata(gcf,'WinSize',1);

   return; 					% setup_page_rows


%--------------------------------------------------------------------------
function  p_value = ratio2p(x,mu,sigma)

   p_value = (1 + erf((x - mu) / (sqrt(2)*sigma))) / 2;
   p_value = (1 - p_value) * 2;

   return; 						% ratio2p


%----------------------------------------------------------------------------
function delete_fig

    link_figure = getappdata(gcbf,'LinkFigureInfo');

    try
       rmappdata(link_figure.hdl,link_figure.name);
    end;

    try
       load('pls_profile');
       pls_profile = which('pls_profile.mat');

       pet_cluster_report_pos = get(gcbf,'position');

       save(pls_profile, '-append', 'pet_cluster_report_pos');
    catch
    end

   return;

