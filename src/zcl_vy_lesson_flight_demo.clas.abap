CLASS zcl_vy_lesson_flight_demo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VY_LESSON_FLIGHT_DEMO IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  out->write( '=====================================' ).
  out->write( 'Ower Own Flight Database(TABLES AND CDS)' ).
  out->write( '=====================================' ).
  out->write( ' ' ).


  "---------------------------------------
  " 1) Seed sample data (So we don't depend on table preview)
  "---------------------------------------

  "Airlines
  DATA lt_carr TYPE STANDARD TABLE OF zflight_carr_1 WITH EMPTY KEY.
  lt_carr = VALUE #(

        ( carrier_id = 'LH' carrier_name = 'Lufthansa' )
        ( carrier_id = 'AA' carrier_name = 'Indian Airlines' )
        ( carrier_id = 'JL' carrier_name = 'American Airlines' )
        ( carrier_id = 'JL' carrier_name = 'Japanis Airlines' )
        ( carrier_id = 'JL' carrier_name = 'Europian Airlines' )
        ( carrier_id = 'JL' carrier_name = 'German Airlines' )
  ).


  "Connections
  DATA lt_conn TYPE STANDARD TABLE OF zflight_conn_new WITH EMPTY KEY.
  lt_conn = VALUE #(

        ( carrier_id = 'LH' connection_id = '0400' airport_from_id = 'FRA' airport_to_id = 'MUC' )
        ( carrier_id = 'LH' connection_id = '1001' airport_from_id = 'FRA' airport_to_id = 'BER' )
        ( carrier_id = 'AA' connection_id = '0007' airport_from_id = 'JRA' airport_to_id = 'LAX' )
        ( carrier_id = 'JL' connection_id = '0088' airport_from_id = 'HND' airport_to_id = 'KIX' )

  ).


  "Upsert-style: Insert new rows, updates existing rows (if keys match)
  "Note: Client (MANDT) is handled automatically by ABAP SQL for client dependent tables.
  MODIFY zflight_carr_1 FROM TABLE @lt_carr.
  MODIFY zflight_conn_new FROM TABLE @lt_conn.


  out->write( 'Sample data Inserted\Updated In ZFLIGHT_CARR_1 AND ZFLIGHT_CONN_NEW' ).
  out->write( '' ).


  "--------------------------------------------------------------------------------
  " 2) Investigating table definition
  "    - Keys : MANDT + CARRIER_ID + CONNECTION_ID
  "    - Client handling is automatic
  "---------------------------------------------------------------------------------

  out->write( '=====================================================' ).
  out->write( 'SELECT SINGLE from TABLE ZFLIGHT_CONN_NEW' ).
  out->write( '=====================================================' ).


  DATA carrier_id TYPE zflight_conn_new-carrier_id VALUE 'LH'.
  DATA connection_id TYPE zflight_conn_new-connection_id VALUE '0400'.
  DATA airport_from TYPE zflight_conn_new-airport_from_id.
  DATA airport_to TYPE zflight_conn_new-airport_to_id.


  CLEAR: airport_from, airport_to.

  SELECT SINGLE
    FROM ZFLIGHT_CONN_NEW
    FIELDS airport_from_id, airport_to_id
    WHERE carrier_id = @carrier_id
      AND connection_id = @connection_id
    INTO ( @airport_from, @airport_to ).


    IF sy-subrc = 0.
        out->write( |Flight { carrier_id } { connection_id } : { airport_from } -> { airport_to }| ).
        out->write( 'Note: table read gives us airports but not airline names' ).
    ELSE.
        out->write( |No row found for { carrier_id } { connection_id } (sy-subrc <> 0)| ).
    ENDIF.


  "--------------------------------------------------------------------------------
  " 3) SELECT SINGLE from CDS view entity ZL_FLIGHT_CONN
  "    - Cleaner names + airline name available
  "---------------------------------------------------------------------------------


  out->write( '=====================================================' ).
  out->write( 'SELECT SINGLE from CDS View Entity ZL_FLIGHT_CONN' ).
  out->write( '=====================================================' ).

  DATA dep_airport TYPE zflight_conn_new-airport_from_id.
  DATA dst_airport TYPE zflight_conn_new-airport_to_id.
  DATA airline_name TYPE zflight_carr_1-carrier_name.

  CLEAR: dep_airport, dst_airport, airline_name.


  SELECT SINGLE
    FROM ZL_FLIGHT_CONN
    FIELDS DepartureAirport, DestinationAirport, AirlineName
    WHERE AirlineID = @carrier_id
        AND ConnectionID = @connection_id
    INTO ( @dep_airport, @dst_airport, @airline_name ).



    IF sy-subrc = 0.
        out->write( |Flight { carrier_id } { connection_id } : { dep_airport } -> { dst_airport }| ).
        out->write( |Airline : { airline_name }| ).
        out->write( 'CDS is nicer: readable fields name + related data included' ).
    ELSE.
        out->write( |No row found via CDS for { carrier_id } { connection_id } (sy-subrc <> 0)| ).
    ENDIF.

    out->write( '' ).


  "--------------------------------------------------------------------------------
  " 4) Show empty result quickly now
  "---------------------------------------------------------------------------------


  out->write( '=====================================================' ).
  out->write( 'Empty Result Demo (sy-subrc + target behaviour)' ).
  out->write( '=====================================================' ).

  DATA bad_carrier TYPE zflight_conn_new-carrier_id VALUE 'XX'.
  DATA bad_conn TYPE zflight_conn_new-connection_id VALUE '6666'.

  " Intentionally do NOT CLEAR dep_airport here to show the concept:


  SELECT SINGLE
    FROM zflight_conn_new
    FIELDS airport_from_id
    WHERE carrier_id = @bad_carrier
        AND connection_id = @bad_conn
    INTO @dep_airport.



    IF sy-subrc = 0.
        out->write( |Found: { dep_airport }| ).
    ELSE.
        out->write( 'No row found (sy-subrc <> 0).' ).
        out->write( |dep airport still = { dep_airport } because SELECT does not overwrite it.| ).
        out->write( 'Best practice : CLEAR targets before SELECT, and handle the no result brance.' ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
