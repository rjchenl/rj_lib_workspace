--JOB紀錄檔
  v_bachno       CIFX.tb_joblog.job_no%TYPE     :='';
  v_job_id       CIFX.tb_joblog.job_id%TYPE     := 'FN_INS_CORE_CUST_DATA';
  v_job_step     CIFX.tb_joblog.step%TYPE       :='';
  v_jobnum       CIFX.tb_joblog.in_count%TYPE   :=0 ;
  v_sucnum       CIFX.tb_joblog.proc_count%TYPE :=0;
  v_errnum       CIFX.tb_joblog.err_count%TYPE  :=0;
  v_memo         CIFX.tb_joblog.memo%TYPE  :='';


      PROCEDURE insert_joblog
      IS
      BEGIN
        CIFX.SP_INSERT_TB_JOBLOG(i_job_no     => v_bachno,     --處理批次
                           i_job_id     => v_job_id,     --程式代號
                           i_step       => v_job_step,   --處理階段名稱
                           i_in_count   => v_jobnum ,    --輸入筆數
                           i_out_count  => v_jobnum,     --輸出筆數
                           i_proc_count => v_sucnum,     --成功筆數
                           i_err_count  => v_errnum,     --錯誤筆數
                           i_memo       => v_memo); --失敗筆數
      END;


  v_bachno := CIFX.FN_GET_JOBNO('JOBLOG') ;
  v_jobnum:=0;
  v_sucnum:=0;
  v_errnum:=0;
  v_job_step :='程序開始';
  v_memo := '';



      v_job_step :='判斷前';
      v_memo := 'V_CNT:'||V_CNT ||'V_GROWN_UP_GUARDIAN_SHIP:'||V_GROWN_UP_GUARDIAN_SHIP;
      insert_joblog;




EXCEPTION
        WHEN OTHERS THEN

        v_job_step :='呼叫HOUSEKEEPING有誤';
        v_memo :=  ':程式錯誤狀況=>'||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        insert_joblog;
