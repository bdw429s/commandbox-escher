component extends='escher.models.AbstractWidget' accessors=true {

    function init() {
        return this;
    }

    function process() {
        while( isActive() ){
            var theLines = drawBox(
                height=10,
                width=75,
                borderColor='blue',
                label=print.boldGreen( 'This is a test of the long string' )
            );

            theLines = drawOverlay(
                theLines,
                drawButton(
                    label='Confirm',
                    hotKey='C',
                    selected=true
                ),
                6,
                17
            )

            theLines = drawOverlay(
                theLines,
                drawButton(
                    label='Cancel',
                    hotKey='n'
                ),
                6,
                47
            )

            setLines(
                theLines
            )

            sleep(1000)
        }
    }

}