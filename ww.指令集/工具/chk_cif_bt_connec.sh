#!/bin/bash
echo ==== CIF PROD  BT SERVER Telnet Test start===========
echo  "
REDIS1 10.230.181.13 6379
REDIS2 10.230.181.13 6380
REDIS3 10.230.181.13 6381
REDIS4 10.230.181.14 6379
REDIS5 10.230.181.14 6380
REDIS6 10.230.181.14 6381
REDIS7 10.230.181.15 6379
REDIS9 10.230.181.15 6380
REDIS9 10.230.181.15 6381
DB1 10.230.204.40 4001
DB2 10.230.204.41 4001
DB3 10.230.204.42 4001
OMS valarm.esunbank.com.tw 3000
ElasticSearch1 10.230.202.31 443
ElasticSearch2 10.230.202.31 9300
ElasticSearch3 10.230.202.32 443
ElasticSearch4 10.230.202.32 9300
ElasticSearch5 10.230.202.33 443
ElasticSearch6 10.230.202.33 9300
ECSG ecsg.esunbank.com.tw 443
kafka1 amihap1p.esunbank.com.tw 9093
kafka2 amihap2p.esunbank.com.tw 9093
kafka3  amihap3p.esunbank.com.tw 9093
" |
while read name host port; 
do

  
  if [ "$name" != "" ] && [ "$host" != "" ] && [ "$port" != "" ] ; then
    r=$(bash -c 'exec 3<> /dev/tcp/'$host'/'$port';echo $?' 2>/dev/null)
    if [ "$r" = "0" ]; then
      echo $name $host $port is open
    else
   
      echo $name $host $port is closed
    fi
   fi
done

echo ==== CIF PROD  BT SERVER Telnet Test end===========
