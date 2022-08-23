/**
* Description of task
*/
component {

	/**
	*
	*/
	function run() {
		

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
