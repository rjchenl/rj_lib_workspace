
declare
    v_tmp_regi_addr_detail varchar2(200 char);
    v_tmp_cont_addr_detail varchar2(200 char);
    v_impact_reg_cnt number;
    v_impact_cnt_cnt number;
    v_handled_count number;  --已處理過顧客資料筆數
    type t_fetch_table is table of cifx.tb_customer%ROWTYPE;
    IMPACT_CUSTS T_FETCH_TABLE;
    IMPACT_CONT_CUSTS T_FETCH_TABLE;
    v_seq number := 0;
    V_CASE_TYPE VARCHAR2(40 CHAR);
    V_SQL  varchar2(4000 char);
begin
    DBMS_OUTPUT.PUT_LINE('==== test start =====');
    DBMS_OUTPUT.ENABLE(9000000);
    for tmp in (select * from CIFX_BATCH.tt_reg_cmp )
        loop
        --======================= 單一整編地址 START ===================
        --整編地址異動數(居住地)
            select count(1) into v_impact_reg_cnt  from cifx.tb_customer
            where REGEXP_LIKE (REGI_ADDRESS_DETAIL,'(' || tmp.old_regadr || '){1}$');
            --整編地址異動數(通訊地)
            select count(1) into v_impact_cnt_cnt  from cifx.tb_customer
            where REGEXP_LIKE (CONT_ADDRESS_DETAIL,'(' || tmp.old_regadr || '){1}$');

            update CIFX_BATCH.tt_reg_cmp
            set REG_IMPACT_CNT = v_impact_reg_cnt,
                CON_IMPACT_CNT = v_impact_cnt_cnt,
                AMEND_TIME = SYSDATE
            where UUID = tmp.UUID;
            commit;
           
           IF v_impact_reg_cnt + v_impact_cnt_cnt > 0 THEN
                    
           
            
            --===============影響清單作業 START ==================
            SELECT * BULK COLLECT INTO IMPACT_CUSTS
            FROM CIFX.TB_CUSTOMER
            where REGEXP_LIKE (REGI_ADDRESS_DETAIL,'(' || tmp.old_regadr || '){1}$')
               OR REGEXP_LIKE (CONT_ADDRESS_DETAIL,'(' || tmp.old_regadr || '){1}$')
            ;
            FOR I IN IMPACT_CUSTS.FIRST..IMPACT_CUSTS.LAST
                LOOP
                    --=================== 單一顧客 start ===========================

                    v_tmp_regi_addr_detail := IMPACT_CUSTS(I).REGI_ADDRESS_DETAIL; --原始 居住地
                    v_tmp_cont_addr_detail := IMPACT_CUSTS(I).CONT_ADDRESS_DETAIL;  --原始 通訊地

                    IF REGEXP_LIKE(IMPACT_CUSTS(I).REGI_ADDRESS_DETAIL,tmp.old_regadr)
                        AND NOT REGEXP_LIKE(IMPACT_CUSTS(I).CONT_ADDRESS_DETAIL,tmp.old_regadr) THEN
                        --居住地轉換/通訊地不變
                        v_tmp_regi_addr_detail := replace(v_tmp_regi_addr_detail,tmp.old_regadr,tmp.NEW_REGADR);
                        v_tmp_cont_addr_detail := NULL;
                        V_CASE_TYPE := '居住地轉換/通訊地不變';
                    ELSIF REGEXP_LIKE(IMPACT_CUSTS(I).CONT_ADDRESS_DETAIL,tmp.old_regadr)
                        AND NOT REGEXP_LIKE(IMPACT_CUSTS(I).REGI_ADDRESS_DETAIL,tmp.old_regadr) THEN
                        --通訊地轉換/居住地不變
                        v_tmp_cont_addr_detail := replace(v_tmp_cont_addr_detail,tmp.old_regadr,tmp.NEW_REGADR);
                        v_tmp_regi_addr_detail := NULL;
                        V_CASE_TYPE := '通訊地轉換/居住地不變';
                    ELSIF REGEXP_LIKE(IMPACT_CUSTS(I).CONT_ADDRESS_DETAIL,tmp.old_regadr)
                        AND REGEXP_LIKE(IMPACT_CUSTS(I).REGI_ADDRESS_DETAIL,tmp.old_regadr) THEN
                        --居住他/通訊地 都轉換
                        v_tmp_regi_addr_detail := replace(v_tmp_regi_addr_detail,tmp.old_regadr,tmp.NEW_REGADR);
                        v_tmp_cont_addr_detail := replace(v_tmp_cont_addr_detail,tmp.old_regadr,tmp.NEW_REGADR);
                        V_CASE_TYPE := '通訊地/居住地都轉換';
                    END IF;

                    v_seq  := v_seq + 1 ;
                    INSERT INTO CIFX_BATCH.TT_IMPT_CI_LIST
                    (SEQ_NUM,
                     CIRCI_KEY,
                     REGI_ADDRESS_DETAIL,
                     CHG_REGI_ADDRESS_DETAIL,
                     PER_CITY,
                     PER_ZIP,
                     PER_AREA,
                     CONT_ADDRESS_DETAIL,
                     CHG_CONT_ADDRESS_DETAIL,
                     CONT_CITY,
                     CUST_ZIP_CODE,
                     CONT_AREA,
                     RESULT_MSG)
                    values(
                              v_seq,
                              IMPACT_CUSTS(I).CIF_VERIFIED_ID,
                              IMPACT_CUSTS(I).REGI_ADDRESS_DETAIL,    --ORI
                              v_tmp_regi_addr_detail,                 --CHG
                              IMPACT_CUSTS(I).PER_CITY,
                              IMPACT_CUSTS(I).PER_ZIP,
                              IMPACT_CUSTS(I).PER_AREA,
                              IMPACT_CUSTS(I).CONT_ADDRESS_DETAIL,     --ORI
                              v_tmp_cont_addr_detail,                                      --CHG_CONT_ADDRESS_DETAIL
                              IMPACT_CUSTS(I).CONT_CITY,
                              IMPACT_CUSTS(I).CUST_ZIP_CODE,
                              IMPACT_CUSTS(I).CONT_AREA,
                              V_CASE_TYPE                                    --ERROR MESSAGE
                          );
                    COMMIT;
                    --=================== 單一顧客 end  ===========================
                END LOOP;
          --===============影響清單作業 END ==================
          
          ELSE
          --地址未影響
          update CIFX_BATCH.tt_reg_cmp
            set REG_IMPACT_CNT = v_impact_reg_cnt,
                CON_IMPACT_CNT = v_impact_cnt_cnt,
                AMEND_TIME = SYSDATE,
                NOTE = '未受影響'
            where UUID = tmp.UUID;
            commit;
          
          END IF;


            --======================= 單一整編地址 END ===================
        end loop;


        DBMS_OUTPUT.PUT_LINE('==== test end =====');

end;



