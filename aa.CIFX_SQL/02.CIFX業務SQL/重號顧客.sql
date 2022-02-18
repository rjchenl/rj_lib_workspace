

--查重號顧客
SELECT cif_original_id,BIRTHDAY,COUNT(1) FROM CIFX.TB_CUSTOMER
GROUP BY cif_original_id,BIRTHDAY
HAVING COUNT(1) >1
;


--查elds帳號存在主檔之統編
SELECT acu.ACC,CUST_ID FROM edls.tb_acc_used acu
where exists (select * from cifx.tb_customer where cif_verified_id = acu.cust_id)
;


--查舊號顧客
   SELECT * FROM CIFX.TB_CUSTOMER
    WHERE EVER_CHANGED_CERT_NO IS NOT NULL
    AND PRIOR_PERSON_IDENTIFITY_NO IS  NULL
   ;

--重覆改號
select * from cifx.tb_service_execution_control sec
where sec.to_exec_timestamp > TO_TIMESTAMP('2021/11/24 00:20:33','YYYY/MM/DD HH24:MI:SS')
--and sec.circi_key = 'F127137315'
and execution_state = 'EVER_CHANGED_ID_CUSTOMER'
AND SEC.EXECUTION_TYPE = 'STAGE1_EXECUTION'
order by to_exec_timestamp desc
;
