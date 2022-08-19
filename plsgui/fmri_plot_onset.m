%  Display onset timing for all conditions in MRI Edit Runs window
%
%  Usage: fmri_plot_onset(condition, evt_onsets);
%	where:	condition = session_info.condition;
%	evt_onsets = session_info.run(r).evt_onsets;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h01 = fmri_plot_onset(varargin)

   action = varargin{1};

   if iscell(action)
      SessionConditions = varargin{1};
      CurrOnsets = varargin{2};

      init_val = inputdlg({'Seconds per TR'}, 'Input', 1, {'2'});

      if isempty(init_val)
         return;
      end

      h01 = init(CurrOnsets,SessionConditions,str2num(init_val{1}),3);
      return;
   end

   if strcmp(action,'zoom')			% zoom menu clicked
      zoom_on_state = get(gcbo,'Userdata');
      if (zoom_on_state == 1)			% zoom on
         zoom on;
         set(gcbo,'Userdata',0,'Label','&Zoom off');
         set(gcf,'pointer','crosshair');
      else					% zoom off
         zoom off;
         set(gcbo,'Userdata',1,'Label','&Zoom on');
         set(gcf,'pointer','arrow');
      end
   elseif strcmp(action,'delete_fig')
      delete_fig;
   end

   return;


%-----------------------------------------------------------

function h01 = init(CurrOnsets, SessionConditions, TRsec, sigma)

   tit = 'Onset Timing Plot';

   save_setting_status = 'on';
   fmri_plot_onset_pos = [];

   try
      load('pls_profile');
   catch
   end

   if ~isempty(fmri_plot_onset_pos) & strcmp(save_setting_status,'on')

      pos = fmri_plot_onset_pos;

   else

      w = 0.8;
      h = 0.5;
      x = (1-w)/2;
      y = (1-h)/2;

      pos = [x y w h];

   end

   xp = 0.0227273;
   yp = 0.0294118;
   wp = 1-2*xp;
   hp = 1-2*yp;

   pos_p = [xp yp wp hp];

   h01 = figure('unit','normal', ...
        'paperunit','normal', ...
        'paperorient','land', ...
        'paperposition',pos_p, ...
        'papertype','usletter', ...
        'numberTitle','off', ...
        'menubar', 'none', ...
        'toolbar','none', ...
        'user', 'Detail Plot', ...
	'name', tit, ...
        'deleteFcn','fmri_plot_onset(''delete_fig'');', ...
        'tag','onset_fig', ...
        'position', pos);

   %  file menu
   %
   rri_file_menu(h01);

   %  zoom
   %
   h1 = uimenu('parent',h01, ...
        'userdata', 1, ...
        'callback','fmri_plot_onset(''zoom'');', ...
        'label','&Zoom on');

   plot_onset(CurrOnsets, SessionConditions, TRsec, sigma);

   return;


%--------------------------------------------------------------

function plot_onset(CurrOnsets, SessionConditions, tr_sec, sigma)

   load rri_color_code
   axes('position',[.075 .2 .85 .7]);
   hold on;

   onset_lst = CurrOnsets{1};
   onset_lst = onset_lst * tr_sec;

   if ~isempty(onset_lst)
      minval = max(onset_lst) + 16;
      maxval = min(onset_lst);
   else
      minval = 9999;
      maxval = 0;
   end

   cond_disp_idx = ones(1,length(CurrOnsets));

   for cond = 1:length(CurrOnsets)
      onset_lst = CurrOnsets{cond};
      onset_lst = onset_lst * tr_sec;

      if ~isempty(onset_lst)
         a = onset_lst(1);
         b = a + 16;			% 16 seconds apart
         mu = (a + b)/2;
         x = linspace(a,b);
         y = gauss1d(x, mu, sigma);
         h = plot(x,y);
         set(h,'color',color_code(cond,:));
      else
         cond_disp_idx(cond) = 0;
      end
   end

   x_tick = [];

   for cond = 1:length(CurrOnsets)
      onset_lst = CurrOnsets{cond};
      onset_lst = onset_lst * tr_sec;

      if minval > min(onset_lst);
         minval = min(onset_lst);
      end

      if maxval < max(onset_lst);
         maxval = max(onset_lst);
      end

      if ~isempty(onset_lst)
         for i = 1:length(onset_lst)
            a = onset_lst(i);
            b = a + 16;			% 16 seconds apart
            mu = (a + b)/2;
            x = linspace(a,b);
            y = gauss1d(x, mu, sigma);
            h = plot(x,y);
            set(h,'color',color_code(cond,:));

            x_tick = [x_tick a];
         end
      end
   end

   hold off;
   maxval = maxval + 16;
   xtick_val = minval:tr_sec:maxval;
   x_tick = unique(sort(x_tick));
   [tmp idx]=intersect(xtick_val,x_tick);
   xtick_label = cell(1,length(xtick_val));
   xtick_label(idx) = num2cell(x_tick);
   set(gca,'xtick',xtick_val,'xlim',[minval maxval],'xgrid','on','ytick', [], ...
	'xticklabel',xtick_label,'ticklength',[0.002,0.01]);
   xlabel('Seconds');
   [l_hdl, o_hdl] = legend(SessionConditions(find(cond_disp_idx)));
   legend_txt(o_hdl);

   return;


%--------------------------------------------------------------
function y = gauss1d(x, mu, sigma)

   y = 1/(sqrt(2*pi)*sigma)*exp(-0.5*(x-mu).^2/sigma^2);

   return;


%--------------------------------------------------------------

function delete_fig

   try
      load('pls_profile');
      pls_profile = which('pls_profile.mat');

      fmri_plot_onset_pos = get(gcbf,'position');

      save(pls_profile, '-append', 'fmri_plot_onset_pos');
   catch
   end

%   h0 = getappdata(gcbf,'main_fig');
 %  hm_detail = getappdata(h0,'hm_detail');
  % set(hm_detail, 'userdata',0, 'check','off');

   return;						% delete_fig

