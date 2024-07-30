%
% copyobj_legacy
%
% workaround for changed behaviour of copyobj in Matlab 2014b
%
% new_handle = copyobj(h,p)
% copyobj(___,'legacy')
%
% Copy graphics objects and their descendants
%
% copyobj(___,'legacy') copies object callback properties and object application data.
% This behavior is consistent with versions of copyobj before Matlab release R2014b.
%

function template = copyobj_legacy(source_hdl,parent_hdl)
  if verLessThan('matlab', '8.4.0') % R2014b
    template = copyobj(source_hdl, parent_hdl);
  else
    template = copyobj(source_hdl, parent_hdl, 'legacy');
  end
end
