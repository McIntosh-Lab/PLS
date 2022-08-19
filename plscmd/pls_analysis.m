%PLS_ANALYSIS  Run PLS analysis on one or more datamats.
%
%  Usage: result = pls_analysis(datamat_lst, num_subj_lst, num_cond, ...
%			[option])
%
%  Inputs:
%
%  datamat_lst  -  Datamat list cell array. Each cell stands for one
%	datamat (2-D Matrix), which is also referred as a group. All
%	datamats must be in the form of "subject in condition".
%
%  num_subj_lst  -  Number of subject list array, containing the number
%	of subjects in each group.
%
%  num_cond  -  Number of conditions in datamat_lst.
%
%  option  -  A struct of optional inputs. It can be:
%
%	option.progress_hdl = ( user interface handle )
%	option.method = [1] | 2 | 3 | 4 | 5 | 6
%	option.num_perm = ( single non-negative integer )
%	option.is_struct = [0] | 1
%	option.num_split = ( single non-negative integer )
%	option.num_boot = ( single non-negative integer )
%	option.clim = ( [95] single number between 0 and 100 )
%	option.bscan = ( subset of  1:num_cond )
%	option.stacked_designdata = ( 2-D numerical matrix )
%	option.stacked_behavdata = ( 2-D numerical matrix )
%	option.meancentering_type = [0] | 1 | 2 | 3
%	option.cormode = [0] | 2 | 4 | 6
%	option.boot_type = ['strat'] | 'nonstrat'
%	
%	Options description in detail:
%	==============================
%
%	progress_hdl: Only specified when using GUI interface. By default,
%		progress_hdl is empty.
%
%	method: This option will decide which PLS method that the
%		program will use:
%			1. Mean-Centering Task PLS
%			2. Non-Rotated Task PLS
%			3. Regular Behavior PLS
%			4. Regular Multiblock PLS
%			5. Non-Rotated Behavior PLS
%			6. Non-Rotated Multiblock PLS
%		If it is not specified, program will use default value 1.
%
%	num_perm: If specified and num_perm > 0, PLS will run permutation
%		test with num_perm amount of samples; otherwise, num_perm
%		will use default value 0, and program will not run 
%		permutation test.
%
%	is_struct: If it is not specified, is_struct will use default
%		value 0. If specified and is_struct = 1, PLS will not 
%		permute conditions within a group. You only need to 
%		specify it when you run Non-Behavior Structure PLS and
%		the segmented data is used.
%
%	num_split: If specified and num_split > 0, PLS will run permutation
%		test with Natasha's Split Half routine; otherwise num_split
%		will use default value 0, and program will not use Split 
%		Half routine.
%
%	num_boot: If specified and num_boot > 0, PLS will run bootstrap
%		test with num_boot amount of samples; otherwise, num_boot
%		will use default value 0, and program will not run
%		bootstrap test.
%
%	clim: Confidence level between 0 and 100. If not specified,
%		program will use default value 95.
%
%	bscan: In Multiblock PLS, you can specify a subset of
%		conditions that are used in multiblock PLS behav
%		block. e.g., bscan=[1 3] for 4 conditions. If it
%		is not specified, it means that all the conditions
%		are selected. Using the above example, bscan is
%		equivalent to [1 2 3 4] for 4 conditions. This 
%		option can be applied to method 4 and 6.
%
%	stacked_designdata: If you are choosing Non-Rotated Task PLS,
%		Non-Rotated Behavior PLS, or Non-Rotated Multiblock PLS,
%		you have to specify this 2-D numerical matrix.
%
%		Number of columns always stand for number of designs. 
%
%		For Non-Rotated Task PLS, number of rows in each group
%		equal to number number of conditions. So total number
%		of rows equal to that multiplied by number of groups, in
%		the form of "condition in group". i.e.:
%			g1	c1
%				c2
%				c3
%			g2	c1
%				c2
%				c3
%
%		For Non-Rotated Behavior PLS, number of rows in each
%		group equal to number of conditions multiplied by number
%		of behavior measures. So total number of rows equal to
%		that multiplied by number of groups, in the form of
%		"measure in condition in group". i.e.:
%			g1	c1	b1
%					b2
%				c2	b1
%					b2
%				c3	b1
%					b2
%			g2	c1	b1
%					b2
%				c2	b1
%					b2
%				c3	b1
%					b2
%
%		For Non-Rotated Multiblock PLS, each group contains both
%		Task Block and Behav Block. So number of rows in each
%		group equal to number number of conditions plus number of
%		conditions multiplied by number of behavior measures. So
%		total number of rows equal to that multiplied by number of
%		groups, like this:
%			g1	c1
%				c2
%				c3
%				c1	b1
%					b2
%				c2	b1
%					b2
%				c3	b1
%					b2
%			g2	c1
%				c2
%				c3
%				c1	b1
%					b2
%				c2	b1
%					b2
%				c3	b1
%					b2
%
%		This option can be applied to method 2, 5 and 6.
%
%	stacked_behavdata: If you are choosing any Behavior PLS or
%		Multiblock PLS, you have to specify this 2-D numerical
%		matrix.
%
%		Number of columns always stand for behavior measures.
%		Number of rows should equal to the sum of the number
%		of rows in datamat list array, and it is in the form
%		of "subject in condition in group".
%
%		This option can be applied to method 3, 4, 5 and 6.
%
%	meancentering_type: Type of meancentering.
%		0. Remove group condition means from conditon means
%		   within each group. Tells us how condition effects
%		   are modulated by group membership. (Boost condition
%		   differences, remove overall group diffrences).
%		1. Remove grand condition means from each group condition
%		   mean. Tells us how conditions are modulated by group 
%		   membership (Boost group differences, remove overall
%		   condition diffrences).
%		2. Remove grand mean over all subjects and conditions.
%		   Tells us full spectrum of condition and group effects.
%		3. Remove all main effects by subtracting condition and
%		   group means. This type of analysis will deal with 
%		   pure group by condition interaction.
%		If it is not specified, program will use default value 0.
%		This option can be applied to method 1, 2, 4, and 6.
%
%	cormode: correaltion mode determines correlation type to analyze.
%		0. Pearson correlation
%		2. covaraince
%		4. cosine angle
%		6. dot product
%
%		If it is not specified, program will use default value 0.
%		This option can be applied to method 3, 4, 5, and 6.
%
%	boot_type: 'strat' (default for standard PLS approach), or
%		'nonstrat' for nonstratified boot samples.
%
%  Outputs:
%
%  result  -  A struct of all outputs. It could have items like:
%
%	method:			PLS option
%				1. Mean-Centering Task PLS
%				2. Non-Rotated Task PLS
%				3. Regular Behavior PLS
%				4. Multiblock PLS
%				5. Non-Rotated Behavior PLS
%				6. Non-Rotated Multiblock PLS
%
%	u:			Brainlv or Salience
%
%	s:			Singular value
%
%	v:			Designlv or Behavlv
%
%	usc:			Brainscores or Scalpscores
%
%	vsc:			Designscores or Behavscores
%
%	TBv:			Store Task / Bahavior v separately
%
%	TBusc:			Store Task / Bahavior usc separately
%
%	TBvsc:			Store Task / Bahavior vsc separately
%
%	datamatcorrs_lst:	Correlation of behavior data with datamat.
%				Only available in behavior PLS.
%
%	lvcorrs:		Correlation of behavior data with usc,
%				only available in behavior PLS.
%
%	perm_result:		struct containing permutation result
%		num_perm:	number of permutation
%		sp:		permuted singular value greater than observed
%		sprob:		sp normalized by num_perm
%		permsamp:	permutation reorder sample
%		Tpermsamp:	permutation reorder sample for multiblock PLS
%		Bpermsamp:	permutation reorder sample for multiblock PLS
%
%	perm_splithalf:		struct containing permutation splithalf
%		num_outer_perm:	permutation splithalf related
%		num_split:	permutation splithalf related
%		orig_ucorr:	permutation splithalf related
%		orig_vcorr:	permutation splithalf related
%		ucorr_prob:	permutation splithalf related
%		vcorr_prob	permutation splithalf related
%		ucorr_ul:	permutation splithalf related
%		ucorr_ll:	permutation splithalf related
%		vcorr_ul:	permutation splithalf related
%		vcorr_ll:	permutation splithalf related
%
%	boot_result:		struct containing bootstrap result
%		num_boot:	number of bootstrap
%		boot_type:	Set to 'nonstrat' if using Natasha's
%				'nonstrat' bootstrap type; set to
%				'strat' for conventional bootstrap.
%		nonrotated_boot: Set to 1 if using Natasha's Non
%				Rotated bootstrap; set to 0 for 
%				conventional bootstrap.
%		bootsamp:	bootstrap reorder sample
%		bootsamp_4beh:	bootstrap reorder sample for behav PLS
%		compare_u:	compared salience or compared brain
%		u_se:		standard error of salience or brainlv
%		clim:		confidence level between 0 and 100.
%		distrib:	orig_usc or orig_corr distribution
%		prop:		orig_usc or orig_corr probability
%
%		following boot_result only available in task PLS:
%
%		usc2:		brain scores that are obtained from the
%				mean-centered datamat
%		orig_usc:	same as usc, with mean-centering on subj
%		ulusc:		upper boundary of orig_usc
%		llusc:		lower boundary of orig_usc
%		ulusc_adj:	percentile of orig_usc distribution with
%				upper boundary of orig_usc
%		llusc_adj:	percentile of orig_usc distribution with
%				lower boundary of orig_usc
%
%		following boot_result only available in behavior PLS:
%
%		orig_corr:	same as lvcorrs
%		ulcorr:		upper boundary of orig_corr
%		llcorr:		lower boundary of orig_corr
%		ulcorr_adj:	percentile of orig_corr distribution with
%				upper boundary of orig_corr
%		llcorr_adj:	percentile of orig_corr distribution with
%				lower boundary of orig_corr
%		num_LowVariability_behav_boots:	display numbers of low
%				variability resampled hehavior data in
%				bootstrap test
%		badbeh:		display bad behav data that is caused by
%				bad re-order (with 0 standard deviation)
%				which will further cause divided by 0
%		countnewtotal:	count the new sample that is re-ordered
%				for badbeh
%
%	is_struct:		Set to 1 if running Non-Behavior
%				Structure PLS; set to 0 for other PLS.
%
%	bscan:			Subset of conditions that are selected
%				for behav block, only in Multiblock PLS.
%
%	num_subj_lst:		Number of subject list array, containing
%				the number of subjects in each group.
%
%	num_cond:		Number of conditions in datamat_lst.
%
%	stacked_designdata:	Stacked design contrast data for all
%				the groups.
%
%	stacked_behavdata:	Stacked behavior data for all the groups
%
%	other_input:		struct containing other input data
%		meancentering_type: Use Natasha's meancentering type
%				if it is not 0.
%		cormode:	Use Natasha's correlation mode if it
%				is not 0.
%

%   Created on 05-JAN-2005 by Jimmy Shen
%   Last update as part of Plscmd.zip: 01-FEB-2011
%   Last update as part of Pls.zip: 16-MAY-2012
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = pls_analysis(datamat_lst, num_subj_lst, k, opt)

   result = [];

   %  check input variable
   %
   if nargin < 3
      disp(' ');
      disp('Usage: result = pls_analysis(datamat_lst, num_subj_lst, num_cond, [option])');
      disp(' ');disp(' ');
      return;
   end

   if isempty(datamat_lst) | ~iscell(datamat_lst)
      error(['datamat_lst should be a datamat cell array. Each cell' char(10) 'represents a datamat. All datamats must be in the form' char(10) 'of "subject in condition".']);
   end

   if isempty(num_subj_lst) | (~isnumeric(num_subj_lst) & ~iscell(num_subj_lst))
      error(['num_subj_lst should be a numeric array. Each element' char(10) 'represents the number of subjects in the corresponding' char(10) 'datamat.']);
   end

   if isempty(k) | ~isnumeric(k) | length(k) ~= 1
      error('num_cond should be a number represents the number of conditions.');
   end

   num_cond = k;
   progress_hdl = [];
   method = 1;
   num_perm = 0;
   is_struct = 0;
   num_split = 0;
   num_boot = 0;
   clim = 95;
   bscan = 1:num_cond;
   stacked_designdata = [];
   stacked_behavdata = [];
   is_perm_splithalf = 0;
   meancentering_type = 0;
   cormode = 0;
   boot_type = 'strat';
   nonrotated_boot = 0;

   if nargin == 4 & ~isempty(opt)

      if ~isstruct(opt)
         error('option argument should be a struct');
      end

      if isfield(opt,'progress_hdl')
         progress_hdl = opt.progress_hdl;

         if isempty(progress_hdl) | ~ishandle(progress_hdl)
            error('Field "progress_hdl" should be a GUI handle');
         end
      end

      if isfield(opt,'method')
         method = opt.method;

         if isempty(method) | ~ismember(method,[1:6])
            error('Field "method" should be 1, 2, 3, 4, 5 or 6');
         end
      end

      if isfield(opt,'num_perm')
         num_perm = opt.num_perm;

         if isempty(num_perm) | num_perm < 0 | round(num_perm) ~= num_perm
            error('Field "num_perm" should be a non-negative integer');
         end
      end

      if isfield(opt,'is_struct')
         is_struct = opt.is_struct;

         if isempty(is_struct) | (is_struct ~= 0 & is_struct ~= 1)
            error('Field "is_struct" should be 1 or 0.');
         end
      end

      if isfield(opt,'num_split')
         num_split = opt.num_split;

         if isempty(num_split) | num_split < 0 | round(num_split) ~= num_split
            error('Field "num_split" should be a non-negative integer');
         end

         if num_split > 0
            is_perm_splithalf = 1;
            opt.nonrotated_boot = 1;
         end
      end

      if isfield(opt,'num_boot')
         num_boot = opt.num_boot;

         if isempty(num_boot) | num_boot < 0 | round(num_boot) ~= num_boot
            error('Field "num_boot" should be a non-negative integer');
         end
      end

      if isfield(opt,'clim')
         clim = opt.clim;

         if isempty(clim) | clim < 0 | clim > 100
            error('Field "clim" should be within 0 and 100');
         end
      end

      if isfield(opt,'bscan')
         bscan = opt.bscan;

         if isempty(bscan) | ~isempty(setdiff(bscan, [1:num_cond]))
            error('Field "bscan" should be a subset of [1:num_cond]');
         end
      end

      if method ~= 4 & method ~= 6
         bscan = 1:num_cond;
      end

      if isfield(opt,'stacked_designdata')
         stacked_designdata = opt.stacked_designdata;

         if isempty(stacked_designdata) | ~isnumeric(stacked_designdata)
            error('Field "stacked_designdata" should be a 2-D numerical matrix');
         end
      end

      if isfield(opt,'stacked_behavdata')
         stacked_behavdata = opt.stacked_behavdata;

         if isempty(stacked_behavdata) | ~isnumeric(stacked_behavdata)
            error('Field "stacked_behavdata" should be a 2-D numerical matrix');
         end
      end

      if isfield(opt,'meancentering_type')
         meancentering_type = opt.meancentering_type;

         if isempty(meancentering_type) | ~ismember(meancentering_type,[0:3])
            error('Field "meancentering_type" should be 0, 1, 2 or 3');
         end
      end

      if isfield(opt,'cormode')
         cormode = opt.cormode;

         if isempty(cormode) | ~ismember(cormode,[0 2 4 6])
            error('Field "cormode" should be 0, 2, 4 or 6');
         end
      end

      if isfield(opt,'boot_type')
         boot_type = opt.boot_type;

         if isempty(boot_type) | ~ismember(boot_type,{'strat','nonstrat'})
            error('Field "boot_type" should be ''strat'' or ''nonstrat''');
         end
      end

      if isfield(opt,'nonrotated_boot')
         nonrotated_boot = opt.nonrotated_boot;

         if isempty(nonrotated_boot) | (nonrotated_boot ~= 0 & nonrotated_boot ~= 1)
            error('Field "nonrotated_boot" should be 1 or 0.');
         end

         if nonrotated_boot == 1 & num_split == 0
            error('num_split must be greater than 0 when nonrotated_boot is 1');
         end
      end

      if isfield(opt,'Tpermsamp')
         Tpermsamp = opt.Tpermsamp;

         if isempty(Tpermsamp) | ~isnumeric(Tpermsamp)
            error('Field "Tpermsamp" should be a 2-D numerical matrix');
         end

         if ~isfield(opt,'num_perm') | size(Tpermsamp,2) ~= num_perm
            error('"Tpermsamp" does not match number of permutaion');
         end
      end

      if isfield(opt,'Bpermsamp')
         Bpermsamp = opt.Bpermsamp;

         if isempty(Bpermsamp) | ~isnumeric(Bpermsamp)
            error('Field "Bpermsamp" should be a 2-D numerical matrix');
         end

         if ~isfield(opt,'num_perm') | size(Bpermsamp,2) ~= num_perm
            error('"Bpermsamp" does not match number of permutaion');
         end
      end

      if isfield(opt,'permsamp')
         permsamp = opt.permsamp;

         if isempty(permsamp) | ~isnumeric(permsamp)
            error('Field "permsamp" should be a 2-D numerical matrix');
         end

         if ~isfield(opt,'num_perm') | size(permsamp,2) ~= num_perm
            error('"permsamp" does not match number of permutaion');
         end
      end

      if isfield(opt,'bootsamp')
         bootsamp = opt.bootsamp;

         if isempty(bootsamp) | ~isnumeric(bootsamp)
            error('Field "bootsamp" should be a 2-D numerical matrix');
         end

         if ~isfield(opt,'num_boot') | size(bootsamp,2) ~= num_boot
            error('"bootsamp" does not match number of bootstrap');
         end
      end

      if isfield(opt,'bootsamp_4beh')
         bootsamp_4beh = opt.bootsamp_4beh;

         if isempty(bootsamp_4beh) | ~isnumeric(bootsamp_4beh)
            error('Field "bootsamp_4beh" should be a 2-D numerical matrix');
         end

         if ~isfield(opt,'num_boot') | size(bootsamp_4beh,2) ~= num_boot
            error('"bootsamp_4beh" does not match number of bootstrap');
         end
      end
   end

   if ~isnumeric(num_subj_lst)
      if num_split ~= 0
         error('Cannot run single subject analysis with Split Half');
      end

      if ~strcmp(boot_type, 'strat')
         error('Cannot run single subject analysis with nonstrat boot type');
      end
   end

   %  init
   %
   num_groups = length(datamat_lst);
   total_rows = 0;

   %  total rows in stacked datamat (extract datamat from each group,
   %  and stacked them together)
   %
   for g = 1:num_groups
      total_rows = total_rows + size(datamat_lst{g}, 1);
   end

   if ismember(method,[3 4 5 6])
      if size(stacked_behavdata,1) ~= total_rows
         error(['Wrong number of rows in behavior data file, which should be ' num2str(total_rows) '.']);
      end
   end

   v7 = version;
   if str2num(v7(1))<7
      singleanalysis = 0;
   else
      singleanalysis = 1;
   end

 if str2num(v7(1:3))<7.4 & strcmp(v7(4),'.')
   pc = computer;
   if singleanalysis & ( strcmp(pc,'GLNXA64') | strcmp(pc,'GLNXI64') | strcmp(pc,'PCWIN64') )
         singleanalysis = 0;
   end

   if 0
      %  Temporary solution for MATLAB Bug Report ID 268001, 
      %  which has problem to perform single precision math operation 
      %  on any Intel 64-bit machine.
      %
      quest = input('\nWe detected that you are running MATLAB on a 64-bit system.\nAccording to MATLAB Bug Report ID 268001, we have to convert\ndata to double precision for Intel based system.\n\nIs this Intel 64-bit machine?\n\n1. No\n2. Yes\n3. Don''t know\n\nPlease select: ','s');
      quest = str2num(quest);
      while isempty(quest) | ~ismember(quest,[1:3])
         disp(' ');disp(' ');
         disp('Please select either 1, 2, or 3 and then strike ''Enter''');
         quest = input('\nWe detected that you are running MATLAB on a 64-bit system.\nAccording to MATLAB Bug Report ID 268001, we have to convert\ndata to double precision for Intel based system.\n\nIs this Intel 64-bit machine?\n\n1. No\n2. Yes\n3. Don''t know\n\nPlease select: ','s');
         quest = str2num(quest);
      end

      if quest ~= 1
         singleanalysis = 0;
      end

   end;
 end

   for g = 1:num_groups
      if singleanalysis
         datamat_lst{g} = single(datamat_lst{g});
      else
         datamat_lst{g} = double(datamat_lst{g});
      end
   end

   if method == 2 & size(stacked_designdata,1) ~= num_groups * k
      error(['Wrong number of rows in contrast data file, which should be ' num2str(num_groups * k) '.']);
   elseif method == 5 & size(stacked_designdata,1) ~= num_groups * k * size(stacked_behavdata,2)
      error(['Wrong number of rows in contrast data file, which should be ' num2str(num_groups * k * size(stacked_behavdata,2)) '.']);
   elseif method == 6 & size(stacked_designdata,1) ~= ( num_groups * k + num_groups * k * size(stacked_behavdata,2) )
      error(['Wrong number of rows in contrast data file, which should be ' num2str(num_groups * k + num_groups * k * size(stacked_behavdata,2)) '.']);
   end

   if singleanalysis
      if ismember(method,[3 4 5 6])
         stacked_behavdata = single(stacked_behavdata);
      end

      if ismember(method,[2 5 6])
         stacked_designdata = single(stacked_designdata);
      end
   else
      if ismember(method,[3 4 5 6])
         stacked_behavdata = double(stacked_behavdata);
      end

      if ismember(method,[2 5 6])
         stacked_designdata = double(stacked_designdata);
      end
   end

   if method == 6
      Ti = ones(1, num_cond);
      num_bm = size(stacked_behavdata,2);
      Bi = zeros(num_bm, num_cond);
      Bi(:,bscan) = 1;
      TBi = [Ti(:) ; Bi(:)];
      TBi = repmat(TBi, [1 num_groups]);
      stacked_designdata = stacked_designdata(find(TBi(:)),:);
   end

   %  Normalize stacked_designdata
   %
   if ismember(method,[2 5 6])
      stacked_designdata = normalize(stacked_designdata);
   end

   %  check if the contrast matrix is rank deficient
   %
   if (rank(stacked_designdata) ~= size(stacked_designdata,2))
      disp(' ');
      disp('Your Contrast matrix is rank deficient.');
      disp(' ');
   end;

   %  check if the contrast matrix is orthogonal
   %
   check_orth = abs(triu(stacked_designdata'*stacked_designdata) - tril(stacked_designdata'*stacked_designdata));
   if ismember(method,[2 5 6]) & max(check_orth(:)) > 1e-4
      disp(' ');
      disp('Effects expressed by each contrast are not independent. Check variable');
      disp('lvintercorrs in result file to see overlap of effects between LVs');
      disp(' ');
   end

   %  check if the behavior matrix is all the same for each group,
   %  because the 'xcor' inside of 'rri_corr_maps' contains a 'stdev',
   %  which is a divident. If it is 0, it will cause divided by 0
   %  problem.
   %
   if ismember(method,[3 4 5 6])
      for g = 1:num_groups
         if ~iscell(num_subj_lst)
            n = num_subj_lst(g);
            span = sum(num_subj_lst(1:g-1)) * k;

            min1 = min(std(stacked_behavdata(1+span:n*k+span,:)));

            if min1 == 0
               msg = 'Please check your behavior data, and make sure that';
               msg = [msg char(10) 'none of the columns are all the same for each group.'];
               error(msg);
            end
         else
            n = num_subj_lst{g};
            span = sum([num_subj_lst{1:g-1}]);

            min1 = min(std(stacked_behavdata(1+span:sum(n)+span,:)));

            if min1 == 0
               msg = 'Please check your behavior data, and make sure that';
               msg = [msg char(10) 'none of the columns are all the same for each group.'];
               error(msg);
            end
         end
      end
   end

   result.method = method;
   result.is_struct = is_struct;

   single_cond_lst = {};

   %  for single condition with multiple groups situation, reconstruct datamat
   %  to make it single group with multiple conditions.
   %
%   if method == 1 & k == 1 & ~iscell(num_subj_lst)
   if ismember(method,[1 2 4 6]) & k == 1
      meancentering_type = 1;
      msg = ['\nBecause you are running single condition Task PLS, input\n'];
      msg = [msg 'Mean-Centering Type has to reset to 1.\n\n'];
      fprintf(msg);
   elseif 0
%      if any(diff(num_subj_lst))
 %        disp('number of subject should be the same for all group in single condition with multiple groups situation.');
  %       disp(' ');disp(' ');
   %      return;
    %  end

%      num_subj_lst = num_subj_lst(1);
 %     k = num_groups;
  %    num_groups = 1;

      tmp = [];

%      for g=1:k
      for g = 1:num_groups
         tmp = [tmp; datamat_lst{g}];
      end

      single_cond_lst = {tmp};

      if meancentering_type ~= 0
         meancentering_type = 0;
         msg = ['\nBecause you are running single condition Mean-Centering PLS,\n'];
         msg = [msg 'input Mean-Centering Type has to reset to 0.\n\n'];
         fprintf(msg);
      end
%   elseif method == 1 & k == 1 & iscell(num_subj_lst)
      error('You need more than one condition to run single subject analysis');
   end

   %  For test purpose
   %
   if exist('plslog.m','file')
      switch method
      case 1
         plslog('PLS mean-centering task analysis');
      case 2
         plslog('PLS non-rotated task analysis');
      case 3
         plslog('PLS regular behavior analysis');
      case 4
         plslog('PLS multiblock analysis');
      case 5
         plslog('PLS non-rotated behavior analysis');
      case 6
         plslog('PLS non-rotated multiblock analysis');
      end
   end

%   if ~isempty(progress_hdl)
%      progress_hdl = rri_progress_ui('initialize');
%      msg = 'Working on PLS ...';
%      rri_progress_ui(progress_hdl, '', msg);
%   end

   %  Stacking datamat
   %
   if ~isempty(single_cond_lst)
      stacked_datamat = single_cond_lst{1};
   else
      stacked_datamat = stacking_datamat(datamat_lst, single_cond_lst, progress_hdl);
   end

   %------------------------------------------_____________________________

   %  Calculate Covariance / Correlation data
   %
   if isempty(progress_hdl)
      disp(' '); disp('Calculating Covariance / Correlation data ...');
   else
      rri_progress_ui(progress_hdl,'',1);
      rri_progress_ui(progress_hdl, '', ...
		'Calculating Covariance / Correlation data ...');
   end

   datamat_reorder = [1:size(stacked_datamat,1)]';

   if ismember(method,[3 4 5 6])
      behavdata_reorder = [1:size(stacked_behavdata,1)]';
   else
      behavdata_reorder = [];
   end

   [datamatsvd, datamatsvd_unnorm, datamatcorrs_lst, stacked_smeanmat] = ...
	rri_get_covcor(method, stacked_datamat, stacked_behavdata, num_groups, ...
	num_subj_lst, num_cond, bscan, meancentering_type, cormode, ...
	single_cond_lst, 1, num_boot, datamat_reorder, behavdata_reorder);

   %~~~~~~~~~~~~~

   %  save datamatcorrs_lst, if behav PLS
   %
   if ismember(method,[3:6])
      result.datamatcorrs_lst = datamatcorrs_lst;
   end

   if isempty(progress_hdl)
      disp('Calculating LVs ...');
   else
      rri_progress_ui(progress_hdl, '', 'Calculating LVs ...');
   end

   if ismember(method,[2 5 6])	% different computation for non-rotated PLS

      crossblock = stacked_designdata' * datamatsvd;

      if nonrotated_boot
         u = normalize(crossblock');
         normalized_u = normalize(u);
         lvintercorrs = normalized_u'*normalized_u;
      else
         u = crossblock';
         lvintercorrs = u'*u;
      end

      result.lvintercorrs = lvintercorrs;
      s = sqrt(sum(crossblock.^2, 2));
      v = stacked_designdata;

   else				% using SVD

      %  Singular Value Decomposition, observed
      %
      [r c] = size(datamatsvd);
      if r <= c
         [u,s,v] = svd(datamatsvd',0);
      else
         [v,s,u] = svd(datamatsvd,0);
      end

      s = diag(s);

   end

   org_s = s;
   org_v = v;

   original_u = u * diag(s);
   original_v = v * diag(s);

   kk = length(bscan);

   if iscell(num_subj_lst)
      for bi=1:length(num_subj_lst)
         num_subj_lst_4beh{bi}=num_subj_lst{bi}(bscan);
      end
   end

   %  Since the 2 matrices that went into the SVD were unit normal, we should
   %  go backwards from the total Singular value Sum of Squares (SSQ)
   %
   if ismember(method, [4 6])

      result.bscan = bscan;

      %  Calculate total SSQ
      %
      total_s = sum(datamatsvd_unnorm(:).^2);

      %  Calculate distribution of normalized SSQ across LVs
      %
      per = s.^2 / sum(s.^2);

      %  Re-calculate singular value based on the distribution of SSQ
      %  across normalized LVs
      %
      org_s = sqrt(per * total_s);

      %  Re-scale v (block LV) with singular value
      %
      org_v = v * diag(org_s);

   end

   %  save u,s,v for all situations (observation)
   %
   result.u = u;
   result.s = s;
   result.v = v;

   if isempty(progress_hdl)
      disp('Calculating Scores ...');
   else
      rri_progress_ui(progress_hdl, '', 'Calculating Scores ...');
   end

   vsc = [];

   switch method
   case {1, 2}
      if method == 1
         usc = stacked_datamat * u;

         if num_boot > 0
            usc2 = stacked_smeanmat * u;
         end
      elseif method == 2
         usc = stacked_datamat * normalize(u);

         if num_boot > 0
            usc2 = stacked_smeanmat * u;
         end
      end

      num_col = size(v, 2);

      % expand the num_subj for each row (cond)
      % did the samething as testvec
      %
      for g = 1:num_groups
         if ~iscell(num_subj_lst)
            n = num_subj_lst(g);

            tmp = reshape(v((g-1)*k+1:(g-1)*k+k,:),[1, num_col*k]);
            tmp = repmat(tmp, [n, 1]);		% expand to num_subj
            tmp = reshape(tmp, [n*k, num_col]);
         else
            n = num_subj_lst{g};
            tmp = [];

            for k1 = 1:k
               tmp1 = v((g-1)*k+1:(g-1)*k+k,:);
               tmp1 = tmp1(k1,:);
               tmp1 = repmat(tmp1, [n(k1), 1]);	% expand to num_subj
               tmp = [tmp; tmp1];
            end
         end

         vsc = [vsc; tmp];			% stack by groups
      end
   case {3, 5}

      row_idx = [];
      last = 0;

      for g = 1:num_groups
         if ~iscell(num_subj_lst)
            n = num_subj_lst(g);

            %  take this advantage (having g & n) to get row_idx
            %
            tmp = 1:n*k;
            tmp = reshape(tmp, [n k]);
            tmp = tmp(:, bscan);
            row_idx = [row_idx ; tmp(:) + last];
            last = last + n*k;
         else
            n = num_subj_lst{g};

            %  get row_idx
            %
            for k1 = 1:k
               if ismember(k1, bscan)
                  tmp = [1:n(k1)]';
                  row_idx = [row_idx ; tmp + last];
               end

               last = last + n(k1);
            end
         end
      end

      if ~iscell(num_subj_lst)
         [usc, vsc, lvcorrs] = rri_get_behavscores(stacked_datamat, ...
		stacked_behavdata, u, v, k, num_subj_lst, cormode);
      else
         [usc, vsc, lvcorrs] = ssb_rri_get_behavscores(stacked_datamat, ...
		stacked_behavdata, u, v, k, num_subj_lst, cormode);
      end

      result.lvcorrs = lvcorrs;

   case {4, 6}

      %  Just for Task PLS Brsin Scores with CI
      %
      if num_boot > 0
         usc2 = stacked_smeanmat * u;
      end

      %  Separate v into 2 parts: Tv (Task) and Bv (Behavior)
      %
      Tv = [];
      Bv = [];

      for g = 1:num_groups
         t = size(stacked_behavdata, 2);

         Tv = [Tv; v((g-1)*k+(g-1)*kk*t+1   : (g-1)*k+(g-1)*kk*t+k,:)];
         Bv = [Bv; v((g-1)*k+(g-1)*kk*t+k+1 : (g-1)*k+(g-1)*kk*t+k+kk*t,:)];
      end

      num_col = size(Tv, 2);

      % expand the num_subj for each row (cond)
      % did the samething as testvec
      %
      Tvsc = [];
      row_idx = [];
      last = 0;

      for g = 1:num_groups
         if ~iscell(num_subj_lst)
            n = num_subj_lst(g);

            tmp = reshape(Tv((g-1)*k+1:(g-1)*k+k,:),[1, num_col*k]);
            tmp = repmat(tmp, [n, 1]);		% expand to num_subj
            tmp = reshape(tmp, [n*k, num_col]);

            Tvsc = [Tvsc; tmp];			% stack by groups

            %  take this advantage (having g & n) to get row_idx
            %
            tmp = 1:n*k;
            tmp = reshape(tmp, [n k]);
            tmp = tmp(:, bscan);
            row_idx = [row_idx ; tmp(:) + last];
            last = last + n*k;
         else
            n = num_subj_lst{g};
            tmp = [];

            for k1 = 1:k
               tmp1 = Tv((g-1)*k+1:(g-1)*k+k,:);
               tmp1 = tmp1(k1,:);
               tmp1 = repmat(tmp1, [n(k1), 1]);	% expand to num_subj
               tmp = [tmp; tmp1];
            end

            Tvsc = [Tvsc; tmp];			% stack by groups

            %  get row_idx
            %
            for k1 = 1:k
               if ismember(k1, bscan)
                  tmp = [1:n(k1)]';
                  row_idx = [row_idx ; tmp + last];
               end

               last = last + n(k1);
            end
         end
      end

      Tusc = stacked_datamat * normalize(u);

      if ~iscell(num_subj_lst)
         [Busc, Bvsc, lvcorrs] = rri_get_behavscores(stacked_datamat(row_idx,:), ...
		stacked_behavdata(row_idx,:), u, Bv, kk, num_subj_lst, cormode);
      else
         [Busc, Bvsc, lvcorrs] = ssb_rri_get_behavscores(stacked_datamat(row_idx,:), ...
		stacked_behavdata(row_idx,:), u, Bv, kk, num_subj_lst_4beh, cormode);
      end

      usc = [Tusc; Busc];
      vsc = [Tvsc; Bvsc];
      result.TBusc = {Tusc, Busc};
      result.TBvsc = {Tvsc, Bvsc};
      result.TBv = {Tv, Bv};

      result.lvcorrs = lvcorrs;

   end

   %  save Scores for all situations
   %
   result.usc = usc;
   result.vsc = vsc;

   %  save Input for all situations
   %
   if ismember(method,[3 4 5 6])
      result.stacked_behavdata = stacked_behavdata;
   end

   if ismember(method,[2 5 6]) & ~isempty(stacked_designdata)
      result.stacked_designdata = stacked_designdata;
   end

%   result.datamat_lst = datamat_lst;
   result.num_subj_lst = num_subj_lst;
   result.num_conditions = k;

   %-------------------------_______________________-----------------------

   if num_perm > 0

     if ~is_perm_splithalf		%%%%%% REGULAR PERMUTATION TEST %%%%%%

      sp = zeros(size(s));
      vp = zeros(size(v));

      if isempty(progress_hdl)
         fprintf('\nMaking resampling matrix for permutation ...\n');
      end

      if ismember(method, [4 6])
         if ~iscell(num_subj_lst)
            Treorder = rri_perm_order(num_subj_lst, k, num_perm, is_struct);

            for p = 1:num_perm
               reorder(:,p) = [rri_randperm_notall(num_subj_lst, k, bscan)'];
            end
         else
            Treorder = ssb_rri_perm_order(num_subj_lst, k, num_perm, is_struct);

            for p = 1:num_perm
               reorder(:,p) = [ssb_rri_randperm_notall(num_subj_lst, k, bscan)'];
            end
         end
      elseif ismember(method, [3 5])
         for p = 1:num_perm
            reorder(:,p) = [randperm(size(stacked_datamat,1))'];
         end
      else
         if ~iscell(num_subj_lst)
            reorder = rri_perm_order(num_subj_lst, k, num_perm, is_struct);
         else
            reorder = ssb_rri_perm_order(num_subj_lst, k, num_perm, is_struct);
         end
      end

      if exist('permsamp','var')
         reorder = permsamp;
      end

      if exist('Tpermsamp','var')
         Treorder = Tpermsamp;
      end

      if isempty(progress_hdl)
         pcntacc = fprintf('Working on %d permutations:', num_perm);
      end

      for p = 1:num_perm

         if isempty(progress_hdl)
            pcntacc = pcntacc + fprintf(' %d', p);
         else
            msg = ['Working on Permutation:  ',num2str(p),' out of ',num2str(num_perm)];
            rri_progress_ui(progress_hdl, 'Run Permutation Test', msg);
            rri_progress_ui(progress_hdl,'',p/num_perm);
         end

         if ismember(method, [4 6])
            datamat_reorder = Treorder(:,p);
            behavdata_reorder = reorder(:,p);
         elseif ismember(method, [3 5])
            datamat_reorder = [1:size(stacked_datamat,1)]';
            behavdata_reorder = reorder(:,p);
         else
            datamat_reorder = reorder(:,p);
            behavdata_reorder = [];
         end

	 %  Check for upcoming NaN and re-sample if necessary.
	 %  this only happened on behavior analysis, because the
	 %  'xcor' inside of 'rri_corr_maps' contains a 'stdev', which
	 %  is a divident. If it is 0, it will cause divided by 0
	 %  problem.
	 %  since this happend very rarely, so the speed will not
	 %  be affected that much.
	 %
         if ismember(method, [3 4 5 6])
            behav_p = stacked_behavdata(behavdata_reorder,:);

            for g = 1:num_groups
               if ~iscell(num_subj_lst)
                  n = num_subj_lst(g);
                  span = sum(num_subj_lst(1:g-1)) * k;

                  min1 = min(std(behav_p(1+span:n*k+span,:)));
                  count = 0;

                  while (min1 == 0)
                     if ismember(method, [4 6])
                        reorder(:,p) = [rri_randperm_notall(num_subj_lst, k, bscan)'];
                        behavdata_reorder = reorder(:,p);
                     elseif ismember(method, [3 5])
                        reorder(:,p) = [randperm(size(stacked_datamat,1))'];
                        behavdata_reorder = reorder(:,p);
                     end

                     behav_p = stacked_behavdata(behavdata_reorder,:);
                     min1 = min(std(behav_p(1+span:n*k+span,:)));
                     count = count + 1;

                     if count > 100
                        msg = 'Please check your behavior data, and make ';
                        msg = [msg 'sure none of the columns are all the '];
                        msg = [msg 'same for each group'];

                        disp(' '); disp(msg);
                        return;
                     end	% if count
                  end		% while min1

                  if count>0 & exist('permsamp','var')
                     disp(' '); disp('permsamp changed'); disp(' ');
                  end
               else
                  n = num_subj_lst{g};
                  span = sum([num_subj_lst{1:g-1}]);

                  min1 = min(std(behav_p(1+span:sum(n)+span,:)));
                  count = 0;

                  while (min1 == 0)
                     if ismember(method, [4 6])
                        reorder(:,p) = [ssb_rri_randperm_notall(num_subj_lst, k, bscan)'];
                        behavdata_reorder = reorder(:,p);
                     elseif ismember(method, [3 5])
                        reorder(:,p) = [randperm(size(stacked_datamat,1))'];
                        behavdata_reorder = reorder(:,p);
                     end

                     behav_p = stacked_behavdata(behavdata_reorder,:);
                     min1 = min(std(behav_p(1+span:sum(n)+span,:)));
                     count = count + 1;

                     if count > 100
                        msg = 'Please check your behavior data, and make ';
                        msg = [msg 'sure none of the columns are all the '];
                        msg = [msg 'same for each group'];

                        disp(' '); disp(msg);
                        return;
                     end	% if count
                  end		% while min1

                  if count>0 & exist('permsamp','var')
                     disp(' '); disp('permsamp changed'); disp(' ');
                  end
               end	% if ~iscell(num_subj_lst)
            end		% for g
         end		% if ismember

         [datamatsvd, datamatsvd_unnorm] = rri_get_covcor(method, ...
		stacked_datamat, stacked_behavdata, num_groups, ...
		num_subj_lst, num_cond, bscan, meancentering_type, ...
		cormode, single_cond_lst, 0, 0, datamat_reorder, ...
		behavdata_reorder);

         if ismember(method, [2 5 6])	% non-rotated PLS
            crossblock = normalize(stacked_designdata)'*datamatsvd;
            sperm = sqrt(sum(crossblock.^2,2));
            sp = sp + (sperm >= s);
         else				% SVD, observed
            %  Singular Value Decomposition, permuted
            %
            [r c] = size(datamatsvd);
            if r <= c
               [pu, sperm, pv] = svd(datamatsvd',0);
            else
               [pv, sperm, pu] = svd(datamatsvd,0);
            end

            %  rotate pv to align with the original v
            %
            rotatemat = rri_bootprocrust(v, pv);

            %  rescale the vectors
            %
            pv = pv * sperm * rotatemat;

            sperm = sqrt(sum(pv.^2));

            if ~ismember(method,[4 6])
               sp = sp + (sperm'>=s);
            else
               ptotal_s = sum(datamatsvd_unnorm(:).^2);
               per = diag(sperm).^2 / sum(diag(sperm).^2);
               sperm = sqrt(per * ptotal_s);
               pv = normalize(pv) * diag(sperm);
               sp = sp + (sperm>=org_s);
               vp = vp + (abs(pv) >= abs(org_v));
            end		% if method
         end		% if ismember

         if isempty(progress_hdl)
            if pcntacc > 70
               fprintf('\n');
               pcntacc = 0;
            end
         end
      end		% for num_perm

      if isempty(progress_hdl)
         fprintf('\n');
      end

      %  Save perm_result
      %
      result.perm_result.num_perm = num_perm;
      result.perm_result.sp = sp;
      result.perm_result.sprob = sp ./ (num_perm + 1);

      if ismember(method, [4 6])
         result.perm_result.permsamp = reorder;
         result.perm_result.Tpermsamp = Treorder;
      else
         result.perm_result.permsamp = reorder;
      end

%      if ismember(method, [4 6])	% method == 4
 %        result.perm_result.vprob = vp ./ (num_perm + 1);
  %    end

     else	%%%%%%%%%%%%%%%%%%   SPLITHALF   %%%%%%%%%%%%%%%%%%%%

      num_lvs = size(u,2);
      num_perm = num_perm + 1;
   sp = zeros(size(s));
      vp = zeros(size(v));

      if isempty(progress_hdl)
         fprintf('\nMaking resampling matrix for permutation ...\n');
      end

      if ismember(method, [4 6])
         if ~iscell(num_subj_lst)
            Treorder = rri_perm_order(num_subj_lst, k, num_perm, is_struct);

            for p = 1:num_perm
               reorder(:,p) = [rri_randperm_notall(num_subj_lst, k, bscan)'];
            end
         else
            Treorder = ssb_rri_perm_order(num_subj_lst, k, num_perm, is_struct);

            for p = 1:num_perm
               reorder(:,p) = [ssb_rri_randperm_notall(num_subj_lst, k, bscan)'];
            end
         end
      elseif ismember(method, [3 5])
         for p = 1:num_perm
            reorder(:,p) = [randperm(size(stacked_datamat,1))'];
         end
      else
         if ~iscell(num_subj_lst)
            reorder = rri_perm_order(num_subj_lst, k, num_perm, is_struct);
         else
            reorder = ssb_rri_perm_order(num_subj_lst, k, num_perm, is_struct);
         end
      end

      if exist('permsamp','var')
         reorder = permsamp;
      end

      if exist('Tpermsamp','var')
         Treorder = Tpermsamp;
      end

      if isempty(progress_hdl)
         pcntacc = fprintf('Working on %d permutations:', num_perm);
      end

      for p = 1:num_perm

         if isempty(progress_hdl)
            pcntacc = pcntacc + fprintf(' %d', p);
         else
            msg = ['Working on Permutation:  ',num2str(p),' out of ',num2str(num_perm)];
            rri_progress_ui(progress_hdl, 'Run Permutation Test', msg);
            rri_progress_ui(progress_hdl,'',p/num_perm);
         end

         if ismember(method, [4 6])
            datamat_reorder = Treorder(:,p);
            behavdata_reorder = reorder(:,p);
         elseif ismember(method, [3 5])
            datamat_reorder = [1:size(stacked_datamat,1)]';
            behavdata_reorder = reorder(:,p);
         else
            datamat_reorder = reorder(:,p);
            behavdata_reorder = [];
         end

	 %  Check for upcoming NaN and re-sample if necessary.
	 %  this only happened on behavior analysis, because the
	 %  'xcor' inside of 'rri_corr_maps' contains a 'stdev', which
	 %  is a divident. If it is 0, it will cause divided by 0
	 %  problem.
	 %  since this happend very rarely, so the speed will not
	 %  be affected that much.
	 %
         if ismember(method, [3 4 5 6])
            behav_p = stacked_behavdata(behavdata_reorder,:);

            for g = 1:num_groups
               if ~iscell(num_subj_lst)
                  n = num_subj_lst(g);
                  span = sum(num_subj_lst(1:g-1)) * k;

                  min1 = min(std(behav_p(1+span:n*k+span,:)));
                  count = 0;

                  while (min1 == 0)
                     if ismember(method, [4 6])
                        reorder(:,p) = [rri_randperm_notall(num_subj_lst, k, bscan)'];
                        behavdata_reorder = reorder(:,p);
                     elseif ismember(method, [3 5])
                        reorder(:,p) = [randperm(size(stacked_datamat,1))'];
                        behavdata_reorder = reorder(:,p);
                     end

                     behav_p = stacked_behavdata(behavdata_reorder,:);
                     min1 = min(std(behav_p(1+span:n*k+span,:)));
                     count = count + 1;

                     if count > 100
                        msg = 'Please check your behavior data, and make ';
                        msg = [msg 'sure none of the columns are all the '];
                        msg = [msg 'same for each group'];

                        disp(' '); disp(msg);
                        return;
                     end	% if count
                  end		% while min1

                  if count>0 & exist('permsamp','var')
                     disp(' '); disp('permsamp changed'); disp(' ');
                  end
               else
                  n = num_subj_lst{g};
                  span = sum([num_subj_lst{1:g-1}]);

                  min1 = min(std(behav_p(1+span:sum(n)+span,:)));
                  count = 0;

                  while (min1 == 0)
                     if ismember(method, [4 6])
                        reorder(:,p) = [ssb_rri_randperm_notall(num_subj_lst, k, bscan)'];
                        behavdata_reorder = reorder(:,p);
                     elseif ismember(method, [3 5])
                        reorder(:,p) = [randperm(size(stacked_datamat,1))'];
                        behavdata_reorder = reorder(:,p);
                     end

                     behav_p = stacked_behavdata(behavdata_reorder,:);
                     min1 = min(std(behav_p(1+span:sum(n)+span,:)));
                     count = count + 1;

                     if count > 100
                        msg = 'Please check your behavior data, and make ';
                        msg = [msg 'sure none of the columns are all the '];
                        msg = [msg 'same for each group'];

                        disp(' '); disp(msg);
                        return;
                     end	% if count
                  end		% while min1

                  if count>0 & exist('permsamp','var')
                     disp(' '); disp('permsamp changed'); disp(' ');
                  end
               end	% if ~iscell(num_subj_lst)
            end		% for g
         end		% if ismember

         [datamatsvd, datamatsvd_unnorm] = rri_get_covcor(method, ...
		stacked_datamat, stacked_behavdata, num_groups, ...
		num_subj_lst, num_cond, bscan, meancentering_type, ...
		cormode, single_cond_lst, 0, 0, datamat_reorder, ...
		behavdata_reorder);

         if ismember(method, [2 5 6])	% non-rotated PLS
            crossblock = normalize(stacked_designdata)'*datamatsvd;
            sperm = sqrt(sum(crossblock.^2,2));
            sp = sp + (sperm >= s);
         else				% SVD, observed
            %  Singular Value Decomposition, permuted
            %
            [r c] = size(datamatsvd);
            if r <= c
               [pu, sperm, pv] = svd(datamatsvd',0);
            else
               [pv, sperm, pu] = svd(datamatsvd,0);
            end

            %  rotate pv to align with the original v
            %
            rotatemat = rri_bootprocrust(v, pv);

            %  rescale the vectors
            %
            pv = pv * sperm * rotatemat;

            sperm = sqrt(sum(pv.^2));

            if ~ismember(method,[4 6])
               sp = sp + (sperm'>=s);
            else
               ptotal_s = sum(datamatsvd_unnorm(:).^2);
               per = diag(sperm).^2 / sum(diag(sperm).^2);
               sperm = sqrt(per * ptotal_s);
               pv = normalize(pv) * diag(sperm);
               sp = sp + (sperm>=org_s);
               vp = vp + (abs(pv) >= abs(org_v));
            end		% if method
         end		% if ismember

         if isempty(progress_hdl)
            if pcntacc > 70
               fprintf('\n');
               pcntacc = 0;
            end
         end
      end		% for num_perm

      if isempty(progress_hdl)
         fprintf('\n');
      end

      %  Save perm_result
      %
      result.perm_result.num_perm = num_perm;
      result.perm_result.sp = sp;
      result.perm_result.sprob = sp ./ (num_perm + 1);

      if ismember(method, [4 6])
         result.perm_result.permsamp = reorder;
         result.perm_result.Tpermsamp = Treorder;
      else
         result.perm_result.permsamp = reorder;
      end
      
      
      %  split brain and behav data (each group of subjects is split into
      %  1st and 2nd half)
      %
      %  get rows that correspond to 1st half and 2nd half of subjects 
      %  within original datamat
      %
      num_subj_lst1 = round(num_subj_lst/2); 
      num_subj_lst2 = num_subj_lst - num_subj_lst1;
      rows1 = []; 
      rows2 = [];  

      for g = 1:num_groups
         tmp = reshape([1:num_subj_lst(g)*k], num_subj_lst(g), k);

         tmp1 = tmp(1:num_subj_lst1(g),:);
         tmp1 = tmp1(:); 
         tmp2 = tmp(num_subj_lst1(g)+[1:num_subj_lst2(g)],:);
         tmp2 = tmp2(:); 

         offset = sum(num_subj_lst(1:g-1)) * k;

         rows1 = [rows1;  offset + tmp1];
         rows2 = [rows2;  offset + tmp2];
      end

      if ismember(method, [4 6])
         Treorder = missnk_rri_perm_order(num_subj_lst, k, num_perm, is_struct);

%         for p = 1:num_perm
%            Breorder(:,p) = [rri_randperm_notall(num_subj_lst, k, bscan)'];
%         end
%%%         Breorder = missnk_rri_perm_order_notall(num_subj_lst, k, num_perm, bscan, is_struct);
         Breorder = Treorder;
         reorder = [1:size(stacked_behavdata,1)]';
      elseif ismember(method, [3 5])
%         for p = 1:num_perm
%            reorder(:,p) = [randperm(size(stacked_datamat,1))'];
%         end
         reorder = missnk_rri_perm_order(num_subj_lst, k, num_perm, is_struct);
      else
         reorder = missnk_rri_perm_order(num_subj_lst, k, num_perm, is_struct);
      end

      if exist('permsamp','var')
         reorder = permsamp;
      end

      if exist('Tpermsamp','var')
         Treorder = Tpermsamp;
      end

      if exist('Bpermsamp','var')
         Breorder = Bpermsamp;
      end

      sop = zeros(num_lvs,1);	% count sprob in official nonrotated style

      %  Create null distribution, do permutations
      %  op=1 corresponds to original effects in unpermuted data
      %
      %  estimate reliability of u_op/v_op through splihalf resampling
      %  create distribution of ucorr and vcorr

      %  (op lv), mean ucorr across inner perms
      %
      ucorr_distrib = zeros([num_perm num_lvs]);

      %  (op lv), mean vcorr across inner perms
      %
      vcorr_distrib = zeros([num_perm num_lvs]);

      if isempty(progress_hdl)
         fprintf('Working on %d outer permutation:\n',num_perm);
      end

      if exist('progress_hdl', 'var')
         opt.progress_hdl = progress_hdl;
      end

      if ismember(method, [4 6])
         if exist('Treorder', 'var')
            opt.Treorder = Treorder;
         end

         if exist('Breorder', 'var')
            opt.Breorder = Breorder;
         end
      end

      if exist('reorder', 'var')
         opt.reorder = reorder;
      end

      if exist('stacked_behavdata', 'var')
         opt.stacked_behavdata = stacked_behavdata;
      end

      if exist('stacked_designdata', 'var')
         opt.stacked_designdata = stacked_designdata;
      end

      is_par = exist('matlabpool','file');

      if is_par & matlabpool('size') > 0
         [sop, ucorr_distrib, vcorr_distrib] = splithalf_perm_par(sop, ...
		ucorr_distrib, vcorr_distrib, num_perm, num_split, num_lvs, ...
		num_groups, num_cond, num_subj_lst, num_subj_lst1, num_subj_lst2, ...
		rows1, rows2, meancentering_type, cormode, single_cond_lst, ...
		method, s, org_s, org_v, bscan, stacked_datamat, opt);
      else
         [sop, ucorr_distrib, vcorr_distrib] = splithalf_perm_nopar(sop, ...
		ucorr_distrib, vcorr_distrib, num_perm, num_split, num_lvs, ...
		num_groups, num_cond, num_subj_lst, num_subj_lst1, num_subj_lst2, ...
		rows1, rows2, meancentering_type, cormode, single_cond_lst, ...
		method, s, org_s, org_v, bscan, stacked_datamat, opt);
      end

      ucorr_distrib = ucorr_distrib / num_split; %(op, lv) format
      vcorr_distrib = vcorr_distrib / num_split; %(op, lv) format

      %  Save perm_splithalf
      %
      result.perm_splithalf.num_outer_perm = num_perm;
      result.perm_splithalf.num_split = num_split;
      result.perm_splithalf.orig_ucorr = ucorr_distrib(1,:);
      result.perm_splithalf.orig_vcorr = vcorr_distrib(1,:);

      %  calculate corr p-vals (probability of surpassing orig corr)
      %
      result.perm_splithalf.ucorr_prob = zeros(1,num_lvs);
      result.perm_splithalf.vcorr_prob = zeros(1,num_lvs);

      for lv = 1:num_lvs
         result.perm_splithalf.ucorr_prob(lv) = sum(ucorr_distrib(2:end,lv) > ucorr_distrib(1,lv)) ./ (num_perm-1);
         result.perm_splithalf.vcorr_prob(lv) = sum(vcorr_distrib(2:end,lv) > vcorr_distrib(1,lv)) ./ (num_perm-1);
      end

      %  alternatively calculate CI's for ucorr, vcorr 
      %  based on null distribution
      %
      result.perm_splithalf.ucorr_ll = percentile(ucorr_distrib(2:end,:),100-clim);
      result.perm_splithalf.ucorr_ul = percentile(ucorr_distrib(2:end,:),clim);
      result.perm_splithalf.vcorr_ll = percentile(vcorr_distrib(2:end,:),100-clim);
      result.perm_splithalf.vcorr_ul = percentile(vcorr_distrib(2:end,:),clim);

%       %  Save perm_result
%       %
%       result.perm_result.num_perm = num_perm - 1;
%       result.perm_result.sp = sop;
%       result.perm_result.sprob = sop/(num_perm - 1);
% 
%       if ismember(method, [4 6])
%          result.perm_result.permsamp = reorder;
%          result.perm_result.Tpermsamp = Treorder;
%          result.perm_result.Bpermsamp = Breorder;
%       else
%          result.perm_result.permsamp = reorder;
%      end

     end	% if ~is_perm_splithalf

     result.perm_result.is_perm_splithalf = is_perm_splithalf;

   end	% if perm

   %-------------------------_______________________-----------------------

   if num_boot > 0

      %  keeps track of number of times a new bootstrap had to be generated
      %
      countnewtotal=0;
      num_LowVariability_behav_boots = [];
      badbeh = [];

      if isempty(progress_hdl)
         fprintf('\nMaking resampling matrix for bootstrap ...\n');
      end

      %  include original un-resampled order only for mean-centering task PLS
      %
      if method == 1 | nonrotated_boot
         incl_seq = 1;
      else
         incl_seq = 0;
      end

      if ~iscell(num_subj_lst)
         [reorder, new_num_boot] = rri_boot_order(num_subj_lst, k, ...
		num_boot, [1:k], incl_seq, boot_type);

         if ismember(method, [4 6])
            [reorder_4beh, new_num_boot2] = rri_boot_order(num_subj_lst, k, ...
		num_boot, bscan, incl_seq, boot_type);

            if new_num_boot2 < new_num_boot
               new_num_boot = new_num_boot2;
            end
         elseif ismember(method, [3 5])
            reorder_4beh = reorder;
         end
      else
         [reorder, new_num_boot] = ssb_rri_boot_order(num_subj_lst, k, ...
		num_boot, [1:k], incl_seq);

         if ismember(method, [4 6])
            [reorder_4beh, new_num_boot2] = ssb_rri_boot_order(num_subj_lst, k, ...
		num_boot, bscan, incl_seq);

            if new_num_boot2 < new_num_boot
               new_num_boot = new_num_boot2;
            end
         elseif ismember(method, [3 5])
            reorder_4beh = reorder;
         end
      end

      if isempty(reorder)
         error('bootstrap order is not available');
      end;

      if ismember(method, [3 4 5 6]) & isempty(reorder_4beh)
         error('bootstrap order is not available');
      end;

      if exist('bootsamp','var')
         reorder = bootsamp;
      end

      if exist('bootsamp_4beh','var')
         reorder_4beh = bootsamp_4beh;
      end

      if new_num_boot ~= num_boot
         num_boot = new_num_boot;
      end

      if ismember(method, [3 4 5 6])
         orig_corr = lvcorrs;

         [r1 c1] = size(orig_corr);
         distrib = zeros(r1, c1, num_boot+1);
         distrib(:, :, 1) = orig_corr;
      end

      if ismember(method, [1 2 4 6])
         orig_usc = [];

         first = 1;
         last = 0;

         if ~iscell(num_subj_lst)
            for g = 1:num_groups
               last = last + k*num_subj_lst(g);

               if ismember(method, [2 6])
                  orig_usc = [orig_usc; rri_task_mean(usc(first:last,:), num_subj_lst(g))];
               else
                  orig_usc = [orig_usc; rri_task_mean(usc2(first:last,:), num_subj_lst(g))];
               end

               first = last + 1;
            end

            if ismember(method, [4 6])
               orig_usc = [];

               first = 1;
               last = 0;

               for g = 1:num_groups
                  last = last + k*num_subj_lst(g);

                  if method == 6
                     orig_usc = [orig_usc; rri_task_mean(usc(first:last,:), num_subj_lst(g))];
                  else
                     orig_usc = [orig_usc; rri_task_mean(usc2(first:last,:), num_subj_lst(g))];
                  end

                  first = last + 1;
               end

               [r2 c2] = size(orig_usc);
               Tdistrib = zeros(r2, c2, num_boot+1);
               Tdistrib(:, :, 1) = orig_usc;
            else
               [r1 c1] = size(orig_usc);
               distrib = zeros(r1, c1, num_boot+1);
               distrib(:, :, 1) = orig_usc;
            end
         else
            for g = 1:num_groups
               last = last + sum(num_subj_lst{g});

               if ismember(method, [2 6])
                  orig_usc = [orig_usc; ssb_rri_task_mean(usc(first:last,:), num_subj_lst{g})];
               else
                  orig_usc = [orig_usc; ssb_rri_task_mean(usc2(first:last,:), num_subj_lst{g})];
               end

               first = last + 1;
            end

            if ismember(method, [4 6])
               orig_usc = [];

               first = 1;
               last = 0;

               for g = 1:num_groups
                  last = last + sum(num_subj_lst{g});

                  if method == 6
                     orig_usc = [orig_usc; ssb_rri_task_mean(usc(first:last,:), num_subj_lst{g})];
                  else
                     orig_usc = [orig_usc; ssb_rri_task_mean(usc2(first:last,:), num_subj_lst{g})];
                  end

                  first = last + 1;
               end

               [r2 c2] = size(orig_usc);
               Tdistrib = zeros(r2, c2, num_boot+1);
               Tdistrib(:, :, 1) = orig_usc;
            else
               [r1 c1] = size(orig_usc);
               distrib = zeros(r1, c1, num_boot+1);
               distrib(:, :, 1) = orig_usc;
            end
         end		% if ~iscell(num_subj_lst)
      end		% if ismember(method, [1 2 4 6])

      max_subj_per_group = 8;

      if ~iscell(num_subj_lst)
         if (sum(num_subj_lst <= max_subj_per_group) == num_groups)
            is_boot_samples = 1;
         else
            is_boot_samples = 0;
         end
      else
         if all([num_subj_lst{:}] <= max_subj_per_group)
            is_boot_samples = 1;
         else
            is_boot_samples = 0;
         end
      end

      switch method
      case 1
         u_sum = zeros(size(u));
%         v_sum = zeros(size(v));
      case {2, 5, 6}
         u_sum = u;
%         v_sum = v;
      case {3, 4}
         u_sum = original_u;
%         v_sum = original_v;
      end

      if nonrotated_boot
         u_sum = zeros(size(u));
%         v_sum = zeros(size(v));
      end

      u_sq = u_sum.^2;
%      v_sq = v_sum.^2;

      if ismember(method, [3 4 5 6])

         %  Check min% unique values for all behavior variables
         %
         num_LowVariability_behav_boots = zeros(1, size(stacked_behavdata, 2));

         for bw = 1:size(stacked_behavdata, 2)
            for p = 1:num_boot
               vv = stacked_behavdata(reorder_4beh(:,p),bw);

               if rri_islowvariability(vv, stacked_behavdata(:,bw))
                  num_LowVariability_behav_boots(bw) = num_LowVariability_behav_boots(bw) + 1;
               end
            end
         end

         if any(num_LowVariability_behav_boots)
            disp(' ');
            disp(' ');
            disp('For at least one behavior measure, the minimum unique values of resampled behavior data does not exceed 50% of its total.');
            disp(' ');
            disp(' ');
         end
      end	% if ismember(method, [3 4 5 6])

      if isempty(progress_hdl)
         pcntacc = fprintf('Working on %d bootstraps:', num_boot);
      end

      for p=1:num_boot

         if isempty(progress_hdl)
            pcntacc = pcntacc + fprintf(' %d', p);
         else
            msg = ['Working on Bootstrap:  ',num2str(p),' out of ',num2str(num_boot)];
            rri_progress_ui(progress_hdl, 'Run Bootstrap Test', msg);
            rri_progress_ui(progress_hdl,'',p/num_boot);
         end

         datamat_reorder = reorder(:,p);

         if ismember(method,[3 4 5 6])
            datamat_reorder_4beh = reorder_4beh(:,p);
            behavdata_reorder = reorder_4beh(:,p);
         else
            datamat_reorder_4beh = [];
            behavdata_reorder = [];
         end

         step = 0;

         for g = 1:num_groups

            %  check reorder for badbehav
            %
            if ismember(method,[3 4 5 6])
               if ~iscell(num_subj_lst)

                   n = num_subj_lst(g);
                   span = sum(num_subj_lst(1:g-1)) * k;	% group length

                   if ~is_boot_samples

                      % the code below is mainly trying to find a proper
                      % reorder matrix

                      % init badbehav array to 0
                      % which is used to record the bad behav data caused by
                      % bad re-order. This variable is for disp only.
                      %
                      badbehav = zeros(k, size(stacked_behavdata,2));

                      % Check for upcoming NaN and re-sample if necessary.
                      % this only happened on behavior analysis, because the
                      % 'xcor' inside of 'corr_maps' contains a 'stdev', which
                      % is a divident. If it is 0, it will cause divided by 0
                      % problem.
                      % since this happend very rarely, so the speed will not
                      % be affected that much.
                      %
                      % For behavpls_boot, also need to account for multiple
                      % scans and behavs
                      %
                      for c=1:k	% traverse all conditions in this group
                          stdmat(c,:) = std(stacked_behavdata(reorder_4beh((1+ ...
				(n*(c-1))+span):(n*c+span), p), :));
                      end		% scanloop

                      % now, check to see if any are zero
                      %
                      while sum(stdmat(:)==0)>0
                          countnewtotal = countnewtotal + 1;

                          % keep track of scan & behav that force a resample
                          %
                          badbehav(find(stdmat(:)==0)) = ...
				badbehav(find(stdmat(:)==0)) + 1;

                          badbeh{g,countnewtotal} = badbehav;	% save instead of disp

                          % num_boot is just something to be picked to prevent
                          % infinite loop
                          %
                          if countnewtotal > num_boot
                              disp('Please check behavior data');
                              breakon=1;
                              break;
                          end

                          reorder_4beh(:,p) = rri_boot_order(num_subj_lst, k, ...
				1, [1:k], incl_seq, boot_type);

                          if ismember(method, [4 6])
                             reorder_4beh(:,p) = rri_boot_order(num_subj_lst, k, ...
				1, bscan, incl_seq, boot_type);
                          end

                          for c=1:k	% recalc stdmat
                              stdmat(c,:) = std(stacked_behavdata(reorder_4beh((1+ ...
                                 (n*(c-1))+span):(n*c+span), p), :));
                          end	% scanloop
                      end	% while

                      if countnewtotal>0 & exist('bootsamp_4beh','var')
                         disp(' '); disp('bootsamp_4beh changed'); disp(' ');
                      end

                      % now, we can use this proper reorder matrix to generate 
                      % datamat_reorder_4beh & behavdata_reorder, and then to
                      % calculate datamatcorrs
                      %
                      datamat_reorder_4beh = reorder_4beh(:,p);
                      behavdata_reorder = reorder_4beh(:,p);

                   end	% if ~is_boot_samples
               else

                   n = num_subj_lst{g};

                   if ~is_boot_samples

                      % the code below is mainly trying to find a proper
                      % reorder matrix

                      % init badbehav array to 0
                      % which is used to record the bad behav data caused by
                      % bad re-order. This variable is for disp only.
                      %
                      badbehav = zeros(k, size(stacked_behavdata,2));

                      % Check for upcoming NaN and re-sample if necessary.
                      % this only happened on behavior analysis, because the
                      % 'xcor' inside of 'corr_maps' contains a 'stdev', which
                      % is a divident. If it is 0, it will cause divided by 0
                      % problem.
                      % since this happend very rarely, so the speed will not
                      % be affected that much.
                      %
                      % For behavpls_boot, also need to account for multiple
                      % scans and behavs
                      %
                      step1 = step;	% group step, for step2 below

                      for c=1:k	% traverse all conditions in this group
                          stdmat(c,:) = ...
				std(stacked_behavdata(reorder_4beh((1:n(c))+step, p), :));

                         step=step+n(c);
                      end		% scanloop

                      % now, check to see if any are zero
                      %
                      while sum(stdmat(:)==0)>0
                          step2 = 0;	% condition step
                          countnewtotal = countnewtotal + 1;

                          % keep track of scan & behav that force a resample
                          %
                          badbehav(find(stdmat(:)==0)) = ...
				badbehav(find(stdmat(:)==0)) + 1;

                          badbeh{g,countnewtotal} = badbehav;	% save instead of disp

                          % num_boot is just something to be picked to prevent
                          % infinite loop
                          %
                          if countnewtotal > num_boot
                              disp('Please check behavior data');
                              breakon=1;
                              break;
                          end

                          reorder_4beh(:,p) = ssb_rri_boot_order(num_subj_lst, k, ...
				1, [1:k], incl_seq);

                          if ismember(method, [4 6])
                             reorder_4beh(:,p) = ssb_rri_boot_order(num_subj_lst, k, ...
				1, bscan, incl_seq);
                          end

                          for c=1:k	% recalc stdmat
                             stdmat(c,:) = ...
				std(stacked_behavdata(reorder_4beh((1:n(c))+step1+step2, p), :));

                             step2=step2+1;
                          end	% scanloop
                      end	% while

                      if countnewtotal>0 & exist('bootsamp_4beh','var')
                         disp(' '); disp('bootsamp_4beh changed'); disp(' ');
                      end

                      % now, we can use this proper reorder matrix to generate 
                      % datamat_reorder_4beh & behavdata_reorder, and then to
                      % calculate datamatcorrs
                      %
                      datamat_reorder_4beh = reorder_4beh(:,p);
                      behavdata_reorder = reorder_4beh(:,p);

                   end	% if ~is_boot_samples

               end	% if ~iscell(num_subj_lst)
            end		% if ismember(method,[3 4 5 6])

            [datamatsvd, datamatsvd_unnorm, datamatcorrs_lst, ...
		stacked_smeanmat] = rri_get_covcor(method, ...
		stacked_datamat, stacked_behavdata, num_groups, ...
		num_subj_lst, num_cond, bscan, meancentering_type, ...
		cormode, single_cond_lst, 1, num_boot, datamat_reorder, ...
		behavdata_reorder, datamat_reorder_4beh);

         end		% for num_groups

         if nonrotated_boot		% Natasha's Non Rotated Bootstrap

            %  project effect (v) onto voxel space
            %
            u_p = datamatsvd' * v;	% brain factor score
      
            %  project brain pattern (u) onto effect space
            %
            v_p =  datamatsvd * u;	% effect factor score
      
            %  update calculations for bootstrap raratios (signal and error)
            %
            u_sum = u_sum + u_p;
            u_sq = u_sq + u_p.^2;
%            v_sum = v_sum + v_p;
%            v_sq = v_sq + v_p.^2;

            %  record distrib, Tdistrib
            %
            if ismember(method,[5 6])
               data_p = stacked_datamat(datamat_reorder_4beh(row_idx),:);
               behav_p = stacked_behavdata(behavdata_reorder(row_idx),:);

               if ~iscell(num_subj_lst)
                  [brainsctmp, behavsctmp, bcorr] = ...
			rri_get_behavscores(data_p, behav_p, normalize(u_p), ...
			stacked_designdata, kk, num_subj_lst, cormode);
               else
                  [brainsctmp, behavsctmp, bcorr] = ...
			ssb_rri_get_behavscores(data_p, behav_p, normalize(u_p), ...
			stacked_designdata, kk, num_subj_lst_4beh, cormode);
               end

               distrib(:,:,p+1) = bcorr;
            end

            if ismember(method,[3 4])
               data_p = stacked_datamat(datamat_reorder_4beh(row_idx),:);
               behav_p = stacked_behavdata(behavdata_reorder(row_idx),:);

               if ~iscell(num_subj_lst)
                  [brainsctmp, behavsctmp, bcorr] = ...
			rri_get_behavscores(data_p, behav_p, normalize(u_p), ...
			normalize(v_p), kk, num_subj_lst, cormode);
               else
                  [brainsctmp, behavsctmp, bcorr] = ...
			ssb_rri_get_behavscores(data_p, behav_p, normalize(u_p), ...
			normalize(v_p), kk, num_subj_lst_4beh, cormode);
               end

               distrib(:,:,p+1) = bcorr;
            end

            if ismember(method, [1 2 4 6])
               tmp_usc2 = stacked_smeanmat * normalize(u_p);
               tmp_orig_usc = [];

               first = 1;
               last = 0;

               for g = 1:num_groups
                  if ~iscell(num_subj_lst)
                     last = last + k*num_subj_lst(g);
                     tmp_orig_usc = [tmp_orig_usc; rri_task_mean(tmp_usc2(first:last,:), num_subj_lst(g))];
                  else
                     last = last + sum(num_subj_lst{g});
                     tmp_orig_usc = [tmp_orig_usc; ssb_rri_task_mean(tmp_usc2(first:last,:), num_subj_lst{g})];
                  end

                  first = last + 1;
               end

               if ismember(method, [1 2])
                  distrib(:, :, p+1) = tmp_orig_usc;
               elseif ismember(method, [4 6])
                  Tdistrib(:, :, p+1) = tmp_orig_usc;
               end
            end

         elseif ismember(method,[2 5 6])	% non-rotated PLS (Rotated Bootstrap)

            crossblock = normalize(stacked_designdata)'*datamatsvd;

            if ismember(method,[5 6])
               data_p = stacked_datamat(datamat_reorder_4beh(row_idx),:);
               behav_p = stacked_behavdata(behavdata_reorder(row_idx),:);

               if ~iscell(num_subj_lst)
                  [brainsctmp, behavsctmp, bcorr] = ...
			rri_get_behavscores(data_p, behav_p, ...
			normalize(crossblock'), ...
			stacked_designdata, kk, num_subj_lst, cormode);
               else
                  [brainsctmp, behavsctmp, bcorr] = ...
			ssb_rri_get_behavscores(data_p, behav_p, ...
			normalize(crossblock'), ...
			stacked_designdata, kk, num_subj_lst_4beh, cormode);
               end

               distrib(:, :, p+1) = bcorr;
            end

            if ismember(method,[2 6])
               tmp_usc = stacked_datamat * normalize(crossblock');
               tmp_usc2 = stacked_smeanmat * normalize(crossblock');
               tmp_orig_usc = [];

               first = 1;
               last = 0;

               for g = 1:num_groups
                  if ~iscell(num_subj_lst)
                     last = last + k*num_subj_lst(g);
                     tmp_orig_usc = [tmp_orig_usc; rri_task_mean(tmp_usc(first:last,:), num_subj_lst(g))];
                  else
                     last = last + sum(num_subj_lst{g});
                     tmp_orig_usc = [tmp_orig_usc; ssb_rri_task_mean(tmp_usc(first:last,:), num_subj_lst{g})];
                  end

                  first = last + 1;
               end

               if method == 6
                  Tdistrib(:, :, p+1) = tmp_orig_usc;
               else
                  distrib(:, :, p+1) = tmp_orig_usc;
               end
            end

            u_sq = u_sq + (crossblock.^2)';
            u_sum = u_sum + crossblock';

         else					% svd

            %  Singular Value Decomposition
            %
            [r c] = size(datamatsvd);
            if r <= c
               [pu, sboot, pv] = svd(datamatsvd',0);
            else
               [pv, sboot, pu] = svd(datamatsvd,0);
            end

            %  rotate pv to align with the original v
            %
            rotatemat = rri_bootprocrust(v, pv);

            %  rescale the vectors
            %
            pu = pu * sboot * rotatemat;
            pv = pv * sboot * rotatemat;

            if ismember(method,[3 4])
               data_p = stacked_datamat(datamat_reorder_4beh(row_idx),:);
               behav_p = stacked_behavdata(behavdata_reorder(row_idx),:);

               if ~iscell(num_subj_lst)
                  [brainsctmp, behavsctmp, bcorr] = ...
			rri_get_behavscores(data_p, behav_p, ...
			normalize(pu), normalize(pv), kk, num_subj_lst, cormode);
               else
                  for bi=1:length(num_subj_lst)
                     num_subj_lst_4beh{bi}=num_subj_lst{bi}(bscan);
                  end

                  [brainsctmp, behavsctmp, bcorr] = ...
			ssb_rri_get_behavscores(data_p, behav_p, ...
			normalize(pu), normalize(pv), kk, num_subj_lst_4beh, cormode);
               end

               distrib(:, :, p+1) = bcorr;

               if method == 4
                  tmp_usc2 = stacked_smeanmat * normalize(pu);
                  tmp_orig_usc = [];

                  first = 1;
                  last = 0;

                  for g = 1:num_groups
                     if ~iscell(num_subj_lst)
                        last = last + k*num_subj_lst(g);
                        tmp_orig_usc = [tmp_orig_usc; rri_task_mean(tmp_usc2(first:last,:), num_subj_lst(g))];
                     else
                        last = last + sum(num_subj_lst{g});
                        tmp_orig_usc = [tmp_orig_usc; ssb_rri_task_mean(tmp_usc2(first:last,:), num_subj_lst{g})];
                     end

                     first = last + 1;
                  end

                  Tdistrib(:, :, p+1) = tmp_orig_usc;
               end

            elseif method == 1
               tmp_usc2 = stacked_smeanmat * normalize(pu);
               tmp_orig_usc = [];

               first = 1;
               last = 0;

               for g = 1:num_groups
                  if ~iscell(num_subj_lst)
                     last = last + k*num_subj_lst(g);
                     tmp_orig_usc = [tmp_orig_usc; rri_task_mean(tmp_usc2(first:last,:), num_subj_lst(g))];
                  else
                     last = last + sum(num_subj_lst{g});
                     tmp_orig_usc = [tmp_orig_usc; ssb_rri_task_mean(tmp_usc2(first:last,:), num_subj_lst{g})];
                  end

                  first = last + 1;
               end

               distrib(:, :, p+1) = tmp_orig_usc;
            end

            u_sum = u_sum + pu;
            u_sq = u_sq + pu.^2;

%            v_sum = v_sum + pv;
%            v_sq = v_sq + pv.^2;

         end		% if nonrotated_boot

         if isempty(progress_hdl)
            if pcntacc > 70
               fprintf('\n');
               pcntacc = 0;
            end
         end

      end		% for num_boot

      fprintf('\n');

      result.boot_result.num_boot = num_boot;
      result.boot_result.clim = clim;
      result.boot_result.num_LowVariability_behav_boots = num_LowVariability_behav_boots;

      result.boot_result.boot_type = boot_type;
      result.boot_result.nonrotated_boot = nonrotated_boot;

    if nonrotated_boot

         u_sum2 = (u_sum.^2) / (num_boot);
%         v_sum2 = (v_sum.^2) / (num_boot);

         %  compute standard errors - standard deviation of bootstrap sample
         %  since original sample is part of bootstrap, divide by number of
         %  bootstrap iterations rather than number of bootstraps minus 1
         %
         %  add ceiling to calculations to prevent the following operations
         %  from producing negative/complex numbers
         %
         %  used abs instead of ceil. 02-jan-2007
         %
         if 0 % method == 3
            u_se = sqrt((ceil(u_sq)-ceil(u_sum2))/(num_boot-1));
%            v_se = sqrt((ceil(v_sq)-ceil(v_sum2))/(num_boot-1));
         else
            u_se = sqrt(abs(u_sq-u_sum2)/(num_boot-1));
%            v_se = sqrt(abs(v_sq-v_sum2)/(num_boot-1));
         end

    else

      switch method
      case 1

         u_sum2 = (u_sum.^2) / (num_boot);
%         v_sum2 = (v_sum.^2) / (num_boot);

         u_se = sqrt(abs(u_sq-u_sum2) / (num_boot-1));
%         v_se = sqrt(abs(v_sq-v_sum2) / (num_boot-1));

      case 2

         %  calculate standard error
         %
         u_sum2 = (u_sum.^2) / (num_boot+1);
%         v_sum2 = (v_sum.^2) / (num_boot+1);

         u_se = sqrt(abs(u_sq-u_sum2) / num_boot);
%         v_se = sqrt(abs(v_sq-v_sum2) / num_boot);

      case {3, 4, 5, 6}

         u_sum2 = (u_sum.^2) / (num_boot+1);
%         v_sum2 = (v_sum.^2) / (num_boot+1);

         %  compute standard errors - standard deviation of bootstrap sample
         %  since original sample is part of bootstrap, divide by number of
         %  bootstrap iterations rather than number of bootstraps minus 1
         %
         %  add ceiling to calculations to prevent the following operations
         %  from producing negative/complex numbers
         %
         %  used abs instead of ceil. 02-jan-2007
         %
         if 0 % method == 3
            u_se = sqrt((ceil(u_sq)-ceil(u_sum2))/(num_boot));
%            v_se = sqrt((ceil(v_sq)-ceil(v_sum2))/(num_boot));
         else
            u_se = sqrt(abs(u_sq-u_sum2)/(num_boot));
%            v_se = sqrt(abs(v_sq-v_sum2)/(num_boot));
         end

      end	% switch method

    end		% if nonrotated_boot

      %  now compare the original unstandarized saliences
      %  with the bootstrap saliences
      %
      ul=clim;
      ll=100-clim;

      % e.g. 0.05 >> 0.025 for upper & lower tails, two-tailed
      %
      climNi = 0.5*(1-(clim*0.01));

      if ismember(method, [1 2])
         [llusc, ulusc, prop, llusc_adj, ulusc_adj] = ...
            rri_distrib(distrib, ll, ul, num_boot, climNi, orig_usc);
      else
         [llcorr, ulcorr, prop, llcorr_adj, ulcorr_adj] = ...
            rri_distrib(distrib, ll, ul, num_boot, climNi, orig_corr);
      end

      %  loop to calculate upper and lower CI limits for multiblock PLS
      %
      if ismember(method, [4 6])
         [llusc, ulusc, Tprop, llusc_adj, ulusc_adj] = ...
            rri_distrib(Tdistrib, ll, ul, num_boot, climNi, orig_usc);
      end

      if ismember(method, [3 4 5 6])

         result.boot_result.orig_corr = orig_corr;
         result.boot_result.ulcorr = ulcorr;
         result.boot_result.llcorr = llcorr;
         result.boot_result.ulcorr_adj = ulcorr_adj;
         result.boot_result.llcorr_adj = llcorr_adj;
         result.boot_result.badbeh = badbeh;
         result.boot_result.countnewtotal = countnewtotal;
         result.boot_result.bootsamp_4beh = reorder_4beh;

         if ismember(method, [4 6])

            result.boot_result.orig_usc = orig_usc;
            result.boot_result.ulusc = ulusc;
            result.boot_result.llusc = llusc;
            result.boot_result.ulusc_adj = ulusc_adj;
            result.boot_result.llusc_adj = llusc_adj;

            result.boot_result.Tprop = Tprop;
            result.boot_result.Tdistrib = Tdistrib;

         end

      elseif method == 1 | method == 2

         result.boot_result.usc2 = usc2;
         result.boot_result.orig_usc = orig_usc;
         result.boot_result.ulusc = ulusc;
         result.boot_result.llusc = llusc;
         result.boot_result.ulusc_adj = ulusc_adj;
         result.boot_result.llusc_adj = llusc_adj;

      end

      result.boot_result.prop = prop;
      result.boot_result.distrib = distrib;
      result.boot_result.bootsamp = reorder;

      % result.boot_result.u_sum2 = u_sum2;
      % result.boot_result.v_sum2 = v_sum2;

      if method == 2 | method == 5
%         result.boot_result.u = u;
 %        result.boot_result.v = v;
      else
  %       result.boot_result.orig_u = original_u;
   %      result.boot_result.orig_v = original_v;
      end

      %  check for zero standard errors - replace with ones
      %
      test_zeros=find(u_se<=0);
      if ~isempty(test_zeros);
         u_se(test_zeros)=1;
      end

%      test_zeros_v=find(v_se<=0);
 %     if ~isempty(test_zeros_v);
  %       v_se(test_zeros_v)=1;
   %   end

      if ismember(method,[2 5 6])
         if nonrotated_boot
            compare_u = original_u ./ u_se;
%            compare_v = original_v ./ v_se;
         else
            compare_u = u ./ u_se;
%            compare_v = v ./ v_se;
         end
      else
         compare_u = original_u ./ u_se;
%         compare_v = original_v ./ v_se;
      end

      %  for zero standard errors - replace bootstrap ratios with zero
      %  since the ratio makes no sense anyway
      %
      if ~isempty(test_zeros);
         compare_u(test_zeros)=0;
      end

%      if ~isempty(test_zeros_v);
 %        compare_v(test_zeros_v)=0;
  %    end

      result.boot_result.compare_u = compare_u;
%      result.boot_result.compare_v = compare_v;
      result.boot_result.u_se = u_se;
%      result.boot_result.v_se = v_se;
      result.boot_result.zero_u_se = test_zeros;
%      result.boot_result.zero_v_se = test_zeros_v;

   end	% if boot


   result.other_input.meancentering_type = meancentering_type;
   result.other_input.cormode = cormode;

   %-------------------------_______________________-----------------------

   result.field_descrip = [
'Result fields description:                                           '
'                                                                     '
'method:                 PLS option                                   '
'                        1. Mean-Centering Task PLS                   '
'                        2. Non-Rotated Task PLS                      '
'                        3. Regular Behavior PLS                      '
'                        4. Multiblock PLS                            '
'                        5. Non-Rotated Behavior PLS                  '
'                        6. Non-Rotated Multiblock PLS                '
'                                                                     '
'u:                      Brainlv or Salience                          '
'                                                                     '
's:                      Singular value                               '
'                                                                     '
'v:                      Designlv or Behavlv                          '
'                                                                     '
'usc:                    Brainscores or Scalpscores                   '
'                                                                     '
'vsc:                    Designscores or Behavscores                  '
'                                                                     '
'TBv:                    Store Task / Bahavior v separately           '
'                                                                     '
'TBusc:                  Store Task / Bahavior usc separately         '
'                                                                     '
'TBvsc:                  Store Task / Bahavior vsc separately         '
'                                                                     '
'datamatcorrs_lst:       Correlation of behavior data with datamat.   '
'                        Only available in behavior PLS.              '
'                                                                     '
'lvcorrs:                Correlation of behavior data with usc,       '
'                        only available in behavior PLS.              '
'                                                                     '
'perm_result:            struct containing permutation result         '
'        num_perm:       number of permutation                        '
'        sp:             permuted singular value greater than observed'
'        sprob:          sp normalized by num_perm                    '
'        permsamp:       permutation reorder sample                   '
'        Tpermsamp:      permutation reorder sample for multiblock PLS'
'        Bpermsamp:      permutation reorder sample for multiblock PLS'
'                                                                     '
'perm_splithalf:         struct containing permutation splithalf      '
'        num_outer_perm: permutation splithalf related                '
'        num_split:      permutation splithalf related                '
'        orig_ucorr:     permutation splithalf related                '
'        orig_vcorr:     permutation splithalf related                '
'        ucorr_prob:     permutation splithalf related                '
'        vcorr_prob      permutation splithalf related                '
'        ucorr_ul:       permutation splithalf related                '
'        ucorr_ll:       permutation splithalf related                '
'        vcorr_ul:       permutation splithalf related                '
'        vcorr_ll:       permutation splithalf related                '
'                                                                     '
'boot_result:            struct containing bootstrap result           '
'        num_boot:       number of bootstrap                          '
'        boot_type:      Set to ''nonstrat'' if using Natasha''s         '
'                        ''nonstrat'' bootstrap type; set to            '
'                        ''strat'' for conventional bootstrap.          '
'        nonrotated_boot: Set to 1 if using Natasha''s Non             '
'                        Rotated bootstrap; set to 0 for              '
'                        conventional bootstrap.                      '
'        bootsamp:       bootstrap reorder sample                     '
'        bootsamp_4beh:  bootstrap reorder sample for behav PLS       '
'        compare_u:      compared salience or compared brain          '
'        u_se:           standard error of salience or brainlv        '
'        clim:           confidence level between 0 and 100.          '
'        distrib:        orig_usc or orig_corr distribution           '
'        prop:           orig_usc or orig_corr probability            '
'                                                                     '
'        following boot_result only available in task PLS:            '
'                                                                     '
'        usc2:           brain scores that are obtained from the      '
'                        mean-centered datamat                        '
'        orig_usc:       same as usc, with mean-centering on subj     '
'        ulusc:          upper boundary of orig_usc                   '
'        llusc:          lower boundary of orig_usc                   '
'        ulusc_adj:      percentile of orig_usc distribution with     '
'                        upper boundary of orig_usc                   '
'        llusc_adj:      percentile of orig_usc distribution with     '
'                        lower boundary of orig_usc                   '
'                                                                     '
'        following boot_result only available in behavior PLS:        '
'                                                                     '
'        orig_corr:      same as lvcorrs                              '
'        ulcorr:         upper boundary of orig_corr                  '
'        llcorr:         lower boundary of orig_corr                  '
'        ulcorr_adj:     percentile of orig_corr distribution with    '
'                        upper boundary of orig_corr                  '
'        llcorr_adj:     percentile of orig_corr distribution with    '
'                        lower boundary of orig_corr                  '
'        num_LowVariability_behav_boots: display numbers of low       '
'                        variability resampled hehavior data in       '
'                        bootstrap test                               '
'        badbeh:         display bad behav data that is caused by     '
'                        bad re-order (with 0 standard deviation)     '
'                        which will further cause divided by 0        '
'        countnewtotal:  count the new sample that is re-ordered      '
'                        for badbeh                                   '
'                                                                     '
'is_struct:              Set to 1 if running Non-Behavior             '
'                        Structure PLS; set to 0 for other PLS.       '
'                                                                     '
'bscan:                  Subset of conditions that are selected       '
'                        for behav block, only in Multiblock PLS.     '
'                                                                     '
'num_subj_lst            Number of subject list array, containing     '
'                        the number of subjects in each group.        '
'                                                                     '
'num_cond                Number of conditions in datamat_lst.         '
'                                                                     '
'stacked_designdata:     Stacked design contrast data for all         '
'                        the groups.                                  '
'                                                                     '
'stacked_behavdata:      Stacked behavior data for all the groups.    '
'                                                                     '
'other_input:            struct containing other input data           '
'        meancentering_type: Use Natasha''s meancentering type         '
'                        if it is not 0.                              '
'        cormode:        Use Natasha''s correlation mode if it         '
'                        is not 0.                                    '
'                                                                     '
];

