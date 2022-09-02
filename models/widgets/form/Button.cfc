/**
 * I collect a line of text from the user.  Press enter to submit.
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='inputValue' type='string' default='';
    property name='inputLabel' type='string';
    property name='inputName' type='string';
    property name='hotKey' type='string';
    property name='onSubmit';

    function init( string inputLabel=' Submit ',string inputName='button', hotKey='', onSubmit ) {
        setInputLabel( inputLabel );
        setInputName( inputName );
        setHotKey( hotKey );
        if( !isNUll( arguments.onSubmit ) ) {
            setnSubmit( onSubmit );
        }

        registerListener( 'onKey', (data)=>doKey( data.key ), ()=>isFocused() );

        return this;
    }

    struct function render( required numeric height, required numeric width ) {
        clearBuffer()
        .drawBox( height=height, width=width, border=false, shadow=false )
        .drawButton(
            label : inputLabel,
            selected : isFocused(),
            hotKey : hotKey
         )
        .commitBuffer();

        return super.render( height, width );
    }

    function doKey( key ) {
        var keyCode = asc( key );
        if(    keyCode == 13
            || keyCode == 10
            || ( len( hotKey ) && keyCode == asc( hotKey ) )
        ) {
            if( !isNUll( variables.onSubmit ) ) {
                variables.onSubmit( this );
            }
            // TODO: Find way for button to know if it's in a form and submit the form automatically
        }

    }

}