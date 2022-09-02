component {

	function run(  ) {
		if( !directoryExists( resolvePath( 'lib' ) ) ) {
			command( 'install "jar:https://repo1.maven.org/maven2/net/java/dev/jna/jna-platform/5.12.1/jna-platform-5.12.1.jar"' ).run();
			command( 'install "jar:https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.12.1/jna-5.12.1.jar"' ).run();
			command( 'install "jar:https://repo1.maven.org/maven2/com/github/oshi/oshi-core/6.2.2/oshi-core-6.2.2.jar"' ).run();
			command( 'install "jar:https://search.maven.org/remotecontent?filepath=org/slf4j/slf4j-api/2.0.0/slf4j-api-2.0.0.jar"' ).run();
			command( 'install "jar:https://search.maven.org/remotecontent?filepath=org/slf4j/slf4j-simple/2.0.0/slf4j-simple-2.0.0.jar"' ).run();

			command( 'install cbjavaloader' ).run();
		}

		loadModule( 'modules/cbjavaloader' )

		jl = getInstance( "loader@cbjavaloader" );
		jl.appendPaths( resolvePath( 'lib' ) );


        si = jl.create('oshi.SystemInfo' );
        var hal = si.getHardware();
        // var platform = si.getCurrentPlatform();
        // var os = si.getOperatingSystem();
        var powerSources = hal.getPowerSources();
		powerSources.each( (p)=>print.line( 'Is Charging: ' &  p.isCharging() ) )
		print.line( powerSources.toString() );
	}

}