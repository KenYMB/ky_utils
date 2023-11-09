function [retval, varargout] = isorth(Mat, varargin)
% ISORTH determins whether input is orthogonal system
% 
% Usage: 
%   ISORTH(A)
%   ISORTH(A,dim)
%   [TF, max_error] = ISORTH(A,dim,check_orthonormal,error_threshold)
% 
%   If dim is specified, ISORTH determin orthogonality along dimension dim.
%   If dim is 0 or not be specified, orthogonality is checked along all
%   dimension.
%   If check_orthonormal is TRUE, ISORTH determin wheter input A is
%   orthonormal system (default is FALSE). 
%   If dim is 0 and check_orthonormal is TRUE, then ISORTH determine
%   whether input is orthogonal matrix.
%   Default value of the error_threshold for the determination is '1e-5'.

% 20180522 Yuasa

narginchk(1,inf);
assert(ndims(Mat)<=2, 'orthogonal system is not defined for N-order matrix');

dim = 0;
if nargin > 1 && ~isempty(varargin{1}),
    dim = varargin{1};
end

checknorm = false;
if nargin > 2 && ~isempty(varargin{2}),
    checknorm = varargin{2};
end

thresh = 1e-5;
if nargin > 3  && ~isempty(varargin{3}),
    thresh = varargin{3};
end

%-- check orthogonal
normval  = norm(Mat);
switch dim
    case 1, orth_err = norm(Mat*Mat' - eye(size(Mat,1))*normval.^2);
    case 2, orth_err = norm(Mat'*Mat - eye(size(Mat,2))*normval.^2);
    otherwise,
        orth_err = max(norm(Mat*Mat' - eye(size(Mat,1))*normval.^2), norm(Mat'*Mat - eye(size(Mat,2))*normval.^2));
end
retval = orth_err < thresh;

%-- check normal
if retval && checknorm
    retval  = abs(normval-1) < thresh;
end
varargout{1} = orth_err;