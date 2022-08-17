component implements='escher.models.IDrawable' accessors=true {
    property name="cursorPosition" type="struct";
    property name="lines" type="array";
	processingdirective pageEncoding='UTF-8';

	variables.attr = createObject( 'java', 'org.jline.utils.AttributedString' );
    variables.box = {
        h : '═',
		v : '║',
		ul : '╔',
		ur : '╗',
		bl : '╚',
		br : '╝',
		hl : '╠',
		hr : '╣',
		vt : '╦',
		vb : '╩',
		sh : '░'
    };
    setCursorPosition( 1, 1 );

    /**
     * @Returns true/false if widget is active
     */
    boolean function isActive() {
        return true;
    }

    /**
     * Renders contents of UI widget
     *
     * @height max height of renderable space
     * @width max width of renderable space
     *
     * @Returns struct with following keys:
     * - lines - contains array of strings representing output
     * - cursorPosition - contains struct with row/col keys representing row/col of cursor starting from upper left
     */
    struct function render( required numeric height, required numeric width ) {

        var data = {
            lines : variables.lines,
            cursorPosition : variables.cursorPosition
        };

        data.lines = data.lines.map( (l) => {
            var al = attr.init( toString( l ) );
            if( al.length() > width ) {
                al = al.subSequence( 0, width )
            }
            return al;
         } );

        // Trim to terminal height so the screen doesn't go all jumpy
        // If there is more output than screen, the user just doesn't get to see the rest
        if( lines.len() > height ) {
            data.lines = data.lines.slice( lines.len()-height, lines.len()-(lines.len()-height) );
        }

        return data;
    }

    function setCursorPosition( required numeric row, required numeric col ) {
        if( row < 1 ) throw( 'Cursor row must be greater than 0' );
        if( col < 1 ) throw( 'Cursor col must be greater than 0' );

        variables.cursorPosition = {
            'row' : row,
            'col' : col
        };
    }

}