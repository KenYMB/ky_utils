function mail(sendmessage, to_address)

% MAIL(sendmessage, [to_address])
%   sends an email with message.
%   
%   Need to modify 'mail_template' appropreately in advance.
% 
% 20170221 Yuasa: modified
% 20171103 Yuasa: script -> function
% 20231108 Yuasa: Clean up

% Dependency: mail_template

%%
%{
%%% SMTP Settings
%-- SMTP Server
setpref( 'Internet', 'SMTP_Server', '*******');
%-- SMTP Username
setpref( 'Internet', 'SMTP_Username', '*******');
%-- SMTP Password
setpref( 'Internet', 'SMTP_Password', '*******');
%-- Sending address
setpref('Internet', 'E_mail', 'myNotify@matlab.com');
%-- SSH Settings
global mail_properties
mail_properties.ssh     = 'yes';
%}
%%
%-- Initial setup of the email server
global mail_properties
if isempty(mail_properties)
    mail_template;
end

%-- SSL Settings
if ~isempty(mail_properties) && isfield(mail_properties,'ssh') && strcmp(mail_properties.ssh,'yes')
  props = java.lang.System.getProperties;
  props.setProperty('mail.smtp.auth','true');
  props.setProperty('mail.smtp.socketFactory.class', ...
                    'javax.net.ssl.SSLSocketFactory');
  props.setProperty('mail.smtp.socketFactory.port','465');
end

%-- Setup email address to send
if ~exist('to_address','var') || isempty(to_address)
    clear to_address
    global to_address %#ok<REDEFGI,TLEV>
end

%-- Set message
if exist('sendmessage','var')
    sendmessage = sprintf('%s\n\nSent from MATLAB',sendmessage);
else
    sendmessage = 'Sent from MATLAB';
end

%-- Send a mail
sendmail(to_address,'MATLAB',sendmessage)

%-- Reset password
setpref( 'Internet', 'SMTP_Password', '*******');
