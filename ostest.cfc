component {

	function run(  ) {
		if( !directoryExists( resolvePath( 'lib' ) ) ) {
			command( 'install "jar:https://repo1.maven.org/maven2/net/java/dev/jna/jna-platform/5.12.1/jna-platform-5.12.1.jar"' ).run();	
			command( 'install "jar:https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.12.1/jna-5.12.1.jar"' ).run();	
			command( 'install "jar:https://repo1.maven.org/maven2/com/github/oshi/oshi-core/6.2.2/oshi-core-6.2.2.jar"' ).run();	
		}

		classLoad( resolvePath( 'lib' ) )
		
	
        si = createObject( 'java', 'oshi.SystemInfo' );
        var hal = si.getHardware();
        // var platform = si.getCurrentPlatform();
        // var os = si.getOperatingSystem();
        var power = hal.getPowerSources();
		SystemOutput(power.isCharging().toString(),1);
	}

}