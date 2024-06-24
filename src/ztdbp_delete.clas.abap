CLASS ztdbp_delete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTDBP_DELETE IMPLEMENTATION.


 METHOD if_oo_adt_classrun~main.
    " Create HTTP client; send request
    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                 comm_scenario  = 'ZTDCS_CALL_EXT_REST_API'
                                 service_id     = 'ZTDOUT_DELETE_REST'
                               ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
        DATA(lo_request) = lo_http_client->get_http_request( ).

        lo_request->set_query( query = 'MaterialCode=Neil_0814' ).

        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>delete ).
        DATA(lv_json_results) = lo_response->get_status( ).

      CATCH cx_root INTO DATA(lx_exception).
        out->write( lx_exception->get_text( ) ).
    ENDTRY.

    " Convert the data from JSON to ABAP using the XCO Library; output the data
    TRY.
        out->write( | { lv_json_results-code } : { lv_json_results-reason } | ).

        " catch any error
      CATCH cx_root INTO DATA(lx_root).
        out->write( lx_root->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
