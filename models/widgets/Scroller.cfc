component extends='escher.models.AbstractWidget' {
    variables.data  = [];

    struct function render( required numeric height, required numeric width ) {
        data.append( messages[ randRange(1,12) ] );
        setLines( data );

        return super.render( argumentCollection=arguments );
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