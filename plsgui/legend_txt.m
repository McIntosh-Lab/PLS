function legend_txt(oh)

   for i=1:length(oh)
      if strcmpi(get(oh(i),'type'),'text')
         set(oh(i),'interpreter','none');
      end
   end

   return;

