function batch_plsgui(varargin)

   if nargin < 1
      error('Usage: batch_plsgui(batch_text_file_name(s))');
   end

   p = which('plsgui');
   [p f] = fileparts(p); [p f] = fileparts(p);
   cmdloc = fullfile(p, 'plscmd');
   addpath(cmdloc);

   for i = 1:nargin
      batch_file = varargin{i};
      fid = fopen(batch_file);

      tmp = fgetl(fid);

      if ischar(tmp) & ~isempty(tmp)
         tmp = strrep(tmp, char(9), ' ');
         tmp = deblank(fliplr(deblank(fliplr(tmp))));
      end

      while ~feof(fid) & (isempty(tmp) | isnumeric(tmp) | strcmpi(tmp(1), '%'))
         tmp = fgetl(fid);

         if ischar(tmp) & ~isempty(tmp)
            tmp = strrep(tmp, char(9), ' ');
            tmp = deblank(fliplr(deblank(fliplr(tmp))));
         end
      end

      fseek(fid, 0, 'bof');

      if ischar(tmp) & ~isempty(tmp)
         tok = strtok(tmp);
      else
         tok = '';
      end

      if strcmpi(tok, 'result_file')
         batch_pls_analysis(fid);
      else
         batch_create_datamat(fid);
      end
   end

   return;					% batch_plsgui

