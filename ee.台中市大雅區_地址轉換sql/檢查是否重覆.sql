with tmp_view as (
select circi_key as circi,circi_key || column_name as pk_col


from (
select
    CIRCI_KEY,
    COLUMN_NAME,
    case RESULT_MSG
        when '居住地轉換/通訊地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN CHG_REGI_ADDRESS_DETAIL    --居住地改變
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE  --通訊地不變
                END
        when '通訊地轉換/居住地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE    --居住地不變
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN CHG_CONT_ADDRESS_DETAIL  --通訊地改變
                END
        when '通訊地/居住地都轉換' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN CHG_REGI_ADDRESS_DETAIL
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN CHG_CONT_ADDRESS_DETAIL
                END
        else '未分類'
        end as COLUMN_CHANGED_VALUE,
    '' AS CHECK_CHAGNE_LOG,
    '' AS CHECK_SPECIFIEC_RULE,

    case RESULT_MSG
        when '居住地轉換/通訊地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE    --居住地原值
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE  --通訊地原值
                END
        when '通訊地轉換/居住地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE    --居住地原值
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE  --原值
                END
        when '通訊地/居住地都轉換' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE
                END
        else '未分類'
        END AS CHECK_BEFORE_VALUE,

    'Y' AS WRITE_LOG_FLAG,
    '' AS TO_CIP_FLAG,
    '' AS PUSH_FLAG,
    'RE11000729' AS REQ_NO
from CIFX_BATCH.tt_impt_ci_list ci_list

    unpivot (
COL_VALUE FOR COLUMN_NAME IN("PER_CITY","PER_ZIP","PER_AREA","REGI_ADDRESS_DETAIL")


)

WHERE RESULT_MSG = '居住地轉換/通訊地不變'

union
select
    CIRCI_KEY,
    COLUMN_NAME,
    case RESULT_MSG
        when '居住地轉換/通訊地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN CHG_REGI_ADDRESS_DETAIL    --居住地改變
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE  --通訊地不變
                END
        when '通訊地轉換/居住地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE    --居住地不變
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN CHG_CONT_ADDRESS_DETAIL  --通訊地改變
                END
        when '通訊地/居住地都轉換' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN CHG_REGI_ADDRESS_DETAIL
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN CHG_CONT_ADDRESS_DETAIL
                END
        else '未分類'
        end as COLUMN_CHANGED_VALUE,
    '' AS CHECK_CHAGNE_LOG,
    '' AS CHECK_SPECIFIEC_RULE,

    case RESULT_MSG
        when '居住地轉換/通訊地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE    --居住地原值
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE  --通訊地原值
                END
        when '通訊地轉換/居住地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE    --居住地原值
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE  --原值
                END
        when '通訊地/居住地都轉換' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE
                END
        else '未分類'
        END AS CHECK_BEFORE_VALUE,

    'Y' AS WRITE_LOG_FLAG,
    '' AS TO_CIP_FLAG,
    '' AS PUSH_FLAG,
    'RE11000729' AS REQ_NO
from CIFX_BATCH.tt_impt_ci_list ci_list

    unpivot (
COL_VALUE FOR COLUMN_NAME IN("CONT_CITY","CUST_ZIP_CODE","CONT_AREA","CONT_ADDRESS_DETAIL")
)

WHERE RESULT_MSG = '通訊地轉換/居住地不變'

union
select
    CIRCI_KEY,
    COLUMN_NAME,
    case RESULT_MSG
        when '居住地轉換/通訊地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN CHG_REGI_ADDRESS_DETAIL    --居住地改變
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE  --通訊地不變
                END
        when '通訊地轉換/居住地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE    --居住地不變
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN CHG_CONT_ADDRESS_DETAIL  --通訊地改變
                END
        when '通訊地/居住地都轉換' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN CHG_REGI_ADDRESS_DETAIL
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN CHG_CONT_ADDRESS_DETAIL
                END
        else '未分類'
        end as COLUMN_CHANGED_VALUE,
    '' AS CHECK_CHAGNE_LOG,
    '' AS CHECK_SPECIFIEC_RULE,

    case RESULT_MSG
        when '居住地轉換/通訊地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE    --居住地原值
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE  --通訊地原值
                END
        when '通訊地轉換/居住地不變' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE    --居住地原值
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE  --原值
                END
        when '通訊地/居住地都轉換' then
            CASE COLUMN_NAME
                WHEN 'PER_CITY' THEN COL_VALUE
                WHEN 'PER_ZIP' THEN  COL_VALUE
                WHEN 'PER_AREA' THEN COL_VALUE
                WHEN 'REGI_ADDRESS_DETAIL' THEN COL_VALUE
                WHEN 'CONT_CITY' THEN COL_VALUE
                WHEN 'CUST_ZIP_CODE' THEN  COL_VALUE
                WHEN 'CONT_AREA' THEN COL_VALUE
                WHEN 'CONT_ADDRESS_DETAIL' THEN COL_VALUE
                END
        else '未分類'
        END AS CHECK_BEFORE_VALUE,

    'Y' AS WRITE_LOG_FLAG,
    '' AS TO_CIP_FLAG,
    '' AS PUSH_FLAG,
    'RE11000729' AS REQ_NO
from CIFX_BATCH.tt_impt_ci_list ci_list

    unpivot (

COL_VALUE FOR COLUMN_NAME IN("PER_CITY","PER_ZIP","PER_AREA","REGI_ADDRESS_DETAIL","CONT_CITY","CUST_ZIP_CODE","CONT_AREA","CONT_ADDRESS_DETAIL")

)

WHERE RESULT_MSG = '通訊地/居住地都轉換'
) 
)
--select count(1) from (
select circi,pk_col,count(1) from tmp_view
--where cntt > 1
group by pk_col,circi
having count(1) > 1

--)

;