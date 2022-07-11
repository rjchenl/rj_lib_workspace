
DECLARE
CURSOR RJ_CURSOR IS (
SELECT KYC_TYPE_CODE FROM CIFX.TB_CUST_KYC  WHERE CIRCI_KEY = 'T164765248'
);
CURSOR RJ_CURSOR2 IS (
SELECT KYC_TYPE_CODE,circi_key FROM CIFX.TB_CUST_KYC  WHERE CIRCI_KEY = 'T164765248'
);
CURSOR RJ_CURSOR3 IS (
SELECT * FROM CIFX.TB_CUST_KYC  WHERE CIRCI_KEY = 'T164765248'
);
--===RECOCD的宣告
v_record_cursor  RJ_CURSOR2%ROWTYPE;    --針對cursor,cursor需在之前宣告
v_record_table CIFX.tb_cust_kyc%ROWTYPE;  --針對table
BEGIN

DBMS_OUTPUT.PUT_LINE('使用顯式CURSOR');
--USING EXPLICIT CURSOR
FOR v_record IN RJ_CURSOR LOOP --說明:FOR迴圈的RECORD不需要宣告
DBMS_OUTPUT.PUT_LINE('CURSOT_FOR_LOOP DEMO1 '||v_record.KYC_TYPE_CODE||','||v_record.KYC_TYPE_CODE);
END LOOP;

DBMS_OUTPUT.PUT_LINE('使用隱式CURSOR');
--USING IMPLICIT CURSOR
FOR v_record2 IN (SELECT KYC_TYPE_CODE FROM CIFX.TB_CUST_KYC  WHERE CIRCI_KEY = 'T164765248')LOOP --說明:FOR迴圈的RECORD不需要宣告
DBMS_OUTPUT.PUT_LINE('CURSOT_FOR_LOOP DEMO1 '||v_record2.KYC_TYPE_CODE||','||v_record2.KYC_TYPE_CODE);
END LOOP;


--===========使用LOOP來提取CURSOR資料(賦值record)================

  OPEN RJ_CURSOR2;  --開啟游標
    LOOP    --常搭配LOOP使用
      FETCH RJ_CURSOR2 INTO v_record_cursor; --提取游標至CURSOR定義的RECORD
      EXIT WHEN RJ_CURSOR2%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('資料'||' :'||v_record_cursor.circi_key||','||v_record_cursor.kyc_type_code);

    END LOOP;
  CLOSE RJ_CURSOR2; --關閉游標

    OPEN RJ_CURSOR3;  --開啟游標
     LOOP    --常搭配LOOP使用
      FETCH RJ_CURSOR3 INTO v_record_table; --提取游標取游標至TABLE定義的RECORD
      EXIT WHEN RJ_CURSOR3%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('資料2'||' :'||v_record_cursor.circi_key||','||v_record_cursor.kyc_type_code);

    END LOOP;
  CLOSE RJ_CURSOR3; --關閉游標

END;
/