--------------------------------------------------------
--  已建立檔案 - 星期四-一月-28-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table TT_IMPT_CI_LIST
--------------------------------------------------------

  CREATE TABLE "CIFX_BATCH"."TT_IMPT_CI_LIST" 
   (	"SEQ_NUM" NUMBER, 
	"CIRCI_KEY" VARCHAR2(40 CHAR), 
	"REGI_ADDRESS_DETAIL" VARCHAR2(200 CHAR), 
	"CHG_REGI_ADDRESS_DETAIL" VARCHAR2(200 CHAR), 
	"PER_CITY" VARCHAR2(30 CHAR), 
	"PER_ZIP" VARCHAR2(5 CHAR), 
	"PER_AREA" VARCHAR2(30 CHAR), 
	"CONT_ADDRESS_DETAIL" VARCHAR2(200 CHAR), 
	"CHG_CONT_ADDRESS_DETAIL" VARCHAR2(200 CHAR), 
	"CONT_CITY" VARCHAR2(30 CHAR), 
	"CUST_ZIP_CODE" VARCHAR2(5 CHAR), 
	"CONT_AREA" VARCHAR2(30 CHAR), 
	"RESULT_MSG" VARCHAR2(50 CHAR)
   ) ;
