function [x] = hrf_ml_spm_cat(x,d)

if ~iscell(x), return, end
 
[n m] = size(x);

if nargin > 1 
    if d == 1
        y = cell(1,m);
        for i = 1:m
            y{i} = hrf_ml_spm_cat(x(:,i));
        end 
    elseif d == 2
        y = cell(n,1);
        for i = 1:n
            y{i} = hrf_ml_spm_cat(x(i,:));
        end 
    else
        error('uknown option')
    end

    x      = y;
    return
end
 
for i = 1:n
for j = 1:m
    if iscell(x{i,j})
        x{i,j} = hrf_ml_spm_cat(x{i,j});
    end
    [u v]  = size(x{i,j});
    I(i,j) = u;
    J(i,j) = v;
end
end
I     = max(I,[],2);
J     = max(J,[],1);
 
[n m] = size(x);
for i = 1:n
for j = 1:m
    if isempty(x{i,j})
%        x{i,j} = sparse(I(i),J(j));
        x{i,j} = zeros(I(i),J(j));
    end
end
end
 
for i = 1:n
    y{i,1} = cat(2,x{i,:});
end
try
    x = sparse(cat(1,y{:}));
catch
    x = cat(1,y{:});
end

