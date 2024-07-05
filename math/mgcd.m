function multi_gcd = mgcd(inp_vec)
% GCD = MGCD(V)
%   estimates common decimal divisor.
% 
% 2以上の要素を持つベクトルから最大公約数的な何かを計算する
% GCD : 最大公約数的な何か
% V   : 入力ベクトル
%       小数も可
% 

% 2015/04/03 Yuasa

%-- check if the input value is vector
vec_siz = size(inp_vec);
if min(vec_siz) > 1
    error('The input value is not VECTOR!');
end

%-- for decimal
% deci_unit = min(min(inp_vec),1);
deci_unit = 1;
%-- round at 10^-dod
dod=fix(log10(flintmax(class(inp_vec))./max(inp_vec(:)).*deci_unit));
tmp_gcd = round(inp_vec ./ deci_unit .* 10^dod);

while(length(tmp_gcd) > 1)
    %-- calculate gcd and reduce length of the vector
    tmp_gcd = gcd(tmp_gcd, fliplr(tmp_gcd));
    tmp_gcd = tmp_gcd(1:ceil(length(tmp_gcd)/2));
end

%-- return to input unit
multi_gcd = tmp_gcd .* deci_unit .* 10^-dod;

%-- Warning
if multi_gcd < 10^-9
    multi_gcd = 0;
    warning('The dataset do not have the common divisor.')
end