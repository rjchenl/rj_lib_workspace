select * from (
select
si.outter_tx_id_in_ap,
si.txn_code,
si.result_code,
SI.SERVICE_URL,
si.SERVICE_INTERCHANGE_ID,
si.txn_time,
si.req_timestamp,
si.resp_timestamp,
round(extract(second from (si.resp_timestamp-si.req_timestamp))*1000) as exec_time
from CIFX.TB_SERVICE_INTERCHANGE si
where si.req_timestamp between to_timestamp('2021-06-15 00:00:00', 'yyyy-mm-dd hh24:mi:ss') and to_timestamp('2021-06-16 00:00:00', 'yyyy-mm-dd hh24:mi:ss')
--and si.txn_code in ('NT1504')  --輸入欲查詢交易代號
order by req_timestamp
)
where exec_time >　10000   --執行時間超過 ms
and SUBSTR(TXN_CODE,1,2) <> 'BT'   --批次交易不看
ORDER BY EXEC_TIME DESC
;
/


--同步紀錄前後夾擊
select si.msg_No,sec.ap_server_executing,cli.* from cifx.tb_change_log_interchange cli
join cifx.tb_service_execution_control sec on sec.service_Interchange_id = cli.FROM_SERVICE_INTERCHANGE_ID
join cifx.tb_service_interchange si on si.service_Interchange_id = sec.service_Interchange_id
where cli.REQ_TIMESTAMP BETWEEN TO_TIMESTAMP('2021/12/30 09:28:00','YYYY/MM/DD HH24:MI:SS')
AND TO_TIMESTAMP('2021/12/30 09:31:00 ','YYYY/MM/DD HH24:MI:SS')
and service_target = 'ESIP_CIP'
--and cli.FROM_SERVICE_INTERCHANGE_ID = '1640856510783131-3954865-88-02'
and sec.ap_server_executing = '10.78.6.50:8443,cifx-controller-a-v1-111-grbdh'
order by cli.REQ_TIMESTAMP desc
;
/