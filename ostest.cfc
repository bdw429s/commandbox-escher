component {

    // byte units 
    variables.TB = 1024 * 1024 * 1024 * 1024;
    variables.GB = 1024 * 1024 * 1024;
    variables.MB = 1024 * 1024;
    variables.KB = 1024;

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
         var platform = si.getCurrentPlatform();
         var os = si.getOperatingSystem();
         var powerSources = hal.getPowerSources();
		powerSources.each( (p)=>print.line( 'Is Charging: ' &  p.isCharging() ) )
		print.line( hal.getNetworkIFs()
        .filter((p)=>{ return p.getName() == 'en0' })
        .map((p)=>{ return arrayToList(p.getIPv4addr(),'.') & " " & p.getName() & " :" & round(p.getSpeed()*0.000000125) & " MB/s"}));

		// print.line( os.getProcesses()
        //             .filter((p)=> { return p.getName() == 'java'})
        //             .map((p)=>{
        //                 var threads = p.getThreadDetails()
        //                 .filter((t)=>{ return t.getState() != 'SLEEPING'})
        //                 .map((t)=>{ return {
        //                     "service": listLast(p.getCurrentWorkingDirectory(),'/'),
        //                     "id": t.getThreadId(),
        //                     "name": t.getName(),
        //                     "state": t.getState().toString()
        //                 }});
        //                 return threads;


        //             })
        //             //.map((p)=>{ return p.getCommandLine() & ': ' & listLast(p.getCurrentWorkingDirectory(),'/') & ' ' & getSize(p.getResidentSetSize()) & '/' & getSize(p.getVirtualSize()) })
        //     );
        
		print.blueBoldline( 'Sensors');
		print.line( printInternetProtocolStats(os.getInternetProtocolStats()));
		// print.blueBoldline( 'CPU');
		// print.line( getCpuInfo(hal.getProcessor()) );
		// print.blueBoldline( 'Disk');
		print.line( getDiskInfo(os) );
		// print.blueBoldline( 'Memory');
		// print.line( getMemoryInfo(hal.getMemory()) );
		// print.line( os.toString() );
		// print.line( powerSources.toString() );
	}

    private function printInternetProtocolStats(internetProtocolStats) {
        var data = [];
        data.append("Internet Protocol statistics:");
        data.append(" TCPv4 Send: " & getSize(internetProtocolStats.getTCPv4Stats().getSegmentsSent()));
        data.append(" TCPv4 Recieve: " & getSize(internetProtocolStats.getTCPv4Stats().getSegmentsReceived()));
        data.append(" TCPv6: " & internetProtocolStats.getTCPv4Stats());
        return data;
      }

    function getCpuInfo(processor) {
        var cpuInfo = {};
        cpuInfo["name"]= processor.getProcessorIdentifier().getName();
        cpuInfo["package"]= processor.getPhysicalPackageCount();
        cpuInfo["core"]= processor.getPhysicalProcessorCount();
        cpuInfo["coreNumber"]= processor.getPhysicalProcessorCount();
        cpuInfo["logic"]= processor.getLogicalProcessorCount();
        // CPU信息
        var prevTicks = processor.getSystemCpuLoadTicks();
        // 等待1秒...
        sleep(1000);
        var ticks = processor.getSystemCpuLoadTicks();
        var user =      ticks[1] - prevTicks[1];
        var nice =      ticks[2] - prevTicks[2];
        var sys =       ticks[3] - prevTicks[3];
        var idle =      ticks[4] - prevTicks[4];
        var iowait =    ticks[5] - prevTicks[5];
        var irq =       ticks[6] - prevTicks[6];
        var softirq =   ticks[7] - prevTicks[7];
        var steal =     ticks[8] - prevTicks[8];
        var totalCpu = user + nice + sys + idle + iowait + irq + softirq + steal;
        cpuInfo["used"] = decimalFormat((100 * user / totalCpu) + (100 * sys / totalCpu));
        cpuInfo["idle"] = decimalFormat((100 * idle / totalCpu));
        return cpuInfo;
    }

    function printServices(os) {
        // DO 5 each of running and stopped
        var i = 0;
        var services = [];
        var service_list = os.getServices();
        for (var i=1; i<=5; i++) {
            var s = service_list[i];
            services.append(s.getName());
        }
        return services;
      }
    

    function getMemoryInfo(memory) {
        var memoryInfo = {};
        memoryInfo["total"] = getSize(memory.getTotal());
        memoryInfo["available"] = getSize(memory.getAvailable());
        memoryInfo["used"] = getSize(memory.getTotal() - memory.getAvailable());
        memoryInfo["usageRate"] = decimalFormat((memory.getTotal() - memory.getAvailable())/memory.getTotal() * 100);
        return memoryInfo;
    }

    function getDiskInfo(os) {
        var fileSystem = os.getFileSystem();
        var fsArray = fileSystem.getFileStores();
        return fsArray.filter((fs)=>{ return fs.getMount() == '/'})
            .reduce((acc,fs)=>{
            
            var diskInfo = {};
            var available = fs.getUsableSpace();
            var total = fs.getTotalSpace();
            var used = total - available;
            diskInfo["dirName"] = fs.getMount();
            diskInfo["sysTypeName"] = fs.getType();
            diskInfo["typeName"] = fs.getName();
            diskInfo["total"] = total > 0 ? getSize(total) : "?";
            diskInfo["available"] = getSize(available);
            diskInfo["used"] = getSize(used);
            if(total != 0){
                diskInfo["usageRate"] = decimalFormat(used/total * 100);
            } else {
                diskInfo["usageRate"]=  0;
            }
            acc[fs.name] = diskInfo;
            return acc;
        },{})
    }

    function getSize(size) {
        var resultSize = "";
        if (size / TB >= 1) {
            resultSize = decimalFormat(size / TB) & "TB";
        } else if (size / GB >= 1) {
            resultSize = decimalFormat(size / GB) & "GB";
        } else if (size / MB >= 1) {
            //1MB
            resultSize = decimalFormat(size /  MB) & "MB";
        } else if (size / KB >= 1) {
            //1KB
            resultSize = decimalFormat(size / KB) & "KB";
        } else {
            resultSize = size & "B";
        }
        return resultSize;
    }

}