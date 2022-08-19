%  hrf_get_design_matrix will return the design matrix X based on the
%  onset time in seconds, number of scans in the run, TR in seconds,
%  and the hemodynamic response function (HRF) model designed by SPM.
%  This design matrix will then be used in General Linear Model (GLM)
%  in the form of Y = X*B + e at each voxel, where Y is the scan image
%  data, e is the residual error, and B is the fit images for each
%  conditions.
%
%  This program is developed based on SPM program. Most of the codes
%  are simply copied over.
%
%------------------------------------------------------------------------
function X = hrf_get_design_matrix2(hrf, ons, dur, nScan, TR, num_skipped_scans, add_constant)

   if nargin < 7
      add_constant = 0;
   end

   if nargin < 6
      num_skipped_scans = 0;
   end

   X = [];

   for i = 1:length(ons)
      onset = ons{i} - num_skipped_scans;
      duration = dur{i};

      bad = find(onset<0);

      if ~isempty(bad)
         msg = ['Onsets fall within "Number of scans to be skipped" are not included due to out of bound.'];

         hdl = findobj(gcf,'Tag','MessageLine');
         if ~isempty(hdl) & ishandle(hdl)
%            set(hdl,'String',msg);
         else
%            uiwait(msgbox(msg,'Wrong Run','modal'));
         end

         onset(bad) = [];
         duration(bad) = [];
      end

      x = hrf_recreate_onset_pulse(onset, duration, nScan, TR);
      X = [X conv(x, hrf)];
   end

   X = X(1:nScan, :);

   if add_constant
      X = [X ones(size(X,1),1)];
   end

   return;				% hrf_get_design_matrix


%------------------------------------------------------------------------
function x = hrf_recreate_onset_pulse(ons, dur, nScan, TR)

   ton = round(ons) + 1;		% onset with 1 TR offset
   toff = round(dur);			% epoch-related response if dur~=0
   toff = toff + ton + 1;		% offset

   ton = max(ton, 1);	% at least 1
   toff = max(toff, 1);	% at least 1

   u = ones(length(ons),1);
   x = zeros(nScan,1);

   for j = 1:length(ton)
      if length(x) > ton(j)
         x(ton(j)) = x(ton(j)) + u(j);
      end

      if length(x) > toff(j)
         x(toff(j)) = x(toff(j)) - u(j);
      end
   end

   x = cumsum(x);

   x = x(1:nScan);

   return;				% hrf_recreate_onset_pulse

