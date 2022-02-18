--------------------------------------------------------
--  DDL for Package PG_UPDATE_ALL_KYC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CIFX"."PG_UPDATE_ALL_KYC" AS

  PROCEDURE SP_UPDATE_ALL_KYC(
  I_CUSTOMER_ID VARCHAR2,
  I_ADD_KYC_LIST_WITH_COMMA VARCHAR2,
  I_DELETE_KYC_LIST_WITH_COMMA VARCHAR2,
  I_SERVICE_INTERCHANGE_ID VARCHAR2,
  I_CHANGE_LOG_ID VARCHAR2
  );

END PG_UPDATE_ALL_KYC;

/
--------------------------------------------------------
--  DDL for Package Body PG_UPDATE_ALL_KYC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CIFX"."PG_UPDATE_ALL_KYC" AS

  PROCEDURE sp_update_all_kyc(
    i_customer_id VARCHAR2,i_add_kyc_list_with_comma VARCHAR2,i_delete_kyc_list_with_comma VARCHAR2,i_service_interchange_id VARCHAR2,
    i_change_log_id VARCHAR2
  )AS
    v_sql VARCHAR2(3000 CHAR):= '';

  --kyc
    v_addkyclist_str VARCHAR2(3000 CHAR):= '';
    v_deletekyclist_str VARCHAR2(3000 CHAR):= '';
    TYPE bulk_kyc_type_code_type IS
      TABLE OF cifx.tb_cust_kyc.kyc_type_code%TYPE INDEX BY PLS_INTEGER;
    v_bulk_kyc_type_code bulk_kyc_type_code_type;
    v_cust_ori_kyc_array input_tb_var_array := input_tb_var_array();  --顧客原有kycTypeCodeArray
    v_cust_addkyclist_array input_tb_var_array := input_tb_var_array();  --顧客此次輸入addKycList
    v_cust_deletekyclist_array input_tb_var_array := input_tb_var_array();  --顧客此次輸入deleteKycList

    kyc_cnt BINARY_INTEGER;
    kyc_array dbms_utility.lname_array;
    v_kyc_value_valid_count INTEGER := 0;
    v_circi_key VARCHAR2(3000 CHAR):= '';
    v_cust_cnt INTEGER := 0;
    v_ori_cust_kyc_with_comma VARCHAR2(3000 CHAR):= '';
    v_chgd_cust_kyc_with_comma VARCHAR2(3000 CHAR):= '';
    v_changed_column_code_id VARCHAR2(3000 CHAR):= '';
    v_change_log_id cifx.tb_change_log.change_log_id%TYPE;
    v_service_interchange_id cifx.tb_service_interchange.service_interchange_id%TYPE;
  BEGIN
    dbms_output.put_line('======== SP_UPDATE_ALL_KYC START ========');
    v_change_log_id := i_change_log_id;

   --確認顧客筆數為1筆
    SELECT COUNT(1)
    INTO v_cust_cnt
    FROM cifx.tb_customer
    WHERE customer_id = i_customer_id;
    IF v_cust_cnt <> 1 THEN
      cifx.pg_throw_err.sp_throw_err('0918');
    END IF;
    SELECT cif_verified_id
    INTO v_circi_key
    FROM cifx.tb_customer
    WHERE customer_id = i_customer_id;

   --取得異動前kyc字串
    SELECT
      LISTAGG(kyc_type_code,',')WITHIN GROUP(
      ORDER BY kyc_type_code)
    INTO v_ori_cust_kyc_with_comma
    FROM cifx.tb_cust_kyc
    WHERE circi_key = v_circi_key;
    dbms_output.put_line('異動前kyc字串(有逗號):'
                         || v_ori_cust_kyc_with_comma);

    --取得顧客原有kyc
    v_sql := 'SELECT KYC_TYPE_CODE FROM CIFX.TB_CUST_KYC WHERE CUSTOMER_ID = '
             || ''''
             || i_customer_id
             || '''';
--    v_sql := 'SELECT KYC_TYPE_CODE FROM CIFX.TB_CUST_KYC WHERE CUSTOMER_ID = ' || '''' || '1560268960297199-1370570-15-01' || '''';
    EXECUTE IMMEDIATE v_sql
    BULK COLLECT
    INTO v_bulk_kyc_type_code;
    FOR i IN 1..v_bulk_kyc_type_code.count LOOP
       --將顧客原有kycTypeCode加入v_cust_ori_kyc_array存放
      IF v_bulk_kyc_type_code(i)NOT MEMBER OF v_cust_ori_kyc_array THEN
        v_cust_ori_kyc_array.extend();
        v_cust_ori_kyc_array(v_cust_ori_kyc_array.last):= v_bulk_kyc_type_code(i);
      END IF;
    END LOOP;

      --顧客原有kyc驗證
    FOR i IN 1..v_cust_ori_kyc_array.count LOOP
      dbms_output.put_line('顧客原有kyc:'
                           || v_cust_ori_kyc_array(i));
    END LOOP;


     --處理add kyc字串
    IF i_add_kyc_list_with_comma IS NOT NULL THEN
      dbms_utility.comma_to_table(
                                 list => regexp_replace(
                                   i_add_kyc_list_with_comma,'(^|,)','\1x'
                                 ),tablen => kyc_cnt,tab => kyc_array
      );
      dbms_output.put_line('kyc_cnt:'
                           || kyc_cnt);
      FOR i IN 1..kyc_cnt LOOP
        --將addKycLisst解析出的單個字串加到array
        IF substr(
          kyc_array(i),2
        )NOT MEMBER OF v_cust_addkyclist_array THEN
          v_cust_addkyclist_array.extend();
          v_cust_addkyclist_array(v_cust_addkyclist_array.last):= substr(
                                                                        kyc_array(i),2
                                                                  );
        END IF;
      END LOOP;
    END IF;

     --驗證addlist
    FOR i IN 1..v_cust_addkyclist_array.count LOOP
      dbms_output.put_line('v_cust_addKycList_array:'
                           || v_cust_addkyclist_array(i));
    END LOOP;
    dbms_output.put_line('==============  delte kyc str ==========');
  --處理delete kyc字串
    IF i_delete_kyc_list_with_comma IS NOT NULL THEN
      dbms_utility.comma_to_table(
                                 list => regexp_replace(
                                   i_delete_kyc_list_with_comma,'(^|,)','\1x'
                                 ),tablen => kyc_cnt,tab => kyc_array
      );
      dbms_output.put_line('kyc_cnt:'
                           || kyc_cnt);
      FOR i IN 1..kyc_cnt LOOP
        --將delete KycLisst解析出的單個字串加到array
        IF substr(
          kyc_array(i),2
        )NOT MEMBER OF v_cust_deletekyclist_array THEN
          v_cust_deletekyclist_array.extend();
          v_cust_deletekyclist_array(v_cust_deletekyclist_array.last):= substr(
                                                                              kyc_array(i),2
                                                                        );
        END IF;
      END LOOP;
    --驗證delete kyc
      FOR i IN 1..v_cust_deletekyclist_array.count LOOP
        dbms_output.put_line('v_cust_deleteKycList_array:'
                             || v_cust_deletekyclist_array(i));
      END LOOP;
    END IF;


  --todo檢核kyc
    FOR i IN 1..v_cust_addkyclist_array.count LOOP
      SELECT COUNT(1)
      INTO v_kyc_value_valid_count
      FROM cifx.tb_key_value_code
      WHERE code_category = 'kyc_type_code' AND code_value = v_cust_addkyclist_array(i);
      IF v_kyc_value_valid_count = 0 THEN
        cifx.pg_throw_err.sp_throw_err('0815%通用代碼表查無此身份別:'
                                       || v_cust_addkyclist_array(i));
      END IF;
    END LOOP;

    FOR i IN 1..v_cust_deletekyclist_array.count LOOP
      SELECT COUNT(1)
      INTO v_kyc_value_valid_count
      FROM cifx.tb_key_value_code
      WHERE code_category = 'kyc_type_code' AND code_value = v_cust_deletekyclist_array(i);
      IF v_kyc_value_valid_count = 0 THEN
        cifx.pg_throw_err.sp_throw_err('0815%通用代碼表查無此身份別:'
                                       || v_cust_deletekyclist_array(i));
      END IF;
    END LOOP;

  --todo異動kyc
  --addKyc
    FOR i IN 1..v_cust_addkyclist_array.count LOOP
    --只新增原顧客kyc沒有的部份
      IF v_cust_addkyclist_array(i)NOT MEMBER OF v_cust_ori_kyc_array THEN
        INSERT INTO cifx.tb_cust_kyc(
          cust_kyc_id,circi_key,customer_id,kyc_type_code
        )VALUES(
          cifx.pg_common.fn_get_uuid,v_circi_key,i_customer_id,v_cust_addkyclist_array(i)
        );
        dbms_output.put_line('增加kyc:'
                             || v_cust_addkyclist_array(i));
      END IF;
    END LOOP;

    FOR i IN 1..v_cust_deletekyclist_array.count LOOP
      IF v_cust_deletekyclist_array(i)MEMBER OF v_cust_ori_kyc_array THEN
        DELETE cifx.tb_cust_kyc
        WHERE customer_id = i_customer_id AND kyc_type_code = v_cust_deletekyclist_array(i);
        dbms_output.put_line('刪除kyc:'
                             || v_cust_deletekyclist_array(i));
      END IF;
    END LOOP;


  --todo寫kyc異動紀錄
  --取得異動後kyc字串
    SELECT
      LISTAGG(kyc_type_code,',')WITHIN GROUP(
      ORDER BY kyc_type_code)
    INTO v_chgd_cust_kyc_with_comma
    FROM cifx.tb_cust_kyc
    WHERE circi_key = v_circi_key;
    dbms_output.put_line('異動後kyc字串(有逗號):'
                         || v_chgd_cust_kyc_with_comma);
    IF nvl(
          v_chgd_cust_kyc_with_comma,' '
       )<> nvl(
              v_ori_cust_kyc_with_comma,' '
           )THEN
      SELECT column_code_id
      INTO v_changed_column_code_id
      FROM cifx.tb_column_code
      WHERE table_name = 'TB_CUST_KYC' AND column_name = 'KYC_TYPE_CODE';

         --沒有主檔異動紀錄存在，自己取號
      v_change_log_id := cifx.pg_common.fn_get_uuid;

      --寫異動紀錄主檔
--            CIFX.SP_INSERT_TB_CHANGE_LOG_FOR_EDLS(
--            I_CHANGE_LOG_ID => v_change_log_id,
--            I_SERVICE_INTERCHANGE_ID => v_service_interchange_id,
--            I_CIRCI_KEY => v_circi_key,
--            I_SOURCE_TYPE => '10',
--            I_ORI_TRADE_SEQ_NO => trim(I_MES_NUM),
--            I_TXN_OPERATION_DATE => TO_CHAR(SYSDATE ,'yyyymmdd'),
--            I_TXN_SEQUENCE => TRIM(I_PRO_UNI)||trim(I_MES_NUM),
--            I_TXN_OPERATION_TIME => TO_CHAR(SYSDATE ,'hh24miss'),
--            I_SUPERVISOR_CODE => null,
--            I_TX_ID => trim(I_TRA_SEQ),
--            I_BRANCH_ID =>  TRIM(I_PRO_UNI),
--            I_TELLER_ID => TRIM(I_TEL_EMP_NUM),
--            I_OPERATE_ID => null,
--            I_SUPERVISOR_ID => TRIM(I_SUP_EMP_NUM),
--            I_SUPERVISOR_CARD_CODE => NULL,
--            I_FORCE_UPDATE => v_force_update,
--            I_NO_SEND_TO_CIP_FLAG => NULL,
--            I_TXN_TIME => TO_TIMESTAMP(TRIM(I_TRA_DAT_TIM),'yyyymmdd hh24miss'),
--            I_TRADE_DATE_IN_AP => SUBSTR(TRIM(I_TRA_DAT_TIM),1,8),
--            I_TRADE_TIME_IN_AP => SUBSTR(TRIM(I_TRA_DAT_TIM),10,6),
--            I_EDLS_ORI_TRADE_SEQ_NO => I_EDLS_ORI_TRADE_SEQ_NO,
--            I_EDLS_SOURCE_CODE => I_EDLS_SOURCE_CODE,
--            I_EDLS_SUPERVISOR_CARD_CODE => I_EDLS_SUPERVISOR_CARD_CODE,
--            I_SENDER_CODE => I_SEN_COD
--          );

          --寫異動紀錄明細檔
--          CIFX.SP_INSERT_CHANGE_LOG_LINEITEM(
--            I_CHANGE_LOG_LINEITEM_ID => CIFX.FN_UUID_NUMBER30,
--            I_CHANGE_LOG_ID => v_change_log_id,
--            I_TABLE_PK => REC_CUST.CUSTOMER_ID,
--            I_MSG_NO => I_MES_NUM,--因為INSERT SERVICE_INTERCHANGE是用這個
--            I_SENT_PRIORITY => '1',
--            I_FUNC_ID => 'FUNC_001',
--            I_CHANGE_TYPE => CASE WHEN v_change_type = 'B' THEN 'C'  WHEN v_change_type = 'L' THEN 'M' ELSE NULL END,
--            I_CHANGED_COLUMN_CODE_ID => v_changed_column_code_id,
--            I_BEFORE_VALUE => CASE WHEN v_change_type = 'B' or v_change_type = 'C' then null else  V_BEFORE_KYC_WITH_COMMON end ,
--            I_CHANGED_VALUE => V_CHANGED_KYC_WITH_COMMON,
--            I_SENT_TIMESTAMP => NULL,
--            I_CIRCI_KEY => v_Return,
--            I_PROPERTY_TYPE_CODE => REC_CUST.PROPERTY_TYPE_CODE,
--            I_CIF_ORIGINAL_ID => REC_CUST.CIF_ORIGINAL_ID,
--            I_BIRTHDAY => REC_CUST.BIRTHDAY
--          );



    END IF;



    dbms_output.put_line('======== SP_UPDATE_ALL_KYC END ========');
  END sp_update_all_kyc;

END pg_update_all_kyc;

/
