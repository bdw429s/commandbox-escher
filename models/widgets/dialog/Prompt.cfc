/**
 * I collect a line of text from the user.  Press enter to submit.
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='prompt' type='string' default='';
    property name='cursorRow' type='numeric' default='1';
    property name='onSubmit';
    property name='mask' type='string';

    function init( string prompt='Input Here: ', onSubmit, mask='' ) {
        setPrompt( prompt );
        setMask( mask );
        if( children.len() ) {
            children.first().widget.setMask( mask );
        }
        if( !isNull( onSubmit ) ) {
            setOnSubmit( onSubmit );
        }

        registerListener( 'onKey', (data)=>{
            if( asc( data.key ) == 13 || asc( data.key ) == 10 ) {
                if( !isNull( getOnSubmit() ) ) {
                    getOnSubmit()( children[1].widget.getInputValue() );
                }
                stop();
            }
        } );

        if( children.len() ) {
            children[1].widget.setLabel( prompt );
        }

        return this;
    }

    function onDIComplete() {
        setChildren( [ { widget : getInstance( 'TextInput@escher' ).init( inputLabel=prompt, maxLength=75, mask=mask) } ] );
    }

    struct function render( required numeric height, required numeric width ) {

        clearBuffer()
        .drawBox( 4, 75 )
        .drawOverlay(
            children[1].widget.render( 1, 70 ),
            2,
            3
        )
        .commitBuffer();

        return super.render( height, width );
    }

}