function MM = surrounds(X,varargin)

% Y = SORROUNDS(X) returns minimum and maximum values with rounding.
%   The minimum value is rounded towards minus infinity and 
%   the maximum value towards infinity, 
%   as values of X are included in the range of Y.
%   If X is matrix, surrounds(X) opperates in each row (DIM=2).
% 
% Y = SORROUNDS(X,DIM) operates along the dimension DIM.
% 
% Y = SORROUNDS(X,DIM,N) rounds to N digits to the right of the decimal point. 
%   If N is zero, X is rounded to the integer (default).
% 
% Y = SORROUNDS(X,DIM,N,DIR) rounds X to the diferrent directions.
%   If DIR is 1, the minimum value is rounded towards minus infinity 
%   and the maximum value towards plus infinity (default).
%   If DIR is -1, the minimum value is rounded towards plus infinity 
%   and the maximum value towards minus infinity.
%   If DIR is 0, the minimum and maximum values are rounded to the
%   nearest values regardless of direction.
% 
% Y = SORROUNDS(...,NANFLAG) specifies how NaN (Not-A-Number) values are 
%     treated.  NANFLAG can be:
%     'omitnan'    - (default) Ignores all NaN values and returns..
%     'includenan' - Returns NaN if there is any NaN value.
%
%  See also MINMAX, ROUND, FLOOR, CEIL.

% 20230424 Yuasa

%-- Interpret inputs
narginchk(1,inf);
%%% set default options
DIM     = [];
N       = 0;
DIR     = 1;
nanflag = 'omitnan';
%%% read options
if nargin>1
    if ischar(varargin{end}) && ismember(varargin{end},{'omitnan','includenan'})
        nanflag = varargin{end};
        varargin(end) = [];
    end
    if length(varargin)>2
        [DIM,N,DIR] = deal(varargin{1:3});
    elseif length(varargin)>1
        [DIM,N] = deal(varargin{1:2});
    else
        DIM     = varargin{1};
    end
end

%-- Get minimum and maximum values (& prepare for output)
catdim = 2;
if isempty(DIM)
    if iscolumn(X),   DIM = 1;
    else,             DIM = 2;
    end
elseif isnumeric(DIM) && ~ismember(2,DIM)
    catdim = DIM(1);
end
minval = min(X,[],DIM,nanflag);
maxval = max(X,[],DIM,nanflag);

%-- Round values
dimcoef = 10.^N;
if DIR > 0
    minval = floor(minval.*dimcoef)./dimcoef;
    maxval = ceil(maxval.*dimcoef)./dimcoef;
elseif DIR < 0
    minval = ceil(minval.*dimcoef)./dimcoef;
    maxval = floor(maxval.*dimcoef)./dimcoef;
else
    minval = round(minval.*dimcoef)./dimcoef;
    maxval = round(maxval.*dimcoef)./dimcoef;
end

%-- Return result
MM = cat(catdim,minval,maxval);

