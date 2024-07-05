function plot_hht(imf,Fs)
% Plot the HHT.
% plot_hht(IMFs,Fs)
% 
% :: Syntax
%    The array x is the input signal and Ts is the sampling period.
%    Example on use: load handel;
%                    plot_hht(emd(y),Fs);
% 
% See also, EMD

% Copyright (c) 2016, Alan Tan
% All rights reserved.

% 20190419 Yuasa: modified

% Get HHT info.
assert(ismatrix(imf), 'IMFs must be a matrix');
M = size(imf,2);
N = size(imf,1);
for k = 1:M
   b(k) = sum(imf(:,k).*imf(:,k));
   th   = angle(hilbert(imf(:,k)));
   d{k} = gradient(unwrap(th))*Fs/(2*pi);
end
% [u,v] = sort(-b);
% b     = 1-b/max(b);

% Set IMF plots & time-frequency plots.
c = linspace(0,(N-1)/Fs,N);
for k1 = 0:4:M-1
   figure
   for k2 = 1:min(4,M-k1)
       %-- plot IMF
       subplot(4,2,2*k2-1), plot(c,imf(:,k1+k2)); set(gca,'FontSize',8,'XLim',[0 c(end)],'YLim',[-1,1].*harmmean(abs(get(gca,'YLim')))); 
   end
   xlabel('Time');
   
   for k2 = 1:min(4,M-k1)
       %-- plot HHT
       maxF = sort(d{k1+k2});  maxF = maxF(round(length(maxF)*0.99))*1.5;
       ordF = fix(log10(maxF));
       if ordF>0,   maxF = ceil(maxF/ordF) * ordF;
       else         maxF = ceil(maxF+eps);          end
       subplot(4,2,2*k2), plot(c,d{k1+k2},'k.','MarkerSize',3);
       set(gca,'FontSize',8,'XLim',[0 c(end)],'YLim',[0 maxF]); ylabel('Frequency');
   end
   xlabel('Time');
   
end
