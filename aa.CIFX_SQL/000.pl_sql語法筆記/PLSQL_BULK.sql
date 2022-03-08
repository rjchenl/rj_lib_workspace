DECLARE
--===========================================
--語法說明:
-- 動態SQL 回傳多個值(BULK物件)
--===========================================
--接使用EXECUTE IMMEDIATE 回傳BULK型態
  TYPE T_KYC_TYPE_CODE IS TABLE OF CIFX.TB_CUST_KYC.KYC_TYPE_CODE%TYPE INDEX BY PLS_INTEGER;
  v_bulk_kyc_type_code  T_KYC_TYPE_CODE;

  v_kyc_sql VARCHAR2(3000 CHAR) := '';

BEGIN
v_kyc_sql := 'SELECT KYC_TYPE_CODE FROM CIFX.TB_CUST_KYC  WHERE CIRCI_KEY = ''T164765248''';
DBMS_OUTPUT.PUT_LINE('v_kyc_sql:' || v_kyc_sql);
EXECUTE IMMEDIATE v_kyc_sql  BULK COLLECT INTO v_bulk_kyc_type_code;
                for m in 1..v_bulk_kyc_type_code.count
                loop
                DBMS_OUTPUT.PUT_LINE('v_bulk_kyc_type_code:'||v_bulk_kyc_type_code(m));
                end loop;
END;
/

DECLARE
--===========================================
--語法說明:
-- 一般BULK 操作
--===========================================
TYPE T_FETCH_TABLE IS TABLE OF CIFX.TB_CUSTOMER%ROWTYPE;
V_CUSTOMER_BULK T_FETCH_TABLE;
BEGIN
DBMS_OUTPUT.PUT_LINE('==========FUNCTION START===========');
SELECT * BULK COLLECT INTO V_CUSTOMER_BULK
FROM CIFX.TB_CUSTOMER FETCH FIRST 10 ROWS ONLY;


--可用COUNT來看是否有資料
IF V_CUSTOMER_BULK.COUNT != 0 THEN
    --逐筆取得資料
    FOR i IN V_CUSTOMER_BULK.FIRST..V_CUSTOMER_BULK.LAST
    LOOP
    DBMS_OUTPUT.PUT_LINE('V_CUSTOMER_BULK(i).CIF_VERIFIED_ID:' || V_CUSTOMER_BULK(i).CIF_VERIFIED_ID);
    END LOOP;
END IF;

END;
/