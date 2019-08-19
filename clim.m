function a = clim(arg1, arg2)
%CLIM COLOR limits.
%   CL = CLIM             gets the color limits of the current axes.
%   CLIM([CMIN CMAX])     sets the color limits.
%   CLMODE = CLIM('mode') gets the color limits mode.
%   CLIM(mode)            sets the color limits mode.
%                            (mode can be 'auto' or 'manual')
%   CLIM(AX,...)          uses axes AX instead of current axes.
%
%   CLIM sets or gets the CLim or CLimMode property of an axes.
%
%   See also XLIM, YLIM, ZLIM.

%   20170205 Yuasa: modify XLIM

if nargin == 0
    a = get(gca,'CLim');
else
    if isscalar(arg1) && ishghandle(arg1) && isprop(arg1,'CLim')
        ax = arg1;
        if nargin==2
            val = arg2;
        else
            a = get(ax,'CLim');
            return
        end
    else
        if nargin==2
            error(message('MATLAB:clim:InvalidNumberArguments'))
        else
            ax = gca;
            val = arg1;
        end
    end

    matlab.graphics.internal.markFigure(ax);
    if ischar(val)
        if(strcmp(val,'mode'))
            a = get(ax,'CLimMode');
        else
            set(ax,'CLimMode',val);
        end
    else
        set(ax,'CLim',val);
    end
end
