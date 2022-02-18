  select * from cifx.TB_COL_BUSINESS_RULE cbr
            where substr(cbr.RULE_ID,1,1) = 'V' --檢核
            AND RULE_PROCESS LIKE '%DYNC%'
--             and rule_id = 'V_053'
            order by col_id asc
            ;
/
--需要+1
select max(rule_id)  from cifx.tb_col_business_rule;
/


INSERT INTO CIFX.TB_COL_BUSINESS_RULE (COL_ID, COLUMN_CODE, TX_ID, SENDER_CODE, CERT_TYPE, CHANGE_TYPE, RULE_ID,
                                         RULE_PROCESS)
  VALUES (
118
  , 'X0142', 'A12301', null, null, null, 'V_056', 'PG_DYNC_VALI.SP_V_056');


COMMIT;
/

select CMPE_COMM_CONTENT
from cifx.tb_customer
where CMPE_COMM_CONTENT is not null
;
/
