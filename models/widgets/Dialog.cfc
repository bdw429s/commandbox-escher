component extends='escher.models.AbstractWidget' accessors=true {
    property name='message' type='string';
    property name='buttons' type='array';
    property name='selectedButtonIndex' type='numeric';
    property name='boxOptions' type='struct';

    function init( string message='', label='', buttons=[], struct boxOptions={} ) {
        setMessage( message );
        setLabel( label );
        setButtons( buttons );
        setBoxOptions( boxOptions );
        setSelectedButtonIndex(1);
        return this;
    }

    function setButtons( array buttons ) {
        variables.buttons = arguments.buttons;

        if( !buttons.len() ) {
            setSelectedButtonIndex( 0 );
            return this;
        }

        buttons.each( (b,i)=>{
            if( b.selected ?: false ) {
                setSelectedButtonIndex( i );
            }
        } );

    }

    function process() {

        while( isActive() ){

            var boxOptions = getBoxOptions();
            boxOptions.width = boxOptions.width ?: 75;
            var messageLines = textControl(
                text=getMessage(),
                height=0,
                width=boxOptions.width-10,
                horizontalStrategy='wordWrap',
                textAlign='center'
            );
            boxOptions.height=messageLines.len()+7;
            boxOptions.borderColor = boxOptions.borderColor ?: 'blue';
            boxOptions.label = boxOptions.label ?: getLabel();

            clearBuffer()
            .drawBox( argumentCollection=boxOptions )
            .drawOverlay(
                messageLines,
                3,
                7
            );
            // Calc button spacing
            var usedWidth = buttons.len()*3 + buttons.reduce( (len,b)=>{return len+len( b.label ) }, 0 );
            if( usedWidth > boxOptions.width-4 ) {
                // TODO: wrap buttons
                throw( 'Buttons are too wide for the dialog' );
            }
            var spaceBetween = int( boxOptions.width-4-usedWidth )/(buttons.len()+1);
            var currOffset=3+spaceBetween;
            buttons.each( (b,i)=>{

                drawButton(
                    label=b.label,
                    hotKey=b.hotKey ?: '',
                    selected=( getSelectedButtonIndex()==i ),
                    row=messageLines.len()+4,
                    col=currOffset
                );
                currOffset += len( b.label ) + 3 + spaceBetween;
            } );

            commitBuffer();

            var key = shell.waitForKey();
            if( key=='key_left' || key == 'back_tab' ) {
                if( selectedButtonIndex > 1 ) {
                    selectedButtonIndex--;
                }
            } else if( key == 'key_right' || asc(key) == 9 ) {
                if( selectedButtonIndex < buttons.len() ) {
                    selectedButtonIndex++;
                }
            // TODO: Prevent some dialogs from being escaped (force the user to answer)?
            } else if( key == 'escape' ) {
                stop();
                return;
            } else if( asc( key ) == 10 || asc( key ) == 13 ) {
                if( selectedButtonIndex && buttons[ selectedButtonIndex ].keyExists( 'onSubmit' ) && isCustomFunction( buttons[ selectedButtonIndex ].onSubmit ) ) {
                    buttons[ selectedButtonIndex ].onSubmit( this )
                }
                stop();
                return;
            }

        }
    }

}