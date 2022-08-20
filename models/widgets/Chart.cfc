/**
 * I am a single-series area chart.  My X/Y resolution will be the number of cols and rows available.
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='seriesData' type="array"
    property name='title' type="string" default="";
    property name='color' type="string" default="blue";
    processingdirective pageEncoding='UTF-8';

    variables.seriesData = [];
    variables.char = '█';
    variables.lastWidth=100;

    function init( string title='', color='blue' ) {
        setTitle( title );
        setColor( color );
        return this;
    }

    function process() {
        while( isActive() ){
            var previousValue = seriesData.len() ? seriesData.last() : 50;
            if( previousvalue < 0 ) previousValue+=10
            if( previousvalue > 100 ) previousValue-=10
            seriesData.append( previousValue + randRange(-5,5) )

            if( seriesData.len() > lastWidth ) {
                seriesData = seriesData.slice( seriesData.len()-lastWidth+1, lastWidth )

            }
            sleep(50)
        }
    }

    struct function render( required numeric height, required numeric width ) {
            lastWidth=width;
            var theData = duplicate( seriesData );
            var theLines = [];
            var graphHeight = getTitle().len() ? height-1 : height;

            if( getTitle().len() ) {
                var headerStartCol = int((width-len(getTitle()))/2);
                var headerEndWidth = width-headerStartCol - getTitle().len();

                theLines.append( repeatString( ' ', headerStartCol ) & getTitle() & repeatString( ' ', headerEndWidth ) )
            }
            loop from=1 to=graphHeight index='local.i' {
                theLines.append( '' )
            }

            var row=0;
            theData.each( (p)=>{
                row++;
                loop from=1 to=graphHeight index='local.i' {
                    if( p/100 < i/graphHeight ) {
                        theLines[ i ] &= print.t( char, color );
                    } else {
                        theLines[ i ] &= ' ';
                    }
                }
            } )

            setLines( theLines );

            return super.render( argumentCollection=arguments );
    }



}