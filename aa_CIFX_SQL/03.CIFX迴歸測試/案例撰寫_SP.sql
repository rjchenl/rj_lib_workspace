--查看案例
select  * from AUTO_TEST.TB_CIFX_SP_EXE
where CASE_ID = 'TS0116-SP_CHG_CUST_TYPE-0004';



--查看案例
select  * from AUTO_TEST.TB_CIFX_SP_EXE
where CASE_ID like  '%TS0116-SP_CHG_CUST_TYPE-000%';



--還原案例
UPDATE  AUTO_TEST.TB_CIFX_SP_EXE
SET TEST_GROUP = 'CIFX_RJ'
WHERE CASE_ID = 'TS0116-SP_CHG_CUST_TYPE-0003';
COMMIT;


--準備測試
UPDATE  AUTO_TEST.TB_CIFX_SP_EXE
SET TEST_GROUP = 'CIFX_RJ_TESTING'
WHERE CASE_ID = 'TS0116-SP_CHG_CUST_TYPE-0002';
COMMIT;

--確認測試目標為1筆
SELECT *
FROM AUTO_TEST.TB_CIFX_SP_EXE
WHERE TEST_GROUP = 'CIFX_RJ_TESTING'
;


--寫入測試案例
INSERT INTO AUTO_TEST.TB_CIFX_SP_EXE (CASE_ID, SCHEMA_NAME, PKG_NAME, EXE_TYPE, SP_FN_NAME, ALLOW_EXECUTE,
                                      PUT_IN_PARA_JSON_TYPE, PUT_IN_PARA_JSON_VALUE, PUT_OUT_PARA_JSON_TYPE,
                                      EXPECTED_VALUE, INITIAL_SCRIPT, TEARDOWN_SCRIPT, TEST_GROUP, EXE_ORDER, SYNOPSIS)
VALUES ('TS0116-SP_CHG_INDIVIDUAL_SETTLE_FLAG-0001', 'CIFX', 'PG_CIFX_TO_EDLS_EXE', 'PROCEDURE',
        'SP_CHG_INDIVIDUAL_SETTLE_FLAG', 'Y',
        '{
	"1": "String",
	"2": "String",
	"3": "String",
	"4": "String",
	"5": "String",
	"6": "String",
	"7": "String",
	"8": "String",
	"9": "String",
	"10": "String",
	"11": "String",
	"12": "String",
	"13": "String",
	"14": "String"
}',
        '{
	"1": "TS0108TS0077202107309999 050007",
	"2": "#Sequence_Number",
	"3": "20201118 134622",
	"4": "TS0108",
	"5": "TS0116",
	"6": "97132",
	"7": "9999",
	"8": "54321",
	"9": "02",
	"10": "A123456789",
	"11": "02",
	"12": "991234",
	"13": "TS0077",
	"14": "991234"
}',
        '{
	"15": "VARCHAR",
	"16": "VARCHAR",
	"17": "VARCHAR"
}', '{"1":"0000"}', '', null,
        'CIFX_RJ_TESTING', '0001', '變更顧客【個別協商一致性方案註記】');

COMMIT;


--修正測試案例
update AUTO_TEST.TB_CIFX_SP_EXE
set INITIAL_SCRIPT =  'UPDATE CIFX.TB_CUSTOMER
SET customer_type_code=''02''
WHERE CIF_VERIFIED_ID=''C836137968''; '
where case_id = 'TS0116-SP_CHG_CUST_TYPE-0001'
;


--查看此次測試 執行結果
SELECT * FROM AUTO_TEST.TB_CIFX_SP_EXE_RESULT
where CASE_ID in (select case_id from AUTO_TEST.TB_CIFX_SP_EXE WHERE TEST_GROUP = 'CIFX_RJ_TESTING')
order by  TX_DATE desc
;

--查看此次測試 執行結果
SELECT result.*,exe.EXPECTED_VALUE FROM AUTO_TEST.TB_CIFX_SP_EXE_RESULT result
join AUTO_TEST.TB_CIFX_SP_EXE exe on exe.CASE_ID = result.CASE_ID
where result.CASE_ID in ('TS0116-SP_CHG_CUST_TYPE-0003')
order by  TX_DATE desc
;