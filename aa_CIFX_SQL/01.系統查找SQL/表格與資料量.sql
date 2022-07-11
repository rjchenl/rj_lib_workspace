select
   table_name,
   num_rows counter
from
   dba_tables
where
   owner = 'CIFX'
order by
   table_name;