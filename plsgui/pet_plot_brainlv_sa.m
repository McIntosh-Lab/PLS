function pet_plot_brainlv_sa(ViewBootstrapRatio, PLSresultFile, ...
	grp_idx, lv_idx, new_fig, behav_idx, sa, cluster_info, update, isstruct)

    if ~exist('isstruct','var')
       isstruct = 0;
    end

    if (new_fig)
        bg_img = getappdata(gcbf,'BackgroundImg');
        rot_amount = getappdata(gcbf,'RotateAmount');
        if (ViewBootstrapRatio)
           blv = getappdata(gcbf,'BSRatio');
	else
           blv = getappdata(gcbf,'BLVData');
	end
    else
        bg_img = getappdata(gcf,'BackgroundImg');
        rot_amount = getappdata(gcf,'RotateAmount');
        if (ViewBootstrapRatio)
           blv = getappdata(gcf,'BSRatio');
	else
           blv = getappdata(gcf,'BLVData');
	end
    end

    if ~isempty(behav_idx)			% called from datamatcorrs plot
        blv = blv{grp_idx, behav_idx};
    end

    if isempty(bg_img)
       no_background_image = 1;
    else
       no_background_image = 0;
    end

%    load('pet_map');				% newcolor: just commented


    load(PLSresultFile);

    if exist('result','var')
        s = result.s;
    end

    if ~isempty(behav_idx)
        num_behav = length(behavname);
    end


if 0
    if ~isempty(behav_idx)			% called from datamatcorrs plot

        load(PLSresultFile,'num_cond_lst','dims','newcoords','s','voxel_size','origin','behavname');
        num_behav = length(behavname);

    else
        load(PLSresultFile,'num_cond_lst','dims','newcoords','s','voxel_size','origin');
    end
end

    if sa
       dims_sa = dims([2,4,3,1]);
       voxel_size = voxel_size([2,3,1]);
       origin = origin([2,3,1]);
    else
       dims_sa = dims([1,4,3,2]);
       voxel_size = voxel_size([1,3,2]);
       origin = origin([1,3,2]);
    end

    num_conditions = num_cond_lst(1);

%    slice_idx = [2:5:65];
    slice_idx = [1:dims_sa(4)];
    num_slices = length(slice_idx);
    slices = dims_sa(4);

    if grp_idx
       num_lv = num_conditions;
    else
       num_lv = size(blv,2);
    end

    brainlv = blv(:,lv_idx);

    if (ViewBootstrapRatio)
       h = findobj(gcf,'Tag','BSThreshold'); thresh = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','BSThreshold2'); thresh2 = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MaxRatio'); max_blv = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MinRatio'); min_blv = str2num(get(h,'String'));
    else
       h = findobj(gcf,'Tag','Threshold'); thresh = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','Threshold2'); thresh2 = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MaxValue'); max_blv = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MinValue'); min_blv = str2num(get(h,'String'));
    end

    too_large = find(brainlv > max_blv); brainlv(too_large) = max_blv;
    too_small = find(brainlv < min_blv); brainlv(too_small) = min_blv;

    if mod(rot_amount,2)
        img_height = dims_sa(2);		% rows - after 90 or 270 rotation
        img_width  = dims_sa(1);		% by default, 90 rotation
    else
        img_height = dims_sa(1);		% rows
        img_width  = dims_sa(2);
    end

    %  display the images
    %
    if (new_fig)
        [axes_hdl,colorbar_hdl] = pet_create_newblv_ui;
    else
        axes_hdl = getappdata(gcf,'BlvAxes');
        colorbar_hdl = getappdata(gcf,'Colorbar');	% newcolor: was commented
    end

    axes(axes_hdl);

    rows = dims_sa(1);
    cols = dims_sa(2);
    slices = dims_sa(4);

    % create the appropriate colormap
    %
    % cmap = set_colormap(max_blv, min_blv, thresh, thresh2);
   
    bg_values = [1 1 1];
    num_blv_colors = 25;
    brain_region_color_idx = 51;
    first_lower_color_idx = 101;
    first_upper_color_idx = 126;

    % set up the colormap for the background 
    %
    bg_brain_values = [0.54 0.54 0.54];
    if (no_background_image),
       bg_cmap = ones(100,1)*bg_brain_values;	% the brain regions
    else
       bg_cmap = bone(140);
       bg_cmap = bg_cmap(1:100,:);
    end;


    %  colormap entries
    %     	 1 - 100    : for the brain regions (background) image
    %           101 - 125    : for the negative blv values below threshold
    %           126 - 150    : for the positive blv values above threshold
    %     	  151       : for the non-brain regions

    cmap = zeros(151,3);
    jetmap = jet(64);
    cmap(1:100,:) = bg_cmap;			% the brain regions
    cmap(101:125,:) = jetmap([1:25],:);		% the negative blv values
    cmap(126:150,:) = jetmap([36:60],:);	% the positive blv values
    cmap(end,:) = bg_values;			% the nonbrain regions


    %  set up the colormap for the display colorbar
    %
    cbar_size = 100;
    cbar_map = ones(cbar_size,1) * bg_brain_values; 
    cbar_step = (max_blv - min_blv) / cbar_size;

    %  prevent_num_lower_color_0
    %
    if 0 % (abs(min_blv) - thresh) < cbar_step & (abs(min_blv) - thresh) ~= 0
        cbar_size = ceil((max_blv - min_blv) / (abs(min_blv) - thresh));
        cbar_map = ones(cbar_size,1) * bg_brain_values;
        cbar_step = (max_blv - min_blv) / cbar_size;
    end
    if 0 % (abs(max_blv) - thresh) < cbar_step & (abs(max_blv) - thresh) ~= 0
        cbar_size = ceil((max_blv - min_blv) / (abs(max_blv) - thresh));
        cbar_map = ones(cbar_size,1) * bg_brain_values;
        cbar_step = (max_blv - min_blv) / cbar_size;
    end

  if cbar_step ~= 0
%    num_lower_color = round((abs(min_blv) - thresh) / cbar_step);

      if max_blv > thresh2 % -abs(thresh)
         num_lower_color = round((thresh2 - min_blv) / cbar_step);
      else
         num_lower_color = round((max_blv - min_blv) / cbar_step);
      end

    if round(64 / 25 * num_lower_color) > 0
       jetmap = jet(round(64 / 25 * num_lower_color));
       cbar_map(1:num_lower_color,:) = jetmap(1:num_lower_color,:);	
    end

%    num_upper_color = round((max_blv - thresh) / cbar_step);

      if min_blv < thresh % abs(thresh)
         num_upper_color = round((max_blv - thresh) / cbar_step);
      else
         num_upper_color = round((max_blv - min_blv) / cbar_step);
      end

    if round(64 / 25 * num_upper_color) > 0
       jetmap = jet(round(64 / 25 * num_upper_color));
       first_jet_color = round((36 / 64) * size(jetmap,1));
       jet_range = [first_jet_color:first_jet_color+num_upper_color-1];
       cbar_map(end-num_upper_color+1:end,:) = jetmap(jet_range,:);
    end

    % Create the image slices in which voxels are set to be within certain range
    %
%    lower_interval = (abs(min_blv) - thresh) / (num_blv_colors-1);
 %   upper_interval = (max_blv - thresh) / (num_blv_colors-1);

      if max_blv > thresh2 % -abs(thresh)
         lower_interval = (thresh2 - min_blv) / (num_blv_colors-1);
      else
         lower_interval = (max_blv - min_blv) / (num_blv_colors-1);
      end

      if min_blv < thresh % abs(thresh)
         upper_interval = (max_blv - thresh) / (num_blv_colors-1);
      else
         upper_interval = (max_blv - min_blv) / (num_blv_colors-1);
      end

    disp_blv = zeros(1,length(newcoords)) + brain_region_color_idx;
    lower_idx = find(brainlv < thresh2);
    blv_offset = brainlv(lower_idx) - min_blv; 

    if lower_interval ~=0
       lower_color_idx = round(blv_offset/lower_interval)+first_lower_color_idx;
    else
       lower_color_idx = ones(size(blv_offset)) * first_lower_color_idx;
    end

    disp_blv(lower_idx) = lower_color_idx;

    upper_idx = find(brainlv > thresh);
    blv_offset = max_blv - brainlv(upper_idx); 

    if upper_interval ~=0
       upper_color_idx = num_blv_colors - round(blv_offset/upper_interval);
    else
       upper_color_idx = num_blv_colors * ones(size(blv_offset));
    end

    upper_color_idx = upper_color_idx + first_upper_color_idx - 1;
    disp_blv(upper_idx) = upper_color_idx;
  else
      disp_blv = zeros(1,length(newcoords)) + brain_region_color_idx;

      if abs(min_blv) < 1e-6
         max_blv = min_blv + eps;
      else
         max_blv = min_blv + abs(min_blv)*1e-9;
      end
  end

    % get non_cluster_coords
    %
    if isempty(cluster_info)
       cluster_idx = newcoords;
    else
       cluster_idx = cluster_info.data{1}.idx;
    end

    if isequal(newcoords, cluster_idx)
       non_cluster_coords = [];
    else
       [tmp cluster_coords] = intersect(newcoords,cluster_idx);
       non_cluster_coords = ones(1,length(newcoords));
       non_cluster_coords(cluster_coords) = 0;
       non_cluster_coords = find(non_cluster_coords);
    end

    if (no_background_image),
       non_brain_region_color_idx = size(cmap,1);
       img = zeros(1,rows*cols*slices) + non_brain_region_color_idx;

       disp_blv(non_cluster_coords) = brain_region_color_idx;

       img(newcoords) = disp_blv;
       img = reshape(img,[dims(1) dims(2) 1 dims(4)]);
    else
       max_bg = max(bg_img(:));
       min_bg = min(bg_img(:));
       img = (bg_img - min_bg) / (max_bg - min_bg) * 100;

       disp_blv(non_cluster_coords) = img(newcoords(non_cluster_coords));

       if exist('lower_idx','var') & ~isempty(lower_idx)
          img(newcoords(lower_idx)) = disp_blv(lower_idx);
       end

       if exist('upper_idx','var') & ~isempty(upper_idx)
          img(newcoords(upper_idx)) = disp_blv(upper_idx);
       end
    end;

    % convert image to sagittal view
    %
    img = rri_axial2other(img,sa);

    blv = reshape(img,[rows*cols,slices]);
    disp_blv = ones(rows*cols, num_slices);

    %  rotate image
    %
    for i=1:num_slices
        tmp=reshape(blv(:,slice_idx(i)),img_width,img_height);
        tmp=rot90(tmp,mod(rot_amount,4));
        disp_blv(:,i)=tmp(:);
    end

    % save a cornor of the last slice as the background intensity
    %
    bg_intensity = disp_blv(1, num_slices);

    %  calculate how many slices to display for each row and column
    %  it's an algorithm from montage which will layout the slice
    %  in near square
    %
    if dims_sa(1) < dims_sa(2)
        siz = [dims_sa(1), dims_sa(2), num_slices];
    else
        siz = [dims_sa(2), dims_sa(1), num_slices];
    end

    cols_disp = sqrt(prod(siz))/siz(2);
    rows_disp = siz(3)/cols_disp;
    if (ceil(cols_disp)-cols_disp) < (ceil(rows_disp)-rows_disp),
        cols_disp = ceil(cols_disp); rows_disp = ceil(siz(3)/cols_disp);
    else
        rows_disp = ceil(rows_disp); cols_disp = ceil(siz(3)/rows_disp);
    end

    max_slice = rows_disp * cols_disp;
    rest_slices = max_slice - num_slices;
    empty_slices = -1 * ones(1,rest_slices);
    slice_idx = [slice_idx, empty_slices];

    % for empty slice (27-30), filled them with background intensity
    %
    blv_filled = [disp_blv, ...
	bg_intensity * ...
	ones(img_height*img_width,rows_disp*cols_disp-num_slices)];

    blv_disp = [];
    for(row = 0:rows_disp-1)

        % take 'cols_disp' amount of slices from blv_filled
        % and put into blv_row
        %
        blv_row = blv_filled(:,[row*cols_disp+1:row*cols_disp+cols_disp]);

        % reshape the slice to integrate the whole row together
        %
        blv_row = reshape(blv_row, [img_height, img_width*cols_disp]);

        blv_disp = [blv_disp; blv_row];

    end

    blv_disp = reshape(blv_disp, [rows_disp*img_height, cols_disp*img_width]);

%%    h_img = image(blv_disp,'CDataMapping','scaled');
%    h_img = image(blv_disp);

    if update
       h_img = findobj(gcf,'tag','BLVImg');
       set(h_img,'CData',blv_disp);
    else
    h_img = image(blv_disp);
    end

    set(h_img,'Tag','BLVImg');
    colormap(cmap);

    %  set up axis label
    %
    num_plus = repmat({'+ '},1,rows_disp);

    y_label = 1 : 1*cols_disp : cols_disp*rows_disp;
    for i = 1:rows_disp
        num_plus{i} = [num2str(y_label(i)-1) num_plus{i}];
    end

    set(gca,'tickdir','out','ticklength',[0.001 0.001]);
    set(gca,'xtick',[img_width/2:img_width:img_width*cols_disp]);
    set(gca,'xticklabel',[1: 1: 1*(cols_disp)]);
    set(gca,'ytick',[img_height/2:img_height:img_height*rows_disp]);
    set(gca,'yticklabel',num_plus);

    if (new_fig)
        create_colorbar(colorbar_hdl, cbar_map, min_blv, max_blv);
        return;
    end


if (0)		% if 0,  newcolor:  above block were vintage approach


    blv = brainlv';
    blv = unmapblv(blv,newcoords,prod(dims));	% make no_data voxel 0

    %  reshape blv to make each slice 1 column for 26 columns
    %
    blv = reshape(blv, img_height*img_width, num_slices);

    %  Overlay matrix 'blv' onto MRI template
    %
    template_file = getappdata(gcf,'template_file');

    if isempty(template_file)
       if no_background_image
            if isequal(dims, [65,87,1,26])
                template_file = 'pet_template';
                load(template_file);
            else
                pet_template = zeros(dims);
                pet_template(newcoords) = 150;
                pet_template = reshape(pet_template, ...
					[dims(1)*dims(2),dims(4)]);
            end
        else
            bg_img = reshape(bg_img, [dims(1)*dims(2),dims(4)]);
            pet_template = bg_img;
        end
    else
        load(template_file);
    end;

    %  Apply pet_template (where: max=203, min=9)
    %  so, the extreme range of temp could be: [-91, 458]
    %
    temp = pet_template + (blv>thresh)*255 + (blv<(thresh*(-1)))*(-100);

    %  rotate image
    %
    for i=1:num_slices
        tmp=reshape(temp(:,i),img_width,img_height);
        tmp=rot90(tmp,mod(rot_amount,4));
        blv(:,i)=tmp(:);
    end

    % save a cornor of the last slice as the background intensity
    %
    bg_intensity = blv(1, num_slices);

    %  calculate how many slices to display for each row and column
    %  it's an algorithm from montage which will layout the slice
    %  in near square
    %
    if dims(1) > dims(2)
        siz = [dims(1), dims(2), dims(4)];
    else
        siz = [dims(2), dims(1), dims(4)];
    end

    cols_disp = sqrt(prod(siz))/siz(2);
    rows_disp = siz(3)/cols_disp;
    if (ceil(cols_disp)-cols_disp) < (ceil(rows_disp)-rows_disp),
        cols_disp = ceil(cols_disp); rows_disp = ceil(siz(3)/cols_disp);
    else
        rows_disp = ceil(rows_disp); cols_disp = ceil(siz(3)/rows_disp);
    end

    max_slice = rows_disp * cols_disp;
    rest_slices = max_slice - num_slices;
    empty_slices = -1 * ones(1,rest_slices);
    slice_idx = [slice_idx, empty_slices];

    % for empty slice (27-30), filled them with background intensity
    %
    blv_filled = [blv, ...
	bg_intensity * ...
	ones(img_height*img_width,rows_disp*cols_disp-num_slices)];

    blv_disp = [];
    for(row = 0:rows_disp-1)

        % take 'cols_disp' amount of slices from blv_filled
        % and put into blv_row
        %
        blv_row = blv_filled(:,[row*cols_disp+1:row*cols_disp+cols_disp]);

        % reshape the slice to integrate the whole row together
        %
        blv_row = reshape(blv_row, [img_height, img_width*cols_disp]);

        blv_disp = [blv_disp; blv_row];

    end

    blv_disp = reshape(blv_disp, [rows_disp*img_height, cols_disp*img_width]);


    h_img = image(blv_disp,'CDataMapping','scaled');
    set(h_img,'Tag','BLVImg');
    colormap(map);

    num_plus = repmat({'+ '},1,rows_disp);
    for i = 0:rows_disp-1
        num_plus{i+1} = [num2str(i*cols_disp) num_plus{i+1}];
    end

    set(gca,'tickdir','out','ticklength',[0.001 0.001]);
    set(gca,'xtick',[img_width/2:img_width:img_width*cols_disp]);
    set(gca,'xticklabel',[1:cols_disp]);
    set(gca,'ytick',[img_height/2:img_height:img_height*rows_disp]);
    set(gca,'yticklabel',num_plus);

    if (new_fig)
%        create_colorbar(colorbar_hdl, map, min_blv, max_blv);
        return;
    end


end		% if 0,  newcolor:  above block were vintage approach


    if grp_idx				% called from datamatcorrs plot
       if isstruct
          set(h_img,'ButtonDownFcn','struct_plot_datamatcorrs(''SelectPixel'')');
       else
          set(h_img,'ButtonDownFcn','pet_plot_datamatcorrs(''SelectPixel'')');
       end
    else
       if isstruct
          set(h_img,'ButtonDownFcn','struct_result_sa_ui(''SelectPixel'')');
       else
          set(h_img,'ButtonDownFcn','pet_result_sa_ui(''SelectPixel'')');
       end
    end

    create_colorbar( colorbar_hdl, cbar_map, min_blv, max_blv ); % newcolor: was commented


    %  save the attributes of the current image
    %
    setappdata(gcf,'Dims',dims);
    setappdata(gcf,'VoxelSize',voxel_size);
    setappdata(gcf,'Origin',origin);
    setappdata(gcf,'SliceIdx',slice_idx);
    setappdata(gcf,'ImgHeight',img_height);
    setappdata(gcf,'ImgWidth',img_width);
    setappdata(gcf,'RowsDisp',rows_disp);
    setappdata(gcf,'ColsDisp',cols_disp);
    setappdata(gcf,'ImgRotateFlg',1);
    setappdata(gcf,'NumLVs',num_lv);
%    setappdata(gcf,'BLVData',brainlv);
    setappdata(gcf,'BLVCoords',newcoords);
    setappdata(gcf,'BLVThreshold',thresh);
    setappdata(gcf,'BLVThreshold2',thresh2);
    setappdata(gcf,'RotateAmount',rot_amount);
    setappdata(gcf,'BLVDisplay',disp_blv);

    %  in order to use function like 'cluster' etc. created by fMRI
    %
    setappdata(gcf,'STDims',dims);
    setappdata(gcf,'STVoxelSize',voxel_size);
    setappdata(gcf,'STOrigin',origin);
    setappdata(gcf,'WinSize',1);

    if ViewBootstrapRatio
        setappdata(gcf,'BSThreshold',thresh);
        setappdata(gcf,'BSThreshold2',thresh2);
        setappdata(gcf,'BSRatioCoords',newcoords);
    end

    if ~isempty(behav_idx)			% called from datamatcorrs plot
        setappdata(gcf,'NumBehav',num_behav);
    end

    %  save background to img
    %
    setappdata(gcf,'cmap',cmap);

    return;					%  pet_plot_brainlv_sa


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Convert the indexed matrix back into the original matrix
%
%   Usage [outmat]=unmapblv(inmat, coords, siz)
%
%   I (inmat): indexed matrix
%   I (coords): index
%   I (siz): size of original matrix
%   O (outmat): original matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outmat] = unmapblv(inmat, coords, siz)

    [r c]=size(inmat);
    outmat=zeros(r,siz);

    for i=1:r;
        outmat(i,coords)=inmat(i,:);
    end

    return;					% unmapblv


%  adopted from bfm
%
%--------------------------------------------------------------------------
function [range, bar_data] = create_colorbar(axes_hdl,cmap,min_range,max_range)

   tick_steps = (max_range - min_range) / (size(cmap,1) - 1);
   y_range = [min_range:tick_steps:max_range];
   range = [max_range:-tick_steps:min_range];
   
   axes(axes_hdl);
   img_h = image([0,1],[min_range max_range],[1:size(cmap,1)]');

   %  use true colour for the colour bar to make sure change of colormap
   %  won't affect it
   %
   bar_data = get(img_h,'CData');
   len = length(bar_data);
   cdata = zeros(len,1,3);
   for i=1:len,
     cdata(i,1,:) = cmap(bar_data(i),:);
   end;
   set(img_h,'CData',cdata);

   %  setup the axes property
%   set(axes_hdl, 'XTick',[],'XLim',[0 1], ...
%            'YLim',[min_range max_range], ...
%	    'YDir','normal', ...
%            'YAxisLocation','right');
   set(axes_hdl, 'XTick',[], ...
            'YLim',[min_range max_range], ...
	    'YDir','normal', ...
            'YAxisLocation','right');

   return;

