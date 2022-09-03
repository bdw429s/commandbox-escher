component extends='escher.models.AbstractWidget' accessors=true {
    property name='message' type='string';
    property name='boxOptions' type='struct';

    function init( string message='', label='', buttons=[], struct boxOptions={} ) {
        setMessage( message );
        setLabel( label );
        setBoxOptions( boxOptions );

        registerListener( 'onKey', (data)=>{
            if( data.key=='key_left' ) {
                emit( 'retractFocus', { success : false } );
            } else if( data.key == 'key_right' ) {
                emit( 'advanceFocus', { success : false }  );
            // TODO: Prevent some dialogs from being escaped (force the user to answer)?
            } else if( data.key == 'escape' ) {
                stop();
            }
        } );


        if( arguments.buttons.len() && !children.len() ) {
            var buttonPanel = application.wirebox.getInstance( 'HorizontalPanel@escher' )
                .init( boxOptions : { border : false } );
            arguments.buttons.each( (b)=>buttonPanel.addPane(
                application.wirebox.getInstance( 'Button@escher' ).init(
                    inputLabel : b.label,
                    inputName : 'button',
                    hotKey : b.hotKey ?: '',
                    onSubmit : ()=>{
                        if( !isNull( b.onSubmit ) ) {
                            b.onSubmit( this );
                        }
                        stop();
                    }
                )
            ) );

            children.append( { widget : buttonPanel } );
        }

        return this;
    }

    struct function render( required numeric height, required numeric width ) {

        var boxOptions = getBoxOptions();
        boxOptions.width = boxOptions.width ?: 75;
        var messageLines = textControl(
            text=getMessage(),
            height=0,
            width=boxOptions.width-10,
            horizontalStrategy='wordWrap',
            textAlign='center'
        );
        boxOptions.height=messageLines.len()+8;
        boxOptions.borderColor = boxOptions.borderColor ?: 'blue';
        boxOptions.label = boxOptions.label ?: getLabel();


        clearBuffer()
        .drawBox( argumentCollection=boxOptions )
        .drawOverlay(
            messageLines,
            3,
            7
        );

        if( children.len() ) {
            drawOverlay(
                children.first().widget.render( 4, boxOptions.width-5 ),
                messageLines.len()+3,
                2
            );
        }

        commitBuffer();

        return super.render( height, width );
    }

}