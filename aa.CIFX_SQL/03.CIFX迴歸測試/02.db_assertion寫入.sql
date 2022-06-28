
--insert DB assertion TODO 注意:尾巴不可以有分號
INSERT INTO AUTO_TEST.TB_CIFX_AUTO_TEST_DB_ASSERTION (CASE_ID, DESCRIPTION, VERIFY_RULE, QUERY_STRING)
VALUES ('TS0116-updateSmsPasswordForDigital-0004', '簡訊密碼維護', '[{"TXNP_COMM_CONTENT":"0988333333"}]',
        'select TXNP_COMM_CONTENT from cifx.tb_customer cust where cust.cif_verified_id = ''A233075994''');
-- ROLLBACK;
COMMIT;


--確認DB assertion
select *
from AUTO_TEST.TB_CIFX_AUTO_TEST_DB_ASSERTION
where CASE_ID = 'TS0116-updateSmsPasswordForDigital-0004'
;


--修正DB assertion
update AUTO_TEST.TB_CIFX_AUTO_TEST_DB_ASSERTION
set VERIFY_RULE = '[{"OTP_SERVICE":"null"}]'
where CASE_ID = 'TS0116-updateSmsPasswordForDigital-0003'
;
commit;


select *
from AUTO_TEST.TB_CIFX_AUTO_TEST_DB_ASSERTION
where CASE_ID like  '%TS0116-updateSmsPasswordForDigital-000%'
;