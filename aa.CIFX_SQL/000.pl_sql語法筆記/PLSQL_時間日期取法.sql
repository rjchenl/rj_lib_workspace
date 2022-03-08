DECLARE
V_FLAG CIFX.TB_ACTION_CONTROL_FLAG%ROWTYPE;
v_cur_date_str varchar2(8 char):= '';
v_cur_time_str varchar2(6 char):= '';
v_datetime_str varchar2(14 char) := '';
BEGIN




v_datetime_str:= '20220114095500';




DBMS_OUTPUT.PUT_LINE('v_datetime_str:' || v_datetime_str);
DBMS_OUTPUT.PUT_LINE('受檢日期:' || SUBSTR(v_datetime_str,1,8));
DBMS_OUTPUT.PUT_LINE('受檢時間:' || SUBSTR(v_datetime_str,9));



SELECT substr(TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS'),1,8) into v_cur_date_str from dual;
SELECT substr(TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS'),9,6) into v_cur_time_str  from dual;
DBMS_OUTPUT.PUT_LINE('v_cur_date_str:' || v_cur_date_str);
DBMS_OUTPUT.PUT_LINE('v_cur_time_str:' || v_cur_time_str);


--日期
if to_date(SUBSTR(v_datetime_str,1,8),'yyyy-MM-dd') = to_date(v_cur_date_str,'yyyy-MM-dd') then
DBMS_OUTPUT.PUT_LINE('日期 就是今天!!');
end if;


if to_date(SUBSTR(v_datetime_str,1,8),'yyyy-MM-dd') > to_date(v_cur_date_str,'yyyy-MM-dd') then
DBMS_OUTPUT.PUT_LINE('日期>今天!!日期未到');
end if;


if to_date(SUBSTR(v_datetime_str,1,8),'yyyy-MM-dd') < to_date(v_cur_date_str,'yyyy-MM-dd') then
DBMS_OUTPUT.PUT_LINE('日期<今天!!日期已過');
end if;


--時間
if to_date(SUBSTR(v_datetime_str,9,6),'HH24MISS') = to_date(v_cur_time_str,'HH24MISS')  then
DBMS_OUTPUT.PUT_LINE('時間 就是現在!!');
end if;




if to_date(SUBSTR(v_datetime_str,9,6),'HH24MISS') > to_date(v_cur_time_str,'HH24MISS')  then
DBMS_OUTPUT.PUT_LINE('時間 現在之後!!');
end if;



if to_date(SUBSTR(v_datetime_str,9,6),'HH24MISS') < to_date(v_cur_time_str,'HH24MISS')  then
DBMS_OUTPUT.PUT_LINE('時間 現在之前!!');
end if;


END;
/