component extends='escher.models.AbstractWidget' accessors=true {
    property name='message' type='string';
    property name='buttons' type='array';

    function init( string message='', label='', buttons=[] ) {
        setMessage( message );
        setLabel( label );
        setButtons( buttons );
        return this;
    }

    function process() {
        var boxWidth = 75;
        var messageLines = textControl(
            text=getMessage(),
            height=0,
            width=boxWidth-10,
            horizontalStrategy='wordWrap'
        )

        while( isActive() ){
            clearBuffer()
            .drawBox(
                height=messageLines.len()+7,
                width=boxWidth,
                borderColor='blue',
                label=getLabel()
            )
            .drawOverlay(
                messageLines,
                3,
                7
            );
            // Calc button spacing
            var usedWidth = buttons.len()*3 + buttons.reduce( (len,b)=>{return len+len( b.label ) }, 0 );
            if( usedWidth > boxWidth-4 ) {
                // TODO: wrap buttons
                throw( 'Buttons are too wide for the dialog' );
            }
            var spaceBetween = int( boxWidth-4-usedWidth )/(buttons.len()+1);
            var currOffset=3+spaceBetween;
            buttons.each( (b)=>{
                drawButton(
                    label=b.label,
                    hotKey=b.hotKey ?: '',
                    selected=b.selected ?: false,
                    row=messageLines.len()+4,
                    col=currOffset
                );
                currOffset += len( b.label ) + 3 + spaceBetween;
            } );

            commitBuffer();

            sleep(1000);

        }
    }

}