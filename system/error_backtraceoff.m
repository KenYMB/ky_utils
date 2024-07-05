function    error_backtraceoff(varargin)
% ERROR_BACKTRACEOFF throw an error without backtrack information.
% 
% Usage:
%   ERROR_BACKTRACEOFF;
%   ERROR_BACKTRACEOFF(message [,func_name]);
%   ERROR_BACKTRACEOFF(msgID,message [,func_name]);
% 
% Inpupts:
%   msgID:      Indicator for error
%   message:    Error message
%   func_name:  Error function name
%               If this value is not input, CallBack function name is loaded
% 
% See also ERROR.

% 20170324 Yuasa

  errStrct = [];
  errStrct.stack.file   = '';
  errStrct.stack.name   = '';
  errStrct.stack.line   = 0;
  
  %-- set id & msg
  if nargin < 1,
      errid   = '';
      errmsg  = '';
  elseif ismsgid(varargin{1})
      errid   = varargin{1};
      if nargin < 2
          errmsg = '';
      else
          errmsg = varargin{2};
      end
  else
      errid   = '';
      errmsg  = varargin{1};
  end
  
  %-- set stack
  if nargin >= 3 && ismsgid(varargin{1})
      fname   = varargin{3};
  elseif nargin >= 2 && ~ismsgid(varargin{1})
      fname   = varargin{2};
  else
      fname   = dbstack;
      if length(fname)>=2
          errStrct.stack.file  = fname(2).file;
          fname = fname(2).name;
      else
          fname = '';
      end
  end
  
  %-- set all
  errStrct.stack.name  = fname;
  errStrct.identifier  = errid;
  errStrct.message     = errmsg;
  
  %-- disable "Error" display
%   if isempty(fname),
%       errStrct.stack(1) = [];
%       errStrct.stack    = reshape(errStrct.stack,[],1);
%   end
  
  error(errStrct);
end
    
function out = ismsgid(errmsg)
% judge if the errmsg is msgID or not
  out = ischar(errmsg) && ...
        ~isempty(regexp(errmsg,'^[a-zA-Z]\w*(:[a-zA-Z]\w*)+$', 'once'));
end