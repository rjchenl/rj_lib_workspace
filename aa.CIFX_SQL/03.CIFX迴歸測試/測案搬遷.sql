insert into cifx_regression.tb_customer
(
SELECT * FROM CIFX.TB_CUSTOMER WHERE CIF_VERIFIED_ID IN (
select CIF_VERIFIED_ID from cifx.tb_customer
minus
select CIF_VERIFIED_ID from cifx_regression.tb_customer)
)
;