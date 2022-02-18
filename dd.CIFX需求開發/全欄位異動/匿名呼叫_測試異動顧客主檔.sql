clear screen;
SET SERVEROUTPUT ON;
declare
    V_input_json_name CLOB := '{
        "header":{
            "senderCode":"TS0077"
        },
        "requestBody":{
            "header":{
                "infoAssetsNo": "TS0077"
            },
            "model":{
                "mobilePhoneNumber": "0911122233",
                "emailSellingFlag": "Y",
                "numberOfChildren":"20","_this_col_not_in_update_list":null,
                "aaa":"bb",
                "_customerCirciKey":"F121813478",
                "birthday":"19780226",
                "customerCertificationNumber":"F121813478",
                "_update":null,
                "_customerCertificationNumber":"A183018269",
                "_insert":null,
                "_accountNumber":null,
                "_accountNumber":"9999979123987",
                "__accountNumber":"9999979100031",
                "residentialAddressDetail":"辇菗路三段１５號８５樓"
            },
            "optional": {
              "forceUpdate": "7"
            }
        }
    }';
    l_row           CIFX.TB_CUSTOMER%ROWTYPE;
    l_service_id    varchar2(100);
    l_key           varchar2(100);
    v_update_column_array  INPUT_TB_VAR_ARRAY := INPUT_TB_VAR_ARRAY(); --初始化
    l_model_keys JSON_KEY_LIST;
    l_obj   json_object_t := new json_object_t;
    l_obj2  json_object_t := new json_object_t;
    lkeys JSON_KEY_LIST;
    keys_string VARCHAR2(100);
    ja JSON_ARRAY_T := new JSON_ARRAY_T;
    l_ap_server_to_exec                cifx.TB_SERVICE_EXECUTION_CONTROL.AP_SERVER_TO_EXEC      %TYPE := SYS_CONTEXT('USERENV', 'IP_ADDRESS')||':0000,'||SYS_CONTEXT('USERENV', 'HOST');
BEGIN
    DBMS_OUTPUT.PUT_LINE('========= TEST START ==========');
    l_service_id := CIFX.FN_UUID_NUMBER30;
    l_key := JSON_OBJECT_T.parse(V_input_json_name).get_Object('requestBody').get_Object('model').get_string('customerCertificationNumber');
    dbms_output.put_line('key='||l_key);
    begin
    execute immediate 'select * from cifx.tb_customer where cif_verified_id = :1' into l_row using l_key;
    exception
        when NO_DATA_FOUND then l_row := null;
    end;
    l_model_keys := json_object_t.parse(V_input_json_name).get_Object('requestBody').get_Object('model').get_keys;
    FOR ii IN 1 .. l_model_keys.count loop
        v_update_column_array.extend;
        v_update_column_array(ii):=l_model_keys(ii);
        dbms_output.put_line(ii||' v_update_column_array='||v_update_column_array(ii));
    END loop;

    CIFX.PG_UPSERT_CUSTOMER.SP_UPSERT_CUSTOMER_MAIN(
        i_input_json => V_input_json_name,
        i_customer => l_row,
        i_update_column_array => v_update_column_array,
        i_service_interchange_id => l_service_id,
        i_ap_server_to_exec => l_ap_server_to_exec
        );
    DBMS_OUTPUT.PUT_LINE('========= TEST END ==========');
    commit;
--    rollback;
END;
/
