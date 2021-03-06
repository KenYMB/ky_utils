function c = num2cellstr(a,dims)
%NUM2CELLSTR Convert numeric array into cell array of strings.
%   C = NUM2CELLSTR(A) converts numeric array A into cell array C by placing
%   each element of A into a separate cell in C. The output array has the
%   same size and dimensions as the input array. Each cell in C contains
%   the same numeric value as its respective element in A.
%
%   C = NUM2CELLSTR(A, DIM) converts numeric array A into a cell array of
%   numeric vectors, the dimensions of which depend on the value of the DIM
%   argument. Return value C contains NUMEL(A)/SIZE(A,DIM) vectors, each of
%   length SIZE(A, DIM). The DIM input must be an integer with a value from
%   NDIMS(A) to 1.
%
%   C = NUM2CELLSTR(A, [DIM1, DIM2, ...]) converts numeric array A into a cell
%   array of numeric arrays, the dimensions of which depend on the values
%   of arguments [DIM1, DIM2, ...]. Given the variables X and Y, where
%   X=SIZE(A,DIM1) and Y=SIZE(A,DIM2), return value C contains
%   NUMEL(A)/PROD(X,Y,...) arrays, each of size X-by-Y-by-.... All DIMn
%   inputs must be an integer with a value from NDIMS(A) to 1.
%
%   NUM2CELLSTR works for all array types.
%
%   Use CELL2MAT or CAT(DIM,C{:}) to convert back.
%
%   See also NUM2CELL, NUM2STR, MAT2CELL, CELL2MAT

%   20170330: Yuasa

narginchk(1,2);
if nargin==1
    c = cell(size(a));
    for i=1:numel(a)
        c{i} = num2str(a(i));
    end 
    return
end

% Size of input array
siz = [size(a),ones(1,max(dims)-ndims(a))];

% Create remaining dimensions vector
rdims = 1:max(ndims(a),max(dims));
rdims(dims) = []; % Remaining dims

% Size of extracted subarray
bsize(sort(dims)) = siz(dims);
bsize(rdims) = 1; % Set remaining dimensions to 1

% Size of output cell
csize = siz;
csize(dims) = 1; % Set selected dimensions to 1
c = cell(csize);

% Permute A so that requested dims are the first few dimensions
a = permute(a,[dims rdims]); 

% Make offset and index into a
offset = prod(bsize);
ndx = 1:prod(bsize);
for i=0:prod(csize)-1,
  c{i+1} = num2str(reshape(a(ndx+i*offset),bsize));
end
