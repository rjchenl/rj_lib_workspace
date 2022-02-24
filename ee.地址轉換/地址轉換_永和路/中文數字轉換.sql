declare

   TYPE v_map_type IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
   v_model_json_map v_map_type;

   V_TEST VARCHAR2(100 CHAR) := '';

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


   begin
   --放值
   v_model_json_map('aaa') := '111';
   v_model_json_map('bbb') := '222';
   v_model_json_map('ccc') := '333';

   --取值
--   DBMS_OUTPUT.PUT_LINE('取值bbb:' ||v_model_json_map('bbb'));
--    DBMS_OUTPUT.PUT_LINE('INSTR:' || INSTR('0123456789','4'));
   DBMS_OUTPUT.PUT_LINE('FN_number_To_Ch_number:' || FN_number_To_Ch_number('6'));
   DBMS_OUTPUT.PUT_LINE('FN_Ch_Number_To_NUMBER:' || FN_Ch_Number_To_NUMBER('七'));



   end;
/