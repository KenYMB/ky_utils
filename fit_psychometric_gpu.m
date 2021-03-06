function [r, x0, K, y0] = fit_psychometric_gpu(xin,yin1,yin2,yin3,yin4,yin5)

% use logistic function
% need Statistic toolbox
% 
% [r, x0, [,K] [,y0]] = fit_psychometric(x, y [,K] [,y0])
% y = K ./ (1 + exp(r.*(x0-x))) + y0
% 
% r  : gain                                 % beta(1)
% x0 : x value for 50%                      % beta(2)
% K  : size of logistic [max(y) - min(y)]   % beta(3)
%      set [] for estimation
% y0 : minimum value for y                  % beta(4)
%      set [] for estimation

% 2014/09/17 Yuasa
% 2015/11/03 for gpu l20 concatenation error

din  = xin;
dout = [yin1,yin2,yin3,yin4,yin5];

% xrange = max(din) - min(din);
yrange = max(dout) - min(dout);
gradfunc = sign(din(find(dout==max(dout),1)) - ...
                din(find(dout==min(dout),1)));      % 関数の傾き

beta0(4) = min(dout)*(gradfunc==1) + ...
           max(dout)*(gradfunc==-1);                % K<-1 -> y0 = maximum value
beta0(3) = yrange*gradfunc;                         % yの最大値と最小値の差

y50 = nearlyeq(dout,beta0(3)/2,[],1);               % 与えられたyの50%を計算
beta0(2) = din(y50);                                % その時のxをx0に設定

x2max    = (max(din) - din(y50)) *2 + din(y50);     % 与えられたxの倍の幅を取る
beta0(1) = log(10^-2) / (beta0(2) - x2max);         % x2maxでyが99%と仮定 -> exp(r*(x0-x2max))=0.01
                                                    % K, y0の値によらずほぼ一定
opts = optimset('Display','off');

% estimate [r,x0,K,y0]
%         param = nlinfit(din,dout,@logistic4_f,beta0);
        param = lsqcurvefit(@logistic4_f,beta0,din,dout,[0,-inf,-inf,-inf],[inf,inf,inf,inf],opts);

r  = param(1);
x0 = param(2);
K  = param(3);
y0 = param(4);

function yhat = logistic4_f(beta,xd)
    
    yhat = beta(3) ./ (1 + exp(beta(1).*(beta(2)-xd))) + beta(4);
    
end

end