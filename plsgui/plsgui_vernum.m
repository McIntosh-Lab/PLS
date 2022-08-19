%usage: ver_num = plsgui_vernum
%
function ver_num = plsgui_vernum()

   [tmp ver_num] = textread('whatsnew.txt','%s%s',1);

%   ver_num = str2num(ver_num{1});
   ver_num = ver_num{1};

   return;

