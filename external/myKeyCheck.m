function myKeyCheck 

% OSで共通のキー配置にする
KbName('UnifyKeyNames'); 

% いずれのキーも押されていない状態にするため１秒ほど待つ
WaitSecs(1.0);

% 無効にするキーの初期化
DisableKeysForKbCheck([]); 

% 常に押されるキー情報を取得する
[ keyIsDown, secs, keyCode ] = KbCheck(-3); 

% 常に押されるキーがあったら、それを無効にする
if keyIsDown 
    fprintf('無効にしたキーがあります\n');
    keys=find(keyCode); % keyCodeの表示
    disp([int2str(keys) ' : ' KbName(keys)]); % キーの名前を表示
    DisableKeysForKbCheck(keys);
end
