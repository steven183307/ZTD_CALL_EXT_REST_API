CLASS ztdbp_post DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTDBP_POST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*   METHOD zne_call_ext_api_post.

    " Create HTTP client; send request
    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                 comm_scenario  = 'ZTDCS_CALL_EXT_REST_API'
                                 service_id     = 'ZTDOUT_POST_REST'
                               ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
        DATA(lo_request) = lo_http_client->get_http_request( ).

*///////////////////////////////////////////////////////////////////////////////
        DATA(lo_json_builder) = xco_cp_json=>data->builder( ).
        lo_json_builder->begin_object(
          )->add_member( 'materialCode' )->add_string( 'Neil_0814'
          )->add_member( 'description' )->add_string( 'Neil_0814'
          )->add_member( 'materialGroup' )->add_string( 'Neil_0814'
          )->end_object( ).

        " After execution LV_JSON_STRING will have the value
        DATA(lv_json_string) = lo_json_builder->get_data( )->to_string( ).

        lo_request->set_content_type( 'application/json' ).
*        lv_json_string = lv_json_string + ',' + lv_json_string.
        lo_request->set_text( i_text = lv_json_string ).
*///////////////////////////////////////////////////////////////////////////////

        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
        DATA(lv_json_results) = lo_response->get_text( ).

      CATCH cx_root INTO DATA(lx_exception).
        out->write( 'Error 1' ).
        out->write( lx_exception->get_text( ) ).
    ENDTRY.

    " Create an ABAP structure to contain the data from the API
    TYPES:
      BEGIN OF ts_osm,
        material_code  TYPE string,
        description    TYPE string,
        material_group TYPE string,
      END OF ts_osm.

    DATA ls_osm TYPE ts_osm.

    " Convert the data from JSON to ABAP using the XCO Library; output the data
    TRY.
        xco_cp_json=>data->from_string( lv_json_results )->apply( VALUE #(
          ( xco_cp_json=>transformation->pascal_case_to_underscore )
          ( xco_cp_json=>transformation->boolean_to_abap_bool )
        ) )->write_to( REF #( ls_osm ) ).

        out->write( | -----------Neil_20230721---------- | ).
        out->write( | Material_1: { ls_osm-material_code } , { ls_osm-description } , { ls_osm-material_group } | ).
        out->write( | ---------------------------------- | ).

        " catch any error
      CATCH cx_root INTO DATA(lx_root).
        out->write( 'Error 2' ).
        out->write( lx_root->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
