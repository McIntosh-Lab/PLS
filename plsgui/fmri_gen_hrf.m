function [response]=fmri_gen_hrf(r,c,duration,sampling_interval)
%
%  Usage: [response]=fmri_gen_hrf(r,c,duration,sampling_interval)
%
%  HRF :  Hemodynamic Response Function h(t) = t^r * exp( -t / c )
%         eg. r=8.6, c=0.547
%
%  Input:
%	r - the r parameter in the above HRF function
%	c - the c parameter in the above HRF function
%	duration - the lenght of response (in seconds)
%	sampling_interval - the sampling interval (in seconds) 
%	(optional)          [default = 1 second]
%
%  Source: Mark S. Cohen, Parametric Analysis of fMRI Data Using Linear
%          Systems Methods, NeuroImage, 6, 93-103, 1997 
%

if ~exist('sampling_interval','var')
  sampling_interval = 1;  % sample for each second
end

len = ceil(duration/sampling_interval);
response = zeros(1,len);

timeline = [1:len] * sampling_interval;
for i=1:len; 
  t=timeline(i);
  response(i) = t^r * exp( -t / c ); 
end
