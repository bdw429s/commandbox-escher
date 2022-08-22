/**
 * I am a single-series area chart.  My X/Y resolution will be the number of cols and rows available.
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='seriesData' type="array"
    property name='title' type="string" default="";
    property name='color' type="string" default="blue";
    property name='YMax' type="any" default="auto";
    processingdirective pageEncoding='UTF-8';

    variables.seriesData = [];
    variables.char = '█';
    variables.lastWidth=100;

    function init( string title='', color='blue', YMax=100 ) {
        setTitle( title );
        setColor( color );
        setYMax( YMax );
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
            sleep(200)
        }
    }

    struct function render( required numeric height, required numeric width ) {
            lastWidth=width;
            var theData = duplicate( seriesData );
            var theLines = [];
            var graphHeight = getTitle().len() ? height-1 : height;

            loop from=1 to=graphHeight index='local.i' {
                theLines.append( '' )
            }
            var thisYMax = YMax;
            if( YMax == 'auto' ) {
                thisYMax = seriesData.max();
            }
            YMaxWidth = toString( YMax ).len();
            var row=0;
            theData.each( (p)=>{
                row++;
                loop from=1 to=graphHeight index='local.i' {
                    if( row == 1 ) {
                        if( i == 1 ) {
                            theLines[ i ] &= '1';
                        } else if( i == graphHeight ) {
                            theLines[ i ] &= thisYMax;
                        } else if( i == int( graphHeight/2 ) ) {
                            theLines[ i ] &= int(thisYMax/2);
                        } else {
                            theLines[ i ] &= ' ';
                        }
                    } else if( row <= YMaxWidth ) {
                        if( i == graphHeight && row <= YMaxWidth ) {
                            theLines[ i ] &= '';
                        } else if( i == int( graphHeight/2 ) && row <= len( int(thisYMax/2) ) ) {
                            theLines[ i ] &= '';
                        } else {
                            theLines[ i ] &= ' ';
                        }
                    } else {
                        if( (p/thisYMax) > i/graphHeight ) {
                            theLines[ i ] &= print.t( char, color );
                        } else {
                            theLines[ i ] &= ' ';
                        }
                    }
                }
            } )

            if( getTitle().len() ) {
                var headerStartCol = int((width-len(getTitle()))/2);
                var headerEndWidth = width-headerStartCol - getTitle().len();

                theLines.append( repeatString( ' ', headerStartCol ) & getTitle() & repeatString( ' ', headerEndWidth ) )
            }

            setLines( theLines.reverse() );

            return super.render( argumentCollection=arguments );
    }



}