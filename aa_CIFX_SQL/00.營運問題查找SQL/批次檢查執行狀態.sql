with job_list as (
select '日曆日' as cate,'00:05' as exec_time ,'JOB_CIFX_BT_CALENDAR'as job_id from dual union all
select '營業日' as cate,'02:00' as exec_time ,'JOB_CIFX_BT_CICPSC'as job_id from dual union all
select '日曆日' as cate,'03:00' as exec_time ,'JOB_CIFX_BT_SYNCCIP'as job_id from dual union all
select '日曆日' as cate,'08:00' as exec_time ,'JOB_CIFX_BT_SYNCCIP'as job_id from dual union all
select '營業日' as cate,'09:00' as exec_time ,'JOB_CIFX_BT_BUSINESS'as job_id from dual union all
select '營業日' as cate,'09:05' as exec_time ,'JOB_CIFX_BT_CIARS'as job_id from dual union all
select '營業日' as cate,'09:30' as exec_time ,'JOB_CIFX_BT_MAL03'as job_id from dual union all
select '營業日' as cate,'10:00' as exec_time ,'JOB_CIFX_BT_CICPS2'as job_id from dual union all
select '營業日' as cate,'10:05' as exec_time ,'JOB_CIFX_BT_CIARS'as job_id from dual union all
select '營業日' as cate,'11:00' as exec_time ,'JOB_CIFX_BT_CIDTB'as job_id from dual union all
select '營業日' as cate,'11:00' as exec_time ,'JOB_CIFX_BT_MAL01'as job_id from dual union all
select '營業日' as cate,'11:05' as exec_time ,'JOB_CIFX_BT_CIARS'as job_id from dual union all
select '營業日' as cate,'12:05' as exec_time ,'JOB_CIFX_BT_CIARS'as job_id from dual union all
select '每月20' as cate,'13:00' as exec_time ,'JOB_CIFX_BT_NHI04'as job_id from dual union all
select '營業日' as cate,'13:00' as exec_time ,'JOB_CIFX_BT_CICPS2'as job_id from dual union all
select '營業日' as cate,'13:05' as exec_time ,'JOB_CIFX_BT_CIARS'as job_id from dual union all
select '營業日' as cate,'14:00' as exec_time ,'JOB_CIFX_BT_MAL02'as job_id from dual union all
select '營業日' as cate,'14:05' as exec_time ,'JOB_CIFX_BT_CIARS'as job_id from dual union all
select '營業日' as cate,'14:30' as exec_time ,'JOB_CIFX_BT_CICPS2'as job_id from dual union all
select '營業日' as cate,'15:05' as exec_time ,'JOB_CIFX_BT_CIARS'as job_id from dual union all
select '營業日' as cate,'15:30' as exec_time ,'JOB_CIFX_BT_MAL04'as job_id from dual union all
select '營業日' as cate,'16:00' as exec_time ,'JOB_CIFX_BT_CICPS2'as job_id from dual union all
select '營業日' as cate,'16:05' as exec_time ,'JOB_CIFX_BT_CIARS'as job_id from dual union all
select '營業日' as cate,'17:00' as exec_time ,'JOB_CIFX_BT_CICK04'as job_id from dual union all
select '營業日' as cate,'17:05' as exec_time ,'JOB_CIFX_BT_CIARS'as job_id from dual union all
select '營業日' as cate,'18:05' as exec_time ,'JOB_CIFX_BT_CIARS'as job_id from dual union all
select '日曆日' as cate,'20:00' as exec_time ,'JOB_CIFX_BT_GODN2'as job_id from dual union all
select '每月19' as cate,'21:00' as exec_time ,'JOB_CIFX_BT_DCI99'as job_id from dual union all
select '每月19' as cate,'22:00' as exec_time ,'JOB_CIFX_BT_DCI9B_GM1042D'as job_id from dual union all
select '每月19' as cate,'22:00' as exec_time ,'JOB_CIFX_BT_DCI9B_GM3020G'as job_id from dual union all
select '營業日' as cate,'22:00' as exec_time ,'JOB_CIFX_BT_CINHI'as job_id from dual union all
select '每月05' as cate,'23:00' as exec_time ,'JOB_CIFX_BT_LI312'as job_id from dual union all
select '每月20' as cate,'23:00' as exec_time ,'JOB_CIFX_BT_CICTP'as job_id from dual




  )
select
JBLIST.cate,
JBLIST.exec_time,
JBLIST.job_id ,
--HIS.START_DATE,
min(
CASE WHEN
JBLIST.cate = '營業日' OR JBLIST.cate = '日曆日' THEN
      CASE WHEN
       (HIS.START_DATE BETWEEN
      TO_TIMESTAMP(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') ||' '|| exec_time,'YYYY-MM-DD HH24:MI') -300/86400
      AND
      TO_TIMESTAMP(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') ||' '|| exec_time,'YYYY-MM-DD HH24:MI') +300/86400 )
      AND HIS.STATUS = 0
      THEN 'SUCCESS'
      WHEN TO_TIMESTAMP(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') ||' '|| exec_time,'YYYY-MM-DD HH24:MI') > CURRENT_DATE THEN 'NOT YET'
      ELSE 'FAIL'
      END

WHEN  SUBSTR(JBLIST.cate,1,2) = '每月'  AND  SUBSTR(JBLIST.cate,2,4) != TO_CHAR(CURRENT_DATE,'DD')
THEN 'NOT YET(MONTH)'


WHEN SUBSTR(JBLIST.cate,1,2) = '每月'  AND  SUBSTR(JBLIST.cate,2,4) = TO_CHAR(CURRENT_DATE,'DD') THEN
      CASE WHEN
             (HIS.START_DATE BETWEEN
            TO_TIMESTAMP(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') ||' '|| exec_time,'YYYY-MM-DD HH24:MI') -300/86400
            AND
            TO_TIMESTAMP(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') ||' '|| exec_time,'YYYY-MM-DD HH24:MI') +300/86400 )
            AND HIS.STATUS = 0
            THEN 'SUCCESS'
            WHEN TO_TIMESTAMP(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') ||' '|| exec_time,'YYYY-MM-DD HH24:MI') > CURRENT_DATE THEN 'NOT YET'
            ELSE 'FAIL'
            END


END
) AS exe_status




from job_list JBLIST
LEFT JOIN cifx_batch.tb_batch_job_execute_his HIS ON JBLIST.JOB_ID = HIS.JOB_ID


AND TO_CHAR(HIS.START_DATE,'YYYY-MM-DD') = TO_CHAR(CURRENT_DATE,'YYYY-MM-DD')
AND ( HIS.START_DATE BETWEEN
TO_TIMESTAMP(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') ||' '|| exec_time,'YYYY-MM-DD HH24:MI') -300/86400
AND
TO_TIMESTAMP(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') ||' '|| exec_time,'YYYY-MM-DD HH24:MI') +300/86400 )
GROUP BY JBLIST.EXEC_time,JBLIST.JOB_ID,JBLIST.cate
ORDER BY EXEC_TIME ASC
;