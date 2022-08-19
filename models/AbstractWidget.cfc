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
    property name='label' type='string' default='';

	processingdirective pageEncoding='UTF-8';

    variables.lines = [];
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
            lines : duplicate( variables.lines )
                // Replace tabs with spaces
                .map( (l)=>replace( l, chr(9), '    ', 'all' )
                    // Replace CRLF and LF with just CR
                    .replace( chr(13) & chr(10), chr(10), 'all' )
                    .replace( chr(13), chr(10), 'all' ) )
                .reduce( function( result, i ) {
                    // Break our ANSI string up on line breaks
                    var as = attr.fromAnsi( toString( i ) );
                    var ps = attr.stripAnsi( toString( i ) );
                    var currPos = 1;
                    while( var breakPosition = ps.reFind( '\n', currPos ) ) {
                            result.append( as.subSequence( currPos-1, breakPosition-1 ).toAnsi() );
                        currPos=breakPosition+1;
                    }
                    result.append( as.subSequence( currPos-1, ps.length() ).toAnsi() );
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

    /**
     * Start the widget.  This will fire the process() method in a thread and mark the widget as active.
     * You are responsible for also starting any composed widgets here
     */
    function start() {

        // Mark widget as active
        setActive( true );

        // Fire up our process method in its own thread
        // It's free to keep running if it wants
       setFuture(
            getTaskScheduler()
                .newSchedule( ()=>{
                    setting requestTimeout=999999999;
                    try {
                        process();
                    } catch( any e ) {
                        if( !e.message contains 'interrupt' ) {
                            setLines( [ 'widget error: #e.message# #e.detail#' ] )
                        }
                    }
                } )
                .start()
        );

    }

    /**
     * Stop the widget.  This will interrupt the process() method and mark the widget as inactive.
     * You are responsible for also stopping any composed widgets here
     */
    function stop() {

        // Mark widget as inactive
        setActive( false );

        // Interrupt the process thread if it's still running
        getFuture().cancel();
        // Wait for it to finish (if interrupted, it could take a second to finish)
        try {
            getFuture().get();
        } catch(any e) {
            // Throws CancellationException
        }

    }

    /**
     * An asynchronous method that will be called in its own thread when the widget is started.  This is where you update the internal state of
     * the widget so it's ready the next time the render() method is run.  This method may keep running as long as the widget is active, but
     * it should be interruptable so a while try/sleep is recommended if you want to periodically update the widgets state.
     * If this method is empty, the thread will simply exist immediatly, leaving the widget active.  In this case, you would need to
     * update the widget state from outside.
     */
    function process() {
        // Default process does nothing
    }


    /**
     * Return label for this widget, if set
     */
    string function getLabel() {
        return variables.label;
    }
}