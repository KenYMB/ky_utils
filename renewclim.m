function    renewclim(newclim, savefmt, tardir, varargin)

% FIGCLIMCHANGE([cmin cmax], {save_formats}, target_dir [, figure_properties])
% changes clim of fig files
% 
% Usage: 
%   renewclim([0 1], {'fig','png'});
%   renewclim([0 1], {'fig','png'}, pwd, 'Position', [0 0 600 400]);

% Dependency: clim, rmempty

% 20171204: Yuasa

narginchk(1,inf);
if ~isnumeric(newclim) || ~ismatrix(newclim) || numel(newclim)~=2 || newclim(1)>=newclim(2)
    error('CLim is invalid.');
end
if nargin<2
    savefmt = {'fig'};
end
if nargin<3
    tardir = pwd;
end
savefmt = cellstr(savefmt);

tarfiles = ls(fullfile(tardir,'*fig'));
if ispc
    tarfiles   = cellstr([repmat([tardir filesep],size(tarfiles,1),1) tarfiles]);
else
    tarfiles   = rmempty(reshape(strsplit(tarfiles),[],1));
end

for ilp=1:length(tarfiles)
    hF = openfig(tarfiles{ilp});
    clim(newclim);
    set(gcf, varargin{:});
    
    [savedir, savename, ext] = fileparts(tarfiles{ilp});
    for isv=1:length(savefmt)
      switch savefmt{isv}
          case 'fig'
              saveas(hF,fullfile(savedir,savename),'fig');
          otherwise
              hgexport(hF,fullfile(savedir,savename),hgexport('factorystyle'),'Format',savefmt{isv});
      end
    end
    
    close(hF);
end