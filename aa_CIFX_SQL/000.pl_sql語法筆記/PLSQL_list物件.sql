declare

  type t_json_rec is record
  (
    input_json varchar2(50),
    input_value varchar2(50),
    table_column varchar2(50)
  );


  type t_json_tab is table of t_json_rec index by varchar2(100 char);
  json_tab t_json_tab;

v_indx varchar2(100 CHAR):= '';

begin

  json_tab('aa').input_json := 'customerCirciKey';
  json_tab('aa').input_value := 'Y109418740';
  json_tab('aa').table_column:= 'CIF_VERIFIED_ID';


  json_tab('bb').input_json := 'emailSellingFlag';
  json_tab('bb').input_value := 'Y';
  json_tab('bb').table_column:= 'EMAIL_SALE_FLAG';

  --  show_detail;
  v_indx := json_tab.first;
  while v_indx is not null
   loop
     dbms_output.put_line('json_tab('||v_indx||'):'  || json_tab(v_indx).input_json || ' ' || json_tab(v_indx).input_value || json_tab(v_indx).table_column);
     v_indx := json_tab.next(v_indx);
   end loop;



end;
/