/**
 * I display an alert for the user which can be dismissed with enter or escape
 * Types are info, warn, error, and success.
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='message' type='string';
    property name='type' type='string';

    function init( string message='', type='info' ) {
        setMessage( message );
        setType( type );
        return this;
    }

    function process() {
        while( isActive() ){
            switch( getType() ) {
                case 'warn':
                    var icon = '!';
                    var color = 'yellow';
                    break;
                case 'error':
                    var icon = '!';
                    var color = 'red';
                    break;
                case 'success':
                    var icon = '*';
                    var color = 'green';
                    break;
                case 'info':
                default:
                    var icon = '*';
                    var color = 'blue';
                    break;

            }

            var headerStartCol = int((75-len(getType()))/2);
            var headerEndWidth = 75-headerStartCol - getType().len();
            var messageStartCol = int((66-len(getMessage()))/2);
            var messageEndWidth = 66-messageStartCol - getMessage().len();
            setLines( [
                print.t( box.ul & repeatString( box.h, headerStartCol ) & ' ' & getType() & ' ' & repeatString( box.h, headerEndWidth-2 ) & box.ur, color ),
                print.t( box.v & repeatString( ' ', 75 ) & box.v, color ) & print.grey( box.shs ),
                print.t( box.v, color ) & '     #icon#   ' & repeatString( ' ', messageStartCol )  & getMessage() & repeatString( ' ', messageEndWidth-1 )  & ' ' & print.t( box.v, color ) & print.grey( box.shs ),
                print.t( box.v & repeatString( ' ', 75 ) & box.v, color ) & print.grey( box.shs ),
                print.t( box.v, color ) & repeatString( ' ', 34 ) & print.white( '  OK  ', 'on#color#' ) & repeatString( ' ', 35 ) & print.t( box.v, color ) & print.grey( box.shs ),
                print.t( box.bl & repeatString( box.h, 75 ) & box.br, color ) & print.grey( box.shs ),
                ' ' & print.grey( repeatString( box.shb, 77 ) )
            ] );

            var key = shell.waitForKey();
            if( key == 'escape' || asc( key ) == 10 || asc( key ) == 13 ) {
                stop();
                return;
            }
        }
    }

}