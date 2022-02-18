select * from cifx.tb_service_execution_control sec
where sec.to_exec_timestamp > TO_TIMESTAMP('2021/11/24 00:20:33','YYYY/MM/DD HH24:MI:SS')
--and sec.circi_key = 'F127137315'
and execution_state = 'EVER_CHANGED_ID_CUSTOMER'
AND SEC.EXECUTION_TYPE = 'STAGE1_EXECUTION'
order by to_exec_timestamp desc
;
