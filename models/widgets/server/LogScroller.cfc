/**
 * I scroll text data from log files in a window
 * I am just a proof of concept, perhaps make me extendable and have subclasses that provide my data.
 * Or perhaps we don't even need a sub clas, but rather pass a closure to produce the data so I can be more resuable
 */
component extends='escher.models.AbstractWidget' accessors=true {
    property name="file" value="";
    variables.data  = [];

    function process() {
		setLabel( variables.file.listLast( '/\' ) );
        while( isActive() ) {

		setLabel( listLast( variables.file.toString(), '/\' ) );
            var data = getTail(variables.file,7)
            setBuffer( data );
            sleep( 500 )
        }
    }

    /**
	 * @path file or directory to tail or raw input to process
	 * @lines number of lines to display.
	 **/
     function getTail( required path, numeric lines = 15 ){//formatServerLog
		var filePath =  arguments.path ;

        if( !fileExists( filePath ) ) return ['Log file not found'];

		variables.file = createObject( "java", "java.io.File" ).init( filePath );

		var startPos = findStartPos();
		var startingLength = 0;

		try {

			var lineCounter = 0;
			var buffer = [];
			var randomAccessFile = createObject( "java", "java.io.RandomAccessFile" ).init( variables.file, "r" );
			var startingLength = variables.file.length();
			variables.position = startingLength;

			// move to the end of the file
			randomAccessFile.seek( position );
			// Was the last character a line feed.
			// Remember the CRLFs will be coming in reverse order
			var lastLF = false;

			while( true && startingLength ){

				var char = randomAccessFile.read();

				// Only increment CRs that were preceded by a LF
				if ( char == 13 && !lastLF ) {
					lineCounter += 1;
				}
				// Check for LF
				if ( char == 10 ) {
					lastLF=true;
					lineCounter += 1;
				} else {
					lastLF=false;
				}
				if ( char != -1 ) buffer.append( chr( char ) );

				position--;

				// stop looping if we have met our line limit or if end of file
				if ( position < startPos || lineCounter == arguments.lines ) {
					break;
				}

				// move to the preceding character
				randomAccessFile.seek( position );

			} // End while

			if( buffer.len() ) {
                // Strip any CR or LF from the last (first really) line to eliminate leading line breaks in console output
				buffer[ buffer.len() ] = listChangeDelims( buffer[ buffer.len() ], '', chr(13) & chr( 10 ) );
			}
		}
		finally {
            if( isDefined( 'randomAccessFile' ) ) {
                randomAccessFile.close();
			}
		}
        var printBuffer =  buffer
        .reverse()
        .toList( "" )
        .listToArray( chr( 13 ) & chr( 10 ) )
        .map( function( line ) {
            return cleanLine( line );
        } )
        return printBuffer;

	}

	// Deal with BOM (Byte order mark)
	// TODO: Actually pay attention to the BOM!
	function findStartPos() {
		var randomAccessFile = createObject( "java", "java.io.RandomAccessFile" ).init( file, "r" );
		randomAccessFile.seek( 0 );
		var length = randomAccessFile.length();
		var startPos = 0
		;
		// Will contain the first few bytes of the file represented by an integer
		var peek = '';

		// If the file has a least 2 bytes
		if( length > 1 ) {
			// read them
			peek &= randomAccessFile.read();
			randomAccessFile.seek( 1 );
			peek &= randomAccessFile.read();
			// If we found one of the 3 char BOMs
			if( listFindNoCase( '254255,255254', peek ) ) {
				// Start after it
				startPos=2;
			}
		}

		// If the file has a least 3 bytes
		if( length > 2 && ! startPos ) {
			// read them
			randomAccessFile.seek( 2 );
			peek &= randomAccessFile.read();
			// If we found one of the 3 char BOMs
			if( listFindNoCase( '239187191', peek ) ) {
				// Start after it
				startPos=3;
			}
		}
		// If the file has at least 4 bytes and we didn't find a 3 byte BOM
		if( length > 3 && ! startPos) {
			// Read the fourth byte
			randomAccessFile.seek( 3 );
			peek &= randomAccessFile.read();
			// If we found one of the 4 char BOMs
			if( listFindNoCase( '00254255,25525400', peek ) ) {
				// Start after it
				startPos=4;
			}
		}

		randomAccessFile.close();
		return startPos;
	}
    function cleanLine( line ) {

		// Log messages from the CF engine or app code writing directly to std/err out strip off "runwar.context" but leave color coded severity
		// Ex:
		// [INFO ] runwar.context: 04/11 15:47:10 INFO Starting Flex 1.5 CF Edition
		line = reReplaceNoCase( line, '^(\[[^]]*])( runwar\.context: )(.*)', '\1 \3' );

		// Log messages from runwar itself, simplify the logging category to just "Runwar:" and leave color coded severity
		// Ex:
		// [DEBUG] runwar.config: Enabling Proxy Peer Address handling
		// [DEBUG] runwar.server: Starting open browser action
		line = reReplaceNoCase( line, '^(\[[^]]*])( runwar\.[^:]*: )(.*)', '\1 Runwar: \3' );

		// Log messages from undertow's predicate logger, simplify the logging category to just "Server Rules:" and leave color coded severity
		// Ex:
		// [TRACE] io.undertow.predicate: Predicate [secure()] resolved to false for HttpServerExchange{ GET /CFIDE/main/ide.cfm}.
		// [TRACE] io.undertow.predicate: Path(s) [/CFIDE/main/ide.cfm] MATCH input [/CFIDE/main/ide.cfm] for HttpServerExchange{ GET /CFIDE/main/ide.cfm}.
		line = reReplaceNoCase( line, '^(\[[^]]*])( io\.undertow\.predicate: )(.*)', '\1 Server Rules: \3' );

		// Log messages from undertow's request dumper logger, simplify the logging category to just "Request Dump:"
		// Ex:
		// [TRACE] io.undertow.predicate: Predicate [secure()] resolved to false for HttpServerExchange{ GET /CFIDE/main/ide.cfm}.
		// [TRACE] io.undertow.predicate: Path(s) [/CFIDE/main/ide.cfm] MATCH input [/CFIDE/main/ide.cfm] for HttpServerExchange{ GET /CFIDE/main/ide.cfm}.
		line = reReplaceNoCase( line, '^(\[[^]]*])( io\.undertow\.request\.dump: )(.*)', 'Request Dump: \3' );

		// Log messages from Tuckey Rewrite engine "Rewrite UrlRewriter:"
		// Ex:
		// [DEBUG] org.tuckey.web.filters.urlrewrite.UrlRewriter: processing request for /services/training
		// [DEBUG] org.tuckey.web.filters.urlrewrite.RuleExecutionOutput: needs to be forwarded to /index.cfm/services/training
		line = reReplaceNoCase( line, '^(\[[^]]*])( org\.tuckey\.web\.filters\.urlrewrite\.UrlRewriter: )(.*)', '\1 Rewrite: \3' );
		line = reReplaceNoCase( line, '^(\[[^]]*])( org\.tuckey\.web\.filters\.urlrewrite\.RuleExecutionOutput: )(.*)', '\1 Rewrite Output: \3' );
		line = reReplaceNoCase( line, '^(\[[^]]*])( org\.tuckey\.web\.filters\.urlrewrite\.+)([^:]*: )(.*)', '\1 Rewrite \3\4' );

		// Strip off redundant severities that come from wrapping LogBox appenders in Log4j appenders
		// [INFO ] DEBUG my.logger.name This rain in spain stays mainly in the plains
		line = reReplaceNoCase( line, '^(\[(INFO |ERROR|DEBUG|WARN )] )(INFO|ERROR|DEBUG|WARN)( .*)', '[\3]\4' );

		// Add extra space so [WARN] becomes [WARN ]
		line = reReplaceNoCase( line, '^\[(INFO|WARN)]( .*)', '[\1 ]\2' );

		if( line.startsWith( '[INFO ]' ) ) {
			return reReplaceNoCase( line, '^(\[INFO ] )(.*)', '[#print.boldCyan('INFO ')#] \2' );
		}

		if( line.startsWith( '[ERROR]' ) ) {
			return reReplaceNoCase( line, '^(\[ERROR] )(.*)', '[#print.boldMaroon('ERROR')#] \2' );
		}

		if( line.startsWith( '[DEBUG]' ) ) {
			return reReplaceNoCase( line, '^(\[DEBUG] )(.*)', '[#print.boldGreen('DEBUG')#] \2' );
		}

		if( line.startsWith( '[WARN ]' ) ) {
			return reReplaceNoCase( line, '^(\[WARN ] )(.*)', '[#print.boldYellow('WARN ')#] \2' );
		}

		if( line.startsWith( '[TRACE]' ) ) {
			return reReplaceNoCase( line, '^(\[TRACE] )(.*)', '[#print.boldMagenta('TRACE')#] \2' );
		}

		return line;

	}

}