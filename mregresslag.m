function [C,RES,LAG] = mregresslag(Y,X,maxlag)

% [C,RES] = MREGRESSLAG(Y,X)
%   returns the matrix C of regression coefficients in the linear model 
%   Y = X*B, and the vector RES of regression residuals.
%   X is an M-by-P design matrix, with rows corresponding to observations
%   and columns to predictor variables. Y is an N-by-O matrix of response
%   observations. If M=N, MREGRESSLAG(Y,X) is equal to X\Y. If not,
%   regression is computed by shifting the design matrix, and return C
%   where RES is minimum.
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

%-- Set lag
lengthX = size(X,1); lengthY = size(Y,1);
if ~exist("maxlag","var") || isempty(maxlag)
    maxlag = 0;
end
if ~isscalar(maxlag) && ~isempty(maxlag)
    error(message('MATLAB:xcorr:MaxLagMustBeScalar'));
end
if ~isnumeric(maxlag)
    error(message('MATLAB:xcorr:UnknInput'));
end
maxlag = min(abs(double(maxlag)),min(lengthX,lengthY)-1);
if maxlag ~= floor(maxlag)
    error(message('MATLAB:xcorr:MaxLagMustBeInteger'));
end
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
