DECLARE

v_sql varchar2(4000 char) := '';
V_EXTENSION_UUID INTEGER := 0 ;

TYPE t_mapping_addr_ext IS TABLE OF cifx_batch.TT_ADDR_MAPPING_EXTENSION%ROWTYPE;
mapping_addr_ext_bulk   t_mapping_addr_ext;

type r_mapping_addr_ext_record is record(
old_addr cifx_batch.TT_ADDR_MAPPING_EXTENSION.old_addr%type,
new_addr cifx_batch.TT_ADDR_MAPPING_EXTENSION.new_addr%type
);
type t_mapping_addr is table of r_mapping_addr_ext_record;
v_mapping_addr_ext_bulk t_mapping_addr;


V_CASE_TYPE VARCHAR2(40 CHAR);
v_tmp_regi_addr_detail varchar2(200 char);
v_tmp_cont_addr_detail varchar2(200 char);
v_seq number := 0;
v_regi_addr_changed boolean := FALSE;
v_cont_addr_changed boolean := FALSE;

TYPE v_map_type IS TABLE OF VARCHAR2(3000) INDEX BY VARCHAR2(3000);
v_model_json_map v_map_type;
v_city varchar2(100 char) := '';
v_area varchar2(100 char) := '';


BEGIN
DBMS_OUTPUT.PUT_LINE('============== ADDR MAPPING OPERATION START ===============');
DBMS_OUTPUT.ENABLE(buffer_size => null);

--clear data
v_sql := 'truncate table cifx_batch.TT_ADDR_MAPPING_EXTENSION';
execute immediate v_sql;
v_sql := 'truncate table CIFX_BATCH.TT_IMPT_CI_LIST';
execute immediate v_sql;


--single address mapping to multiple mapping
FOR REC_ADDR_MAPPING IN (SELECT * FROM CIFX_BATCH.TT_ADDR_MAPPING order by uuid asc)
LOOP
--    DBMS_OUTPUT.PUT_LINE('---------------- 修改地址清單(原資料) ---------------------');
--    DBMS_OUTPUT.PUT_LINE('REC_ADDR_MAPPING.UUID:' || REC_ADDR_MAPPING.UUID);
--    DBMS_OUTPUT.PUT_LINE('REC_ADDR_MAPPING.OLD_LI:' || REC_ADDR_MAPPING.OLD_LI);
--    DBMS_OUTPUT.PUT_LINE('REC_ADDR_MAPPING.OLD_NB:' || REC_ADDR_MAPPING.OLD_NB);
--    DBMS_OUTPUT.PUT_LINE('REC_ADDR_MAPPING.OLD_ADDR:'|| REC_ADDR_MAPPING.OLD_ADDR);
--    DBMS_OUTPUT.PUT_LINE('REC_ADDR_MAPPING.NEW_ADDR:'|| REC_ADDR_MAPPING.NEW_ADDR);
--    DBMS_OUTPUT.PUT_LINE('-----------------修改地址清單(擴充)--------------------');

    --EXTEND MAPPING
--    DBMS_OUTPUT.PUT_LINE('PATTERN_0:' || REC_ADDR_MAPPING.OLD_ADDR);
--    DBMS_OUTPUT.PUT_LINE('PATTERN_1:' || REGEXP_REPLACE(REC_ADDR_MAPPING.OLD_ADDR,'之','-'));
--    DBMS_OUTPUT.PUT_LINE('PATTERN_2:' || REGEXP_REPLACE(REC_ADDR_MAPPING.old_addr,
--            --取得 號 跟 樓 中間的中文數字-> 五樓
--            SUBSTR(REC_ADDR_MAPPING.old_addr,INSTR(REC_ADDR_MAPPING.old_addr,'號')+1,1)|| '樓',
--                      --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
--                       instr('一二三四五六七八九',SUBSTR(REC_ADDR_MAPPING.old_addr,INSTR(REC_ADDR_MAPPING.old_addr,'號')+1,1) ,1)||'F'));

--    DBMS_OUTPUT.PUT_LINE('PATTERN_3:' || REGEXP_REPLACE(
--                    REGEXP_REPLACE(REC_ADDR_MAPPING.old_addr,
--                            --取得 號 跟 樓 中間的中文數字-> 五樓
--                            SUBSTR(REC_ADDR_MAPPING.old_addr,INSTR(REC_ADDR_MAPPING.old_addr,'號')+1,1)|| '樓',
--                                      --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
--                                       instr('一二三四五六七八九',SUBSTR(REC_ADDR_MAPPING.old_addr,INSTR(REC_ADDR_MAPPING.old_addr,'號')+1,1) ,1)||'F')
--                    ,'之','-'));

    --INSERT EXTENSION


    V_EXTENSION_UUID := V_EXTENSION_UUID +1 ;
    INSERT INTO CIFX_BATCH.TT_ADDR_MAPPING_EXTENSION(
    UUID,GROUP_ID,PATTERN_NO,OLD_LI,OLD_NB,OLD_ADDR,NEW_ADDR)VALUES(
    V_EXTENSION_UUID,REC_ADDR_MAPPING.UUID,'PATTERN_0',REC_ADDR_MAPPING.OLD_LI,REC_ADDR_MAPPING.OLD_NB,
    REC_ADDR_MAPPING.OLD_ADDR,--PATTERN_0
    REC_ADDR_MAPPING.NEW_ADDR);

    V_EXTENSION_UUID := V_EXTENSION_UUID +1 ;
    INSERT INTO CIFX_BATCH.TT_ADDR_MAPPING_EXTENSION(
    UUID,GROUP_ID,PATTERN_NO,OLD_LI,OLD_NB,OLD_ADDR,NEW_ADDR)VALUES(
    V_EXTENSION_UUID,REC_ADDR_MAPPING.UUID,'PATTERN_1',REC_ADDR_MAPPING.OLD_LI,REC_ADDR_MAPPING.OLD_NB,
    REGEXP_REPLACE(REC_ADDR_MAPPING.OLD_ADDR,'之','－'),--PATTERN_1
    REC_ADDR_MAPPING.NEW_ADDR);

    V_EXTENSION_UUID := V_EXTENSION_UUID +1 ;
    INSERT INTO CIFX_BATCH.TT_ADDR_MAPPING_EXTENSION(
    UUID,GROUP_ID,PATTERN_NO,OLD_LI,OLD_NB,OLD_ADDR,NEW_ADDR)VALUES(
    V_EXTENSION_UUID,REC_ADDR_MAPPING.UUID,'PATTERN_2',REC_ADDR_MAPPING.OLD_LI,REC_ADDR_MAPPING.OLD_NB,
    REGEXP_REPLACE(REC_ADDR_MAPPING.old_addr,
            --取得 號 跟 樓 中間的中文數字-> 五樓
            SUBSTR(REC_ADDR_MAPPING.old_addr,INSTR(REC_ADDR_MAPPING.old_addr,'號')+1,1)|| '樓',
                      --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                       TO_MULTI_BYTE(instr('一二三四五六七八九',SUBSTR(REC_ADDR_MAPPING.old_addr,INSTR(REC_ADDR_MAPPING.old_addr,'號')+1,1) ,1))||'Ｆ'),--PATTERN_2
    REC_ADDR_MAPPING.NEW_ADDR);

    V_EXTENSION_UUID := V_EXTENSION_UUID +1 ;
    INSERT INTO CIFX_BATCH.TT_ADDR_MAPPING_EXTENSION(
    UUID,GROUP_ID,PATTERN_NO,OLD_LI,OLD_NB,OLD_ADDR,NEW_ADDR)VALUES(
    V_EXTENSION_UUID,REC_ADDR_MAPPING.UUID,'PATTERN_3',REC_ADDR_MAPPING.OLD_LI,REC_ADDR_MAPPING.OLD_NB,
    REGEXP_REPLACE(
                    REGEXP_REPLACE(REC_ADDR_MAPPING.old_addr,
                            --取得 號 跟 樓 中間的中文數字-> 五樓
                            SUBSTR(REC_ADDR_MAPPING.old_addr,INSTR(REC_ADDR_MAPPING.old_addr,'號')+1,1)|| '樓',
                                      --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                                       TO_MULTI_BYTE(instr('一二三四五六七八九',SUBSTR(REC_ADDR_MAPPING.old_addr,INSTR(REC_ADDR_MAPPING.old_addr,'號')+1,1) ,1))||'Ｆ')
                    ,'之','－'),--PATTERN_3
    REC_ADDR_MAPPING.NEW_ADDR);

    V_EXTENSION_UUID := V_EXTENSION_UUID +1 ;
    INSERT INTO CIFX_BATCH.TT_ADDR_MAPPING_EXTENSION(
    UUID,GROUP_ID,PATTERN_NO,OLD_LI,OLD_NB,OLD_ADDR,NEW_ADDR)VALUES(
    V_EXTENSION_UUID,REC_ADDR_MAPPING.UUID,'PATTERN_4',REC_ADDR_MAPPING.OLD_LI,REC_ADDR_MAPPING.OLD_NB,
    REGEXP_REPLACE(REC_ADDR_MAPPING.old_addr,
            --取得 號 跟 樓 中間的中文數字-> 五樓
            SUBSTR(REC_ADDR_MAPPING.old_addr,INSTR(REC_ADDR_MAPPING.old_addr,'號')+1,1)|| '樓',
                      --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                       TO_MULTI_BYTE(instr('一二三四五六七八九',SUBSTR(REC_ADDR_MAPPING.old_addr,INSTR(REC_ADDR_MAPPING.old_addr,'號')+1,1) ,1))||'樓'),--PATTERN_4
    REC_ADDR_MAPPING.NEW_ADDR);

    commit;

END LOOP;

--================================= 臺南市佳里區 start ======================================
v_city := '臺南市';
v_area := '佳里區';
--go through customer if mapping to TT_ADDR_MAPPING_EXTENSION
for single_cust in (
select cif_verified_id,
PER_CITY,PER_ZIP,PER_AREA,REGI_ADDRESS_DETAIL,
CONT_CITY,CUST_ZIP_CODE,CONT_AREA,CONT_ADDRESS_DETAIL
from cifx_batch.tt_customer --測試用
-- from cifx.tb_customer    --營運用
where
(per_city = v_city
and per_area = v_area
and REGI_ADDRESS_DETAIL is not null)
or
(cont_city = v_city
and cont_area = v_area
and CONT_ADDRESS_DETAIL is not null)
)
loop
--    DBMS_OUTPUT.PUT_LINE('-----------------------compare start -------------------------------');
--    =================== 單一顧客 start ===========================
--    DBMS_OUTPUT.PUT_LINE('single_cust.cif_verified_id:' || single_cust.cif_verified_id);
--    DBMS_OUTPUT.PUT_LINE('single_cust.REGI_ADDRESS_DETAIL:' || single_cust.REGI_ADDRESS_DETAIL);
--    DBMS_OUTPUT.PUT_LINE('single_cust.CONT_ADDRESS_DETAIL:' || single_cust.CONT_ADDRESS_DETAIL);
--    DBMS_OUTPUT.PUT_LINE('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    v_regi_addr_changed := false;
    v_cont_addr_changed := false;

    select old_addr,new_addr bulk collect into v_mapping_addr_ext_bulk from cifx_batch.TT_ADDR_MAPPING_EXTENSION
    group by old_addr,new_addr
    ;

    for i in v_mapping_addr_ext_bulk.first..v_mapping_addr_ext_bulk.last
    loop

--        DBMS_OUTPUT.PUT_LINE('=================== 單一地址對應 start ===========================');
        v_tmp_regi_addr_detail:= null;
        v_tmp_cont_addr_detail:= null;
        V_CASE_TYPE:= null;
--        DBMS_OUTPUT.PUT_LINE('v_mapping_addr_ext_bulk(i).old_addr:' || v_mapping_addr_ext_bulk(i).old_addr);
--        DBMS_OUTPUT.PUT_LINE('v_mapping_addr_ext_bulk(i).new_addr:' || v_mapping_addr_ext_bulk(i).new_addr);


        if REGEXP_LIKE(nvl(single_cust.REGI_ADDRESS_DETAIL,' '),'(' || v_mapping_addr_ext_bulk(i).old_addr || '){1}$') then
--         DBMS_OUTPUT.PUT_LINE('居住地有改');
--         DBMS_OUTPUT.PUT_LINE('顧客原居住地:' || single_cust.REGI_ADDRESS_DETAIL);
--         DBMS_OUTPUT.PUT_LINE('比對舊的地址:' || v_mapping_addr_ext_bulk(i).old_addr );
--         DBMS_OUTPUT.PUT_LINE('比對新的地址:' || v_mapping_addr_ext_bulk(i).new_addr);
--         DBMS_OUTPUT.PUT_LINE('顧客新居住地:' || replace(single_cust.REGI_ADDRESS_DETAIL,v_mapping_addr_ext_bulk(i).old_addr,v_mapping_addr_ext_bulk(i).new_addr));
        v_regi_addr_changed := true;
        v_model_json_map('change_regi_addr') := replace(single_cust.REGI_ADDRESS_DETAIL,v_mapping_addr_ext_bulk(i).old_addr,v_mapping_addr_ext_bulk(i).new_addr);
        end if;

        if REGEXP_LIKE(nvl(single_cust.CONT_ADDRESS_DETAIL,' '),'(' || v_mapping_addr_ext_bulk(i).old_addr || '){1}$') then
--         DBMS_OUTPUT.PUT_LINE('通訊地有改');
--         DBMS_OUTPUT.PUT_LINE('顧客原通訊地:' || single_cust.CONT_ADDRESS_DETAIL);
--         DBMS_OUTPUT.PUT_LINE('比對舊的地址:' ||v_mapping_addr_ext_bulk(i).old_addr );
--         DBMS_OUTPUT.PUT_LINE('比對新的地址:' ||v_mapping_addr_ext_bulk(i).new_addr );
--         DBMS_OUTPUT.PUT_LINE('顧客新通訊地:' || replace(single_cust.CONT_ADDRESS_DETAIL,v_mapping_addr_ext_bulk(i).old_addr,v_mapping_addr_ext_bulk(i).new_addr));
        v_cont_addr_changed := true;
        v_model_json_map('change_cont_addr') := replace(single_cust.CONT_ADDRESS_DETAIL,v_mapping_addr_ext_bulk(i).old_addr,v_mapping_addr_ext_bulk(i).new_addr);
        end if;
--        DBMS_OUTPUT.PUT_LINE('=================== 單一地址對應 end ===========================');
    end loop;




     --多個地址比完的結果

      if v_regi_addr_changed and not v_cont_addr_changed then
         V_CASE_TYPE := '居住地轉換/通訊地不變';
         v_tmp_regi_addr_detail := v_model_json_map('change_regi_addr');
         v_tmp_cont_addr_detail := null;
     elsif not v_regi_addr_changed and v_cont_addr_changed then
         V_CASE_TYPE := '通訊地轉換/居住地不變';
         v_tmp_cont_addr_detail := v_model_json_map('change_cont_addr');
         v_tmp_regi_addr_detail := null;
      elsif v_regi_addr_changed and v_cont_addr_changed then
         V_CASE_TYPE := '通訊地/居住地都轉換';
         v_tmp_cont_addr_detail := v_model_json_map('change_cont_addr');
         v_tmp_regi_addr_detail := v_model_json_map('change_regi_addr');
      else
         V_CASE_TYPE := '無對應地址';
     end if;


     if V_CASE_TYPE <> '無對應地址' then


--      DBMS_OUTPUT.PUT_LINE('@@@@@@@@@@@@@  寫入前CHCK @@@@@@@@@@@');
--      DBMS_OUTPUT.PUT_LINE('v_tmp_regi_addr_detail:' ||v_tmp_regi_addr_detail);
--      DBMS_OUTPUT.PUT_LINE('v_tmp_cont_addr_detail:' ||v_tmp_cont_addr_detail);
--      DBMS_OUTPUT.PUT_LINE('V_CASE_TYPE：'|| V_CASE_TYPE);


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
                  single_cust.CIF_VERIFIED_ID,
                  single_cust.REGI_ADDRESS_DETAIL,    --ORI
                  v_tmp_regi_addr_detail,                 --CHG
                  single_cust.PER_CITY,
                  single_cust.PER_ZIP,
                  single_cust.PER_AREA,
                  single_cust.CONT_ADDRESS_DETAIL,     --ORI
                  v_tmp_cont_addr_detail,                                      --CHG_CONT_ADDRESS_DETAIL
                  single_cust.CONT_CITY,
                  single_cust.CUST_ZIP_CODE,
                  single_cust.CONT_AREA,
                  V_CASE_TYPE                                    --ERROR MESSAGE
              );
            COMMIT;

      end if;

--    DBMS_OUTPUT.PUT_LINE('-----------------------compare end -------------------------------');
    --=================== 單一顧客 end ===========================
end loop;
--================================= 臺南市佳里區 end ======================================





DBMS_OUTPUT.PUT_LINE('============== ADDR MAPPING OPERATION END ===============');
END;