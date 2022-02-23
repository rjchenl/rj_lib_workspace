select push_status,mobile_phone_no,case when ascii(substr(mobile_phone_no,length(mobile_phone_no),1)) = 13 then '有斷行符' else 'ok' end     from edls.tb_push_sms
where mq_code = 'QSSMS01'
and pay_unit_code = 'B161'
and create_date > TO_TIMESTAMP('2021/12/02 13:00:00','YYYY/MM/DD HH24:MI:SS')
and mobile_phone_no in (
'0952691667',
'0986183182',
'0970013385',
'0939616930',
'0979621882',
'0927685157',
'0963696383',
'0978700166'
)
order by create_date desc
;
