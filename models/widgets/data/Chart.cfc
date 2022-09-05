/**
 * I am a single-series area chart.  My X/Y resolution will be the number of cols and rows available.
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='seriesData' type="array"
    property name='title' type="string" default="";
    property name='color' type="string" default="blue";
    property name='YMax' type="any" default="auto";
    property name='dataProducer' type="function";
    property name='produceIntervalMS' type="numeric";

    processingdirective pageEncoding='UTF-8';

    variables.seriesData = [];
    variables.char = '█';
    variables.lastWidth=100;

    function init( string title='', color='blue', YMax=100, function dataProducer, numeric produceIntervalMS=1000 ) {
        setTitle( title );
        setColor( color );
        setYMax( YMax );
        setProduceIntervalMS( produceIntervalMS );
        if( !isNull( dataProducer ) ) {
            setDataProducer( dataProducer );
        }
        return this;
    }

    function addDataPoint( required numeric data ) {
        seriesData.append( data );
        resize();
        return this;
    }

    function addDataPoints( required array data ) {
        seriesData.append( data, true );
        resize();
        return this;
    }

    function resize() {
        // Trim data to the width of the last known render
        if( seriesData.len() > lastWidth ) {
            seriesData = seriesData.slice( seriesData.len()-lastWidth+1, lastWidth )
        }
        return this;
    }

    function reset() {
        seriesData = [];
        return this;
    }

    function process() {
        if( !isNull( dataProducer ) ) {
            while( isActive() ){
                var data = dataProducer( this );
                if( isArray( data ) ) {
                    addDataPoints( data );
                } else {
                    addDataPoint( data )
                }
                sleep( getProduceIntervalMS() )
            }
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
            YMaxWidth = toString( thisYMax ).len();
            var row=0;
            theData.each( (p)=>{
                // Remove this if/when we allow negative graph values
                p=max(p,0);
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

            setBuffer( theLines.reverse() );

            return super.render( argumentCollection=arguments );
    }



}