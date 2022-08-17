/**
 * I allow rendering of 1 or more nested widgets inside a horizontal panel where each widget is to the left or right of the others.
 * I am more of a container widget and don't have any output other than my border.
 *
 * ╔══════╦═══╦═════════╗
 * ║      ║   ║         ║
 * ╚══════╩═══╩═════════╝
 *
 * TODO: make border customizable or be able to turn off completely
 */
component extends='escher.models.AbstractWidget' {
    //  Array of panes to display.  Each item contains struct with widget CFC instance, requestedWith, actualWidth, and lines
    property name="panes" type="array";

    variables.panes=[];

    /**
     * Allow panes to be added via constructor, HOWEVER ther is no way to pass width in this case
    * HorizontalPanel.init( widget1, widget2, widget3 )
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
    function addPane( iDrawable widget, width=-1 ) {
        panes.append( {
            widget : widget,
            requestedWidth : width,
            actualWidth : 0,
            lines=[]
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
        width=width-4 - ((panes.len()-1)*3);
        height = height - 2;

        // Now we calculate actual width of all panes.
        // TODO, move this to separate function
        // The end result of this method is that the actualWidth will be populated for each pane
        // If the total actual widths is too large, the content will just get truncated

        // Start with any panes asking for a set number of columns and give them precedence
        var claimedCols = panes.reduce( (acc,p)=>{
            if( !toString(p.requestedWidth).endsWith( '%' ) && p.requestedWidth != -1 ) {
                // Actual width is just the exact width they asked for (dangerous for small screens)
                p.actualWidth=p.requestedWidth;
                return acc+p.requestedWidth;
            }
            return acc;
        }, 0 );

        var remainingCols = width-claimedCols;
        if( remainingCols > 0 ) {
            //  Now calculate panes asking for a % of what's left (mixing panes with percentages AND set widths won't work that well)
            var claimedPerc = panes.reduce( (acc,p)=>{
                if( toString(p.requestedWidth).endsWith( '%' ) ) {
                    // Actual width is percentage of remaining columns (round down)
                    p.actualWidth=int( (p.requestedWidth.left(-1)/100)*remainingCols );
                    remainingCols -= p.actualWidth;
                    return acc+p.requestedWidth.left(-1);
                }
                return acc;
            }, 0 );

            // Do a quick sanity check that we haven't claimed more than 100% of the panel!
            if( claimedPerc > 100 ) {
                throw( 'Pane width percentages total [#claimedPerc#] is greater than 100.' );
            }

            if( remainingCols > 0 ) {
                // All remaining panes with width of -1 equally spread out over remaining space
                // First, how many stretch panes are sharing the remaining columns?
                var numStrectchPanes = panes.reduce( (acc,p)=>{
                    if( p.requestedWidth == -1 ) {
                        return acc+1;
                    }
                    return acc;
                }, 0 );
                var colsAvailbleForStretch = remainingCols;
                if( numStrectchPanes ) {
                    panes.each( (p)=>{
                        if( p.requestedWidth == -1 ) {
                            // Actual width is equal percentage of remaining columns (round down)
                            p.actualWidth = int( colsAvailbleForStretch/numStrectchPanes );
                            remainingCols -= p.actualWidth;
                        }
                    } );
                    // Based on the rounding, we may have extra space-- arbitrarily assign the left over it to the last stretch pane
                    if( remainingCols > 0 ) {
                        panes.filter( (p)=>p.requestedWidth == -1 ).last().actualWidth+=remainingCols;
                    }

                }
            }

        }
        // Now that we know the final widths availble to each pane, ask them each to render themselves.
        // Since this is a horizontal panel, their height is our height (minus the borders which we trimmed above)
        // Store each pane's rendered lines and we'll assemble them below one line at a time
        panes.each( (pane)=>pane.lines=pane.widget.render( height, pane.actualWidth ).lines );

        var finalLines = [];
        // Let's do a pass over the panes to calulate thetop and bottom rows
        var topRow = box.ul & box.h;
        var bottomRow = box.bl & box.h;
        loop from=1 to=panes.len() index="local.paneNo" {
            // Add border chars to represent each pane content width
            topRow &= repeatString( box.h, panes[ paneNo ].actualWidth )
            bottomRow &= repeatString( box.h, panes[ paneNo ].actualWidth )
            // At the break between panes, put our junction char in
            if( paneNo < panes.len() ) {
                topRow &= box.h & box.vt & box.h;
                bottomRow &= box.h & box.vb & box.h;
            }
        }
        // Finish off top and bottom rows.  We'll append/prepent them later
        topRow &= box.h & box.ur;
        bottomRow &= box.h & box.br;

        // For each line, we need to combine the first, second, third, and so on lines from the widgets to make each full line
        loop from=1 to=height index="local.row" {
            var thisRow = box.v & ' ';
            // Now, grab the current line from each pane to assemble
            loop from=1 to=panes.len() index="local.paneNo" {
                // If our pane has content for this row, use it (the pane may not have rendered all the rows available)
                if( row <= panes[ paneNo ].lines.len() ) {
                    thisRow &= panes[ paneNo ].lines[ row ];
                    // If the pane didn't generate a wide enough line, pad this pane's content with spaces
                    if( panes[ paneNo ].lines[ row ].length() < panes[ paneNo ].actualWidth ) {
                        thisRow &= repeatString( ' ', panes[ paneNo ].actualWidth-panes[ paneNo ].lines[ row ].length() );
                    }
                // If the pane gave us no content, just fill this row with spaces
                } else {
                    thisRow &= repeatString( ' ', panes[ paneNo ].actualWidth );
                }
                //  For all panes but the last, put in our vertical beam and padding between panes
                if( paneNo < panes.len() ) {
                    thisRow &= ' ' & box.v & ' ';
                }
            }
            // Finalize right side of row and append.
            thisRow &= ' ' & box.v;
            finalLines.append( thisRow )
        }
        // Slap top row on top and bottom row on bottom (we generated this above)
        finalLines.prepend( topRow )
        finalLines.append( bottomRow )

        setLines( finalLines );
        // Let abstract class clean up data (truncate) and convert strings to AttributedStrings, as well as create final render output struct.
        return super.render( originalHeight, originalWidth );
    }

}