function  mail_template

% template script of mail server settings for mex
% set global structure variable of 'mail_properties'
% 
% 20170221 Yuasa

%%% SMTP Settings
global mail_properties
%-- SMTP Server
coder.extrinsic('setpref( ''Internet'', ''SMTP_Server'', ''***'');');
%-- SMTP Username
coder.extrinsic('setpref( ''Internet'', ''SMTP_Username'', ''***'');');
%-- SMTP Password
coder.extrinsic('setpref( ''Internet'', ''SMTP_Password'', ''***'');');
%-- Sending address
coder.extrinsic('setpref( ''Internet'', ''E_mail'', ''myNotify@matlab.com'');');
%-- SSH Settings
mail_properties.ssh     = 'yes';

end