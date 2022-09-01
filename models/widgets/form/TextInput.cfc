/**
 * I collect a line of text from the user.  Press enter to submit.
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='value' type='string' default='';
    property name='cursorRow' type='numeric' default='1';
    property name='maxLength' type='numeric';

    function init( string label='Input Here: ', maxLength=50 ) {
        setLabel( label );
        setMaxLength( maxLength );
        registerListener( 'onKey', (data)=>doKey( data.key ) );
        setCursorPosition( 1, len( label )+cursorRow )
        return this;
    }

    struct function render( required numeric height, required numeric width ) {
        // TODO: allow text to sroll inside of control
        maxLength = min( maxLength, width );
        setBuffer( [
            getLabel() & print.boldBlackOnSilverBackground( value & repeatString( ' ', (min(maxLength,width)-len(getLabel() & value) ) ) )
        ] );
        setCursorPosition( 1, len( label )+cursorRow )

        return super.render( height, width );
    }

    function doKey( key ) {

        if( key.startsWith( 'key' ) ) {
            switch( key ) {
                case 'key_left':
                    if( cursorRow > 1 ) cursorRow--;
                    break;
                case 'key_right':
                if( cursorRow <= len( value ) ) cursorRow++;
                    break;
                case 'key_home':
                    cursorRow=1;
                    break;
                case 'key_end':
                    cursorRow=len( value )+1;
                    break;
                case 'key_dc':
                    if( cursorRow<=len(value) ) {
                        value = value.mid( 1,cursorRow-1 ) & value.mid(cursorRow+1, len(value))
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
                    if(cursorRow==len(value)+1) {
                        if( cursorRow > 2 ) {
                            value = value.left(-1);
                            cursorRow--;
                        } else if( cursorRow==2 ) {
                            value='';
                            cursorRow--;
                        }
                    } else {
                        if( cursorRow > 1 ){
                            value = value.mid( 1,cursorRow-2 ) & value.mid(cursorRow, len(value))
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
                    if( value.len() >= maxLength ) break;

                    if(cursorRow==len(value)+1) {
                        value &= key;
                    } else {
                        value = value.mid( 1,cursorRow-1 ) & key & value.mid(cursorRow, len(value))
                    }
                    cursorRow++;
            }
        }

        setCursorPosition( 1, len( label )+cursorRow )
    }

}