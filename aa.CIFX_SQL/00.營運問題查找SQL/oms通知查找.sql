--check issue
select uuid,oms_id,oms_msg,executing_timestamp from cifx.tb_oms_execution_control
order by to_exec_timestamp desc;




--stg1/stg2
select
cli.FROM_SERVICE_INTERCHANGE_ID,
sec.service_execution_control_id,
CLI.MSG_NO,
SEC.CIRCI_KEY,
CL.TX_ID,
case when CLL.SENT_TIMESTAMP is null
then 'ok resync to cip ' else 'NOT ok to sync CIP' end as "isOkSync",
cli.RESP_CONTENT,

si.ap_server_to_process,
case when si.service_interchange_id is null
then 'from cip sync' else 'from si' end as "txnSourceFrom",

case when cl.tx_id in (
'A149041',
'TQP03002',
'NT1504',
'A101011',
'A101012'
) then 'YES' else 'no' end  as "isImpactCust",
CLL.CIRCI_KEY,
CL.CHANGE_LOG_ID,
CL.SERVICE_INTERCHANGE_ID,
CL.TX_ID,
CC.COLUMN_NAME,
CC.COLUMN_DESC,
CLL.BEFORE_VALUE,
CLL.CHANGED_VALUE,
CLL.CREATE_TIMESTAMP,
cll.sent_timestamp

--sec.execution_type,
--sec.execution_state,
--cli.req_content
--PEC.*,
--PMN.*,
--CL.*,
--CLL.*,
--CC.COLUMN_DESC,
--CER.*
from cifx.tb_oms_execution_control oec
LEFT join cifx.tb_change_log_interchange cli on cli.service_interchange_id = oec.service_interchange_id
LEFT JOIN CIFX.TB_CIP_EXCHANGE_RECORD CER ON CER.SERVICE_INTERCHANGE_ID = CLI.from_service_Interchange_id
LEFT JOIN CIFX.TB_SERVICE_EXECUTION_CONTROL SEC ON SEC.SERVICE_INTERCHANGE_ID = CLI.from_service_Interchange_id
LEFT join cifx.tb_service_interchange si on si.service_interchange_id = cli.from_service_Interchange_id
-------------------- << PUSH >>-------------------------------
--LEFT JOIN CIFX.TB_PUSH_MQ_NOTICE PMN ON PMN.SERVICE_INTERCHANGE_ID = CLI.from_service_Interchange_id
--LEFT JOIN CIFX.TB_PUSH_EXECUTION_CONTROL PEC ON PEC.SERVICE_INTERCHANGE_ID = CLI.from_service_Interchange_id
-------------------- << CHANGE_LOG >>-------------------------------
LEFT JOIN CIFX.TB_CHANGE_LOG CL ON CL.SERVICE_INTERCHANGE_ID = CLI.from_service_Interchange_id
LEFT JOIN CIFX.TB_CHANGE_LOG_LINEITEM CLL ON CL.CHANGE_LOG_ID = CLL.CHANGE_LOG_ID
LEFT JOIN CIFX.TB_COLUMN_CODE CC ON CC.COLUMN_CODE_ID = CLL.CHANGED_COLUMN_CODE_ID
where oec.uuid in (
'1636551271833508-4510215-62-01')
and sec.execution_type = 'STAGE1_EXECUTION'
;


--檢查該顧客後續同步任務中，是否有改號交易
select sec.*,cl.tx_id from cifx.tb_service_execution_control sec
join cifx.tb_change_log cl on cl.SERVICE_INTERCHANGE_ID = sec.SERVICE_INTERCHANGE_ID
where sec.circi_key ='S220293741'
order by req_timestamp desc
;


--同步任務歷史
select * from cifx.tb_service_execution_control sec
where sec.circi_key ='X120012087'
order by req_timestamp desc
;


select * from CIFX.TB_SERVICE_INTERCHANGE si
where si.SERVICE_INTERCHANGE_ID = '1629729365890888-9585124-02-02';



--CLI查看是否重覆送同步
SELECT * FROM CIFX.TB_CHANGE_LOG_INTERCHANGE CLI
WHERE CLI.FROM_SERVICE_INTERCHANGE_ID = '1627643249148783-5037679-15-01'
AND SERVICE_TARGET = 'ESIP_CIP'
;




--同步紀錄前後夾擊
select CLI.* from cifx.tb_change_log_interchange cli
 join cifx.tb_service_execution_control sec  on sec.service_Interchange_id = cli.FROM_SERVICE_INTERCHANGE_ID
where cli.REQ_TIMESTAMP BETWEEN TO_TIMESTAMP('2022/01/21 14:56:00','YYYY/MM/DD HH24:MI:SS')
AND TO_TIMESTAMP('2022/01/21 14:58:00 ','YYYY/MM/DD HH24:MI:SS')
 and service_target = 'ESIP_CIP'
 AND SEC.AP_SERVER_EXECUTING = '10.78.6.85:8443,cifx-controller-a-v1-112-92r7l'
order by cli.REQ_TIMESTAMP desc
;
/

select cli.*,sec.AP_SERVER_EXECUTING from cifx.tb_change_log_interchange cli
join cifx.tb_service_execution_control sec
on sec.service_Interchange_id = cli.FROM_SERVICE_INTERCHANGE_ID
where cli.REQ_TIMESTAMP BETWEEN TO_TIMESTAMP('2022/01/12 09:47:00','YYYY/MM/DD HH24:MI:SS')
AND TO_TIMESTAMP('2022/01/12 10:48:00 ','YYYY/MM/DD HH24:MI:SS')
and service_target = 'ESIP_CIP'
order by cli.REQ_TIMESTAMP desc
;


--是否在新核改過號
SELECT CL.CIRCI_KEY,CL.TX_ID,CL.TXN_OPERATION_DATE AS OP_DATE,CL.TXN_OPERATION_TIME AS OP_TIME,
CC.NBS_COLUMN_NAME_FOR_CHANGE AS COL_NAME,BEFORE_VALUE,CHANGED_VALUE,
CL.SERVICE_INTERCHANGE_ID
FROM CIFX.TB_CHANGE_LOG CL
JOIN CIFX.TB_CHANGE_LOG_LINEITEM CLL ON CL.CHANGE_LOG_ID = CLL.CHANGE_LOG_ID
LEFT JOIN CIFX.TB_COLUMN_CODE CC ON CLL.CHANGED_COLUMN_CODE_ID = CC.COLUMN_CODE_ID
WHERE CL.CIRCI_KEY IN ('P221923665') AND COLUMN_CODE IN ('X0161','X0558')
ORDER BY CL.CIRCI_KEY,CL.TXN_OPERATION_DATE,CL.TXN_OPERATION_TIME DESC;



--是否在舊號有改過後
SELECT CL.CIRCI_KEY,CL.TX_ID,CL.TXN_OPERATION_DATE AS OP_DATE,CL.TXN_OPERATION_TIME AS OP_TIME,
CC.NBS_COLUMN_NAME_FOR_CHANGE AS COL_NAME,BEFORE_VALUE,CHANGED_VALUE,
CL.SERVICE_INTERCHANGE_ID
FROM CIFX.TB_leg_CHANGE_LOG CL
JOIN CIFX.TB_leg_CHANGE_LOG_LINEITEM CLL ON CL.CHANGE_LOG_ID = CLL.CHANGE_LOG_ID
LEFT JOIN CIFX.TB_leg_COLUMN_CODE CC ON CLL.CHANGED_COLUMN_CODE_ID = CC.COLUMN_CODE_ID
WHERE CL.CIRCI_KEY IN ('P221923665') AND COLUMN_CODE IN ('X0161','X0558')
ORDER BY CL.CIRCI_KEY,CL.TXN_OPERATION_DATE,CL.TXN_OPERATION_TIME DESC;




--顧客主檔
SELECT FIRST_TXN_DATE FROM CIFX.TB_CUSTOMER
WHERE CIF_VERIFIED_ID IN ('P221923665');
/



--在新核是否被刪除過
SELECT * FROM CIFX.TB_HIS_CUSTOMER
WHERE CIF_VERIFIED_ID IN ('P221923665');

--新核刪除顧客時間 123
select *
from cifx.tb_his_change_log hcl
join cifx.tb_his_change_log_lineitem hcll on hcll.change_log_id = hcl.change_log_id
where hcl.circi_key = 'E120772351'
order by hcll.create_timestamp desc
;




--改號議題
--service_interchange_id_before  A改B  A的異動紀錄
--service_interchange_id_after A改B  B的異動紀錄
--service_interchange_id_create A改B    B是否存在  (原本B存在則有值，原本B不存在則無值)
SELECT * FROM CIFX.TB_CHG_ID_LOG
WHERE original_id_before like '%P221923%'
;



--PRIOR_PERSON_IDENTIFITY_NO 為null表示現在查詢的號是暫時的
select EVER_CHANGED_CERT_NO,PRIOR_PERSON_IDENTIFITY_NO from cifx.tb_customer
where cif_verified_Id = 'JC30061138'
;
--PRIOR_PERSON_IDENTIFITY_NO 不為null表示現在查詢的號是正在用的
select EVER_CHANGED_CERT_NO,PRIOR_PERSON_IDENTIFITY_NO from cifx.tb_customer
where cif_verified_Id = 'J800012174'
;


--確認是否可以重送
select sec.SERVICE_INTERCHANGE_ID,sec.SERVICE_EXECUTION_CONTROL_ID,cll.SENT_TIMESTAMP from CIFX.TB_CHANGE_LOG_LINEITEM cll
join cifx.tb_change_log cl on cl.change_log_id = cll.change_log_id
join cifx.tb_service_execution_control sec on sec.SERVICE_INTERCHANGE_ID = cl.SERVICE_INTERCHANGE_ID
where sec.SERVICE_EXECUTION_CONTROL_ID = ''
;


--舊號顧客判斷
SELECT EVER_CHANGED_CERT_NO,PRIOR_PERSON_IDENTIFITY_NO FROM CIFX.TB_CUSTOMER
WHERE EVER_CHANGED_CERT_NO IS NOT NULL
AND PRIOR_PERSON_IDENTIFITY_NO IS  NULL
and cif_verified_id = 'P221923665'
;




--顧客異動紀錄
SELECT
CLL.CIRCI_KEY,
CL.CHANGE_LOG_ID,
CL.SERVICE_INTERCHANGE_ID,
CL.TX_ID,
CC.COLUMN_NAME,
CC.COLUMN_DESC,
CLL.BEFORE_VALUE,
CLL.CHANGED_VALUE,
CLL.CREATE_TIMESTAMP
FROM CIFX.TB_CHANGE_LOG CL
JOIN CIFX.TB_CHANGE_LOG_LINEITEM CLL ON CL.CHANGE_LOG_ID = CLL.CHANGE_LOG_ID
JOIN CIFX.TB_COLUMN_CODE CC ON CC.COLUMN_CODE_ID = CLL.CHANGED_COLUMN_CODE_ID
WHERE CL.CIRCI_KEY = 'P221923665'
ORDER BY CLL.CREATE_TIMESTAMP DESC
;


--CIP是否有收到MSG_NO
select * from CIP_GR_INTEGRATION.Tb_Service_Interchange@CIP_CIFX_INI
where msg_no = 'TS0116_00_20220207182131_98811';

--CIP確認收到之MSG_NO是否失敗(有查到資料就是失敗)
select * from CIP_GR_INTEGRATION.Tb_Invalid_Service_Request@CIP_CIFX_INI
where msg_no = 'TS0116_00_20220207182131_98811';


