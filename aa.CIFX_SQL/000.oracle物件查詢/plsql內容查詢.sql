
select * from DBA_objects
where
OWNER = 'CIFX'
AND
(
object_type='PACKAGE'
or object_type = 'FUNCTION'
OR OBJECT_TYPE = 'PROCEDURE'
);
/


SELECT * FROM ALL_SOURCE
WHERE 1 = 1
AND TYPE = 'PACKAGE BODY'
AND OWNER = 'CIFX'    --放schema name
AND NAME = 'PG_RJTEST' --放置Package name
;
/