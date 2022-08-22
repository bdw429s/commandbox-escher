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
						.addPane( getInstance( 'Time@escher' ) )
						.addPane( getInstance( 'chart@escher' ).init( 'My Chart', 'red', 'auto' ) )
						.addPane( getInstance( 'Time@escher' ) ),
					'75%'
				 )
				.addPane( getInstance( 'VerticalPanel@escher' )
					.addPane( getInstance( 'Scroller@escher' ) )
					.addPane( getInstance( 'Scroller@escher' ) )
					.setLabel( 'Log Files' )
				)//,
				//getInstance( 'textInput@escher' ).init( 'Enter Something: ' )
			)
		);
		print.greenLine( 'Complete!' );
	}

}
