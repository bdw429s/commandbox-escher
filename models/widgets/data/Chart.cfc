/**
 * I am a single-series area chart.  My X/Y resolution will be the number of cols and rows available.
 */
component extends='escher.models.widgets.data.AbstractChart' accessors=true {

    struct function render( required numeric height, required numeric width ) {
            lastWidth=width;
            var theData = duplicate( seriesData );
            var theLines = [];
            var graphHeight = getTitle().len() ? height-1 : height;

            loop from=1 to=graphHeight index='local.i' {
                theLines.append( '' )
            }
            var thisYMax = YMax;
            if( YMax == 'auto' ) {
                thisYMax = seriesData.max();
            }
            YMaxWidth = toString( thisYMax ).len();
            var row=0;
            theData.each( (p)=>{
                // Remove this if/when we allow negative graph values
                p=max(p,0);
                row++;
                loop from=1 to=graphHeight index='local.i' {
                    if( row == 1 ) {
                        if( i == 1 ) {
                            theLines[ i ] &= '1';
                        } else if( i == graphHeight ) {
                            theLines[ i ] &= thisYMax;
                        } else if( i == int( graphHeight/2 ) ) {
                            theLines[ i ] &= int(thisYMax/2);
                        } else {
                            theLines[ i ] &= ' ';
                        }
                    } else if( row <= YMaxWidth ) {
                        if( i == graphHeight && row <= YMaxWidth ) {
                            theLines[ i ] &= '';
                        } else if( i == int( graphHeight/2 ) && row <= len( int(thisYMax/2) ) ) {
                            theLines[ i ] &= '';
                        } else {
                            theLines[ i ] &= ' ';
                        }
                    } else {
                        if( (p/thisYMax) > i/graphHeight ) {
                            theLines[ i ] &= print.t( char, color );
                        } else {
                            theLines[ i ] &= ' ';
                        }
                    }
                }
            } )

            if( getTitle().len() ) {
                var headerStartCol = int((width-len(getTitle()))/2);
                var headerEndWidth = width-headerStartCol - getTitle().len();

                theLines.append( repeatString( ' ', headerStartCol ) & getTitle() & repeatString( ' ', headerEndWidth ) )
            }

            setBuffer( theLines.reverse() );

            return super.render( argumentCollection=arguments );
    }



}