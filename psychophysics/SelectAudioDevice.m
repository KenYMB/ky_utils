function DevID = SelectAudioDevice(varargin)

% DeviceID = SelectAudioDevice([monitorID])
% 
% this script support setting up auditory device 
% for PsychPortAudio in PsychToolBox 3.
% It works after 'InitializePsychSound'.

% 20160526 Yuasa @MATLAB2013b, 2016a
% 20160601 Enable selection by number keys

if nargin == 0
    monnum = 1;
else
    monnum = varargin{1};
end

Adevices = PsychPortAudio('GetDevices');

hf = dialog('WindowStyle', 'normal', 'Name', 'Audio Devices');

%-- analyze Device Name width
nDevices        = size(Adevices,2);
WholeDeviceName = cell(nDevices,1);
TextWrap = cell(nDevices,1);  TextWidth = zeros(nDevices,4);
TestStrings=uicontrol(hf,'Style','text','Visible','off');
% MultiLine = ones(idev,1);
for idev = 1:nDevices
    WholeDeviceName{idev} = [Adevices(idev).HostAudioAPIName ' :    ' Adevices(idev).DeviceName];   % \t = 9
    [TextWrap{idev},TextWidth(idev,:)]= textwrap(TestStrings,WholeDeviceName(idev),120);
%     MultiLine(idev) = length(TextWrap{idev});
end
TextWidthM = max(TextWidth(:,3));
% MaxLine   = sum(MultiLine);
delete(TestStrings)

%-- default value
SelID = find([Adevices.HostAudioAPIId]==5)-1;       % Select Mac Core Audio
if isempty(SelID),
SelID = find([Adevices.HostAudioAPIId]==8)-1;  end  % Select ALSA on Linux
if isempty(SelID),
SelID = find([Adevices.HostAudioAPIId]==3)-1;  end  % Select ASIO
if isempty(SelID),
SelID = (1:length(Adevices))-1;                end  % Select All
OutID = find([Adevices.NrOutputChannels]>0)-1;      % Select Output Device
SelID = intersect(SelID,OutID);
if isempty(SelID),
SelID = 0;   warning('no output device');
else
SelID = SelID(1);
end

%-- dialog size & position
dlgpos = [200+TextWidthM+10, 33+25*nDevices+30];

MInf = get(groot,'monitorPositions');
monnum = round(monnum);
if strcmp(monnum,'end') || monnum>size(MInf,1); monnum=size(MInf,1); end
if monnum<1; monnum = 1; end
dlgpos = [floor(MInf(monnum,3)/2-dlgpos(1)/2+MInf(monnum,1)), ...
    floor(MInf(monnum,4)/2-dlgpos(2)/2+MInf(monnum,2)), ...
    dlgpos];

%-- uicontrol
set(hf,'Position',dlgpos);
hrg = uibuttongroup(hf,'BorderType','none','Unit','pixel','Position',[0 0 30 dlgpos(4)],...
    'SelectionChangeFcn',@RBCallback,'UserData',SelID);
% hrg = uibuttongroup(hf,'BorderType','none','Unit','pixel','Position',[0 0 30 dlgpos(4)],...
%     'SelectionChangeFcn',@RBCallback,'UserData',SelID);                       % after 2015a

htl(1) = uicontrol(hf,'Style','text', 'String','ID', 'Position', [30 dlgpos(4)-35 30 25],'HorizontalAlignment','center');
htl(2) = uicontrol(hf,'Style','text', 'String','Host', 'Position', [60 dlgpos(4)-35 30 25],'HorizontalAlignment','center');
htl(3) = uicontrol(hf,'Style','text', 'String','Device Name', 'Position', [90 dlgpos(4)-35 TextWidthM+10 25],'HorizontalAlignment','center');
htl(4) = uicontrol(hf,'Style','text', 'String','Latency [ms]', 'Position', [90+TextWidthM+10 dlgpos(4)-35 110 25],'HorizontalAlignment','center');

hb1 = uicontrol(hf,'Style','pushbutton','String',getString(message('MATLAB:uistring:popupdialogs:OK')),'Position',[dlgpos(3)-135 3 60 22]);
hb2 = uicontrol(hf,'Style','pushbutton','String',getString(message('MATLAB:uistring:popupdialogs:Cancel')),'Position',[dlgpos(3)-70 3 60 22]);

for idev = 1:nDevices
    hsw(idev) = uicontrol(hrg,'Style','radiobutton','Value',0,...
        'Position',[10 dlgpos(4)-25*idev-30 20 25],'HorizontalAlignment','center',...
        'KeyPressFcn',{@OKKeyback,hrg,hb1,hb2},'UserData',Adevices(idev).DeviceIndex);
    hid(idev) = uicontrol(hf,'Style','text','String',num2str(Adevices(idev).DeviceIndex),...
        'Position',[30 dlgpos(4)-25*idev-38 30 25],'HorizontalAlignment','center',...
        'KeyPressFcn',{@OKKeyback,hrg,hb1,hb2},'ButtonDownFcn',{@SelClick,hrg,hsw(idev)},'Enable','inactive');
    hhs(idev) = uicontrol(hf,'Style','text','String',num2str(Adevices(idev).HostAudioAPIId),...
        'Position',[60 dlgpos(4)-25*idev-38 30 25],'HorizontalAlignment','center',...
        'KeyPressFcn',{@OKKeyback,hrg,hb1,hb2},'ButtonDownFcn',{@SelClick,hrg,hsw(idev)},'Enable','inactive');
    hdn(idev) = uicontrol(hf,'Style','text','String',WholeDeviceName{idev},...
        'Position',[95 dlgpos(4)-25*idev-38 TextWidthM+10 25],'HorizontalAlignment','left',...
        'KeyPressFcn',{@OKKeyback,hrg,hb1,hb2},'ButtonDownFcn',{@SelClick,hrg,hsw(idev)},'Enable','inactive');
    hlt(idev) = uicontrol(hf,'Style','text','String',sprintf(' %5.1f - %5.1f',Adevices(idev).LowOutputLatency*10^3, Adevices(idev).HighOutputLatency*10^3),...
        'Position',[90+TextWidthM+10 dlgpos(4)-25*idev-38 110 25],'HorizontalAlignment','center',...
        'KeyPressFcn',{@OKKeyback,hrg,hb1,hb2},'ButtonDownFcn',{@SelClick,hrg,hsw(idev)},'Enable','inactive');
    
    set(hlt(idev),'FontName',get(0,'FixedWidthFontName'));
    if idev == SelID+1
        set(hsw(idev),'Value',1);
    end
end

set(hb1,'Callback',{@OKCallback},'KeyPressFcn',{@OKKeyback,hrg,hb1,hb2});
set(hb2,'Callback',{@CCallback,hrg},'KeyPressFcn',{@OKKeyback,hrg,hb1,hb2});
set(hf,'CloseRequestFcn',{@CCallback,hrg},'KeyPressFcn',{@OKKeyback,hrg,hb1,hb2});

uicontrol(hb1)   % focus OK prompt

uiwait(hf);

DevID = get(hrg,'UserData');

% close(hf);   % invalid during 'CloseRequestFcn' definition
delete(hf);


function RBCallback(src,callbackdata)
set(src,'UserData',get(callbackdata.NewValue,'UserData'));

function SelClick(varargin)
hrg = varargin{3};
hsw = varargin{4};
SelID = get(hsw,'UserData');
set(hsw,'Value',1);
set(hrg,'UserData',SelID);

function OKCallback(varargin)
uiresume(gcbf);

function CCallback(varargin)
hrg = varargin{3};
set(hrg, 'UserData', '');
uiresume(gcbf);

function OKKeyback(varargin)
hrg = varargin{3};
hb1 = varargin{4};
hb2 = varargin{5};
Str = varargin{2};
src = varargin{1};
if strcmp(Str.Key,'return')
    if src == hb2
        CCallback([],[],hrg);
    else
        uicontrol(hb1)      % reflect current input
        OKCallback([],[],hrg);
    end
elseif strcmp(Str.Key,'escape')
    CCallback([],[],hrg);
elseif ~isempty(Str.Character) && ~isempty(str2double(Str.Character))...
        && str2double(Str.Character) >= 0 ...
        && str2double(Str.Character) < min(10,length(get(hrg,'Children'))),
    hsw = get(hrg,'Children');
    hsw = hsw(cell2mat(get(hsw,'UserData')) == str2double(Str.Character));
    SelClick([],[],hrg,hsw);
end