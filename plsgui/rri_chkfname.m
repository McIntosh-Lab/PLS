%  Usage: status = rri_chkfname(fname, module, type)
%
function status = rri_chkfname(fname, module, type)

   str_len = length(['_', module, type, '.mat']);

   if length(fname) <= str_len
      status = 0;
      return;
   end

   fname = fname(end-str_len+1:end);
   status = strcmp(fname,['_',module,type,'.mat']);

   return;

