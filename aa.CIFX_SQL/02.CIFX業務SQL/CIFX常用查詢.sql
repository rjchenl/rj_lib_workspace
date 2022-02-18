--欄位相關
select * from cifx.tb_column_code_opt;


--顧客主檔
SELECT * FROM CIFX.TB_CUSTOMER
;
/
--改號顧客
select EVER_CHANGED_CERT_NO,PRIOR_PERSON_IDENTIFITY_NO,CIF_VERIFIED_ID from cifx.tb_customer
where cif_verified_Id = 'C204239173'
;


--交易日期區間
SELECT req_content, resp_content, result_code
FROM cifx.tb_service_interchange si
WHERE si.txn_code = '交易代號'
  AND result_code = '0000'
 and si.REQ_TIMESTAMP BETWEEN TO_TIMESTAMP('2021/06/01 00:00:00','YYYY/MM/DD HH24:MI:SS')
                          and TO_TIMESTAMP('2021/06/31 00:00:00 ','YYYY/MM/DD HH24:MI:SS')
ORDER BY si.req_timestamp DESC;
/



-- 異動紀錄串連
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
WHERE CL.CIRCI_KEY = 'A110110112'
and tx_id = ''
ORDER BY CLL.CREATE_TIMESTAMP DESC
;
/
-- 只看今日
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
WHERE CL.CIRCI_KEY = 'X213793293'
and tx_id = 'BT$CIFIX'
and CLL.CREATE_TIMESTAMP >= trunc(current_timestamp)
ORDER BY CLL.CREATE_TIMESTAMP DESC
;
/
-- 舊核
SELECT
CLL.CIRCI_KEY,
CL.CHANGE_LOG_ID,
CL.SERVICE_INTERCHANGE_ID,
CL.TX_ID,
CC.COLUMN_NAME,
CC.COLUMN_DESC,
CLL.BEFORE_VALUE,
CLL.CHANGED_VALUE
FROM CIFX.TB_HIS_CHANGE_LOG CL
JOIN CIFX.TB_HIS_CHANGE_LOG_LINEITEM CLL ON CL.CHANGE_LOG_ID = CLL.CHANGE_LOG_ID
JOIN CIFX.TB_COLUMN_CODE CC ON CC.COLUMN_CODE_ID = CLL.CHANGED_COLUMN_CODE_ID
WHERE CL.CIRCI_KEY = 'A110110112'
ORDER BY CLL.CREATE_TIMESTAMP DESC
;
/
--分行簽退
SELECT BH_CODE,CN_NAME
FROM EDLS.TB_BRANCH WHERE SIGN_STATUS = '0'
AND UNIQUE_CODE NOT IN ('04','05','07')
ORDER BY SIGN_STATUS;
/

