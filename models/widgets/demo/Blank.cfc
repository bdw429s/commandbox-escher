/**
 * I am a single-series area chart.  My X/Y resolution will be the number of cols and rows available.
 */
component extends='escher.models.AbstractWidget' accessors=true {

    struct function render( required numeric height, required numeric width ) {
        var lines=[];
        loop times=height {
            lines.append( repeatString( ' ', width ) )
        }
        setBuffer( lines );
        return super.render( height, width );
    }

}