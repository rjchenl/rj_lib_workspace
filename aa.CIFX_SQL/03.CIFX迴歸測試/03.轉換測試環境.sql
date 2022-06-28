

--=================== by case id改為本地測試 ==========================
UPDATE AUTO_TEST.TB_CIFX_AUTO_TEST_CASE_OCP
SET TEST_GROUP  = 'CIFX_RJ_TESTING',
    HOST_NAME   = 'localhost',
    PORT_NUMBER = '8443'
WHERE CASE_ID IN ('TS0116-queryCustContact-0001');  --改這邊
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


