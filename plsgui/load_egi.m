%load_EGI  load EGI (Electrical Geodesics Inc) simple-binary data file.
%
%  Usage: egi = load_egi(filename, [machineformat], [gain_cal], [zero_cal])
%
%  egi - EGI structure containing EGI header field, EGI data & event.
%	For segmented EGI data, it also contains category_idx field
%	and timestamp_ms field.
%
%  filename - EGI's data file name.
%
%  machineformat (option) - Default is little-endian 'ieee-le'.
%
%    'ieee-le'     or 'l' - IEEE floating point with little-endian
%                           byte ordering
%    'ieee-be'     or 'b' - IEEE floating point with big-endian
%                           byte ordering
%    'vaxd'        or 'd' - VAX D floating point and VAX ordering
%    'vaxg'        or 'g' - VAX G floating point and VAX ordering
%    'cray'        or 'c' - Cray floating point with big-endian
%                           byte ordering
%    'ieee-le.l64' or 'a' - IEEE floating point with little-endian
%                           byte ordering and 64 bit long data type
%    'ieee-be.l64' or 's' - IEEE floating point with big-endian byte
%                           ordering and 64 bit long data type.
%
%  gain_cal (option) - Gain calibration value (if available).
%
%  zero_cal (option) - Zero calibration value (if available).
%
%  Notes:
%
%  1. This program only supports EGI simple-binary data file with
%     Version Number from 2 to 7.
%
%  References:
%
%  1. Net Station File Formats Technical Manual: S-MAN-200-FFTR-001
%
%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%
function egi = load_egi(filename, varargin)

   if ~exist('filename','var'),
      error('Usage: egi = load_egi(filename, [machineformat], [gain_cal], [zero_cal])');
   end

   if ~exist(filename,'file')
      error([filename, ': Can''t open file']);
   end

   machineformat = 'ieee-le';
   gain_cal = [];
   zero_cal = [];

   if nargin > 1, machineformat = lower(varargin{1}); end;
   if nargin > 2, gain_cal = varargin{3}; end;
   if nargin > 3, zero_cal = varargin{4}; end;

   fid = fopen(filename,'r',machineformat);

   if fid < 0,
      msg = sprintf('Cannot open file %s.',filename);
      error(msg);
   end

   version = fread(fid, 1, 'int32')';
   fseek(fid, 0, 'bof');

   if (version < 2 | version > 7) & ...
      (strcmpi(machineformat, 'l') | strcmpi(machineformat, 'b') | ...
      strcmpi(machineformat, 'ieee-le') | strcmpi(machineformat, 'ieee-be'))

      fclose(fid);

      if strcmpi(machineformat, 'l') | strcmpi(machineformat, 'ieee-le')
         machineformat = 'ieee-be';
      else
         machineformat = 'ieee-le';
      end

      fid = fopen(filename,'r',machineformat);
   end

   version = fread(fid, 1, 'int32')';
   fseek(fid, 0, 'bof');

   if (version < 2 | version > 7)
      fclose(fid);
      error('This program only supports EGI simple-binary data file with Version Number from 2 to 7.');
   end

   egi.hdr = read_hdr(fid, gain_cal, zero_cal);

   [egi.data, egi.event, egi.category_idx, egi.timestamp_ms] = ...
		read_data(fid, egi.hdr);

   fclose(fid);

   return;					% load_egi


%---------------------------------------------------------------------
function hdr = read_hdr(fid, gain_cal, zero_cal)

   %  Struct						% off + size
   hdr.version = fread(fid, 1, 'int32')';		% 0 + 4
   hdr.year = fread(fid, 1, 'int16')';			% 4 + 2
   hdr.month = fread(fid, 1, 'int16')';			% 6 + 2
   hdr.day = fread(fid, 1, 'int16')';			% 8 + 2
   hdr.hour = fread(fid, 1, 'int16')';			% 10 + 2
   hdr.minute = fread(fid, 1, 'int16')';		% 12 + 2
   hdr.second = fread(fid, 1, 'int16')';		% 14 + 2
   hdr.millisecond = fread(fid, 1, 'int32')';		% 16 + 4
   hdr.rate = fread(fid, 1, 'int16')';			% 20 + 2
   hdr.nchannels = fread(fid, 1, 'int16')';		% 22 + 2
   hdr.gain = fread(fid, 1, 'int16')';			% 24 + 2
   hdr.nbits = fread(fid, 1, 'int16')';			% 26 + 2
   hdr.range = fread(fid, 1, 'int16')';			% 28 + 2

   switch hdr.version

   %  For unsegmented files (Versions 2, 4, and 6), the EEG data and/or
   %  events part of the file consists of consecutive single sample
   %  records (SSRs).
   %
   case {2, 4, 6}
      hdr.nsamples = fread(fid, 1, 'int32')';		% 30 + 4
      hdr.ncategories = 0;
      hdr.category = {};
      hdr.nsegments = 0;

   %  For segmented files (Versions 3, 5, and 7), the EEG segment part
   %  of the file consists of consecutive segments.
   %
   case {3, 5, 7}
      hdr.ncategories = fread(fid, 1, 'int16')';	% 30 + 2

      %  Decode pascal string, which is a one-dimensional character array
      %  with an added byte at the beginning that holds the length.
      %
      for i = 1 : hdr.ncategories
         num_char = fread(fid, 1, 'uchar')';
         hdr.category{i} = fread(fid, num_char, '*char')';
      end

      hdr.nsegments = fread(fid, 1, 'int16')';
      hdr.nsamples = fread(fid, 1, 'int32')';

   end;		% switch

   hdr.nevent_codes = fread(fid, 1, 'int16')';
   hdr.event_codes = '';

   if hdr.nevent_codes > 0
      for i = 1 : hdr.nevent_codes
         hdr.event_codes = [hdr.event_codes; fread(fid, 4, '*char')'];
      end
   end

   hdr.gain_cal = gain_cal;
   hdr.zero_cal = zero_cal;
   hdr.dataunits = 'microvolts';

   return;					% read_hdr


%---------------------------------------------------------------------
function [data, event, category_idx, timestamp_ms] = read_data(fid, hdr)

   %  switch precision
   %
   switch hdr.version

   %  integer precision (2 byte)
   %
   case {2, 3}
      precision = 'int16';

   %  floating-poing single precision (4 byte)
   %
   case {4, 5}
      precision = 'float32';

   %  floating-poing double precision (8 byte)
   %
   case {6, 7}
      precision = 'float64';

   end;		% switch precision

   %  switch unsegmented / segmented
   %
   switch hdr.version

   %  For unsegmented files (Versions 2, 4, and 6), the EEG data and/or
   %  events part of the file consists of consecutive single sample
   %  records (SSRs).
   %
   case {2, 4, 6}

      %  For data below, each column is a single sample record (SSR) and
      %  the number of column is "nsamples". In each SSR column, there
      %  are (Nc + Ne) rows, where Nc is number of channel "nchannels",
      %  and Ne is number of event "nevent_codes". Event for a given 
      %  sample occur after the EEG data for that sample, with each event
      %  having the precision as its associated EEG data. Value of event 
      %  will be either 0 or 1.
      %
      tmp = fread(fid, [(hdr.nchannels + hdr.nevent_codes), hdr.nsamples], ...
		precision);

      data = tmp(1 : hdr.nchannels, :);
      event = tmp( (hdr.nchannels+1) : end, :);
      category_idx = [];
      timestamp_ms = [];

   %  For segmented files (Versions 3, 5, and 7), the EEG segment part
   %  of the file consists of consecutive segments.
   %
   case {3, 5, 7}

      %  For data below, each column is composed of an int16 category
      %  index "category_index", an int32 timestamp (in milliseconds)
      %  "timestamp_ms", and nsamples of SSR. The number of column is
      %  "nsegments". Each SSR still contains (Nc + Ne) of rows, where
      %  Nc is number of channel "nchannels", and Ne is number of event
      %  "nevent_codes".
      %
      data = zeros(hdr.nchannels, hdr.nsamples * hdr.nsegments);
      event = zeros(hdr.nevent_codes, hdr.nsamples * hdr.nsegments);

      for i = 1 : hdr.nsegments
         category_idx(i) = fread(fid, 1, 'int16')';
         timestamp_ms(i) = fread(fid, 1, 'int32')';

         tmp = fread(fid, ...
            [(hdr.nchannels + hdr.nevent_codes), hdr.nsamples], precision);

         data(:, [((i-1)*hdr.nsamples+1) : i*hdr.nsamples]) = ...
		tmp(1 : hdr.nchannels, :);
         event(:, [((i-1)*hdr.nsamples+1) : i*hdr.nsamples]) = ...
		tmp( (hdr.nchannels+1) : end, :);
      end;
   end;		% switch unsegmented / segmented

   %  If the values of hdr.nbits or hdr.range are 0, data are in microvolts
   %  and no conversion required; otherwise, data should be converted to
   %  microvolts.
   %
   if hdr.nbits ~= 0 & hdr.range ~= 0

      if isempty(hdr.gain_cal) | isempty(hdr.zero_cal)

         %  If gain calibration or zero calibration is not available,
         %  use the following formula to convert A/D units to microvolts.
         %  The formula uses approximate values for the gain calibration
         %  and zero calibration (refer to "Gains and Zeros" section in
         %  Chapter 2 "Net Amps 200" of the EGI system Technical Manual.
         %
         data = (hdr.range / 2^hdr.nbits) * data;
      else

         %  Current calibration signal p-p value is 400 microvolts
         %
         data = (data - zero_cal) * 400 / gain_cal;
      end
   end

   return;					% read_data

