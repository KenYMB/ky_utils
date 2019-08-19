function varargout = LoadDisplayInfo(displayName, datapath, autoset)

% Usage: 
%   displayInfo = LOADDISPLAYINFO(displayName)
%   [Inch, Type (, CalibDate, Path_of_CaliblatedData)] = LOADDISPLAYINFO(displayName, dataPath)
% 
% need 'displayInfo.csv' in dataPath directory
%  'displayInfo.csv': displayID, displayName, Inch, Type, CalibDate
% need 'gammaTable_*_displayName_CaliblatedData.mat' in dataPath/CalibratedData directory
%  'gammaTable_....mat': matlab data including caliblation data
% 
% if dataPath is not specified, it will search in the function path
% 
% Example: 
%   [monitor_size, monitor_type, calibdate, calbpath] = LoadDisplayInfo(displayName);
%   if ~strcmp(calbpath,'NaN')
%       load(calbpath);   % myApplied
%       addpath(fullfile(fileparts(calbpath),'..','mytransformation'));
%   end

% 20160629 Yuasa
% 20160705 Yuasa: for mac applied
% 20160713 Yuasa: replace 'xlsread' to avoid using excel software
% 20170622 Yuasa: add output variable 'CaliblatedData'
% 20170731 Yuasa: fix 'CaliblatedData'

% using: cellstrfind, SetDefault

nargoutchk(0,4);

SetDefault('displayName','');
SetDefault('datapath',fileparts(which(mfilename)));
SetDefault('autoset',false);

dispData = fullfile(datapath, 'displayInfo.csv');
assert(logical(exist(dispData,'file')),'''displayInfo.csv'' is not found');
% [~,~,RAWdisplayInfo]=xlsread(dispData);     % need Excel
if exist('readtable','file')
    RAWdisplayInfo = readtable(dispData);       % need MATLAB 2013b or later
    RAWdisplayInfo = [RAWdisplayInfo.Properties.VariableNames; table2cell(RAWdisplayInfo)];
else
    RAWdisplayInfo = readanycsv(dispData);      % Always (maybe) work
end

displayID = cellfind(RAWdisplayInfo(:,cellfind(RAWdisplayInfo(1,:),'displayName')),displayName) - 1;

if isempty(displayID)
    fprintf('\n%% Registered display names are\n');
    disp(char(RAWdisplayInfo(2:end,cellfind(RAWdisplayInfo(1,:),'displayName'))));
    error('No INFORMATION about the display');
end

displayInfo.Inch        = RAWdisplayInfo{displayID+1, cellfind(RAWdisplayInfo(1,:),'Inch')};
displayInfo.Type        = RAWdisplayInfo{displayID+1, cellfind(RAWdisplayInfo(1,:),'Type')};
displayInfo.CalibDate   = num2str(RAWdisplayInfo{displayID+1, cellfind(RAWdisplayInfo(1,:),'CalibDate')});
displayInfo.CaliblatedData  = 'NaN';

%-- load caliblated data
if ~strcmp(displayInfo.CalibDate,'NaN')
  if ispc
    displayInfo.CaliblatedData = cellstr(ls(fullfile(datapath,'CalibratedData',['gammaTable_*' displayName '_' displayInfo.CalibDate '.mat'])));
  else
    displayInfo.CaliblatedData = strsplit(ls(fullfile(datapath,'CalibratedData',['gammaTable_*' displayName '_' displayInfo.CalibDate '.mat'])));
  end
  %-- set priority
  if length(displayInfo.CaliblatedData) > 1
    isapplied = cellstrfind(displayInfo.CaliblatedData,'*myApplied*');
    if ~isempty(isapplied)
        displayInfo.CaliblatedData = displayInfo.CaliblatedData(isapplied(1));
    end
  end
  if ispc
      displayInfo.CaliblatedData = fullfile(datapath,'CalibratedData',displayInfo.CaliblatedData{1});
  else
      displayInfo.CaliblatedData = displayInfo.CaliblatedData{1};
  end
end

if nargout == 1 || (nargout==0 && ~autoset)
    varargout = {displayInfo};
else
    varargout = {displayInfo.Inch, displayInfo.Type, displayInfo.CalibDate, displayInfo.CaliblatedData};
end

if autoset
    if ~strcmp(displayInfo.CaliblatedData,'NaN') && exist(displayInfo.CaliblatedData,'file')
        evalin('caller',sprintf('load(''%s'')',displayInfo.CaliblatedData)); % load into root workspace
        addpath(fullfile(datapath,'mytransformation'));
        fprintf('Color caliblation data is loaded.\n');
    elseif strcmp(displayInfo.CalibDate,'NaN')
        warning('Color caliblation data is not registered.');
    else
        warning('Failed to load color caliblation data.');
    end
end
    

function outMat = readanycsv(filename)

% output = readanycsv(filename)
% 
% you can read csv file which include numbers and texts
% output is cell matrix

% 20160713 Yuasa

fid = fopen(filename,'r');
title = fgetl(fid);
title = textscan(title,'%s','delimiter', ',');
title = title{1};       NumList = length(title);
readMat = textscan(fid,repmat('%s',1,NumList),'delimiter', ',');
fclose(fid);
empcell = numel(readMat{1}) - numel(readMat{end});
if empcell
    readMat{end} = cat(1,readMat{end},cell(empcell,1));
end

outMat={};
for ireadM = 1:length(readMat)
    outMat(:,ireadM) = cat(1,title{ireadM},readMat{ireadM});
    for ifixM = 2:size(outMat,1)
        if isempty(outMat{ifixM,ireadM}),  outMat{ifixM,ireadM} = nan;
        elseif max(strcmp(title{ireadM},{'displayID','Inch','CalibDate'})),
            outMat{ifixM,ireadM} = str2double(outMat{ifixM,ireadM});
        end
    end
end