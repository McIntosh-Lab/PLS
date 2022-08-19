function smallfc_plot_brainlv(ViewBootstrapRatio, PLSresultFile, ...
	grp_idx, lv_idx, new_fig, behav_idx, cluster_info, update, lag_idx)

    if ViewBootstrapRatio == 1
       blv = getappdata(gcf,'BSRatio');
    elseif ViewBootstrapRatio == 2
       blv = getappdata(gcf,'BLVData');
       bs = getappdata(gcf,'BSRatio');
    elseif ViewBootstrapRatio == 0
       blv = getappdata(gcf,'BLVData');
    end

    if ~isempty(behav_idx)			% called from datamatcorrs plot
	if behav_idx < 0
	        blv = blv{grp_idx, 1};
	else
	        blv = blv{grp_idx, behav_idx};
	end
    end

    no_background_image = 1;

    if ~isempty(behav_idx)			% called from datamatcorrs plot

	if behav_idx < 0
	        load(PLSresultFile,'num_cond_lst','dims');
		num_behav = 1;
	else
        	load(PLSresultFile,'num_cond_lst','dims','behavname');
	        num_behav = length(behavname);
	end

    else
        load(PLSresultFile,'num_cond_lst','dims');
    end

    num_conditions = num_cond_lst(1);

    if grp_idx
       num_lv = num_conditions;
    else
       num_lv = size(blv,2);
    end

    brainlv = blv(:,lv_idx);

    brainlv = reshape(brainlv, dims);
    brainlv = brainlv(:,:, lag_idx);

    if ViewBootstrapRatio == 1
       h = findobj(gcf,'Tag','BSThreshold'); thresh = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','BSThreshold2'); thresh2 = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MaxRatio'); max_blv = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MinRatio'); min_blv = str2num(get(h,'String'));
    elseif ViewBootstrapRatio == 2

	if behav_idx < 0
		thresh = 0;
		thresh2 = 0;
		max_blv = max(brainlv(:));
		min_blv = min(brainlv(:));
	else

       h = findobj(gcf,'Tag','Threshold'); thresh = abs(str2num(get(h,'String')));
						thresh2 = -thresh;
       h = findobj(gcf,'Tag','MaxValue'); max_blv = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MinValue'); min_blv = str2num(get(h,'String'));

       h = findobj(gcf,'Tag','BSLVIndexEdit'); bs_lv_idx = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','BSThreshold'); bs_thresh = abs(str2num(get(h,'String')));
						bs_thresh2 = -bs_thresh;

       bs = bs(:, bs_lv_idx);
       bs_strong = zeros(size(bs));
       bs_idx = [find(bs < bs_thresh2); find(bs > bs_thresh)];
       bs_strong(bs_idx) = 1;
       brainlv = brainlv .* bs_strong;

	end

    elseif ViewBootstrapRatio == 0
       h = findobj(gcf,'Tag','Threshold'); thresh = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','Threshold2'); if isempty(h), thresh2 = -thresh; 
       else, thresh2 = str2num(get(h,'String')); end;
       h = findobj(gcf,'Tag','MaxValue'); max_blv = str2num(get(h,'String'));
       h = findobj(gcf,'Tag','MinValue'); min_blv = str2num(get(h,'String'));
    end

    too_large = find(brainlv > max_blv); brainlv(too_large) = max_blv;
    too_small = find(brainlv < min_blv); brainlv(too_small) = min_blv;

    %  display the images
    %
    if (new_fig)
        [axes_hdl,colorbar_hdl] = smallfc_create_newblv_ui;
    else
        axes_hdl = getappdata(gcf,'BlvAxes');
        colorbar_hdl = getappdata(gcf,'Colorbar');	% newcolor: was commented
    end

    axes(axes_hdl);
   
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
%       num_lower_color = round((abs(min_blv) - thresh) / cbar_step);

      if max_blv > thresh2 % -abs(thresh)
         num_lower_color = round((thresh2 - min_blv) / cbar_step);
      else
         num_lower_color = round((max_blv - min_blv) / cbar_step);
      end

       if round(64 / 25 * num_lower_color) > 0
          jetmap = jet(round(64 / 25 * num_lower_color));
          cbar_map(1:num_lower_color,:) = jetmap(1:num_lower_color,:);	
       end

%       num_upper_color = round((max_blv - thresh) / cbar_step);

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
%       lower_interval = (abs(min_blv) - thresh) / (num_blv_colors-1);
 %      upper_interval = (max_blv - thresh) / (num_blv_colors-1);

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

       disp_blv = zeros(1,length(brainlv(:))) + brain_region_color_idx;
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

    newcoords = 1:length(brainlv(:));

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
       img = zeros(1,length(brainlv(:))) + non_brain_region_color_idx;

       disp_blv(non_cluster_coords) = brain_region_color_idx;

       img(newcoords) = disp_blv;
       img = reshape(img,[dims(1) dims(2)]); 
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

    blv = reshape(img,[dims(1) dims(2)]);
    blv_disp = blv;

    if update
       h_img = findobj(gcf,'tag','BLVImg');
       set(h_img,'CData',blv_disp);
    else
       h_img = image(blv_disp); 
    end

    set(h_img,'Tag','BLVImg');
    colormap(cmap);

    set(gca,'tickdir','out','ticklength',[0.001 0.001], ...
	'xtick',[1:dims(2)],'ytick',[1:dims(1)] );

    if (new_fig)
        create_colorbar(colorbar_hdl, cbar_map, min_blv, max_blv);
        return;
    end

    if grp_idx				% called from datamatcorrs plot
	if behav_idx < 0
	       set(h_img,'ButtonDownFcn','smallfc_plot_condmean(''SelectPixel'')');
	else
	       set(h_img,'ButtonDownFcn','smallfc_plot_datamatcorrs(''SelectPixel'')');
	end
    else
       set(h_img,'ButtonDownFcn','smallfc_result_ui(''SelectPixel'')');
    end

    create_colorbar( colorbar_hdl, cbar_map, min_blv, max_blv ); % newcolor: was commented


    %  save the attributes of the current image
    %
    if ~isappdata(gcf, 'Dims')
       setappdata(gcf,'Dims',dims);
    end

    setappdata(gcf,'NumLVs',num_lv);
%    setappdata(gcf,'BLVData',brainlv);

    if ~isappdata(gcf,'BLVCoords')
       setappdata(gcf,'BLVCoords',newcoords);
    end

    setappdata(gcf,'BLVThreshold',thresh);
    setappdata(gcf,'BLVThreshold2',thresh2);
    setappdata(gcf,'BLVDisplay',blv);

    %  in order to use function like 'cluster' etc. created by fMRI
    %
    if ~isappdata(gcf, 'STDims')
       setappdata(gcf,'STDims',dims);
    end

    setappdata(gcf,'WinSize',1);

    if ViewBootstrapRatio
        setappdata(gcf,'BSThreshold',thresh);
        setappdata(gcf,'BSThreshold2',thresh2);

       if ~isappdata(gcf, 'BSRatioCoords')
          setappdata(gcf,'BSRatioCoords',newcoords);
       end
    end

    if ~isempty(behav_idx)			% called from datamatcorrs plot
        setappdata(gcf,'NumBehav',num_behav);
    end

    %  save background to img
    %
    setappdata(gcf,'cmap',cmap);

    return;					%  smallfc_plot_brainlv


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

