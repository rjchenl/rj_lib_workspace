UPDATE CIFX.TB_SERVICE_EXECUTION_CONTROL
SET EXECUTION_STATE     = 'TO_EXECUTE',
    RESULT_CODE         = NULL,
    EXECUTING_TIMESTAMP = null,
    EXECUTED_TIMESTAMP  = null,
    ap_server_EXECUTING = NULL
WHERE SERVICE_EXECUTION_CONTROL_ID IN ('1636448165161664-4283243-08-01')
  AND EXECUTION_TYPE = 'STAGE1_EXECUTION';
/

UPDATE CIFX.TB_SERVICE_EXECUTION_CONTROL
SET EXECUTION_STATE     = 'EXECUTED',
    ap_server_EXECUTING = NULL
WHERE SERVICE_EXECUTION_CONTROL_ID IN ('1636551271613337-4510181-44-01')
  and execution_type = 'STAGE1_EXECUTION';
/

SELECT EXECUTION_TYPE, SERVICE_INTERCHANGE_ID, CIRCI_KEY, EXECUTION_STATE
FROM CIFX.TB_SERVICE_EXECUTION_CONTROL
WHERE SERVICE_EXECUTION_CONTROL_ID IN ('1636448165161664-4283243-08-01')
  AND EXECUTION_TYPE = 'STAGE1_EXECUTION';
/

-- ======================== oms ============================


select * from cifx.tb_oms_execution_control
order by to_exec_timestamp desc
;
/

update cifx.tb_oms_execution_control
set ap_server_to_exec = null,
ap_server_executing = null,
ap_server_executing_thread = null,
execution_state  ='TO_EXECUTE',
to_exec_timestamp = NULL,
executing_timestamp = null,
executed_timestamp = null,
broken_timestamp = null,
retry_count = null,
result_code = null
where uuid = '1644426904907710-3990928-98-01';
/
commit;
/