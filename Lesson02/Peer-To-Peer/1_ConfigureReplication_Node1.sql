-- Node 1: Neptune\SQL2014
:setvar Publisher "Neptune\SQL2014"
-- Node 2: Neptune\SQL2016
:setvar Subscriber "Neptune\SQL2016"
:setvar DatabaseName "AdventureWorks"
:setvar PublicationName "P2P_AdventureWorks"

:CONNECT $(Publisher)


-- Enabling the replication database 
USE master 

EXEC sp_replicationdboption 
  @dbname = "$(DatabaseName)", 
  @optname = N'publish', 
  @value = N'true' 

GO

-- Adding the transactional publication 
USE $(DatabaseName) 

EXEC sp_addpublication 
@publication ="$(PublicationName)", 
@description = N'Peer-to-Peer publication of database ''AdventureWorks'' from Publisher ''NEPTUNE\SQL2016''.' , 
@sync_method = N'native', 
@allow_push = N'true', 
@allow_pull = N'true', 
@allow_anonymous = N'false', 
@repl_freq = N'continuous', 
@status = N'active', 
@independent_agent = N'true', 
@immediate_sync = N'true', 
@allow_queued_tran = N'false', 
@allow_dts = N'false', 
@replicate_ddl = 1, 
@allow_initialize_from_backup = N'true', 
@enabled_for_p2p = N'true', 
@p2p_conflictdetection = N'true', 
@p2p_continue_onconflict=N'true',
@p2p_originator_id = 1

GO

-- Adding the transactional articles 
EXEC sp_addarticle 
  @publication = "$(PublicationName)", 
  @article = N'SalesOrderDetail', 
  @source_owner = N'Sales', 
  @source_object = N'SalesOrderDetail', 
  @destination_table = N'SalesOrderDetail', 
  @destination_owner = N'Sales', 
  @ins_cmd = N'CALL [sp_MSins_SalesSalesOrderDetail01166611037]', 
  @del_cmd = N'CALL [sp_MSdel_SalesSalesOrderDetail01166611037]', 
  @upd_cmd = N'SCALL [sp_MSupd_SalesSalesOrderDetail01166611037]' 

GO


EXEC sp_addarticle 
  @publication = "$(PublicationName)", 
  @article = N'SalesOrderHeader', 
  @source_owner = N'Sales', 
  @source_object = N'SalesOrderHeader', 
  @destination_table = N'SalesOrderHeader', 
  @destination_owner = N'Sales', 
  @ins_cmd = N'CALL [sp_MSins_SalesSalesOrderHeader0611538077]', 
  @del_cmd = N'CALL [sp_MSdel_SalesSalesOrderHeader0611538077]', 
  @upd_cmd = N'SCALL [sp_MSupd_SalesSalesOrderHeader0611538077]' 

GO

USE $(DatabaseName) 

GO
-- Adding the transactional subscriptions 
EXEC sp_addsubscription 
  @publication = "$(PublicationName)", 
  @subscriber = "$(Subscriber)", 
  @destination_db = "$(DatabaseName)", 
  @subscription_type = N'Push', 
  @sync_type = N'replication support only', 
  @article = N'all', 
  @update_mode = N'read only', 
  @subscriber_type = 0 

GO


EXEC sp_addpushsubscription_agent 
  @publication ="$(PublicationName)", 
  @subscriber = "$(Subscriber)", 
  @subscriber_db = "$(DatabaseName)", 
  @job_login = NULL, 
  @job_password = NULL, 
  @subscriber_security_mode = 1, 
  @frequency_type = 64, 
  @frequency_interval = 1, 
  @frequency_relative_interval = 1, 
  @frequency_recurrence_factor = 0, 
  @frequency_subday = 4, 
  @frequency_subday_interval = 5, 
  @active_start_time_of_day = 0, 
  @active_end_time_of_day = 235959, 
  @active_start_date = 0, 
  @active_end_date = 0

  