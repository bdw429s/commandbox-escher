component extends='escher.models.AbstractWidget' accessors=true {
    property name='inputText' type='string' default='';
    property name='cursorRow' type='numeric' default='1';
    property name='prompt' type='string';
    property name='onSubmit';

    function init( string prompt='Input Here: ', onSubmit ) {
        setPrompt( prompt );
        if( !isNull( onSubmit ) ) {
            setOnSubmit( onSubmit );
        }
        return this;
    }


    function process() {
        while( isActive() ){
            setCursorPosition( 2, len( prompt )+cursorRow+2 )
            var maxLen = 73-getPrompt().len();
            setLines( [
                print.blue( box.ul & repeatString( box.h, 75 ) & box.ur ),
                print.blue( box.v ) & ' ' & getPrompt() & print.boldBlackOnSilverBackground( inputText & repeatString( ' ', 73-len(getPrompt() & inputText) ) ) & ' ' & print.blue( box.v ),
                print.blue( box.bl & repeatString( box.h, 75 ) & box.br )
            ] );

            var key = shell.waitForKey();
            if( key.startsWith( 'key' ) ) {
                switch( key ) {
                    case 'key_left':
                        if( cursorRow > 1 ) cursorRow--;
                        break;
                    case 'key_right':
                    if( cursorRow <= len( inputText ) ) cursorRow++;
                        break;
                    case 'key_home':
                        cursorRow=1;
                        break;
                    case 'key_end':
                        cursorRow=len( inputText )+1;
                        break;
                    case 'key_dc':
                        if( cursorRow<=len(inputText) ) {
                            inputText = inputText.mid( 1,cursorRow-1 ) & inputText.mid(cursorRow+1, len(inputText))
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
                        if(cursorRow==len(inputText)+1) {
                            if( cursorRow > 2 ) {
                                inputText = inputText.left(-1);
                                cursorRow--;
                            } else if( cursorRow==2 ) {
                                inputText='';
                                cursorRow--;
                            }
                        } else {
                            if( cursorRow > 1 ){
                                inputText = inputText.mid( 1,cursorRow-2 ) & inputText.mid(cursorRow, len(inputText))
                                cursorRow--;
                            }
                        }
                        break;
                    // Enter
                    case 13:
                    case 10:
                        if( !isNull( getOnSubmit() ) ) {
                            getOnSubmit()( inputText );
                        }
                        stop();
                        return;
                        break;
                    // Tab
                    case 9:
                        // nothing
                        break;
                    default:
                        if( inputText.len() >= maxLen ) break;

                        if(cursorRow==len(inputText)+1) {
                            inputText &= key;
                        } else {
                            inputText = inputText.mid( 1,cursorRow-1 ) & key & inputText.mid(cursorRow, len(inputText))
                        }
                        cursorRow++;
                }
          }
        }
    }

}