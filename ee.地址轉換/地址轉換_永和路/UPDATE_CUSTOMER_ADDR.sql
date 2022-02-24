
update cifx.tb_customer
set REGI_ADDRESS_DETAIL = '永和路67號',
PER_CITY = '新北市',
PER_ZIP = '235',
PER_AREA = '中和區',
CONT_ADDRESS_DETAIL = '永和路67號',
CONT_CITY = '新北市',
CUST_ZIP_CODE = '235',
CONT_AREA = '中和區'
where cif_verified_id = 'F121954312'
;

COMMIT;