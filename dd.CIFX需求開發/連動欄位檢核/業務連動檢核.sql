SELECT dgbas_industry_code
FROM cifx.tb_customer
WHERE substr(
    cif_verified_id,
    1,
    1
  )= '&' AND principal_name IS NOT NULL;

SELECT cif_verified_id
FROM cifx.tb_customer
WHERE REGEXP_LIKE(cif_verified_id,
                  '[[:digit:]]')AND length(cif_verified_id)= 8;

SELECT cif_verified_id
FROM cifx.tb_customer
WHERE REGEXP_LIKE(substr(
  cif_verified_id,
  9,
  1
),
                  '[[:alpha:]]');

SELECT cbr.*,
       cco.column_name
FROM cifx.tb_col_business_rule cbr
JOIN cifx.tb_column_code_opt cco ON cco.column_code = cbr.column_code
WHERE rule_id = 'V_027';

SELECT column_desc
FROM cifx.tb_column_code_opt
WHERE column_name = 'PRINCIPAL_CERT_NO';
SELECT *
FROM cifx.tb_column_code_opt
WHERE column_code = 'X0208';

SELECT *
FROM cifx.tb_joblog
WHERE job_id = 'updateCustomer'
--and job_no = '20220214192519'
--and memo like '%V_028%'
ORDER BY run_time DESC;

SELECT *
FROM cifx.tb_joblog
WHERE job_id = 'updateCustomer' AND job_no = '20220215164724' AND memo LIKE '%V_037%'
ORDER BY run_time ASC;


SELECT bh_code
FROM edls.tb_branch
--WHERE BH_CODE
WHERE bh_b_code = 'B0200';

--20129406
SELECT customer_type_code,
       COUNT(1)
FROM cifx.tb_customer
WHERE length(cif_verified_id)= 8
GROUP BY customer_type_code;

UPDATE cifx.tb_customer
SET
  income_tax_type = '2'
WHERE cif_verified_id = 'C29900017A';
COMMIT;

SELECT birthday
FROM cifx.tb_customer
WHERE cif_verified_id = 'A123456789';

SELECT acc.*
FROM edls.tb_acc_used acc
JOIN cifx.tb_customer cust ON acc.cust_id = cust.cif_verified_id
--where acc.acc_status = '0'
;

SELECT cust_id,
       '2' AS acc_type            --帳號類別(定期性存款)
       ,
       td_acc_no AS account	            --帳號
       ,
       prod_id AS prod_code           --產品代號
       ,
       acc_status AS acc_status	        --帳戶狀態
       ,
       '' AS esa_acc_mark        --ESA帳號註記
       ,
       '' AS sleeping_acc_mark   --久未往來註記
       ,
       open_acc_bh AS open_acc_bh         --開戶分行
       ,
       booking_bh AS booking_bh          --設帳分行
       ,
       source_bh AS source_bh           --來源分行
       ,
       open_acc_date AS open_acc_date       --開戶日期
FROM edls.tb_td_acc acc
JOIN cifx.tb_customer cust ON cust.cif_verified_id = acc.cust_id
WHERE REGEXP_LIKE(substr(
  acc.cust_id,
  1,
  1
),
                  '[[:alpha:]]');

SELECT *
FROM edls.tb_branch
--       WHERE BH_CODE = '9915'
WHERE bh_b_code = 'B0200';

SELECT cif_original_id,
       dgbas_industry_code
FROM cifx.tb_customer
WHERE substr(
  cif_original_id,
  1,
  2
)= 'NI';
COMMIT;


SELECT cc.table_name,
       cc.column_name,
       pseudo_column
FROM cifx.tb_sys_col_act sc
LEFT JOIN cifx.tb_column_code cc ON cc.column_code = sc.column_code
WHERE sc.sender_code = 'TS0120' AND identifier_code = 'TS0120@01' AND act_type = 'Q' AND io_type = 'I';
/

SELECT COUNT(1)
FROM cifx.tb_customer
WHERE cif_original_id = 'A123456789' AND birthday = '19880101';

SELECT cif_original_id,
       birthday,
       COUNT(1)
FROM cifx.tb_customer
GROUP BY cif_original_id,
         birthday
HAVING COUNT(1)> 1;

