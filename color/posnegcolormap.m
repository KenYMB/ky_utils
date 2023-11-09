function    varargout = posnegcolormap(varargin)
% POSNEGCOLORMAP set different colormap for positive and negative values.
% 
% posnegcolormap(map1,map2)
% cmap = posnegcolormap(map1,map2)
%   sets map1 for positive value and map2 for negative value.
%   map1 and map2 are scaled to the current positive and negative colormap
%   limits.
% 
% posnegcolormap(map1,'-reverse',map2)
% posnegcolormap(map1,map2,'-reverse')
% posnegcolormap(map1,'-reverse',map2,'-reverse')
%   sets reversed colormap respectively.
% 
% posnegcolormap(map1,map2,'-samescale')
%   sets map1 and map2 which are sacled to the wider limits of positive and
%   negative values.
% 
% posnegcolormap(axis,map1,map2)
%   sets the colormap for the axis.
% Note: different from COLORMAP, POSNEGCOLORMAP cannot target on figure
% 
% See also COLORMAP, CLIM

% Dependency: clim

% 20200311 Yuasa

%-- Define function for compatibility
if verLessThan('matlab','9.1')     % matlab2016a or earlier
    ischars = @ischar;
else
    ischars = @(x) (ischar(x) || isstring(x));
end

%%% Check options
%-- Find options
optionidx = cellfun(ischars,varargin);
varargin(optionidx) = cellfun(@char,varargin(optionidx),'UniformOutput',false);
optionidx = cellfun(@(x) ischars(x)&&strcmp(x(1),'-'),varargin);
%-- Get options
options   = varargin(optionidx);
%-- Check '-samescale'
samescale = any(ismember(options,'-samescale'));
%-- Check '-reverse'
revflag   = false(1,nargin);
revflag(optionidx)   = ismember(options,'-reverse');
revflag   = circshift(revflag,-1);
if revflag(end) || any(revflag & optionidx)
    error('Invalid usage of ''-reverse'' option');
end
%-- Check unknown options
invalididx = ~ismember(options,{'-samescale','-reverse'});
if any(invalididx)
    warning('Ignore unknown options:%s',sprintf(' ''%s''',options{invalididx}));
end

%%% Check arguments
args      = varargin(~optionidx);
revflag(optionidx) = [];
%-- Get graphics handle
if ischars(args{1})||(length(args{1}) > 1)||isempty(args{1})
    narginchk(2,5);
    figH = gca;
    argshift = 0;
else
    narginchk(3,6);
    assert(~revflag(1), 'Invalid usage of ''-reverse'' option');
    figH = args{1};
    argshift = 1;
end
%-- Collect maps ang reverse flag
if ischars(args{1+argshift})
    map1 = loadColormap(lower(args{1+argshift}),figH);
else
    map1 = args{1+argshift};
end
chkColormap(map1);
if ischars(args{2+argshift})
    map2 = loadColormap(lower(args{2+argshift}),figH);
else
    map2 = args{2+argshift};
end
chkColormap(map2);
%-- Reverse colormaps
if revflag(1+argshift)
    map1 = flipud(map1);
end
if revflag(2+argshift)
    map2 = flipud(map2);
end

%%% Marge positive and negative colormaps
%-- Get map heights
mapheight1  = size(map1,1);
mapheight2  = size(map2,1);
%-- Get current color limits and set apparent limits to set full colormap
clrlimit    = clim(figH);
if samescale
    aprlimit1  = max(abs(clrlimit(:)));
    aprlimit2  = -aprlimit1;
else
    aprlimit1  = max([clrlimit,0]);
    aprlimit2  = min([clrlimit,0]);
end
%-- Copute bin length of each colormap
clrbinsiz1     = aprlimit1./mapheight1;
clrbinsiz2     = -aprlimit2./mapheight2;
clrbinsiz      = max(clrbinsiz1,clrbinsiz2);
%-- Downsample colormap with higher resolution
if clrbinsiz1 < clrbinsiz
    if clrbinsiz1>0
        newmapheight = round(abs(mapheight2 ./ aprlimit2 .* aprlimit1));
        map1 = resampleColormap(map1,newmapheight);
    else
        map1 = [];
    end
elseif clrbinsiz2 < clrbinsiz
    if clrbinsiz2>0
        newmapheight = round(abs(mapheight1 ./ aprlimit1 .* aprlimit2));
        map2 = resampleColormap(map2,newmapheight);
    else
        map2 = [];
    end
end
%-- Marge colormaps
if size(map2,1)>1
    map = cat(1,map2(1:end-1,:),map1);
else
    map = cat(1,map2,map1);
end
%-- Crop colormaps
ctick = linspace(aprlimit2,aprlimit1,size(map,1));
map(ctick<clrlimit(1) | ctick>clrlimit(2),:) = [];

%%% Set colormap
set(figH, 'Colormap', map);
if nargout>0
    varargout{1} = map;
end
end

%%% Sub functions
% function mapContainer = getMapContainer(obj)
% % getMapContainer(OBJECT), returns OBJECT
% % If OBJECT has the AlphaMap/ColorMap property
% % If OBJECT doesn't have AlphaMap/ColorMap as it's property but has a ColorSpace, then the ColorSpace is returned
% % If OBJECT doesn't have either of the above,  EMPTY is returned.
% 
% % Does OBJ have a property called ColorMap or AlphaMap?
% if isscalar(obj) && ( isprop(obj,'Colormap') || isprop(obj,'Alphamap') )
%     mapContainer = obj;
%     return;
% end
% 
% % Does OBJ have a valid ColorSpace?
% % ColorSpaces have the AlphaMap/ColorMap property,
% if isscalar(obj) && isprop(obj, 'ColorSpace') && isa(get(obj,'ColorSpace'), 'matlab.graphics.axis.colorspace.ColorSpace')
%     mapContainer = get(obj,'ColorSpace');
%     return;
% end
% 
% % object does not contain a map return empty;
% mapContainer = [];
% end

function map = loadColormap(mapname,figH)
mapname = char(mapname);
if strcmp(mapname,'default')
    if ~exist('figH','var'), figH = gcf; end
    fig = ancestor(figH,'figure');
    map = get(fig,'defaultfigureColormap');
else
    k = min(strfind(mapname,'('));
    if ~isempty(k)
        map = feval(mapname(1:k-1),str2double(mapname(k+1:end-1)));
    elseif ~exist('figH','var')
        mapheight = size(get(figH,'Colormap'),1);
        map = feval(mapname,mapheight);
    else
        map = feval(mapname);
    end
end
end

function chkColormap(map)
if isempty(map) || (size(map,2) ~= 3)
    error(message('MATLAB:colormap:InvalidNumberColumns'));
end
if min(min(map)) < 0 || max(max(map)) > 1
    error(message('MATLAB:colormap:InvalidInputRange'))
end
end

function map = resampleColormap(map,newheight)
    mapheigt = size(map,1);
    map = interp1(linspace(0,1,mapheigt),map,linspace(0,1,newheight),'linear');
    map = map - min([map(:);0]);  % normalize [0,1]
    map = map./max([map(:);1]);   % normalize [0,1]
end