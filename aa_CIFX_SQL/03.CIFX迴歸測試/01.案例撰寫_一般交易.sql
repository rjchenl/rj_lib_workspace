---------------------- 單筆case_id案例 ============
SELECT *
FROM AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
WHERE CASE_ID = 'TS0116-queryCustContact-0001'
;

DELETE AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
where CASE_ID = 'TS0116-queryCustContact-0001'
;
COMMIT;

--新增測試案例
INSERT INTO AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP (CASE_ID, SYNOPSIS, HOST_NAME, PORT_NUMBER, PATH, VERIFY_RULE,
                                                  REQUEST_BODY, PREREQUISITE, TEST_GROUP, ORDER_INDEX, VERIFY_DB,
                                                  INITIAL_DB_SCRIPT, DISABLE, TEARDOWN_DB_SCRIPT, STATUS, RELEASE_DATE,
                                                  INFOASSETSNO, TXID, ISSUE_TRACKING)
VALUES ('TS0116-queryCustContact-0001',    --TODO CASE_ID
        '顧客聯絡方式查詢（匯款集中）新服務',                                 --TODO SYNOPSIS
        'cifx-controller-a-reg.apps.ocp-sit1.testesunbank.com.tw',  --HOST_NAME
        443,   --PORT_NUMBER
        '/cifx/queryCustContact',  --PATH  --TODO
        '{ "resultCode": "0000", "resultDescription": "交易成功"}',  --VERIFY_RULE
        '{"header": {
    "msgNo": "#Sequence_Number",
    "txnCode": "queryCustContact  ",
    "senderCode": "TS0141",
    "receiverCode": "TS0116",
    "txnTime": "#yyyy-MM-dd HH:mm:ss",
    "operatorCode": "99538",
    "unitCode": "9915",
    "authorizerCode": "rjchenl"
  },
 "requestBody": {
		"header": {
			"acDate": null,
			"acDateROC": null,
			"bitMap": null,
			"cashier": null,
			"collectingBranch": null,
			"communicationSeqNo": "U89878",
			"infoAssetsNo": "TS9999",
			"irSeqNo": "0000",
			"isHoliday": null,
			"isNextDateAccount": null,
			"length": null,
			"mac": null,
			"macData": null,
			"mType": null,
			"nextTradeSeqNo": null,
			"oriTradeSeqNo": "U89878",
			"tradeAttribution1": "0",
			"tradeAttribution2": "1",
			"tradeAttribution3": "1",
			"tradeAttribution4": " ",
			"tradeSeqNoInAP": "U89878 ",
			"tradingSummary": null,
			"txId": "V185 ",
			"txIdInAP": "V185 ",
			"txSystem": null,
			"userType": null,
			"uuid": "        ",
			"customerInfo": {
				"customerClub": null,
				"cik": null,
				"moneyLaunderingMarker": null,
				"specificMemberFlag": null
			},
			"teller": {
				"tellerId": "  ",
				"operateId": "",
				"supervisorId": "     ",
				"supervisorCardCode": null,
				"tradeSeqNo": null,
				"centralizeMark": null
			},
			"branch": {
				"branchCode": "9915",
				"signStatus": null
			},
		},
		"model": {
			"customerCirciKey": "Y214278821"
		},
		"optional": {
			"forceUpdate": null
		}
	}
}',
        null,      --PREREQUISITE
        'CIFX_RJ', --TEST_GROUP
        001,       --TODO 序號
        'N',       --TODO VERIFY_DB
        '',        --TODO INITIAL_DB_SCRIPT  尾巴可以有分號
        'N',       --DISABLE
        '',        --TODO TEARDOWN_DB_SCRIPT 尾巴可以有分號
        'R',       --STATUS
        sysdate,   --RELEASE_DATE
        'TS0141',  --INFOASSETSNO
        'queryCustContact'   --TXID
        , null                  --ISSUE_TRACKING
        );

COMMIT;

--確認寫入成功
SELECT *
FROM AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
WHERE CASE_ID = 'TS0116-updateSmsPasswordForDigital-0004'
;

select * from AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
where test_group = 'CIFX_RJ2'
-- AND INITIAL_DB_SCRIPT IS NOT NULL
-- where test_group = 'CIFX'
--and synopsis = '顧客整合開戶建檔'
;

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


