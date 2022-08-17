component extends='escher.models.AbstractWidget' {
    variables.data      = [];
    variables.loaded    = false;
    variables.location  = {};

    struct function render( required numeric height, required numeric width ) {

        if ( !variables.loaded ){
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

            setLines( data );
            variables.loaded = true;
        }

        return super.render( argumentCollection=arguments );
    }

}