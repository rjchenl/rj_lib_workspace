--------------------------------------------------------
--  已建立檔案 - 星期六-十二月-11-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table TB_COL_VALIDATION
--------------------------------------------------------

  CREATE TABLE "CIFX"."TB_COL_VALIDATION" 
   (	"COL_VLII_ID" NUMBER(*,0), 
	"SENDER_CODE" VARCHAR2(20 CHAR), 
	"COLUMN_CODE" VARCHAR2(20 CHAR), 
	"TX_ID" VARCHAR2(100 CHAR), 
	"VALI_ID" VARCHAR2(20 CHAR), 
	"VALI_PROCESS" CLOB, 
	"ERROR_CODE" VARCHAR2(100 CHAR), 
	"VALI_CONTENT" VARCHAR2(3000 CHAR)
   ) ;

   COMMENT ON COLUMN "CIFX"."TB_COL_VALIDATION"."COL_VLII_ID" IS '流水號';
   COMMENT ON COLUMN "CIFX"."TB_COL_VALIDATION"."SENDER_CODE" IS '系統代碼';
   COMMENT ON COLUMN "CIFX"."TB_COL_VALIDATION"."COLUMN_CODE" IS '欄位代碼';
   COMMENT ON COLUMN "CIFX"."TB_COL_VALIDATION"."TX_ID" IS '交易代號';
   COMMENT ON COLUMN "CIFX"."TB_COL_VALIDATION"."VALI_ID" IS '檢核編號';
   COMMENT ON COLUMN "CIFX"."TB_COL_VALIDATION"."VALI_PROCESS" IS '驗證流程';
   COMMENT ON COLUMN "CIFX"."TB_COL_VALIDATION"."ERROR_CODE" IS '錯誤代碼';
   COMMENT ON COLUMN "CIFX"."TB_COL_VALIDATION"."VALI_CONTENT" IS '檢核內容';
REM INSERTING into CIFX.TB_COL_VALIDATION
SET DEFINE OFF;
Insert into CIFX.TB_COL_VALIDATION (COL_VLII_ID,SENDER_CODE,COLUMN_CODE,TX_ID,VALI_ID,ERROR_CODE,VALI_CONTENT) values (1,'TS0077','X0150',null,'V_001','$181','『居留證期限』＞＝1年且﹝行業編號（主計處代碼）﹞第1-2碼≠「06」');
--------------------------------------------------------
--  DDL for Index TB_COL_VALIDATION_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "CIFX"."TB_COL_VALIDATION_PK" ON "CIFX"."TB_COL_VALIDATION" ("COL_VLII_ID") 
  ;
--------------------------------------------------------
--  Constraints for Table TB_COL_VALIDATION
--------------------------------------------------------

  ALTER TABLE "CIFX"."TB_COL_VALIDATION" MODIFY ("COL_VLII_ID" NOT NULL ENABLE);
  ALTER TABLE "CIFX"."TB_COL_VALIDATION" ADD CONSTRAINT "TB_COL_VALIDATION_PK" PRIMARY KEY ("COL_VLII_ID")
  USING INDEX  ENABLE;
