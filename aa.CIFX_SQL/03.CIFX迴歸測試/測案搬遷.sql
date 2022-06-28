
/**
  需要在CIFX_REGRESSION_IT18442 下執行
 */
insert into cifx_regression.tb_customer
(
SELECT * FROM CIFX.TB_CUSTOMER WHERE CIF_VERIFIED_ID IN (
select CIF_VERIFIED_ID from cifx.tb_customer
minus
select CIF_VERIFIED_ID from cifx_regression.tb_customer)
)
;
COMMIT;
/



select CIF_VERIFIED_ID from cifx.tb_customer
minus
select CIF_VERIFIED_ID from cifx_regression.tb_custome
;
/
