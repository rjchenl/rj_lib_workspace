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