component extends='escher.models.AbstractWidget' accessors=true {
    variables.location  = {};

    setLines( [
        'Gathering weather data....'
    ] );

    function process() {
        while( isActive() ){

            var data = [];

            try{
                var location = getLocation();
                cfhttp(
                    url = "https://wttr.in/#location.city#, #location.region#",
                    useragent="curl/7.54.1"
                );
                data = cfhttp.fileContent.listToArray( chr(10) );
            }
            catch ( any e ){
                data = [
                    "The following error occured while fetching your weather information",
                    e.message
                ]
            }
            data.append( 'Last updated #dateTimeFormat( now(), 'mm/dd/yyyy hh:nn:ss tt' )#' );

            setLines( data );

            // Update once per minute
            sleep( 60 * 1000 )
        }

    }

    function getLocation() {
        if( variables.location.count() ) {
            return variables.location;
        }

        try{
            // get current location
            cfhttp(
                url = "https://ipinfo.io/",
                result = "location"
            ){
                cfhttpParam(
                    type="header",
                    name="Accept",
                    value="application/json"
                )
            }

            location = isJSON( location.fileContent ) ?
                        deserializeJSON( location.fileContent ) :
                        { city:"Houston", region:"Texas" }

        }
        catch ( any e ){}

        return variables.location;
    }

}