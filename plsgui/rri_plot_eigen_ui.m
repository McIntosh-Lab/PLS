%RRI_PLOT_EIGEN_UI Plot EIGENVALUE Bar Graph
%	RRI_PLOT_EIGEN_UI plot the eigen value (s), and the permutation
%	probability in perm_result (if not empty) in bar graph
%
%  USAGE: eigen_fig = rri_plot_eigen_ui({s, perm_result, perm_splithalf, isnonrotated})
%
%--------------------------------------------------------------------

function eigen_fig = rri_plot_eigen_ui(varargin)

   if nargin == 0 | ~ischar(varargin{1})	% input is not action

      s = varargin{1}{1};
      perm_result = varargin{1}{2};

      if length(varargin{1}) > 2
         perm_splithalf = varargin{1}{3};
      else
         perm_splithalf = '';
      end

      if length(varargin{1}) > 3
         isnonrotated = varargin{1}{4};
      else
         isnonrotated = 0;
      end

      [tmp tit_fn] = rri_fileparts(get(gcf,'name'));
      eigen_fig = init(s, perm_result, perm_splithalf, isnonrotated, tit_fn);

      DisplayEigenPLSResult;
      return;

   end

   %  clear the message line,
   %
   h = findobj(gcf,'Tag','MessageLine');
   if ishandle(h)
      set(h,'String','');
   end

   action = varargin{1};

   switch action
      case {'choose_eigen'}
         choose_eigen;
      case {'choose_cross'}
         choose_cross;
      case {'choose_perm'}
         choose_perm;
      case {'toggle_perm_result'}
         toggle_perm_result;
      case {'delete_fig'}
         delete_fig;
   end

   return					% rri_plot_eigen_ui


%-------------------------------------------------------------------------

function  h0 = init(s, perm_result, perm_splithalf, isnonrotated, tit_fn)

   tit = ['PLS Singular Value Plot  [', tit_fn, ']'];

   save_setting_status = 'on';
   rri_plot_eigen_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(rri_plot_eigen_pos) & strcmp(save_setting_status,'on')

      pos = rri_plot_eigen_pos;

   else

      w = 0.5;
      h = 0.5;

      pos = [(1-w)/2 (1-h)/2 w h];

   end

   xp = 0.0227273;
   yp = 0.0294118;
   wp = 1-2*xp;
   hp = 1-2*yp;

   pos_p = [xp yp wp hp];

   h0 = figure('unit','normal', ...
        'paperunit','normal', ...
        'paperorient','land', ...
        'paperposition',pos_p, ...
        'papertype','usletter', ...
	'numberTitle','off', ...
	'menubar', 'none', ...
	'toolbar', 'none', ...
	'user','PLS Singular Value Plot', ...
	'name',tit, ...
	'deleteFcn', 'rri_plot_eigen_ui(''delete_fig'');', ...
	'position', pos);

   %  file menu
   %
   rri_file_menu(h0);

   h_view = uimenu('parent',h0, ...
        'visible','on', ...
        'label','&View');
   h1 = uimenu('parent', h_view, ...
	'checked','on', ...
	'label','&Observed Singular Values', ...
	'callback','rri_plot_eigen_ui(''choose_eigen'');',...
	'tag','eigen');
   h1 = uimenu('parent', h_view, ...
	'checked','off', ...
	'label','&Percent Crossblock Covarience', ...
	'callback','rri_plot_eigen_ui(''choose_cross'');',...
	'tag','cross');

   if ~isempty(perm_result)		% have permutation result
      h1 = uimenu('parent', h_view, ...
	'checked','off', ...
	'callback','rri_plot_eigen_ui(''choose_perm'');',...
	'tag','perm', ...
	'label','&Permuted Singular Values');

      if isfield(perm_result,'sprob')
         setappdata(h0, 'sprob', perm_result.sprob);
      else
         setappdata(h0, 'sprob', perm_result.s_prob);
      end

      setappdata(h0, 'num_perm', perm_result.num_perm);
   end;

   if ~isempty(perm_splithalf)
      setappdata(h0, 'ucorr_prob', perm_splithalf.ucorr_prob);
      setappdata(h0, 'vcorr_prob', perm_splithalf.vcorr_prob);
   else
      setappdata(h0, 'ucorr_prob', []);
      setappdata(h0, 'vcorr_prob', []);
   end;

   setappdata(h0, 'eigen', s);
   setappdata(h0, 'cross', erp_per(s));

   if 0 % isnonrotated
      setappdata(h0, 'filter', 1:length(s));
   else
      setappdata(h0, 'filter', 1:max(find(erp_per(s) >= 0.01)));
   end

   return					% init


%-------------------------------------------------------------------------

function delete_fig()

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      rri_plot_eigen_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'rri_plot_eigen_pos');
   catch
   end

   h0 = getappdata(gcbf,'main_fig');
   if isempty(h0), return; end;

   hm_eigen = getappdata(h0,'hm_eigen');
   set(hm_eigen, 'userdata',0, 'check','off');

   return;					% delete_fig


%-------------------------------------------------------------------------

function DisplayPropCrossCov()

   filter = getappdata(gcbf, 'filter');
   cross = getappdata(gcbf, 'cross');

   bar(cross * 100,'b');
%   bar(cross,'b');

   set(gca, ...
        'Units', 'normal', ...
        'Position', [0.12 0.14 0.76 0.72], ...
        'FontUnits', 'point', ...
        'FontSize', 10, ...
        'YGrid','on');

   set(get(gca,'xlabel'), ...
        'FontUnits', 'normal', ...
        'FontSize', 0.05, ...
        'string','Latent Variable');
   set(get(gca,'ylabel'), ...
        'FontUnits', 'normal', ...
        'FontSize', 0.05, ...
        'string','Percent');
   set(get(gca,'title'), ...
        'FontUnits', 'normal', ...
        'FontSize', 0.05, ...
        'string','Percent Crossblock Covarience');

   arg = '';

%   num_lv = length(cross);

%   for i=1:num_lv
    for i=filter
      if 1	% cross(i) > 0.0001
         nam{i} = ['LV',num2str(i)];
         val{i} = [sprintf('%.2f',100*cross(i)) '%'];
         eval(['arg = [arg, ''nam{',num2str(i), ...
		  '}, '' ''val{',num2str(i), ...
		  '}, ''];']);
      end
   end

   arg = arg(1:end-2);				% take 2 char [, ]
   eval(['h=rri_txtbox(', arg, ');']);

   posa=get(gca,'position');
   pos=get(h,'position');
   set(h,'position', ...
	[posa(1)+posa(3)-pos(3)-0.01, posa(2)+posa(4)-pos(4)-0.01, pos(3), pos(4)]);

   return;					% DisplayPropCrossCov


%-------------------------------------------------------------------------

function DisplayEigenPLSResult()

   filter = getappdata(gcf, 'filter');
   eigen = getappdata(gcf,'eigen');
   plot_data = eigen;
%   plot_data = eigen.^2/sum(eigen.^2)*100;

   bar(plot_data);

   set(gca, ...
	'Units', 'normal', ...
	'Position', [0.12 0.14 0.76 0.72], ...
        'FontUnits', 'point', ...
        'FontSize', 10, ...
	'YGrid','on');

   set(get(gca,'xlabel'), ...
	'FontUnits', 'normal', ...
	'FontSize', 0.05, ...
	'string','Latent Variable');
   set(get(gca,'ylabel'), ...
	'FontUnits', 'normal', ...
	'FontSize', 0.05, ...
	'string','Observed Singular Values');
   set(get(gca,'title'), ...
	'FontUnits', 'normal', ...
	'FontSize', 0.05, ...
	'string','Observed Singular Values');

   arg = '';

%   num_lv = length(plot_data);

%   for i=1:num_lv
    for i=filter
      if 1	% plot_data(i) > 0.01
         nam{i} = ['LV',num2str(i)];
         val{i} = sprintf('%.2f',plot_data(i));
         eval(['arg = [arg, ''nam{',num2str(i), ...
		  '}, '' ''val{',num2str(i), ...
		  '}, ''];']);
      end
   end

   arg = arg(1:end-2);				% take 2 char [, ]
   eval(['h=rri_txtbox(', arg, ');']);

   posa=get(gca,'position');
   pos=get(h,'position');
   set(h,'position', ...
	[posa(1)+posa(3)-pos(3)-0.01, posa(2)+posa(4)-pos(4)-0.01, pos(3), pos(4)]);

   return;     					% DisplayEigenPLSResult


%-------------------------------------------------------------------------

function DisplayEigenPermResult()

   filter = getappdata(gcbf, 'filter');
   num_perm = getappdata(gcbf,'num_perm');
   sprob = getappdata(gcbf,'sprob');
   ucorr_prob = getappdata(gcbf,'ucorr_prob');
   vcorr_prob = getappdata(gcbf,'vcorr_prob');

   if isempty(sprob)
       return;
   end;

%   bar(sprob * 100,'r');
   bar(sprob,'r');


%   axis([0 num_lv+1 0 105]);

   set(gca, ...
	'Units', 'normal', ...
	'Position', [0.12 0.14 0.76 0.72], ...
        'FontUnits', 'point', ...
        'FontSize', 10, ...
	'YGrid','on');

%   xlabel('Latent Variable');
%   ylabel('Probability (%)');
%   title(sprintf('Eigenvalues smaller than those of the %d permutation tests',num_perm));

   set(get(gca,'xlabel'), ...
	'FontUnits', 'normal', ...
	'FontSize', 0.05, ...
	'string','Latent Variable');
   set(get(gca,'ylabel'), ...
	'FontUnits', 'normal', ...
	'FontSize', 0.05, ...
	'string','Probability');
   set(get(gca,'title'), ...
	'FontUnits', 'normal', ...
	'FontSize', 0.05, ...
	'string',sprintf('Permuted values greater than observed, %d permutation tests',num_perm));

   arg = '';

%   num_lv = length(sprob);

   j = 0;

%   for i=1:num_lv
    for i=filter
      if 1	% sprob(i) > 0.001

         j = j + 1;
         nam{j} = ['LV',num2str(i)];
         val{j} = [sprintf('%.3f',sprob(i))];
         eval(['arg = [arg, ''nam{',num2str(j), ...
		  '}, '' ''val{',num2str(j), ...
		  '}, ''];']);

         if ~isempty(ucorr_prob)
            j = j + 1;
            nam{j} = ['p_braincorr_LV',num2str(i)];
            val{j} = [sprintf('%.3f',ucorr_prob(i))];
            eval(['arg = [arg, ''nam{',num2str(j), ...
		  '}, '' ''val{',num2str(j), ...
		  '}, ''];']);
         end

         if ~isempty(vcorr_prob)
            j = j + 1;
            nam{j} = ['p_designcorr_LV',num2str(i)];
            val{j} = [sprintf('%.3f',vcorr_prob(i))];
            eval(['arg = [arg, ''nam{',num2str(j), ...
		  '}, '' ''val{',num2str(j), ...
		  '}, ''];']);
         end
      end
   end

   arg = arg(1:end-2);				% take 2 char [, ]
   eval(['h=rri_txtbox(', arg, ');']);

   posa=get(gca,'position');
   pos=get(h,'position');
   set(h,'position', ...
	[posa(1)+posa(3)-pos(3)-0.01, posa(2)+posa(4)-pos(4)-0.01, pos(3), pos(4)]);

   return;     					% DisplayEigenPermResult


%-------------------------------------------------------------------------

function toggle_perm_result

   h = findobj(gcf,'Tag','PermResultMenu');
   if isempty(h),		% no permutation results
      return;
   end;

   switch (get(h,'Checked')),
     case {'off'},
        set(h,'Checked','on','Label','&PLS Result');
        DisplayEigenPermResult;
     case {'on'},
        set(h,'Checked','off','Label','&Permutation Result');
        DisplayEigenPLSResult;
   end;

   return;     					% toggle_perm_result


%-------------------------------------------------------------------------

function choose_eigen

   h_eigen = findobj(gcf,'tag','eigen');
   h_cross = findobj(gcf,'tag','cross');
   h_perm = findobj(gcf,'tag','perm');

   if strcmp(get(h_eigen,'check'), 'on')
      return;
   end

   set(h_eigen, 'check', 'on');
   set(h_cross, 'check', 'off');
   set(h_perm, 'check', 'off');
   DisplayEigenPLSResult;

   return;					% choose_eigen


%-------------------------------------------------------------------------

function choose_cross

   h_eigen = findobj(gcf,'tag','eigen');
   h_cross = findobj(gcf,'tag','cross');
   h_perm = findobj(gcf,'tag','perm');

   if strcmp(get(h_cross,'check'), 'on')
      return;
   end

   set(h_eigen, 'check', 'off');
   set(h_cross, 'check', 'on');
   set(h_perm, 'check', 'off');
   DisplayPropCrossCov;

   return;					% choose_cross


%-------------------------------------------------------------------------

function choose_perm

   h_eigen = findobj(gcf,'tag','eigen');
   h_cross = findobj(gcf,'tag','cross');
   h_perm = findobj(gcf,'tag','perm');

   if strcmp(get(h_perm,'check'), 'on')
      return;
   end

   set(h_eigen, 'check', 'off');
   set(h_cross, 'check', 'off');
   set(h_perm, 'check', 'on');
   DisplayEigenPermResult;

   return;					% choose_perm


