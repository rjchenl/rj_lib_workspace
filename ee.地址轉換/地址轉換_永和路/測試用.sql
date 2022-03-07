select * from cifx.tb_customer
fetch first 20 rows only
;

--A151535973  戶籍
--A12345678B  通訊

update cifx.tb_customer
set PER_CITY = '新北市',
    PER_AREA = '中和區',
    REGI_ADDRESS_DETAIL = '我是一條隨便的路永和路６７-１號２Ｆ',
    CONT_CITY = NULL,
    CUST_ZIP_CODE = NULL,
    CONT_AREA = NULL,
    CONT_ADDRESS_DETAIL = NULL
where cif_verified_id = 'A151535973';
COMMIT;
update cifx.tb_customer
set PER_CITY = NULL,
    PER_AREA = NULL,
    REGI_ADDRESS_DETAIL = NULL,
    CONT_CITY = '新北市',
    CUST_ZIP_CODE = NULL,
    CONT_AREA = '中和區',
    CONT_ADDRESS_DETAIL = '我也是一條隨便的路永和路６７之１號四樓'
where cif_verified_id = 'A12345678B';
COMMIT;

truncate table CIFX_BATCH.TT_CUSTOMER;

--搬資料
INSERT INTO CIFX_BATCH.TT_CUSTOMER
SELECT * FROM CIFX.TB_CUSTOMER
WHERE CIF_VERIFIED_ID IN
(
'A151535973',
'A12345678B'
);
COMMIT;
