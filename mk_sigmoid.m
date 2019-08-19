function y_val = mk_sigmoid(x_val, x50, width)
% 
%  y_val = mk_sigmoid(x_val, x50, width)
% 
% x_val: input values            % ex: 1:1000
% x50  : x value for 50%         % ex: 250
% width: x95 - x5                % ex: 100 

% 20160907 Yuasa


    x5    = x50-width./2;                      % x value for 5%
    gain  = log(1/0.05 - 1) ./ (x50 - x5);     % y(x5)=0.05 -> exp(r*(x0-x2max))=1/0.05 - 1

    y_val = 1 ./ (1 + exp(gain.*(x50-x_val)));