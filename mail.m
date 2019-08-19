function mail(sendmessage)

% send a mail
% 
% 20170221 Yuasa: modified
% 20171103 Yuasa: script -> function



%%
%{
%%% SMTP Settings
%-- SMTP Server
setpref( 'Internet', 'SMTP_Server', 'mail.nict.go.jp');
%-- SMTP Username
setpref( 'Internet', 'SMTP_Username', 'm1670005');
%-- SMTP Password
setpref( 'Internet', 'SMTP_Password', '*******');
%-- Sending address
setpref('Internet', 'E_mail', 'myNotify@matlab.com');
%-- SSH Settings
global mail_properties
mail_properties.ssh     = 'yes';
%}
%%
%-- Select mail server
mail_nict;

%-- SSL Settings
global mail_properties
if ~isempty(mail_properties) && isfield(mail_properties,'ssh') && strcmp(mail_properties.ssh,'yes')
  props = java.lang.System.getProperties;
  props.setProperty('mail.smtp.auth','true');
  props.setProperty('mail.smtp.socketFactory.class', ...
                    'javax.net.ssl.SSLSocketFactory');
  props.setProperty('mail.smtp.socketFactory.port','465');
end


%-- message
if exist('sendmessage','var')
    sendmessage = sprintf('èIóπ %s',sendmessage);
else
    sendmessage = 'èIóπ';
end

%-- Send a mail
% sendmail('ken-ichi_y.magan-soil@docomo.ne.jp','MATLAB',sendmessage)
% sendmail('kenichi_y@nifty.com','MATLAB',sendmessage)
sendmail('yuasa.research@gmail.com','MATLAB',sendmessage)

%-- Reset password
setpref( 'Internet', 'SMTP_Password', '*******');