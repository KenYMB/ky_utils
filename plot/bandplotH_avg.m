function bandplotH_avg(varargin)
    
% BANDPLOTH_AVG plot average of Y1 with error band
% 
% Usage
%   BANDPLOTH_AVG(cfg,x1,Y1,x2,Y2)
% 
% Inputs:
%   cfg.xlim       = horizontal scaling, can be 'maxmin' or [ymin ymax] (default = 'maxmin')
%   cfg.ylim       = vertical scaling, can be 'maxmin' or [ymin ymax] (default = 'maxmin')
%   cfg.errortype  = 'sd' or 'se', compute type of error band (default = 'se')
%   cfg.title      = 1 x (inputs/cfg.block) cell array of character, title of each subplot
%   cfg.legend     = 1 x cfg.block cell array of character, legend of each data
%   cfg.block      = number, numbers of plot for each subplot (default = 1)
%   cfg.fontsize   = number, font size (default = 10)
%   cfg.linecolor  = charactor strings, colors of plots
% 
% Example: plot 3 datas each for 2 subplots
%   cfg.block =3;
%   bandplotH_avg(cfg, x11,Y11, x12,Y12, x13,Y13,..
%                      x21,Y21, x22,Y22, x23,Y23);

% SetDefault: nearlyeq

% 20170411 Yuasa

%-- input setting
if isstruct(varargin{1})
    cfg = varargin{1};
    xi = 2;
else
    cfg = [];
    xi = 1;
end
if xi == 1 && nargin == 1
    Dx{1} = [];
    DY{1} = varargin{1};
else
    iinp = 0;
    while(xi<=nargin)
        iinp = iinp + 1;
        Dx{iinp} = varargin{xi};
        DY{iinp} = varargin{xi+1};
        assert(ndims(DY{iinp})<=2, message('MATLAB:plot:DataDimensionError'));
        xi   = xi + 2;
    end
end
ninp = iinp;

if isempty(Dx{1})
    if min(size(DY{1}))==1, DY{1} = reshape(DY{1},1,[]);    end     % is vector
    Dx{1} = size(DY{1},2);
end

%-- parameter setting
if ~isfield(cfg,'xlim') || isempty(cfg.xlim)
    cfg.xlim = 'maxmin';
end
if ~isfield(cfg,'ylim') || isempty(cfg.ylim)
    cfg.ylim = 'maxmin';
end
if ~isfield(cfg,'errortype') || isempty(cfg.errortype)
    cfg.errortype = 'se';
end
if ~isfield(cfg,'block') || isempty(cfg.block)
    cfg.block = 1;
else
    cfg.block = round(cfg.block);
end
if ~isfield(cfg,'fontsize') || isempty(cfg.fontsize)
    cfg.fontsize = 10;
end
if ~isfield(cfg,'title') || isempty(cfg.title)
    cfg.title = cell(ninp,1);
end
if ~isfield(cfg,'legend') || isempty(cfg.legend)
    cfg.legend = cell(ninp,1);
elseif ~iscell(cfg.legend)
    cfg.legend = repmat({{cfg.legend}},round((ninp/cfg.block)),1);
elseif ~iscell(cfg.legend{1})
    cfg.legend = repmat({cfg.legend},round((ninp/cfg.block)),1);
end
if ~isfield(cfg,'linecolor') || isempty(cfg.linecolor)
    cfg.linecolor = 'brgkywrgbkywrgbkywrgbkyw';
end

%-- data processing
for iinp = 1:ninp
    Dx{iinp} = reshape(Dx{iinp},1,[]);
    if ischar(cfg.xlim) && strcmp(cfg.xlim,'maxmin')
        xidx{iinp} = 1:length(xidx{iinp});
    else
        xidx{iinp} = [nearlyeq(Dx{iinp},cfg.xlim(1)):nearlyeq(Dx{iinp},cfg.xlim(2))];
    end
    if size(DY{iinp},2) ~= length(Dx{iinp})
        DY{iinp} = DY{iinp}';
        assert(size(DY{iinp},2) == length(Dx{iinp}), message('MATLAB:samelen'));
    end
    numavg{iinp} = size(DY{iinp},1);
    AveY{iinp} = mean(DY{iinp}(:,xidx{iinp}),1);
    switch cfg.errortype
       case 'sd'
          varY{iinp} = sqrt(var(DY{iinp}(:,xidx{iinp}),0,1));
       case 'se'
          varY{iinp} = sqrt(var(DY{iinp}(:,xidx{iinp}),0,1)./numavg{iinp});
    end
end
if ischar(cfg.xlim) && strcmp(cfg.xlim,'maxmin')
    cfg.xlim = [nanmin([Dx{:}]) nanmax([Dx{:}])];
end
if ischar(cfg.ylim) && strcmp(cfg.ylim,'maxmin')
    cfg.ylim = [nanmin([AveY{:}]-[varY{:}]) nanmax([AveY{:}]+[varY{:}])];
end

assert(mod(ninp,cfg.block)==0, 'cfg.block is invalid');
for isbpl=1:(ninp/cfg.block)
    %%%%% plot %%%%%
    subplot(1,(ninp/cfg.block),isbpl)
        hold on
    
    for iblc = 1:cfg.block
        iinp = (isbpl - 1)*cfg.block + iblc;
        plot(gca,Dx{iinp}(xidx{iinp}),AveY{iinp},cfg.linecolor(iblc));
    end
    for iblc = 1:cfg.block
        iinp = (isbpl - 1)*cfg.block + iblc;
        fill([Dx{iinp}(xidx{iinp}) fliplr(Dx{iinp}(xidx{iinp}))],...
            [AveY{iinp} - varY{iinp}, fliplr(AveY{iinp} + varY{iinp})],...
            cfg.linecolor(iblc), 'FaceAlpha',0.2, 'EdgeColor','none');
    end
        
    for iblc = 1:cfg.block
        iinp = (isbpl - 1)*cfg.block + iblc;
        plot(gca,Dx{iinp}(xidx{iinp}),AveY{iinp},cfg.linecolor(iblc));
    end
    title([cfg.title{isbpl} ' Cortex']);  set(gca,'FontSize',cfg.fontsize);
    legend(cfg.legend{isbpl},'Location','northwest','Box','off')
    xlim(cfg.xlim); ylim(cfg.ylim);
    hold off
end
