function imhandle = imcolsample(color,imsize)

% imcolsample(color [,size])
% 
% color :    Color Vector
% imsize:    Matrix size
% 
% show color sample

% 20160627 Yuasa: Created

narginchk(1,2);
nargoutchk(0,1);

if nargin < 2 || numel(imsize) < 1;
    imsize = [250 250];
elseif numel(imsize) < 2;
    imsize = repmat(imsize,1,2);
end
immat = ones(imsize(1:2));
    
colormat = colorMat(immat,color);

if max(colormat(:)) > 1
    colormat = double(colormat) / 255;
end

imhandle  = imshow(colormat);
fighandle = get(get(imhandle,'Parent'),'Parent');
set(fighandle,'MenuBar','none','ToolBar','none');

if nargout == 0
    clear imhandle
end