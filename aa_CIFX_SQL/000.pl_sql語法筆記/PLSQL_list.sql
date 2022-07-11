create or replace TYPE INPUT_TB_VAR_ARRAY  AS TABLE OF VARCHAR2(4000 char);
/

declare
  TYPE varrary_type IS TABLE OF VARCHAR2(256 CHAR);
  v_array              varrary_type := varrary_type();

begin

  --賦值
  IF '要加入的值' NOT MEMBER OF v_array   THEN
      v_array.extend();
      v_array(v_array.last) := '要加入的值' ;
  END IF;

  --取值
  for i in v_array.first..v_array.last
  loop
  DBMS_OUTPUT.PUT_LINE('v_array(i):' || v_array(i));
  end loop;

end;
/