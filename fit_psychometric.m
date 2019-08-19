function varargout = fit_psychometric(varargin)

% use logistic function
% need Statistic toolbox
% 
% [r, x0, [,K] [,y0]] = fit_psychometric(x, y [,K] [,y0])
% y = K ./ (1 + exp(r.*(x0-x))) + y0
% r  : gain                                 % beta(1)
% x0 : x value for 50%                      % beta(2)
% K  : size of logistic [max(y) - min(y)]   % beta(3)
% y0 : minimum value for y                  % beta(4)

% 20140917 Yuasa
% 20151026 Yuasa: message off
% 20170512 Yuasa: enhance for irregular

narginchk(2,4);

din  = varargin{1};     % x
dout = varargin{2};     % y

r  = [];
x0 = [];

switch nargin
    case 2,
        K  = [];
        y0 = [];
    case 3,
        K  = varargin{3};
        y0 = [];
    case 4,
        K  = varargin{3};
        y0 = varargin{4};
end

% xrange = max(din) - min(din);
yrange = max(dout) - min(dout);
ydiff  = diff(dout);
gradfunc = sign(din(find(dout==max(dout),1)) - ...
                din(find(dout==min(dout),1)));      % ŠÖ”‚ÌŒX‚«

beta0(4) = min(dout)*(gradfunc==1) + ...
           max(dout)*(gradfunc==-1);                % K<-1 -> y0 = maximum value
if ~isempty(y0),    beta0(4) = y0;     end
beta0(3) = yrange*gradfunc;                         % y‚ÌÅ‘å’l‚ÆÅ¬’l‚Ì·
if ~isempty(K),     beta0(3) = K;      end

y50 = nearlyeq(dout,beta0(3)/2 + beta0(4),[],1);    % —^‚¦‚ç‚ê‚½y‚Ì50%‚ğŒvZ
beta0(2) = din(y50);                                % ‚»‚Ì‚Ìx‚ğx0‚Éİ’è

x2max    = (max(din) - din(y50)) *2 + din(y50);     % —^‚¦‚ç‚ê‚½x‚Ì”{‚Ì•‚ğæ‚é
  issatur  = abs(ydiff) < (max(abs(ydiff)).*0.05);  % saturation check -> Å‘å•Ï‰»—Ê‚Ì5%ˆÈ‰º‚Ì•Ï‰»‚ª‚ ‚é‚©? -> x2max’u‚«Š·‚¦
  if max(issatur),   x2max = din(find(issatur,1)+1);   end
beta0(1) = log(10^-2) / (beta0(2) - x2max);         % x2max‚Åy‚ª99%‚Æ‰¼’è -> exp(r*(x0-x2max))=0.01
                                                    % K, y0‚Ì’l‚É‚æ‚ç‚¸ˆê’è

opts = optimset('Display','off');

if isempty(y0)
    if isempty(K)            % estimate [r,x0,K,y0]
        nargoutchk(4,4);
%         param = nlinfit(din,dout,@logistic4_f,beta0);
        param = lsqcurvefit(@logistic4_f,beta0,din,dout,[0,-inf,-inf,-inf],[inf,inf,inf,inf],opts);
    else                     % estimate [r,x0,y0]
        nargoutchk(4,4);
        beta0 = beta0([1:2 4]);
%         param = nlinfit(din,dout,@logistic3_y0_f,beta0);
        param = lsqcurvefit(@logistic3_y0_f,beta0,din,dout,[0,-inf,-inf],[inf,inf,inf],opts);
        param = [param(1:2) K param(3)];
    end
else
    if isempty(K)            % estimate [r,x0,K]
        nargoutchk(3,4);
        beta0 = beta0(1:3);
%         param = nlinfit(din,dout,@logistic3_K_f,beta0);
        param = lsqcurvefit(@logistic3_K_f,beta0,din,dout,[0,-inf,-inf],[inf,inf,inf],opts);
        param = [param y0];
    else                     % estimate [r,x0]
        nargoutchk(2,4);
        beta0 = beta0(1:2);
%         param = nlinfit(din,dout,@logistic2_f,beta0);
        param = lsqcurvefit(@logistic2_f,beta0,din,dout,[0,-inf],[inf,inf],opts);
        param = [param K y0];
    end
end


varargout = {param(1), param(2)};
switch nargout
    case 3
        varargout{3} = param(3);
    case 4
        varargout(3:4) = {param(3), param(4)};
end


function yhat = logistic4_f(beta,xd)
    
    yhat = beta(3) ./ (1 + exp(beta(1).*(beta(2)-xd))) + beta(4);
    
end

function yhat = logistic3_y0_f(beta,xd)
        
    yhat = K ./ (1 + exp(beta(1).*(beta(2)-xd))) + beta(3);

end

function yhat = logistic3_K_f(beta,xd)
        
    yhat = beta(3) ./ (1 + exp(beta(1).*(beta(2)-xd))) + y0;

end

function yhat = logistic2_f(beta,xd)
        
    yhat = K ./ (1 + exp(beta(1).*(beta(2)-xd))) + y0;

end


end