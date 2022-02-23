--DBMS_OUTPUT.ENABLE(buffer_size => null);
set define off;
DECLARE

--V_INPUT_JSON CLOB := '{ "header": { "msgNo": "TS0077_20211208160318_224", "txnCode": "updateCustomer", "txnTime": "2021-12-08 16:03:18", "senderCode": "TS0077", "receiverCode": "TS0116", "operatorCode": "98930", "unitCode": "0598", "authorizerCode": "RJCHENL" }, "requestBody": { "header": { "acDate": "20211208", "acDateROC": "01101208", "bitMap": null, "cashier": null, "collectingBranch": null, "communicationSeqNo": null, "counterRegionType": null, "ctl": null, "deviceName": null, "deviceTypeNo": null, "element": null, "errorMessage": null, "fromAccountNo": null, "globalNo": null, "headerType": null, "infoAssetsNo": "TS0077", "irSeqNo": "0000", "isHoliday": null, "isNextDateAccount": null, "length": null, "mac": null, "macData": null, "mType": null, "nextTradeSeqNo": null, "oriTradeSeqNo": "E60007", "password": null, "pCode": null, "processType": null, "referenceNumber": null, "region": "IFP0ATWB", "returnCode": null, "reverseTradeSeqNo": null, "row4": null, "rsv": null, "signatureData": null, "syncData": null, "systemDate": null, "systemDateROC": null, "systemTime": null, "tradeDateInAP": null, "tradeTimeInAP": null, "toAccountNo": null, "tradeAttribution1": "0", "tradeAttribution2": "1", "tradeAttribution3": "1", "tradeAttribution4": null, "tradeSeqNoInAP": "{{msgNo}}", "tradingSummary": null, "txId": "A121012", "txIdInAP": null, "txSystem": null, "userType": null, "uuid": null, "workStationId": "Local", "customerInfo": { "customerClub": null, "cik": null, "moneyLaunderingMarker": null, "specificMemberFlag": null }, "teller": { "tellerId": "98930", "operateId": "E7", "supervisorId": null, "supervisorCardCode": null, "tradeSeqNo": "12", "centralizeMark": "N" }, "branch": { "branchCode": "9257", "signStatus": null }, "oriInData": null, "msgCode": null, "sys": null, "msgType": null, "dateTime": null, "localDate": null, "localTime": null, "EAITradeSeqNo": null, "EJVLD": null, "EAITxId": null }, "model": { "customerCirciKey": "F121284477", "mobilePhoneNumber": "0911122234", "residentialPhoneNumber": "0933333333", "permanentPhoneNumber": "0987654321", "customerCertificationNumber": "F121284477", "birthday": "19710820", "industrialCodeForDgbas": "021601" }, "optional": { "forceUpdate": "" } } }';
V_INPUT_JSON CLOB := '
 {
  "header" : {
    "msgNo" : "TS0120_20220215164842_361",
    "txnCode" : "updateCustomer",
    "txnTime" : "2022-02-15 16:48:42",
    "senderCode" : "TS0120",
    "receiverCode" : "TS0116",
    "operatorCode" : null,
    "unitCode" : "9915",
    "authorizerCode" : "rjchenl"
  },
  "requestBody" : {
    "header" : {
      "acDate" : null,
      "acDateROC" : null,
      "bitMap" : null,
      "cashier" : null,
      "collectingBranch" : null,
      "communicationSeqNo" : null,
      "counterRegionType" : null,
      "ctl" : null,
      "deviceName" : null,
      "deviceTypeNo" : null,
      "element" : null,
      "errorMessage" : null,
      "fromAccountNo" : null,
      "globalNo" : null,
      "headerType" : null,
      "infoAssetsNo" : "TS0120",
      "irSeqNo" : null,
      "isHoliday" : null,
      "isNextDateAccount" : null,
      "length" : null,
      "mac" : null,
      "macData" : null,
      "mType" : null,
      "nextTradeSeqNo" : null,
      "oriTradeSeqNo" : "TS0120_20220215164842_361",
      "password" : null,
      "pCode" : null,
      "processType" : null,
      "referenceNumber" : null,
      "region" : null,
      "returnCode" : null,
      "reverseTradeSeqNo" : null,
      "row4" : null,
      "rsv" : null,
      "signatureData" : null,
      "syncData" : null,
      "systemDate" : null,
      "systemDateROC" : null,
      "systemTime" : null,
      "tradeDateInAP" : null,
      "tradeTimeInAP" : null,
      "toAccountNo" : null,
      "tradeAttribution1" : null,
      "tradeAttribution2" : null,
      "tradeAttribution3" : null,
      "tradeAttribution4" : null,
      "tradeSeqNoInAP" : null,
      "tradingSummary" : null,
      "txId" : "updateCustomer",
      "txIdInAP" : null,
      "txSystem" : null,
      "userType" : null,
      "uuid" : null,
      "workStationId" : null,
      "customerInfo" : {
        "customerClub" : null,
        "cik" : null,
        "moneyLaunderingMarker" : null,
        "specificMemberFlag" : null
      },
      "teller" : {
        "tellerId" : "97217  ",
        "operateId" : "10",
        "supervisorId" : "     ",
        "supervisorCardCode" : null,
        "tradeSeqNo" : null,
        "centralizeMark" : "Y"
      },
      "branch" : {
        "branchCode" : "9915",
        "signStatus" : null
      },
      "oriInData" : null,
      "msgCode" : null,
      "sys" : null,
      "msgType" : null,
      "dateTime" : null,
      "localDate" : null,
      "localTime" : null,
      "EAITradeSeqNo" : null,
      "EJVLD" : null,
      "EAITxId" : null
    },
    "model" : {
          "customerCertificationNumber": "04174592",
            "creationDepartment": "9915",
            "customerName": "ｃｉｆｘ測試公司戶",
            "birthday": "19881111",
            "permanentCity": "臺北市",
            "permanentArea": "中正區",
            "permanentAddressDetail": "天祥路８６巷１號",
            "permanentZip": "100",
            "residentialCity": "臺北市",
            "residentialArea": "中山區",
            "residentialAddressDetail": "天祥路８６巷１號",
            "residentialZip": "104",
            "industrialCodeForDgbas": "130100",
            "customerPropertyType": "1",
            "customerType": "01",
            "taxType": "1",
            "nationality": "0",
            "registeredCountry": "TW",
            "industrialPropertyType": "02",
            "chinaMasterCode": "1",
            "chinaSubCode": "",
            "principalName": "代表人是陳阿傑",
            "companyExtensionNumber":"13",
            "parentCompanyCertificationNumber":"04174592"

    },
    "optional" : {
      "forceUpdate" : ""
    }
  }
}
';
--O_RESULT_CODE CLOB := '';
--O_RESULT_DESC CLOB := '';
O_RESULT_CODE varchar2(3000 char) := '';
O_RESULT_DESC varchar2(3000 char) := '';

BEGIN
CIFX.PG_UPDATE_ALL_COL_CUST.SP_UPDATE_ALL_COL_CUST
(I_INPUT_JSON => V_INPUT_JSON,
I_SERVICE_INTERCHANGE_ID => '1234',
I_AP_SERVER_TO_EXEC   => '5566',
O_RESULT_CODE => O_RESULT_CODE,
O_RESULT_DESC => O_RESULT_DESC
);

DBMS_OUTPUT.PUT_LINE('O_RESULT_DESC:'||O_RESULT_DESC);
commit;
END ;
/
