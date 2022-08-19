%LOAD_NEUROSCAN  will load NeuroScan binary data file to a NeuroScan
%  structure. It supports file format AVG (average EEG), EEG (epoched
%  EEG), and CNT (continuous EEG). For continuous EEG format, it can
%  automatically distinguish whether data is from SynAmps module or is
%  from 100 and 330 KHz modules.
%
%  load_neuroscan will use file extension to tell whether it is an AVG,
%  an EEG, or a CNT format, unless the fileformat argument is provided.
%  If it can not find the proper file extension and the fileformat
%  argument is not provided, AVG data will be assumed.
%
%  Usage: ns = load_neuroscan(filename, [fileformat], [machineformat], ...
%					[cnt_start_time], [cnt_end_time])
%
%  ns - structure containing NeuroScan header fields SETUP & ELECTLOC,
%	and data. For epoched EEG data, a field SWEEP will be appended.
%	For continuous EEG data, fields TEEG & EVENT will be appended.
%
%  filename - NeuroScan data file name.
%
%  fileformat (optional) - Either 'AVG' (default), 'EEG', 'CNT', or 'CNT32'.
%			If it is empty, the default value will be used.
%
%  machineformat (optional) - Default is little-endian 'ieee-le'.
%			If it is empty, the default value will be used.
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
%  cnt_start_time (optional) - Only for continuous data file, you can 
%		specify the start time with unit in second that you 
%		want to extract. The rounded start time will be 
%		displayed in ns.start_time. By default, it starts 
%		at 0 second.
%
%  cnt_end_time (optional) - Only for continuous data file, you can 
%		specify the end time with unit in second that you 
%		want to extract. The rounded start time will be 
%		displayed in ns.end_time. By default, it ends at 
%		the end of data.
%
%  Notes:
%
%  1. This program assumed that the data were acquired from NeuroScan
%     version 3.0 and above.
%
%  2. There are two headers for all NeuroScan data file. General header
%     containing information that applies to all channels should be at
%     the beginning of a NeuroScan data file. The size of general header
%     is 900 bytes. Channel-specific header containing information that
%     pertains to particular channel should come after general header.
%     The size of channel-specific header is 75 bytes per channel.
%
%  3. Average Neuroscan data is stored as 4-byte floates in vectored
%     format for each channel. Each channel has a 5-byte header that
%     is no longer used. Thus, after SETUP & ELECTLOC, there is an
%     unused 5-byte header followed by SETUP.pnts of 4-byte floating
%     point numbers for the first channel; then a 5-byte header for
%     channel two followed by SETUP.pnts * size(float) bytes, etc.
%     Therefore, the total number of bytes after SETUP & ELECTLOC is:
%     SETUP.nchannels * ( 5 + SETUP.pnts * sizeof(float) ). To scale
%     a data point to microvolts, multiply by the channel-specific
%     calibration factor (i.e., for electrode j: channel[j]->calib)
%     and divided by the number of sweeps in the average (i.e., 
%     channel[j]->n);
%
%  4. According to CNTTOASC from Neuroscan, continuous Neuroscan data
%     type can be distinguished by SETUP.ContinuousType:
%
%     Type 0 or 1 means using 100/330KHz module for continuous files.
%     Data is stored as 2-byte integer after SETUP hdr and ELECTLOC 
%     hdr in multiplexed format. Each data scan consists of 
%     SETUP.nchannels points.
%
%     Type 3 means using SynAmps for continuous files. Data is stored
%     as 2-byte integer after SETUP hdr and ELECTLOC hdr, and is sent
%     in a blocked rather than multiplexed format. The size of block 
%     in byte is SETUP.ChannelOffset and the size of block in point
%     is SETUP.ChannelOffset/2. Since data is recorded continuously, 
%     block has to be concatenated each other.
%
%     To scale a data point to microvolts for channel j, first subtract
%     off the amplifier d.c.offset (if any) found in the variable
%     (ELECTLOC[j]->baseline). Then multiply by the sensitivity
%     (ELECTLOC[j]->sensitivity) times the channel specific scale factor
%     (ELECTLOC[j]->calib) devided by 204.8.
%
%     After continuous NeuroScan data, there is an Event Table.
%     At the beginning of the event table is a TEEG ("Tagged EEG")
%     structure that is defined in the sethead.h file. Following
%     this structure is the event table property. There are two
%     types of event tables - the first with a minimum of event
%     information, and the second with additional behavioral
%     information. The Teeg variable in the TEEG structure
%     indicates the type of event table. The number of events
%     in the event table can be calculated by dividing the size
%     variable in the TEEG structure by sizeof(EVENT1) or 
%     sizeof(EVENT2). The EVENT immediately follow the TEEG.
%
%  5. There are SETUP.compsweeps of data in an .EEG file. Each sweep
%     of data consists of a sweep header followed by the EEG data.
%     After the sweep header, data is stored as 2-byte integers in
%     multiplexed format. The scaling of .EEG data to microvolts is
%     identical to scaling of .CNT data above.
%
%  References:
%
%  1. Header structure can be found on: http://www.neuro.com/files/sethead.h
%  2. Appendix C of Document number 2204 Revision C, from Neuroscan
%  3. CNTTOASC from Neuroscan Customer Support Download Area
%  4. EEG2ASC from Neuroscan Customer Support Download Area
%
%  December 8, 2006 (jimmy): 
%	Neuroscan version 4.3 also has 32-bit acquisition
%	for its continuous data files. By default, it collects
%	16-bit integer data with the original SynAmp (SynAmp1).
%	With SynAmp2, it will collect 32-bit integer data. 
%	According to Neuroscan tech support, "this file format 
%	must be determined prior to reading the file, i.e. there
%	is no flag within the file itself to identify a file as 
%	32-bit". In order to read 32-bit data format, optional 
%	input "fileformat" of "load_neuroscan.m" function must
%	be specified to 'cnt32'. For example, you can load data
%	using: ns = load_neuroscan('myfile.cnt', 'cnt32'); Type
%	"help load_neuroscan" for the usage of "fileformat".
%	Because now the continuous data file can be very large,
%	you can specify cnt_start_time and cnt_end_time. Their
%	units are "second". For example, if you only want to
%	extract data from 0 second to 1.998 second, you can type:
%	ns = load_neuroscan('myfile.cnt', 'cnt', '', 0, 1.998);
%	The actual rounded start_time and end_time will be 
%	displayed in ns.start_time and ns.end_time.
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function ns = load_neuroscan(filename, varargin)

   if ~exist('filename','var'),
      error('Usage: ns=load_neuroscan(filename,[fileformat],[machineformat],[cnt_start_time],[cnt_end_time])');
   end

   if ~exist(filename,'file')
      error([filename, ': Can''t open file']);
   end

   ext = [];
   machineformat = '';
   start_time = [];
   end_time = [];

   if nargin > 1, ext = varargin{1}; end;
   if nargin > 2, machineformat = lower(varargin{2}); end;
   if nargin > 3, start_time = varargin{3}; end;
   if nargin > 4, end_time = varargin{4}; end;

   if isempty(ext) | ( ~strcmpi(ext,'avg') & ~strcmpi(ext,'eeg') & ... 
	~strcmpi(ext,'cnt') & ~strcmpi(ext,'cnt32') )

      [tmp1 tmp2 ext] = fileparts(filename);
      ext = ext(2:end);
   end

   if isempty(machineformat)
      machineformat = 'ieee-le';
   end

   fid = fopen(filename,'r',machineformat);

   %  General header containing information that applies to all channels
   %  should be at the beginning of a NeuroScan data file. The size of
   %  general header is 900 bytes.
   %
   if fid < 0,
      msg = sprintf('Cannot open file %s.',filename);
      error(msg);
   else
      ns.SETUP = read_SETUP(fid);		% general hdr
   end

   %  Channel-specific header containing information that pertains to
   %  particular channel should come after general header. The size of
   %  channel-specific header is 75 bytes per channel.
   %
   for i = 1:ns.SETUP.nchannels			% channel-specific hdr
      ns.ELECTLOC(i) = read_ELECTLOC(fid);
   end

   if strcmpi(ext, 'cnt') | strcmpi(ext, 'cnt32')	% read continuous data

      if ns.SETUP.savemode ~= 3
         error('Invalid continuous NeuroScan data');
      end

      if strcmpi(ext, 'cnt32')
         ns.precision = 'int32';
      else
         ns.precision = 'int16';
      end;

      ns.start_time = start_time;
      ns.end_time = end_time;

      [ns.data start_time end_time] = read_cnt(fid, ns);

      ns.start_time = start_time;
      ns.end_time = end_time;

      %  After continuous NeuroScan data, there is an Event Table.
      %  At the beginning of the event table is a TEEG ("Tagged EEG")
      %  structure that is defined in the sethead.h file. Following
      %  this structure is the event table property. There are two
      %  types of event tables - the first with a minimum of event
      %  information, and the second with additional behavioral
      %  information. The Teeg variable in the TEEG structure
      %  indicates the type of event table. The number of events
      %  in the event table can be calculated by dividing the size
      %  variable in the TEEG structure by sizeof(EVENT1) or 
      %  sizeof(EVENT2). The EVENT immediately follow the TEEG.

      ns.TEEG = read_TEEG(fid, ns.SETUP);	% tag for EEG types
         
      if ns.TEEG.Teeg == 1			% event type 1
         event_size = 8;
      elseif ns.TEEG.Teeg == 2			% event type 2
         event_size = 19;
      else
         error('Invalid Event table for continuous NeuroScan data');
      end

      for i = 1:floor(ns.TEEG.Size/event_size)	% read event table
         ns.EVENT(i) = read_EVENT(fid, ns);
      end
   elseif strcmpi(ext, 'eeg')

      %  There are SETUP.compsweeps of data in an .EEG file. Each sweep
      %  of data consists of a sweep header followed by the EEG data.
      %
      ns.data = zeros(ns.SETUP.nchannels, ns.SETUP.pnts*ns.SETUP.compsweeps);

      for i = 1:ns.SETUP.compsweeps		% read SWEEP head
         ns.SWEEP(i) = read_SWEEP(fid, ns.SETUP);

         %  After the sweep header, data is stored as 2-byte integers in
         %  multiplexed format.
         %
         ns.data(:, [ns.SETUP.pnts*(i-1)+1 : ns.SETUP.pnts*i]) = ...
		fread(fid, [ns.SETUP.nchannels, ns.SETUP.pnts], 'int16');
      end

      %  scale data
      %
      for j = 1:ns.SETUP.nchannels

         %  To scale a data point to microvolts for channel j, first subtract
         %  off the amplifier d.c.offset (if any) found in the variable
         %  (ELECTLOC[j]->baseline). Then multiply by the sensitivity
         %  (ELECTLOC[j]->sensitivity) times the channel specific scale factor
         %  (ELECTLOC[j]->calib) devided by 204.8.

         dc = ns.ELECTLOC(j).baseline;
         sf = ns.ELECTLOC(j).sensitivity * ns.ELECTLOC(j).calib / 204.8;
         ns.data(j,:) = sf*(ns.data(j,:) - dc);
      end
   else

      ns.data = read_avg(fid, ns);
   end

   ns.dataunits = 'microvolts';

   fclose(fid);

   return;					% load_neuroscan


%---------------------------------------------------------------------
function [data, start_time, end_time] = read_cnt(fid, ns)
  
   %  each data point is 2-byte for 16-bit CNT data file
   %  and is 4-byte for 32-bit CNT32 data file
   %
   if strcmpi(ns.precision, 'int32')
      byte_per_pnts = 4;
   else
      byte_per_pnts = 2;
   end;

   %  number of data scans (in bytes) for all channels
   %
   ndata = (ns.SETUP.EventTablePos - (900 + 75 * ns.SETUP.nchannels));

   %  number of data scans (in bytes) for each channel
   %
   ndata = ndata / ns.SETUP.nchannels;

   %  number of data scans (in data points) for each channel
   %
   ndata = ndata / byte_per_pnts;

   %  round to start timepoints &  end_timepoints first,
   %  then, replace start_time & end_time with actual value
   %
   if isempty(ns.start_time)
      start_pnts = 0;
   else
      start_pnts = round(ns.start_time * ns.SETUP.rate);
   end;

   start_time = start_pnts / ns.SETUP.rate;

   if isempty(ns.end_time)
      end_pnts = ndata - 1;
   else
      end_pnts = round(ns.end_time * ns.SETUP.rate);
   end

   end_time = end_pnts / ns.SETUP.rate;

   %  read data
   %

if 0	% no difference between ContinuousType to read data

   if ns.SETUP.ContinuousType == 3		% SynAmp

      %  Type 3 means using SynAmps for continuous files. Data is stored
      %  as 2-byte integer after SETUP hdr and ELECTLOC hdr, and is sent
      %  in a blocked rather than multiplexed format. The size of block 
      %  in byte is SETUP.ChannelOffset and the size of block in point
      %  is SETUP.ChannelOffset/2. Since data is recorded continuously, 
      %  block has to be concatenated each other.

      %  block size in data points should be SETUP.ChannelOffset / 2
      %  since each data point is 2-byte (16-bit short integer)
      %
      blk_pnts = ns.SETUP.ChannelOffset / byte_per_pnts;

      %  find the block for start_time and the block for end_time,
      %
      start_blk = floor(start_pnts / blk_pnts) + 1;
      end_blk = floor(end_pnts / blk_pnts) + 1;

      %  replace start_time with the beginning of start block, and
      %  end_time with the end of end block
      %
      start_pnts = (start_blk - 1) * blk_pnts;
      end_pnts = (end_blk - 1) * blk_pnts;

      start_time = start_pnts / ns.SETUP.rate;
      end_time = end_pnts / ns.SETUP.rate;

      data = zeros(ns.SETUP.nchannels, (end_pnts-start_pnts+1));

      fseek(fid, start_pnts*ns.SETUP.nchannels*byte_per_pnts, 'cof');

      for i = 1 :(end_blk-start_blk)
         data(:, ((i-1)*blk_pnts+1):(i*blk_pnts) ) = ...
		[fread(fid, [ns.SETUP.nchannels blk_pnts], ns.precision)];
      end		% for num_block

   elseif ns.SETUP.ContinuousType == 1 | ns.SETUP.ContinuousType == 0

      %  Type 0 or 1 means using 100/330KHz module for continuous files.
      %  Data is stored as 2-byte integer after SETUP hdr and ELECTLOC 
      %  hdr in multiplexed format. Each data scan consists of 
      %  SETUP.nchannels points.

end
end

      fseek(fid, start_pnts*ns.SETUP.nchannels*byte_per_pnts, 'cof');

      data = fread(fid, [ns.SETUP.nchannels, (end_pnts-start_pnts+1)], ...
			ns.precision);
   %else
    %  error('Invalid continuous NeuroScan data');
   %end		% switch ContinuousType

   %  scale data
   %
   for j = 1:ns.SETUP.nchannels

      %  To scale a data point to microvolts for channel j, first subtract
      %  off the amplifier d.c.offset (if any) found in the variable
      %  (ELECTLOC[j]->baseline). Then multiply by the sensitivity
      %  (ELECTLOC[j]->sensitivity) times the channel specific scale factor
      %  (ELECTLOC[j]->calib) devided by 204.8.

      dc = ns.ELECTLOC(j).baseline;
      sf = ns.ELECTLOC(j).sensitivity * ns.ELECTLOC(j).calib / 204.8;
      data(j,:) = sf*(data(j,:) - dc);
   end

   return;					% read_cnt


%---------------------------------------------------------------------
function data = read_avg(fid, ns)

   %  Average Neuroscan data is stored as 4-byte floates in vectored
   %  format for each channel. Each channel has a 5-byte header that
   %  is no longer used. Thus, after SETUP & ELECTLOC, there is an
   %  unused 5-byte header followed by SETUP.pnts of 4-byte floating
   %  point numbers for the first channel; then a 5-byte header for
   %  channel two followed by SETUP.pnts * size(float) bytes, etc.
   %  Therefore, the total number of bytes after SETUP & ELECTLOC is:
   %  SETUP.nchannels * ( 5 + SETUP.pnts * sizeof(float) ). To scale
   %  a data point to microvolts, multiply by the channel-specific
   %  calibration factor (i.e., for electrode j: channel[j]->calib)
   %  and divided by the number of sweeps in the average (i.e., 
   %  channel[j]->n);

   data = zeros(ns.SETUP.nchannels, ns.SETUP.pnts);

   for j = 1:ns.SETUP.nchannels
      fseek(fid, 5, 'cof');
      data(j,:) = [fread(fid, ns.SETUP.pnts, 'float32')]';
      data(j,:) = data(j,:) * ns.ELECTLOC(j).calib / ns.ELECTLOC(j).n;
   end

   return;					% read_avg


%---------------------------------------------------------------------
function SETUP = read_SETUP(fid)

   fseek(fid,0,'bof');

   %  Original structures	
   %  typedef struct{ 
   %     char   rev[12];         /* Revision string                         */
   %     long   NextFile;        /* offset to next file                     */
   %     long   PrevFile;        /* offset to prev file                     */
   %     char   type;            /* File type AVG=0, EEG=1, etc.            */
   %     char   id[20];          /* Patient ID                              */
   %     char   oper[20];        /* Operator ID                             */
   %     char   doctor[20];      /* Doctor ID                               */
   %     char   referral[20];    /* Referral ID                             */
   %     char   hospital[20];    /* Hospital ID                             */
   %     char   patient[20];     /* Patient name                            */
   %     short  int age;         /* Patient Age                             */
   %     char   sex;             /* Patient Sex Male='M', Female='F'        */
   %     char   hand;            /* Handedness Mixed='M',Rt='R', lft='L'    */
   %     char   med[20];         /* Medications                             */
   %     char   category[20];    /* Classification                          */
   %     char   state[20];       /* Patient wakefulness                     */
   %     char   label[20];       /* Session label                           */
   %     char   date[10];        /* Session date string                     */
   %     char   time[12];        /* Session time strin                      */
   %     float  mean_age;        /* Mean age (Group files only)             */
   %     float  stdev;           /* Std dev of age (Group files only)       */
   %     short int n;            /* Number in group file                    */
   %     char   compfile[38];    /* Path and name of comparison file        */
   %     float  SpectWinComp;    // Spectral window compensation factor
   %     float  MeanAccuracy;    // Average respose accuracy
   %     float  MeanLatency;     // Average response latency
   %     char   sortfile[46];    /* Path and name of sort file              */
   %     int    NumEvents;       // Number of events in eventable
   %     char   compoper;        /* Operation used in comparison            */
   %     char   avgmode;         /* Set during online averaging             */
   %     char   review;          /* Set during review of EEG data           */
   %     short unsigned nsweeps;      /* Number of expected sweeps          */
   %     short unsigned compsweeps;   /* Number of actual sweeps            */ 
   %     short unsigned acceptcnt;    /* Number of accepted sweeps          */
   %     short unsigned rejectcnt;    /* Number of rejected sweeps          */
   %     short unsigned pnts;         /* Number of points per waveform      */
   %     short unsigned nchannels;    /* Number of active channels          */
   %     short unsigned avgupdate;    /* Frequency of average update        */
   %     char  domain;           /* Acquisition domain TIME=0, FREQ=1       */
   %     char  variance;         /* Variance data included flag             */
   %     unsigned short rate;    /* D-to-A rate                             */
   %     double scale;           /* scale factor for calibration            */
   %     char  veogcorrect;      /* VEOG corrected flag                     */
   %     char  heogcorrect;      /* HEOG corrected flag                     */
   %     char  aux1correct;      /* AUX1 corrected flag                     */
   %     char  aux2correct;      /* AUX2 corrected flag                     */
   %     float veogtrig;         /* VEOG trigger percentage                 */
   %     float heogtrig;         /* HEOG trigger percentage                 */
   %     float aux1trig;         /* AUX1 trigger percentage                 */
   %     float aux2trig;         /* AUX2 trigger percentage                 */
   %     short int heogchnl;     /* HEOG channel number                     */
   %     short int veogchnl;     /* VEOG channel number                     */
   %     short int aux1chnl;     /* AUX1 channel number                     */
   %     short int aux2chnl;     /* AUX2 channel number                     */
   %     char  veogdir;          /* VEOG trigger direction flag             */
   %     char  heogdir;          /* HEOG trigger direction flag             */
   %     char  aux1dir;          /* AUX1 trigger direction flag             */ 
   %     char  aux2dir;          /* AUX2 trigger direction flag             */
   %     short int veog_n;       /* Number of points per VEOG waveform      */
   %     short int heog_n;       /* Number of points per HEOG waveform      */
   %     short int aux1_n;       /* Number of points per AUX1 waveform      */
   %     short int aux2_n;       /* Number of points per AUX2 waveform      */
   %     short int veogmaxcnt;   /* Number of observations per point - VEOG */
   %     short int heogmaxcnt;   /* Number of observations per point - HEOG */
   %     short int aux1maxcnt;   /* Number of observations per point - AUX1 */
   %     short int aux2maxcnt;   /* Number of observations per point - AUX2 */
   %     char   veogmethod;      /* Method used to correct VEOG             */
   %     char   heogmethod;      /* Method used to correct HEOG             */
   %     char   aux1method;      /* Method used to correct AUX1             */
   %     char   aux2method;      /* Method used to correct AUX2             */
   %     float  AmpSensitivity;  /* External Amplifier gain                 */
   %     char   LowPass;         /* Toggle for Amp Low pass filter          */
   %     char   HighPass;        /* Toggle for Amp High pass filter         */
   %     char   Notch;           /* Toggle for Amp Notch state              */
   %     char   AutoClipAdd;     /* AutoAdd on clip                         */
   %     char   baseline;        /* Baseline correct flag                   */
   %     float  offstart;        /* Start point for baseline correction     */
   %     float  offstop;         /* Stop point for baseline correction      */
   %     char   reject;          /* Auto reject flag                        */
   %     float  rejstart;        /* Auto reject start point                 */
   %     float  rejstop;         /* Auto reject stop point                  */
   %     float  rejmin;          /* Auto reject minimum value               */
   %     float  rejmax;          /* Auto reject maximum value               */
   %     char   trigtype;        /* Trigger type                            */
   %     float  trigval;         /* Trigger value                           */
   %     char   trigchnl;        /* Trigger channel                         */
   %     short int trigmask;     /* Wait value for LPT port                 */
   %     float trigisi;          /* Interstimulus interval (INT trigger)    */
   %     float trigmin;          /* Min trigger out voltage (start of pulse)*/
   %     float trigmax;          /* Max trigger out voltage (during pulse)  */
   %     char  trigdir;          /* Duration of trigger out pulse           */
   %     char  Autoscale;        /* Autoscale on average                    */
   %     short int n2;           /* Number in group 2 (MANOVA)              */
   %     char  dir;              /* Negative display up or down             */
   %     float dispmin;          /* Display minimum (Yaxis)                 */
   %     float dispmax;          /* Display maximum (Yaxis)                 */
   %     float xmin;             /* X axis minimum (epoch start in sec)     */
   %     float xmax;             /* X axis maximum (epoch stop in sec)      */
   %     float AutoMin;          /* Autoscale minimum                       */
   %     float AutoMax;          /* Autoscale maximum                       */
   %     float zmin;             /* Z axis minimum - Not currently used     */
   %     float zmax;             /* Z axis maximum - Not currently used     */
   %     float lowcut;           /* Archival value - low cut on external amp*/ 
   %     float highcut;          /* Archival value - Hi cut on external amp */ 
   %     char  common;           /* Common mode rejection flag              */
   %     char  savemode;         /* Save mode EEG AVG or BOTH               */
   %     char  manmode;          /* Manual rejection of incomming data      */
   %     char  ref[10];          /* Label for reference electode            */
   %     char  Rectify;          /* Rectification on external channel       */
   %     float DisplayXmin;      /* Minimun for X-axis display              */
   %     float DisplayXmax;      /* Maximum for X-axis display              */
   %     char  phase;            /* flag for phase computation              */
   %     char  screen[16];       /* Screen overlay path name                */
   %     short int CalMode;      /* Calibration mode                        */
   %     short int CalMethod;    /* Calibration method                      */
   %     short int CalUpdate;    /* Calibration update rate                 */
   %     short int CalBaseline;  /* Baseline correction during cal          */
   %     short int CalSweeps;    /* Number of calibration sweeps            */
   %     float CalAttenuator;    /* Attenuator value for calibration        */
   %     float CalPulseVolt;     /* Voltage for calibration pulse           */
   %     float CalPulseStart;    /* Start time for pulse                    */
   %     float CalPulseStop;     /* Stop time for pulse                     */  
   %     float CalFreq;          /* Sweep frequency                         */  
   %     char  taskfile[34];     /* Task file name                          */
   %     char  seqfile[34];      /* Sequence file path name                 */
   %     char  SpectMethod;      // Spectral method
   %     char  SpectScaling;     // Scaling employed
   %     char  SpectWindow;      // Window employed
   %     float SpectWinLength;   // Length of window %
   %     char  SpectOrder;       // Order of Filter for Max Entropy method
   %     char  NotchFilter;      // Notch Filter in or out
   %     short HeadGain;         // Current head gain for SYNAMP
   %     int   AdditionalFiles;  // No of additional files
   %     char  unused[5];        // Free space
   %     short  FspStopMethod;   /* FSP - Stoping mode                      */
   %     short  FspStopMode;     /* FSP - Stoping mode                      */
   %     float FspFValue;        /* FSP - F value to stop terminate         */
   %     short int FspPoint;     /* FSP - Single point location             */
   %     short int FspBlockSize; /* FSP - block size for averaging          */
   %     unsigned short FspP1;   /* FSP - Start of window                   */
   %     unsigned short FspP2;   /* FSP - Stop  of window                   */
   %     float FspAlpha;         /* FSP - Alpha value                       */
   %     float FspNoise;         /* FSP - Signal to ratio value             */
   %     short int FspV1;        /* FSP - degrees of freedom                */ 
   %     char  montage[40];      /* Montage file path name                  */ 
   %     char  EventFile[40];    /* Event file path name                    */ 
   %     float fratio;           /* Correction factor for spectral array    */
   %     char  minor_rev;        /* Current minor revision                  */
   %     short int eegupdate;    /* How often incomming eeg is refreshed    */ 
   %     char   compressed;      /* Data compression flag                   */
   %     float  xscale;          /* X position for scale box - Not used     */
   %     float  yscale;          /* Y position for scale box - Not used     */
   %     float  xsize;           /* Waveform size X direction               */
   %     float  ysize;           /* Waveform size Y direction               */
   %     char   ACmode;          /* Set SYNAP into AC mode                  */
   %     unsigned char   CommonChnl;   /* Channel for common waveform       */
   %     char   Xtics;           /* Scale tool- 'tic' flag in X direction   */ 
   %     char   Xrange;          /* Scale tool- range (ms,sec,Hz) flag X dir*/ 
   %     char   Ytics;           /* Scale tool- 'tic' flag in Y direction   */ 
   %     char   Yrange;          /* Scale tool- range (uV, V) flag Y dir    */ 
   %     float  XScaleValue;     /* Scale tool- value for X dir             */
   %     float  XScaleInterval;  /* Scale tool- interval between tics X dir */
   %     float  YScaleValue;     /* Scale tool- value for Y dir             */
   %     float  YScaleInterval;  /* Scale tool- interval between tics Y dir */
   %     float  ScaleToolX1;     /* Scale tool- upper left hand screen pos  */
   %     float  ScaleToolY1;     /* Scale tool- upper left hand screen pos  */
   %     float  ScaleToolX2;     /* Scale tool- lower right hand screen pos */
   %     float  ScaleToolY2;     /* Scale tool- lower right hand screen pos */
   %     short int port;         /* Port address for external triggering    */
   %     long  NumSamples;       /* Number of samples in continous file     */
   %     char  FilterFlag;       /* Indicates that file has been filtered   */
   %     float LowCutoff;        /* Low frequency cutoff                    */
   %     short int LowPoles;     /* Number of poles                         */
   %     float HighCutoff;       /* High frequency cutoff                   */ 
   %     short int HighPoles;    /* High cutoff number of poles             */
   %     char  FilterType;       /* Bandpass=0 Notch=1 Highpass=2 Lowpass=3 */
   %     char  FilterDomain;     /* Frequency=0 Time=1                      */
   %     char  SnrFlag;          /* SNR computation flag                    */
   %     char  CoherenceFlag;    /* Coherence has been  computed            */
   %     char  ContinousType;    /* Method used to capture events in *.cnt  */ 
   %     long  EventTablePos;    /* Position of event table                 */ 
   %     float ContinousSeconds; // Number of seconds to displayed per page
   %     long  ChannelOffset;    // Block size of one channel in SYNAMPS 
   %     char  AutoCorrectFlag;  // Autocorrect of DC values
   %     unsigned char DCThreshold; // Auto correct of DC level 
   %     ELECTLOC elect_tab[N_ELECT];
   %  }SETUP;

   %  Struct							% off + size
   SETUP.rev		= fread(fid,12,'*char')';		% 0 + 12
   SETUP.NextFile	= fread(fid,1,'int32')';		% 12 + 4
   SETUP.PrevFile	= fread(fid,1,'int32')';		% 16 + 4
   SETUP.type		= fread(fid,1,'char')';			% 20 + 1
   SETUP.id		= fread(fid,20,'*char')';		% 21 + 20
   SETUP.oper		= fread(fid,20,'*char')';		% 41 + 20
   SETUP.doctor		= fread(fid,20,'*char')';		% 61 + 20
   SETUP.referral	= fread(fid,20,'*char')';		% 81 + 20
   SETUP.hospital	= fread(fid,20,'*char')';		% 101 + 20
   SETUP.patient	= fread(fid,20,'*char')';		% 121 + 20
   SETUP.age		= fread(fid,1,'int16')';		% 141 + 2
   SETUP.sex		= fread(fid,1,'*char')';		% 143 + 1
   SETUP.hand		= fread(fid,1,'*char')';		% 144 + 1
   SETUP.med		= fread(fid,20,'*char')';		% 145 + 20
   SETUP.category	= fread(fid,20,'*char')';		% 165 + 20
   SETUP.state		= fread(fid,20,'*char')';		% 185 + 20
   SETUP.label		= fread(fid,20,'*char')';		% 205 + 20
   SETUP.date		= fread(fid,10,'*char')';		% 225 + 10
   SETUP.time		= fread(fid,12,'*char')';		% 235 + 12
   SETUP.mean_age	= fread(fid,1,'float32')';		% 247 + 4
   SETUP.stdev		= fread(fid,1,'float32')';		% 251 + 4
   SETUP.n		= fread(fid,1,'int16')';		% 255 + 2
   SETUP.compfile	= fread(fid,38,'*char')';		% 257 + 38
   SETUP.SpectWinComp	= fread(fid,1,'float32')';		% 295 + 4
   SETUP.MeanAccuracy	= fread(fid,1,'float32')';		% 299 + 4
   SETUP.MeanLatency	= fread(fid,1,'float32')';		% 303 + 4
   SETUP.sortfile	= fread(fid,46,'*char')';		% 307 + 46
   SETUP.NumEvents	= fread(fid,1,'int32')';		% 353 + 4
   SETUP.compoper	= fread(fid,1,'char')';			% 357 + 1
   SETUP.avgmode	= fread(fid,1,'char')';			% 358 + 1
   SETUP.review		= fread(fid,1,'char')';			% 359 + 1
   SETUP.nsweeps	= fread(fid,1,'uint16')';		% 360 + 2
   SETUP.compsweeps	= fread(fid,1,'uint16')';		% 362 + 2
   SETUP.acceptcnt	= fread(fid,1,'uint16')';		% 364 + 2
   SETUP.rejectcnt	= fread(fid,1,'uint16')';		% 366 + 2
   SETUP.pnts		= fread(fid,1,'uint16')';		% 368 + 2
   SETUP.nchannels	= fread(fid,1,'uint16')';		% 370 + 2
   SETUP.avgupdate	= fread(fid,1,'uint16')';		% 372 + 2
   SETUP.domain		= fread(fid,1,'char')';			% 374 + 1
   SETUP.variance	= fread(fid,1,'char')';			% 375 + 1
   SETUP.rate		= fread(fid,1,'uint16')';		% 376 + 2
   SETUP.scale		= fread(fid,1,'float64')';		% 378 + 8
   SETUP.veogcorrect	= fread(fid,1,'char')';			% 386 + 1
   SETUP.heogcorrect	= fread(fid,1,'char')';			% 387 + 1
   SETUP.aux1correct	= fread(fid,1,'char')';			% 388 + 1
   SETUP.aux2correct	= fread(fid,1,'char')';			% 389 + 1
   SETUP.veogtrig	= fread(fid,1,'float32')';		% 390 + 4
   SETUP.heogtrig	= fread(fid,1,'float32')';		% 394 + 4
   SETUP.aux1trig	= fread(fid,1,'float32')';		% 398 + 4
   SETUP.aux2trig	= fread(fid,1,'float32')';		% 402 + 4
   SETUP.heogchnl	= fread(fid,1,'int16')';		% 406 + 2
   SETUP.veogchnl	= fread(fid,1,'int16')';		% 408 + 2
   SETUP.aux1chnl	= fread(fid,1,'int16')';		% 410 + 2
   SETUP.aux2chnl	= fread(fid,1,'int16')';		% 412 + 2
   SETUP.veogdir	= fread(fid,1,'char')';			% 414 + 1
   SETUP.heogdir	= fread(fid,1,'char')';			% 415 + 1
   SETUP.aux1dir	= fread(fid,1,'char')';			% 416 + 1
   SETUP.aux2dir	= fread(fid,1,'char')';			% 417 + 1
   SETUP.veog_n		= fread(fid,1,'int16')';		% 418 + 2
   SETUP.heog_n		= fread(fid,1,'int16')';		% 420 + 2
   SETUP.aux1_n		= fread(fid,1,'int16')';		% 422 + 2
   SETUP.aux2_n		= fread(fid,1,'int16')';		% 424 + 2
   SETUP.veogmaxcnt	= fread(fid,1,'int16')';		% 426 + 2
   SETUP.heogmaxcnt	= fread(fid,1,'int16')';		% 428 + 2
   SETUP.aux1maxcnt	= fread(fid,1,'int16')';		% 430 + 2
   SETUP.aux2maxcnt	= fread(fid,1,'int16')';		% 432 + 2
   SETUP.veogmethod	= fread(fid,1,'char')';			% 434 + 1
   SETUP.heogmethod	= fread(fid,1,'char')';			% 435 + 1
   SETUP.aux1method	= fread(fid,1,'char')';			% 436 + 1
   SETUP.aux2method	= fread(fid,1,'char')';			% 437 + 1
   SETUP.AmpSensitivity = fread(fid,1,'float32')';		% 438 + 4
   SETUP.LowPass	= fread(fid,1,'char')';			% 442 + 1
   SETUP.HighPass	= fread(fid,1,'char')';			% 443 + 1
   SETUP.Notch		= fread(fid,1,'char')';			% 444 + 1
   SETUP.AutoClipAdd	= fread(fid,1,'char')';			% 445 + 1
   SETUP.baseline	= fread(fid,1,'char')';			% 446 + 1
   SETUP.offstart	= fread(fid,1,'float32')';		% 447 + 4
   SETUP.offstop	= fread(fid,1,'float32')';		% 451 + 4
   SETUP.reject		= fread(fid,1,'char')';			% 455 + 1
   SETUP.rejstart	= fread(fid,1,'float32')';		% 456 + 4
   SETUP.rejstop	= fread(fid,1,'float32')';		% 460 + 4
   SETUP.rejmin		= fread(fid,1,'float32')';		% 464 + 4
   SETUP.rejmax		= fread(fid,1,'float32')';		% 468 + 4
   SETUP.trigtype	= fread(fid,1,'char')';			% 472 + 1
   SETUP.trigval	= fread(fid,1,'float32')';		% 473 + 4
   SETUP.trigchnl	= fread(fid,1,'char')';			% 477 + 1
   SETUP.trigmask	= fread(fid,1,'int16')';		% 478 + 2
   SETUP.trigisi	= fread(fid,1,'float32')';		% 480 + 4
   SETUP.trigmin	= fread(fid,1,'float32')';		% 484 + 4
   SETUP.trigmax	= fread(fid,1,'float32')';		% 488 + 4
   SETUP.trigdir	= fread(fid,1,'char')';			% 492 + 1
   SETUP.AutoScale	= fread(fid,1,'char')';			% 493 + 1
   SETUP.n2		= fread(fid,1,'int16')';		% 494 + 2
   SETUP.dir		= fread(fid,1,'char')';			% 496 + 1
   SETUP.dispmin	= fread(fid,1,'float32')';		% 497 + 4
   SETUP.dispmax	= fread(fid,1,'float32')';		% 501 + 4
   SETUP.xmin		= fread(fid,1,'float32')';		% 505 + 4
   SETUP.xmax		= fread(fid,1,'float32')';		% 509 + 4
   SETUP.AutoMin	= fread(fid,1,'float32')';		% 513 + 4
   SETUP.AutoMax	= fread(fid,1,'float32')';		% 517 + 4
   SETUP.zmin		= fread(fid,1,'float32')';		% 521 + 4
   SETUP.zmax		= fread(fid,1,'float32')';		% 525 + 4
   SETUP.lowcut		= fread(fid,1,'float32')';		% 529 + 4
   SETUP.highcut	= fread(fid,1,'float32')';		% 533 + 4
   SETUP.common		= fread(fid,1,'char')';			% 537 + 1
   SETUP.savemode	= fread(fid,1,'char')';			% 538 + 1
   SETUP.manmode	= fread(fid,1,'char')';			% 539 + 1
   SETUP.ref		= fread(fid,10,'*char')';		% 540 + 10
   SETUP.Rectify	= fread(fid,1,'char')';			% 550 + 1
   SETUP.DisplayXmin	= fread(fid,1,'float32')';		% 551 + 4
   SETUP.DisplayXmax	= fread(fid,1,'float32')';		% 555 + 4
   SETUP.phase		= fread(fid,1,'char')';			% 559 + 1
   SETUP.screen		= fread(fid,16,'*char')';		% 560 + 16
   SETUP.CalMode	= fread(fid,1,'int16')';		% 576 + 2
   SETUP.CalMethod	= fread(fid,1,'int16')';		% 578 + 2
   SETUP.CalUpdate	= fread(fid,1,'int16')';		% 580 + 2
   SETUP.CalBaseline	= fread(fid,1,'int16')';		% 582 + 2
   SETUP.CalSweeps	= fread(fid,1,'int16')';		% 584 + 2
   SETUP.CalAttenuator	= fread(fid,1,'float32')';		% 586 + 4
   SETUP.CalPulseVolt	= fread(fid,1,'float32')';		% 590 + 4
   SETUP.CalPulseStart	= fread(fid,1,'float32')';		% 594 + 4
   SETUP.CalPulseStop	= fread(fid,1,'float32')';		% 598 + 4
   SETUP.CalFreq	= fread(fid,1,'float32')';		% 602 + 4
   SETUP.taskfile	= fread(fid,34,'*char')';		% 606 + 34
   SETUP.seqfile	= fread(fid,34,'*char')';		% 640 + 34
   SETUP.SpectMethod	= fread(fid,1,'char')';			% 674 + 1
   SETUP.SpectScaling	= fread(fid,1,'char')';			% 675 + 1
   SETUP.SpectWindow	= fread(fid,1,'char')';			% 676 + 1
   SETUP.SpectWinLength	= fread(fid,1,'float32')';		% 677 + 4
   SETUP.SpectOrder	= fread(fid,1,'char')';			% 681 + 1
   SETUP.NotchFilter	= fread(fid,1,'char')';			% 682 + 1
   SETUP.HeadGain	= fread(fid,1,'int16')';		% 683 + 2
   SETUP.AdditionalFiles = fread(fid,1,'int32')';		% 685 + 4
   SETUP.unused		= fread(fid,5,'*char')';		% 689 + 5
   SETUP.FspStopMethod	= fread(fid,1,'int16')';		% 694 + 2
   SETUP.FspStopMode	= fread(fid,1,'int16')';		% 696 + 2
   SETUP.FspFvalue	= fread(fid,1,'float32')';		% 698 + 4
   SETUP.FspPoint	= fread(fid,1,'int16')';		% 702 + 2
   SETUP.FspBlockSize	= fread(fid,1,'int16')';		% 704 + 2
   SETUP.FspP1		= fread(fid,1,'uint16')';		% 706 + 2
   SETUP.FspP2		= fread(fid,1,'uint16')';		% 708 + 2
   SETUP.FspAlpha	= fread(fid,1,'float32')';		% 710 + 4
   SETUP.FspNoise	= fread(fid,1,'float32')';		% 714 + 4
   SETUP.FspV1		= fread(fid,1,'int16')';		% 718 + 2
   SETUP.montage	= fread(fid,40,'*char')';		% 720 + 40
   SETUP.EventFile	= fread(fid,40,'*char')';		% 760 + 40
   SETUP.fratio		= fread(fid,1,'float32')';		% 800 + 4
   SETUP.minor_rev	= fread(fid,1,'char')';			% 804 + 1
   SETUP.eegupdate	= fread(fid,1,'int16')';		% 805 + 2
   SETUP.compressed	= fread(fid,1,'char')';			% 807 + 1
   SETUP.xscale		= fread(fid,1,'float32')';		% 808 + 4
   SETUP.yscale		= fread(fid,1,'float32')';		% 812 + 4
   SETUP.xsize		= fread(fid,1,'float32')';		% 816 + 4
   SETUP.ysize		= fread(fid,1,'float32')';		% 820 + 4
   SETUP.ACmode		= fread(fid,1,'char')';			% 824 + 1
   SETUP.CommonChnl	= fread(fid,1,'char')';			% 825 + 1
   SETUP.Xtics		= fread(fid,1,'char')';			% 826 + 1
   SETUP.Xrange		= fread(fid,1,'char')';			% 827 + 1
   SETUP.Ytics		= fread(fid,1,'char')';			% 828 + 1
   SETUP.Yrange		= fread(fid,1,'char')';			% 829 + 1
   SETUP.XScaleValue	= fread(fid,1,'float32')';		% 830 + 4
   SETUP.XScaleInterval	= fread(fid,1,'float32')';		% 834 + 4
   SETUP.YScaleValue	= fread(fid,1,'float32')';		% 838 + 4
   SETUP.YScaleInterval	= fread(fid,1,'float32')';		% 842 + 4
   SETUP.ScaleToolX1	= fread(fid,1,'float32')';		% 846 + 4
   SETUP.ScaleToolY1	= fread(fid,1,'float32')';		% 850 + 4
   SETUP.ScaleToolX2	= fread(fid,1,'float32')';		% 854 + 4
   SETUP.ScaleToolY2	= fread(fid,1,'float32')';		% 858 + 4
   SETUP.port		= fread(fid,1,'int16')';		% 862 + 2
   SETUP.NumSamples	= fread(fid,1,'int32')';		% 864 + 4
   SETUP.FilterFlag	= fread(fid,1,'char')';			% 868 + 1
   SETUP.LowCutoff	= fread(fid,1,'float32')';		% 869 + 4
   SETUP.LowPoles	= fread(fid,1,'int16')';		% 873 + 2
   SETUP.HighCutoff	= fread(fid,1,'float32')';		% 875 + 4
   SETUP.HighPoles	= fread(fid,1,'int16')';		% 879 + 2
   SETUP.FilterType	= fread(fid,1,'char')';			% 881 + 1
   SETUP.FilterDomain	= fread(fid,1,'char')';			% 882 + 1
   SETUP.SnrFlag	= fread(fid,1,'char')';			% 883 + 1
   SETUP.CoherenceFlag	= fread(fid,1,'char')';			% 884 + 1
   SETUP.ContinuousType	= fread(fid,1,'char')';			% 885 + 1
   SETUP.EventTablePos	= fread(fid,1,'int32')';		% 886 + 4
   SETUP.ContinuousSeconds = fread(fid,1,'float32')';		% 890 + 4
   SETUP.ChannelOffset	= fread(fid,1,'int32')';		% 894 + 4
   SETUP.AutoCorrectFlag = fread(fid,1,'char')';		% 898 + 1
   SETUP.DCThreshold	= fread(fid,1,'char')';			% 899 + 1
								% 900 total
   return;					% read_SETUP


%---------------------------------------------------------------------
function ELECTLOC = read_ELECTLOC(fid)

   %  Original structures	 
   %  typedef struct {          /* Electrode structure  ------------------- */
   %    char  lab[10];          /* Electrode label - last bye contains NULL */
   %    char  reference;        /* Reference electrode number               */
   %    char  skip;             /* Skip electrode flag ON=1 OFF=0           */
   %    char  reject;           /* Artifact reject flag                     */
   %    char  display;          /* Display flag for 'STACK' display         */
   %    char  bad;              /* Bad electrode flag                       */
   %    unsigned short int n;   /* Number of observations                   */
   %    char  avg_reference;    /* Average reference status                 */
   %    char  ClipAdd;          /* Automatically add to clipboard           */
   %    float x_coord;          /* X screen coord. for 'TOP' display        */
   %    float y_coord;          /* Y screen coord. for 'TOP' display        */
   %    float veog_wt;          /* VEOG correction weight                   */
   %    float veog_std;         /* VEOG std dev. for weight                 */
   %    float snr;              /* signal-to-noise statistic                */
   %    float heog_wt;          /* HEOG Correction weight                   */
   %    float heog_std;         /* HEOG Std dev. for weight                 */
   %    short int baseline;     /* Baseline correction value in raw ad units*/
   %    char  Filtered;         /* Toggel indicating file has be filtered   */
   %    char  Fsp;              /* Extra data                               */
   %    float aux1_wt;          /* AUX1 Correction weight                   */ 
   %    float aux1_std;         /* AUX1 Std dev. for weight                 */
   %    float sensitivity;      /* electrode sensitivity                    */
   %    char  Gain;             /* Amplifier gain                           */
   %    char  HiPass;           /* Hi Pass value                            */
   %    char  LoPass;           /* Lo Pass value                            */
   %    unsigned char Page;     /* Display page                             */
   %    unsigned char Size;     /* Electrode window display size            */
   %    unsigned char Impedance;/* Impedance test                           */
   %    unsigned char PhysicalChnl; /* Physical channel used                */
   %    char  Rectify;           /* Free space                              */
   %    float calib;            /* Calibration factor                       */
   %  }ELECTLOC;

   %  Struct							% off + size
   ELECTLOC.lab			= fread(fid,10,'*char')';	% 0 + 10
   ELECTLOC.reference		= fread(fid,1,'char')';		% 10 + 1
   ELECTLOC.skip		= fread(fid,1,'char')';		% 11 + 1
   ELECTLOC.reject		= fread(fid,1,'char')';		% 12 + 1
   ELECTLOC.display		= fread(fid,1,'char')';		% 13 + 1
   ELECTLOC.bad			= fread(fid,1,'char')';		% 14 + 1
   ELECTLOC.n			= fread(fid,1,'uint16')';	% 15 + 2
   ELECTLOC.avg_reference	= fread(fid,1,'char')';		% 17 + 1
   ELECTLOC.ClipAdd		= fread(fid,1,'char')';		% 18 + 1
   ELECTLOC.x_coord		= fread(fid,1,'float32')';	% 19 + 4
   ELECTLOC.y_coord		= fread(fid,1,'float32')';	% 23 + 4
   ELECTLOC.veog_wt		= fread(fid,1,'float32')';	% 27 + 4
   ELECTLOC.veog_std		= fread(fid,1,'float32')';	% 31 + 4
   ELECTLOC.snr			= fread(fid,1,'float32')';	% 35 + 4
   ELECTLOC.heog_wt		= fread(fid,1,'float32')';	% 39 + 4
   ELECTLOC.heog_std		= fread(fid,1,'float32')';	% 43 + 4
   ELECTLOC.baseline		= fread(fid,1,'int16')';	% 47 + 2
   ELECTLOC.Filtered		= fread(fid,1,'char')';		% 49 + 1
   ELECTLOC.Fsp			= fread(fid,1,'char')';		% 50 + 1
   ELECTLOC.aux1_wt		= fread(fid,1,'float32')';	% 51 + 4
   ELECTLOC.aux1_std		= fread(fid,1,'float32')';	% 55 + 4
   ELECTLOC.sensitivity		= fread(fid,1,'float32')';	% 59 + 4
   ELECTLOC.Gain		= fread(fid,1,'char')';		% 63 + 1
   ELECTLOC.HiPass		= fread(fid,1,'char')';		% 64 + 1
   ELECTLOC.LoPass		= fread(fid,1,'char')';		% 65 + 1
   ELECTLOC.Page		= fread(fid,1,'char')';		% 66 + 1
   ELECTLOC.Size		= fread(fid,1,'char')';		% 67 + 1
   ELECTLOC.Impedance		= fread(fid,1,'char')';		% 68 + 1
   ELECTLOC.Physicalchnl	= fread(fid,1,'char')';		% 69 + 1
   ELECTLOC.Rectify		= fread(fid,1,'char')';		% 70 + 1
   ELECTLOC.calib		= fread(fid,1,'float32')';	% 71 + 4
								% 75 total
   return;					% read_ELECTLOC


%---------------------------------------------------------------------
function TEEG = read_TEEG(fid, SETUP)

   fseek(fid,SETUP.EventTablePos,'bof');

   %  Original structures
   %  typedef struct{
   %     unsigned char Teeg;	// 1 for event type 1; 2 for event type 2
   %     long Size;
   %     union {
   %         void *Ptr;      //Memory pointer
   %         long Offset;    //Relative file position 
   %                         //0 Means the data start immediately
   %                         //>0 Means the data starts at a relative offset
   %                         // from current position at the end of the tag
   %     };
   %  } TEEG;

   %  Struct							% off + size
   TEEG.Teeg	= fread(fid,1,'char')';				% 0 + 1
   TEEG.Size	= fread(fid,1,'int32')';			% 1 + 4
   TEEG.Offset	= fread(fid,1,'int32')';			% 5 + 4
								% 9 total
   return;					% read_TEEG


%---------------------------------------------------------------------
function EVENT = read_EVENT(fid, ns)

   if ns.TEEG.Teeg == 1				% event type 1

      %  Original structures
      %  typedef struct{
      %     unsigned short	StimType; //range  0-65535
      %     unsigned char	KeyBoard; // corresponding to function keys+1
      %     unsigned char	KeyPad:4; //range  0-15  bit coded response pad
      %					  //values 0xd=Accept 0xc=Reject 
      %     long 		Offset;   //file offset of event  
      %  } EVENT1;

      %  Struct							% off + size
      EVENT.StimType	= fread(fid,1,'uint16')';		% 0 + 2
      EVENT.Keyboard	= fread(fid,1,'char')';			% 2 + 1
      EVENT.KeyPad	= fread(fid,1,'char')';			% 3 + 1
      EVENT.Offset	= fread(fid,1,'int32')';		% 4 + 4
								% 8 total
   elseif ns.TEEG.Teeg == 2			% event type 2

      %  Original structures
      %  typedef struct{
      %     EVENT1	Event1; 
      %     short	Type;
      %     short	Code;       
      %     float32	Latency;
      %     char	EpochEvent;
      %     char	Accept;
      %     char	Accuracy;
      %  } EVENT2;

      %  Struct							% off + size
      EVENT.StimType	= fread(fid,1,'uint16')';		% 0 + 2
      EVENT.Keyboard	= fread(fid,1,'char')';			% 2 + 1
      EVENT.KeyPad	= fread(fid,1,'char')';			% 3 + 1
      EVENT.Offset	= fread(fid,1,'int32')';		% 4 + 4
      EVENT.Type	= fread(fid,1,'int16')';		% 8 + 2
      EVENT.Code	= fread(fid,1,'int16')';		% 10 + 2
      EVENT.Latency	= fread(fid,1,'float32')';		% 12 + 4
      EVENT.EpochEvent	= fread(fid,1,'char')';			% 16 + 1
      EVENT.Accept	= fread(fid,1,'char')';			% 17 + 1
      EVENT.Accuracy	= fread(fid,1,'char')';			% 18 + 1
								% 19 total
   else
      error('Invalid Event table for continuous NeuroScan data');
   end

   %  Make EVENT.Offset relative to the first time point
   %  (original EVENT.Offset was file offset position)
   %
   EVENT.Offset = ...
	( EVENT.Offset - (900 + 75 * ns.SETUP.nchannels) ) / ns.SETUP.nchannels;

   %  Convert EVENT.Offset (in bytes) to EVENT.Offset (in data points)
   %  since each data point is 2-byte (16-bit short integer)
   %
   if strcmpi(ns.precision, 'int32')
      EVENT.Offset = EVENT.Offset / 4;
   else
      EVENT.Offset = EVENT.Offset / 2;
   end;

   return;					% read_EVENT


%---------------------------------------------------------------------
function SWEEP = read_SWEEP(fid, SETUP)

   %  Original structures
   %  typedef struct{
   %     char accept;		/* accept byte	*/
   %     short ttype;		/* trial type	*/
   %     short correct;		/* accuracy	*/
   %     float rt;		/* reaction time */
   %     short response;	/* response type */
   %     short reserved;	/* not used	*/
   %  } SWEEP_HEAD;

   %  Struct							% off + size
   SWEEP.accept	  = fread(fid,1,'char')';			% 0 + 1
   SWEEP.ttype	  = fread(fid,1,'int16')';			% 1 + 2
   SWEEP.correct  = fread(fid,1,'int16')';			% 3 + 2
   SWEEP.rt	  = fread(fid,1,'float32')';			% 5 + 4
   SWEEP.response = fread(fid,1,'int16')';			% 9 + 2
   SWEEP.reserved = fread(fid,1,'int16')';			% 11 + 2
								% 13 total
   return;					% read_SWEEP

