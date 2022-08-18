/**
 * I am a scrolling progress bar
 * I am just a proof of concept, perhaps make me extendable and have subclasses that provide my data.
 * Or perhaps we don't even need a sub clas, but rather pass a closure to produce the data so I can be more resuable
 */
component extends='escher.models.AbstractWidget' {
    processingdirective pageEncoding='UTF-8';

    variables.position = 0;
    variables.char = '█';
    struct function render( required numeric height, required numeric width ) {
            variables.data  = [];
            variables.position = (variables.position < width) ? variables.position + 1 : 1;

            for(var h = 1; h <= height; h++){
                var str = RepeatString(variables.char,variables.position);
                var coloredString = print.blueText(str); //TODO color my string
                var al = attr.init( toString(coloredString));
                data.append( al );
            }

            setLines( data );

            return super.render( argumentCollection=arguments );
    }



}