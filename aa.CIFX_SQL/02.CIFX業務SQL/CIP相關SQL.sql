--找CIP/CIFX同時存在的顧客
select *
from cifx.tb_customer@cyberark_cifx a
         inner join
     (select circi_key, disabled from cip_batch.vw_cust_key_mapping where circi_key is not null) b
     on a.cif_verified_id = b.circi_key
where b.disabled is null
      ;
/
--只找CIP存在的顧客
select a.cust_id,a.circi_key,a.CREDIT_CARD_KEY,a.BIRTHDAY,b.DISABLED,b.DISABLED_DATETIME,b.DISABLED_SYSTEM_CODE
from CIP_BATCH.VW_CUST_KEY_MAPPING a
left join CIP_GR_INTEGRATION.TB_CUSTOMER_TAG b on a.cust_id=b.cust_id
where b.DISABLED is null;
/


--由CIFX SEC 找應該要在CIP存在的顧客(並且CIFX有改過號)
select cust.cust_name,cust.cif_verified_id,cust.EVER_CHANGED_CERT_NO,cust.PRIOR_PERSON_IDENTIFITY_NO from cifx.tb_service_execution_control sec
join cifx.tb_customer cust
on cust.cif_verified_id = sec.circi_key
where sec.execution_type = 'STAGE1_EXECUTION' and sec.execution_state = 'EXECUTED'
and cust.EVER_CHANGED_CERT_NO is not null
and cust.PRIOR_PERSON_IDENTIFITY_NO is null
;
/


--查看有收到cip覆蓋回覆異動紀錄
SELECT CLL.CIRCI_KEY,
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
WHERE CL.SENDER_CODE  = 'UP0090'
AND   CL.TX_ID = 'A121013'
AND   CLL.FUNC_ID = 'FUNC_031'
AND CLL.CHANGE_LOG_ID = ''  --看什麼看欄位
ORDER BY CLL.CREATE_TIMESTAMP DESC;