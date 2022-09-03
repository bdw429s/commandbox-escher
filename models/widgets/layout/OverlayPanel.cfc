/**
 * I allow rendering of a widget on top of another widget
 */
component extends='escher.models.AbstractWidget' accessors=true{
    //  Array of panes to display.  Each item contains struct with widget CFC instance, requestedWith, actualWidth, and lines
    property name="pane";
    property name="overlay";

    function init( pane, overlay ) {
        if( !isNull( arguments.pane ) ) {
            setPane( pane );
            children = [ { widget : pane } ];
            if( isActive() ) {
                pane.start();
            }
        }
        if( !isNull( arguments.overlay ) ) {
            addOverlay( overlay );
        }

        // We have a custom setFocus listener that favors the overlay, if active
        registerListener( 'setFocus', (data) => {
            setFocused( true );
            onFocus();
            // If there is an overlay, it gets focus
            if( !isNull( overlay ) && overlay.isActive() ) {
                overlay.emit( 'setFocus', data );
                // Stop default propagation
                return false;
            }
            // Otherwise, propagte down into or main pane
            pane.emit( 'setFocus', data );
            return false;
        } );

        registerListener( 'advanceFocus', (data) => {
            // If there is an overlay, it gets focus
            if( !isNull( overlay ) && overlay.isActive() ) {
                overlay.emit( 'advanceFocus', data );
                // Stop default propagation
                return false;
            }
            // Otherwise, default behavior
            pane.emit( 'advanceFocus', data );
            return false;
        } );

        registerListener( 'retractFocus', (data) => {
            // If there is an overlay, it gets focus
            if( !isNull( overlay ) && overlay.isActive() ) {
                overlay.emit( 'retractFocus', data );
                // Stop default propagation
                return false;
            }
            // Otherwise, default behavior
            pane.emit( 'retractFocus', data );
            return false;
        } );


        return this;
    }

    function addOverlay( iDrawable widget ) {
        setOverlay( widget )
        children[2] =  { widget : widget };
        if( isActive() ) {
            widget.start();
        }
        return this;
    }

    /**
     * Render overlap, if set
     *
     * @height current height constraint
     * @width current width constraint
     */
    struct function render( required numeric height, required numeric width ) {
        var pageRender = pane.render( height, width );

        if( !isNull( overlay ) && overlay.isActive() ) {
            var overLayRender = overlay.render( height, width );
            var overLayLines = overLayRender.buffer;

            var midLine = int( pageRender.buffer.len()/2 );
            var startLine = midLine - int( overLayLines.len()/2 );

            var thisLine = attr.fromAnsi( pageRender.buffer[startLine+1] );
            var thisLineWidth = thisLine.length();
            var overlayLine = attr.fromAnsi( overlayLines[1] );
            var overlayLineWidth = overlayLine.length();
            var overlayLineStart = int( thisLineWidth/2 )-int( overlayLineWidth/2 );


            if( !isNull( overLayRender.cursorPosition ) ) {
                setCursorPosition( overLayRender.cursorPosition.row+startLine, overLayRender.cursorPosition.col+overlayLineStart-1 )
            }
            var lineNo=0;
            for( var overlayLine in overlayLines ) {
                lineNo++;
                var thisLine = attr.fromAnsi( pageRender.buffer[startLine+lineNo] );
                overlayLine = attr.fromAnsi( overlayLine );
                var overlayLineWidth = overlayLine.length();
                pageRender.buffer[startLine+lineNo] =  thisLine.subSequence( 0, overlayLineStart-1 ).toAnsi() & overlayLine.toAnsi() & thisLine.subSequence( overlayLineStart+overlayLineWidth-1, thisLineWidth ).toAnsi();
            }
        } else {
            if( !pane.isFocused() ) {
                pane.emit( 'setFocus' );
            }
            if( !isNull( pageRender.cursorPosition ) ) {
                setCursorPosition( pageRender.cursorPosition.row, pageRender.cursorPosition.col )
            } else {
                setCursorPosition( -1, -1 )
            }
        }
        setBuffer( pageRender.buffer )
        return super.render( height, width );
    }

    function start() {
        pane.start();
        if( !isNull( variables.overlay ) ) {
            overlay.start()
        }
        super.start();
    }

    function stop() {
        pane.stop();
        if( !isNull( variables.overlay ) ) {
            overlay.stop()
        }
        super.stop();
    }

}