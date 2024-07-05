function varargout =  resetfig(varargin)

% RESETFIG(h1,h2,...[,'size'])
% 
%   Reset all properties of figures/axes,
%     including Position, Units, WindowStyle, PaperUnits for figure handles,
%     and Position, Units for axis handles.
%   And focus on the 1st indicated figure & axis.
% 
%   If you use RESET, the above parameters are not reset.
%   If 'size' is indicated, only figure size is reset in the above parameters.
%   If 'keep' is indicated, figure size and position are not reset.
% 
% Example:
%   h1 = resetfig(gcf);
% 
%   see also, reset, clf, cla

% 20170216 Yuasa
% 20160220 Yuasa: check invalid handles
% 20170223 Yuasa: add resetting setappdata, guidata
% 20170307 Yuasa: minor fix
% 20170405 Yuasa: add 'keep'
% 20170414 Yuasa: output new handle
% 20170517 Yuasa: enable matrix and cell input
% 20190509 Yuasa: minor fix

%-- get handles
option       = [];
invalidh     = [];
addhandleidx = [];
handles = varargin;
isfig   = zeros(1,length(handles));
if nargin ~= 0
    for ih = 1:nargin
        if ischar(handles{ih})
            %-- for option
            option      = handles{ih};
            invalidh    = [invalidh ih];
        else
            %-- for matrix or cell input
            if iscell(handles{ih}),  handles{ih} = [handles{ih}{:}];   end
            if numel(handles{ih})>1,
                handles      = [handles, mat2cell(reshape(handles{ih}(2:end),1,[]),1,ones(1,numel(handles{ih})-1))];
                addhandleidx = [addhandleidx, ih.*ones(1,numel(handles{ih})-1)];
                handles{ih}  = handles{ih}(1);
            end
            %-- check handles
            if ~ishandle(handles{ih})
                %-- for invalid handle
                warning('%s handle does not exist',iptnum2ordinal(ih));
                invalidh    = [invalidh ih];
            elseif strcmp(get(handles{ih},'Type'),'figure')
                %-- for figure handle
                isfig(ih)   = 1;
            end
        end
    end
    isfig   = [isfig, zeros(1,length(addhandleidx))];
end
for ih = (nargin+1):length(handles)
    %-- check handles
    if ~ishandle(handles{ih})
        %-- for invalid handle
        warning('handle in %s input does not exist',iptnum2ordinal(addhandleidx(ih)));
        invalidh    = [invalidh ih];
    elseif strcmp(get(handles{ih},'Type'),'figure')
        %-- for figure handle
        isfig(ih)   = 1;
    end
end
%-- delete invalid handle & option
handles(invalidh)  = [];
isfig(invalidh)    = [];
    
%-- set defaults
if nargin == 0 || isempty(handles)
    handles{1} = gcf;
    isfig      = 1;
end
if isempty(option),     option = 'all';     end


%-- specify focus figure
%-- for axis, parent figure of 1st axis is focused
CurFig  = handles{1};
RootAx  = {CurFig};
while(~strcmp(get(CurFig,'Type'),'figure'))
    CurFig = get(CurFig,'Parent');
    RootAx = [RootAx, {CurFig}];
end

%-- get default
hF = figure('Visible','off');
hA = gca;

figDef              = [];
figDef.Position     = get(hF,'Position');
figDef.Units        = get(hF,'Units');
figDef.WindowStyle  = get(hF,'WindowStyle');
figDef.PaperUnits   = get(hF,'PaperUnits');

axDef              = [];
axDef.Position     = get(hA,'Position');
axDef.Units        = get(hA,'Units');

delete(hF);

%-- reset
for ih = 1:length(handles)
  switch option
    case 'all'
       if isfig(ih)
          resetcommon(handles{ih});
          clf(handles{ih});
          try set(handles{ih},figDef); end
       else
          try % maybe already reset
            resetcommon(handles{ih});
            cla(handles{ih});
            set(handles{ih},axDef);
          end
       end
    case 'size'
       if isfig(ih)
          resetcommon(handles{ih});
          clf(handles{ih});
          try
            curPos = get(handles{ih},'Position');
            set(handles{ih},'Position', [curPos(1:2) figDef.Position(3:4)]); 
          end
       else
          try % maybe already reset
            resetcommon(handles{ih});
            cla(handles{ih});
            curPos = get(handles{ih},'Position');
            set(handles{ih},'Position', [curPos(1:2) axDef.Position(3:4)]); 
          end
       end
    case 'keep'
       if isfig(ih)
          resetcommon(handles{ih});
          clf(handles{ih});
       else
          try % maybe already reset
            resetcommon(handles{ih});
            cla(handles{ih});
          end
       end
  end
end

%-- output handles
if nargout ~= 0
  varargout = handles;
end

%-- set focus
try
  set(0,'CurrentFigure',CurFig);
  for iax = length(RootAx):-1:2
      set(RootAx{iax},'CurrentAxes',RootAx{iax-1});
  end
end
end


function resetcommon(h)
% common reset process for figure and axis
reset(h);
guidata(h,[]);
appdatanames = fieldnames(getappdata(h));
for ilp=1:length(appdatanames)
    rmappdata(h,appdatanames{ilp});
end
pause(0);
end