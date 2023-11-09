function [C,RES,LAG] = mregresslag(Y,X,maxlag)

% [C,RES] = MREGRESSLAG(Y,X)
%   returns the matrix C of regression coefficients in the linear model 
%   Y = X*C, and the vector RES of regression residuals.
%   X is an M-by-P design matrix, with rows corresponding to observations
%   and columns to predictor variables. Y is an N-by-O matrix of response
%   observations. If M=N, MREGRESSLAG(Y,X) is equal to X\Y. If not,
%   regression is computed by shifting the design matrix, and return C
%   where RES is minimum.
%   If Y is not matrix, C is reshaped to match the input argument X,
%   computed in the linear model Y(:,:) = X*C(:,:).
%   If X and Y are not matrix with the same number of dimensions,
%   MREGRESSLAG is applied on each matrix at the dimensions over 3; C is
%   computed in the linear model Y(:,:,ii) = X(:,:,ii)*C(:,:,ii).
% 
% [C,RES,LAG] = MREGRESSLAG(Y,X,MAXLAG)
%   allows extra shift in the regression over the range of lags:  
%   -MAXLAG to MAXLAG.
% 
% Example: 
%   t = linspace(0,1,500);
%   X = [sin(3*2*pi*t+pi/3); sin(16*2*pi*t-pi/10); sin(37*2*pi*t+5*pi/3)]';
%   Ctrue = [2,-1,3; 5,0.2,1; -1,-2,-3; 3,1,4; 2,2,-1]';
%   Y = X*Ctrue + randn(size(X*Ctrue))*0.5;
%   Y(:,4) = circshift(Y(:,4),17);
%   Y(:,5) = circshift(Y(:,5),-10);
%   X = X(101:(end-50),:);
% 
%   maxlag = 50;
%   [C,RES,LAG] = mregresslag(Y,X,maxlag);
%   disp(C-Ctrue); disp(LAG-100);
% 
% See also MLDIVIDE, REGRESS, XCORR

% 20230616 Yuasa
% 20230706 Yuasa: implement 3-D mode

%-- Set lag
%%%%%%%%% Element Mode %%%%%%%%%
if ~ismatrix(X)
ovsizeX = size(X,3:ndims(X));
ovsizeY = size(Y,3:ndims(Y));
assert(ndims(X) == ndims(Y) && isequal(ovsizeX,ovsizeY), 'Arguments must be 2-D.');
C   = zeros([size(X,2),size(Y,2),ovsizeX]);
RES = zeros([1,size(Y,2),ovsizeX]);
LAG = RES;
for ii=1:prod(ovsizeX)
    [C(:,:,ii),RES(:,:,ii),LAG(:,:,ii)] = mregresslag(Y(:,:,ii),X(:,:,ii),maxlag);
end

%%%%%%%%% Squeeze Mode %%%%%%%%%
elseif ~ismatrix(Y)
[C,RES,LAG] = mregresslag(Y(:,:),X,maxlag);
ovsizeY = num2cell(size(Y,2:ndims(Y)));
C   = reshape(C,  [],ovsizeY{:});
RES = reshape(RES,[],ovsizeY{:});
LAG = reshape(LAG,[],ovsizeY{:});

%%%%%%%%%%%%  MAIN  %%%%%%%%%%%%
else
lengthX = size(X,1); lengthY = size(Y,1);
if ~exist("maxlag","var") || isempty(maxlag)
    maxlag = 0;
end
assert(isscalar(maxlag) || isempty(maxlag), message('MATLAB:xcorr:MaxLagMustBeScalar'));
assert(isnumeric(maxlag),                   message('MATLAB:xcorr:UnknInput'));
maxlag = min(abs(double(maxlag)),min(lengthX,lengthY)-1);
assert(maxlag == floor(maxlag),             message('MATLAB:xcorr:MaxLagMustBeInteger'));
lags = (min(lengthY-lengthX,0)-maxlag):(max(lengthY-lengthX,0)+maxlag);
nlag = length(lags);

%-- Regression with shifting
C   = zeros(size(X,2),size(Y,2),nlag);
RES = zeros(1,size(Y,2),nlag);
tidxBase = 1:max(lengthX,lengthY);
for lagidx = 1:nlag
    tidxX = tidxBase-lags(lagidx); tidxX(tidxX<1|tidxX>lengthX) = [];
    tidxY = tidxBase+lags(lagidx); tidxY(tidxY<1|tidxY>lengthY) = [];
    comlength = min(length(tidxX),length(tidxY));
    tidxX = tidxX(1:comlength);    tidxY = tidxY(1:comlength);

    C(:,:,lagidx)   = X(tidxX,:)\Y(tidxY,:);
    RES(:,:,lagidx) = vecnorm(Y(tidxY,:)-X(tidxX,:)*C(:,:,lagidx),2,1);
end
[RES,LAG] = min(RES,[],3,'linear');
C   = C(:,LAG);
LAG = lags(ceil(LAG./length(RES)));
end
