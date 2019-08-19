function        varargout = num2handle(varargin)
% handles                = NUM2HANDLE(handle_numbers)
% [handle1,handle2,...]  = NUM2HANDLE(handle_number1,handle_number2,...)
%   convert handle numbers into graphics object handles.
%   inout handle numbers are numbers or a vector.
%   output handles are cell-array of graphics object handles, 
%   if numbers of output variables are less than inputs.
% 
% See also HANDLE2NUM.

% 20170313 Yuasa

%-- input & output check
narginchk(1,inf);
h_num = cell2mat(varargin);
if nargout > 1
    nargoutchk(numel(h_num),numel(h_num));
end

%-- get handle number
h   = cell(1,numel(h_num));
for ifig = 1:numel(h_num)
    try
        h{ifig}  =  findobj(h_num(ifig),'-depth',0);
    catch
        h{ifig}  = nan;
    end 
end

%-- output
if nargout > 1 || numel(h_num) == 1
    varargout    = h;
else
    varargout{1} = h;
end
end