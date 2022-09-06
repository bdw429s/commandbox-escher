/**
 * I scroll text data in a window
 * I am just a proof of concept, perhaps make me extendable and have subclasses that provide my data.
 * Or perhaps we don't even need a sub clas, but rather pass a closure to produce the data so I can be more resuable
 */
component extends='escher.models.AbstractWidget'  accessors=true {
    property name='title' type="string" default="";
    property name='dataProducer' type="function";
    property name='produceIntervalMS' type="numeric";
    property name='width' type="numeric";
    property name='height' type="numeric";


    variables.data  = [];

    function init( string title='', function dataProducer, numeric produceIntervalMS=1000 ) {
        setTitle( title );
        setProduceIntervalMS( produceIntervalMS );
        if( !isNull( dataProducer ) ) {
            setDataProducer( dataProducer );
        }
        return this;
    }

    function process() {
        if( !isNull( dataProducer ) ) {
            while( isActive() ){
                var data = dataProducer( this );
                //var maxHeight = data.len();
                // if(height > 0 && (height/2) < maxHeight ){
                //     maxHeight = fix(height/2)-1;
                // }
                //data = data.slice(0,maxHeight);
                setBuffer(listToArray(print.table(data=data,width=getWidth()),"#chr(10)#"));
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