component extends='escher.models.AbstractWidget' {
    property name="panes" type="array";

    variables.panes=[];

    function init() {
        arguments.each( (k,v)=>addPane(v) );
        return this;
    }

    function addPane( iDrawable widget, width=-1 ) {
        panes.append( {
            widget : widget,
            requestedWidth : width,
            actualWidth : 0,
            lines=[]
        } );
        return this;
    }

    struct function render( required numeric height, required numeric width ) {
        var originalHeight = height;
        var originalWidth = width;
        width=width-4 - ((panes.len()-1)*3);
        height = height - 2;
        var claimedCols = panes.reduce( (acc,p)=>{
            if( !toString(p.requestedWidth).endsWith( '%' ) && p.requestedWidth != -1 ) {
                p.actualWidth=p.requestedWidth;
                return acc+p.requestedWidth;
            }
            return acc;
        }, 0 );
        var remainingCols = width-claimedCols;
        if( remainingCols > 0 ) {
            var claimedPerc = panes.reduce( (acc,p)=>{
                if( toString(p.requestedWidth).endsWith( '%' ) ) {
                    p.actualWidth=int( (p.requestedWidth.left(-1)/100)*remainingCols );
                    remainingCols -= p.actualWidth;
                    return acc+p.requestedWidth.left(-1);
                }
                return acc;
            }, 0 );
            if( claimedPerc > 100 ) {
                throw( 'Pane width percentages total [#claimedPerc#] is greater than 100.' );
            }
            if( remainingCols > 0 ) {
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
                            p.actualWidth = int( colsAvailbleForStretch/numStrectchPanes );
                            remainingCols -= p.actualWidth;
                        }
                    } );
                    if( remainingCols > 0 ) {
                        panes.filter( (p)=>p.requestedWidth == -1 ).last().actualWidth++;
                    }

                }
            }

        }
        panes.each( (pane)=>pane.lines=pane.widget.render( height, pane.actualWidth ).lines );

        var finalLines = [];
        var topRow = box.ul & box.h;
        var bottomRow = box.bl & box.h;
        loop from=1 to=panes.len() index="local.paneNo" {
            topRow &= repeatString( box.h, panes[ paneNo ].actualWidth )
            bottomRow &= repeatString( box.h, panes[ paneNo ].actualWidth )
            if( paneNo < panes.len() ) {
                topRow &= box.h & box.vt & box.h;
                bottomRow &= box.h & box.vb & box.h;
            }
        }
        topRow &= box.h & box.ur;
        bottomRow &= box.h & box.br;

        loop from=1 to=height index="local.row" {
            var thisRow = box.v & ' ';
            loop from=1 to=panes.len() index="local.paneNo" {
                if( row <= panes[ paneNo ].lines.len() ) {
                    thisRow &= panes[ paneNo ].lines[ row ];
                    if( panes[ paneNo ].lines[ row ].length() < panes[ paneNo ].actualWidth ) {
                        thisRow &= repeatString( ' ', panes[ paneNo ].actualWidth-panes[ paneNo ].lines[ row ].length() );
                    }
                } else {
                    thisRow &= repeatString( ' ', panes[ paneNo ].actualWidth );
                }
                if( paneNo < panes.len() ) {
                    thisRow &= ' ' & box.v & ' ';
                }
            }
            thisRow &= ' ' & box.v;
            finalLines.append( thisRow )
        }

        finalLines.prepend( topRow )
        finalLines.append( bottomRow )

        setLines( finalLines );
        return super.render( originalHeight, originalWidth );
    }

}