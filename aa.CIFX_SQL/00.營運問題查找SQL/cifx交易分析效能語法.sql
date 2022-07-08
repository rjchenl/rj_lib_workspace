--查詢逐筆交易時間
select si.service_interchange_id,si.txn_code,si.req_timestamp,si.result_code,si.resp_timestamp,round(extract(second from (si.resp_timestamp-si.req_timestamp))*1000) exec_time
from CIFX.TB_SERVICE_INTERCHANGE si
where si.req_timestamp between to_timestamp('2020-03-25', 'YYYY-MM-DD') and to_timestamp('2020-01-31', 'YYYY-MM-DD')
and si.txn_code = 'A212015'
order by req_timestamp desc;
/

-- CIFX 查詢整體統計資訊
with tx_data as (
select si.txn_code,round(extract(second from (si.resp_timestamp-si.req_timestamp))*1000) exec_time from CIFX.TB_SERVICE_INTERCHANGE si
where si.req_timestamp between to_timestamp('2021-06-15', 'YYYY-MM-DD') and to_timestamp('2021-06-17', 'YYYY-MM-DD')
),total_tx as (
select txn_code,count(1) ct,round(avg(tx_data.exec_time)) av,min(tx_data.exec_time) mi,max(tx_data.exec_time) mx from tx_data
group by txn_code
),to_tx as (
select txn_code,count(1) ct  from tx_data where tx_data.exec_time > 100 group by txn_code
)
select total_tx.txn_code,total_tx.ct total,nvl(to_tx.ct,0) overtime,total_tx.av avg_mils,total_tx.mx max_mils,total_tx.mi min_mils from total_tx
left outer join to_tx on total_tx.txn_code = to_tx.txn_code
order by total_tx.ct desc;
--CIFX 查詢個別交易回應時間分布(只統計99分位內數據)
with per_hi_time as (
select txn_code,percentile_cont(0.99) within group(order by extract(second from (resp_timestamp-req_timestamp))*1000 asc) hi_per from CIFX.TB_SERVICE_INTERCHANGE
where req_timestamp between to_timestamp('2021-06-15', 'YYYY-MM-DD') and to_timestamp('2021-06-17', 'YYYY-MM-DD') group by txn_code
),tx_data as (
select si.txn_code,round(extract(second from (si.resp_timestamp-si.req_timestamp))*1000) exec_time from CIFX.TB_SERVICE_INTERCHANGE si,per_hi_time
where si.txn_code = per_hi_time.txn_code and si.req_timestamp between to_timestamp('2021-06-15', 'YYYY-MM-DD') and to_timestamp('2021-06-17', 'YYYY-MM-DD')
and round(extract(second from (si.resp_timestamp-si.req_timestamp))*1000) < per_hi_time.hi_per
)
SELECT CASE
         WHEN exec_time <= 100 THEN '1. 1-100'
         WHEN exec_time <= 300 THEN '2. 101-300'
         WHEN exec_time <= 1000 THEN '3. 301-1000'
         WHEN exec_time <= 5000 THEN '4. 1001-5000'
         ELSE '5. 5000+'
       END AS exec_time,
       COUNT(*) AS TIMES,
       100*round(COUNT(*)/SUM(COUNT(*)) OVER(),4) AS "PCT%"
FROM tx_data
GROUP BY CASE
         WHEN exec_time <= 100 THEN '1. 1-100'
         WHEN exec_time <= 300 THEN '2. 101-300'
         WHEN exec_time <= 1000 THEN '3. 301-1000'
         WHEN exec_time <= 5000 THEN '4. 1001-5000'
         ELSE '5. 5000+'
         END
ORDER BY exec_time;
/

-- cifx效能 by 日期區間 (找哪支交易比較慢)
with tx_data as (
select si.txn_code,round(extract(second from (si.resp_timestamp-si.req_timestamp))*1000) exec_time from CIFX.TB_SERVICE_INTERCHANGE si
where si.req_timestamp between to_timestamp('2021-06-15 00:00:00', 'yyyy-mm-dd hh24:mi:ss') and to_timestamp('2021-06-17 00:00:00', 'yyyy-mm-dd hh24:mi:ss')
),total_tx as (
select txn_code,count(1) ct,round(avg(tx_data.exec_time)) av,min(tx_data.exec_time) mi,max(tx_data.exec_time) mx from tx_data
group by txn_code
),to_tx as (
select txn_code,count(1) ct  from tx_data where tx_data.exec_time > 100 group by txn_code
),to_10s as (
select txn_code,count(1) ct  from tx_data where tx_data.exec_time > 10000 group by txn_code
)
select total_tx.txn_code,total_tx.ct total,nvl(to_tx.ct,0) overtime,nvl(to_10s.ct,0) over10s,total_tx.av avg_mils,total_tx.mx max_mils,total_tx.mi min_mils from total_tx
left outer join to_tx on total_tx.txn_code = to_tx.txn_code
left outer join to_10s on total_tx.txn_code = to_10s.txn_code
where substr(total_tx.txn_code,1,2) <> 'BT'
order by total_tx.av desc;
/

-- CIFX DB 效能語法(特定交易/執行時間異常)
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
from ODS_TW.TB_SERVICE_INTERCHANGE@ODS si
where si.req_timestamp between to_timestamp('2021-06-16 00:00:00', 'yyyy-mm-dd hh24:mi:ss') and to_timestamp('2021-06-17 00:00:00', 'yyyy-mm-dd hh24:mi:ss')
--and si.txn_code in ('NT1504')  --輸入欲查詢交易代號
order by req_timestamp
)d
where exec_time >　10000   --執行時間超過 ms
and SUBSTR(TXN_CODE,1,2) <> 'BT'   --批次交易不看
ORDER BY EXEC_TIME DESC
;
/