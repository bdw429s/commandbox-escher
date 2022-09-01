/**
 * I allow rendering of 1 or more nested widgets inside a vertical panel where each widget is to above or below the others.
 * I am more of a container widget and don't have any output other than my border.
 *
 * ╔═╡ label ╞══╗
 * ╠════════════╣
 * ╠════════════╣
 * ║            ║
 * ╚════════════╝
 *
 * TODO: make border customizable or be able to turn off completely
 */
component extends='escher.models.AbstractWidget' accessors=true {

    /**
    * Allow children to be added via constructor, HOWEVER ther is no way to pass height in this case
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
        children.append( {
            widget : widget,
            requestedHeight : height,
            actualHeight : 0
        } );
        if( isActive() ) {
            widget.start();
        }
        return this;
    }

    /**
     * Build out bordered box with our children inside
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
        height = height - 2 - (children.len()-1);

        // Now we calculate actual width of all children.
        // TODO, move this to separate function
        // The end result of this method is that the actualHeight will be populated for each pane
        // If the total actual heights is too large, the content will just get truncated

        // Start with any children asking for a set number of rows and give them precedence
        var claimedRows = children.reduce( (acc,p)=>{
            if( !toString(p.requestedHeight).endsWith( '%' ) && p.requestedHeight != -1 ) {
                // Actual height is just the exact width they asked for (dangerous for small screens)
                p.actualHeight=p.requestedHeight;
                return acc+p.requestedHeight;
            }
            return acc;
        }, 0 );
        var remainingRows = height-claimedRows;
        if( remainingRows > 0 ) {
            //  Now calculate children asking for a % of what's left (mixing children with percentages AND set heights won't work that well)
            var claimedPerc = children.reduce( (acc,p)=>{
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
                // All remaining children with height of -1 equally spread out over remaining space
                // First, how many stretch children are sharing the remaining rows?
                var numStrectchChildren = children.reduce( (acc,p)=>{
                    if( p.requestedHeight == -1 ) {
                        return acc+1;
                    }
                    return acc;
                }, 0 );
                var rowsAvailbleForStretch = remainingRows;
                if( numStrectchChildren ) {
                    children.each( (p)=>{
                        if( p.requestedHeight == -1 ) {
                            // Actual width is equal percentage of remaining rows (round down)
                            p.actualHeight = int( rowsAvailbleForStretch/numStrectchChildren );
                            remainingRows -= p.actualHeight;
                        }
                    } );
                    // Based on the rounding, we may have extra space-- arbitrarily assign the left over it to the last stretch pane
                    if( remainingRows > 0 ) {
                        children.filter( (p)=>p.requestedHeight == -1 ).last().actualHeight++;
                    }

                }
            }

        }

        // Now that we know the final heights availble to each pane, stitch them together
        // Since this is a vertical panel, their width is our width (minus the borders which we trimmed above)

        var finalLines = [];
        // Top border line
        var paneLabel = children.first().widget.getLabel();
        if( len( paneLabel ) ) {
            finalLines.append( box.ul & box.h & box.llb & ' ' & paneLabel & ' '& box.lrb & repeatString( box.h, width+2-attr.stripAnsi( paneLabel ).length()-5 ) & box.ur )
        } else {
            finalLines.append( box.ul & repeatString( box.h, width+2 ) & box.ur )
        }
        var paneNo = 0;
        // Loop over the children, we'll assemble them as we go
        for( var pane in children ) {
            paneNo++;
            // Get the rendered content for the nested widget
            var paneLines = pane.widget.render( pane.actualHeight, width ).buffer;
            finalLines.append(
                paneLines
                    // for each line
                    .map( (l)=>{
                        // Add our borders and buffers
                        var line =  box.v & " " & l;
                        // Fill in any empty space if the pane didn't render enough space to fill the width
                        var rawLen = attr.stripAnsi( l ).length();
                        if( rawLen < width ) {
                            line &= repeatString( ' ', width - rawLen )
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
            // For all children but the last, but in our horizontal beam separator
            if( paneNo < children.len() ) {
                var paneLabel = children[paneNo+1].widget.getLabel();
                if( len( paneLabel ) ) {
                    finalLines.append( box.hl & box.h & box.llb & ' ' & paneLabel & ' ' & box.lrb & repeatString( box.h, width+2-attr.stripAnsi( paneLabel ).length()-5 ) & box.hr )
                } else {
                    finalLines.append( box.hl & repeatString( box.h, width+2 ) & box.hr )
                }
            }
        }
        // Bottom border line
        finalLines.append( box.bl & repeatString( box.h, width+2 ) & box.br )

        setBuffer( finalLines );
        // Let abstract class clean up data (truncate) and convert strings to AttributedStrings, as well as create final render output struct.
        return super.render( originalHeight, originalWidth );
    }

    function start() {
        children.each( (p)=>p.widget.start() );
        super.start();
    }

    function stop() {
        children.each( (p)=>p.widget.stop() );
        super.stop();
    }

}