@echo off

set workpath=D:\DEV\CIFX_GIT\cifx

IF EXIST Assigment rd /S /Q   Assigment 
mkdir Assigment\Deploy
mkdir Assigment\Rollback


For %%i in (CIFX,CIFX_BATCH) do (

mkdir Assigment\Deploy\%%i 
mkdir Assigment\Rollback\%%i 
mkdir temp2

mkdir temp3

cd Assigment\Deploy\%%i  
echo set define off ; >> %%i_all.sql
echo alter session set current_schema = %%i ; >> %%i_all.sql
cd ..\..\..
cd  Deploy\%%i\



copy *.sql  ..\..\temp2\ > nul 2>nul
cd ..\..\Assigment\Deploy\%%i
type ..\..\..\temp2\*.sql >> %%i_all.sql 2>nul

cd ..\..\..
cd Assigment\Rollback\%%i  
echo set define off ; >> %%i_all.sql
echo alter session set current_schema = %%i ; >> %%i_all.sql
cd ..\..\..
cd  Rollback\%%i\


copy *.sql  ..\..\temp3\ > nul 2>nul
cd ..\..\Assigment\Rollback\%%i
type ..\..\..\temp3\*.sql >> %%i_all.sql 2>nul




rem delete tmp folder
cd ..\..\..
rd /S /Q  temp2
rd /S /Q  temp3




)

setlocal enableextensions
cd Rollback\CIFX
set count=0
for %%x in (*.sql) do set /a count+=1



if %count% geq 1 (
 echo Rollback\CIFX 掸计: %count% 
) else (
 echo Rollback\CIFX 掸计: %count%
 del ..\..\Assigment\Rollback\CIFX\CIFX_all.sql /s /f /q
 
)

cd ..\..

cd Rollback\CIFX_BATCH
set count=0
for %%x in (*.sql) do set /a count+=1




if %count% geq 1 (
  echo Rollback\CIFX_BATCH 掸计: %count%  
 ) else (
 echo Rollback\CIFX_BATCH 掸计: %count%
 del ..\..\Assigment\Rollback\CIFX_BATCH\CIFX_BATCH_all.sql /s /f /q
 
)


cd ..\..


cd Deploy\CIFX
set count=0
for %%x in (*.sql) do set /a count+=1


if %count% geq 1 (
  echo Deploy\CIFX 掸计: %count% 
 ) else (
  echo Deploy\CIFX 掸计: %count%
 del ..\..\Assigment\Deploy\CIFX\CIFX_all.sql /s /f /q
 
)

cd ..\..


cd Deploy\CIFX_BATCH
set count=0
for %%x in (*.sql) do set /a count+=1


if %count% geq 1 (
 echo Deploy\CIFX_BATCH 掸计: %count%  
 ) else (
 echo Deploy\CIFX_BATCH 掸计: %count%
 del ..\..\Assigment\Deploy\CIFX_BATCH\CIFX_BATCH_all.sql /s /f /q
 
)

cd ..\..

endlocal



pause






