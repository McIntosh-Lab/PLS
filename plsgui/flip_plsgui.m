%  This function will flip Left/Right for the created PLSgui datamat files
%  or PLSgui result files. The originator is flipped together. If you
%  flipped *result.mat file once, please make sure that all corresponding
%  *sessiondata.mat files must also be flipped, and should only be flipped
%  once. Since one datamat file may serve several result files, we don't 
%  want to automatically flip datamat file while flipping result file. It
%  only flips PLSgui sessiondata files and PLSgui result files. If you feed
%  it with *.mat files other than *sessiondata.mat or *result.mat, an 
%  "Incorrect file found" warning message will be displayed. For Structural
%  PLSgui, *data.mat will be automatically flipped together with 
%  *sessiondata.mat file.
%
%  If you mistakenly flipped a file, you can just flip it again, and it
%  will be restored to previous status.
%
%  In order to trace the flips you have done on PLSgui datamat files and
%  PLSgui result files, a variable called "flip_history" is saved with all
%  the flip time stamps logged.
%
%  Before a datamat is created, please always remember to use the existing
%  "Check image orientation" button in "Create Datamat" window of "plsgui"
%  program to do the flipping.
%
%  If you are using "batch_plsgui" program, you can flip raw images using
%  "flip_lr.m" program. This program is in the same folder as "batch_plsgui"
%  and "plsgui" program. By the way, "flip_lr.m" will save image in NIfTI 
%  format.
%
%  Usage:	flip_plsgui('abc_fMRIresult.mat') or simply:
%		flip_plsgui('*sessiondata.mat')
%
function flip_plsgui(file)

   if ~exist('file','var') | ~ischar(file)
      error('Usage: flip_plsgui(''abc_fMRIresult.mat'') or flip_plsgui(''*sessiondata.mat'')');
   end

   files = dir(file);

   if isempty(files)
      disp(['File not found: ', file, '.']);
   end

   for i = 1:length(files)
      fn = files(i).name;

      if exist(fn, 'file')
         disp(['Working on: ', fn, ' ...']);
         flip_fail = doflip(fn);

         if(flip_fail)
            disp(['Incorrect file found: ', fn, ' ...']);
         end
      else
         disp(['File not found: ', fn, '.']);
      end
   end

   return;						% flip_plsgui


%-------------------------------------------------------------------------
function flip_fail = doflip(fn)

   flip_fail = 0;
   load(fn);
   FlipFileName = fn;

   if ~exist('coords','var') & ~exist('st_coords','var') & ~exist('newcoords','var')
      flip_fail = 1;
      return;
   end

   if exist('flip_history','var')
      flip_history = [flip_history {datestr(now)}];
   else
      flip_history = {datestr(now)};
   end

   if exist('dims','var')
      flip_dim = dims;
   end
   
   if exist('st_dims','var')
      flip_dim = st_dims;
   end

   if exist('origin','var') & ~isequal(origin, [0 0 0])
      origin(1) = flip_dim(1) - origin(1) + 1;

      if origin < 1
         origin = 1;
      end
   end

   if exist('st_origin','var')
      st_origin(1) = flip_dim(1) - st_origin(1) + 1;

      if st_origin < 1
         st_origin = 1;
      end
   end

   flip_cdx = zeros(1, prod(flip_dim));
   flip_idx = 1:prod(flip_dim);

   if exist('coords','var')
      flip_cdx(coords) = 1:length(coords);
   end

   if exist('st_coords','var')
      flip_cdx(st_coords) = 1:length(st_coords);
   end

   if exist('newcoords','var')
      flip_cdx(newcoords) = 1:length(newcoords);
   end

   flip_cdx = squeeze(reshape(flip_cdx, flip_dim));
   flip_cdx = flipdim(flip_cdx, 1);

   flip_idx = squeeze(reshape(flip_idx, flip_dim));
   flip_idx = flipdim(flip_idx, 1);

   flip_cdx = flip_cdx(find(flip_cdx));
   flip_coord = zeros(1, prod(flip_dim));

   if exist('coords','var')
      flip_coord(coords) = 1;
      flip_coord = flip_coord(flip_idx);
      coords = find(flip_coord);
      coords = coords(flip_cdx);
      [coords idx] = sort(coords);
      coords = [coords(:)]';
   end

   if exist('st_coords','var')
      flip_coord(st_coords) = 1;
      flip_coord = flip_coord(flip_idx);
      st_coords = find(flip_coord);
      st_coords = st_coords(flip_cdx);
      [st_coords idx] = sort(st_coords);
      st_coords = [st_coords(:)]';
   end

   if exist('newcoords','var')
      flip_coord(newcoords) = 1;
      flip_coord = flip_coord(flip_idx);
      newcoords = find(flip_coord);
      newcoords = newcoords(flip_cdx);
      [newcoords idx] = sort(newcoords);
      newcoords = [newcoords(:)]';
   end

   if exist('brainlv','var')
      if(size(brainlv,1) == length(idx))
         brainlv = brainlv(idx,:);
      else
         brainlv = reshape(brainlv, [st_win_size, round(size(brainlv,1)/st_win_size), size(brainlv,2)]);
         brainlv = brainlv(:,idx,:);
         brainlv = reshape(brainlv, [size(brainlv,1)*size(brainlv,2), size(brainlv,3)]);
      end
   end

   if(exist('boot_result','var') & isfield(boot_result,'compare'))
      if(size(boot_result.compare,1) == length(idx))
         boot_result.compare = boot_result.compare(idx,:);
      else
         boot_result.compare = reshape(boot_result.compare, [st_win_size, round(size(boot_result.compare,1)/st_win_size), size(boot_result.compare,2)]);
         boot_result.compare = boot_result.compare(:,idx,:);
         boot_result.compare = reshape(boot_result.compare, [size(boot_result.compare,1)*size(boot_result.compare,2), size(boot_result.compare,3)]);
      end
   end

   if(exist('boot_result','var') & isfield(boot_result,'brain_se'))
      if(size(boot_result.brain_se,1) == length(idx))
         boot_result.brain_se = boot_result.brain_se(idx,:);
      else
         boot_result.brain_se = reshape(boot_result.brain_se, [st_win_size, round(size(boot_result.brain_se,1)/st_win_size), size(boot_result.brain_se,2)]);
         boot_result.brain_se = boot_result.brain_se(:,idx,:);
         boot_result.brain_se = reshape(boot_result.brain_se, [size(boot_result.brain_se,1)*size(boot_result.brain_se,2), size(boot_result.brain_se,3)]);
      end
   end

   if(exist('boot_result','var') & isfield(boot_result,'brainlv_se'))
      if(size(boot_result.brainlv_se,1) == length(idx))
         boot_result.brainlv_se = boot_result.brainlv_se(idx,:);
      else
         boot_result.brainlv_se = reshape(boot_result.brainlv_se, [st_win_size, round(size(boot_result.brainlv_se,1)/st_win_size), size(boot_result.brainlv_se,2)]);
         boot_result.brainlv_se = boot_result.brainlv_se(:,idx,:);
         boot_result.brainlv_se = reshape(boot_result.brainlv_se, [size(boot_result.brainlv_se,1)*size(boot_result.brainlv_se,2), size(boot_result.brainlv_se,3)]);
      end
   end

   if(exist('boot_result','var') & isfield(boot_result,'original_sal'))
      if(size(boot_result.original_sal,1) == length(idx))
         boot_result.original_sal = boot_result.original_sal(idx,:);
      else
         boot_result.original_sal = reshape(boot_result.original_sal, [st_win_size, round(size(boot_result.original_sal,1)/st_win_size), size(boot_result.original_sal,2)]);
         boot_result.original_sal = boot_result.original_sal(:,idx,:);
         boot_result.original_sal = reshape(boot_result.original_sal, [size(boot_result.original_sal,1)*size(boot_result.original_sal,2), size(boot_result.original_sal,3)]);
      end
   end

   if(exist('boot_result','var') & isfield(boot_result,'orig_brainlv'))
      if(size(boot_result.orig_brainlv,1) == length(idx))
         boot_result.orig_brainlv = boot_result.orig_brainlv(idx,:);
      else
         boot_result.orig_brainlv = reshape(boot_result.orig_brainlv, [st_win_size, round(size(boot_result.orig_brainlv,1)/st_win_size), size(boot_result.orig_brainlv,2)]);
         boot_result.orig_brainlv = boot_result.orig_brainlv(:,idx,:);
         boot_result.orig_brainlv = reshape(boot_result.orig_brainlv, [size(boot_result.orig_brainlv,1)*size(boot_result.orig_brainlv,2), size(boot_result.orig_brainlv,3)]);
      end
   end

   if exist('datamatcorrs_lst','var')
      for i = 1:length(datamatcorrs_lst)
         if(size(datamatcorrs_lst{i},2) == length(idx))
            datamatcorrs_lst{i} = datamatcorrs_lst{i}(:,idx);
         else
            datamatcorrs_lst{i} = reshape(datamatcorrs_lst{i}, [size(datamatcorrs_lst{i},1), st_win_size, round(size(datamatcorrs_lst{i},2)/st_win_size)]);
            datamatcorrs_lst{i} = datamatcorrs_lst{i}(:,:,idx);
            datamatcorrs_lst{i} = reshape(datamatcorrs_lst{i}, [size(datamatcorrs_lst{i},1), size(datamatcorrs_lst{i},2)*size(datamatcorrs_lst{i},3)]);
         end
      end
   end

   if exist('newdata_lst','var')
      for i = 1:length(newdata_lst)
         if(size(newdata_lst{i},2) == length(idx))
            newdata_lst{i} = newdata_lst{i}(:,idx);
         else
            newdata_lst{i} = reshape(newdata_lst{i}, [size(newdata_lst{i},1), st_win_size, round(size(newdata_lst{i},2)/st_win_size)]);
            newdata_lst{i} = newdata_lst{i}(:,:,idx);
            newdata_lst{i} = reshape(newdata_lst{i}, [size(newdata_lst{i},1), size(newdata_lst{i},2)*size(newdata_lst{i},3)]);
         end
      end
   end

   if exist('datamat','var')
      if(size(datamat,2) == length(idx))
         datamat = datamat(:,idx);
      else
         datamat = reshape(datamat, [size(datamat,1), st_win_size, round(size(datamat,2)/st_win_size)]);
         datamat = datamat(:,:,idx);
         datamat = reshape(datamat, [size(datamat,1), size(datamat,2)*size(datamat,3)]);
      end
   end

   if exist('st_datamat','var') & exist('brainlv','var')
      for i = 1:length(st_datamat)
         if(size(st_datamat{i},2) == length(idx))
            st_datamat{i} = st_datamat{i}(:,idx);
         else
            st_datamat{i} = reshape(st_datamat{i}, [size(st_datamat{i},1), st_win_size, round(size(st_datamat{i},2)/st_win_size)]);
            st_datamat{i} = st_datamat{i}(:,:,idx);
            st_datamat{i} = reshape(st_datamat{i}, [size(st_datamat{i},1), size(st_datamat{i},2)*size(st_datamat{i},3)]);
         end
      end
   elseif exist('st_datamat','var') & ~exist('brainlv','var')
      if(size(st_datamat,2) == length(idx))
         st_datamat = st_datamat(:,idx);
      else
         st_datamat = reshape(st_datamat, [size(st_datamat,1), st_win_size, round(size(st_datamat,2)/st_win_size)]);
         st_datamat = st_datamat(:,:,idx);
         st_datamat = reshape(st_datamat, [size(st_datamat,1), size(st_datamat,2)*size(st_datamat,3)]);
      end
   end

   if exist('datafile','var')
      load(datafile, 'datamat');

      if(exist('datamat','var') & ndims(datamat) == 2)
         datamat = datamat(:,idx);
      end

      eval(['save ' datafile ' create_ver datamat flip_history']);
      clear datamat;
   end

   clear fn flip_dim flip_coord flip_cdx flip_idx idx idx2;
   v = version;
   v = str2num(v(1));

   if v<7
      clear v;
      eval(['save ' FlipFileName]);
   else
      clear v;

      if singleprecision
         eval(['save ' FlipFileName]);
      else
         eval(['save -V6 ' FlipFileName]);
      end
   end

   return;

