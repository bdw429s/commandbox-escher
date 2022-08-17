component extends='escher.models.AbstractWidget' {
    property name="panes" type="array";

    variables.panes=[];

    function init() {
        arguments.each( (k,v)=>addPane(v) );
        return this;
    }

    function addPane( iDrawable widget, height=-1 ) {
        panes.append( {
            widget : widget,
            requestedHeight : height,
            actualHeight : 0
        } );
        return this;
    }

    struct function render( required numeric height, required numeric width ) {
        var originalHeight = height;
        var originalWidth = width;
        width=width-4;
        height = height - 2 - (panes.len()-1);
        var claimedRows = panes.reduce( (acc,p)=>{
            if( !toString(p.requestedHeight).endsWith( '%' ) && p.requestedHeight != -1 ) {
                p.actualHeight=p.requestedHeight;
                return acc+p.requestedHeight;
            }
            return acc;
        }, 0 );
        var remainingRows = height-claimedRows;
        if( remainingRows > 0 ) {
            var claimedPerc = panes.reduce( (acc,p)=>{
                if( toString(p.requestedHeight).endsWith( '%' ) ) {
                    p.actualHeight=int( (p.requestedHeight.left(-1)/100)*remainingRows );
                    remainingRows -= p.actualHeight;
                    return acc+p.requestedHeight.left(-1);
                }
                return acc;
            }, 0 );
            if( claimedPerc > 100 ) {
                throw( 'Pane height percentages total [#claimedPerc#] is greater than 100.' );
            }
            if( remainingRows > 0 ) {
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
                            p.actualHeight = int( rowsAvailbleForStretch/numStrectchPanes );
                            remainingRows -= p.actualHeight;
                        }
                    } );
                    if( remainingRows > 0 ) {
                        panes.filter( (p)=>p.requestedHeight == -1 ).last().actualHeight++;
                    }

                }
            }

        }
        var finalLines = [];
        finalLines.append( box.ul & repeatString( box.h, width+2 ) & box.ur )
        var paneNo = 0;
        for( var pane in panes ) {
            paneNo++;
            var paneLines = pane.widget.render( pane.actualHeight, width ).lines;
            finalLines.append(
                paneLines
                .map( (l)=>{
                    var line =  box.v & " " & l;
                    if( len( l ) < width ) {
                        line &= repeatString( ' ', width - len( l ) )
                    }
                    return line & " " & box.v;
                 } )
            , true );
            if( paneLines.len() < pane.actualHeight ) {
                loop times=pane.actualHeight-paneLines.len() {
                    finalLines.append( box.v & repeatString( ' ', width+2 ) & box.v );
                }
            }
            if( paneNo < panes.len() ) {
                finalLines.append( box.hl & repeatString( box.h, width+2 ) & box.hr )
            }
        }
        finalLines.append( box.bl & repeatString( box.h, width+2 ) & box.br )

        setLines( finalLines );
        return super.render( originalHeight, originalWidth );
    }

}