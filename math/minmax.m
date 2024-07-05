function    mm = minmax(x,dim,varargin)
% MINMAX(x) returns the range (min and max) of input matrix x along its rows.
% MINMAX(x, dim) returns the range along the specified dimension.
% 
% See also MIN, MAX

% 20240705 Yuasa


% Set default value
if nargin < 2
    dim = 2;
elseif (ischar(dim)||isstring(dim)) && ~ismember(dim,"all")
    varargin = [{dim}, varargin];
    dim = 2;
end

% Dimension to output min and max
if isnumeric(dim)
    catdim = min(dim);
else
    catdim = 2;
end

% Take min and max
mn = min(x,[],dim,varargin);
mx = max(x,[],dim,varargin); 

% Return
mm = cat(catdim,mn,mx);
