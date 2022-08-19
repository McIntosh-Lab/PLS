%  Calculate Hemodynamic Response Function Data
%
%  [hrf_cond_range, hrf_cond_data, hrf_avg_range, hrf_avg_curr, ...
%	hrf_avg_grand, hrf_range, hrf_curr, hrf_grand] = ...
%	fmri_hrf_data(evt_onsets, condition, TR, win_size);
%
%  Input:
%	evt_onsets:	session_info.run(r).evt_onsets
%	condition:	session_info.condition
%	TR:		regularly TR = 2
%	win_size:	initially, win_size will be set to 8
%
%  Output:
%	hrf_cond_range:	xrange of hrf for each cond
%	hrf_cond_data:	y value of hrf for each cond
%	hrf_avg_range:	xrange to plot hrf avg
%	hrf_avg_curr:	avg for each cond's hrf in each cond ts
%	hrf_avg_grand:	avg for combined cond's hrf in each cond ts
%	hrf_range:	xrange to plot hrf (not used)
%	hrf_curr:	each cond's hrf in each cond ts (not used)
%	hrf_grand:	combined cond's hrf in each cond ts (not used)
%
%  E.g.: [x1 y1 x2 y2 y22] = fmri_hrf_data(evt_onsets,condition,2,8);
%
%
function [hrf_cond_range, hrf_cond_data, hrf_avg_range, hrf_avg_curr, ...
	hrf_avg_grand, hrf_range, hrf_curr, hrf_grand] = ...
	fmri_hrf_data(evt_onsets, condition, TR, win_size);


     xrange = [0:win_size-1];
     all_onsets = [];

     for i = 1:length(evt_onsets)
        evt_onsets{i} = evt_onsets{i} + 1;
        all_onsets = [all_onsets evt_onsets{i}'];
     end

     num_scans = ceil(max(all_onsets))+win_size;

     [hrf_cond_range, hrf_cond_data, hrf_range, hrf_curr, hrf_grand] = ...
	fmri_hrf_cond(evt_onsets,num_scans,TR,condition,1,win_size);

     ts = hrf_cond_data;
     grand_ts = sum([ts{:}],2)';
     hrf_cond_data = [ts{:}]';

     num_cond = length(ts);

     for c=1:num_cond,
        time_pts = round(evt_onsets{c});

        if ~isempty(time_pts)
           time_pts_mtx = repmat(time_pts(:)', win_size,1) + ...
			  repmat([1:win_size]',1,length(time_pts)) - 1;

           % hemo response for cond c only
	   %
	   % will plot the mean along those onsets time series (index)
	   % that fall in the period of cond c
	   %
           curr_ts = ts{c};

	   % hemo response for combined cond (sum of all cond)
	   %
	   % will plot the mean along those onsets time series (index)
	   % that fall in the period of cond c
	   %
           curr_grand_ts = grand_ts;

	   hrf_avg_curr(c,:) = mean(curr_ts(time_pts_mtx),2)';
	   hrf_avg_grand(c,:) = mean(curr_grand_ts(time_pts_mtx),2)';
        else
           hrf_avg_curr(c,:) = zeros(1, win_size,1);
           hrf_avg_grand(c,:) = zeros(1, win_size,1);
        end
     end;

     hrf_avg_range = xrange;

     return;						% fmri_hrf_data


%----------------------------------------------------------------------------
function [hrf_cond_range, hrf_cond_data, hrf_range, hrf_curr, hrf_grand] = ...
	fmri_hrf_cond(onsets,num_scans,TR,cond_name,disp_timing,HRF_win_size)
%
%  USAGE: time_series = fmri_hrf_cond(onsets,num_scans,TR,cond_name, ...
%							disp_timing,HRF_win_size)
%
%  Display the time series of each condition with the assumed HRF model.
%  The last subplot is the overlay plots of all conditions.
%
%  Input:
%	onsets: cell array of onsets of each condition
%	num_scans: total number of scans
%	TR: TR (in second)
%	cond_name:  names of conditions for display timing plots
%	disp_timing:  0 - no timing plot display
%		      1 - display the timing plot for each condition (default)
%	HRF_win_size: window size for displaying the HRFs
%		      set to 0 if want no HRFs display
%	
%
%  Output:
%	time_series (optional): cell array of time series for each condition
%
%  Example:
%
%    TR = 2;   
%    num_scans = 180;
%    onsets = { [21:20:num_scans], [21:20:num_scans], [21:20:num_scans], ...
%	     [1:30:num_scans], [1:30:num_scans] };
%    show_HRFs(onsets,num_scans,TR);
%  

  if ~exist('TR','var') | isempty(TR)
	TR = 2;
  end;

  if ~exist('cond_name','var') | isempty(cond_name)
	cond_name = [];
	show_cond_label = 0;
  else
	show_cond_label = 1;
  end;

  if ~exist('disp_timing','var') | isempty(disp_timing)
	disp_timing = 1;
  end;

  if ~exist('HRF_win_size','var') | isempty(HRF_win_size) | (HRF_win_size == 0)
	show_HRF = 0;
  else
	show_HRF = 1;
  end;

  response_mag = 2.0;

%  color_code = 'rgbcmyk';
%  style = {'-',':','-.','--'};

  num_cond = length(onsets);
  ts = cell(1,num_cond);

%  if (disp_timing), f_hdl = figure; end;

  for i=1:num_cond,
%     c_idx = mod(i,length(color_code)-1)+1;
%     s_idx = floor((i-1) / length(color_code))+1;
%
     ts{i} = gen_tseries(onsets{i},response_mag,num_scans,TR);
%     coding = [color_code(c_idx),style{s_idx}];
%
%     if (disp_timing), 
%        figure(f_hdl);
%
%	% plot onsets in cond i
%	%
%        subplot(num_cond+1,1,i); plot([0:num_scans-1],ts{i},coding);
%        if (show_cond_label),
%	   set(gca,'YLabel',text('string',cond_name{i}));
%        end
%
%	% plot combined onsets for all cond
%	%
%        subplot(num_cond+1,1,num_cond+1); 
%        hold on;
%   	   plot([0:num_scans-1],ts{i},coding);
%        hold off;
%      end;
  end;

	hrf_cond_range = [0:num_scans-1];
	hrf_cond_data = ts;

%  if (disp_timing) & (show_cond_label),
%     set(gca,'YLabel',text('string','Combined'));
%  end;

  if (show_HRF)
     [hrf_range, hrf_curr, hrf_grand] = disp_cond_HRF(ts, onsets, ...
		HRF_win_size, cond_name);
  end;

%  if (nargout == 1)
%     varargout(1) = { ts };
%  end;

  return;						% fmri_hrf_cond

  
%----------------------------------------------------------------------------
function [response] = gen_tseries(onsets,response_mag,num_scans,TR,hrf_params)
%
%
  if ~exist('hrf_params','var')
    a = 8.6; b = 0.547; len = 20;
  else
    [a, b, len] = deal(hrf_params{:});
  end;
  delay = 0;

  response=zeros(num_scans,1);
  rr=[0 0 fmri_gen_hrf(a,b,len) 0];
  rr=rr/max(rr);
  
  TRoffset = floor((delay)/TR);
  HRFoffset = TR-mod(delay,TR);

  for idx=1:length(onsets),
    i = round(onsets(idx));
    rrr=rr(HRFoffset:TR:15);
    range = [i:(i+length(rrr)-1)] + TRoffset;

    if (range(end) <= num_scans)
       response(range)=response(range)'+ response_mag*rrr;
    end;
  end

  return;			% gen_tseries


%----------------------------------------------------------------------------
function [xrange, mean_curr_ts, mean_grand_ts] = disp_cond_HRF(ts,onsets, ...
	win_size, cond_name);
%
%

   grand_ts = sum([ts{:}],2)';

   num_cond = length(ts);
%   cond_HRF = cell(1,num_cond);

   xrange = [0:win_size-1];

%   f_hdl = figure;
   for c=1:num_cond,
        time_pts = round(onsets{c});

        if ~isempty(time_pts)
           time_pts_mtx = repmat(time_pts(:)', win_size,1) + ...
			  repmat([1:win_size]',1,length(time_pts)) - 1;

           curr_ts = ts{c};  
%	    cond_HRF{c} = [mean(curr_ts(time_pts_mtx),2) ...
%			  mean(grand_ts(time_pts_mtx),2)];
%
%           figure(f_hdl);
%           subplot(num_cond,1,c);
%
%           plot(xrange,mean(curr_ts(time_pts_mtx),2),'g--', ...
%		xrange,mean(grand_ts(time_pts_mtx),2),'b');

           mean_curr_ts(c,:) = mean(curr_ts(time_pts_mtx),2)';
           mean_grand_ts(c,:) = mean(grand_ts(time_pts_mtx),2)';

%           set(gca,'xlim',[0 win_size-1]);
%
%           if (c == 1),
%              legend('No Interference','Max. Interference');
%           end;
%
%           if ~isempty(cond_name),
%	       set(gca,'ylabel',text('string',sprintf('%s',cond_name{c})));
%           end;
        else
           mean_curr_ts(c,:) = zeros(1, win_size,1);
           mean_grand_ts(c,:) = zeros(1, win_size,1);
        end
   end;

   return;

