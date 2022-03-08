declare
--===== CURSOR部份 =====
--系統cursor
v_cursor SYS_REFCURSOR;
--自定義cursor
CURSOR v_rj_cursor is (SELECT CIF_VERIFIED_ID,CUST_NAME FROM CIFX.TB_CUSTOMER WHERE CIF_VERIFIED_ID = 'A123456789');

--===== RECORED部份 =====
v_tb_customer cifx.tb_customer%rowtype;
TYPE t_test_record IS RECORD(
CIF_VERIFIED_ID cifx.tb_customer.cif_verified_id%type,
CUST_NAME cifx.tb_customer.cust_name%type
);
v_rj_record t_test_record;

  --================== 內部函式 start ==========================
 FUNCTION FN_RJ_CURSOR_ALL_COLUMN_TEST(I_IN IN VARCHAR2)
 RETURN CIFX.PG_DAO_TYPES.REF_CURSOR
 IS
 RESULT_CUR CIFX.PG_DAO_TYPES.REF_CURSOR;
 V_CURSOR sys_refcursor;
 BEGIN
 DBMS_OUTPUT.PUT_LINE('I_IN:' || I_IN);
 OPEN RESULT_CUR FOR
 SELECT * FROM CIFX.TB_CUSTOMER WHERE CIF_VERIFIED_ID = 'A123456789';
 return RESULT_CUR;
 END FN_RJ_CURSOR_ALL_COLUMN_TEST;



  PROCEDURE SP_RJ_CUSRSOR_ALL_COLUMN_TEST(I_IN VARCHAR2,O_CURSOR OUT SYS_REFCURSOR)
  IS
  BEGIN
  DBMS_OUTPUT.PUT_LINE('I_IN:' || I_IN);
  OPEN O_CURSOR FOR
  SELECT * FROM CIFX.TB_CUSTOMER WHERE CIF_VERIFIED_ID = 'A123456789';
  END SP_RJ_CUSRSOR_ALL_COLUMN_TEST;


  FUNCTION FN_RJ_CURSOR_PARTITAL_COLUMN_TEST(I_IN IN VARCHAR2)
  RETURN CIFX.PG_DAO_TYPES.REF_CURSOR
  IS
  RESULT_CUR CIFX.PG_DAO_TYPES.REF_CURSOR;
  BEGIN
  OPEN RESULT_CUR FOR
  SELECT CIF_VERIFIED_ID,CUST_NAME FROM CIFX.TB_CUSTOMER WHERE CIF_VERIFIED_ID = 'A123456789';
  return RESULT_CUR;
  END FN_RJ_CURSOR_PARTITAL_COLUMN_TEST;

  PROCEDURE  SP_RJ_CURSOR_PARTITAL_COLUMN_TEST(I_IN VARCHAR2,O_CURSOR OUT SYS_REFCURSOR)
  IS
  BEGIN
  OPEN O_CURSOR FOR
  SELECT CIF_VERIFIED_ID,CUST_NAME FROM CIFX.TB_CUSTOMER WHERE CIF_VERIFIED_ID = 'A123456789';
  END SP_RJ_CURSOR_PARTITAL_COLUMN_TEST;

  --================== 內部函式 end ==========================

begin


DBMS_OUTPUT.PUT_LINE('====== 測試接FUNCTION CURSOR 整筆資料 START =========');
v_cursor := FN_RJ_CURSOR_ALL_COLUMN_TEST(I_IN => '456');
loop
fetch v_cursor into v_tb_customer;
 EXIT WHEN v_cursor%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE('v_tb_customer.cif_verified_id :' || v_tb_customer.cif_verified_id);
end loop;
DBMS_OUTPUT.PUT_LINE('====== 測試接FUNCTION CURSOR 整筆資料 END =========');

DBMS_OUTPUT.PUT_LINE('====== 測試接PROCEDURE CURSOR 整筆資料 START =========');
 SP_RJ_CUSRSOR_ALL_COLUMN_TEST( I_IN => '456',
                                O_CURSOR => v_cursor);
loop
fetch v_cursor into v_tb_customer;
 EXIT WHEN v_cursor%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE('v_tb_customer.cif_verified_id :' || v_tb_customer.cif_verified_id);
end loop;
DBMS_OUTPUT.PUT_LINE('====== 測試接PROCEDURE CURSOR 整筆資料 END =========');

--EDLS_REGRESSION_AUTO_TEST


DBMS_OUTPUT.PUT_LINE('====== 測試接FUNCTION CURSOR 部份資料 START =========');
v_cursor := FN_RJ_CURSOR_PARTITAL_COLUMN_TEST(I_IN => '456');
loop
fetch v_cursor into v_rj_record;
 EXIT WHEN v_cursor%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE('v_rj_record.cif_verified_id :' || v_rj_record.cif_verified_id);
 DBMS_OUTPUT.PUT_LINE('v_rj_record.CUST_NAME :' || v_rj_record.CUST_NAME);
end loop;

DBMS_OUTPUT.PUT_LINE('====== 測試接FUNCTION CURSOR 部份資料 END =========');



DBMS_OUTPUT.PUT_LINE('====== 測試接PROCEDURE CURSOR 部份資料 START =========');
SP_RJ_CURSOR_PARTITAL_COLUMN_TEST(I_IN  => '123' ,
                                            O_CURSOR => v_cursor);
--使用系統CURSOR不需要打開與關閉
loop
fetch v_cursor into v_rj_record;
 EXIT WHEN v_cursor%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE('v_rj_record.cif_verified_id :' || v_rj_record.cif_verified_id);
 DBMS_OUTPUT.PUT_LINE('v_rj_record.CUST_NAME :' || v_rj_record.CUST_NAME);
end loop;
--使用自定義CURSOR 需要自行打開與關閉
open v_rj_cursor;  --自定義CURSOR ONLY
loop
fetch v_rj_cursor into v_rj_record;
 EXIT WHEN v_rj_cursor%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE('v_rj_record.cif_verified_id :' || v_rj_record.cif_verified_id);
 DBMS_OUTPUT.PUT_LINE('v_rj_record.CUST_NAME :' || v_rj_record.CUST_NAME);
end loop;
close v_rj_cursor; --自定義CURSOR ONLY
DBMS_OUTPUT.PUT_LINE('====== 測試接PROCEDURE CURSOR 部份資料 END =========');
end;