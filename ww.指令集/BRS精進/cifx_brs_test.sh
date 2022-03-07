#!/bin/sh
# author: ESB18442
# purpose :CIFX BRS service validation



echo "=========== test start ================="
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
      "customerCirciKey":"A158460693",
      "birthday":"00000000"
		},
		"optional": {
			"forceUpdate": null
		}
	}
}

EOF
}

statusCode_A10101A=$(curl -d "`build_data_A10101A`" -H "Content-Type: application/json" -k  -v  -X POST https://localhost:8443/cifx/queryIntegrationOpenedAccount | grep    \"resultCode\":\"0000\" )
echo "statusCode_A10101A:"$statusCode_A10101A
echo "=========== test end ===================" 
