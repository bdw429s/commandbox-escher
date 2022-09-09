/**
 * I collect a line of text from the user.  Press enter to submit.
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name='formName' type='string' default='';
    property name='onSubmit';
    property name='formData';

    function init( iDrawable child, onSubmit, string formName='' ) {
        setFormName( formName );
        setFormData( {} );
        if( !isNUll( arguments.onSubmit ) ) {
            setOnSubmit( onSubmit );
        }
        if( !isNUll( arguments.child ) ) {
            addChild( child );
        }

        return this;
    }

    struct function render( required numeric height, required numeric width ) {
        var pageRender = children.first().widget.render( height, width );
        if( !isNull( pageRender.cursorPosition ) ) {
            setCursorPosition( pageRender.cursorPosition.row, pageRender.cursorPosition.col )
        } else {
            setCursorPosition( -1, -1 )
        }
        setBuffer( pageRender.buffer )
        return super.render( height, width );
    }

    function submit() {
        if( !isNull( variables.onSubmit ) ){
            // All all my decendants who are form fields to append their data to this formData struct
            this.emit( 'onFormDataCollection', { formData : getFormData() } );
            onSubmit( getFormData(), this );
        }
    }
}