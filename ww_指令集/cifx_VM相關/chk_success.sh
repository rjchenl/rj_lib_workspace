#!/bin/sh
#purpose : test build ap succuess

echo ===========test start =============


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
				"tellerId": "97185  ",
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
				"branchCode": "9915",
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
			"birthday": "        ",
			"customerCirciKey": "Y252051459",
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
				"tellerId": "97142  ",
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


statusCode_A10101A=$(curl -d "`build_data_A10101A`" -H "Content-Type: application/json" -k  -v  -X POST https://10.230.212.163:8443/cifxf/queryIntegrationOpenedAccount | grep    \"resultCode\":\"0000\" )
statusCode_A101011=$(curl -d "`build_data_A101011`" -H "Content-Type: application/json" -k  -v  -X POST https://10.230.212.163:8443/cifxf/openIntegrationAccount | grep    \"resultCode\":\"0000\" )

echo statusCode_A10101A:$statusCode_A10101A
echo statusCode_A101011: $statusCode_A101011

 if  [ "$statusCode_A10101A" == "" ] || [ "$statusCode_A101011" == "" ];then
 echo has err
 exit 1
 fi
 

echo ===========test end =============