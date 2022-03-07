#!/bin/bash
# author:ESB18442
# purpose :routine clean cif -ts  log 

current_year=`date +%Y`
current_month=`date +%m`

#delete server log
find /opt/Tomcat/log/ -name "*.log.*" -mtime +13 -exec rm -rf {} \;

#delete ap log
find /opt/Tomcat/log/UP0061_01/log/ap-$current_year/$current_month/ -name "*.log" -mtime +13 -exec rm -rf {} \;
find /opt/Tomcat/log/UP0061_01/log/trace-sql-$current_year/$current_month/ -name "*.log" -mtime +13 -exec rm -rf {} \;
find /opt/Tomcat/log/UP0061_01/log/outbound-$current_year/$current_month/ -name "*.log" -mtime +13 -exec rm -rf {} \;
