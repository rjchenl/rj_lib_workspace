--*************************************************************************
--Author:季函提供
--Purpose:統編改號sp
--*************************************************************************

DECLARE
  I_MES_NUM VARCHAR2(200);
  I_TRA_SEQ VARCHAR2(200);
  I_TRA_DAT_TIM VARCHAR2(200);
  I_SEN_COD VARCHAR2(200);
  I_REC_COD VARCHAR2(200);
  I_TEL_EMP_NUM VARCHAR2(200);
  I_PRO_UNI VARCHAR2(200);
  I_SUP_EMP_NUM VARCHAR2(200);
  I_FUN_ID VARCHAR2(200);
  I_EDLS_ORI_TRADE_SEQ_NO VARCHAR2(10);
  I_EDLS_SOURCE_CODE VARCHAR2(6);
  I_EDLS_SUPERVISOR_CARD_CODE VARCHAR2(36);
  I_VER_ID_BEFORE VARCHAR2(200);
  I_BIR_BEFORE VARCHAR2(200);
  I_VER_ID_AFTER VARCHAR2(200);
  I_BIR_AFTER VARCHAR2(200);
  I_OP VARCHAR2(200);
  I_ACC VARCHAR2(200);
  O_RES_COD VARCHAR2(200);
  O_RES_DES VARCHAR2(200);
  O_ERR_MES VARCHAR2(200);
  O_CIRCI VARCHAR2(200);
BEGIN
  I_MES_NUM                   := 'frjj_TestSP_CHG_CUST_ID';
--  I_TRA_SEQ                   := 'TS0108_TS0116_'||TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
  I_TRA_SEQ                   := 'A149023';
  I_TRA_DAT_TIM               := TO_CHAR(SYSDATE, 'YYYYMMDD HH24MISS');
  I_SEN_COD                   := 'TS0108';
  I_REC_COD                   := 'TS0116';
  I_TEL_EMP_NUM               := '12345';
  I_PRO_UNI                   := '9999';
  I_SUP_EMP_NUM               := '54321';
  I_FUN_ID                    := '04';
  I_EDLS_ORI_TRADE_SEQ_NO     := ' 991234';
  I_EDLS_SOURCE_CODE          := 'TS0077';
  I_EDLS_SUPERVISOR_CARD_CODE := '991234';
  I_VER_ID_BEFORE := 'A145660698';--A
  I_BIR_BEFORE := '19771010';
  I_VER_ID_AFTER := 'A151144963';--B
  I_BIR_AFTER := '19771010';
  I_OP := '3';
  I_ACC := 'TEST';

DBMS_OUTPUT.PUT_LINE(' ===================== 改號sp開始 ===============');
  PG_CIFX_TO_EDLS_EXE.SP_CHG_CUST_ID(
    I_MES_NUM => I_MES_NUM,
    I_TRA_SEQ => I_TRA_SEQ,
    I_TRA_DAT_TIM => I_TRA_DAT_TIM,
    I_SEN_COD => I_SEN_COD,
    I_REC_COD => I_REC_COD,
    I_TEL_EMP_NUM => I_TEL_EMP_NUM,
    I_PRO_UNI => I_PRO_UNI,
    I_SUP_EMP_NUM => I_SUP_EMP_NUM,
    I_FUN_ID => I_FUN_ID,
    I_EDLS_ORI_TRADE_SEQ_NO => I_EDLS_ORI_TRADE_SEQ_NO,
    I_EDLS_SOURCE_CODE => I_EDLS_SOURCE_CODE,
    I_EDLS_SUPERVISOR_CARD_CODE => I_EDLS_SUPERVISOR_CARD_CODE,
    I_VER_ID_BEFORE => I_VER_ID_BEFORE,
    I_BIR_BEFORE => I_BIR_BEFORE,
    I_VER_ID_AFTER => I_VER_ID_AFTER,
    I_BIR_AFTER => I_BIR_AFTER,
    I_OP => I_OP,
    I_ACC => I_ACC,
    O_RES_COD => O_RES_COD,
    O_RES_DES => O_RES_DES,
    O_ERR_MES => O_ERR_MES,
    O_CIRCI => O_CIRCI
  );
    COMMIT;  --測試時要開啟 (因為營運交易是由edls控制)

  DBMS_OUTPUT.PUT_LINE('O_RES_COD = ' || O_RES_COD);
  DBMS_OUTPUT.PUT_LINE('O_RES_DES = ' || O_RES_DES);
  DBMS_OUTPUT.PUT_LINE('O_ERR_MES = ' || O_ERR_MES);
  DBMS_OUTPUT.PUT_LINE(' ===================== 改號sp結束 ===============');
END;


