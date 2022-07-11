--------------------------------------------------------
--  DDL for Table TT_ADDR_MAPPING
--------------------------------------------------------

  CREATE TABLE "CIFX_BATCH"."TT_ADDR_MAPPING" 
   (	"UUID" NUMBER(*,0), 
	"OLD_LI" VARCHAR2(100 CHAR), 
	"OLD_NB" VARCHAR2(100 CHAR), 
	"OLD_ADDR" VARCHAR2(1000 CHAR), 
	"NEW_ADDR" VARCHAR2(1000 CHAR)
   ) ;

   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING"."UUID" IS 'UUID流水號';
   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING"."OLD_LI" IS '(原)里';
   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING"."OLD_NB" IS '(原)鄰';
   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING"."OLD_ADDR" IS '原(地址)';
   COMMENT ON COLUMN "CIFX_BATCH"."TT_ADDR_MAPPING"."NEW_ADDR" IS '(新)地址';
--------------------------------------------------------
--  DDL for Index TT_ADDR_MAPPING_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "CIFX_BATCH"."TT_ADDR_MAPPING_PK" ON "CIFX_BATCH"."TT_ADDR_MAPPING" ("UUID") 
  ;
--------------------------------------------------------
--  Constraints for Table TT_ADDR_MAPPING
--------------------------------------------------------

  ALTER TABLE "CIFX_BATCH"."TT_ADDR_MAPPING" MODIFY ("UUID" NOT NULL ENABLE);
  ALTER TABLE "CIFX_BATCH"."TT_ADDR_MAPPING" ADD CONSTRAINT "TT_ADDR_MAPPING_PK" PRIMARY KEY ("UUID")
  USING INDEX  ENABLE;
