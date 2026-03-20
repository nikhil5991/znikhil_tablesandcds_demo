@EndUserText.label: 'flight connection with airline name'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZL_FLIGHT_CONN 
    as select from zflight_conn_new as Conn
    association[0..1] to zflight_carr_1 as _Carrier
        on _Carrier.carrier_id = Conn.carrier_id
{
   key Conn.carrier_id as AirlineID,
   key Conn.connection_id as ConnectionID,
       Conn.airport_from_id as DepartureAirport,
       Conn.airport_to_id as DestinationAirport,
       
       _Carrier.carrier_name as AirlineName,
       
       _Carrier
}
