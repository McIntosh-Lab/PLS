function [behavdata_lst, newdata_lst, newcoords, dims, num_cond_lst, ...
	num_subj_lst, subj_name_lst, voxel_size, origin, ...
	behavname, behavdata] = struct_get_common(varargin)

    if(nargin > 0)

        datamat_files = varargin{1};
	cond_selection = varargin{2};

        if(nargin > 2)
           newbehavname = varargin{3};
           newbehavdata = varargin{4};
           newbehavdata_lst = varargin{5};
           progress_hdl = varargin{6};
        end

    else
        error('Check input arguments');
    end

    if(nargin > 2)
        progress_hdl = rri_progress_ui('initialize', 'Trimming datamat');
        msg = 'Loading group information ...';
        rri_progress_ui(progress_hdl, '', msg);
    end

    num_files = length(datamat_files);

    % get dims first, to compute the image size
    %
    [tmp datamat_files{1}] = rri_fileparts(datamat_files{1});
    load(datamat_files{1},'dims','voxel_size','origin','session_info');

    if isempty(cond_selection)
       cond_selection = ones(1,session_info.num_conditions);
    end

    % according to SPM: if the origin field contains 0, then the origin is
    % assumed to be at the center of the volume.

    if isempty(origin) | all(origin == 0)
	origin = floor((dims([1 2 4])+1)/2);
    end

    if(nargin > 2)
        msg = 'Trimming the datamats ...';
        rri_progress_ui(progress_hdl, '', msg);
    end

    % compute the common coords
    %  
    siz = prod(dims);
    multed = zeros(1, siz);
    coord_idx = zeros(num_files, siz);
    behavdata_lst = {};
    subj_name_lst = {};
    oldbehavname = {};
    oldbehavdata = [];

    for i=1:num_files

       [tmp datamat_files{i}] = rri_fileparts(datamat_files{i});
       load(datamat_files{i}, 'behavname', ...
		'coords','session_info','behavdata','selected_subjects');

        num_cond_lst(i) = sum(cond_selection);
%        num_subjects = session_info.num_subjects;
        num_subjects = sum(selected_subjects);
        num_subj_lst(i) = num_subjects;

%        selected_subjects = ones(num_subjects,1);
	selected_subjects = selected_subjects';
        bmask = selected_subjects * cond_selection;
        bmask = find(bmask(:));

        if ~isempty(behavdata)
            oldbehavname = behavname;
            behavdata_lst{i} = behavdata(bmask,:);

            c1 = size(behavdata_lst{i},2);
            c2 = size(oldbehavdata,2);
            min_col = [1:min(c1,c2)];

            oldbehavdata = [oldbehavdata(:,min_col); behavdata_lst{i}(:,min_col)];
        end						% else, taskpls

        multed(coords) = multed(coords) + 1;
        coord_idx(i,coords) = coord_idx(i,coords) + 1;

        subj_name_lst{i} = session_info.subj_name(find(selected_subjects));

        if(nargin > 2)
            rri_progress_ui(progress_hdl,'',i/(2*num_files));
        end

    end

    if ~exist('oldbehavname','var')
       oldbehavname = {};
       for i=1:size(oldbehavdata,2)
          oldbehavname = [oldbehavname, {['behav', num2str(i)]}];
       end
    end


    newcoords = find(multed == num_files);		% find only the overlapped part

    % now compute the common data
    %  
    multed = zeros(1, siz);
    multed(newcoords) = 1;

    for i=1:num_files

	% relative location needs both coord_idx & multed information
	%
        relative = coord_idx(i,:) + multed;

	% remove unrelated information
	%
        relative = relative(find(relative));

        if 0 % (nargin > 2)
            rri_progress_ui(progress_hdl,'', ...
		1/10+1/40+(i-1)*3/(40*num_files)+1/(40*num_files));
        end

	% find relative location of newcoords
	%
        relative = find(relative == 2);

        [tmp datamat_files{i}] = rri_fileparts(datamat_files{i});
        load(datamat_files{i},'session_info','selected_subjects','datafile');
        [tmp datafile] = rri_fileparts(datafile);
	load(datafile);

%        num_subjects = session_info.num_subjects;
        num_subjects = sum(selected_subjects);

%        selected_subjects = ones(num_subjects,1);
	selected_subjects = selected_subjects';
        bmask = selected_subjects * cond_selection;
        bmask = find(bmask(:));

        newdata_lst{i} = datamat(bmask, relative);

        avg = 0;

        if(avg)
	    % average on conditions for each newdata_lst
	    %
            dat = reshape(newdata_lst{i}, ...
		[num_subj_lst(i), num_cond_lst(i), length(newcoords)]);

            gm = mean(dat, 2);
        end

        if 0 % (nargin > 2)
            rri_progress_ui(progress_hdl,'', ...
		1/10+1/40+(i-1)*3/(40*num_files)+2/(40*num_files));
        end

        if(avg)
	    % fill all the conditions with grand mean
	    %
            dat = repmat(gm, [1, num_cond_lst(i), 1]);

            newdata_lst{i} = reshape(dat, ...
		[num_subj_lst(i)*num_cond_lst(i), length(newcoords)]);
        end

        if(nargin > 2)
            rri_progress_ui(progress_hdl,'', ...
		0.5 + i/(2*num_files));
        end

    end

    if exist('newbehavdata','var') & ~isempty(newbehavdata)
	behavname = newbehavname;
	behavdata = newbehavdata;
	behavdata_lst = newbehavdata_lst;
    else
	behavname = oldbehavname;
	behavdata = oldbehavdata;
    end

    return					% struct_get_common

