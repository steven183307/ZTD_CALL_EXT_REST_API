CLASS ztdbp_web_version DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTDBP_WEB_VERSION IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    " Create HTTP client; send request
    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                 comm_scenario  = 'ZTDCS_CALL_EXT_REST_API'
                                 service_id     = 'ZTDOUT_GET_ALL_REST'
                               ).
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
        DATA(lo_request) = lo_http_client->get_http_request( ).

        lo_request->set_query( query = '' ).

        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get ).
        DATA(lv_json_results) = lo_response->get_text( ).

        DATA: result2 TYPE String.

      CATCH cx_root INTO DATA(lx_exception).
        result2 = lx_exception->get_text( ) .
    ENDTRY.

    " Create an ABAP structure to contain the data from the API
    TYPES:
      BEGIN OF ts_osm,
        material_code  TYPE string,
        description    TYPE string,
        material_group TYPE string,
      END OF ts_osm.

    DATA lt_osm TYPE STANDARD TABLE OF ts_osm WITH EMPTY KEY.
    DATA ls_osm LIKE LINE OF lt_osm.

    " Convert the data from JSON to ABAP using the XCO Library; output the data
    TRY.
        xco_cp_json=>data->from_string( lv_json_results )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore )
          ( xco_cp_json=>transformation->boolean_to_abap_bool )
        ) )->write_to( REF #( lt_osm ) ).

        DATA: result TYPE String.

        result = |<!DOCTYPE HTML> \n| &&
                 |<html> \n| &&
                 |<head> \n| &&
                 |    <meta http-equiv="X-UA-Compatible" content="IE=edge"> \n| &&
                 |    <meta http-equiv='Content-Type' content='text/html;charset=UTF-8' /> \n| &&
                 |    <title>Json Uploader to Create SO</title> \n| &&
                 |</head> \n| &&
                 |<body> \n| &&
                 |<div>|.

        LOOP AT lt_osm INTO ls_osm.
          result = result && | Material_{ sy-tabix }:{ ls_osm-material_code },{ ls_osm-description },{ ls_osm-material_group } <br>| .
        ENDLOOP.

        result = result && |</div> \n| &&
                           |</body> \n| &&
                           | \n| &&
                           |</html> |.

        response->set_text( result ).

        " catch any error
      CATCH cx_root INTO DATA(lx_root).
        result = lx_root->get_text( ) .
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
