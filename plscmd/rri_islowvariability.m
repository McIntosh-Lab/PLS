function status = rri_islowvariability(bodat, behavdata)

   status = 0;

   %  Get what is in this particular behavmat
   %
   origU=unique(behavdata);

   %  Get how are those unique values clustered
   %  & does any one of them appear too often
   %
   for j=1:length(origU);
      bodatU(j)=length(find(bodat==origU(j)));
   end

   if max(bodatU)/length(behavdata) >= 0.5
      status = 1;
   end

   return;

