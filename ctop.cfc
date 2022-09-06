
component {
    property name="osUtil" inject="OSUtil@escher";

    function run(){
    //    print.table( osUtil.getCores());
    //    print.table( osUtil.getDisk())
    //    print.table( osUtil.getMemory())
    //    print.table( osUtil.getService())
      //print.table( osUtil.getCpu())
    //    print.table( osUtil.getNetwork())
    //    print.table( osUtil.getProcessList())
    }

    
    function run() {
        
        
        get( 'Painter' ).start(
		    get( 'OverlayPanel' ).init(
					get( 'vbox' )
						.addPane( 
                            get( 'hbox' )
				            .addPane(
                                get( 'vbox' ).init( { border : false } )
                                    .addPane(get('miniChart').init(
                                        title="CPU",
                                        dataProducer=()=>{
                                            var cpu = osUtil.getCpu();
                                            return cpu.used;
                                        }
                                    ))						            
                                    .addPane( get('List').init(dataProducer=()=>{
                                        var cpu = osUtil.getCpu();
                                        return [
                                            "Model": cpu.name,
                                            "Cores": cpu.coreNumber,
                                            "CPU Usage": cpu.used & '%'
                                        ]
                                    }),'60%')					            
                                    .addPane( get('Progress').init(dataProducer=()=>{
                                        var cpu = osUtil.getCpu();
                                        return cpu.used
                                    }))
                            )
				            .addPane(
                                get( 'vbox' ).init( { border : false } )
                                .addPane(get('miniChart').init(
                                    title="Core 1",
                                    dataProducer=()=>{
                                        var cpu = osUtil.getCores(1);
                                        return cpu.used;
                                    }
                                ))
                                .addPane(get('miniChart').init(
                                    title="Core 2",
                                    dataProducer=()=>{
                                        var cpu = osUtil.getCores(2);
                                        return cpu.used;
                                    }
                                ))
                                .addPane(get('miniChart').init(
                                    title="Core 3",
                                    dataProducer=()=>{
                                        var cpu = osUtil.getCores(3);
                                        return cpu.used;
                                    }
                                ))	
                            )
				            .addPane(
                                get( 'vbox' ).init( { border : false } )
                                .addPane(get('miniChart').init(
                                    title="Core 4",
                                    dataProducer=()=>{
                                        var cpu = osUtil.getCores(4);
                                        return cpu.used;
                                    }
                                ))
                                .addPane(get('miniChart').init(
                                    title="Core 5",
                                    dataProducer=()=>{
                                        var cpu = osUtil.getCores(5);
                                        return cpu.used;
                                    }
                                ))
                                .addPane(get('miniChart').init(
                                    title="Core 6",
                                    dataProducer=()=>{
                                        var cpu = osUtil.getCores(6);
                                        return cpu.used;
                                    }
                                ))	
                            )
                            .addPane(
                                get( 'vbox' ).init( { border : false } )
                                .addPane(get('miniChart').init(
                                    title="Core 7",
                                    dataProducer=()=>{
                                        var cpu = osUtil.getCores(7);
                                        return cpu.used;
                                    }
                                ))
                                .addPane(get('miniChart').init(
                                    title="Core 8",
                                    dataProducer=()=>{
                                        var cpu = osUtil.getCores(8);
                                        return cpu.used;
                                    }
                                ))
                                .addPane(get('miniChart').init(
                                    title="Core 9",
                                    dataProducer=()=>{
                                        var cpu = osUtil.getCores(9);
                                        return cpu.used;
                                    }
                                ))	
                            )
                            , '10' )
						.addPane( 
                            get( 'hbox' )
                                .addPane(
                                    get('Table').init("CPU Usage",()=>{
                                        return osUtil.getProcessList()
                                    }),
                                    '87%'
                                )
                                .addPane(
                                    get( 'vbox' )
                                    .addPane(
                                        get('List').init("Memory",()=>{
                                            var memory = osUtil.getMemory();
                                            return memory
                                        })
                                    )
                                    .addPane(
                                        get('Progress').init("Memory Usage",()=>{
                                            var memory = osUtil.getMemory();
                                            return memory.usageRate
                                        }),'5'
                                    )
                                    .addPane(
                                        get('List').init("Disk",()=>{
                                            var disk = osUtil.getDisk();
                                            return disk[StructKeyArray(disk)[1]];
                                        })
                                    )
                                    .addPane(
                                        get('List').init("Network Info",()=>{
                                            var network = osUtil.getNetwork();
                                            return network
                                        })
                                    )
                                )
                        )	 
		    )
		);
        
    }

    function get(required string widgetName){
        if(widgetName == 'hbox') widgetName = 'HorizontalPanel';
        if(widgetName == 'vbox') widgetName = 'VerticalPanel';
        return getInstance("#widgetName#@escher");
    }
}