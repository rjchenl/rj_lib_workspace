declare

v_after_tb_cusomter cifx.tb_customer%rowtype;
v_sql varchar2(3000 char) := '';
--F121993720
begin



select * into v_after_tb_cusomter from cifx.tb_customer where cif_verified_id = 'F121993720';


DBMS_OUTPUT.PUT_LINE('v_after_tb_cusomter.cust_name :' || v_after_tb_cusomter.cust_name );


v_sql := 'declare
          r cifx.tb_customer%rowtype := :1;
           begin
                r.cust_Name :=  ' || '''' || '我是新的' || '''' || ';
                :1 := r;
           end;';
DBMS_OUTPUT.PUT_LINE('v_sql:' || v_sql);
execute immediate  v_sql using  in out v_after_tb_cusomter;
DBMS_OUTPUT.PUT_LINE('v_after_tb_cusomter.cust_name :' || v_after_tb_cusomter.cust_name );



end;
/
--程式片斷
-- select kafka_topic_name into v_send_topic_name from cifx.tb_push_kfk_map where push_txn_code = I_TX_CODE;
-- for v_rec_send_column_code in (
--              select cco.json_Name,cco.column_name from cifx.tb_push_col_send_map  pcsm
--              join cifx.tb_column_code_opt cco on cco.column_code = pcsm.send_column_code
--              where pcsm.push_kfk_txn_code = I_TX_CODE
--             )
--         loop
--             --取得顧客主檔動態欄位
--              v_sql := 'declare
--               r cifx.tb_customer%rowtype := :1;
--                begin
--                     :2 := r.'  || v_rec_send_column_code.column_name || ';' ||'
--                end;';
--               execute immediate  v_sql using  in v_tb_customer ,out v_column_value;
--               --組成model內容
--               v_model_content := v_model_content || '"' || v_rec_send_column_code.json_name || '":"' || v_column_value || '",';
--
--         end loop;
-- /
