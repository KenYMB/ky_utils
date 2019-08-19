function [imf, res] = emd(x, maxnumimf, sdthresh, maxnumiter, interp_method)
% Empiricial Mode Decomposition (Hilbert-Huang Transform)
% imf = emd(x)
% imf = emd(x,Interpolation)
% imf = emd(x,MaxNumIMF,SiftRelativeTolerance,SiftMaxIterations,Interpolation)
% [imf,residual] = emd(x,MaxNumIMF,SiftRelativeTolerance,SiftMaxIterations,Interpolation)
% 
%   'x'                     = time-domain signal. x should be a column vector
%                             or a matrix of column vectors.
%   'MaxNumIMF'             = Maximum number of IMFs extracted. (default = 10)
%   'SiftRelativeTolerance' = convergence criterion. (default = 0.2)
%   'SiftMaxIterations'     = maximum iteration number of convergence.
%                             (default = 100)
%   'Interpolation'         = 'spline (default)' or 'pchip', interpolation method.
% 
%   'imf'                   = matrix of IMFs. Last cell is residual.
%   'residual'              = residual of the signal.
% 
% Decomposition stops when one of signals satisfies the criterion.
% 
% See also, PLOT_HHT, HHT

% Copyright (c) 2016, Alan Tan
% All rights reserved.

% 20190419 Yuasa: modified

narginchk(1,5);
nargoutchk(0,2);

if ~exist('maxnumimf','var') || isempty(maxnumimf) || ischar(maxnumimf)
    if exist('maxnumimf','var') && ~isempty(maxnumimf) && ischar(maxnumimf),
        interp_method = maxnumimf;    end
    maxnumimf = 10;
end
if ~exist('sdthresh','var') || isempty(sdthresh) || ischar(sdthresh)
    if exist('sdthresh','var') && ~isempty(sdthresh) && ischar(sdthresh),
        interp_method = sdthresh;    end
    sdthresh = 0.2;
end
if ~exist('maxnumiter','var') || isempty(maxnumiter) || ischar(maxnumiter)
    if exist('maxnumiter','var') && ~isempty(maxnumiter) && ischar(maxnumiter),
        interp_method = maxnumiter;    end
    maxnumiter = 100;
end
if ~exist('interp_method','var') || isempty(interp_method)
    interp_method = 'spline';
end

if     ~ismatrix(x)
    error('Input signal should be a column vector or a matrix of column vectors');
elseif ndims(x)==1;
    c   = transpose(x(:));
else
    c   = transpose(x);
end

imf = cell(0);
while ~ismonotonic(c) && length(imf)<=maxnumimf
   h = cell(1,size(c,1));
   for isig = 1:size(c,1)
      h{isig} = c(isig,:);
      sd = Inf;
      iter = 0;
      while ((sd > sdthresh) || ~isimf(h{isig})) && (iter < maxnumiter)
         %-- find local max/min points; spline interpolate to get max and min envelopes
         m  = ( getspline(h{isig},interp_method) + (-getspline(-h{isig},interp_method)) ) / 2;
         hnew = h{isig} - m;

         %-- calculate standard deviation
         sd = sum((h{isig} - hnew).^2) / sum(h{isig}.^2);
         h{isig} = hnew;
         
         iter = iter + 1;
      end
   end

   imf{end+1} = cat(3,h{:});          % imf
   c          = c - cat(1,h{:});
end
imf = permute(cat(1,imf{1:end-1}),[2,1,3]);
if nargout > 1
    res = permute(c,[2,1,3]);             % residual
end

%%% FUNCTIONS

function u = ismonotonic(x)
u1 = zeros(1,size(x,1));
for isig = 1:size(x,1)
  u1(isig) = length(findpeaks(x(isig,:)))*length(findpeaks(-x(isig,:)));
end
if min(u1) > 0, u = 0;
else       u = 1; end

function u = isimf(x)

N  = length(x);
u1 = sum(x(1:(N-1)).*x(2:N) < 0);
u2 = length(findpeaks(x))+length(findpeaks(-x));
if abs(u1-u2) > 1, u = 0;
else               u = 1; end

function s = getspline(x,interp_method)

N = length(x);
p = findpeaks(x);
switch interp_method
    case 'spline', s = spline([0 p N+1],[0 x(p) 0],1:N);
    case 'pchip',  s = pchip([0 p N+1],[0 x(p) 0],1:N);
    otherwise,     error('Unknown interpolation method: %s\n',interp_method);
end

function n = findpeaks(x)

n    = find(diff(diff(x) > 0) < 0);
u    = find(x(n+1) > x(n));
n(u) = n(u)+1;
