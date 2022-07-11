@echo off

echo ====== test start=====

IF EXIST %~dp0%uat_sp_upload.txt  (
rem cfg exists
SETLOCAL ENABLEDELAYEDEXPANSION
for /f "delims='=', tokens=1-2" %%i in (uat_sp_upload.txt) do (
	if /i "%%i" == "workpath" (
	set workpath=%%j
	)
	if /i "%%i" == "sqlplusPath" (
	set sqlplusPath=%%j
	)
)
) ELSE (
rem cfg does NOT exists
set sqlplusPath=\DevEnvironment\sqlPlus\instantclient-basic-windows.x64-19.3.0.0.0dbru\instantclient_19_3\
)

rem set sqlPlusPosition:%sqlplusPath:~0,2%
set workpath=%cd%

For %%i in (CIFX,CIFX_BATCH) do (

IF EXIST temp_%%i rd /S /Q   temp_%%i 

mkdir temp_%%i
mkdir temp2
cd temp_%%i
echo set define off ; >> cifx_all.sql
cd ..
cd  Deploy\%%i \
copy *.sql  ..\..\temp2\
cd ..\..\temp_%%i\
type ..\temp2\*.sql >> cifx_all.sql

cd ..
rd /S /Q  temp2

)

set path1=%workpath%\temp_CIFX\
set path2=%workpath%\temp_CIFX_BATCH\
cd %path1%
echo exit >> cifx_all.sql

cd ..
cd %path2%
echo exit >> cifx_all.sql

cd /d %sqlplusPath%

sqlplus CIFX/CIFXesun13@oradb-cifxu.testesunbank.com.tw:3031/edlsu  @ %workpath%\temp_CIFX\cifx_all.sql  
timeout /t 3

sqlplus CIFX_BATCH/CIFX_BATCH@oradb-cifxu.testesunbank.com.tw:3031/edlsu @ %workpath%\temp_CIFX_BATCH\cifx_all.sql  


cd %workpath%
rd /S /Q  temp_CIFX
rd /S /Q  temp_CIFX_BATCH



echo ====== test end=====
pause







