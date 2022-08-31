/**
 * I am an abstract widget class to house useful methods and variables for all widgets to use
  */
component implements='escher.models.IDrawable' accessors=true {
    // DI
	property name="print" inject="print";
	property name='wirebox' inject='wirebox';
    property name='shell' inject='shell';

    // Store row/col struct for current cursor position.  Not needed if this widget doesn't ever need the cursor drawn
    // If null, it means the widget does not require the cursor to be anywhere on screen and it will not be sent back from render()
    property name="cursorPosition" type="struct";
    // Array of "lines" of text representing the output of this widget
    property name="buffer" type="array";
    property name="backBuffer" type="array";
    property name="active" type="boolean" default=false;
	property name='taskScheduler';
	property name='future';
	property name='UUID' default="#createUUID()#";
    property name='label' type='string' default='';

	processingdirective pageEncoding='UTF-8';

    variables.buffer = [];
    variables.backBuffer = [];
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
		llb : '╡', // label left boundary
		lrb : '╞', // label right boundary
		shs : '█', // Shadow side
        shb : '▀', // Shadow bottom
        shls : '▄' // Shadow lower side
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
     * @Returns Gets widget back buffer
     */
    array function getBuffer() {
        return variables.backBuffer;
    }

    /**
     * @Returns Gets widget committed buffer in a thread safe manner
     * The array of lines will be duplicated so any changes myst
     * be set back via setBuffer()
     */
    array function getCommittedBuffer() {
        lock name='widget-buffer-#UUID#' type='readOnly' {
           return duplicate(  variables.buffer );
        }
    }

    /**
     * @Returns Commits widget back buffer into the front buffer in a thread safe manner
     */
    function commitBuffer() {
        lock name='widget-buffer-#UUID#' type='exclusive' {
           variables.buffer = variables.backBuffer;
        }
        return this;
    }

    /**
     * @Returns Clears widget back buffer
     */
    function clearBuffer() {
        variables.backBuffer=[];
        return this;
    }

    /**
     * Renders contents of UI widget
     *
     * @height max height of renderable space
     * @width max width of renderable space
     *
     * @Returns struct with following keys:
     * - buffer - contains array of strings representing output
     * - cursorPosition - contains struct with row/col keys representing row/col of cursor starting from upper left
     */
    struct function render( required numeric height, required numeric width ) {

        var data = {
            buffer : getCommittedBuffer()
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
        data.buffer = data.buffer.map( (l) => {
            // toString() is important as AttributedString's constructor doesn't like "simple values" like dates
            if( attr.stripAnsi( toString( l ) ).length() > width ) {
                return attr.fromAnsi( toString( l ) ).subSequence( 0, width ).toString();

            }
            return l;
         } );

        // Trim to terminal height so the screen doesn't go all jumpy
        // If there is more output than screen, the user just doesn't get to see the rest
        if( data.buffer.len() > height ) {
            data.buffer = data.buffer.slice( data.buffer.len()-height, data.buffer.len()-(data.buffer.len()-height) );
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
                            setBuffer( [
                                'widget error: #e.message# #e.detail#',
                                (e.tagContext.len() ? '#e.tagContext[1].template#:#e.tagContext[1].line#' : '' )
                            ] )
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
     * If this method is empty, the thread will simply exit immediately, leaving the widget active.  In this case, you would need to
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

    function drawBox(
        required height,
        required width,
        border=true,
        borderColor='',
        backgroundColor='',
        shadow=true,
        label='',
        labelPosition='center'
    ){
        var box = duplicate = variables.box;
        if( !border ) {
            box.append(
                {
                    h : ' ',
                    v : ' ',
                    ul : ' ',
                    ur : ' ',
                    bl : ' ',
                    br : ' ',
                    hl : ' ',
                    hr : ' ',
                    vt : ' ',
                    vb : ' ',
                    llb : ' ',
                    lrb : ' '
                }
            )
        }

        var color='#borderColor#on#backgroundColor#';

        if( !shadow ) {
            width++;
        }

        if( width <= 7 ) {
            label = '';
        }
        if( len( label ) ) {
            var aLabel = attr.fromAnsi( label );
            var labelLen = aLabel.length()+4;

            if( labelLen > width-3 ) {
                aLabel = aLabel.subSequence( 0, (width-3-4) );
                label = aLabel.toString();
                labelLen = aLabel.length()+4;
            }

            if( labelPosition == 'left' ) {
                var headerStartCol = 0;
                var headerEndWidth = width-2-headerStartCol - labelLen;
            } else if( labelPosition == 'right' ) {
                var headerStartCol = width-3-labelLen;
                var headerEndWidth = 0;
            } else {
                var headerStartCol = int((width-3-labelLen)/2);
                var headerEndWidth = width-3-headerStartCol - labelLen;
            }

            backBuffer.append( print.t( box.ul & repeatString( box.h, headerStartCol ) & box.llb, color ) & print.t( ' ' & label, 'on#backgroundColor#' ) & print.t( ' ', 'on#backgroundColor#' ) & print.t( box.lrb & repeatString( box.h, headerEndWidth ) & box.ur, color ) );
        } else {
            backBuffer.append( print.t( box.ul & repeatString( box.h, width-3 ) & box.ur, color ) );
        }
        loop times=( shadow ? height-3 : height-2 ) {
            backBuffer.append( print.t( box.v & repeatString( ' ', width-3 ) & box.v, color ) & ( shadow ? print.grey( box.shs ) : '' ) );
        }
        backBuffer.append( print.t( box.bl & repeatString( box.h, width-3 ) & box.br, color ) & ( shadow ? print.grey( box.shs ) : '' ) );
        if( shadow ) {
            backBuffer.append( ' ' & print.grey( repeatString( box.shb, width-1 ) ) );
        }

        return this;


    }

    function drawButton(
        textColor='white',
        backgroundColor='blue',
        shadow,
        label='',
        hotKey='',
        selected=false,
        numeric row,
        numeric col
    ){
        var color='#( selected ? 'reversed': '' )##textColor#on#backgroundColor#';
        arguments.shadow = arguments.shadow ?: arguments.selected;
        var lines = [];

        if( len( Hotkey ) && find( hotKey, label ) ) {
            var findPos = find( hotKey, label );
            var label1=mid( label, 1, findPos-1 );
            var label2=mid( label, findPos, 1 );
            var label3=mid( label, findPos+1, len( label ) );
        } else {
            var label1=label;
            var label2='';
            var label3='';
        }

        lines.append( print.t( ' #label1#', color ) & print.underscored( label2, color ) & print.t( '#label3# ', color ) & ( shadow ? print.grey( box.shls ) : '' ) );
        if( shadow ) {
            lines.append( ' ' & print.grey( repeatString( box.shb, len( label )+2 ) ) );
        }
        return drawOverlay(
            lines,
            row,
            col
        );

    }

    function drawOverlay(
        array overlayLines,
        numeric row,
        numeric col
    ) {

        if( row < 1 ) {
            row = 1;
        }
        if( col < 1 ) {
            col = 1;
        }
        // TODO: Allow overlayLines to be array, strut, or iDrawable

        var outerLines = getBuffer();
        if( isNull( arguments.row ) ) {
            var midLine = int( outerLines.len()/2 );
            var startLine = midLine - int( overLayLines.len()/2 );
        } else {
            var startLine = arguments.row;
        }

        if( isNull( arguments.col ) ) {
            var thisLine = attr.fromAnsi( outerLines[startLine] );
            var thisLineWidth = thisLine.length();
            var overlayLine = attr.fromAnsi( overlayLines[1] );
            var overlayLineWidth = overlayLine.length();
            var overlayLineStart = int( thisLineWidth/2 )-int( overlayLineWidth/2 );
        } else {
            var overlayLineStart = arguments.col;
        }


        //setCursorPosition( overLayRender.cursorPosition.row+startLine, overLayRender.cursorPosition.col+overlayLineStart-1 )
        var lineNo=0;
        for( var overlayLine in overlayLines ) {
            lineNo++;
            outerLineNo=startLine+lineNo-1;
            while( outerLines.len() < outerLineNo ) {
                outerLines.append( '' );
            }
            var thisLine = attr.fromAnsi( outerLines[outerLineNo] );
            var thisLineWidth = thisLine.length();
            overlayLine = attr.fromAnsi( overlayLine );
            var overlayLineWidth = overlayLine.length();
            // If the overlay starts inside the current line, take the substring prior
            if( overlayLineStart <= thisLineWidth ) {
                outerLines[outerLineNo] = thisLine.subSequence( 0, overlayLineStart-1 ).toAnsi();
            // Otherise, take the full line and pad spaces
            } else {
                outerLines[outerLineNo] = thisLine.toAnsi() & repeatString( ' ', overlayLineStart - thisLineWidth - 1 );
            }
            // Add in the overlay
            outerLines[outerLineNo] &= overlayLine.toAnsi();
            // If the overlay ednds inside the current line, take the substring after

            if( overlayLineStart+overlayLineWidth <= thisLineWidth ) {
                outerLines[outerLineNo] &= thisLine.subSequence( overlayLineStart+overlayLineWidth-1, thisLineWidth ).toAnsi();
            }

        }
        return this;
    }

    /**
     * Helps display and format blocks of text
     *
     * @text A string with possible line breaks or an array of lines.  Any lines in the array with line breaks will be turned into multiple lines
     * @height Number of rows to fit text inside of.  Value of -1 disables vertical control strategy, displaying all input lines.
     * @width Number of columns to fix text inside of
     * @horizontalStrategy How to deal with lines of text wider than the supplied width (wrap,truncate,wordWrap)
     * @verticalStrategy How to deal with lines of text after the supplied height (truncateTop,truncateBottom)
     * @textAlign How to align text within the width given (left,center)
     */
    array function textControl(
        required any text,
        required numeric height=-1,
        required numeric width,
        horizontalStrategy='truncate',
        verticalStrategy='truncateBottom',
        textAlign='left'
    ) {
        if( isSimpleValue( text ) ) {
            text = [ text ];
        }
        var alignText = ( as ) => {
            if( textAlign == 'center' && as.length() < width ) {
                var padding = attr.init( repeatString( ' ', int( (width-as.length())/2 ) ) );
                return attr.join( attr.fromAnsi(''), [ padding, as, padding ] );
            } else {
                return as;
            }
        };
        // Helper function for wrapping a single line of text
        var appendLine = ( result, thisLine ) => {
            // As long as our string is too long, keep cutting it down
            while( thisLine.length() > width ) {
                // If we are truncating, it's a one-and-done.  (appended below)
                if( horizontalStrategy == 'truncate' ) {
                    thisLine = thisLine.subSequence( 0, width );
                // Basic wrap just cuts at the exact width
                } else if( horizontalStrategy == 'wrap' ) {
                    result.append(  alignText( thisLine.subSequence( 0, width ) ).toAnsi() );
                    thisLine = thisLine.subSequence( width, thisLine.length() );
                // Word wrap looks for a word boundary to cut at
                } else if( horizontalStrategy == 'wordWrap' ) {
                    var end = width;
                    // Back up until we find a space or the start of the string
                    while( end > width/2 && thisLine.subSequence( end, end+1 ).toAnsi() != ' ' ) {
                        end--;
                    }
                    // We couldn't find a word boundary.
                    if( end <= width/2 ) {
                        end = width;
                    }
                    result.append(  alignText( thisLine.subSequence( 0, end ) ).toAnsi() );
                    thisLine = thisLine.subSequence( end+1, thisLine.length() );
                } else {
                    throw( 'Invalid horizontalStrategy [#horizontalStrategy#].  Valid options are truncate, wrap, or wordWrap' )
                }
            }
            // This isa ny left over
            result.append(  alignText( thisLine ).toAnsi() );
        };

        text = text
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
                    var thisLine = as.subSequence( currPos-1, breakPosition-1 );
                    currPos=breakPosition+1;
                    appendLine( result, thisLine );
                }

                appendLine( result, as.subSequence( currPos-1, ps.length() ) );
                return result;
            }, [] )

        // Deal with more lines than we have height for
        if( height > 0 && text.len() > height ) {
            if( verticalStrategy == 'truncateTop' ) {
                text = text.slice( text.len()-height, text.len()-(text.len()-height)+1 );
            } else if( verticalStrategy == 'truncateBottom' ) {
                text = text.slice( 1, height );
            } else {
                throw( 'Invalid verticalStrategy [#verticalStrategy#].  Valid options are truncateTop or truncateBottom' )
            }
        }

        return text;
    }
}