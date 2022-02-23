--=================== 舊號註記清除作業 ===================
--查改號欄位
   select cif_verified_id,EVER_CHANGED_CERT_NO,PRIOR_PERSON_IDENTIFITY_NO FROM CIFX.TB_CUSTOMER
   where cif_verified_id = 'F284202182';
/


--是否在新核改過號
SELECT CL.CIRCI_KEY,CL.TX_ID,CL.TXN_OPERATION_DATE AS OP_DATE,CL.TXN_OPERATION_TIME AS OP_TIME,
CC.NBS_COLUMN_NAME_FOR_CHANGE AS COL_NAME,BEFORE_VALUE,CHANGED_VALUE,
CL.SERVICE_INTERCHANGE_ID
FROM CIFX.TB_CHANGE_LOG CL
JOIN CIFX.TB_CHANGE_LOG_LINEITEM CLL ON CL.CHANGE_LOG_ID = CLL.CHANGE_LOG_ID
LEFT JOIN CIFX.TB_COLUMN_CODE CC ON CLL.CHANGED_COLUMN_CODE_ID = CC.COLUMN_CODE_ID
WHERE CL.CIRCI_KEY IN ('P221923665') AND COLUMN_CODE IN ('X0161','X0558')
ORDER BY CL.CIRCI_KEY,CL.TXN_OPERATION_DATE,CL.TXN_OPERATION_TIME DESC;
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

--找舊號
   SELECT cif_verified_id,EVER_CHANGED_CERT_NO,PRIOR_PERSON_IDENTIFITY_NO FROM CIFX.TB_CUSTOMER
    WHERE EVER_CHANGED_CERT_NO IS NOT NULL
    AND PRIOR_PERSON_IDENTIFITY_NO IS NULL;
--找新號
   SELECT cif_verified_id,EVER_CHANGED_CERT_NO,PRIOR_PERSON_IDENTIFITY_NO FROM CIFX.TB_CUSTOMER
    WHERE EVER_CHANGED_CERT_NO IS NOT NULL
    AND PRIOR_PERSON_IDENTIFITY_NO IS  not NULL;
--看執行結果
select * from cifx_batch.tb_bt_cifix;

--異動紀錄 (只看今日)
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
WHERE CL.CIRCI_KEY = 'F284202182'
and tx_id = 'BT$CIFIX'
and CLL.CREATE_TIMESTAMP >= trunc(current_timestamp)
ORDER BY CLL.CREATE_TIMESTAMP DESC
;
/


--SEC
