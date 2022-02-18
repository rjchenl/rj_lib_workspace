

select * from cifx.tb_kfk_sec;
/

TRUNCATE TABLE CIFX.tb_kfk_sec;
INSERT INTO CIFX.TB_KFK_SEC (UUID, SERVICE_INTERCHANGE_ID, SEND_KFK_CONTENT, EXECUTION_STATE, AP_SERVER_TO_EXEC, AP_SERVER_EXECUTING, TO_EXEC_TIMESTAMP, EXECUTING_TIMESTAMP, EXECUTED_TIMESTAMP, BROKEN_TIMESTAMP, RETRY_COUNT, KFK_TOPIC_NAME) VALUES (cifx.fn_uuid_number30(), '1642176321586215-3963277-65-02', '{ "headers": { "txnCode":"F01", "txnDate":"20220113", "txnTime":"112800" }, "model":{ "customerCirciKey":"F127137311", "customerName":"陳阿傑", } }', 'TO_EXECUTE', '10.214.42.46:8443,LC105-18442-01', null, sysdate, null, null, null, null, 'UP0090_TS0116_00_1');
COMMIT;
/

UPDATE cifx.tb_customer
SET
  foreign_exchange_role_type = '05'
WHERE cif_verified_id = 'X212962418';
COMMIT;
/

--舊PUSH驗證
SELECT *
FROM cifx.tb_push_execution_control pec
WHERE REGEXP_LIKE(pec.ap_server_to_exec,
                  'LC105-18442-01')
ORDER BY uuid DESC;

SELECT *
FROM cifx.tb_service_interchange si
WHERE si.txn_code = 'A101011' AND result_code = '0000'
ORDER BY si.req_timestamp DESC;





SELECT *
FROM cifx.tb_service_interchange si
WHERE si.txn_code = 'createOrUpdateCustomerForNBS' AND result_code = '0000'
ORDER BY si.req_timestamp DESC;

--1643041196489688-3970640-91-02
SELECT *
FROM cifx.tb_push_execution_control pec
WHERE pec.service_interchange_id = '1643043447662846-3983501-23-01';

--1643043447793330-3983501-36-01
--1643043447794636-3983501-38-01
SELECT * FROM CIFX.TB_PUSH_MQ_NOTICE PMN
WHERE PMN.SERVICE_INTERCHANGE_ID = '1643043447662846-3983501-23-01';



SELECT *
FROM cifx.tb_joblog
ORDER BY run_time DESC;