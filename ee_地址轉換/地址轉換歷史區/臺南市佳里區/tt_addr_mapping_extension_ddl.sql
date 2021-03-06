--------------------------------------------------------
--  DDL for Table TT_ADDR_MAPPING_EXTENSION
--------------------------------------------------------

  CREATE TABLE "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION" 
   (	"UUID" NUMBER(*,0), 
	"GROUP_ID" VARCHAR2(100 CHAR), 
	"PATTERN_NO" VARCHAR2(100 CHAR), 
	"OLD_LI" VARCHAR2(100 CHAR), 
	"OLD_NB" VARCHAR2(100 CHAR), 
	"OLD_ADDR" VARCHAR2(2000 CHAR), 
	"NEW_ADDR" VARCHAR2(2000 CHAR)
   ) ;

   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION"."UUID" IS '流水號';
   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION"."GROUP_ID" IS '分群ID(原資料UUID)';
   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION"."PATTERN_NO" IS '對映轉換型式';
   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION"."OLD_LI" IS '舊里';
   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION"."OLD_NB" IS '舊鄰';
   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION"."OLD_ADDR" IS '舊詳細地址';
   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION"."NEW_ADDR" IS '新詳細地址';
--------------------------------------------------------
--  DDL for Index TT_ADDR_MAPPING_EXTENSION_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION_PK" ON "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION" ("UUID") 
  ;
--------------------------------------------------------
--  Constraints for Table TT_ADDR_MAPPING_EXTENSION
--------------------------------------------------------

  ALTER TABLE "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION" MODIFY ("UUID" NOT NULL ENABLE);
  ALTER TABLE "CIFX_BATCH"."TT_ADDR_MAPPING_EXTENSION" ADD CONSTRAINT "TT_ADDR_MAPPING_EXTENSION_PK" PRIMARY KEY ("UUID")
  USING INDEX  ENABLE;
