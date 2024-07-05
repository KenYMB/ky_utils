function    varargout = SetupKyUtils

% SETUPKYUTILS search directories related to myfunction, and add them into path
% Usage: 
%   oldpath = SetupKyUtils;

% 20170622 Yuasa
% 20170731 Yuasa: not to add calibration related directory
% 20180517 Yuasa: 'Setup_ft_utilities' is a copy of this function (partly modified)
% 20190621 Yuasa: comment out 'savepath'
% 20190819 Yuasa: change name from 'SetupMyFunction' to 'SetupKyUtils'
%                 exclude directories start with . (ex .git)
% 20191223 Yuasa: minor fix for UNIX

nargoutchk(0,1);

rootdir = fileparts(which(mfilename));
pathlist = genpath(rootdir);

%-- add ft_utilities
adddir = {'ft_utilities', 'fieldtrip_utilities'};
locpos = {'..'};
  addexist = false;
  for idir = 1:length(adddir)   % check in path
    addexist = or(addexist,~isempty(strfind(pathlist,[filesep adddir{idir} pathsep])));
  end
  if ~addexist
      for idir = 1:length(adddir)   % check in locpos
        addexist = false(1,length(locpos));
        for iloc = 1:length(locpos)
            addexist(idir) = exist(fullfile(rootdir,locpos{iloc},adddir{idir}),'dir');
        end
        isadd = find(addexist,1);
        if ~isempty(isadd)
            pathlist = [pathlist genpath(absolute_path(fullfile(rootdir,locpos{iloc},adddir{idir})))];
            break;
        end
      end
  end
    
pathlist = strsplit(pathlist,pathsep)';

filesepexp =  regexptranslate('escape',filesep);

%-- remove hidden dir
idir = ~cellfun(@isempty,regexp(pathlist,[filesepexp '\.'],'once'));
pathlist(idir) = [];

%-- remove calibration related dir
idir = ~cellfun(@isempty,regexp(pathlist,[filesepexp 'CalibratedData'],'once')) |...
       ~cellfun(@isempty,regexp(pathlist,[filesepexp 'mytransformation'],'once'));
pathlist(idir) = [];

%-- remove private dir
idir = ~cellfun(@isempty,regexp(pathlist,[filesepexp 'ft_private'],'once'));
pathlist(idir) = [];

%-- set low priority for ft_fix
idir = ~cellfun(@isempty,regexp(pathlist,[filesepexp 'ft_fix'],'once'));
lowPpath = pathlist(idir);
pathlist(idir) = [];

%-- output
pathlist  = strjoin(pathlist,pathsep);
lowPpath  = strjoin(lowPpath,pathsep);
oldpath   = addpath(pathlist);
addpath(lowPpath,'-END');
% savepath;

if nargout>0
    varargout{1} = oldpath;
end

end

function APATH = absolute_path(RPATH) 

if ~ischar(RPATH), error('Input value is not path.'); end 

[dirname, filename, ext] = fileparts(RPATH);
[num,pathinfo] = fileattrib(dirname);
APATH = fullfile(pathinfo.Name, strcat([filename, ext]));

end