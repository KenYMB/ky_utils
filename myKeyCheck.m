function myKeyCheck 

% OS�ŋ��ʂ̃L�[�z�u�ɂ���
KbName('UnifyKeyNames'); 

% ������̃L�[��������Ă��Ȃ���Ԃɂ��邽�߂P�b�قǑ҂�
WaitSecs(1.0);

% �����ɂ���L�[�̏�����
DisableKeysForKbCheck([]); 

% ��ɉ������L�[�����擾����
[ keyIsDown, secs, keyCode ] = KbCheck(-3); 

% ��ɉ������L�[����������A����𖳌��ɂ���
if keyIsDown 
    fprintf('�����ɂ����L�[������܂�\n');
    keys=find(keyCode); % keyCode�̕\��
    disp([int2str(keys) ' : ' KbName(keys)]); % �L�[�̖��O��\��
    DisableKeysForKbCheck(keys);
end
