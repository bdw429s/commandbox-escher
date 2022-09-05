/**
 * I am a single-series area chart.  My X/Y resolution will be the number of cols and rows available.
 */
component extends='escher.models.widgets.data.Chart' accessors=true {

    function init( string title='', color='blue', YMax=100 ) {
        super.init( argumentCollection=arguments );
        setProduceIntervalMS( 1000 );
        setDataProducer( ()=>{
            var previousValue = seriesData.len() ? seriesData.last() : 50;
            if( previousvalue < 0 ) previousValue+=10
            if( val( YMax ) && previousvalue > YMax ) previousValue-=10
           return max( previousValue + randRange(-5,5), 0 );
        } );
        return this;
    }

}