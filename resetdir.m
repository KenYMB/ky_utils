function resetdir()
% reload current directory

% 20201110 Yuasa

PWD = pwd;
if ispc
    cd(userpath);
else
    cd ~;
end
cd(PWD);