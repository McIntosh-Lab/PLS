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
function X = hrf_get_design_matrix(hrf, ons, dur, nScan, TR, num_skipped_scans, add_constant)

   if nargin < 7
      add_constant = 0;
   end

   if nargin < 6
      num_skipped_scans = 0;
   end

   X = [];
   nBin = 16;		% default value for num of time bin per scan
   dBin = TR/nBin;	% duration for each bin

%   hrf = hrf_spm_hrf(dBin, nBin);
   hrf0 = hrf_spm_hrf(TR);

   if length(hrf) ~= length(hrf0)
      error(['Number of data points in HRF data for TR=' num2str(TR) ' should be ' num2str(length(hrf0))]);
   end

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

      x = hrf_recreate_onset_pulse(onset, duration, nScan, TR, nBin, dBin);
      X = [X conv(x, hrf)];
   end

   X = X((0:(nScan-1))*nBin + 1 + 32, :);

   if add_constant
      X = [X ones(size(X,1),1)];
   end

   return;				% hrf_get_design_matrix


%------------------------------------------------------------------------
function x = hrf_recreate_onset_pulse(ons, dur, nScan, TR, nBin, dBin)

   ton = round(ons*TR/dBin) + 32;	% onset with 32 bin offset
   toff = round(dur*TR/dBin);		% epoch-related response if dur~=0
   toff = toff + ton + 1;		% offset

   ton = max(ton, 1);	% at least 1
   toff = max(toff, 1);	% at least 1

   if ~any(dur)
      u = ones(length(ons),1)/dBin;	% scalar to make sum(u*dBin) numEvent
					% for conv?
   else
      u = ones(length(ons),1);
   end

   x = zeros((nScan*nBin + 128),1);

   for j = 1:length(ton)
      if length(x) > ton(j)
         x(ton(j)) = x(ton(j)) + u(j);
      end

      if length(x) > toff(j)
         x(toff(j)) = x(toff(j)) - u(j);
      end
   end

   x = cumsum(x);
   x = x( 1 : (nScan*nBin + 32) );

   return;				% hrf_recreate_onset_pulse

