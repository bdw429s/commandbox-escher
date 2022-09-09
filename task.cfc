/**
* Description of task
*/
component {

	/**
	*
	*/
	function run() {
		var painter = getInstance( 'Painter@escher' );
/*
		painter.start(
			getInstance( 'OverlayPanel@escher' ).init(
				getInstance( 'Blank@escher' ),
				getInstance( name='alert@escher', initArguments={ message="The British are coming!", type="error", onSubmit=()=>painter.stop() } )
			)
		);

		painter.start(
			getInstance( 'OverlayPanel@escher' ).init(
				getInstance( 'Blank@escher' ),
				getInstance( name='confirm@escher', initArguments={  message="Release the robots? ", onSubmit=()=>painter.stop()} )
			)
		);

		painter.start(
			getInstance( 'OverlayPanel@escher' ).init(
				getInstance( 'Blank@escher' ),
				getInstance( name='Prompt@escher', initArguments={ prompt='Enter New Value: ', onSubmit=()=>painter.stop() } )
			)
		);

		painter.start(
			getInstance( 'OverlayPanel@escher' ).init(
				getInstance( 'Blank@escher' ),
				getInstance( name='Dialog@escher', initArguments={
					message : "This is some text which will be nicely word-wrapped.  The dialog will stretch to fit, and the buttons will be evently spaced below.",
					label : "Hey, you!",
					buttons : [
						{
							label : 'Yes',
							hotKey : 'Y',
							selected : true,
							onSubmit : ()=>painter.stop()
						},
						{
							label : 'No',
							hotKey : 'N',
							onSubmit : ()=>painter.stop()
						},
						{
							label : 'Maybe',
							hotKey : 'M',
							onSubmit : ()=>painter.stop()
						}
					]
				} )
			)
		);
*/
		painter.start(
			getInstance( 'OverlayPanel@escher' ).init(
				getInstance( 'HorizontalPanel@escher' )
				.addPane(
					getInstance( 'VerticalPanel@escher' )
						.addPane( getInstance( 'Time@escher' ), '6' )
						.addPane( getInstance( 'chartDemo@escher' ).init( 'CPU Usage', 'red', '100' ) )
						.addPane( getInstance( 'chartDemo@escher' ).init( 'Memory', 'blue', 'auto' ) ),
					'75%'
				 )
				.addPane( getInstance( 'VerticalPanel@escher' )
					.addPane( getInstance( 'Scroller@escher' ), '50%' )
					.addPane(
						getInstance( name : 'Form@escher', initArguments : {
							child : getInstance( 'VerticalPanel@escher' ).init( { border : false } )
										.addPane( getInstance( 'TextInput@escher' ).init( 'Name: ' ) )
										.addPane( getInstance( 'TextInput@escher' ).init( 'Age: ' ) )
										.addPane( getInstance( 'TextInput@escher' ).init( 'Color: ' ) )
										.addPane( getInstance( 'TextInput@escher' ).init( inputLabel='Password: ', mask='*' ) )
										.addPane( getInstance( 'Button@escher' ).init( inputLabel='Save', type="submit" ) ),
							onSubmit : (formData)=>print.line(formData)
						} )
					)
					 .setLabel( 'Log Files' )
				)//,
				//getInstance( 'prompt@escher' ).init( 'Enter Password: ' )
				//getInstance( 'confirm@escher' ).init( "Release the robots? ", (response, dialog)=>print.line( 'You confirmed [#response#]' ) )
			)
		);

	//	task( 'ctop' ).run();

	}

}
