/**
 * I collect a line of text from the user.  Press enter to submit.
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='inputValue' type='string' default='';
    property name='inputLabel' type='string';
    property name='inputName' type='string';
    property name='hotKey' type='string';
    property name='onSubmit';
    property name='type';
    property name='depressed' type='boolean' default='false';

    function init( string inputLabel=' Submit ',string inputName='button', hotKey='', onSubmit, type="" ) {
        setInputLabel( inputLabel );
        setType( type );
        setInputName( inputName );
        setHotKey( hotKey );
        if( !isNUll( arguments.onSubmit ) ) {
            setOnSubmit( onSubmit );
        }

        registerListener( 'onKey', (data)=>doKey( data.key ) );

        return this;
    }

    struct function render( required numeric height, required numeric width ) {
        clearBuffer()
        .drawBox( height=height, width=width, border=false, shadow=false )
        .drawButton(
            label : inputLabel,
            selected : isFocused(),
            hotKey : hotKey,
            depressed : depressed
         )
        .commitBuffer();

        return super.render( height, width );
    }

    function onPress() {
        depressed=true;
        sleep(300)
        depressed=false;
        sleep(200)
        if( !isNUll( variables.onSubmit ) ) {
            variables.onSubmit( this );
        }
        if( getType() == 'submit' ) {
            var ancestorForm = findAncestor( 'Form' );
            if( !isNull( ancestorForm ) ) {
                ancestorForm.submit()
            }
        }
    }

    function doKey( key ) {
        // TODO: Find way for button to know if it's in a form and submit the form automatically
        var keyCode = asc( key );
        // Listen for hotkeys even when not focused
        if( len( hotKey )
            && ( keyCode == asc( lCase( hotKey ) )
              || keyCode == asc( uCase( hotKey ) ) )
        ) {
            onPress();
        }

        if( !isFocused() ) {
            return;
        }

        // Must be focused to listen to Enter
        if(    keyCode == 13
            || keyCode == 10
            || ( len( hotKey ) && ( keyCode == asc( lCase( hotKey ) ) || keyCode == asc( uCase( hotKey ) ) ) )
        ) {
            onPress()
        }

    }

}