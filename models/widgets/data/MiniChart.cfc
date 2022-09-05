/**
 * I am a single-series area chart.  My X/Y resolution will be the number of cols and rows available.
 */
component extends='escher.models.widgets.data.AbstractChart' accessors=true {
    processingdirective pageEncoding='UTF-8';

    variables.chars = {
        '00' : 10240, //
        '01' : 10368, //
        '02' : 10400, //
        '03' : 10416, //
        '04' : 10424, // ⢸
        '10' : 10304, //
        '11' : 10432, //
        '12' : 10464, //
        '13' : 10480, //
        '14' : 10488, // ⣸
        '20' : 10308, //
        '21' : 10436, //
        '22' : 10468, //
        '23' : 10484, //
        '24' : 10492, //
        '30' : 10310, //
        '31' : 10438, //
        '32' : 10470, //
        '33' : 10486, // ⣶
        '34' : 10494, // ⣾
        '40' : 10311, //
        '41' : 10439, //
        '42' : 10471, //
        '43' : 10487, // ⣷
        '44' : 10495, // ⣿
    };

    struct function render( required numeric height, required numeric width ) {
            lastWidth=width;
            var theData = duplicate( seriesData );
            var theLines = [];
            var nextCharCode = '';
            var totalLine = '';

            loop from="1" to=theData.len() index="local.i" {
                var thisValue = theData[i];
                if( len( nextCharCode ) == 2 ) {
                    totalLine &= chr( chars[ nextCharCode ] );
                    if( len( totalLine ) >= width ) {
                        break;
                    }
                    nextCharCode = '';
                }
                nextCharCode &= int( (thisValue/YMax)*4 );
            }
            if( len( nextCharCode ) == 1 ) {
                totalLine &= chr( chars[ nextCharCode & '0' ] );
            } else {
                totalLine &= chr( chars[ nextCharCode ] );
            }
            setBuffer( [ print.t( totalLine, color ) ] );
            return super.render( argumentCollection=arguments );
    }



}