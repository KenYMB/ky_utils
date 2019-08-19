function    output = easyfilt(input,ftype,Fs,Fc,order)

% y = EASYFILT(x,ftype,Fs,Fc,n)
%   apply filter easily
% 
%   y:      filtered signal
%   x:      input signal
%   ftype:  filter type ('low' | 'bandpass' | 'high' | 'stop')
%   Fs:     sampling freqeuncy [Hz]
%   Fc:     cutoff frequency [Hz]
%   n:      filter order (default:3)

% 20180607 Yuasa

% Using: SetDefault

narginchk(4,inf);

SetDefault('order',3);

%% main
Wn = Fc/(Fs/2);

[Fb,Fa] = butter(order,Wn,ftype);

output = filtfilt(Fb,Fa,input);