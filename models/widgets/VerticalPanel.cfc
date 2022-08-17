/**
 * I allow rendering of 1 or more nested widgets inside a vertical panel where each widget is to above or below the others.
 * I am more of a container widget and don't have any output other than my border.
 *
 * ╔════════════╗
 * ╠════════════╣
 * ╠════════════╣
 * ║            ║
 * ╚════════════╝
 *
 * TODO: make border customizable or be able to turn off completely
 */
component extends='escher.models.AbstractWidget' {
    //  Array of panes to display.  Each item contains struct with widget CFC instance, requestedHeight, actualHeight
    property name="panes" type="array";

    variables.panes=[];

    /**
    * Allow panes to be added via constructor, HOWEVER ther is no way to pass height in this case
    * VeritcalPanel.init( widget1, widget2, widget3 )
    * So they will all be auto-scaling
    */
    function init() {
        arguments.each( (k,v)=>addPane(v) );
        return this;
    }

    /**
     * Add a single pane to the panel
     *
     * @widget The widget to draw in this page
     * @width N% for percentage, N for set number of cols, -1 for auto-scaling based on parent size
     */
    function addPane( iDrawable widget, height=-1 ) {
        panes.append( {
            widget : widget,
            requestedHeight : height,
            actualHeight : 0
        } );
        return this;
    }

    /**
     * Build out bordered box with our panes inside
     *
     * @height current height constraint
     * @width current width constraint
     */
    struct function render( required numeric height, required numeric width ) {
        // I need this to pass to super.render() below.
        var originalHeight = height;
        var originalWidth = width;

        // This is the effective size MINUS the borders.
        width=width-4;
        height = height - 2 - (panes.len()-1);

        // Now we calculate actual width of all panes.
        // TODO, move this to separate function
        // The end result of this method is that the actualHeight will be populated for each pane
        // If the total actual heights is too large, the content will just get truncated

        // Start with any panes asking for a set number of rows and give them precedence
        var claimedRows = panes.reduce( (acc,p)=>{
            if( !toString(p.requestedHeight).endsWith( '%' ) && p.requestedHeight != -1 ) {
                // Actual height is just the exact width they asked for (dangerous for small screens)
                p.actualHeight=p.requestedHeight;
                return acc+p.requestedHeight;
            }
            return acc;
        }, 0 );
        var remainingRows = height-claimedRows;
        if( remainingRows > 0 ) {
            //  Now calculate panes asking for a % of what's left (mixing panes with percentages AND set heights won't work that well)
            var claimedPerc = panes.reduce( (acc,p)=>{
                if( toString(p.requestedHeight).endsWith( '%' ) ) {
                    // Actual height is percentage of remaining columns (round down)
                    p.actualHeight=int( (p.requestedHeight.left(-1)/100)*remainingRows );
                    remainingRows -= p.actualHeight;
                    return acc+p.requestedHeight.left(-1);
                }
                return acc;
            }, 0 );

            // Do a quick sanity check that we haven't claimed more than 100% of the panel!
            if( claimedPerc > 100 ) {
                throw( 'Pane height percentages total [#claimedPerc#] is greater than 100.' );
            }
            if( remainingRows > 0 ) {
                // All remaining panes with height of -1 equally spread out over remaining space
                // First, how many stretch panes are sharing the remaining rows?
                var numStrectchPanes = panes.reduce( (acc,p)=>{
                    if( p.requestedHeight == -1 ) {
                        return acc+1;
                    }
                    return acc;
                }, 0 );
                var rowsAvailbleForStretch = remainingRows;
                if( numStrectchPanes ) {
                    panes.each( (p)=>{
                        if( p.requestedHeight == -1 ) {
                            // Actual width is equal percentage of remaining rows (round down)
                            p.actualHeight = int( rowsAvailbleForStretch/numStrectchPanes );
                            remainingRows -= p.actualHeight;
                        }
                    } );
                    // Based on the rounding, we may have extra space-- arbitrarily assign the left over it to the last stretch pane
                    if( remainingRows > 0 ) {
                        panes.filter( (p)=>p.requestedHeight == -1 ).last().actualHeight++;
                    }

                }
            }

        }

        // Now that we know the final heights availble to each pane, stitch them together
        // Since this is a vertical panel, their width is our width (minus the borders which we trimmed above)

        var finalLines = [];
        // Top border line
        finalLines.append( box.ul & repeatString( box.h, width+2 ) & box.ur )
        var paneNo = 0;
        // Loop over the panes, we'll assemble them as we go
        for( var pane in panes ) {
            paneNo++;
            // Get the rendered content for the nested widget
            var paneLines = pane.widget.render( pane.actualHeight, width ).lines;
            finalLines.append(
                paneLines
                    // for each line
                    .map( (l)=>{
                        // Add our borders and buffers
                        var line =  box.v & " " & l;
                        // Fill in any empty space if the pane didn't render enough space to fill the width
                        if( len( l ) < width ) {
                            line &= repeatString( ' ', width - len( l ) )
                        }
                        return line & " " & box.v;
                    } )
            , true );
            // If our pane didn't give us enough rows, add blank filler rows
            if( paneLines.len() < pane.actualHeight ) {
                loop times=pane.actualHeight-paneLines.len() {
                    finalLines.append( box.v & repeatString( ' ', width+2 ) & box.v );
                }
            }
            // For all panes but the last, but in our horizontal beam separator
            if( paneNo < panes.len() ) {
                finalLines.append( box.hl & repeatString( box.h, width+2 ) & box.hr )
            }
        }
        // Bottom border line
        finalLines.append( box.bl & repeatString( box.h, width+2 ) & box.br )

        setLines( finalLines );
        // Let abstract class clean up data (truncate) and convert strings to AttributedStrings, as well as create final render output struct.
        return super.render( originalHeight, originalWidth );
    }

}