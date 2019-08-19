function [CC] = cellstrsplit(C,varargin)
% CC     = cellstrfind(cellstrArray)
% CC     = cellstrfind(cellstrArray,deliminater)
%
% Split cell-array of strings at specified delimiter.
%
% See also: strsplit, cellstr

% 190308: Yuasa

narginchk(1,inf);
nargoutchk(0,1);
if isempty(C), CC = []; return; end

if ~iscellstr(C)
    help cellstrfind
    error('First argument must be a cellstr.')
else
    C = reshape(C,[],1);
end

%-- apply strsplit for each cell
CP = cell(length(C),1);
maxrow = 1;

for I = 1:length(C)
    CP{I} = strsplit(C{I},varargin{:});
    maxrow = max(length(CP{I}),maxrow);
end

%-- combine results
CC = cell(length(C),maxrow);

for I = 1:length(C)
    CC(I,1:length(CP{I})) = CP{I};
end

return
