%READ_EEG  will  Read in EEG data file.
%
%  Usage: [data EEG_format] = read_eeg(filename, EEG_format);
%
%  data - data matrix with a size of numbers of channel by numbers of
%	time point, or vice versa.
%
%  filename - EEG data file name.
%
%  EEG_format - structure containing a 'vendor' name, and a
%	'machineformat'. If not provided, ASCII file will be assumed.
%
%  - Jimmy Shen (pls@rotman-baycrest.on.ca)
%
function [data, EEG_format] = read_eeg(filename, varargin)

   if ~exist('filename','var'),
      error('Usage: [data EEG_format] = read_eeg(filename, EEG_format);');
   end

   if ~exist(filename,'file')
      error([filename, ': Can''t open file']);
   end

   if nargin > 1
      EEG_format = varargin{1};
   else
      error('Usage: [data EEG_format] = read_eeg(filename, EEG_format);');
   end

   if isempty(EEG_format) | ( isfield(EEG_format, 'vendor') & ...
      strcmpi(EEG_format.vendor, 'besa') )

      try
         data = load(filename);	% fast read for no header EEG file
         return;
      catch
         fid = fopen(filename);	% open file

         if fid == -1		% error to open the file
            error([filename, ': Can''t open file']);
         end

         hdr = fgetl(fid);	% ignore 1st line that is EEG header
         hdr = hdr(1:4);

         if strcmpi(hdr,'npts') | strcmpi(hdr,'[ave')

            %  If it is BESA file, call strip_besa_hdr routine
            %
            fclose(fid);
            data = strip_besa_hdr(filename);

         else

            %  Otherwise, simply try the rest of lines by ignoring
            %  the 1st line, and convert data to double
            %
            i = 1;
            while ~feof(fid)
               tmp = fgetl(fid);
               if ~ischar(tmp)
                  if isnumeric(tmp) & tmp == -1
                  else
                     data = [];
                  end
                  break;
               end

               tmp = str2num(tmp);
               if isempty(tmp)
                  data = [];
                  break;
               end

               if exist('data','var') & length(tmp) ~= size(data,2)
                  data = [];
                  break;
               end

               data(i,:) = tmp;
               i = i + 1;
            end

            fclose(fid);
         end
      end

   else

      if ~isempty(EEG_format) & isfield(EEG_format, 'vendor') & ...
	isfield(EEG_format, 'machineformat')

         switch upper(EEG_format.vendor)
            case 'ANT'		% Advanced Neuro Technology

               ant = load_ant(filename, EEG_format.machineformat);
               data = ant.means;

            case 'EGI'		% Electrical Geodesics Inc

               egi = load_egi(filename, EEG_format.machineformat);
               data = egi.data;

            otherwise		% NEUROSCAN and Compumedics

               ns = load_neuroscan(filename, 'avg', EEG_format.machineformat);
               data = ns.data;
         end;

         return;
      end
   end

   return;					% read_eeg

