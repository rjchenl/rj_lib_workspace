DECLARE

cursor mapping_cursor_type is
select * from cifx_batch.tt_addr_mapping order by uuid asc;

rec_map mapping_cursor_type%rowtype;



v_seq number := 0;

type t_fetch_table is table of cifx.tb_customer%ROWTYPE;
IMPACT_CUSTS_BULK_OF_PATTERN_0  T_FETCH_TABLE;
IMPACT_CUSTS_BULK_OF_PATTERN_1  T_FETCH_TABLE;
IMPACT_CUSTS_BULK_OF_PATTERN_2  T_FETCH_TABLE;
IMPACT_CUSTS_BULK_OF_PATTERN_3  T_FETCH_TABLE;

IMPACT_CUSTS_BULK_OF_PATTERN_0_0 T_FETCH_TABLE;
IMPACT_CUSTS_BULK_OF_PATTERN_1_1 T_FETCH_TABLE;
IMPACT_CUSTS_BULK_OF_PATTERN_2_2 T_FETCH_TABLE;
IMPACT_CUSTS_BULK_OF_PATTERN_3_3 T_FETCH_TABLE;



TYPE varrary_type IS TABLE OF VARCHAR2(256 CHAR);
  v_pattern_array    varrary_type := varrary_type();

-------------------------------------------------------
--                     REGI_ADDRESS_DETAIL,
--                     PER_CITY,
--                     PER_ZIP,
--                     PER_AREA,
--                     CONT_ADDRESS_DETAIL,
--                     CONT_CITY,
--                     CUST_ZIP_CODE,
--                     CONT_AREA,
-------------------------- 內部函數 ----------------------------

  PROCEDURE SP_INSERT_TMP(
  i_rec_map mapping_cursor_type%rowtype,
  i_impact_cust_bulk T_FETCH_TABLE,
  i_index integer
  )
  IS
  i_tmp_regi_addr_detail varchar2(200 char):= '';
  i_tmp_cont_addr_detail varchar2(200 char) := '';
  I_CASE_TYPE varchar2(200 char) := '';
  BEGIN
      IF REGEXP_LIKE(i_impact_cust_bulk(i_index).REGI_ADDRESS_DETAIL,i_rec_map.old_addr)
        AND NOT REGEXP_LIKE(i_impact_cust_bulk(i_index).CONT_ADDRESS_DETAIL,i_rec_map.old_addr) THEN
        --戶籍地轉換/通訊地不變
        i_tmp_regi_addr_detail := replace(i_impact_cust_bulk(i_index).REGI_ADDRESS_DETAIL,i_rec_map.old_addr,i_rec_map.new_addr);
        i_tmp_cont_addr_detail := NULL;
        I_CASE_TYPE := '戶籍地轉換/通訊地不變';
    ELSIF REGEXP_LIKE(i_impact_cust_bulk(i_index).CONT_ADDRESS_DETAIL,i_rec_map.old_addr)
        AND NOT REGEXP_LIKE(i_impact_cust_bulk(i_index).REGI_ADDRESS_DETAIL,i_rec_map.old_addr) THEN
        --通訊地轉換/戶籍地不變
        i_tmp_cont_addr_detail := replace(i_impact_cust_bulk(i_index).CONT_ADDRESS_DETAIL,i_rec_map.old_addr,i_rec_map.new_addr);
        i_tmp_regi_addr_detail := NULL;
        I_CASE_TYPE := '通訊地轉換/戶籍地不變';
    ELSIF REGEXP_LIKE(i_impact_cust_bulk(i_index).CONT_ADDRESS_DETAIL,i_rec_map.old_addr)
        AND REGEXP_LIKE(i_impact_cust_bulk(i_index).REGI_ADDRESS_DETAIL,i_rec_map.old_addr) THEN
        --戶籍他/通訊地都轉換
        i_tmp_regi_addr_detail := replace(i_impact_cust_bulk(i_index).REGI_ADDRESS_DETAIL,i_rec_map.old_addr,i_rec_map.new_addr);
        i_tmp_cont_addr_detail := replace(i_impact_cust_bulk(i_index).CONT_ADDRESS_DETAIL,i_rec_map.old_addr,i_rec_map.new_addr);
        I_CASE_TYPE := '戶籍他/通訊地都轉換';
    END IF;

     DBMS_OUTPUT.PUT_LINE('i_tmp_regi_addr_detail:'|| i_tmp_regi_addr_detail);
     DBMS_OUTPUT.PUT_LINE('i_tmp_cont_addr_detail:'|| i_tmp_cont_addr_detail);
     DBMS_OUTPUT.PUT_LINE('I_CASE_TYPE:'|| I_CASE_TYPE);

  END;


   function FN_number_To_Ch_number(
   v_input_number IN VARCHAR2
   )return varchar
   IS
   begin
   RETURN SUBSTR('一二三四五六七八九',v_input_number,1);
   end;

   function FN_Ch_Number_To_NUMBER(
   v_input_number IN VARCHAR2
   )return varchar
   IS
   begin
   RETURN instr('一二三四五六七八九',v_input_number,1);
   end;

   procedure sp_insert_impact_list(
   i_customer in cifx.tb_customer%ROWTYPE)
   is

   begin
   DBMS_OUTPUT.PUT_LINE('我是傳進來的customer:' || i_customer.cif_verified_Id);
--   insert into cifx_batch.tt_impt_ci_list(
--   SEQ_NUM, CIRCI_KEY, REGI_ADDRESS_DETAIL, CHG_REGI_ADDRESS_DETAIL, PER_CITY, PER_ZIP, PER_AREA, CONT_ADDRESS_DETAIL, CHG_CONT_ADDRESS_DETAIL, CONT_CITY, CUST_ZIP_CODE, CONT_AREA, RESULT_MSG,
--   )




   end;


BEGIN
DBMS_OUTPUT.PUT_LINE('======== TEST START =========');


for v_addr_mapping in (select * from cifx_batch.tt_addr_mapping order by uuid asc)
loop

--------------------------------取得單一地址對映資料 開始-------------------------
DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------');
DBMS_OUTPUT.PUT_LINE('v_addr_mapping.old_li:' || v_addr_mapping.old_li);  --舊里
DBMS_OUTPUT.PUT_LINE('v_addr_mapping.old_nb:' || v_addr_mapping.old_nb);  --舊鄰
DBMS_OUTPUT.PUT_LINE('v_addr_mapping.old_addr:' || v_addr_mapping.old_addr);  --舊地址
DBMS_OUTPUT.PUT_LINE('v_addr_mapping.new_addr:' || v_addr_mapping.new_addr);  --新地址
DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------');


DBMS_OUTPUT.PUT_LINE('pattern0:' || v_addr_mapping.old_addr);
DBMS_OUTPUT.PUT_LINE('pattern1:'|| REGEXP_REPLACE(v_addr_mapping.old_addr,'之','-'));
DBMS_OUTPUT.PUT_LINE('pattern2:' || REGEXP_REPLACE(v_addr_mapping.old_addr,
        --取得 號 跟 樓 中間的中文數字-> 五樓
        SUBSTR('永和路67之1號五樓',INSTR('永和路67之1號五樓','號')+1,1)|| '樓',
                  --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                   instr('一二三四五六七八九',SUBSTR('永和路67之1號五樓',INSTR('永和路67之1號五樓','號')+1,1) ,1)||'F'));
DBMS_OUTPUT.PUT_LINE('pattern3:' || REGEXP_REPLACE(
                REGEXP_REPLACE(v_addr_mapping.old_addr,
                        --取得 號 跟 樓 中間的中文數字-> 五樓
                        SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1)|| '樓',
                                  --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                                   instr('一二三四五六七八九',SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1) ,1)||'F')
                ,'之','-'));

------------------------------ PATTERN0 ----------------------------------------


SELECT * BULK COLLECT INTO IMPACT_CUSTS_BULK_OF_PATTERN_0
FROM CIFX.TB_CUSTOMER CUST
WHERE
REGEXP_LIKE(REGI_ADDRESS_DETAIL,v_addr_mapping.old_addr)  --原PATTERN
OR
REGEXP_LIKE(CONT_ADDRESS_DETAIL,v_addr_mapping.old_addr)  --原PATTERN
AND CIF_VERIFIED_ID = 'X111695470' -- 測試用
;

IF   v_addr_mapping.old_addr NOT MEMBER OF v_pattern_array  --先前沒找過此PATTERN
AND  IMPACT_CUSTS_BULK_OF_PATTERN_0.COUNT <> 0              --此PATTERN找到有值
THEN
    v_pattern_array.EXTEND();
    v_pattern_array(v_pattern_array.LAST) := v_addr_mapping.old_addr;
    FOR i in IMPACT_CUSTS_BULK_OF_PATTERN_0.first..IMPACT_CUSTS_BULK_OF_PATTERN_0.last
    loop

     DBMS_OUTPUT.PUT_LINE('符合PATTERN_0顧客統編:' || IMPACT_CUSTS_BULK_OF_PATTERN_0(i).CIF_VERIFIED_ID);
     DBMS_OUTPUT.PUT_LINE('符合PATTERN_0顧客戶籍地址(舊):' || IMPACT_CUSTS_BULK_OF_PATTERN_0(i).REGI_ADDRESS_DETAIL);
     DBMS_OUTPUT.PUT_LINE('符合PATTERN_0顧客戶籍地址(新):' || REPLACE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).REGI_ADDRESS_DETAIL,
                                                                                                            v_addr_mapping.old_addr,
                                                                                                            v_addr_mapping.new_addr)
     );

     DBMS_OUTPUT.PUT_LINE('符合PATTERN_0顧客通訊地址(舊):' || IMPACT_CUSTS_BULK_OF_PATTERN_0(i).CONT_ADDRESS_DETAIL);
     DBMS_OUTPUT.PUT_LINE('符合PATTERN_0顧客通訊地址(新):' || REPLACE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).CONT_ADDRESS_DETAIL,
                                                                                                            v_addr_mapping.old_addr,
                                                                                                            v_addr_mapping.new_addr)
     );
     -----------------------------------------單一顧客開始-----------------------------------------------
     DBMS_OUTPUT.PUT_LINE('==== SP_INSERT_TMP start =======');
     SP_INSERT_TMP(
          i_rec_map =>v_addr_mapping,
          i_impact_cust_bulk =>IMPACT_CUSTS_BULK_OF_PATTERN_0,
          i_index =>i
        );
    DBMS_OUTPUT.PUT_LINE('==== SP_INSERT_TMP end =======');


     --判斷是戶籍還是通訊符合變更條件

     --戶籍地轉換/通訊地不變
--     IF REGEXP_LIKE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).REGI_ADDRESS_DETAIL,v_addr_mapping.old_addr)
--     AND NOT REGEXP_LIKE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).CONT_ADDRESS_DETAIL,v_addr_mapping.old_addr) THEN
--        v_tmp_regi_addr_detail := REPLACE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).REGI_ADDRESS_DETAIL,v_addr_mapping.old_addr,v_addr_mapping.new_addr);
--        v_tmp_cont_addr_detail := NULL;
--        V_CASE_TYPE := '戶籍地轉換/通訊地不變';
--     --通訊地轉換/戶籍地不變
--     ELSIF REGEXP_LIKE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).CONT_ADDRESS_DETAIL,v_addr_mapping.old_addr)
--     AND NOT REGEXP_LIKE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).REGI_ADDRESS_DETAIL,v_addr_mapping.old_addr) THEN
--        v_tmp_regi_addr_detail := NULL;
--        v_tmp_cont_addr_detail :=  REPLACE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).CONT_ADDRESS_DETAIL,v_addr_mapping.old_addr,v_addr_mapping.new_addr);
--        V_CASE_TYPE := '通訊地轉換/戶籍地不變';
--
--     --都轉換
--      ELSIF  REGEXP_LIKE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).REGI_ADDRESS_DETAIL,v_addr_mapping.old_addr)
--     AND REGEXP_LIKE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).CONT_ADDRESS_DETAIL,v_addr_mapping.old_addr) THEN
--        v_tmp_regi_addr_detail :=  REPLACE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).REGI_ADDRESS_DETAIL,v_addr_mapping.old_addr,v_addr_mapping.new_addr);
--        v_tmp_cont_addr_detail :=  REPLACE(IMPACT_CUSTS_BULK_OF_PATTERN_0(i).CONT_ADDRESS_DETAIL,v_addr_mapping.old_addr,v_addr_mapping.new_addr);
--        V_CASE_TYPE := '都轉換';
--     END IF;






--     sp_insert_impact_list(IMPACT_CUSTS_BULK_OF_PATTERN_0(i));
     -----------------------------------------單一顧客結束-----------------------------------------------
    end loop;
END IF;






------------------------------ PATTERN1 ----------------------------------------
SELECT * BULK COLLECT INTO IMPACT_CUSTS_BULK_OF_PATTERN_1
FROM CIFX.TB_CUSTOMER CUST
WHERE
REGEXP_LIKE(REGI_ADDRESS_DETAIL,REGEXP_REPLACE(v_addr_mapping.old_addr,'之','-'))
AND CIF_VERIFIED_ID = 'X111695470' -- 測試用
;

IF REGEXP_REPLACE(v_addr_mapping.old_addr,'之','-') NOT MEMBER OF v_pattern_array
AND IMPACT_CUSTS_BULK_OF_PATTERN_1.COUNT <> 0 THEN


    v_pattern_array.EXTEND();
    v_pattern_array(v_pattern_array.LAST) := REGEXP_REPLACE(v_addr_mapping.old_addr,'之','-');

    FOR i in IMPACT_CUSTS_BULK_OF_PATTERN_1.first..IMPACT_CUSTS_BULK_OF_PATTERN_1.last
    loop
    DBMS_OUTPUT.PUT_LINE('符合PATTERN_1顧客統編:' || IMPACT_CUSTS_BULK_OF_PATTERN_1(i).CIF_VERIFIED_ID);
     DBMS_OUTPUT.PUT_LINE('符合PATTERN_1顧客戶籍地址(舊):' || IMPACT_CUSTS_BULK_OF_PATTERN_1(i).REGI_ADDRESS_DETAIL);
     DBMS_OUTPUT.PUT_LINE('符合PATTERN_1顧客戶籍地址(新):' || REPLACE(IMPACT_CUSTS_BULK_OF_PATTERN_1(i).REGI_ADDRESS_DETAIL,
                                                                                                            REGEXP_REPLACE(v_addr_mapping.old_addr,'之','-'),
                                                                                                            v_addr_mapping.new_addr)
                                                                                                            );
    sp_insert_impact_list(IMPACT_CUSTS_BULK_OF_PATTERN_1(i));
    end loop;
END IF;

------------------------------ PATTERN2 ----------------------------------------
SELECT * BULK COLLECT INTO IMPACT_CUSTS_BULK_OF_PATTERN_2
FROM CIFX.TB_CUSTOMER CUST
WHERE
--號跟樓同時有 =>中間有中文數字
--INSTR(REGI_ADDRESS_DETAIL,'號') <> 0 AND INSTR(REGI_ADDRESS_DETAIL,'樓') <> 0
--AND
 --==============  樓條件(含樓層數字轉換)=======================
REGEXP_LIKE(REGI_ADDRESS_DETAIL,
--樓PATTERN
REGEXP_REPLACE(v_addr_mapping.old_addr,
        --取得 號 跟 樓 中間的中文數字-> 五樓
        SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1)|| '樓',
                  --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                   instr('一二三四五六七八九',SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1) ,1)||'F'))
AND CIF_VERIFIED_ID = 'X111695470' -- 測試用
;

IF REGEXP_REPLACE(v_addr_mapping.old_addr,
        --取得 號 跟 樓 中間的中文數字-> 五樓
        SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1)|| '樓',
                  --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                   instr('一二三四五六七八九',SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1) ,1)||'F') NOT MEMBER OF v_pattern_array
AND IMPACT_CUSTS_BULK_OF_PATTERN_2.COUNT <> 0 THEN
    --加入PATTERN
    v_pattern_array.EXTEND();
    v_pattern_array(v_pattern_array.LAST) := REGEXP_REPLACE(v_addr_mapping.old_addr,
        --取得 號 跟 樓 中間的中文數字-> 五樓
        SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1)|| '樓',
                  --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                   instr('一二三四五六七八九',SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1) ,1)||'F') ;


   FOR i in IMPACT_CUSTS_BULK_OF_PATTERN_2.first..IMPACT_CUSTS_BULK_OF_PATTERN_2.last
    loop
    DBMS_OUTPUT.PUT_LINE('符合PATTERN_2顧客統編:' || IMPACT_CUSTS_BULK_OF_PATTERN_2(i).CIF_VERIFIED_ID);
     DBMS_OUTPUT.PUT_LINE('符合PATTERN_2顧客戶籍地址(舊):' || IMPACT_CUSTS_BULK_OF_PATTERN_2(i).REGI_ADDRESS_DETAIL);
     DBMS_OUTPUT.PUT_LINE('符合PATTERN_2顧客戶籍地址(新):' || REPLACE(IMPACT_CUSTS_BULK_OF_PATTERN_2(i).REGI_ADDRESS_DETAIL,
                                                                                                            REGEXP_REPLACE(v_addr_mapping.old_addr,
        --取得 號 跟 樓 中間的中文數字-> 五樓
        SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1)|| '樓',
                  --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                   instr('一二三四五六七八九',SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1) ,1)||'F'),
                                                                                                            v_addr_mapping.new_addr)
                                                                                                            );
    sp_insert_impact_list(IMPACT_CUSTS_BULK_OF_PATTERN_2(i));
    end loop;
END IF;


------------------------------ PATTERN3 ----------------------------------------
SELECT * BULK COLLECT INTO IMPACT_CUSTS_BULK_OF_PATTERN_3
FROM CIFX.TB_CUSTOMER CUST
WHERE
REGEXP_LIKE(REGI_ADDRESS_DETAIL,
REGEXP_REPLACE(
                REGEXP_REPLACE(REGI_ADDRESS_DETAIL,
                        --取得 號 跟 樓 中間的中文數字-> 五樓
                        SUBSTR(REGI_ADDRESS_DETAIL,INSTR(REGI_ADDRESS_DETAIL,'號')+1,1)|| '樓',
                                  --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                                   instr('一二三四五六七八九',SUBSTR(REGI_ADDRESS_DETAIL,INSTR(REGI_ADDRESS_DETAIL,'號')+1,1) ,1)||'F')
                ,'之','-')
                   )
AND CIF_VERIFIED_ID = 'X111695470' -- 測試用
;

IF REGEXP_REPLACE(
                REGEXP_REPLACE(v_addr_mapping.old_addr,
                        --取得 號 跟 樓 中間的中文數字-> 五樓
                        SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1)|| '樓',
                                  --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                                   instr('一二三四五六七八九',SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1) ,1)||'F')
                ,'之','-')
                 NOT MEMBER OF  v_pattern_array
    AND IMPACT_CUSTS_BULK_OF_PATTERN_3.COUNT <> 0 THEN

    v_pattern_array.EXTEND();
    v_pattern_array(v_pattern_array.LAST) :=REGEXP_REPLACE(
                REGEXP_REPLACE(v_addr_mapping.old_addr,
                        --取得 號 跟 樓 中間的中文數字-> 五樓
                        SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1)|| '樓',
                                  --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                                   instr('一二三四五六七八九',SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1) ,1)||'F')
                ,'之','-');


   FOR i in IMPACT_CUSTS_BULK_OF_PATTERN_3.first..IMPACT_CUSTS_BULK_OF_PATTERN_3.last
    loop
        DBMS_OUTPUT.PUT_LINE('符合PATTERN_3顧客統編:' || IMPACT_CUSTS_BULK_OF_PATTERN_3(i).CIF_VERIFIED_ID);
     DBMS_OUTPUT.PUT_LINE('符合PATTERN_3顧客戶籍地址(舊):' || IMPACT_CUSTS_BULK_OF_PATTERN_3(i).REGI_ADDRESS_DETAIL);
     DBMS_OUTPUT.PUT_LINE('符合PATTERN_3顧客戶籍地址(新):' || REPLACE(IMPACT_CUSTS_BULK_OF_PATTERN_3(i).REGI_ADDRESS_DETAIL,
                                                                                                            REGEXP_REPLACE(
                REGEXP_REPLACE(v_addr_mapping.old_addr,
                        --取得 號 跟 樓 中間的中文數字-> 五樓
                        SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1)|| '樓',
                                  --取得 號 跟 樓 中間的中文數字後，置換為數字 || 'F' -> 5F
                                   instr('一二三四五六七八九',SUBSTR(v_addr_mapping.old_addr,INSTR(v_addr_mapping.old_addr,'號')+1,1) ,1)||'F')
                ,'之','-'),
                                                                                                            v_addr_mapping.new_addr)

                                                                                                      );
    sp_insert_impact_list(IMPACT_CUSTS_BULK_OF_PATTERN_3(i));
    end loop;

END IF;


DBMS_OUTPUT.PUT_LINE('符合pattern數目:' ||v_pattern_array.count );
if v_pattern_array.count <> 0 then
for i in v_pattern_array.first..v_pattern_array.last
loop
DBMS_OUTPUT.PUT_LINE('v_pattern_array:' || v_pattern_array(i));
end loop;
else
DBMS_OUTPUT.PUT_LINE('此地址無mapping任何顧客:' || v_addr_mapping.old_addr);
end if;

--------------------------------取得單一地址對映資料 結束-------------------------
END LOOP;



DBMS_OUTPUT.PUT_LINE('======== TEST END =========');
END;
