---------------------- 單筆case_id案例 ============
SELECT *
FROM AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
WHERE CASE_ID = 'TS0116-V587-0002'
;


--單筆案例執行結果
SELECT *
FROM AUTO_TEST.TB_CIFX_AUTO_TEST_RESULT_OCP
WHERE CASE_ID IN ('TS0116-V587-0001')
ORDER BY TX_DATE DESC;




--insert DB assertion
INSERT INTO AUTO_TEST.TB_CIFX_AUTO_TEST_DB_ASSERTION (CASE_ID, DESCRIPTION, VERIFY_RULE, QUERY_STRING)
VALUES ('TS0116-V185-0001', '顧客聯絡方式查詢（匯款集中）', '[{"TXNP_COMM_CONTENT":"092222222"}]',
        'select TXNP_COMM_CONTENT from cifx.tb_customer cust where cust.cif_verified_id = ''Y155134971'';');


--DB assertion
select *
from AUTO_TEST.TB_CIFX_AUTO_TEST_DB_ASSERTION
where CASE_ID = 'TS0116-N1536-0002';


-- "mobilePhoneNumberForSmsTrade":"092222222"
--更新案例 電文
update AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
set VERIFY_RULE = '{ "resultCode": "0000", "resultDescription": " 交易成功","mobilePhoneNumberForSmsTrade":"092222222" }'
where case_id = 'TS0116-V185-0001';
COMMIT;
--更新案例 電文
update AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
set path = '/cifx/queryRegisteredEventCodeForEB'
where case_id = 'TS0116-QueryRegisteredEventCodeForEB-0001';
COMMIT;



update AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
set INITIAL_DB_SCRIPT = 'INSERT INTO CIFX.TB_CUST_KYC (CUST_KYC_ID, CIRCI_KEY, CUSTOMER_ID, KYC_TYPE_CODE) VALUES (''1629111540014705-3308608-31-09'', ''Y121315462'', ''1629119146449013-3318374-61-02'', ''C5'');
commit;'
where CASE_ID = 'TS0116-VC05-0001';
COMMIT;


--刪除案例
delete AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
where case_id = 'TS0116-VT814-0001';
commit;


--更新案例 驗證規則
update AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
set VERIFY_RULE = '{ "resultCode": "S075", "resultDescription": "此顧客已辦理停止蒐集處理利用個人資料"}'
where case_id = 'TS0116-A12105-0002';
commit;


--=================== by case id 改為regression環境測試 ==========================
UPDATE AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
--CIFX_UPDATE
SET TEST_GROUP  = 'CIFX_RJ',
    HOST_NAME   = 'cifx-controller-a-reg.apps.ocp-sit1.testesunbank.com.tw',
    PORT_NUMBER = '443'
WHERE CASE_ID IN ('TS0116-V587-0001');

COMMIT;

--=================== by case id改為本地測試 ==========================
UPDATE AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
SET TEST_GROUP  = 'CIFX_RJ_TESTING',
    HOST_NAME   = 'localhost',
    PORT_NUMBER = '8443'
WHERE CASE_ID IN ('TS0116-V587-0002');
COMMIT;
--=========================== 確認測試目標為1 筆 ==============

SELECT *
FROM AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
WHERE TEST_GROUP = 'CIFX_RJ_TESTING';


--================== 本地執行JMETER =====================
UPDATE AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
SET TEST_GROUP = 'CIFX_RJ_TESTING'
WHERE CASE_ID IN ('TS0116-QueryRegisteredEventCodeForEB-0001');
COMMIT;
--================== 還原執行JMETER =====================

UPDATE AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
SET TEST_GROUP = 'CIFX_RJ'
WHERE CASE_ID IN ('TS0116-VT814-0001');
COMMIT;



-- --==================平行查看CASE 與執行結果================
-- SELECT
-- --CASEE.*
-- -- RT.*
-- CASEE.CASE_ID,
-- RT.IS_PASS,
-- RT.ERROR_MESSAGE,
-- CASEE.VERIFY_RULE,
-- CASEE.REQUEST_BODY,
-- CASEE.VERIFY_RULE AS EXPECTED_VALUE,
-- CASEE.PATH        AS URL_PATH,
-- RT.RESULT_CODE    AS ACUTAL_VALUE
--
-- FROM AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP CASEE
--          JOIN AUTO_TEST.TB_CIFX_AUTO_TEST_RESULT_OCP RT ON CASEE.CASE_ID = RT.CASE_ID
-- WHERE 1 = 1
-- -- AND CASEE.TEST_GROUP = 'CIFX_RJ'
-- --AND RT.IS_PASS = 'F'
--   AND CASEE.CASE_ID = 'TS0116-A101011-0100'
-- ORDER BY RT.TX_DATE DESC;
-- ;


--============================================


--新增測試案例
INSERT INTO AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP (CASE_ID, SYNOPSIS, HOST_NAME, PORT_NUMBER, PATH, VERIFY_RULE,
                                                  REQUEST_BODY, PREREQUISITE, TEST_GROUP, ORDER_INDEX, VERIFY_DB,
                                                  INITIAL_DB_SCRIPT, DISABLE, TEARDOWN_DB_SCRIPT, STATUS, RELEASE_DATE,
                                                  INFOASSETSNO, TXID, ISSUE_TRACKING)
VALUES ('TS0116-V587-0002', '顧客語音客服語音密碼註銷', 'cifx-controller-a-reg.apps.ocp-sit1.testesunbank.com.tw', 443,
        '/cifx/cancelVoicePassword', '{ "resultCode": "0000", "resultDescription": "交易成功"}', '{
  "header": {
    "msgNo": "#Sequence_Number",
    "txnCode": "V185",
    "senderCode": "TS0077",
    "receiverCode": "TS0108",
    "txnTime": "#yyyy-MM-dd HH:mm:ss",
    "operatorCode": "99999",
    "unitCode": "0598",
    "authorizerCode": "rjchenl"
  },
	"requestBody": {
		"header": {
			"acDate": null,
			"acDateROC": null,
			"bitMap": null,
			"cashier": null,
			"collectingBranch": null,
			"communicationSeqNo": null,
			"counterRegionType": null,
			"ctl": null,
			"deviceName": null,
			"deviceTypeNo": null,
			"element": null,
			"errorMessage": null,
			"fromAccountNo": null,
			"globalNo": null,
			"headerType": null,
			"infoAssetsNo": "TS0112",
			"irSeqNo": null,
			"isHoliday": null,
			"isNextDateAccount": null,
			"length": null,
			"mac": null,
			"macData": null,
			"mType": " ",
			"nextTradeSeqNo": null,
			"oriTradeSeqNo": "#Sequence_Number",
			"password": "    ",
			"pCode": null,
			"processType": " ",
			"referenceNumber": null,
			"region": "MPP09ESB ",
			"returnCode": null,
			"reverseTradeSeqNo": "       ",
			"row4": null,
			"rsv": null,
			"signatureData": null,
			"syncData": null,
			"systemDate": null,
			"systemDateROC": null,
			"systemTime": null,
			"tradeDateInAP": "        ",
			"tradeTimeInAP": "      ",
			"toAccountNo": null,
			"tradeAttribution1": null,
			"tradeAttribution2": null,
			"tradeAttribution3": null,
			"tradeAttribution4": null,
			"tradeSeqNoInAP": null,
			"tradingSummary": null,
			"txId": "V587   ",
			"txIdInAP": "V587   ",
			"txSystem": "4",
			"userType": " ",
			"uuid": null,
			"workStationId": null,
			"customerInfo": {
				"customerClub": null,
				"cik": "                    ",
				"moneyLaunderingMarker": null,
				"specificMemberFlag": null
			},
			"teller": {
				"tellerId": "     ",
				"operateId": "  ",
				"supervisorId": null,
				"supervisorCardCode": null,
				"tradeSeqNo": null,
				"centralizeMark": null
			},
			"branch": {
				"branchCode": "9915",
				"signStatus": null
			},
			"oriInData": "MPP09ESB V587   mvqwDq34                                                                                                                                                                                                                                                                                             Q111080321",
			"msgCode": null,
			"sys": null,
			"msgType": null,
			"dateTime": null,
			"localDate": null,
			"localTime": null,
			"EAITradeSeqNo": null,
			"EJVLD": null,
			"EAITxId": null
		},
		"model": {
			"customerCirciKey": "Y107857936",
			"accountNumber": "             "
		},
		"optional": {
			"forceUpdate": null
		}
	}

}', null, 'CIFX_RJ', 001, 'Y', '', 'N', '', 'R', TO_DATE('2021-10-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'TS0052',
        'VT587', null);

COMMIT;
select * from AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
where test_group = 'CIFX_RJ'
--and synopsis = '顧客整合開戶建檔'
;