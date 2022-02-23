
--刪除前確認463筆資料
SELECT COUNT(1) from cifx_batch.tt_impt_ci_list
WHERE NOT( PER_AREA = '大雅區' OR CONT_AREA ='大雅區');

--執行刪除
DELETE cifx_batch.tt_impt_ci_list
WHERE NOT( PER_AREA = '大雅區' OR CONT_AREA ='大雅區');

--刪除前確認應為0筆
SELECT COUNT(1) from cifx_batch.tt_impt_ci_list
WHERE NOT( PER_AREA = '大雅區' OR CONT_AREA ='大雅區');


--確認無誤後COMMIT
COMMIT;