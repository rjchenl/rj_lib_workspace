#!/bin/sh
#ESB18693 YuJie
echo "========== Tomcat Version=========="
currentTime=$(date +%y%m%d%H%M)
echo "===== check point ====="
echo Argument1:{${1}} 
echo Argument2:{${2}}
echo currentTime:{${currentTime}}
echo -n "WHOAMI:" && whoami
echo PATH:{${PATH}}
echo "===== check point ====="
#configure properties
extention=.jar
waiting=60
backupDir=/home/tomcatuser/Backup/
deploymentDir=/opt/Tomcat/deployments
deploymentLogDir=/home/tomcatuser/deployments.log
mainClass="EdlsApplication"
logRecordDir=/opt/Tomcat/configuration/logRecord
#configure properties

trap "cat /home/tomcatuser/tmp.log 1>&2" EXIT

# Argument $1 only used for debug 
checkPositionUnique(){
	echo position:${POSITION}
	{
		POSITION_PATH=`find ${backupDir} -name $POSITION`
	} ||{
		echo ERROR: Multiple target files found! Target:{${1}} must be clear! && exit 1
	}
	
	if [ "$POSITION_PATH" = "" ]
	then
		echo ERROR:${backupDir}${1} cannot be found on server! Please Check!!
		exit 1
	fi
		
	echo POSITION PATH:${POSITION_PATH}
}

automatic_tomcat_shutdown(){

	PID=`ps -aux | grep $1 | grep -v grep | awk '{print $2}'`
	
	while [ "$PID" != "" ]
		do
			echo kill ==${PID}== 
			kill -9 ${PID}
			sleep 2
			PID=`ps -aux | grep $1 | grep -v grep | awk '{print $2}'`
		done
		
		echo tomcat shutdown!
	
		sleep 3
}


get_log_sequence(){

	currentDate=$(date +%Y%m%d)
	
	todaysLog=`awk "/$currentDate/" $logRecordDir | sort -r | head -n 1`
	
	if [ "$todaysLog" = "" ]
	then
	
	echo "${currentDate} 0" >> ${logRecordDir}
	todaysLog=`awk "/$currentDate/" $logRecordDir | sort -r | head -n 1`
	
	fi
	
	lastSequence=`awk "/$currentDate/" $logRecordDir | sort -r | head -n 1 | awk '{print $2}'`
	
	nextSequence=$((${lastSequence} + 1))
	
	sed -i "s/$todaysLog/$currentDate $nextSequence/g" "$logRecordDir"

	echo Get server log sequence: ${nextSequence}
}

automatic_tomcat_start(){

	get_log_sequence

	serverLogDir=/opt/Tomcat/log/"$currentDate".server.log."$nextSequence"
	
	{
	nohup java -jar -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true -Dkafka.truststore.file=/home/tomcatuser/cert/truststore.jks ${deploymentDir}/${1}   >"$serverLogDir" 2>&1 &
	} ||{
	echo ERROR: Started failed! && exit 1
	}
	
	startPID=$!
		
	echo -e "tomcat start! PID:$startPID"
	
	sleep 15
}

automatic_tomcat_check(){
	
	STATUS=`awk "/$mainClass/" "$serverLogDir"`
	COUNT=1
	echo STATUS:"(${STATUS})"
	echo serverLogDir:"(${serverLogDir})"
	while [ "$STATUS" = "" ]
	do
		sleep 1
		
		COUNT=$((${COUNT} + 1))
		
		STATUS=`awk "/$mainClass/" "$serverLogDir"`
		
		echo STATUS:"(${STATUS})"
		
		if [ "$waiting" = "$COUNT" ]
		then
			
			automatic_tomcat_shutdown
			
			resilience=`awk '/'$1'/' "$deploymentLogDir" |sort -nrk2 |awk '{print $1; exit}'`
				
			echo resilience:${resilience}
				
			resilience_position=`ls ${backupDir} | grep ${resilience}`
				
			echo resilience_position:${resilience_position}
			
			if [ "$resilience_position" != "" ]
			then
				
				POSITION=${resilience_position}
				
				checkPositionUnique
				
				resilience_restoration=`echo ${resilience}|awk '{sub(/\.[0-9]{10}\'${extention}'/,"",$0);print}'`
				
				echo resilience_restoration:${resilience_restoration}
		
				mv ${backupDir}"${resilience_position}" ${backupDir}"${resilience_restoration}"${extention}
		
				cp ${backupDir}"${resilience_restoration}"${extention} ${deploymentDir}
				
				sleep 5
		
				mv ${backupDir}"${resilience_restoration}"${extention} ${backupDir}"${resilience_position}"
				
				automatic_tomcat_start ${resilience_restoration}${extention}
				
				STATUS=`awk "/$mainClass/" "$serverLogDir"`
				
				COUNT=1 
				
				while [ "$STATUS" = "" ]
				do
					sleep 1
					
					COUNT=$((${COUNT} + 1))
					
					STATUS=`awk "/$mainClass/" "$serverLogDir"`
					
					if [ "$waiting" = "$COUNT" ]
					then 
						echo ERROR:${1}${extention} deploy failed! ${resilience} recover failed! Backed up in ${backupDir}"$1"."$currentTime""$extention}"! Please Check
						exit 1
					fi
					
				done
				
				echo ERROR:${resilience} recover successfully! ${1}${extention} deploy failed!  Backed up in ${backupDir}"$1"."$currentTime""$extention"! Please Check
				exit 1
				
			fi
				
			echo ERROR:${1}${extention} deploy failed! No files available for recovery! Backed up in ${backupDir}"$1"."$currentTime""$extention"! Please Check
			exit 1
		fi
					
					
	done
		
}

chk_api_success(){
timestamp=$(date +%Y%m%d%H%M%S)
echo timestamp:$timestamp
#gen a number between 1~999
seq_s=$(( $RANDOM % 1000 + 1 ))
echo seq_s:$seq_s

msgNo="$timestamp"_"$seq_s"
echo msgNo:$msgNo



#與msNo的timestamp格式不一樣
 ymdtime=$(date +%Y-%m-%d)
 hmstime=$(date +%H:%M:%S)
 timestamp_s="$ymdtime"" ""$hmstime"
echo timestamp_s:$timestamp_s


build_data_A10101A()
{
  cat <<EOF
{
  "header": {
    "msgNo": "TS0077_$msgNo",
    "txnCode": "A10101A",
    "senderCode": "TS0077",
    "receiverCode": "UP0061",
    "txnTime": "$timestamp_s",
    "operatorCode": "97185",
    "unitCode": "9915",
    "authorizerCode": "test_build"
  },
  "requestBody": {
		"header": {
			"acDate": null,
			"bigAccMarkCode": null,
			"bitMap": null,
			"collectingBranch": null,
			"communicationSeqNo": " 050001",
			"counterRegionType": null,
			"ctl": null,
			"dest": null,
			"deviceName": null,
			"deviceTypeNo": null,
			"dsp": null,
			"dspf": null,
			"eaitradeSeqNo": null,
			"eaitxId": null,
			"ejvld": null,
			"element": null,
			"errorMessage": null,
			"fromAccountNo": null,
			"fsup": null,
			"globalNo": null,
			"headerType": null,
			"infoAssetsNo": "TS0077",
			"irSeqNo": "0000",
			"isHoliday": null,
			"isNextDateAccount": null,
			"length": null,
			"ltrm": null,
			"mac": null,
			"macData": null,
			"mType": null,
			"mtype": null,
			"nextTradeSeqNo": null,
			"oazz": null,
			"oriInData": "",
			"oriTradeSeqNo": " 050001",
			"password": null,
			"pCode": null,
			"processType": null,
			"referenceNumber": null,
			"region": "IFP0QTWB ",
			"regionData": null,
			"repeatFlag": null,
			"returnCode": null,
			"reverseTradeSeqNo": null,
			"row4": null,
			"rsv": "                                                                                                               ",
			"signatureData": null,
			"successTxId": null,
			"syncData": null,
			"systemDate": null,
			"systemTime": null,
			"tradeDateInAP": null,
			"tradeTimeInAP": null,
			"toAccountNo": null,
			"tradeAttribution1": "0",
			"tradeAttribution2": "1",
			"tradeAttribution3": "3",
			"tradeAttribution4": " ",
			"tradeSeqNoInAP": "        ",
			"tradingSummary": null,
			"txId": "A10101A ",
			"txIdInAP": "        ",
			"txSystem": null,
			"txWay": " ",
			"userType": null,
			"uuid": "        ",
			"workStationId": "LC105-19",
			"customerInfo": {
				"customerClub": null,
				"cik": null,
				"moneyLaunderingMarker": null,
				"specificMemberFlag": null
			},
			"teller": {
				"tellerId": "97132",
				"operateId": "65",
				"supervisorId": null,
				"supervisorCardCode": null,
				"tradeSeqNo": null,
				"centratedWork": null
			},
			"branch": {
				"amendDate": null,
				"createDate": null,
				"status": 1,
				"branchSeqNo": null,
				"branchCode": "9999",
				"branchBCode": null,
				"centralStatus": null,
				"signStatus": null,
				"interBranchTransactionStatus": null,
				"accountingStatus": null,
				"lastBizDay": null,
				"curBizDay": null,
				"nextBizDay": null,
				"authorizationCheck": null,
				"entriesOpenClose": null,
				"signOffWay": null,
				"branchIdentificationNumber": null,
				"reSignOn": null,
				"taxBranchCode": null,
				"foreignBusinessType": null,
				"localCurrency": null,
				"generalMark": null,
				"reminderMark": null,
				"simpleMark": null,
				"overseasMark": null,
				"internalNoAccMark": null,
				"internalHaveAccMark": null,
				"obuMark": null,
				"preparatoryOffice": null,
				"holidaybranch": null,
				"forexTrack": null,
				"chineseName": null,
				"taxBranchName": null,
				"phoneNumber": null,
				"address": null,
				"managerName": null,
				"taxSerialNumber": null,
				"houseTaxSerialNumber": null,
				"businessUnit": null,
				"city": null,
				"uniqueCode": null,
				"openingDate": null,
				"englishName": null,
				"holidayEndTime": null,
				"branchMICRMarker": null,
				"checkClearingSettlementBranch": null,
				"checkClearingSettlementCategory": null,
				"settlementLeadingBranch": null,
				"clearingHouseCode": null,
				"foreignSettlementBranch": null,
				"inwardCheckBatchMarker": null,
				"blankCheckBatchMarker": null,
				"bookingUnitMark": null,
				"consumerCenterMark": null,
				"enterpriseCenterMark": null,
				"zipcode": null
			}
		},
		"model": {
			"birthday": "01000614",
			"customerCirciKey": "A121253708",
			"tellerNumber": null
		},
		"optional": {
			"forceUpdate": null
		}
	}
}

EOF
}

build_data_A101011(){
 cat <<EOF
{
  "header": {
    "msgNo": "TS0077_$msgNo",
    "txnCode": "A101011",
    "senderCode": "TS0077",
    "receiverCode": "UP0061",
    "txnTime": "$timestamp_s",
    "operatorCode": "97142",
    "unitCode": "9999",
    "authorizerCode": "test_build"
  },
  "requestBody": {
		"header": {
			"acDate": null,
			"bigAccMarkCode": null,
			"bitMap": null,
			"collectingBranch": null,
			"communicationSeqNo": "       ",
			"counterRegionType": null,
			"ctl": null,
			"dest": null,
			"deviceName": null,
			"deviceTypeNo": null,
			"dsp": null,
			"dspf": null,
			"eaitradeSeqNo": null,
			"eaitxId": null,
			"ejvld": null,
			"element": null,
			"errorMessage": null,
			"fromAccountNo": null,
			"fsup": null,
			"globalNo": null,
			"headerType": null,
			"infoAssetsNo": "TS0077",
			"irSeqNo": "0000",
			"isHoliday": null,
			"isNextDateAccount": null,
			"length": null,
			"ltrm": null,
			"mac": null,
			"macData": null,
			"mType": null,
			"nextTradeSeqNo": null,
			"oazz": null,
			"oriInData": "",
			"oriTradeSeqNo": " 123456",
			"password": null,
			"pCode": null,
			"processType": null,
			"referenceNumber": null,
			"region": "IFP0ATWB ",
			"regionData": null,
			"repeatFlag": null,
			"returnCode": null,
			"reverseTradeSeqNo": null,
			"row4": null,
			"rsv": "                                                                                                               ",
			"signatureData": null,
			"successTxId": null,
			"syncData": null,
			"systemDate": null,
			"systemTime": null,
			"tradeDateInAP": null,
			"tradeTimeInAP": null,
			"toAccountNo": null,
			"tradeAttribution1": "0",
			"tradeAttribution2": "1",
			"tradeAttribution3": "1",
			"tradeAttribution4": " ",
			"tradeSeqNoInAP": "1500001 ",
			"tradingSummary": null,
			"txId": "A101011 ",
			"txIdInAP": "        ",
			"txSystem": null,
			"txWay": " ",
			"userType": null,
			"uuid": "        ",
			"workStationId": "LC105-19",
			"customerInfo": {
				"customerClub": null,
				"cik": null,
				"moneyLaunderingMarker": null,
				"specificMemberFlag": null
			},
			"teller": {
				"tellerId": "97132  ",
				"operateId": "15",
				"supervisorId": null,
				"supervisorCardCode": null,
				"tradeSeqNo": null,
				"centratedWork": null
			},
			"branch": {
				"branchCode": "9999",
				"signStatus": null
			},
			"systemDateROC": null,
			"acDateROC": null
		},
		"model": {
			"customerName": "測試ＮＢＳ測試ＮＢＳ　　　　　　　　　　　　　　　　　　　　　　　　　　　　　",
			"birthday": "00791019",
			"customerCertificationNumber": "O128086646",
			"fullPermanentAddress": "基隆市信義區這是一條路我想不出來了　　　　　　　　　　　　　　　　　　　　　　",
			"permanentPhoneNumber": "           ",
			"fullResidentialAddress": "基隆市信義區這是一條路我想不出來了　　　　　　　　　　　　　　　　　　　　　　",
			"residentialPhoneNumber": "           ",
			"residentialZip": "201",
			"mobilePhoneNumber": "0900000000 ",
			"mobilePhoneNumberForSmsTrade": "           ",
			"fax": "           ",
			"emailAddress": "TEST@TEST.TEST                                    ",
			"accountPurpose": "01",
			"otherAccountPurpose": "　　　　",
			"companyCertificationNumber": "          ",
			"serveCompanyName": "玉山銀行資訊處　　　　　　　　　　　　",
			"companyPhoneNumber": "           ",
			"jobPositionType": "  ",
			"marriedStatus": " ",
			"numberOfChildren": "0",
			"educationLevel": "  ",
			"personalAnnualIncome": "  ",
			"nameInEnglish": "                                                                                ",
			"grownUpGuardianship": " ",
			"principalName": "　　　　　　　　　　",
			"principalCertificationNumber": "          ",
			"foreignExchangeContactName": "　　　　　　　　　　　　　　　　　　　　　　　　　　　　　",
			"foreignExchangeContactPhoneNumber": "                              ",
			"alienResidenceIdentificationNumber": "          ",
			"alienResidenceIssueDate": "        ",
			"alienResidenceExpiredDate": "        ",
			"passportIdentificationNumber": "                    ",
			"industryType": "001",
			"industrialCodeForDgbas": "0615B0",
			"industrialPropertyType": "02",
			"customerPropertyType": "0",
			"customerType": "01",
			"taxType": "1",
			"nationality": "0",
			"registeredCountry": "TW",
			"referrerIdentificationNumber": "          ",
			"foreignExchangeRoleType": "  ",
			"officeFlag": " ",
			"customerStatement": "           ",
			"diplomaticIdentificationNumber": "         ",
			"entryAndExitPermitNumber": "           ",
			"entryAndExitPermitStartDate": "00000000",
			"entryAndExitPermitEndDate": "00000000",
			"capital": "0",
			"annualRevenue": "  ",
			"forceUpdate": "Y",
			"travelCardFlag": " "
		},
		"optional": {
			"forceUpdate": null
		}
	}
}

EOF
}


statusCode_A10101A=$(curl -d "`build_data_A10101A`" -H "Content-Type: application/json" -k  -v  -X POST https://cifxsitap.testesunbank.com.tw:8443/cifxs/queryIntegrationOpenedAccount | grep    \"resultCode\":\"0000\" )
statusCode_A101011=$(curl -d "`build_data_A101011`" -H "Content-Type: application/json" -k  -v  -X POST https://cifxsitap.testesunbank.com.tw:8443/cifxs/openIntegrationAccount | grep    \"resultCode\":\"0000\" )

echo statusCode_A10101A:$statusCode_A10101A
echo statusCode_A101011: $statusCode_A101011

 if  [ "$statusCode_A10101A" == "" ] || [ "$statusCode_A101011" == "" ];then
 echo has err
 exit 1
 fi

}



if [ "$2" = "Y" ]
then
	echo Mode: specific version on server
	
	POSITION=`ls ${backupDir} | grep $1`
	
	checkPositionUnique ${1}
	
	restoration=`echo ${POSITION}|awk '{sub(/\.[0-9]{10}\'${extention}'/,"",$0);print}'`
	
	echo restoration:${restoration}
	
	mv ${backupDir}"${POSITION}" ${backupDir}"${restoration}"${extention}
	
	cp ${backupDir}"${restoration}"${extention} ${deploymentDir}
	
	sleep 5
	
	mv ${backupDir}"${restoration}"${extention} ${backupDir}"${POSITION}"
	
	automatic_tomcat_shutdown ${restoration}${extention}
	
	automatic_tomcat_start ${restoration}${extention}
	
	automatic_tomcat_check ${restoration}
	
	echo specific version Deploy finished! ${POSITION}
	
elif [ "$2" = "N" ]
then

	echo Mode: Normal
	
	POSITION=${1}${extention}
	
	checkPositionUnique ${1}${extention}
	
	echo ${POSITION} successfully upload !!!
	
	cp "$backupDir""$POSITION" "$deploymentDir"

	sleep 5

	mv "$backupDir""$POSITION" "$backupDir""$1"."$currentTime""$extention"
	
	automatic_tomcat_shutdown ${POSITION}
	
	automatic_tomcat_start ${POSITION}
	
	automatic_tomcat_check ${1}
	
	echo Deploy finished! Labeled as "$1"."$currentTime""$extention"
	echo -e "$1"."$currentTime""$extention" >> "$deploymentLogDir"
	echo The latest five versions :
	awk '/'${1}'/' "$deploymentLogDir" |sort -nrk1 |awk 'NR < 6'

elif [ "$2" = "RE" ]
then
	echo Mode: RE-RUN
	
	POSITION=${1}${extention}
	
	backupDir=/opt/Tomcat/deployments/
	
	checkPositionUnique ${1}${extention}
	
	backupDir=/home/tomcatuser/Backup/
	
	echo Ready
	
	automatic_tomcat_shutdown ${POSITION}
	
	automatic_tomcat_start ${POSITION}
	
	automatic_tomcat_check ${1}
	
	echo RE-RUN finished!
	
else
	echo ERROR:Argument2 {${2}} must be Y or N! Please Check
	exit 1
fi	
	chk_api_success
	echo Completed!
