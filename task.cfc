/**
* Description of task
*/
component {

	/**
	*
	*/
	function run() {


		getInstance( 'Painter@escher' ).start( getInstance( 'alert@escher' ).init( "The British are coming!", "error" ) );

		getInstance( 'Painter@escher' ).start(
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
					.addPane( getInstance( 'VerticalPanel@escher' ).init( { border : false } )
						.addPane( getInstance( 'TextInput@escher' ).init( 'Name: ' ) )
						.addPane( getInstance( 'TextInput@escher' ).init( 'Age: ' ) )
						.addPane( getInstance( 'TextInput@escher' ).init( 'Color: ' ) )
						.addPane( getInstance( 'TextInput@escher' ).init( 'Password: ' ) )
					 )
					 .setLabel( 'Log Files' )
				),
				//getInstance( 'prompt@escher' ).init( 'Enter Password: ' )
				getInstance( 'confirm@escher' ).init( "Release the robots? ", (response, dialog)=>print.line( 'You confirmed [#response#]' ) )
			)
		);


		getInstance( 'Painter@escher' ).start( getInstance( 'Dialog@escher' ).init(
			message : "This is some text which will be nicely wrapped.  The dialog will stretch to fit.",
			label : "Hey, you!",
			buttons : [
				{
                    label : 'Confirm',
                    hotKey : 'C',
                    selected : true,
					onSubmit : (dialog)=>print.line( 'Confirmed!' )
				},
				{
                    label : 'Cancel',
                    hotKey : 'n',
					onSubmit : (dialog)=>print.line( 'Cancelled!' )
				}
			]
		 ) );

		//return;

		getInstance( 'Painter@escher' ).start( getInstance( 'Prompt@escher' ).init( 'Enter Passphrase: ', (r)=>print.line( r ) ) );
		//return;
		getInstance( 'Painter@escher' ).start( getInstance( 'alert@escher' ).init( "The British are coming!", "error" ) );
		getInstance( 'Painter@escher' ).start( getInstance( 'confirm@escher' ).init( "Release the robots? ", (response, dialog)=>print.line( 'You confirmed [#response#]' ) ) );
		//return;

		getInstance( 'Painter@escher' ).start( getInstance( 'time@escher' ) );
		getInstance( 'Painter@escher' ).start( getInstance( 'weather@escher' ) );
		getInstance( 'Painter@escher' ).start( getInstance( 'scroller@escher' ) );
		getInstance( 'Painter@escher' ).start( getInstance( 'chartDemo@escher' ).init( 'My Chart' ) );


		getInstance( 'Painter@escher' ).start(
			getInstance( 'HorizontalPanel@escher' )
				.addPane( getInstance( 'VerticalPanel@escher' )
					.addPane( getInstance( 'TextInput@escher' ).init( 'Name: ' ) )
					.addPane( getInstance( 'TextInput@escher' ).init( 'Age: ' ) )
					.addPane( getInstance( 'TextInput@escher' ).init( 'Color: ' ) )
				)
				.addPane( getInstance( 'VerticalPanel@escher' )
					.addPane( getInstance( 'TextInput@escher' ).init( 'Password: ' ) )
					.addPane( getInstance( 'TextInput@escher' ).init( 'Company: ' ) )
					.addPane( getInstance( 'Button@escher' ).init( ' Save! ' ) )
				)


		);

		print.greenLine( 'Complete!' );
	}

}
