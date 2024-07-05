function hms = dnum2hms(varargin)

% DNUM2HMS   converts serial date number to time.
% This function is simple version of DATESTR, and outputs only time.
% Serial date number is the output of DATENUM.
% 
% hms = dnum2hms(dnum,[decround],[deccut])
% 
% hms   : 'hour:minute:second'
% dnum  : 'serial date number' or 'hour:minute:second' 
% 
% decround : round 'second' to demical at this order (defalt = '')
% deccut  : the order of demical to output 'second' (default = 6)
% 
% Example:
%   dnum2hms(7.3597e+05,2,4) outputs '12:00:25.6300'.
% 
% See alsoo: DATENUM, DATESTR, DATEVEC

% 2015/06/28 Yuasa

narginchk(1,3);

dnum = varargin{1};
if nargin == 3
    deccut = varargin{3};
    decround = varargin{2};
elseif nargin == 2
    deccut = 6;
    decround = varargin{2};
else
    deccut = 6;
    decround = '';    
end


dvec = datevec(dnum);
if ~isempty(decround)
    dvec(6) = round(dvec(6) * 10^decround) / 10^decround;
end

hms = sprintf('%02.0f:%02.0f:%0*.*f',  dvec(4:5), deccut+3, deccut, dvec(6));

end