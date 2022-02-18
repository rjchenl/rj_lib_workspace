--總交易分析
with txn_raw_data as (
select
TO_CHAR(si.req_timestamp,'YYYYMMDD') TX_DATE ,
SI.SENDER_CODE,
si.txn_code,round(extract(second from (si.resp_timestamp-si.req_timestamp))*1000) exec_time
from ods_tw.TB_SERVICE_INTERCHANGE@ods si
--from cifx.TB_SERVICE_INTERCHANGE si
where
SUBSTR(TXN_CODE,1,2) <> 'BT'   --批次交易不看
AND  si.REQ_TIMESTAMP BETWEEN TO_TIMESTAMP('2021/05/05 00:00:00','YYYY/MM/DD HH24:MI:SS')  --時間區間(不加就是現有全部時間)
AND TO_TIMESTAMP('2021/05/06 00:00:00 ','YYYY/MM/DD HH24:MI:SS')
),
txn_avg as (
select
TX_DATE,
SENDER_CODE,
txn_code,
count(1) ct,
round(avg(txn_raw_data.exec_time)) av,
min(txn_raw_data.exec_time) mi,
max(txn_raw_data.exec_time) mx
from txn_raw_data
group by TX_DATE,SENDER_CODE,txn_code
)
--=============================================================
,v_txn_overtime as (
select
TX_DATE,
SENDER_CODE,
txn_code,
count(1) ct_over10
from txn_raw_data
where txn_raw_data.exec_time > 10000
and SUBSTR(TXN_CODE,1,2) <> 'BT'   --批次交易不看
group by TX_DATE,SENDER_CODE,txn_code
)
--======================= SHOW VIEW  ======================================
select
txn_avg.TX_DATE,
txn_avg.SENDER_CODE,
txn_avg.txn_code,
txn_avg.ct,
txn_avg.av,
txn_avg.mi,
txn_avg.mx,
v_txn_overtime.ct_over10
from txn_avg
left join v_txn_overtime
on (v_txn_overtime.TX_DATE = txn_avg.tx_date
and v_txn_overtime.sender_code = txn_avg.sender_code
and v_txn_overtime.txn_code = txn_avg.txn_code)
order by txn_avg.TX_DATE,txn_avg.SENDER_CODE,txn_avg.txn_code,v_txn_overtime.ct_over10 desc
;
/



--驗證用(超過10秒)
select * from (
select
si.txn_code,
si.result_code,
SI.SERVICE_URL,
si.SERVICE_INTERCHANGE_ID,
EXTRACT(month FROM SI.REQ_TIMESTAMP) AS month,
EXTRACT(day FROM SI.REQ_TIMESTAMP) AS day,
si.txn_time,
si.req_timestamp,
si.resp_timestamp,
round(extract(second from (si.resp_timestamp-si.req_timestamp))*1000) as exec_time
from ODS_TW.TB_SERVICE_INTERCHANGE@ODS si
where si.req_timestamp between to_timestamp('2021-12-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss') and to_timestamp('2021-12-30 00:00:00', 'yyyy-mm-dd hh24:mi:ss')
--and si.txn_code in ('NT1504')  --輸入欲查詢交易代號
order by req_timestamp
)
where exec_time >　10000   --執行時間超過 ms
and SUBSTR(TXN_CODE,1,2) <> 'BT'   --批次交易不看
ORDER BY EXEC_TIME DESC
;
/