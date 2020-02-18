function varargout = figsize(fig,varargin)

% FIGSIZE modifies the figure window size
% 
% Usage: 
%   state = FIGSIZE(fig, operator [,noreverse])
% 
%   fig         = figure handle
%   operator    = 'max'/'min'/'norm'/'state'
%       'max'   : maximazes the figure window   (direction = 1)
%                 or restores the figure        (direction = 0)
%       'min'   : minimized the figure window   (direction = 1)
%                 or restores the figure        (direction = 0)
%       'norm'  : set the figure size to normal
%                 and returns the previous state
%       'state' : returns the current state     { Maximized | Minimized | Normal }
% noreverse     = logial, if true, direction is fixed to "1"  (default = true)
%       if no direction is indicated, the figure state will be reversed
% 

% Dependency: maxfig, minfig, figstate

% 20170131 Yuasa: unify maxfig, minfig, figstate
% 20170405 Yuasa: change 'direction' to 'noreverse'

narginchk(1,3);

%-- set parameters
if nargin == 1 || strcmpi(varargin{1},'state')
    operator    = 'state';
elseif strcmpi(varargin{1},'max') || strcmpi(varargin{1},'maximized')
    operator    = 'max';
elseif strcmpi(varargin{1},'min') || strcmpi(varargin{1},'minimized')
    operator    = 'min';
elseif strcmpi(varargin{1},'norm') || strcmpi(varargin{1},'normal')
    operator    = 'norm';
else
    operator    = varargin{1};
end
state   = figstate(fig);
if nargin == 3
    noreverse   = varargin{2};
else
    noreverse   = true;
end

if noreverse || (strcmp(operator,'max') && ~strcmp(state,'Maximized')) ...
        || (strcmp(operator,'min') && ~strcmp(state,'Minimized'))
    direction   = 1;
else
    direction   = 0;
end

%-- set return value
if nargout ~= 0
    varargout{1} = state;
end

%-- main
switch operator
    case 'max'
        maxfig(fig,direction);
    case 'min'
        minfig(fig,direction);
    case 'norm'
        while(~strcmp(state,'Normal'))
            switch state
                case 'Maximized',     maxfig(fig,0);
                case 'Minimized',     minfig(fig,0);
            end
            state   = figstate(fig);
        end
    case 'state'
        varargout{1} = state;
    otherwise
        error('Invalid operator');
end

            
            