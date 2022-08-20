/**
 * I show a yes/no confirmation to the user. Options can be selected with left, right, tab, shift tab, Y, and N
 * Press enter to submit
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='message' type='string';
    property name='onSubmit';
    property name='response' type='boolean' default=true;

    function init( string message='', onSubmit ) {
        setMessage( message );
        if( !isNull( onSubmit ) ) {
            setOnSubmit( onSubmit );
        }
        return this;
    }

    function process() {
        while( isActive() ){
            var color = 'blue'
            var messageStartCol = int((75-len(getMessage()))/2);
            var messageEndWidth = 75-messageStartCol - getMessage().len();
            var yesFormat = '#response?'reversed':''#BoldWhiteOn#color#';
            var noFormat = '#!response?'reversed':''#WhiteOn#color#';
            setLines( [
                print.t( box.ul & repeatString( box.h, 75 ) & box.ur, color ),
                print.t( box.v & repeatString( ' ', 75 ) & box.v, color ) & print.grey( box.shs ),
                print.t( box.v, color ) & repeatString( ' ', messageStartCol )  & getMessage() & repeatString( ' ', messageEndWidth-1 )  & ' ' & print.t( box.v, color ) & print.grey( box.shs ),
                print.t( box.v & repeatString( ' ', 75 ) & box.v, color ) & print.grey( box.shs ),
                print.t( box.v, color ) & repeatString( ' ', 23 )
                    & print.t( '  ', yesFormat ) & print.underscored( 'Y', yesFormat ) & print.t( 'es  ', yesFormat ) & print.grey( response ? box.shls : ' ' ) & repeatString( ' ', 17 )
                    & print.t( '  ', noFormat )& print.underscored( 'N', noFormat )& print.t( 'o  ', noFormat ) & print.grey( !response ? box.shls : ' ' ) & repeatString( ' ', 20 )
                    & print.t( box.v, color ) & print.grey( box.shs ),
                print.t( box.v, color ) & repeatString( ' ', 24 ) & print.grey( repeatString( response ? box.shb : ' ' , 7 ) ) & repeatString( ' ', 5 ) & repeatString( ' ', 13 )
                    & print.grey( repeatString( !response ? box.shb : ' ' , 6 ) ) & repeatString( ' ', 20 ) & print.t( box.v, color ) & print.grey( box.shs ),
                print.t( box.v & repeatString( ' ', 75 ) & box.v, color ) & print.grey( box.shs ),
                print.t( box.Bl & repeatString( box.h, 75 ) & box.Br, color ) & print.grey( box.shs ),
                ' ' & print.grey( repeatString( box.shb, 77 ) )
            ] );

            var key = shell.waitForKey();
            if( key=='key_left' || key == 'back_tab' || key == 'y' ) {
                if( !response ) response=!response;
            } else if( key == 'key_right' || asc(key) == 9 || key == 'n' ) {
                if( response ) response=!response;
            } else if( asc( key ) == 10 || asc( key ) == 13 ) {
                if( !isNull( getOnSubmit() ) ) {
                    getOnSubmit()( response );
                }
                stop();
                return;
            }
        }
    }

}