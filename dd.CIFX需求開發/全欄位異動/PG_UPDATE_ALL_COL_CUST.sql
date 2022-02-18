--------------------------------------------------------
--  DDL for Package PG_UPDATE_ALL_COL_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CIFX"."PG_UPDATE_ALL_COL_CUST" AS
    test_ggg                          varchar2(100 char) := 'from';
      TYPE g_input_all_json_type IS RECORD (
                                     input_json                      cifx.TB_QUERY_TRX_MAPPING.OUT_PARA_NAME %TYPE,
                                     input_value                     VARCHAR2(200 CHAR),
                                     db_column_name                  cifx.TB_COLUMN_CODE.COLUMN_NAME         %TYPE,
                                     data_type                       VARCHAR2(50 CHAR)
                                 );
    TYPE g_input_json_table IS TABLE OF g_input_all_json_type INDEX BY cifx.TB_COLUMN_CODE.COLUMN_NAME%TYPE;
    g_input_model_tab                         g_input_json_table;

     PROCEDURE SP_UPDATE_ALL_COL_CUST(
     I_INPUT_JSON IN CLOB,
     I_SERVICE_INTERCHANGE_ID IN VARCHAR2,
     I_AP_SERVER_TO_EXEC      IN VARCHAR2,
     O_RESULT_CODE OUT varchar2,
     O_RESULT_DESC OUT varchar2
     );

END PG_UPDATE_ALL_COL_CUST;

/

  GRANT EXECUTE ON "CIFX"."PG_UPDATE_ALL_COL_CUST" TO "APCIFXT01";
  GRANT DEBUG ON "CIFX"."PG_UPDATE_ALL_COL_CUST" TO "APCIFXT01";
--------------------------------------------------------
--  DDL for Package Body PG_UPDATE_ALL_COL_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CIFX"."PG_UPDATE_ALL_COL_CUST" AS

    --*************************************************************************
    --Author:ESB18442
    --Purpose:大異動流程主體
    --*************************************************************************
   PROCEDURE SP_UPDATE_ALL_COL_CUST(
   I_INPUT_JSON IN CLOB,
   I_SERVICE_INTERCHANGE_ID IN VARCHAR2,
   I_AP_SERVER_TO_EXEC      IN VARCHAR2,
   O_RESULT_CODE OUT varchar2,
   O_RESULT_DESC OUT varchar2
   )
   IS
      jsb     json_object_t;
      model_jsb    json_object_t;
      jsb_key_list   json_key_list;
      model_key_jsb_key_list      json_key_list;
      v_json_model_clob  clob;

      input_cust_jo json_object_t := NEW JSON_OBJECT_T();

      v_indx_by_column_name varchar2(1000 char) := '';

     -- =========== 識別條件變數 =============
      v_customerCirciKey varchar2(100 char) := '';
      v_birthday varchar2(100 char) := '';
      v_customerCertificationNumber varchar2(100 char) := '';
      v_accountNumber varchar2(100 char) := '';

     -- 呼叫SP_VAL_COLUMN_VALUE回傳變數宣告
      V_OPT_COLUMN_CODE varchar2(3000 char) := '';
      V_R_RESULT  varchar2(3000 char) := '';
      V_R_RESULT_DESCRIPTION  varchar2(3000 char) := '';
      V_R_ERROR_MESSAGE varchar2(3000 char) := '';
      ---------------------------------------------
      -- 手續費優惠(SP_CHG_SERVICE_FEE_DISCOUNT)
      v_fee_discount_chg_result_code varchar2 (4 char);
      v_fee_discount_result_description varchar2 (100 char);
      v_fee_discount_err_msg varchar2 (1000 char);
            ----------------------------------------------
      --CIDVE 84,64事故
      v_cursor SYS_REFCURSOR;
      v_src_column_name CIFX.TB_COLUMN_CODE.COLUMN_NAME%TYPE;
      v_src_before_value CIFX.TB_CHANGE_LOG_LINEITEM.BEFORE_VALUE%TYPE;
      v_src_change_value CIFX.TB_CHANGE_LOG_LINEITEM.CHANGED_VALUE%TYPE;
      v_src_origin_value CIFX.TB_CHANGE_LOG_LINEITEM.CHANGED_VALUE%TYPE;
      v_src_branch_id CIFX.TB_CHANGE_LOG.BRANCH_ID%TYPE;
      v_residnetial_city   CIFX.TB_CUSTOMER.CONT_CITY%TYPE;
      v_residential_area   CIFX.TB_CUSTOMER.CONT_AREA%TYPE;
      v_residential_address_detail  CIFX.TB_CUSTOMER.CONT_ADDRESS_DETAIL%TYPE;
      v_customer_status   CIFX.TB_CUSTOMER.CUSTOMER_STATUS%TYPE;
      v_before_special_service_flag CIFX.TB_CUSTOMER.SPECIAL_SERVICE_FLAG%TYPE;
      v_before_otp_service CIFX.TB_CUSTOMER.OTP_SERVICE%TYPE;
      v_before_ivr_pwd_state_flag CIFX.TB_CUSTOMER.IVR_PWD_STATE_FLAG%TYPE;
      v_before_txnp_comm_content CIFX.TB_CUSTOMER.TXNP_COMM_CONTENT%TYPE;
      v_before_grown_up_guardian_ship  CIFX.TB_CUSTOMER.GROWN_UP_GUARDIAN_SHIP%TYPE;
      v_count_84    NUMBER(2) := 0;
      v_is_64    boolean := false;
      v_count_cidve_event number(2):= 0;
      v_cidve_result_code varchar2 (4 char);
      v_cidve_result_description varchar2 (100 char);
      v_cidve_err_msg varchar2 (1000 char);
      v_84_result varchar2 (4 char);
      v_64_result varchar2 (4 char);
	  v_64_result_description varchar2 (100 char);
      -----------------------------------------------
      --需從header取的之變數
      v_header_sender_code  varchar2 (3000 char) := '';
      v_tx_id               varchar2 (3000 char) := '';
      v_msg_no              varchar2 (3000 char) := '';
      v_branch_code         varchar2 (3000 char) := '';
      v_teller_id           varchar2 (3000 char) := '';
      v_ori_trade_seq_no    varchar2 (3000 char) := '';
      v_supervisor_card_code varchar2 (3000 char) := '';
      v_supervisor_code     varchar2 (3000 char) := '';

      v_column_name varchar2 (3000 char) := ''; --對應到json的資料庫欄位名稱
      v_column_value varchar2 (3000 char) := '';--json輸入的異動值
      v_sql varchar2(3000 char) := '';
      v_column_map_chk_count integer := 0 ;
      --承接大查詢
      v_cur  SYS_REFCURSOR; --系統游標
      V_RECIEIVE_CUSOTMER_ID_ARRAY INPUT_ARRAY := INPUT_ARRAY();  --初始化  回傳顧客customer_id array
      V_RECIEIVE_IDENFITIER_CONDITION_ARRAY INPUT_TB_VAR_ARRAY := INPUT_TB_VAR_ARRAY();  --初始化 回傳識別條件columnn array

      V_RECIEIVE_IDENFITIER_JSON_ARRAY  INPUT_TB_VAR_ARRAY := INPUT_TB_VAR_ARRAY();  --初始化(排除條件用)  識別條件json array
      v_fix_identifier_json_col  INPUT_TB_VAR_ARRAY := INPUT_TB_VAR_ARRAY();    --初始化(排除條件用)  固定識別條件json array

      v_tb_column_code_opt                    CIFX.TB_COLUMN_CODE_OPT%ROWTYPE:=null;
      v_sql_tmp_vli_proc clob:='';




      v_tx_resulst_code varchar2(100 char):= '';
      v_tx_resulst_desc varchar2(100 char):= '';

      v_customer_id varchar2(100 char) := '';

      -- 業務檢核 + 連動邏輯用
      -- 顧客主檔(變更前)
      v_tb_customer CIFX.TB_CUSTOMER%ROWTYPE;
      -- 顧客主檔(變更後)
      v_tb_customer_after CIFX.TB_CUSTOMER%ROWTYPE;


      v_update_column_array INPUT_TB_VAR_ARRAY := INPUT_TB_VAR_ARRAY(); --初始化   --最後異動欄位ARRAY
      v_ori_model_ja_col  INPUT_TB_VAR_ARRAY := INPUT_TB_VAR_ARRAY(); --初始化  原始model ARRAY

      TYPE v_map_type IS TABLE OF VARCHAR2(3000) INDEX BY VARCHAR2(3000);
      v_db_col_to_json_col_map v_map_type;--輸入顧客主檔欄位 回傳json變數名稱
      v_json_col_to_db_col_map v_map_type;--輸入json變數名稱 回傳顧客主檔欄位
      v_db_col_to_data_type_map   v_map_type;--輸入顧客主檔欄位 回傳dataType

      --接使用EXECUTE IMMEDIATE 回傳BULK型態
      TYPE bulk_db_col_name_type IS TABLE OF CIFX.tb_column_code_opt.column_Name%TYPE INDEX BY PLS_INTEGER;
      v_bulk_db_col_name  bulk_db_col_name_type;
      TYPE bulk_col_json_name_type IS TABLE OF CIFX.tb_column_code_opt.json_name%TYPE  INDEX BY PLS_INTEGER;
      v_bulk_col_json_name bulk_col_json_name_type;
      TYPE bulk_data_type_type IS TABLE OF CIFX.tb_column_code_opt.data_type%TYPE  INDEX BY PLS_INTEGER;
      v_bulk_data_type bulk_data_type_type;

      -- 輸入欄位業務檢核用
      v_cert_type varchar2(2 char):= '';
      v_change_type varchar2(1 char):= '';
      v_customerPropertyType varchar2(1 char):= '';

      -- 呼叫介接SP回傳結果
      v_return_code varchar2(4 char):= '';
      v_cert_type_return varchar2(2 char):= '';
      v_check_number varchar2(1 char):= '';

      v_test varchar2(3000 char) := '';

      --======================== 內部函數 =============================
      PROCEDURE SET_IDENTIFIER_CONDITION_VALUE
      IS
      BEGIN
      for i in 1..v_ori_model_ja_col.count
       loop
       if v_ori_model_ja_col(i) = 'customerCirciKey' or v_ori_model_ja_col(i) = 'birthday'
          or v_ori_model_ja_col(i) = 'customerCertificationNumber' or v_ori_model_ja_col(i) = 'accountNumber' then
            case v_ori_model_ja_col(i)
               when 'customerCirciKey' then
                 v_customerCirciKey := json_VALUE(v_json_model_clob,'$.' || v_ori_model_ja_col(i)  error on error );
               when 'birthday' then
                 v_birthday := json_VALUE(v_json_model_clob,'$.' || v_ori_model_ja_col(i)  error on error );
               when 'customerCertificationNumber' then
                 v_customerCertificationNumber := json_VALUE(v_json_model_clob,'$.' || v_ori_model_ja_col(i)  error on error );
               when 'accountNumber' then
                 v_accountNumber := json_VALUE(v_json_model_clob,'$.' || v_ori_model_ja_col(i)  error on error );
               else
                DBMS_OUTPUT.PUT_LINE(v_ori_model_ja_col(i) || '-> 無此對應');
            end case;
       end if;
       end loop;
      END SET_IDENTIFIER_CONDITION_VALUE;

      PROCEDURE FIND_ALL_COL_CUST
      IS
      BEGIN
      DBMS_OUTPUT.PUT_LINE('======================= 呼叫大查詢 start ===================');
--      test_ggg := '預設global 變數';
--      dbms_lock.sleep(10);
--      DBMS_OUTPUT.PUT_LINE('test_ggg :' || test_ggg);
              --呼叫大查詢查回顧客
              CIFX.PG_ALL_COL_QUERY_CUSTOMER.SP_FIND_ALL_COL_CUST(
                I_SENDER_CODE => v_header_sender_code,        --系統代碼
                I_CIF_VERIFIED_ID => v_customerCirciKey,    --銀行歸戶統編
                I_BIRTHDAY => v_birthday,           --顧客生日
                I_CIF_ORIGINAL_ID => v_customerCertificationNumber,    --原始證號
                I_ACCOUNT_NUMBER => v_accountNumber,     --帳號
                I_SKIP_STP_USE_FLAG => NULL ,  -- Y :跳過"停止個資利用" 檢核
                O_SYS_CURSOR => v_cur,
                O_CUSTOMER_ID_ARRAY => V_RECIEIVE_CUSOTMER_ID_ARRAY,
                O_CONDITION_ARRAY => V_RECIEIVE_IDENFITIER_CONDITION_ARRAY
              );
              --將回傳DB欄位ARRAY轉換為json array存起來
              for i in 1..V_RECIEIVE_IDENFITIER_CONDITION_ARRAY.count
              loop
                V_RECIEIVE_IDENFITIER_JSON_ARRAY.EXTEND();
                V_RECIEIVE_IDENFITIER_JSON_ARRAY(V_RECIEIVE_IDENFITIER_JSON_ARRAY.LAST) := v_db_col_to_json_col_map(V_RECIEIVE_IDENFITIER_CONDITION_ARRAY(i));
                DBMS_OUTPUT.PUT_LINE('大查詢回傳識別條件array:' || V_RECIEIVE_IDENFITIER_CONDITION_ARRAY(i));
              end loop;

              for i in 1..V_RECIEIVE_CUSOTMER_ID_ARRAY.count
              loop
              DBMS_OUTPUT.PUT_LINE('大查詢回傳customer_id:' || V_RECIEIVE_CUSOTMER_ID_ARRAY(i));
              end loop;

--               test_ggg := '預設global 變數 完成';
--               DBMS_OUTPUT.PUT_LINE('test_ggg :' || test_ggg);
             DBMS_OUTPUT.PUT_LINE('======================= 呼叫大查詢 end ===================');

      END FIND_ALL_COL_CUST;

      PROCEDURE COMPOSE_UPDATE_COLUMN_ARRAY
      IS
      BEGIN
          --model欄位array中 排除 此次查詢回傳之識別欄位
          for i in 1..v_ori_model_ja_col.count
          loop
             if v_ori_model_ja_col(i) not member of  V_RECIEIVE_IDENFITIER_JSON_ARRAY   --排除此次查詢回傳之識別欄位json array
             and v_ori_model_ja_col(i) not member of v_fix_identifier_json_col then     --排除固定識別欄位json array
              --加入至最後異動欄位update_column_array
              v_update_column_array.extend();
              v_update_column_array(v_update_column_array.last) := v_json_col_to_db_col_map(v_ori_model_ja_col(i));
             end if;
          end loop;
      END COMPOSE_UPDATE_COLUMN_ARRAY;

      PROCEDURE SET_DB_COLUMN_NAME_TO_JSON_NAME_MAPPING
      IS
      BEGIN
          v_sql := 'select column_name,json_name,data_type from cifx.tb_column_code_opt opt where opt.table_name = ' || ''''
           ||'TB_CUSTOMER' || '''' ;
           execute immediate v_sql  BULK COLLECT INTO v_bulk_db_col_name,v_bulk_col_json_name,v_bulk_data_type;
           for i in 1..v_bulk_db_col_name.count
           loop
             v_db_col_to_json_col_map(v_bulk_db_col_name(i)) := v_bulk_col_json_name(i);
             v_json_col_to_db_col_map(v_bulk_col_json_name(i)) := v_bulk_db_col_name(i);
             v_db_col_to_data_type_map(v_bulk_db_col_name(i))   := v_bulk_data_type(i);
           end loop;
      END SET_DB_COLUMN_NAME_TO_JSON_NAME_MAPPING;

      PROCEDURE SET_FIX_IDENTIFIER_JSON_ARRAY
      IS
      BEGIN
        if 'accountNumber' not member of v_fix_identifier_json_col then
          v_fix_identifier_json_col.extend();
          v_fix_identifier_json_col(v_fix_identifier_json_col.last) := 'accountNumber';
        end if;

        if 'customerCirciKey' not member of v_fix_identifier_json_col then
          v_fix_identifier_json_col.extend();
          v_fix_identifier_json_col(v_fix_identifier_json_col.last) := 'customerCirciKey';
        end if;

        if 'customerCertificationNumber' not member of v_fix_identifier_json_col then
          v_fix_identifier_json_col.extend();
          v_fix_identifier_json_col(v_fix_identifier_json_col.last) := 'customerCertificationNumber';
        end if;
      END SET_FIX_IDENTIFIER_JSON_ARRAY;

      PROCEDURE SET_INPUT_CUSTOMER_RECORD
      IS
      BEGIN
      for i in 1..model_key_jsb_key_list.count
                loop
--                    DBMS_OUTPUT.PUT_LINE('輸入 JSON變數欄位):' || model_key_jsb_key_list(i));
--                    DBMS_OUTPUT.PUT_LINE('輸入 資料庫欄位:' || v_json_col_to_db_col_map(model_key_jsb_key_list(i)));
--                    DBMS_OUTPUT.PUT_LINE('輸入 欄位值:' || model_jsb.get_string(model_key_jsb_key_list(i)));
--                    DBMS_OUTPUT.PUT_LINE('輸入  dataType:' || v_db_col_to_data_type_map(v_json_col_to_db_col_map(model_key_jsb_key_list(i))));
                    g_input_model_tab(v_json_col_to_db_col_map(model_key_jsb_key_list(i))).input_json := model_key_jsb_key_list(i);
                    g_input_model_tab(v_json_col_to_db_col_map(model_key_jsb_key_list(i))).input_value := model_jsb.get_string(model_key_jsb_key_list(i));
                    g_input_model_tab(v_json_col_to_db_col_map(model_key_jsb_key_list(i))).db_column_name := v_json_col_to_db_col_map(model_key_jsb_key_list(i));
                    g_input_model_tab(v_json_col_to_db_col_map(model_key_jsb_key_list(i))).data_type := v_db_col_to_data_type_map(v_json_col_to_db_col_map(model_key_jsb_key_list(i)));

                    --存放  資料庫欄位: 欄位值 關係
                    input_cust_jo.put(v_json_col_to_db_col_map(model_key_jsb_key_list(i)),model_jsb.get_string(model_key_jsb_key_list(i)));
                          if v_json_col_to_db_col_map(model_key_jsb_key_list(i))  is not null
                          and model_jsb.get_string(model_key_jsb_key_list(i)) is not null then
                                case v_json_col_to_db_col_map(model_key_jsb_key_list(i))
                                    when 'FIRST_TXN_DATE' then v_tb_customer_after.FIRST_TXN_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CREATION_DPT_CODE' then v_tb_customer_after.CREATION_DPT_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PRINCIPAL_CERT_NO' then v_tb_customer_after.PRINCIPAL_CERT_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'TAX_ID_NO' then v_tb_customer_after.TAX_ID_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'INDUSTRY_PROPS_TYPE_CODE' then v_tb_customer_after.INDUSTRY_PROPS_TYPE_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'INCOME_TAX_TYPE' then v_tb_customer_after.INCOME_TAX_TYPE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PRINCIPAL_NAME' then v_tb_customer_after.PRINCIPAL_NAME := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'BIRTHDAY' then v_tb_customer_after.BIRTHDAY := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'NATIONALITY' then v_tb_customer_after.NATIONALITY := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'GENDER_CODE' then v_tb_customer_after.GENDER_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'REG_COUNTRY_CODE' then v_tb_customer_after.REG_COUNTRY_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EVER_CHANGED_CERT_NO' then v_tb_customer_after.EVER_CHANGED_CERT_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'MERGE_BANK' then v_tb_customer_after.MERGE_BANK := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CENTER_BATCH_CREATION' then v_tb_customer_after.CENTER_BATCH_CREATION := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PERFORMANCE_DPT_CODE' then v_tb_customer_after.PERFORMANCE_DPT_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CUSTOMER_TYPE_CODE' then v_tb_customer_after.CUSTOMER_TYPE_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'DGBAS_INDUSTRY_CODE' then v_tb_customer_after.DGBAS_INDUSTRY_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PRIOR_PERSON_IDENTIFITY_NO' then v_tb_customer_after.PRIOR_PERSON_IDENTIFITY_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'NCB_INDUSTRY_CODE' then v_tb_customer_after.NCB_INDUSTRY_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'SERVE_COMPANY_NAME' then v_tb_customer_after.SERVE_COMPANY_NAME := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'SERVE_COMPANY_CERT_NO' then v_tb_customer_after.SERVE_COMPANY_CERT_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'JOB_POSITION_TYPE' then v_tb_customer_after.JOB_POSITION_TYPE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'INDUSTRY_TYPE_CODE' then v_tb_customer_after.INDUSTRY_TYPE_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PARENT_COMPANY_CERT_NO' then v_tb_customer_after.PARENT_COMPANY_CERT_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'FOREIGN_BRANCH_FLAG' then v_tb_customer_after.FOREIGN_BRANCH_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PARENT_COMPANY_COUNTRY' then v_tb_customer_after.PARENT_COMPANY_COUNTRY := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CHINA_MASTER_CODE' then v_tb_customer_after.CHINA_MASTER_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CHINA_SUB_CODE' then v_tb_customer_after.CHINA_SUB_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CIF_ORIGINAL_ID' then v_tb_customer_after.CIF_ORIGINAL_ID := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'DUP_CERT_NO_ORG_CHECKING_NUM' then v_tb_customer_after.DUP_CERT_NO_ORG_CHECKING_NUM := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CUST_NAME' then v_tb_customer_after.CUST_NAME := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'ACCOUNT_PURPOSE_CODE' then v_tb_customer_after.ACCOUNT_PURPOSE_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'OTHER_ACCOUNT_PURPOSE' then v_tb_customer_after.OTHER_ACCOUNT_PURPOSE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PERSONAL_ANNUAL_INCOME' then v_tb_customer_after.PERSONAL_ANNUAL_INCOME := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CPS_CUSTOMER_SOURCE_CODE' then v_tb_customer_after.CPS_CUSTOMER_SOURCE_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EDU_LEVEL_CODE' then v_tb_customer_after.EDU_LEVEL_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'MARRIED_STATUS_CODE' then v_tb_customer_after.MARRIED_STATUS_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CHILDREN_NUM' then v_tb_customer_after.CHILDREN_NUM := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'INTRODUCER_PERSON_CER_NO' then v_tb_customer_after.INTRODUCER_PERSON_CER_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'MATE_CERT_NO' then v_tb_customer_after.MATE_CERT_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'ENTRY_EXIT_PERMIT_START_DATE' then v_tb_customer_after.ENTRY_EXIT_PERMIT_START_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'ENTRY_EXIT_PERMIT_END_DATE' then v_tb_customer_after.ENTRY_EXIT_PERMIT_END_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'ENTRY_EXIT_PERMIT_NO' then v_tb_customer_after.ENTRY_EXIT_PERMIT_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'FOREIGN_EXCHANGE_ROLE_TYPE' then v_tb_customer_after.FOREIGN_EXCHANGE_ROLE_TYPE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'OFFICE_NOTE_DESCRIPTION' then v_tb_customer_after.OFFICE_NOTE_DESCRIPTION := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'GOVERNMENT_OFFICIAL_NO' then v_tb_customer_after.GOVERNMENT_OFFICIAL_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PARTY_ENGLISH_NAME' then v_tb_customer_after.PARTY_ENGLISH_NAME := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EXPIRED_DATE' then v_tb_customer_after.EXPIRED_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'ISSUE_DATE' then v_tb_customer_after.ISSUE_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EXCHANGE_RESIDENCE_PERMIT_NO' then v_tb_customer_after.EXCHANGE_RESIDENCE_PERMIT_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PASSPORT_NO' then v_tb_customer_after.PASSPORT_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EXCHANGE_CONTACT_PERSON_NAME' then v_tb_customer_after.EXCHANGE_CONTACT_PERSON_NAME := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EXCHANGE_CONTACT_PERSON_PHONE' then v_tb_customer_after.EXCHANGE_CONTACT_PERSON_PHONE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONT_ENGLISH_ADDR_COUNTRYCODE' then v_tb_customer_after.CONT_ENGLISH_ADDR_COUNTRYCODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONT_CITY' then v_tb_customer_after.CONT_CITY := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CUST_ZIP_CODE' then v_tb_customer_after.CUST_ZIP_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONT_ADDRESS_DETAIL' then v_tb_customer_after.CONT_ADDRESS_DETAIL := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PER_CITY' then v_tb_customer_after.PER_CITY := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PER_ZIP' then v_tb_customer_after.PER_ZIP := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'REGI_ADDRESS_DETAIL' then v_tb_customer_after.REGI_ADDRESS_DETAIL := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PER_AREA' then v_tb_customer_after.PER_AREA := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONT_ENGLISH_ADDR_ADMINAREA' then v_tb_customer_after.CONT_ENGLISH_ADDR_ADMINAREA := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONT_ENGLISH_ADDR' then v_tb_customer_after.CONT_ENGLISH_ADDR := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'OVERDUE_CREDIT_ACCOUNT' then v_tb_customer_after.OVERDUE_CREDIT_ACCOUNT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'DEBT_CONSULT' then v_tb_customer_after.DEBT_CONSULT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONSUMER_DEBT_CLEAN' then v_tb_customer_after.CONSUMER_DEBT_CLEAN := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CREDIT_CARD_SETTLEMENT' then v_tb_customer_after.CREDIT_CARD_SETTLEMENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'SPECIFIC_MEMBER_FLAG' then v_tb_customer_after.SPECIFIC_MEMBER_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'STOP_USE_CUSTOMER_DATA_FLAG' then v_tb_customer_after.STOP_USE_CUSTOMER_DATA_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'TERRORISTS_FLAG' then v_tb_customer_after.TERRORISTS_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CUSTOMER_STATUS' then v_tb_customer_after.CUSTOMER_STATUS := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'REHABILITATED' then v_tb_customer_after.REHABILITATED := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PRE_MEDIATE_FLAG' then v_tb_customer_after.PRE_MEDIATE_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'ACCOUNT_REVIEW_STATE' then v_tb_customer_after.ACCOUNT_REVIEW_STATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'BANK_INTERNAL_COMMON_SALE' then v_tb_customer_after.BANK_INTERNAL_COMMON_SALE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'AGREE_CS_FLAG' then v_tb_customer_after.AGREE_CS_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'AGREE_CS_WITH_CONSENT_FLAG' then v_tb_customer_after.AGREE_CS_WITH_CONSENT_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'DM_SALE_FLAG' then v_tb_customer_after.DM_SALE_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'SMS_SALE_FLAG' then v_tb_customer_after.SMS_SALE_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PHONE_SALE_FLAG' then v_tb_customer_after.PHONE_SALE_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EMAIL_SALE_FLAG' then v_tb_customer_after.EMAIL_SALE_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'NOTIFICATION_TYPE' then v_tb_customer_after.NOTIFICATION_TYPE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'RESI_COMM_CONTENT' then v_tb_customer_after.RESI_COMM_CONTENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONT_COMM_CONTENT' then v_tb_customer_after.CONT_COMM_CONTENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'COMP_COMM_CONTENT' then v_tb_customer_after.COMP_COMM_CONTENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONE_COMM_CONTENT' then v_tb_customer_after.CONE_COMM_CONTENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CMPE_COMM_CONTENT' then v_tb_customer_after.CMPE_COMM_CONTENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CNTP_COMM_CONTENT' then v_tb_customer_after.CNTP_COMM_CONTENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'TXNP_COMM_CONTENT' then v_tb_customer_after.TXNP_COMM_CONTENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'FAXT_COMM_CONTENT' then v_tb_customer_after.FAXT_COMM_CONTENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EMAIL_COMM_CONTENT' then v_tb_customer_after.EMAIL_COMM_CONTENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'REFUSE_LOAN_REASON' then v_tb_customer_after.REFUSE_LOAN_REASON := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CREDIT_CARD_HOLDER' then v_tb_customer_after.CREDIT_CARD_HOLDER := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'INDIVIDUAL_CONSULTATION' then v_tb_customer_after.INDIVIDUAL_CONSULTATION := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'JCIC_NO' then v_tb_customer_after.JCIC_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'WISE_CUSTOMER_SEG_MAIN' then v_tb_customer_after.WISE_CUSTOMER_SEG_MAIN := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'FC_FLAG' then v_tb_customer_after.FC_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'GIB_VERSION_CODE' then v_tb_customer_after.GIB_VERSION_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'GIB_AUTHTXN_CODE' then v_tb_customer_after.GIB_AUTHTXN_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'IVR_PWD_STATE_FLAG' then v_tb_customer_after.IVR_PWD_STATE_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'NO_BANK_STATM_FLAG' then v_tb_customer_after.NO_BANK_STATM_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'TRAVEL_CARD_FLAG' then v_tb_customer_after.TRAVEL_CARD_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CAPITAL' then v_tb_customer_after.CAPITAL := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'YEAR_REVENUE_CODE' then v_tb_customer_after.YEAR_REVENUE_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'TW_FUNDED_FLAG' then v_tb_customer_after.TW_FUNDED_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'UD_EXTENSION_FLAG' then v_tb_customer_after.UD_EXTENSION_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'DEBT_REFRESH_CLOSED' then v_tb_customer_after.DEBT_REFRESH_CLOSED := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'DEBT_CLEAN_CLOSED' then v_tb_customer_after.DEBT_CLEAN_CLOSED := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PIB_VERSION' then v_tb_customer_after.PIB_VERSION := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PIB_STATUS' then v_tb_customer_after.PIB_STATUS := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PIB_APPLY_DATE' then v_tb_customer_after.PIB_APPLY_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PIB_CANCEL_DATE' then v_tb_customer_after.PIB_CANCEL_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'SUPPLEMENTARY_PREMIUM_FLAG' then v_tb_customer_after.SUPPLEMENTARY_PREMIUM_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'RECEIPT_BUSINESS_FLAG' then v_tb_customer_after.RECEIPT_BUSINESS_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'FAX_TRANSACTION_FLAG' then v_tb_customer_after.FAX_TRANSACTION_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CUST_RATING' then v_tb_customer_after.CUST_RATING := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'TELLER_NO' then v_tb_customer_after.TELLER_NO := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'DATA_ENTRY_DATE' then v_tb_customer_after.DATA_ENTRY_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'REPORT_UNIT' then v_tb_customer_after.REPORT_UNIT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CREATION_UNIT' then v_tb_customer_after.CREATION_UNIT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'REPORT_DESCRIPTION' then v_tb_customer_after.REPORT_DESCRIPTION := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'GROWN_UP_GUARDIAN_SHIP' then v_tb_customer_after.GROWN_UP_GUARDIAN_SHIP := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PARTY_KIND' then v_tb_customer_after.PARTY_KIND := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'FIN_HOLD_CUS_STATE_FLAG' then v_tb_customer_after.FIN_HOLD_CUS_STATE_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'NOTE' then v_tb_customer_after.NOTE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'NO_SEND_TO_CIP_FLAG' then v_tb_customer_after.NO_SEND_TO_CIP_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CROSS_SELLING_NOTE' then v_tb_customer_after.CROSS_SELLING_NOTE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'BRANCH_OR_SUBSIDIARY_FLAG' then v_tb_customer_after.BRANCH_OR_SUBSIDIARY_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'REFUSE_TXN_DATE' then v_tb_customer_after.REFUSE_TXN_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'LOAN_NOTE' then v_tb_customer_after.LOAN_NOTE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'MGNT_UNIT_CODE' then v_tb_customer_after.MGNT_UNIT_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'OTP_SERVICE' then v_tb_customer_after.OTP_SERVICE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'SPECIAL_SERVICE_FLAG' then v_tb_customer_after.SPECIAL_SERVICE_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CIF_VERIFIED_ID' then v_tb_customer_after.CIF_VERIFIED_ID := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CUSTOMER_ID' then v_tb_customer_after.CUSTOMER_ID := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CROSS_SELLING_FLAG' then v_tb_customer_after.CROSS_SELLING_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CROSS_SELLING_DATE' then v_tb_customer_after.CROSS_SELLING_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CROSS_SELLING_TIME' then v_tb_customer_after.CROSS_SELLING_TIME := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CROSS_SELLING_IP' then v_tb_customer_after.CROSS_SELLING_IP := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CROSS_SELLING_CHANNEL' then v_tb_customer_after.CROSS_SELLING_CHANNEL := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CROSS_SELLING_UPD_PERSON' then v_tb_customer_after.CROSS_SELLING_UPD_PERSON := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EFG_FLAG' then v_tb_customer_after.EFG_FLAG := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'RESI_COMM_CONTENT2' then v_tb_customer_after.RESI_COMM_CONTENT2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'RESE_COMM_CONTENT' then v_tb_customer_after.RESE_COMM_CONTENT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'BBCALL' then v_tb_customer_after.BBCALL := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONT_COMM_CONTENT2' then v_tb_customer_after.CONT_COMM_CONTENT2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'COMP_COMM_CONTENT2' then v_tb_customer_after.COMP_COMM_CONTENT2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'RESE_COMM_CONTENT2' then v_tb_customer_after.RESE_COMM_CONTENT2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONE_COMM_CONTENT2' then v_tb_customer_after.CONE_COMM_CONTENT2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CMPE_COMM_CONTENT2' then v_tb_customer_after.CMPE_COMM_CONTENT2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CNTP_COMM_CONTENT2' then v_tb_customer_after.CNTP_COMM_CONTENT2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'TXNP_COMM_CONTENT2' then v_tb_customer_after.TXNP_COMM_CONTENT2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'BBCALL2' then v_tb_customer_after.BBCALL2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'FAXT_COMM_CONTENT2' then v_tb_customer_after.FAXT_COMM_CONTENT2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EMAIL_COMM_CONTENT2' then v_tb_customer_after.EMAIL_COMM_CONTENT2 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'RESI_COMM_CONTENT3' then v_tb_customer_after.RESI_COMM_CONTENT3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONT_COMM_CONTENT3' then v_tb_customer_after.CONT_COMM_CONTENT3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'COMP_COMM_CONTENT3' then v_tb_customer_after.COMP_COMM_CONTENT3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'RESE_COMM_CONTENT3' then v_tb_customer_after.RESE_COMM_CONTENT3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONE_COMM_CONTENT3' then v_tb_customer_after.CONE_COMM_CONTENT3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CMPE_COMM_CONTENT3' then v_tb_customer_after.CMPE_COMM_CONTENT3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CNTP_COMM_CONTENT3' then v_tb_customer_after.CNTP_COMM_CONTENT3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'TXNP_COMM_CONTENT3' then v_tb_customer_after.TXNP_COMM_CONTENT3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'BBCALL3' then v_tb_customer_after.BBCALL3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'FAXT_COMM_CONTENT3' then v_tb_customer_after.FAXT_COMM_CONTENT3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'EMAIL_COMM_CONTENT3' then v_tb_customer_after.EMAIL_COMM_CONTENT3 := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'NOTE_ON_SAVE_TRASFER' then v_tb_customer_after.NOTE_ON_SAVE_TRASFER := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'NOTE_ON_CREDIT' then v_tb_customer_after.NOTE_ON_CREDIT := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'LC_ORIGINAL_HANDLE_WAY' then v_tb_customer_after.LC_ORIGINAL_HANDLE_WAY := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'REPORT_DATE' then v_tb_customer_after.REPORT_DATE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'JOB_POSITION_NAME' then v_tb_customer_after.JOB_POSITION_NAME := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CROSS_SELLING_VERSION' then v_tb_customer_after.CROSS_SELLING_VERSION := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'PROPERTY_TYPE_CODE' then v_tb_customer_after.PROPERTY_TYPE_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'ACCOUNT_REVIEW_PENDING' then v_tb_customer_after.ACCOUNT_REVIEW_PENDING := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'AML_REVIEW_STATUS_CODE' then v_tb_customer_after.AML_REVIEW_STATUS_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'AML_CONTROL_STATUS_CODE' then v_tb_customer_after.AML_CONTROL_STATUS_CODE := model_jsb.get_string(model_key_jsb_key_list(i));
                                    when 'CONT_AREA' then v_tb_customer_after.CONT_AREA := model_jsb.get_string(model_key_jsb_key_list(i));
                                ELSE
                                DBMS_OUTPUT.PUT_LINE('');
                               end case;
                          end if;
                end loop;
      END ;





--==============================================  主程式開始 ===========================================================
   BEGIN
   DBMS_OUTPUT.PUT_LINE(' ============== SP_UPDATE_ALL_COL_CUST START ========');
   DBMS_OUTPUT.ENABLE(buffer_size => null);
   jsb := json_object_t.PARSE(I_INPUT_JSON);
      --取得SENDER_CODE
      v_header_sender_code := json_value(I_INPUT_JSON,'$.header.senderCode');
      --取得txId
      v_tx_id  := json_value(I_INPUT_JSON,'$.header.txnCode');
      v_msg_no := json_value(I_INPUT_JSON,'$.header.msgNo');
      v_branch_code        := json_value(I_INPUT_JSON,'$.requestBody.header.branch.branchCode');
      v_teller_id          := json_value(I_INPUT_JSON,'$.requestBody.header.teller.tellerId');
      v_ori_trade_seq_no   := json_value(I_INPUT_JSON,'$.requestBody.header.oriTradeSeqNo');
      v_supervisor_card_code := json_value(I_INPUT_JSON,'$.requestBody.header.teller.supervisorCardCode');
      v_supervisor_code := SUBSTR(json_value(I_INPUT_JSON,'$.requestBody.header.teller.supervisorCardCode'),5 ,6);

      --解析model欄位(多欄位用query)
       v_json_model_clob :=  json_query(I_INPUT_JSON,'$.requestBody.model' pretty);
       --取得model下所有key值
       model_jsb := json_object_t.parse(v_json_model_clob);
       model_key_jsb_key_list:= model_jsb.get_keys;

       --將原本varray的model 轉換 table array中，以方便後續操作
       for i in 1..model_key_jsb_key_list.count
       loop
         v_ori_model_ja_col.extend();
         v_ori_model_ja_col(v_ori_model_ja_col.last) := model_key_jsb_key_list(i);
       end loop;

       --將DB COLUMN_CODE 和 JSON_NAME關係存至map做對映
       SET_DB_COLUMN_NAME_TO_JSON_NAME_MAPPING();

       --設定固定之識別欄位
      SET_FIX_IDENTIFIER_JSON_ARRAY();

       --識別條件變數賦值
       SET_IDENTIFIER_CONDITION_VALUE();

       --呼叫大查詢
       FIND_ALL_COL_CUST();

       --過濾MODEL下識別欄位並組成異動欄位(包含生日欄位判斷)
       COMPOSE_UPDATE_COLUMN_ARRAY();



       -- 查詢顧客是否已建檔
       -- 顧客已建檔 → 維護
       IF V_RECIEIVE_CUSOTMER_ID_ARRAY.count() = 1 THEN
          SELECT * INTO v_tb_customer FROM CIFX.TB_CUSTOMER WHERE CUSTOMER_ID = V_RECIEIVE_CUSOTMER_ID_ARRAY(1);

          --準備異動後的v_tb_cusotmer_after rowtype物件，先塞好原值，待後續欄位覆蓋掉異動值
          SELECT * INTO v_tb_customer_after FROM CIFX.TB_CUSTOMER WHERE CUSTOMER_ID = V_RECIEIVE_CUSOTMER_ID_ARRAY(1);

          --逐筆Setting變更後rowtype物件
          SET_INPUT_CUSTOMER_RECORD();


        --go through g_input_model_tab物件 START (測試用)
        v_indx_by_column_name := g_input_model_tab.first;
        while v_indx_by_column_name is not null
         loop
           DBMS_OUTPUT.PUT_LINE('g_input_model_tab(v_indx_by_column_name).input_json:' || g_input_model_tab(v_indx_by_column_name).input_json);
--           DBMS_OUTPUT.PUT_LINE('g_input_model_tab(v_indx_by_column_name).input_value:' || g_input_model_tab(v_indx_by_column_name).input_value);
--           DBMS_OUTPUT.PUT_LINE('g_input_model_tab(v_indx_by_column_name).db_column_name:' || g_input_model_tab(v_indx_by_column_name).db_column_name);
--           DBMS_OUTPUT.PUT_LINE('g_input_model_tab(v_indx_by_column_name).data_type:' || g_input_model_tab(v_indx_by_column_name).data_type);
           v_indx_by_column_name := g_input_model_tab.next(v_indx_by_column_name);
         end loop;
         --go through g_input_model_tab物件 END (測試用)

          -- 判斷證號類型
          CIFX.SP_VAL_CERTIFICATION_TYPE(
                I_FUNCTION => '1',
                I_CERT_NO => v_tb_customer.CIF_ORIGINAL_ID,
                I_BIRTHDAY => v_tb_customer.BIRTHDAY,
                O_RETURN_CODE => v_return_code,
                O_CERT_TYPE => v_cert_type_return,
                O_CHECK_NUMBER => v_check_number
              );
            v_cert_type := v_cert_type_return;
            IF v_cert_type IS NULL THEN
              CIFX.SP_THROW_ERR1('0918,使用 SP_VAL_CERTIFICATION_TYPE(1,I_CIF_ORIGINAL_ID)，取得cert_type is null');
            END IF;

            -- 轉換OBU顧客證號類型代碼
            IF 'O' = v_cert_type AND v_tb_customer.PROPERTY_TYPE_CODE IN ('0','6') THEN v_cert_type := 'OA'; END IF;
            IF 'O' = v_cert_type AND v_tb_customer.PROPERTY_TYPE_CODE NOT IN ('0','6') THEN v_cert_type := 'OB'; END IF;
       -- 查無顧客 → 新建檔
       ELSIF V_RECIEIVE_CUSOTMER_ID_ARRAY.count() = 0 THEN
           v_tb_customer := NULL;
           DBMS_OUTPUT.PUT_LINE('全欄位查詢:查無顧客');
          -- 判斷證號類型及檢核證號合法性
          CIFX.SP_VAL_CERTIFICATION_TYPE(
              I_FUNCTION => '2',
              I_CERT_NO => v_customerCertificationNumber,
              I_BIRTHDAY => v_birthday,
              O_RETURN_CODE => v_return_code,
              O_CERT_TYPE => v_cert_type_return,
              O_CHECK_NUMBER => v_check_number
          );
          -- 無法識別或舊證號
          IF v_cert_type IS NULL OR v_cert_type IN ('X','F','G','H') THEN
              CIFX.SP_THROW_ERR1('5008,呼叫SP_VAL_CERTIFICATION_TYPE(2,I_CIF_ORIGINAL_ID)檢核，建檔統編不合法，['||v_cert_type||']');
          END IF;
          v_cert_type := v_cert_type_return;
          -- 轉換OBU顧客證號類型代碼
          v_customerPropertyType := json_value(I_INPUT_JSON,'$requestBody.model.customerPropertyType');
          IF 'O' = v_cert_type AND v_customerPropertyType IN ('0','6') THEN v_cert_type := 'OA'; END IF;
          IF 'O' = v_cert_type AND v_customerPropertyType NOT IN ('0','6') THEN v_cert_type := 'OB'; END IF;
       ELSE
            --查回筆多筆顧客
            v_tb_customer := NULL;
            DBMS_OUTPUT.PUT_LINE('全欄位查詢:查回多筆顧客，無法判斷');
       END IF;

       -- v_update_column_array(json_node)欄位和v_tb_column_code_opt.column_name對應
       -- 逐欄位基本檢核
       for i in 1..v_update_column_array.count
       loop
       -- 取得非識別條件(即異動欄位資訊)
           DBMS_OUTPUT.PUT_LINE('最後異動欄位(input json):' ||v_update_column_array(i) );
           DBMS_OUTPUT.PUT_LINE('最後異動欄位 資料庫欄位(input json):' || v_db_col_to_json_col_map(v_update_column_array(i)) );
             --取得欄位db名稱
             v_sql := 'SELECT count(1)
              FROM CIFX.TB_COLUMN_CODE_OPT OPT
              WHERE OPT.JSON_NAME = ' || '''' || v_db_col_to_json_col_map(v_update_column_array(i)) || '''';
              execute immediate v_sql into v_column_map_chk_count;

              if v_column_map_chk_count <> 1 then
               CIFX.SP_THROW_ERR('0910,輸入 資料庫 欄位【' || v_update_column_array(i) || '】對應資料庫欄位有誤！！' );
              end if;

              v_sql := 'SELECT OPT.*
              FROM CIFX.TB_COLUMN_CODE_OPT OPT
              WHERE OPT.JSON_NAME = ' || '''' || v_db_col_to_json_col_map(v_update_column_array(i)) || ''''
               ;

              execute immediate v_sql into v_tb_column_code_opt;

              v_column_value := json_VALUE(v_json_model_clob,'$.' || v_db_col_to_json_col_map(v_update_column_array(i))  error on error );

             --呼叫btcifxix檢核欄位元件
             CIFX.SP_VAL_COLUMN_VALUE(
              I_COLUMN_NAME =>v_tb_column_code_opt.column_name, --異動資料庫欄位名稱
              I_COLUMN_VALUE =>v_column_value, --異動欄位值
              O_RESULT  =>  V_R_RESULT,   --成功則回傳0000
              O_RESULT_DESCRIPTION  =>  V_R_RESULT_DESCRIPTION,
              O_ERROR_MESSAGE  =>  V_R_ERROR_MESSAGE
             );
             CASE
             WHEN V_R_RESULT = 'CODE' THEN
                V_R_RESULT := '0918';
             WHEN V_R_RESULT IN ('RULD','RULT','RULN', 'RULC','RULE','RULC', 'RULL', 'RULF') THEN
                V_R_RESULT := '0913';
             ELSE
                NULL;
             END CASE;
             IF V_R_RESULT <> '0000' THEN
                DBMS_OUTPUT.PUT_LINE('column_name:'|| v_tb_column_code_opt.column_name);
                DBMS_OUTPUT.PUT_LINE('v_column_value:'||v_column_value);
                DBMS_OUTPUT.PUT_LINE('V_R_RESULT_DESCRIPTION:' || V_R_RESULT_DESCRIPTION);
                DBMS_OUTPUT.PUT_LINE('V_R_ERROR_MESSAGE:' || V_R_ERROR_MESSAGE);
                CASE V_R_RESULT
                WHEN '0913' THEN
                    CIFX.PG_THROW_ERR.SP_THROW_ERR(V_R_RESULT || '%'|| v_tb_column_code_opt.column_desc || '-' || V_R_RESULT_DESCRIPTION);
                ELSE
                    CIFX.PG_THROW_ERR.SP_THROW_ERR(V_R_RESULT || '%'|| v_tb_column_code_opt.column_desc);
                END CASE;
             END IF;


     end loop;



     -- 逐欄位進行邏輯處理
     -- 輸入欄位業務檢核規則 + 欄位異動業務處理邏輯
    for i in 1..v_update_column_array.count
    loop
    -- ============= 輸入欄位業務檢核規則 START =========================================
        DBMS_OUTPUT.PUT_LINE('================ 輸入欄位業務檢核規則 START ==================');
        DBMS_OUTPUT.PUT_LINE('v_update_column_array(i):' || v_update_column_array(i));
        for v_col_rule_rec in (
            select * from cifx.TB_COL_BUSINESS_RULE cbr
            where substr(cbr.RULE_ID,1,1) = 'V' --檢核
            and cbr.column_code = v_tb_column_code_opt.column_code  --此次檢核欄位
        )loop

            DBMS_OUTPUT.PUT_LINE('受檢欄位:' || v_tb_column_code_opt.column_code);
            DBMS_OUTPUT.PUT_LINE('變數:' || v_col_rule_rec.rule_process);
            DBMS_OUTPUT.PUT_LINE('v_cert_type:' || v_cert_type);


                   EXECUTE immediate 'DECLARE BEGIN '|| v_col_rule_rec.rule_process || '( I_INPUT_JSON => :1 , I_TB_CUSTOMER => :2, I_tb_customer_after => :3 , I_TX_ID => :4 , I_SENDER_CODE => :5 , I_CERT_TYPE => :6 , I_CHANGE_TYPE => :7 ); END;'
                   using IN I_INPUT_JSON,IN v_tb_customer,IN v_tb_customer_after,IN v_tx_id,IN v_header_sender_code,IN v_cert_type,IN v_change_type;


             end loop;
        DBMS_OUTPUT.PUT_LINE('================ 欄位異動業務處理邏輯 END ==================');
        for v_cascade_rule_rec in (
            select * from CIFX.TB_COL_CASCADE_RULE ccr
            where ccr.column_code = v_tb_column_code_opt.column_code  --此次檢核欄位
        )loop
               EXECUTE immediate   'DECLARE BEGIN '|| v_cascade_rule_rec.rule_process || '( I_INPUT_JSON => :1 , I_TB_CUSTOMER => :2 , I_TX_ID => :3 , I_SENDER_CODE => :4 , I_CERT_TYPE => :5 , I_CHANGE_TYPE => :6); END;'
               using IN I_INPUT_JSON,IN v_tb_customer,IN OUT v_tb_customer_after,IN v_tx_id,IN v_header_sender_code,IN v_cert_type,IN v_change_type;
        end loop;
    end loop;
    DBMS_OUTPUT.PUT_LINE('v_tb_customer_after:' || v_tb_customer_after.customer_status);
      --TODO (待胡珅學長開發完成) 實際異動/建檔顧客
      /*
      1.顧客異動功能開發(已完成)
      2.顧客建檔功能開發(已完成)
      3.顧客異動紀錄寫入(1.2共用)(已完成)
      4.SEC寫入((已完成待搬遷)
      */
     DBMS_OUTPUT.PUT_LINE('========== 呼叫 胡珅學長 顧客異動/建檔核心 START =================');
--        CIFX.PG_UPSERT_CUSTOMER.SP_UPSERT_CUSTOMER_MAIN(
--        i_input_json => I_INPUT_JSON,
--        i_customer => v_tb_customer,
--        i_update_column_array => v_update_column_array,
--        i_service_interchange_id => I_SERVICE_INTERCHANGE_ID,
--        i_ap_server_to_exec => I_AP_SERVER_TO_EXEC,
--        o_customer_id => v_customer_id
--        );
     DBMS_OUTPUT.PUT_LINE('========== 呼叫 胡珅學長 顧客異動/建檔核心 END =================');
     --取得新資料
     v_customer_id := '1560268960297199-1370570-15-01';--待刪除
     SELECT * INTO v_tb_customer_after FROM CIFX.TB_CUSTOMER WHERE CUSTOMER_ID = v_customer_id;

     --TODO 搬遷SEC寫入至此

     --TODO 異動KYC
     DBMS_OUTPUT.PUT_LINE('========== 異動kyc start =================');

     DBMS_OUTPUT.PUT_LINE('========== 異動kyc end =================');

     --TODO 寫入PUSH
      BEGIN
        FOR v_arr_push IN
          (
          SELECT DISTINCT v_tb_customer_after.CIF_VERIFIED_ID,NVL(REGEXP_SUBSTR(PUSH_CODE, '[^\]+', 1, LEVEL, 'i'), 'NULL') AS TX_CODE, I_SERVICE_INTERCHANGE_ID
          FROM
            (SELECT  PUSH_CODE
             FROM CIFX.TB_CHANGE_LOG CL
             JOIN CIFX.TB_CHANGE_LOG_LINEITEM CLL ON CL.CHANGE_LOG_ID = CLL.CHANGE_LOG_ID
             JOIN CIFX.TB_COLUMN_CODE_OPT CCO ON  CCO.PUSH_CODE IS NOT NULL AND CCO.TABLE_NAME = 'TB_CUSTOMER'
             JOIN CIFX.TB_COLUMN_CODE CC ON CCO.COLUMN_CODE = CC.COLUMN_CODE
             WHERE CL.SERVICE_INTERCHANGE_ID = I_SERVICE_INTERCHANGE_ID  AND CL.CIRCI_KEY = v_tb_customer_after.CIF_VERIFIED_ID)
          CONNECT BY LEVEL <= REGEXP_COUNT(PUSH_CODE ,'[\]')+1
          )
          LOOP
            --         dbms_output.put_line(v_arr_push.TX_CODE);
            CIFX.SP_INS_PUSH_BY_TXCODE(v_tb_customer_after.CIF_VERIFIED_ID, v_arr_push.TX_CODE, I_SERVICE_INTERCHANGE_ID);
          END LOOP;
        EXCEPTION
        WHEN OTHERS THEN
          CIFX.PG_THROW_ERR.SP_THROW_ERR('0901%發送PUSH錯誤');
      END;
     --TODO 寫入EDLS
     --手續費優惠變更
     CIFX.SP_CHG_SERVICE_FEE_DISCOUNT(
      v_tb_customer_after.CIF_VERIFIED_ID,
      I_SERVICE_INTERCHANGE_ID,
      v_fee_discount_chg_result_code,
      v_fee_discount_result_description,
      v_fee_discount_err_msg);

      IF v_fee_discount_chg_result_code <> '0000' THEN
        CIFX.PG_THROW_ERR.SP_THROW_ERR(v_fee_discount_chg_result_code || '%更新手續費優惠錯誤');
      END IF;
     --TODO 寫入CIDVE
      OPEN v_cursor for
      SELECT  cll.changed_value, cc.column_name, cll.before_value, cl.branch_id
             FROM CIFX.TB_CHANGE_LOG CL
             JOIN CIFX.TB_CHANGE_LOG_LINEITEM CLL ON CL.CHANGE_LOG_ID = CLL.CHANGE_LOG_ID
             JOIN CIFX.TB_COLUMN_CODE CC ON CLL.CHANGED_COLUMN_CODE_ID = CC.COLUMN_CODE_ID AND CC.COLUMN_NAME
             IN('CONT_CITY','CONT_AREA', 'CONT_ADDRESS_DETAIL','CUSTOMER_STATUS','NOTIFICATION_TYPE','SPECIAL_SERVICE_FLAG','OTP_SERVICE','IVR_PWD_STATE_FLAG','TXNP_COMM_CONTENT','GROWN_UP_GUARDIAN_SHIP')
             WHERE CL.SERVICE_INTERCHANGE_ID = I_SERVICE_INTERCHANGE_ID  AND CL.CIRCI_KEY = v_tb_customer_after.CIF_VERIFIED_ID;
      LOOP
        FETCH v_cursor INTO
          v_src_change_value, v_src_column_name, v_src_origin_value, v_src_branch_id;
        EXIT WHEN v_cursor%NOTFOUND;
--        dbms_output.put_line('v_src_column_name =>' || v_src_column_name);
        CASE v_src_column_name
          WHEN 'CONT_CITY' THEN
            v_residnetial_city := v_src_change_value;
          WHEN 'CONT_AREA' THEN
            v_residential_area := v_src_change_value;
          WHEN 'CONT_ADDRESS_DETAIL' THEN
            v_residential_address_detail := v_src_change_value;
          WHEN 'CUSTOMER_STATUS' THEN
            v_customer_status := v_src_change_value;
          WHEN 'SPECIAL_SERVICE_FLAG' THEN
            v_before_special_service_flag := v_src_origin_value;
          WHEN 'OTP_SERVICE' THEN
            v_before_otp_service := v_src_change_value;
          WHEN 'IVR_PWD_STATE_FLAG' THEN
            v_before_ivr_pwd_state_flag :=  v_src_origin_value;
          WHEN 'TXNP_COMM_CONTENT' THEN
            v_before_txnp_comm_content := v_src_origin_value;
          ELSE
            NULL;
          END CASE;
        -- 判斷是否需寫入事故檔(CIDVE)
        CASE
        WHEN v_src_column_name IN ('TXNP_COMM_CONTENT','SPECIAL_SERVICE_FLAG','OTP_SERVICE','IVR_PWD_STATE_FLAG') THEN
          v_count_cidve_event := v_count_cidve_event + 1;
        -- 判斷是否有84事故連動欄位
        WHEN v_src_column_name IN ('CUSTOMER_STATUS', 'CONT_CITY','CONT_AREA','CONT_ADDRESS_DETAIL') THEN
          v_count_84 := v_count_84 + 1;
        -- 判斷是否有64事故
        WHEN v_src_column_name IN ('GROWN_UP_GUARDIAN_SHIP') AND NVL(v_src_origin_value, ' ') <> NVL(v_src_change_value, ' ')  THEN
          v_is_64 := true;
        ELSE
            NULL;
        END CASE;
        --

      END LOOP;
      CLOSE v_cursor;
      -- 寫入CIDVE事故檔
      IF v_count_cidve_event > 0 THEN
        CIFX.SP_INS_CIDVE_EVENT(
            'A999999' , --交易序號
            TO_CHAR(SYSDATE , 'yyyymmdd hh24miss') , --交易日期及時間
            'TS0116' , --傳送系統代碼
            v_src_branch_id , -- 分行代碼
            '99999' , -- 異動人員代碼(員編)
            NULL, -- 授權主管代碼(員編)
            v_tb_customer.CIF_VERIFIED_ID,
            I_SERVICE_INTERCHANGE_ID,
            v_tb_customer.otp_service,
            v_tb_customer_after.otp_service,
            v_tb_customer.special_service_flag,
            v_tb_customer_after.special_service_flag,
            v_tb_customer.txnp_comm_content,
            v_tb_customer_after.txnp_comm_content,
            v_tb_customer.IVR_PWD_STATE_FLAG,
            v_tb_customer_after.IVR_PWD_STATE_FLAG,
            v_cidve_result_code,
            v_cidve_result_description,
            v_cidve_err_msg
          );

          IF v_cidve_result_code <> '0000' THEN
            CIFX.PG_THROW_ERR.SP_THROW_ERR(v_cidve_result_code || '%電子銀行事故檔寫入錯誤');
          END IF;
      END IF;
      --解除EDLS 84事故
      IF v_count_84 > 0 THEN
        v_84_result := CIFX.FN_EIGHTY_FOUR_EVENT(
            I_CUSTOMER_CIRCI_KEY       =>   v_tb_customer_after.CIF_VERIFIED_ID,
            I_BRANCH_ID                =>   v_branch_code,
            I_TELLER_ID                =>   v_teller_id,
            I_ORI_TRADE_SEQ_NO         =>   v_ori_trade_seq_no,
            I_SUPERVISOR_CODE          =>   v_supervisor_code,
            I_CUSTOMER_STATUS_OLD      =>   v_tb_customer.CUSTOMER_STATUS,
            I_CONT_CITY_OLD            =>   v_tb_customer.CONT_CITY,
            I_CONT_AREA_OLD            =>   v_tb_customer.CONT_AREA,
            I_CONT_ADDRESS_DETAIL_OLD  =>   v_tb_customer.CONT_ADDRESS_DETAIL,
            I_CONT_CITY                =>   v_tb_customer_after.CONT_CITY,
            I_CONT_AREA                =>   v_tb_customer_after.CONT_AREA,
            I_CONT_ADDRESS_DETAIL      =>   v_tb_customer_after.CONT_ADDRESS_DETAIL
        );
        IF v_84_result NOT IN ('0000','9999') THEN
            CIFX.PG_THROW_ERR.SP_THROW_ERR(v_84_result || '%84事故寫入錯誤');
        END IF;
      END IF;
      --新增或解除EDLS 64事故
      IF v_is_64 THEN
        EDLS.PG_EDLS_TO_CIF.SP_REG_REL_DEPT_ACC_EVENT_OF_CUST_ID
        ( i_cust_id            =>   v_tb_customer_after.CIF_VERIFIED_ID,          -- 銀行歸戶統編
        i_function             =>   CASE WHEN  nvl(v_tb_customer_after.grown_up_guardian_ship,'0') IN ('0','4','6') THEN 'N' ELSE 'Y' END,        -- 作業註記 (Y=>表示為登錄 N=>表示為解除)
        i_event_code           =>   '64',                 -- 事故代號 (因僅提供CIFX使用，為免誤用，僅開放34/44/64/74)
        i_event_desc           =>   '成年監護',                 -- 事故說明
        i_tx_id                =>   v_tx_id,                 -- 交易代號
        i_tx_bh                =>   v_branch_code,                 -- 交易分行
        i_tx_serial_no         =>   v_ori_trade_seq_no,                 -- 交易序號
        i_tx_handler           =>   v_teller_id,                 -- 交易員編
        i_auth_code            =>   v_supervisor_card_code,                 -- 授權碼
        i_auth_sup_id          =>   v_supervisor_code,                 -- 授權主管員編
        i_info_asset_code      =>   'TS0116',                 -- 資訊資產代號
        o_result               =>   v_64_result,           -- 執行結果代號
        o_chn_result           =>   v_64_result_description        -- 執行結果中文
       );
        IF v_84_result NOT IN ('0000','5008') THEN
            CIFX.PG_THROW_ERR.SP_THROW_ERR(v_64_result || '%64事故寫入錯誤');
        END IF;
      END IF;

       --測試取得解析後clob下的的節點你好
--       v_test := json_query(v_json_model_clob,'$.mobilePhoneNumber' with wrapper error on error );
       DBMS_OUTPUT.PUT_LINE('v_64_result_description:'||v_64_result_description);
       v_test:=I_SERVICE_INTERCHANGE_ID;
     O_RESULT_DESC := v_test;
    EXCEPTION
        WHEN COLLECTION_IS_NULL THEN
        DBMS_OUTPUT.PUT_LINE('大異動_我有進COLLECTION_IS_NULL');
        DBMS_OUTPUT.PUT_LINE('大異動_最後查無顧客');



   DBMS_OUTPUT.PUT_LINE(' ============== SP_UPDATE_ALL_COL_CUST END ========');
   END SP_UPDATE_ALL_COL_CUST;

END PG_UPDATE_ALL_COL_CUST;

/

  GRANT EXECUTE ON "CIFX"."PG_UPDATE_ALL_COL_CUST" TO "APCIFXT01";
  GRANT DEBUG ON "CIFX"."PG_UPDATE_ALL_COL_CUST" TO "APCIFXT01";
