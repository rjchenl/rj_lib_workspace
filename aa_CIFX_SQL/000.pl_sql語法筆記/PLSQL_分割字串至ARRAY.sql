declare
  l_input varchar2(4000) := '1,2,3';
  l_count binary_integer;
  l_array dbms_utility.lname_array;
begin
  dbms_utility.comma_to_table
  ( list   => regexp_replace(l_input,'(^|,)','\1x')
  , tablen => l_count
  , tab    => l_array
   );
   dbms_output.put_line(l_count);
   for i in 1 .. l_count
   loop
     dbms_output.put_line
     ( 'Element ' || to_char(i) ||
       ' of array contains: ' ||
       substr(l_array(i),2)
     );
   end loop;
end;
/