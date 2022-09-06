/**
 * I scroll text data in a window
 * I am just a proof of concept, perhaps make me extendable and have subclasses that provide my data.
 * Or perhaps we don't even need a sub clas, but rather pass a closure to produce the data so I can be more resuable
 */
component extends='escher.models.AbstractWidget'  accessors=true {
    processingdirective pageEncoding='UTF-8';

    property name='title' type="string" default="";
    property name='dataProducer' type="function";
    property name='produceIntervalMS' type="numeric";
    property name='percent' type="numeric" default="0";
    property name='color' type="string";

    variables.position = 0;
    variables.char = '█';
    variables.data  = [];

    function init( string title='', function dataProducer, numeric produceIntervalMS=1000, color='blue' ) {
        setLabel( title );
        setColor( color );
        setProduceIntervalMS( produceIntervalMS );
        if( !isNull( dataProducer ) ) {
            setDataProducer( dataProducer );
        }
        return this;
    }

    function process() {
        if( !isNull( dataProducer ) ) {
            while( isActive() ){
                percent = dataProducer( this );
                sleep( getProduceIntervalMS() )
            }
        }
    }

    struct function render( required numeric height, required numeric width ) {

        var lines = [];
        var charactersOfBox = fix((percent/100)*width);

        for(var h = 1; h <= height; h++){
            var str = RepeatString(variables.char,charactersOfBox);
            lines.append( print.t(str,color) );
        }

        setBuffer(lines);

        return super.render( argumentCollection=arguments );
    }




}