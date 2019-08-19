function        varargout = handle2num(varargin)
% handle_numbers    = HANDLE2NUM(handles)
% handle_numbers    = HANDLE2NUM(handle1,handle2,...)
%   convert graphics object handles into handle numbers.
%   input handles are graphics object handles or cell-array of graphics
%   object handles.
% 
% See also NUM2HANDLE.

% 20170313 Yuasa

%-- input & output check
narginchk(1,inf);
if nargout > 1 && nargout ~= nargin
    error(message('MATLAB:nargoutchk:tooManyOutputs'));
end
h = varargin;
if nargin == 1 && iscell(h{1})
    h = h{1};
end

%-- get handle number
h_num   = cell(1,numel(h));
for ifig = 1:numel(h)
    if isgraphics(h{ifig})
        h_num{ifig}  = handle2struct(h{ifig});
        h_num{ifig}  = h_num{ifig}.handle;
    else
        h_num{ifig}  = nan;
    end 
end

%-- output
if nargout > 1
    varargout    = h_num;
else
    varargout{1} = cell2mat(h_num);
end
end