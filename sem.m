function y = sem(x,varargin)

%SEM Standard error.
%   Y = SEM(X) returns the standard error of the values in X. For matrices,
%   Y is a row vector containing the standard deviation of each column. For
%   N-D arrays, SEM operates along the first non-singleton dimension of X.
%
%   SEM normalizes Y by N-1 if N>1, where N is the sample size.  This is
%   the sqrt of an unbiased estimator of the variance of the population
%   from which X is drawn, as long as X consists of independent,
%   identically distributed samples. For N=1, Y is normalized by N.
%
%   Y = SEM(X,1) normalizes by N and produces the square root of the second
%   moment of the sample about its mean.  SEM(X,0) is the same as SEM(X).
%
%   Y = SEM(X,W) computes the standard error using the weight vector W.
%   W typically contains either counts or inverse variances.  The length of
%   W must equal the length of the dimension over which SEM operates, and
%   its elements must be nonnegative.  If X(I) is assumed to have standard
%   deviation proportional to 1/SQRT(W(I)), then Y * SQRT(MEAN(W)/W(I)) is
%   an estimate of the standard error of X(I).  In other words, Y *
%   SQRT(MEAN(W)) is an estimate of standard error for an observation
%   given weight 1.
%
%   Y = SEM(X,0,'all') or Y = SEM(X,1,'all') returns the standard error of
%   all elements of X. A weight of 0 normalizes by N-1 and a weight of 1
%   normalizes by N.
%
%   Y = SEM(X,W,DIM) takes the standard error along the dimension DIM of X.
%
%   Y = SEM(X,0,VECDIM) or Y = SEM(X,1,VECDIM) operates on the dimensions 
%   specified in the vector VECDIM. A weight of 0 normalizes by N-1 and a 
%   weight of 1 normalizes by N. For example, SEM(X,0,[1 2]) operates on
%   the elements contained in the first and second dimensions of X.
%
%   The standard error is the square root of the variance (VAR).
%
%   SEM(...,NANFLAG) specifies how NaN (Not-A-Number) values are treated.
%   The default is 'includenan':
%
%   'includenan' - the standard error of a vector containing NaN 
%                  values is also NaN.
%   'omitnan'    - elements of X or W containing NaN values are ignored.
%                  If all elements are NaN, the result is NaN.
% 
%   [Yn Yp] = SEM(X,...) returns the size of the both side of standard
%   error separately.
% 
%   See also STD, MEAN.

%   20231030 Yuasa

omitnan = ismember('omitnan',varargin(cellfun(@ischar,varargin)));

if nargin < 3
    % Figure out which dimension sum will work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
else
   dim = varargin{2};
end
if omitnan     
    d_num = mysize(x, dim) - matlab.internal.math.countnan(x, dim);
else
    d_num = mysize(x, dim);
end

% Call std(x,flag,dim) with as many of those args as are present.
y = std(x,varargin{:}) ./ sqrt(d_num);



function s = mysize(x, dim)
if isnumeric(dim) || islogical(dim)
    if isscalar(dim)
        s = size(x,dim);
    else
        s = size(x,dim(1));
        for i = 2:length(dim)
            s = s * size(x,dim(i));
        end
    end
else
    s = numel(x);
end

