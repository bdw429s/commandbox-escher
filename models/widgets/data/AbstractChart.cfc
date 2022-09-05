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
        return super.render( argumentCollection=arguments );
    }



}