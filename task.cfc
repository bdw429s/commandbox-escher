/**
* Description of task
*/
component {

	/**
	*
	*/
	function run() {
		getInstance( 'Painter@escher' ).start(
			getInstance( 'HorizontalPanel@escher' )
				.addPane(
					getInstance( 'VerticalPanel@escher' )
					.addPane( getInstance( 'Time@escher' ) )
					.addPane( getInstance( 'Time@escher' ) )
					.addPane( getInstance( 'Time@escher' ) ),
					'75%'
				 )
				.addPane( getInstance( 'VerticalPanel@escher' )
					.addPane( getInstance( 'Scroller@escher' ) )
					.addPane( getInstance( 'Scroller@escher' ) )
				)
		);
		print.greenLine( 'Complete!' );
	}

}
