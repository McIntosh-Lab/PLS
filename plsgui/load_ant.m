%LOAD_ANT  load ANT (Advanced Neuro Technology) average data file.
%
%  Usage: ant = load_ant(filename, [machineformat])
%
%  ant - ANT structure containing ANT header field, means matrix and
%	variances matrix.
%
%  filename - ANT's average data file name.
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
%  Notes:
%
%  The "load_ant.m" program is based on openlib library "cntopenlib.zip"
%  and additional information "avr.txt" file that are released by ANT's
%  technical support.
%
%  Since January 2004, ANT's average data file has been changed, and the
%  history section is included in its header. This info is not included
%  in the "cntopenlib.zip"; however, it is in the "avr.txt" file released
%  by ANT's support people.
%
%  Some people were using "avr2asc" provided by ANT's EEProbe_3.3.120 to
%  convert ANT's average to plain text file. However, the disadvantage 
%  is that the "avr2asc" only supports new version of ANT's average data
%  on Linux and Mac platforms, and does not work under MATLAB.
%
%  Other programs that are relied on their "cntopenlib.zip" (e.g. Robert
%  Oostenveld's "read_eep_avr" that is used by EEGLAB) can only support
%  old version, and they are compiled in mex or dll file. You must first
%  use "avrstrip" in EEProbe_3.3.120 to convert your new version of ANT's
%  average data to old version before you can use "read_eep_avr" to load
%  them.
%
%  The "load_ant.m" is the only explicit .m program so far (April, 2007)
%  that supports both old & new versions of ANT's average data file on any
%  platform.
%
%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%
function ant = load_ant(filename, varargin)

   if ~exist('filename','var')
      error('Usage: ant = load_ant(filename, [machineformat])');
   end

   if ~exist(filename,'file')
      error([filename, ': Can''t open file']);
   end

   machineformat = 'ieee-le';

   if nargin > 1, machineformat = lower(varargin{1}); end;

   fid = fopen(filename,'r',machineformat);

   if fid < 0,
      msg = sprintf('Cannot open file %s.',filename);
      error(msg);
   end

   header_size = fread(fid, 1, 'uint16')';
   channel_header_size = fread(fid, 1, 'uint16')';
   fseek(fid, 0, 'bof');

   if (header_size ~= 38 | channel_header_size ~= 16) & ...
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

   header_size = fread(fid, 1, 'uint16')';
   channel_header_size = fread(fid, 1, 'uint16')';
   fseek(fid, 0, 'bof');

   if (header_size ~= 38 | channel_header_size ~= 16)
      fclose(fid);
      error('This program only supports ANT''s Average ERP data file.');
   end

   ant = read_avr(fid);		% read ANT structure
   fclose(fid);

   return;					% load_ant


%---------------------------------------------------------------------
function ant = read_avr(fid)

   %  Read ANT header
   %
   ant.hdr = read_avr_hdr(fid);

   %  Read ANT data
   %
   [ant.means, ant.variances] = read_avr_data(fid, ant.hdr);

   return;					% read_avr


%---------------------------------------------------------------------
function hdr = read_avr_hdr(fid)

%  Global Header (first 38 bytes)
%
%  offset             type      value
%  -----------------------------------------------------------------------
%    0                s16       global header size (always 38)
%    2                s16       channel header size (always 16)
%    4                s16       nchannels
%    6                s16       nsamples
%    8                s16       ntrials    (total number of trials)
%   10                s16       nrejected  (number of rejected trials)
%   12                f32       time in ms for first data point
%   16                f32       sample interval
%   20                char[10]  condition label
%   30                char[8]   color code (see below)
%
%  Channel Header (16 bytes per channel)
%
%  offset             type      value
%  -----------------------------------------------------------------------
%    0                char[10]  channel label
%   10                u32       file offset for data of this channel
%   14                char[2]   unused
%  
%  Original structures
%  
%  typedef struct {
%    char          lab[11];                 /* channel label */
%    int           filepos;                 /* offset of data in file */
%  } avrchan_t;
%  
%  typedef struct {
%    char           condlab[11];            /* condition label */
%    char           condcol[9];             /* associated color code */
%                                           /* e.g. "color:23"       */
%  
%    unsigned short trialc;                 /* total number of trials */
%    unsigned short rejtrialc;              /* number of rejected trials */
%    slen_t         sample0;                /* start sample time */  
%    slen_t         samplec;                /* number of samples */
%    float          period;                 /* sampling intervall in ms */
%  
%    float          mtrialc;                /* mean of trial numbers for grand_av */
%                                           /* not stored, initialized to trialc - rejtrialc during load */
%    
%    unsigned short chanc;                  /* number of channels */
%    avrchan_t      *chanv;                 /* channel info table */
%    
%    short            header_size;
%    short            channel_header_size;
%  } avr_t;

   %  Struct						% off + size
   header_size = fread(fid, 1, 'uint16')';		% 0 + 2
   channel_header_size = fread(fid, 1, 'uint16')';	% 2 + 2
   hdr.chanc = fread(fid, 1, 'uint16');			% 4 + 2
   hdr.samplec = fread(fid, 1, 'uint16');		% 6 + 2
   hdr.trialc = fread(fid, 1, 'uint16');		% 8 + 2
   hdr.rejtrialc = fread(fid, 1, 'uint16');		% 10 + 2
   hdr.sample0 = fread(fid, 1, 'float32');		% 12 + 4
   hdr.period = fread(fid, 1, 'float32');		% 16 + 4
   hdr.condlab = deblank(char(fread(fid, 10, 'uint8')'));	% 20 + 10
   hdr.condcol = char(fread(fid, 8, 'uint8')');		% 30 + 8
   hdr.chanlab = [];

   for i = 1 : hdr.chanc				% 38 + 16*chanc

%      hdr.chanv(i).label = deblank(char(fread(fid, 10, 'uint8')'));
%      hdr.chanv(i).filepos = fread(fid, 1, 'uint32')';	% offset
%      tmp = char(fread(fid, 2, 'uint8')');		% unused

      hdr.chanlab = [hdr.chanlab; char(fread(fid, 10, 'uint8')')];
      tmp = char(fread(fid, 6, 'uint8')');		% unused

   end

   hdr_pos = ftell(fid);

   if strcmp(char(fread(fid,9,'uint8')'),'[History]')

      buf = char(fread(fid,128,'uint8')');
      hist_end = findstr(buf,'EOH');

      while isempty(hist_end)
         buf = char(fread(fid,128,'uint8')');
         hist_end = findstr(buf,'EOH');
      end

      %          E_of_Buffer       B_of_EOH     EOH  NL
      fseek(fid, ftell(fid) - (128-hist_end+1) + 3 + 1 , 'bof');

   else
      fseek(fid,hdr_pos,'bof');
   end

   hdr.sample0 = round(hdr.sample0 / hdr.period);
   hdr.period = hdr.period / 1000;
   hdr.mtrialc = hdr.trialc - hdr.rejtrialc;
   hdr.timeaxis = 1000 * ( (0 : hdr.samplec-1) + hdr.sample0 ) * hdr.period;

   return;					% read_avr_hdr


%---------------------------------------------------------------------
function [means, variances] = read_avr_data(fid, hdr)

%  nsamples f32's for the means, nsamples f32's for the variances
%  this is repeated nchannels times

   data = [ fread(fid, [2*hdr.samplec, hdr.chanc], 'float32') ]';

   means = data(:, 1: hdr.samplec);
   variances = data(:, 1+hdr.samplec: hdr.samplec*2);

   return;					% read_avr_data

