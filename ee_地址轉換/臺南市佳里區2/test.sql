--地址滙入結果
SELECT * FROM CIFX_BATCH.TT_ADDR_MAPPING order by uuid asc;
--將匯入的地址轉成各種pattern
SELECT * FROM CIFX_BATCH.TT_ADDR_MAPPING order by uuid asc;
--展開pattern並去除重覆pattern
select old_addr,new_addr  from cifx_batch.TT_ADDR_MAPPING_EXTENSION group by old_addr,new_addr;
--查看執行結果
select * from CIFX_BATCH.TT_IMPT_CI_LIST
--where circi_key = 'A151535973'
;

--單一測試主檔
select PER_CITY, PER_ZIP, PER_AREA, REGI_ADDRESS_DETAIL, CONT_CITY, CUST_ZIP_CODE, CONT_AREA, CONT_ADDRESS_DETAIL from cifx_batch.TT_CUSTOMER
where cif_verified_id = 'A151535973' ;

--清除執行結果
truncate table CIFX_BATCH.TT_IMPT_CI_LIST;

select * from cifx_batch.tt_customer;



select
PER_CITY,
PER_ZIP,
PER_AREA,
REGI_ADDRESS_DETAIL,

CONT_CITY,
CUST_ZIP_CODE,
CONT_AREA,
CONT_ADDRESS_DETAIL
from cifx.tb_customer
where cif_verified_id = 'A151535973'
;


select
PER_CITY,
PER_ZIP,
PER_AREA,
REGI_ADDRESS_DETAIL,

CONT_CITY,
CUST_ZIP_CODE,
CONT_AREA,
CONT_ADDRESS_DETAIL

from cifx_batch.TT_CUSTOMER
where cif_verified_id = 'A151535973'
;

--A151535973  戶籍
--A12345678B  通訊

--測試戶籍
update cifx_batch.tt_customer
set PER_CITY = '臺南市',
    PER_AREA = '佳里區',
    REGI_ADDRESS_DETAIL = '我是一條條的路佳里興３號之３',
    CONT_CITY = NULL,
    CUST_ZIP_CODE = NULL,
    CONT_AREA = NULL,
    CONT_ADDRESS_DETAIL = NULL
where cif_verified_id = 'A151535973';
COMMIT;

--測試通訊變更
update cifx_batch.tt_customer
set PER_CITY = NULL,
    PER_AREA = NULL,
    REGI_ADDRESS_DETAIL = NULL,
    CONT_CITY = '臺南市',
    CUST_ZIP_CODE = NULL,
    CONT_AREA = '佳里區',
    CONT_ADDRESS_DETAIL = '我也是一條隨便的路安西７１號之１０'
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
