/**
 * I am an abstract widget class to house useful methods and variables for all widgets to use
  */
component implements='escher.models.IDrawable' accessors=true {
    // DI
	property name="print" inject="print";
	property name='wirebox' inject='wirebox';

    // Store row/col struct for current cursor position.  Not needed if this widget doesn't ever need the cursor drawn
    // If null, it means the widget does not require the cursor to be anywhere on screen and it will not be sent back from render()
    property name="cursorPosition" type="struct";
    // Array of "lines" of text representing the output of this widget
    property name="lines" type="array";
    property name="active" type="boolean" default=false;
	property name='taskScheduler';
	property name='future';
	property name='UUID' default="#createUUID()#";

	processingdirective pageEncoding='UTF-8';

    // Re-usable Java proxy for creating attributed strings
	variables.attr = createObject( 'java', 'org.jline.utils.AttributedString' );
    // Helper with border chars for box drawing
    variables.box = {
        h : '═', // horizoinal beam
		v : '║', // vertical beam
		ul : '╔', // upper left corner
		ur : '╗', // upper right corner
		bl : '╚', // botton left corner
		br : '╝', // botton right corner
		hl : '╠', // horizonal left junction
		hr : '╣', // horizonal right junction
		vt : '╦', // vertical top junction
		vb : '╩', // vertical bottom junction
		sh : '░' // Shadow
    };

	function onDIComplete() {
		setTaskScheduler( wirebox.getTaskScheduler() );
	}

    /**
     * @Returns true/false if widget is active
     */
    boolean function isActive() {
        return getActive();
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
            lines : variables.lines
                .reduce( function( result, i ) {
                    result.append( toString( i ).listToArray( chr( 13 ) & chr( 10 ) ), true );
                    return result;
                }, [] )
        };

        // Only set if not null
        if( !isNull( variables.cursorPosition ) ) {
            data.cursorPosition = variables.cursorPosition;
        }

        // Trim lines too long.  We could throw an error, but for now we just truncate
        data.lines = data.lines.map( (l) => {
            // toString() is important as AttributedString's constructor doesn't like "simple values" like dates
            if( attr.stripAnsi( toString( l ) ).length() > width ) {
                return attr.fromAnsi( toString( l ) ).subSequence( 0, width ).toString();

            }
            return l;
         } );

        // Trim to terminal height so the screen doesn't go all jumpy
        // If there is more output than screen, the user just doesn't get to see the rest
        if( lines.len() > height ) {
            data.lines = data.lines.slice( lines.len()-height, lines.len()-(lines.len()-height) );
        }

        return data;
    }

    /**
     * Set the cursor position relative to this widget
     *
     * @row 1-based row index
     * @col 1-based col index (Cursor appears BEFORE this index)
     */
    function setCursorPosition( required numeric row, required numeric col ) {
        if( row < 1 ) throw( 'Cursor row must be greater than 0' );
        if( col < 1 ) throw( 'Cursor col must be greater than 0' );

        // Calling setCursorPosition(-1,-1) "turns off" the cursor
        if( row == -1 || col == -1 ) {
            variables.delete( 'cursorPosition' );
            return;
        }

        variables.cursorPosition = {
            'row' : row,
            'col' : col
        };
    }

    function start() {

        setFuture(
            getTaskScheduler().newSchedule( ()=>process() )
                .start()
        );

        setActive( true );
    }

    function stop() {
        getFuture().cancel();
        try {
            getFuture().get();
        } catch(any e) {
            // Throws CancellationException
        }

        setActive( false );
    }

    function process() {

    }
}