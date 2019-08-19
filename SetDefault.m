function   varargout = SetDefault(varname, defval, keepempty)
% SETDEFAULT search a variable in the current workspace,
% and set default value if the variable is not exist or empty.
% 
% Usage: 
%   issetdefault = SETDEFAULT(variable_name, default_value (,keepempty))
% 
% when 'variable' already exists, 'issetdefault' outputs false.
% if 'keepempty' is true, this function only work when the variable is not
% exist.
% Subfield of a structure is also valid.

% 20170622 Yuasa

narginchk(2,3)

if nargin < 3,  keepempty = false;
else            keepempty = logical(keepempty);
end

issetdefault = false;

%-- keep empty
if keepempty
    varempty = false;
end

%-- check existence
assert(ischar(varname),'1st input value must be a variable name.');
chkstrct = strsplit(varname,'.');
varexist = evalin('caller',sprintf('exist(''%s'',''var'')',chkstrct{1}));   % check existence
%-- check existence of subfield
if varexist
    if length(chkstrct) == 1    % need not to consider fields
        fldexst = true;
    else
        fldexst  = evalin('caller',sprintf('isstruct(%s)',chkstrct{1}));    % check the structure
        if fldexst
            getstrct = evalin('caller',sprintf('%s',chkstrct{1}));          % copy the structure
            fldexst  = issubfield(getstrct,chkstrct{2:end});
            try
                eval(sprintf('%s = %s;',strjoin([{'getstrct'}, chkstrct(2:end)],'.'),'defval'));
                defval   = getstrct;
            catch %-- skip if a part of fields exists but is not structure array
                fldexst  = true;
                varempty = false;
                wst = warning('backtrace','off');
                warning('Field ''%s'' is not structure.',strjoin(chkstrct(1:end-1),'.'));
                warning(wst);
            end
        else
            wst = warning('backtrace','off');
            warning('Variable ''%s'' is not structure.',chkstrct{1});
            warning(wst);
        end
    end
elseif length(chkstrct) ~= 1
    getstrct = [];
    eval(sprintf('%s = %s;',strjoin([{'getstrct'}, chkstrct(2:end)],'.'),'defval'));
    defval   = getstrct;
end
%-- check empty
% if ~exist('varempty','var') && varexist && fldexst
%     varempty = evalin('caller',sprintf('isempty(%s)',varname));             % check empty
% end
if varexist && fldexst
    SetDefault('varempty', evalin('caller',sprintf('isempty(%s)',varname)));             % check empty
end
if ~varexist || ~fldexst || varempty
    assignin('caller',chkstrct{1},defval);
    issetdefault = true;
end
if nargout~=0
    varargout = {issetdefault};
end


function A = issubfield(strct, varargin)
% ISSUBFIELD try ISFIELD recursively

if isempty(strct)
  A = false;
else
  fieldname = varargin;
  A = true;
  for k = 1:numel(fieldname)
    if isfield(strct, fieldname{k})
      strct = strct.(fieldname{k});
    else
      A = false;
      return;
    end
  end
end
