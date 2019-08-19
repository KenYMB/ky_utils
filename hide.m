function stat = hide(varargin)

% Hide specified figure
% 
% Usage: 
%   HIDE 
%   HIDE(h)
%   HIDE all
%   HIDE all hidden
%   HIDE(h,'off')
%   HIDE off all
% 
% See also: CLOSE

% Using: cellfind

% 20180510: Yuasa

nargoutchk(0,1)
if nargout>0, stat = false; end

optidx = cellfind(varargin, {'on','off','all','hidden','gcf'});

isrev = ~isempty(cellfind(varargin, 'off'));
isall = ~isempty(cellfind(varargin, 'all'));
ishid = ~isempty(cellfind(varargin, 'hidden'));
isgcf = ~isempty(cellfind(varargin, 'gcf')) | nargin==length(optidx);

if isall
    %-- get all handles
    gr = groot;
    hidstat = gr.ShowHiddenHandles;
    %-- check hidden handles
    if ishid,   gr.ShowHiddenHandles = 'on';    end
    handles = gr.Children;
    handles = mat2cell(handles,ones(length(handles),1));
    gr.ShowHiddenHandles = hidstat;
else
    %-- check handles
    handles = varargin;
    handles(optidx) = [];
    ishandlelist = false(length(handles));
    for ih = 1:length(handles)
        %-- str -> handle number
        if ischar(handles{ih}),   handles{ih} = str2double(handles{ih}); end
        if ishandle(handles{ih}), ishandlelist(ih) = true;  end
    end
    %-- get gcf
    if isgcf
        handles{end+1}      = gcf;
        ishandlelist(end+1) = true;
    end
    %-- remove bad handles
    handles(~ishandlelist) = [];
    assert(numel(handles)>0, 'Specified window does not exist.');
end

%-- hide figures
if isrev,       visprop = 'on';         % show figure
else            visprop = 'off';        % hide figure
end
for ih = 1:length(handles)
    set(handles{ih},'Visible',visprop);
end

if nargout>0, stat = true; end


