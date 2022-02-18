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
      v_tmp_add_kyc_list json_array_t := json_array_t();
      v_tmp_del_kyc_list json_array_t := json_array_t();

      v_indx_by_column_name varchar2(1000 char) := '';

     -- =========== 識別條件變數 =============
      v_customerCirciKey varchar2(100 char) := '';
      v_birthday varchar2(100 char) := '';
      v_customerCertificationNumber varchar2(100 char) := '';
      v_accountNumber varchar2(100 char) := '';
      v_customer_id CIFX.TB_CUSTOMER.CUSTOMER_ID%TYPE := '';--顧客uuid

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
      -------------------------------------------------
      -- kyc 使用
      v_add_kyc_list    CIFX.INPUT_ARRAY := INPUT_ARRAY();
      v_del_kyc_list    CIFX.INPUT_ARRAY := INPUT_ARRAY();
      v_before_kyc      varchar2 (100 char);
      v_changed_kyc       varchar2 (100 char);

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

        if 'addKycList' not member of v_fix_identifier_json_col then
          v_fix_identifier_json_col.extend();
          v_fix_identifier_json_col(v_fix_identifier_json_col.last) := 'addKycList';
        end if;

        if 'deleteKycList' not member of v_fix_identifier_json_col then
          v_fix_identifier_json_col.extend();
          v_fix_identifier_json_col(v_fix_identifier_json_col.last) := 'deleteKycList';
        end if;
      END SET_FIX_IDENTIFIER_JSON_ARRAY;

      PROCEDURE SET_INPUT_CUSTOMER_RECORD
      IS
      BEGIN
      for i in 1..model_key_jsb_key_list.count
                loop
                    IF model_key_jsb_key_list(i) IN ('addKycList', 'deleteKycList') THEN
                        continue;
                    END IF;
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



                     --INPUT ROWYTYPE 動態賦值
                          if v_json_col_to_db_col_map(model_key_jsb_key_list(i))  is not null
                          and model_jsb.get_string(model_key_jsb_key_list(i)) is not null then

                              case v_db_col_to_data_type_map(v_json_col_to_db_col_map(model_key_jsb_key_list(i)))  --欄位在db型態
                                when 'VARCHAR2' then   --賦值需加單引號
                                    V_SQL := 'declare r CIFX.TB_CUSTOMER%ROWTYPE:=:1;
                                              begin r.' || v_json_col_to_db_col_map(model_key_jsb_key_list(i)) || ':= ' || '''' || model_jsb.get_string(model_key_jsb_key_list(i))  || '''' ||';
                                              :1 := r;
                                              end;  ';
                                else
                                   V_SQL := 'declare r CIFX.TB_CUSTOMER%ROWTYPE:=:1;
                                              begin r.' || v_json_col_to_db_col_map(model_key_jsb_key_list(i)) || ':= ' ||  model_jsb.get_string(model_key_jsb_key_list(i))  ||';
                                              :1 := r;
                                              end;  ';
                              end case;

                              EXECUTE IMMEDIATE V_SQL using in  out v_tb_customer_after ;
                          end if;
                end loop;
      END ;



     PROCEDURE SP_VAL_KYC -- 驗證KYC
     IS
        v_add_key_value_code_count NUMBER := 0;
        v_del_key_value_code_count NUMBER := 0;
        v_branch_b_code EDLS.TB_BRANCH.BH_B_CODE%TYPE;
        v_kyc CIFX.TB_CUST_KYC.KYC_TYPE_CODE%TYPE;
        PROCEDURE CHK(I_INPUT_ARRAY CIFX.INPUT_ARRAY)
        IS
            v_branch_b_code EDLS.TB_BRANCH.BH_B_CODE%TYPE;
            v_kyc CIFX.TB_CUST_KYC.KYC_TYPE_CODE%TYPE;
        BEGIN
            BEGIN
                SELECT BH_B_CODE INTO v_branch_b_code FROM EDLS.TB_BRANCH WHERE BH_CODE = v_branch_code;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    CIFX.PG_THROW_ERR.SP_THROW_ERR('0910%查無分行');
            END;

            FOR i IN 1..I_INPUT_ARRAY.COUNT
            LOOP
                    v_kyc := I_INPUT_ARRAY(i);
                    DBMS_OUTPUT.PUT_LINE('v_kyc 檢核:' || v_kyc);
                    --當顧客身份別代碼為「C6」只有GAML與信卡可以變更
                    IF v_kyc = 'C6' AND v_tx_id = 'A12103' THEN
                        CIFX.PG_THROW_ERR.SP_THROW_ERR('0991');
                    END IF;
                    --當顧客身份別代碼為「A8」或「F6」時交易代碼需為「R12103」
                    IF v_kyc IN ('A8', 'F6') AND v_tx_id <> 'R12103' THEN
                        CIFX.PG_THROW_ERR.SP_THROW_ERR('0991');
                    END IF;
                     -- 〔顧客身份代碼〕為「Q2」時需〔交易代碼〕為「A12103」且〔交易分行代表變數〕為「B9006」時才能維護
                    IF v_kyc = 'Q2' AND (v_tx_id <> 'A12103' OR v_branch_b_code <> 'B9006') THEN
                        CIFX.PG_THROW_ERR.SP_THROW_ERR('7106');
                    END IF;
                    --當〔顧客身份代碼〕為「F4」時需〔交易分行〕為「9015」時才能維護
                    IF v_kyc = 'F4' AND v_branch_b_code <> 'B9015' THEN
                        CIFX.PG_THROW_ERR.SP_THROW_ERR('7106');
                    END IF;
                    IF v_kyc IN ('A1','A2','A3','A4','A5','A6','A7','A9', 'B1','B2','B3','B4','B5','B6','B7','B8','B9','F2','F3','G1','G2','G3','G4','G5','G6','G7','G8','G9','Q3')
                    AND v_tx_id IN('A12103','R12103')
                    THEN
                        CIFX.PG_THROW_ERR.SP_THROW_ERR('0991');
                    END IF;
            END LOOP;
        END ;
     BEGIN
        --非空值時檢核是否符合【通用代碼表】.【代碼類型】='kyc_type_code'所定義的【代碼值】值域
        IF v_add_kyc_list.COUNT <> 0 THEN
            SELECT COUNT(KEY_VALUE_CODE_ID) INTO v_add_key_value_code_count FROM CIFX.TB_KEY_VALUE_CODE WHERE CODE_CATEGORY = 'kyc_type_code' AND CODE_VALUE IN (SELECT * FROM TABLE(v_add_kyc_list));
            CHK(v_add_kyc_list);
            IF v_add_key_value_code_count < 1 THEN
                CIFX.PG_THROW_ERR.SP_THROW_ERR('0815');
            END IF;
        END IF;

        IF v_del_kyc_list.COUNT <> 0 THEN
            SELECT COUNT(KEY_VALUE_CODE_ID) INTO v_del_key_value_code_count FROM CIFX.TB_KEY_VALUE_CODE WHERE CODE_CATEGORY = 'kyc_type_code' AND CODE_VALUE IN (SELECT * FROM TABLE(v_del_kyc_list));
            CHK(v_del_kyc_list);
            IF v_del_key_value_code_count < 1 THEN
                CIFX.PG_THROW_ERR.SP_THROW_ERR('0815');
            END IF;
        END IF;




     END ;

     PROCEDURE SP_CHG_KYC --連動KYC
     IS
        v_result_cursor CIFX.PG_DAO_TYPES.REF_CURSOR;
        v_kyc CIFX.TB_CUST_KYC.KYC_TYPE_CODE%TYPE;
        v_chk       BOOLEAN;
        v_datacount NUMBER;
        v_key_value_code_count NUMBER := 0;
    BEGIN
--新增身份
        IF v_add_kyc_list IS NOT NULL THEN
            FOR I IN 1..v_add_kyc_list.COUNT
                LOOP
                    v_kyc := v_add_kyc_list(I);
                    DBMS_OUTPUT.PUT_LINE('新增KYC:' || v_kyc);

                    --沒有此身份才新增
                    SELECT COUNT(CUST_KYC_ID)
                    INTO v_datacount
                    FROM CIFX.TB_CUST_KYC
                    WHERE CUSTOMER_ID   = v_tb_customer_after.customer_id
                      AND KYC_TYPE_CODE = v_kyc;
                    IF v_datacount    < 1 THEN
                        INSERT
                        INTO CIFX.TB_CUST_KYC
                        (
                            CUST_KYC_ID,
                            CIRCI_KEY,
                            CUSTOMER_ID,
                            KYC_TYPE_CODE
                        )
                        VALUES
                        (
                            CIFX.FN_UUID_NUMBER30(),
                            v_tb_customer_after.cif_verified_id,
                            v_customer_id,
                            v_kyc
                        );
                    END IF;
                END LOOP;
        END IF;
        --刪除身份
        IF v_del_kyc_list IS NOT NULL THEN
            FOR I IN 1..v_del_kyc_list.COUNT
                LOOP
                    v_kyc := v_del_kyc_list
                        (
                            I
                        )
                    ;
                     DBMS_OUTPUT.PUT_LINE('刪除KYC:' || v_kyc);

                    DELETE CIFX.TB_CUST_KYC
                    WHERE CUSTOMER_ID   = v_tb_customer_after.customer_id
                      AND KYC_TYPE_CODE = v_kyc;
                END LOOP;
        END IF;
    END SP_CHG_KYC;


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
      v_tmp_add_kyc_list := json_object_t(v_json_model_clob).get_array('addKycList');
      v_tmp_del_kyc_list := json_object_t(v_json_model_clob).get_array('deleteKycList');

      IF v_tmp_add_kyc_list IS NOT NULL THEN
          FOR i IN 0 .. v_tmp_add_kyc_list.get_size - 1 LOOP
            v_add_kyc_list.extend();
            v_add_kyc_list(v_add_kyc_list.last) := v_tmp_add_kyc_list.get_string(i);
          end loop;
      END IF;

      IF v_tmp_del_kyc_list IS NOT NULL THEN
          FOR i IN 0 .. v_tmp_del_kyc_list.get_size - 1 LOOP
             v_del_kyc_list.extend();
             v_del_kyc_list(v_del_kyc_list.last) := v_tmp_del_kyc_list.get_string(i);
          end loop;
      END IF;

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
          v_change_type := 'M';
          SELECT * INTO v_tb_customer FROM CIFX.TB_CUSTOMER WHERE CUSTOMER_ID = V_RECIEIVE_CUSOTMER_ID_ARRAY(1);

          --準備異動後的v_tb_cusotmer_after rowtype物件，先塞好原值，待後續欄位覆蓋掉異動值
          SELECT * INTO v_tb_customer_after FROM CIFX.TB_CUSTOMER WHERE CUSTOMER_ID = V_RECIEIVE_CUSOTMER_ID_ARRAY(1);
          DBMS_OUTPUT.PUT_LINE('之前 v_tb_customer_after.CHILDREN_NUM:' ||v_tb_customer_after.CHILDREN_NUM );
          --逐筆Setting變更後rowtype物件
          SET_INPUT_CUSTOMER_RECORD();
         DBMS_OUTPUT.PUT_LINE('之後 v_tb_customer_after.CHILDREN_NUM:' ||v_tb_customer_after.CHILDREN_NUM );

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
           v_change_type := 'C';
           v_tb_customer := NULL;

           IF 'CIF_ORIGINAL_ID' NOT MEMBER OF v_update_column_array THEN --前面被去識別條件，若為建檔需加回
            v_update_column_array.extend();
            v_update_column_array(v_update_column_array.last) := 'CIF_ORIGINAL_ID';
           END IF;
           DBMS_OUTPUT.PUT_LINE('全欄位查詢:查無顧客');
          -- 判斷證號類型及檢核證號合法性
          CIFX.SP_VAL_CERTIFICATION_TYPE(
              I_FUNCTION => '2',
              I_CERT_NO => nvl(v_customerCertificationNumber, ' '),
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

             --呼叫檢核欄位元件
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

    -- ============= 輸入欄位業務檢核規則 START =========================================
    DBMS_OUTPUT.PUT_LINE('================ 輸入欄位業務檢核規則 START ==================');

    for v_col_rule_rec in (
        select DISTINCT RULE_ID, RULE_PROCESS from cifx.TB_COL_BUSINESS_RULE cbr
        JOIN CIFX.TB_COLUMN_CODE_OPT cc ON  CBR.COLUMN_CODE = CC.COLUMN_CODE
        where substr(cbr.RULE_ID,1,1) = 'V' --檢核
        AND REGEXP_LIKE(cbr.RULE_PROCESS,'PG_DYNC_VALI')  --仁傑測試用(待刪除)
        and cc.COLUMN_NAME IN (SELECT * FROM TABLE(v_update_column_array))  --此次檢核欄位
    )loop

        DBMS_OUTPUT.PUT_LINE('受檢欄位:' || v_tb_column_code_opt.column_code);
        DBMS_OUTPUT.PUT_LINE('變數:' || v_col_rule_rec.rule_process);
        DBMS_OUTPUT.PUT_LINE('v_cert_type:' || v_cert_type);
        EXECUTE immediate 'DECLARE BEGIN '|| v_col_rule_rec.rule_process || '( I_INPUT_JSON => :1 , I_TB_CUSTOMER => :2, I_tb_customer_after => :3 , I_TX_ID => :4 , I_SENDER_CODE => :5 , I_CERT_TYPE => :6 , I_CHANGE_TYPE => :7 ); END;'
        using IN I_INPUT_JSON,IN v_tb_customer,IN v_tb_customer_after,IN v_tx_id,IN v_header_sender_code,IN v_cert_type,IN v_change_type;

    end loop;
    DBMS_OUTPUT.PUT_LINE('================ 欄位異動業務處理邏輯 END ==================');

    SP_VAL_KYC();--檢核KYC

    for v_cascade_rule_rec in ( --連動非KYC之欄位
        select DISTINCT RULE_ID, RULE_PROCESS, cc2.COLUMN_NAME AS CHANGED_COLUMN_NAME from CIFX.TB_COL_CASCADE_RULE ccr
        JOIN CIFX.TB_COLUMN_CODE_OPT cc ON  CCR.COLUMN_CODE = CC.COLUMN_CODE
        JOIN CIFX.TB_COLUMN_CODE_OPT cc2 ON  CCR.CHANGED_COLUMN_CODE = CC2.COLUMN_CODE AND CC2.COLUMN_NAME <> 'KYC_TYPE_CODE' --
        where cc.COLUMN_NAME MEMBER OF v_update_column_array --此次檢核欄位
    )loop
           EXECUTE immediate   'DECLARE BEGIN '|| v_cascade_rule_rec.rule_process || '( I_INPUT_JSON => :1 , I_TB_CUSTOMER => :2, I_TB_CUSTOMER_AFTER => :3 , I_TX_ID => :4 , I_SENDER_CODE => :5 , I_CERT_TYPE => :6 , I_CHANGE_TYPE => :7); END;'
           using IN I_INPUT_JSON,IN v_tb_customer,IN OUT v_tb_customer_after,IN v_tx_id,IN v_header_sender_code,IN v_cert_type,IN v_change_type;
           IF v_cascade_rule_rec.CHANGED_COLUMN_NAME NOT MEMBER OF v_update_column_array THEN
               v_update_column_array.extend();
               v_update_column_array(v_update_column_array.last) := v_cascade_rule_rec.CHANGED_COLUMN_NAME;
           END IF;
    end loop;

    --取得KYC改前值
    IF v_change_type = 'C' THEN
        v_before_kyc := null;
    ELSE
      select LISTAGG(KYC_TYPE_CODE, ',') WITHIN GROUP (ORDER BY KYC_TYPE_CODE)  into v_before_kyc
      from CIFX.TB_CUST_KYC
      where CIRCI_KEY=v_tb_customer_after.CIF_VERIFIED_ID;
    END IF;

    for v_cascade_rule_kyc_rec in ( --KYC之欄位
        select DISTINCT RULE_ID, RULE_PROCESS, cc2.COLUMN_NAME AS CHANGED_COLUMN_NAME from CIFX.TB_COL_CASCADE_RULE ccr
        JOIN CIFX.TB_COLUMN_CODE_OPT cc ON  CCR.COLUMN_CODE = CC.COLUMN_CODE
        JOIN CIFX.TB_COLUMN_CODE_OPT cc2 ON  CCR.CHANGED_COLUMN_CODE = CC2.COLUMN_CODE AND CC2.COLUMN_NAME = 'KYC_TYPE_CODE'
        where cc.COLUMN_NAME MEMBER OF v_update_column_array --此次檢核欄位
    )loop
           EXECUTE immediate   'DECLARE BEGIN '|| v_cascade_rule_kyc_rec.rule_process || '( I_TB_CUSTOMER => :1, I_TB_CUSTOMER_AFTER => :2 , I_ADD_KYC_LIST => :3 , I_DELETE_KYC_LIST => :4); END;'
           using IN v_tb_customer,IN v_tb_customer_after,IN OUT v_add_kyc_list,IN OUT v_del_kyc_list;
    end loop;

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
--     v_customer_id := '1560268960297199-1370570-15-01';--待刪除
--     SELECT * INTO v_tb_customer_after FROM CIFX.TB_CUSTOMER WHERE CUSTOMER_ID = v_customer_id;

    SP_CHG_KYC(); --

    select LISTAGG(KYC_TYPE_CODE, ',') WITHIN GROUP (ORDER BY KYC_TYPE_CODE)  into v_changed_kyc
    from CIFX.TB_CUST_KYC
    where CIRCI_KEY=v_tb_customer_after.CIF_VERIFIED_ID;

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

