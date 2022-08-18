/**
 * I scroll text data in a window
 * I am just a proof of concept, perhaps make me extendable and have subclasses that provide my data.
 * Or perhaps we don't even need a sub clas, but rather pass a closure to produce the data so I can be more resuable
 */
component extends='escher.models.AbstractWidget' {
    variables.data  = [];

    function process() {
        while( isActive() ) {

            // This data can come from anywhere-- and should probabkly be fed in a separate thread
            // so, if it's expensive to get, it doesn't slow down rendering.
            // Also, this array is never cleaned so it will grow forever, lol
            data.append( print.text( messages[ randRange(1,12) ], 'color#randRange(1,255)#' ) );

            setLines( data );

            sleep( 500 )
        }
    }

    messages = [
        'shining shoes...',
        'counting down to blast off...',
        'Checking registry...',
        'BLAM!',
        'This is a test of the emergency broadcast system',
        'I like spam',
        'Until we meet again...',
        'By the powers invested in me...',
        'Tightening screws...',
        'Hammering nails',
        'I like this new UI stuff...',
        'Animation nation is here...'
    ];

}