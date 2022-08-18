/**
* Description of task
*/
component {
	property name="serverService" inject="serverService";

	/**
	*
	*/
	function run( required name ) {

		var serverInfo = serverService.getServerInfoByName(arguments.name);
		if(!serverInfo.keyExists("name")){
			print.redLine("Unrecognized Server Name");
			return;
		} 
		var serverLog = serverInfo.consolelogPath;
		var rewritesLog = serverInfo.rewritesLogPath;
		
		getInstance( 'Painter@escher' ).start(
			getInstance( 'VerticalPanel@escher' )
				.addPane( 
					getInstance( 'HorizontalPanel@escher' )
						.addPane( getInstance( 'Scroller@escher' ) )
						.addPane( getInstance( 'Time@escher' ) )
				)
				.addPane( 
					getInstance( 'LogScroller@escher' ).setFile(serverLog)
				)
				.addPane( 
					getInstance( 'LogScroller@escher' ).setFile(rewritesLog)
				)
				 
		);
		print.greenLine( 'Complete!' );
	}

}
