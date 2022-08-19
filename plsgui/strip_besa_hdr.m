%STRIP_BESA_HDR  Remove non-numerical header lines in the BESA file.
%
%   Usage: strip_besa_hdr(filename, [outputfile]);
%
%   filename -	Name of BESA file with non-numerical header. Please
%		notice that old BESA file contains all header 
%		information in its first line; however, new BESA 
%		file contains header information in first sevreal
%		lines.
%
%   outputfile - If it is specified, a new output file with this
%		file name will be created. BESA matrix without 
%		non-numerical header line(s) will be saved in
%		this file in plain text format. Otherwise, no new
%		file will be be created.
%
%   besa_matrix - BESA matrix without non-numerical header line(s)
%

%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function besa_matrix = strip_besa_hdr(filename, outputfile)

   besa_matrix = [];

   fid = fopen(filename);

   if fid == -1
      error('Specified BESA file does not exist');
      return;
   end

   dat = fread(fid);
   fclose(fid);
   nl = find(dat==10);

   hdr = dat(1:nl(1));
   hdrs = char(hdr');
   hdrn = str2num(hdrs);

   i = 1;
   while isempty(hdrn)
      hdr = dat(nl(i):nl(i+1));
      hdrs = char(hdr');
      hdrn = str2num(hdrs);
      i = i + 1;
   end

   if i == 1
      hdr = 1;
   else
      hdr = nl(i-1);
   end

   hdr = dat(hdr:end);
   hdrs = char(hdr');
   besa_matrix = str2num(hdrs);

   if exist('outputfile', 'var')
      save(outputfile, '-ascii', 'besa_matrix');
   end

   return;

