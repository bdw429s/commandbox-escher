/**
* Description of task
*/
component {

	/**
	*
	*/
	function run() {
		getInstance( 'Painter@escher' ).start( getInstance( 'time@escher' ) );
		getInstance( 'Painter@escher' ).start( getInstance( 'weather@escher' ) );
		getInstance( 'Painter@escher' ).start( getInstance( 'alert@escher' ).init( "The British are coming!", "error" ) );
		getInstance( 'Painter@escher' ).start( getInstance( 'confirm@escher' ).init( "Release the robots? " ) );
		getInstance( 'Painter@escher' ).start( getInstance( 'textInput@escher' ) );
		getInstance( 'Painter@escher' ).start( getInstance( 'scroller@escher' ) );
		getInstance( 'Painter@escher' ).start( getInstance( 'chart@escher' ).init( 'My Chart' ) );
		

		getInstance( 'Painter@escher' ).start(
			getInstance( 'OverlayPanel@escher' ).init(
				getInstance( 'HorizontalPanel@escher' )
				.addPane(
					getInstance( 'VerticalPanel@escher' )
						.addPane( getInstance( 'Time@escher' ), '6' )
						.addPane( getInstance( 'chart@escher' ).init( 'CPU Usage', 'red', '100' ) )
						.addPane( getInstance( 'chart@escher' ).init( 'Memory', 'blue', 'auto' ) ),
					'75%'
				 )
				.addPane( getInstance( 'VerticalPanel@escher' )
					.addPane( getInstance( 'Scroller@escher' ) )
					.addPane( getInstance( 'Scroller@escher' ) )
					.setLabel( 'Log Files' )
				),
				getInstance( 'textInput@escher' ).init( 'Enter Password: ' )
			)
		);
		print.greenLine( 'Complete!' );
	}

}
