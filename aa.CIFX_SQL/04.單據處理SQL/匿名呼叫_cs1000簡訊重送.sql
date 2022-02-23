declare
v_send_sms_seq_no integer;
begin

----找出簡訊發送成功資料
for v_sms_rec in (
select * from cifx_batch.TB_BT_CS1000_TEMP
where result_desc = '簡訊發送成功'
)loop
DBMS_OUTPUT.PUT_LINE('===== singledata start =======');
DBMS_OUTPUT.PUT_LINE('v_sms_rec.phone_no:'|| v_sms_rec.phone_no);
DBMS_OUTPUT.PUT_LINE('v_sms_rec.send_sms_body:'|| v_sms_rec.send_sms_body);

v_send_sms_seq_no := 0;
                  CIFX_BATCH.PG_INSERT_SMS_SEC.SP_CALL_EDLS_PUSH_SMS
                  (
                    i_mq_code => 'QSSMS01',
                    i_mobile_phone_no => REPLACE(REPLACE(v_sms_rec.phone_no, CHR(13), ''), CHR(10), '') ,  --去掉換行符
                    i_sms_type => '1',
                    i_force_mark  => 'N',--原本是N
                    i_reservation_time => NULL,
                    i_valid_time => NULL,
                    i_proj_code => NULL,
                    i_pay_unit_code => 'B161',
                    i_message_content => v_sms_rec.send_sms_body,
                    i_urgent_mark => NULL,--原本是N  --建華:只能帶'Y'或是NULL
                    o_seq_no => v_send_sms_seq_no
                  );
DBMS_OUTPUT.PUT_LINE('v_send_sms_seq_no:'|| v_send_sms_seq_no);

DBMS_OUTPUT.PUT_LINE('===== singledata end =======');
end loop;

-- 驗證edls結果用
-- select * from edls.tb_push_sms
-- where mq_code = 'QSSMS01'
-- and pay_unit_code = 'B161'
-- order by create_date desc
-- ;

;


end;