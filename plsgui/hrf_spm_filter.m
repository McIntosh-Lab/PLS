
% From SPM program

%---------------------------------------------
%---------------------------------------------
function [argout] = hrf_spm_filter(K,Y)

if nargin == 1 & isstruct(K)
    for s = 1:length(K)
        k       = length(K(s).row);
        n       = fix(2*(k*K(s).RT)/K(s).HParam + 1);
        X0      = hrf_spm_dctmtx(k,n);
        K(s).X0 = X0(:,2:end);
    end

    argout = K;
else
    if isstruct(K)
        if ~isfield(K(1),'X0')
            K = hrf_spm_filter(K);
        end

        for s = 1:length(K)
            y = Y(K(s).row,:);
            y = y - K(s).X0*(K(s).X0'*y);
            Y(K(s).row,:) = y;
        end
    else
        Y = K*Y;
    end

    argout = Y;
end


%---------------------------------------------
%---------------------------------------------
function C = hrf_spm_dctmtx(N,K,n,f)

d = 0;

if nargin == 1, K = N; end;

if any(nargin == [1 2]),
    n = (0:(N-1))';
elseif nargin == 3,
    if strcmp(n,'diff'),
        d = 1;
        n = (0:(N-1))';
    elseif strcmp(n,'diff2'),
        d = 2;
        n = (0:(N-1))';
    else
        n = n(:);
    end
elseif nargin == 4,
    n = n(:);
    if strcmp(f,'diff'),
        d = 1;
    elseif strcmp(f,'diff2'),
        d = 2;
    else
        error('Incorrect Usage');
    end
else
    error('Incorrect Usage');
end

C = zeros(size(n,1),K);

if d == 0,
    C(:,1)=ones(size(n,1),1)/sqrt(N);
    for k=2:K
        C(:,k) = sqrt(2/N)*cos(pi*(2*n+1)*(k-1)/(2*N));
    end
elseif d == 1,
    for k=2:K
        C(:,k) = -2^(1/2)*(1/N)^(1/2)*sin(1/2*pi*(2*n*k-2*n+k-1)/N)*pi*(k-1)/N;
    end
elseif d == 2,
    for k=2:K,
        C(:,k) = -2^(1/2)*(1/N)^(1/2)*cos(1/2*pi*(2*n+1)*(k-1)/N)*pi^2*(k-1)^2/N^2;
    end;
else
    error('Can''t do this');
end

