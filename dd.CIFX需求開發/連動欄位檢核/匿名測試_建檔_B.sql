set define off;
DECLARE

V_INPUT_JSON CLOB := '
{
  "header" : {
    "msgNo" : "TS0120_20220214202101_582",
    "txnCode" : "updateCustomer",
    "txnTime" : "2022-02-14 20:21:01",
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
      "oriTradeSeqNo" : "TS0120_20220214202101_582",
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
        "tellerId" : null,
        "operateId" : null,
        "supervisorId" : null,
        "supervisorCardCode" : null,
        "tradeSeqNo" : null,
        "centralizeMark" : null
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
      "creationDepartment" : "9915",
      "industrialPropertyType" : "02",
      "taxType" : "2",
      "principalName" : "代表人是陳阿傑",
      "principalCertificationNumber":"A123456789",
      "birthday" : "19881111",
      "nationality" : "2",
      "registeredCountry" : "CC",
      "customerPropertyType" : "1",
      "customerType" : "01",
      "industrialCodeForDgbas" : "130200",
      "chinaMasterCode" : "1",
      "customerCertificationNumber" : "98135921",
      "customerName" : "ｃｉｆｘ測試公司戶",
      "residentialCity" : "臺北市",
      "residentialZip" : "104",
      "residentialAddressDetail" : "天祥路８６巷１號",
      "residentialArea" : "中山區",
      "permanentCity" : "臺北市",
      "permanentZip" : "100",
      "permanentAddressDetail" : "天祥路８６巷１號",
      "permanentArea" : "中正區"
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

END ;
/



