WITH CUST_VIEW AS (
select
cust_name AS 戶名,
cif_verified_id ,

RESI_COMM_CONTENT as 戶籍電話,
CONT_COMM_CONTENT as 通訊電話,
CNTP_COMM_CONTENT as 連繫用手機,
TXNP_COMM_CONTENT as OTP手機
from cifx.tb_customer
where
 EXCHANGE_CONTACT_PERSON_PHONE = '0975124047'
 or RESI_COMM_CONTENT = '0975124047'
 or CONT_COMM_CONTENT = '0975124047'
 or COMP_COMM_CONTENT = '0975124047'
 or FAXT_COMM_CONTENT = '0975124047'
 or RESI_COMM_CONTENT2 = '0975124047'
 or CONT_COMM_CONTENT2 = '0975124047'
 or COMP_COMM_CONTENT2 = '0975124047'
 or FAXT_COMM_CONTENT2 = '0975124047'
 or RESI_COMM_CONTENT3 = '0975124047'
 or CONT_COMM_CONTENT3 = '0975124047'
 or COMP_COMM_CONTENT3 = '0975124047'
 or FAXT_COMM_CONTENT3 = '0975124047'
 or CNTP_COMM_CONTENT =  '0975124047'
 or TXNP_COMM_CONTENT =  '0975124047'
 or CNTP_COMM_CONTENT2 = '0975124047'
 or TXNP_COMM_CONTENT2 = '0975124047'
 or CNTP_COMM_CONTENT3 = '0975124047'
 or TXNP_COMM_CONTENT3 = '0975124047'

)
,ACC_INFO  AS (
SELECT ACC AS 帳號  FROM EDLS.TB_ACC_USED
JOIN CUST_VIEW ON CUST_VIEW.cif_verified_id = CUST_ID
)
,ACC_INFO  AS (
SELECT ACC AS 帳號  FROM EDLS.TB_ACC_USED
JOIN CUST_VIEW ON CUST_VIEW.cif_verified_id = CUST_ID
)
SELECT * FROM CUST_VIEW,ACC_INFO
;



--OTP手機為為某號
select * from cifx.TB_CHANGE_LOG_LINEITEM cli
where CHANGED_COLUMN_CODE_ID = '1558002081007529-5750146-22-02'  --otp手機
and
(changed_value = '0972887932' or before_value = '0972887932')
;


--現在OTP手機是
select TXNP_COMM_CONTENT,CIF_VERIFIED_ID from  cifx.TB_CUSTOMER
where TXNP_COMM_CONTENT = '0972887932'
;



--手機相關欄位查詢
with ever_otp_phone as (
select '目前OTP手機號碼是0972887932' as 說明,
CIF_VERIFIED_ID  as 統編
from  cifx.TB_CUSTOMER
where TXNP_COMM_CONTENT = '0972887932'
union all
select 'OTP手機號碼曾經是0972887932' as note,
circi_key as circikey
from cifx.TB_CHANGE_LOG_LINEITEM cli
where CHANGED_COLUMN_CODE_ID = '1558002081007529-5750146-22-02'  --otp手機
and (changed_value = '0972887932' or before_value = '0972887932')
group by circi_key
)
select * from ever_otp_phone
;


    WITH CUST_VIEW AS (
    select
--    cust_name AS 戶名,
    cif_verified_id as 統編,
--
case EXCHANGE_CONTACT_PERSON_PHONE when '0916263341' then'0916263341'else '' end as 外匯聯絡人電話,
case RESI_COMM_CONTENT when '0916263341' then'0916263341'else '' end as 戶籍電話,
case CONT_COMM_CONTENT when '0916263341' then'0916263341'else '' end as 通訊電話,
case COMP_COMM_CONTENT when '0916263341' then'0916263341'else '' end as 公司電話,
case FAXT_COMM_CONTENT when '0916263341' then'0916263341'else '' end as 傳真電話,
case RESI_COMM_CONTENT2 when '0916263341' then'0916263341'else '' end as 戶籍電話二,
case CONT_COMM_CONTENT2 when '0916263341' then'0916263341'else '' end as 通訊電話二,
case COMP_COMM_CONTENT2 when '0916263341' then'0916263341'else '' end as 公司電話二,
case FAXT_COMM_CONTENT2 when '0916263341' then'0916263341'else '' end as 傳真電話二,
case RESI_COMM_CONTENT3 when '0916263341' then'0916263341'else '' end as 戶籍電話三,
case CONT_COMM_CONTENT3 when '0916263341' then'0916263341'else '' end as 通訊電話三,
case COMP_COMM_CONTENT3 when '0916263341' then'0916263341'else '' end as 公司電話三,
case FAXT_COMM_CONTENT3 when '0916263341' then'0916263341'else '' end as 傳真電話三,
case CNTP_COMM_CONTENT when '0916263341' then'0916263341'else '' end as 連繫用手機,
case TXNP_COMM_CONTENT when '0916263341' then'0916263341'else '' end as otp手機,
case CNTP_COMM_CONTENT2 when '0916263341' then'0916263341'else '' end as 通訊用行動電話二,
case TXNP_COMM_CONTENT2 when '0916263341' then'0916263341'else '' end as 簡訊密碼專屬行動電話二,
case CNTP_COMM_CONTENT3 when '0916263341' then'0916263341'else '' end as 通訊用行動電話三,
case TXNP_COMM_CONTENT3 when '0916263341' then'0916263341'else '' end as 簡訊密碼專屬行動電話三


    from cifx.tb_customer cust
    where
     cust.EXCHANGE_CONTACT_PERSON_PHONE = '0916263341'
     or cust.RESI_COMM_CONTENT = '0916263341'
     or cust.CONT_COMM_CONTENT = '0916263341'
     or cust.COMP_COMM_CONTENT = '0916263341'
     or cust.FAXT_COMM_CONTENT = '0916263341'
     or cust.RESI_COMM_CONTENT2 = '0916263341'
     or cust.CONT_COMM_CONTENT2 = '0916263341'
     or cust.COMP_COMM_CONTENT2 = '0916263341'
     or cust.FAXT_COMM_CONTENT2 = '0916263341'
     or cust.RESI_COMM_CONTENT3 = '0916263341'
     or cust.CONT_COMM_CONTENT3 = '0916263341'
     or cust.COMP_COMM_CONTENT3 = '0916263341'
     or cust.FAXT_COMM_CONTENT3 = '0916263341'
     or cust.CNTP_COMM_CONTENT =  '0916263341'
     or cust.TXNP_COMM_CONTENT =  '0916263341'
     or cust.CNTP_COMM_CONTENT2 = '0916263341'
     or cust.TXNP_COMM_CONTENT2 = '0916263341'
     or cust.CNTP_COMM_CONTENT3 = '0916263341'
     or cust.TXNP_COMM_CONTENT3 = '0916263341'

    )
    ,ACC_INFO  AS (
    SELECT ACC AS 帳號  FROM EDLS.TB_ACC_USED
    JOIN CUST_VIEW ON CUST_VIEW.統編 = CUST_ID
    )
    ,ACC_INFO  AS (
    SELECT ACC AS 帳號  FROM EDLS.TB_ACC_USED
    JOIN CUST_VIEW ON CUST_VIEW.統編 = CUST_ID
    )
    SELECT * FROM CUST_VIEW,ACC_INFO
    ;

