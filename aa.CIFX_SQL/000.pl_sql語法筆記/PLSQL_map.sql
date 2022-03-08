declare

   TYPE v_map_type IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
   v_model_json_map v_map_type;
   begin
   --放值
   v_model_json_map('aaa') := '111';
   v_model_json_map('bbb') := '222';
   v_model_json_map('ccc') := '333';

   --取值
   DBMS_OUTPUT.PUT_LINE('取值bbb:' ||v_model_json_map('bbb'));

   end;
/