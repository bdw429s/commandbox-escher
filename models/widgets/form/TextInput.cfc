/**
 * I collect a line of text from the user.  Press enter to submit.
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='inputValue' type='string' default='';
    property name='inputLabel' type='string';
    property name='inputName' type='string';
    property name='cursorRow' type='numeric' default='1';
    property name='maxLength' type='numeric';
    property name='mask' type='string';

    function init( string inputLabel='Input Here: ', string inputName='Input Here: ', maxLength=50, mask='' ) {
        setInputLabel( inputLabel );
        setMaxLength( maxLength );
        setMask( mask );
        registerListener( 'onKey', (data)=>doKey( data.key ), ()=>isFocused() );
        return this;
    }

    function onFocus() {
        setCursorPosition( 1, len( inputLabel )+cursorRow )
    }

    function onBlur() {
        setCursorPosition( -1, -1 )
    }

    struct function render( required numeric height, required numeric width ) {
        // TODO: allow text to sroll inside of control
        var inputValueToShow = inputValue;
        if( len( mask ) ) {
            inputValueToShow = repeatString( left( mask, 1 ), len( inputValue ) );
        }
        setBuffer( [
           getInputLabel() & print.BlackOnSilverBackground( inputValueToShow & repeatString( ' ', (width-len(getInputLabel() & inputValue) ) ) )
        ] );

        return super.render( height, width );
    }

    function doKey( key ) {

        if( key.startsWith( 'key' ) ) {
            switch( key ) {
                case 'key_left':
                    if( cursorRow > 1 ) cursorRow--;
                    break;
                case 'key_right':
                if( cursorRow <= len( inputValue ) ) cursorRow++;
                    break;
                case 'key_home':
                    cursorRow=1;
                    break;
                case 'key_end':
                    cursorRow=len( inputValue )+1;
                    break;
                case 'key_dc':
                    if( cursorRow<=len(inputValue) ) {
                        inputValue = inputValue.mid( 1,cursorRow-1 ) & inputValue.mid(cursorRow+1, len(inputValue))
                    }

                break;
            }
        } else if( key == 'escape' ) {
            // nothing
        } else if( key == 'back_tab' ) {
            // nothing
        } else {

            switch( asc( key ) ) {
                // backspace
                case 8:
                    if(cursorRow==len(inputValue)+1) {
                        if( cursorRow > 2 ) {
                            inputValue = inputValue.left(-1);
                            cursorRow--;
                        } else if( cursorRow==2 ) {
                            inputValue='';
                            cursorRow--;
                        }
                    } else {
                        if( cursorRow > 1 ){
                            inputValue = inputValue.mid( 1,cursorRow-2 ) & inputValue.mid(cursorRow, len(inputValue))
                            cursorRow--;
                        }
                    }
                    break;
                // Tab
                case 9:
                // Enter
                case 13:
                case 10:
                    // nothing
                    break;
                default:
                    if( inputValue.len() >= maxLength ) break;

                    if(cursorRow==len(inputValue)+1) {
                        inputValue &= key;
                    } else {
                        inputValue = inputValue.mid( 1,cursorRow-1 ) & key & inputValue.mid(cursorRow, len(inputValue))
                    }
                    cursorRow++;
            }
        }

        setCursorPosition( 1, len( inputLabel )+cursorRow )
    }

}