function  pink_data = pinknoise(n,AB,Fs,ty,Ff)

% pink_data = pinknoise(n,Fs,AB,[ty],[Ff])
%
% n : number of samples (seconds * Fs)
% AB: Amplitude (0<AB<1)
% Fs: sampling frequency
% ty: type
%     0 = pink noise (default)
%     1 = white noise
%     2 = brown noise
% Ff: filtering frequency [low high] (default = [])
%     if length(Ff)==1 -> it works as high pass filter

% 20150611 Yuasa

warning('off','stats:lillietest:OutOfRangePHigh')

if ~exist('ty','var'),      ty = 0;     end
if ~exist('Ff','var'),      Ff = [];    end

% Lilliefors test to generate accurate whitenoise
ifGauss = 1;
if exist('lillietest','file')
    while ifGauss
        rand('state',sum(100*clock)); % 乱数のシードを日付と時間で決める
        Sn=randn(1,n);                % ノイズの生成
        Sn=Sn/max(abs(Sn));           % -1から1で標準化
        [h,p] = lillietest(Sn);
        ifGauss = p <0.5;
    end
end

% Generate noise filter
Flist = linspace(0,Fs,ceil(n/2));

switch ty
    case 0  % pinknoise
        F=Fs./Flist;                % 実数領域のフィルタ形状の定義
    case 1  % whitenoise
        F=ones(1,ceil(n/2));       	% 実数領域のフィルタ形状の定義
    case 2  % brownnoise
        F=(Fs./Flist).^2;       	% 実数領域のフィルタ形状の定義
end

if ~isempty(Ff)
    if (length(Ff)==1 && Ff <= Fs/2) ||...
            (length(Ff)==2 && Ff(2) <= Fs/2 && Ff(1)<Ff(2) && Ff(1)>=0)
        % hpf
        temp = abs(Flist - Ff(1));
        hpf = find(temp == min(temp),1,'last');
        if Flist(hpf) >= Ff(1), hpf = hpf - 1;  end;
         % adopt to filter
         F(1:hpf) = 0;
        
        % lps
        if length(Ff)==2
            temp = abs(Flist - Ff(2));
            lpf = find(temp == min(temp),1,'first');
            if Flist(lpf) <= Ff(2), lpf = lpf + 1;  end;
             % adopt to filter
             F(lpf:end) = 0;
        end
    end
end        
    
F(1) = 0;                           % 0Hz成分の除外
if mod(n,2)
    F=[F fliplr(F(1:end-1))];     % フィルタ形状の定義
else
    F=[F fliplr(F)];              % フィルタ形状の定義
end

S=fft(Sn);                    % ノイズの時間情報を周波数情報に変換
S=abs(S).*F.^(1/2).*exp(1i*angle(S));  % フィルタリング
iS=ifft(S);                    % 周波数情報を時間情報に変換
pink_data = AB * real(iS) / max(abs(real(iS)));

warning('on','stats:lillietest:OutOfRangePHigh')
if ifGauss; warning('Skip Lilliefors Test.'); end