USE master
GO
sp_configure 'show advanced options',1
GO
RECONFIGURE WITH OVERRIDE
GO
sp_configure 'Database Mail XPs',1
GO
RECONFIGURE 
GO

Declare @AccountNameDef Varchar(100) = 'Informativo TI'
Declare @AccountDesc Varchar(200) = 'Conta padrão para envio de Emails'
Declare @Email Varchar(100) = 'informativo@shared.mandic.net.br'
Declare @Smtp Varchar(100) = 'sharedrelay-cluster.mandic.net.br'
Declare @Porta Int = 25
Declare @Senha Varchar(100) = 'mudaaqui'
Declare @ssl bit = 0 --0 para não 1 para sim
Declare @EmailParaTeste Varchar(254) = 'dmussatto@dmdev.com.br'


---- Habilitando opções avançadas
--EXEC master.dbo.sp_configure 'show advanced option', '1';  

-- Criar a conta no SQL 

EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = @AccountNameDef,
    @email_address = @Email,
    @replyto_address = @Email,
    @display_name = @AccountNameDef,
    @description = @AccountDesc,
    @mailserver_name = @Smtp,
    @port = @Porta,
    @use_default_credentials = 0, --Usar basic authentication
    @username = @Email,
    @password = @Senha,
    @enable_ssl = @ssl;

-- Criando o Perfil

EXECUTE msdb.dbo.sysmail_add_profile_sp
    @profile_name = @AccountNameDef,
    @description = @AccountDesc;

-- Adicionando a conta ao perfil criado

EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @AccountNameDef,
    @account_name = @AccountNameDef,
    @sequence_number =1 ;
    
--Gerando acesso para as bases

EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = @AccountNameDef,
    @principal_name = 'public',
    @is_default = 1 ;

-- Enviando email teste

EXEC msdb..sp_send_dbmail 

    @profile_name=@AccountNameDef, -- Coloque o profile desejado.
    @recipients=@EmailParaTeste, -- Coloque os receptores da mensagem.
    @importance = 'HIGH',
    @subject='Teste de Envio',
    @body= 'body',
    @body_format = 'html'
