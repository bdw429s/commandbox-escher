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
    property name='width' type="numeric" default="0";
    property name='height' type="numeric" default="0";

    variables.position = 0;
    variables.char = '█';
    variables.data  = [];

    function init( string title='', function dataProducer, numeric produceIntervalMS=1000 ) {
        setLabel( title );
        setProduceIntervalMS( produceIntervalMS );
        if( !isNull( dataProducer ) ) {
            setDataProducer( dataProducer );
        }
        return this;
    }

    function process() {
        if( !isNull( dataProducer ) ) {
            while( isActive() ){
                var percent = dataProducer( this );
                var lines = [];
                var charactersOfBox = fix((percent/100)*variables.width);

                for(var h = 1; h <= variables.height; h++){
                    var str = RepeatString(variables.char,charactersOfBox);
                    var coloredString = print.blueText(str); //TODO color my string
                    var al = attr.init( toString(coloredString));
                    lines.append( al );
                }

                setBuffer(lines);
                sleep( getProduceIntervalMS() )
            }
        }
    }

    struct function render( required numeric height, required numeric width ) {
        setWidth(width);
        setHeight(height);
        return super.render( argumentCollection=arguments );
    }


  

}