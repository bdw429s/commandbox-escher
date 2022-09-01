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
            if( isActive() ) {
                pane.start();
            }
        }
        if( !isNull( arguments.overlay ) ) {
            addOverlay( overlay );
        }
        return this;
    }

    function addOverlay( iDrawable widget ) {
        setOverlay( widget )
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
        var theLines = pane.render( height, width ).buffer;

        if( !isNull( overlay ) && overlay.isActive() ) {
            var overLayRender = overlay.render( height, width );
            var overLayLines = overLayRender.buffer;

            var midLine = int( theLines.len()/2 );
            var startLine = midLine - int( overLayLines.len()/2 );

            var thisLine = attr.fromAnsi( theLines[startLine+1] );
            var thisLineWidth = thisLine.length();
            var overlayLine = attr.fromAnsi( overlayLines[1] );
            var overlayLineWidth = overlayLine.length();
            var overlayLineStart = int( thisLineWidth/2 )-int( overlayLineWidth/2 );


            setCursorPosition( overLayRender.cursorPosition.row+startLine, overLayRender.cursorPosition.col+overlayLineStart-1 )
            var lineNo=0;
            for( var overlayLine in overlayLines ) {
                lineNo++;
                var thisLine = attr.fromAnsi( theLines[startLine+lineNo] );
                overlayLine = attr.fromAnsi( overlayLine );
                var overlayLineWidth = overlayLine.length();
                theLines[startLine+lineNo] =  thisLine.subSequence( 0, overlayLineStart-1 ).toAnsi() & overlayLine.toAnsi() & thisLine.subSequence( overlayLineStart+overlayLineWidth-1, thisLineWidth ).toAnsi();
            }
        } else {
            setCursorPosition( 1, 1 )
        }
        setBuffer( theLines )
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