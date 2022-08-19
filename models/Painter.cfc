/**
*********************************************************************************
* Copyright Since 2014 CommandBox by Ortus Solutions, Corp
* www.coldbox.org | www.ortussolutions.com
********************************************************************************
* @author Brad Wood
*
* Handles timed redraws of the console for UI widgets
*
*/
component singleton accessors=true {
	// DI
	property name='wirebox'				inject='wirebox';
	property name="progressBarGeneric"	inject="progressBarGeneric";
	property name="progressBar"			inject="progressBar";
	property name="job"					inject="InteractiveJob";
	property name='shell'				inject='shell';
	property name='multiSelect';

	property name='active' type='boolean' default='false';
	property name='taskScheduler';
	property name='future';
	property name='widget';

	function onDIComplete() {
		variables.attr = createObject( 'java', 'org.jline.utils.AttributedString' );
		setTaskScheduler( wirebox.getTaskScheduler() );
		terminal = shell.getReader().getTerminal();
		display = createObject( 'java', 'org.jline.utils.Display' ).init( terminal, false );
	}

	/**
	* Starts up the scheduled painting thread if not already started
	*
	*/
	function start(iDrawable widget ) {
		widget.start();
		setWidget( arguments.widget );

		// If we have a dumb terminal or are running inside a CI server, skip the screen redraws all together.
		if( !shell.isTerminalInteractive() || terminal.getWidth() == 0 ) {
			return;
		}

		if( !getActive() ) {
			lock timeout="20" name="ConsolePainter" type="exclusive" {
				if( !getActive() ) {
					setFuture(
						getTaskScheduler().newSchedule( ()=>paint() )
					        .every( 200 )
					        .start()
					);

					setActive( true );
				}
			}
		}

		try {
			while( getActive() ) {
				sleep( 200 );
			}
		} catch( any e ) {
			stop();
		}
	}

	/**
	* Stops the scheduled painting thread if no jobs or progress bars are active and it's not already stopped
	*
	*/
	function stop() {

		widget.stop();

		if( getActive() ) {
			lock timeout="20" name="ConsolePainter" type="exclusive" {
				if( getActive() ) {
					clear();

					setActive( false );

					getFuture().cancel();
					try {
						getFuture().get();
					} catch(any e) {
						// Throws CancellationException
					}
					clear();

				}
			}
		}

	}

	/**
	* Draw the lines to the console
	*
	*/
	function paint() {
		try {
			if( !getWidget().isActive() ) {
				stop();
				return;
			}

			var height = terminal.getHeight();
			var width = terminal.getWidth();
			display.resize( height, width );

			var renderedContent = getWidget().render( height-1, width );
			var lines = renderedContent.lines
				.map( (l)=>attr.fromAnsi(l) );
			var cursorPosInt = 0;
			if( renderedContent.keyExists( 'cursorPosition' ) ) {
				cursorPosInt = terminal.getSize().cursorPos( renderedContent.cursorPosition.row-1, renderedContent.cursorPosition.col-1 );
			}

			// Add to console and flush
			display.update(
				lines,
				cursorPosInt
			);

		} catch( any e ) {
			if( !(e.type contains 'interrupt') ) {
				systemoutput( e.message & ' ' & e.detail, 1 );
				systemoutput( "#e.tagContext[1].template#: line #e.tagContext[1].line#", 1 );
				rethrow;
			}
		}
	}

	/**
	* Clear the console
	*/
	function clear() {
		display.resize( terminal.getHeight(), terminal.getWidth() );
		sleep(100)
		display.update(
			[ attr.init( ' ' ) ,attr.init( ' ' ) ,attr.init( ' ' ) ,attr.init( ' ' ) ],
			0
		);

	}
}