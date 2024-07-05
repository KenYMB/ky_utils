function varargout = sbjdlginp(varargin)

% SbjIn = SBJDLGINP(prompt,name,numlines,defaultanswer,monitor)
% 
% show input dialog (in sub monitor)
% properties are based on inputdlg
% 
% prompt        : instruction message
%                (input as a cell array for multiple items)
% name          : dialog's name
% (numlines     : unavailable; all prompts have one line)
% defaultanswer : fill default answer in edit window
%                (input as a cell array for multiple items)
% screen        : set screen number (default:2)
%                ('end':last screen)
% 
% 'return' key works as 'OK' button
% 'esc' key works as 'Cancel' button
% 
% 
% You can also use this function as 
% [Ans1 Ans2 ...] = SBJDLGINP(prompt,name,numlines,defaultanswer,monitor)
% 
% in this form, outputs are not cell array

% 2014/02/02 Yuasa @MATLAB2013b
% 2016/05/24 Enable multiple prompts @MATLAB2016a
% 2016/06/06 Bug fix
% 2016/07/14 expand empty input

if nargin < 1 || isempty(varargin{1}),  prompt = '';        else    prompt        = varargin{1};    end
if nargin < 2 || isempty(varargin{2}),  name = 'dialog';    else    name          = varargin{2};    end
if nargin < 3 || isempty(varargin{3}),  numlines = 1;       else    numlines      = varargin{3};    end
if nargin < 4 || isempty(varargin{4}),  defaultanswer = ''; else    defaultanswer = varargin{4};    end
if nargin < 5 || isempty(varargin{5}),  monnum = 2;         else    monnum        = varargin{5};    end

if iscell(prompt); dlgline = length(prompt);
else               dlgline = 1;              prompt = {prompt};
end
if iscell(defaultanswer);
else               defaultanswer = {defaultanswer};
end
    dlgerror = dlgline - length(defaultanswer);
    defaultanswer = cat(2,reshape(defaultanswer,1,[]),repmat({''},1,dlgerror));
    
if nargout > 1
    nargoutchk(dlgline,dlgline);
end

hf = dialog('WindowStyle', 'modal', 'Name', name);

TextFontSize = 12;

%-- analyze text width
TextWrap = cell(dlgline,1);  TextWidth = zeros(dlgline,4);
TestStrings=uicontrol(hf,'Style','text','FontSize',TextFontSize,'Visible','off');
MultiLine = ones(dlgline,1);
for iprmpt = 1:dlgline
    [TextWrap{iprmpt},TextWidth(iprmpt,1:4)]= textwrap(TestStrings,prompt(iprmpt),80);
end
TextWidthM = max(TextWidth(:,3));
delete(TestStrings)
TestStrings=uicontrol(hf,'Style','text','FontSize',TextFontSize,...
    'Position',[0 0 TextWidthM 50]+1, 'Visible','off'); % +1 is important!
for iprmpt = 1:dlgline
    [TextWrap{iprmpt},TextWidth(iprmpt,1:4)]= textwrap(TestStrings,prompt(iprmpt));
    MultiLine(iprmpt) = length(TextWrap{iprmpt});
end
TextWidthM = max([200; TextWidth(:,3)+30+20]);          % left&right margin
MaxLine   = sum(MultiLine);
delete(TestStrings)

%-- dialog size & position
dlgpos = [TextWidthM, 32+15*MaxLine+35*dlgline];

MInf = get(groot,'monitorPositions');
% Mres = get(groot,'ScreenSize');
monnum = round(monnum);
if strcmp(monnum,'end') || monnum>size(MInf,1); monnum=size(MInf,1); end
if monnum<1; monnum = 1; end
dlgpos = [floor(MInf(monnum,3)/2-dlgpos(1)/2+MInf(monnum,1)), ...
    floor(MInf(monnum,4)/2-dlgpos(2)/2+MInf(monnum,2)), ...
    dlgpos];

%-- set uicontrol
iline = 0;
for iprmpt = 1:dlgline
    iline = iline + MultiLine(iprmpt);
    htx(iprmpt) = uicontrol(hf,'Style','text','String',TextWrap{iprmpt},...
        'Position',[20 dlgpos(4)-15*iline-35*iprmpt+20 dlgpos(3)-30 15*MultiLine(iprmpt)+10],...
        'HorizontalAlignment','left','FontSize',TextFontSize);
    hid(iprmpt) = uicontrol(hf,'Style','edit','BackgroundColor',[1 1 1],...
        'Position',[20 dlgpos(4)-15*iline-35*iprmpt dlgpos(3)-30 25],...
        'HorizontalAlignment','left','String',defaultanswer{iprmpt});
end
set(hf,'Position',dlgpos);

hb1 = uicontrol(hf,'Style','pushbutton','String',getString(message('MATLAB:uistring:popupdialogs:OK')),'Position',[dlgpos(3)-135 5 60 22]);
hb2 = uicontrol(hf,'Style','pushbutton','String',getString(message('MATLAB:uistring:popupdialogs:Cancel')),'Position',[dlgpos(3)-70 5 60 22]);

set(hb1,'Callback',{@OKCallback,hid},'KeyPressFcn',{@OKKeyback,hid,hb1,hb2});
set(hb2,'Callback',{@CCallback,hid},'KeyPressFcn',{@OKKeyback,hid,hb1,hb2});
set(hf,'CloseRequestFcn',{@CCallback,hid},'KeyPressFcn',{@OKKeyback,hid,hb1,hb2});
for iprmpt = 1:dlgline
    set(hid(iprmpt),'KeyPressFcn',{@OKKeyback,hid,hb1,hb2});
end
setdefaultbutton(hf, hb1);

uicontrol(hid(1))   % focus first prompt

uiwait(hf);

%-- output as cell-array unless multiple outputs are indicated
if nargout > 1,
    varargout = get(hid(1),'UserData');
    if size(varargout,1) < 1
                    varargout = cell(1,nargout);
    end
else
    varargout{1} = get(hid(1),'UserData');
    if (dlgline == 1) && ~iscell(varargout{1})
        varargout{1} = varargout(1);
    end
end

% close(hf);   % invalid during 'CloseRequestFcn' definition
delete(hf);


function OKCallback(src,Str,hid)
uicontrol(src);             % select OK bottun
set(hid(1), 'UserData', get(hid,'String'));
uiresume(gcbf);

function CCallback(src,Str,hid)
uicontrol(src);             % select Cancel bottun
set(hid(1), 'UserData', cell(0));
uiresume(gcbf);

function OKKeyback(varargin)
hid = varargin{3};
hb1 = varargin{4};
hb2 = varargin{5};
Str = varargin{2};  % event data
src = varargin{1};  % current hundle
if strcmp(Str.Key,'return')
    if src == hb2
        CCallback(hb2,[],hid);
    else
        uicontrol(hb1);    	% reflect current input
        IsEditor = length(intersect(hid, src));
        if IsEditor && length(get(src,'String')) < 1
            set(src,'String','');
        end
        OKCallback(hb1,[],hid);
    end
elseif strcmp(Str.Key,'escape')
    CCallback(hb2,[],hid);
end

    function setdefaultbutton(figH, btnH)
    if usejava('awt')
        % We are running with Java Figures
        fh = handle(figH);
        fh.setDefaultButton(btnH);
    else
        % We are running with Native Figures
    end