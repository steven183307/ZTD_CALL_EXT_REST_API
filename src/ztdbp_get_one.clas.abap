CLASS ztdbp_get_one DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTDBP_GET_ONE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    " Create HTTP client; send request
    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                 comm_scenario  = 'ZTDCS_CALL_EXT_REST_API'
                                 service_id     = 'ZTDOUT_GET_ONE_REST'
                               ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
        DATA(lo_request) = lo_http_client->get_http_request( ).

        lo_request->set_query( query = 'MaterialCode=Neil_0814' ).

        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get ).
        DATA(lv_json_results) = lo_response->get_text( ).

      CATCH cx_root INTO DATA(lx_exception).
        out->write( lx_exception->get_text( ) ).
    ENDTRY.

    " Create an ABAP structure to contain the data from the API
    TYPES:

      BEGIN OF ts_osm,
        material_code  TYPE string,
        description    TYPE string,
        material_group TYPE string,
      END OF ts_osm.

*    DATA ls_osm TYPE ts_osm.
    DATA ls_osm TYPE STANDARD TABLE OF ts_osm WITH EMPTY KEY.
    DATA ls_osm1 LIKE LINE OF ls_osm.

    " Convert the data from JSON to ABAP using the XCO Library; output the data
    TRY.
        out->write( | -----------0814---------- | ).

        out->write( lv_json_results ).

        out->write( | ---------------------------------- | ).

        " catch any error
      CATCH cx_root INTO DATA(lx_root).
        out->write( lx_root->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
