--SP_CHG_INDIVIDUAL_SETTLE_FLAG
declare

      I_MES_NUM  VARCHAR2(100 char) := 'TestSP_CHG_INDIVIDUAL_SETTLE_FLAG';
    I_TRA_SEQ     varchar2(100 char) :='TS0108_TS0116_20201118134622';
    I_TRA_DAT_TIM varchar2(100 char) :='20201118 134622';
    I_SEN_COD     varchar2(100 char) :='TS0108';
    I_REC_COD     varchar2(100 char) :='TS0116';
    I_TEL_EMP_NUM varchar2(100 char) :='12345';
    I_PRO_UNI     varchar2(100 char) :='9999';
    I_SUP_EMP_NUM varchar2(100 char) :='54321';
    I_FUN_ID      varchar2(100 char) :='02';
    I_CIR_KEY     varchar2(100 char) :='A123456789';
    I_IND_SET_FLA varchar2(100 char) :='02';   --此註記
    I_EDLS_ORI_TRADE_SEQ_NO      TB_CHANGE_LOG.EDLS_ORI_TRADE_SEQ_NO%TYPE := '991234';
    I_EDLS_SOURCE_CODE           TB_CHANGE_LOG.EDLS_SOURCE_CODE%TYPE := 'TS0077';
    I_EDLS_SUPERVISOR_CARD_CODE  TB_CHANGE_LOG.SUPERVISOR_CARD_CODE%TYPE := '991234';

    O_RES_COD varchar2(100 char) :='';
    O_RES_DES varchar2(100 char) :='';
    O_ERR_MES varchar2(100 char) :='';

begin
    
    DBMS_OUTPUT.PUT_LINE('==================== SP_CHG_INDIVIDUAL_SETTLE_FLAG start ===================');
    CIFX.SP_CHG_INDIVIDUAL_SETTLE_FLAG(
    I_MES_NUM => I_MES_NUM,
    I_TRA_SEQ => I_TRA_SEQ,
    I_TRA_DAT_TIM => I_TRA_DAT_TIM,
    I_SEN_COD => I_SEN_COD,
    I_REC_COD => I_REC_COD,
    I_TEL_EMP_NUM => I_TEL_EMP_NUM,
    I_PRO_UNI => I_PRO_UNI,
    I_SUP_EMP_NUM => I_SUP_EMP_NUM,
    I_FUN_ID => I_FUN_ID,
    I_CIR_KEY => I_CIR_KEY,
    I_IND_SET_FLA => I_IND_SET_FLA,  --chr18 是清空
    I_EDLS_ORI_TRADE_SEQ_NO     =>I_EDLS_ORI_TRADE_SEQ_NO,
    I_EDLS_SOURCE_CODE          =>I_EDLS_SOURCE_CODE,
    I_EDLS_SUPERVISOR_CARD_CODE =>I_EDLS_SUPERVISOR_CARD_CODE,
    O_RES_COD => O_RES_COD,
    O_RES_DES => O_RES_DES,
    O_ERR_MES => O_ERR_MES
  );

    DBMS_OUTPUT.PUT_LINE('==================== SP_CHG_INDIVIDUAL_SETTLE_FLAG end ===================');

    --查有效值
-- SELECT *
-- FROM CIFX.TB_KEY_VALUE_CODE
-- WHERE CODE_CATEGORY = 'individual_settlement_flag'
--   ;




end;