/**
 * I show a table of servers to demonstrate the table functionality
 * I am just a proof of concept, perhaps make me extendable and have subclasses that provide my data.
 * Or perhaps we don't even need a sub clas, but rather pass a closure to produce the data so I can be more resuable
 */
component extends='escher.models.AbstractWidget' accessors=true {
    processingdirective pageEncoding='UTF-8';
    property name="serverService" inject="serverService";

    function process(){
        while( isActive() ){
            var servers = serverService.getServers();
            var serverlist = servers
                .reduce((acc,serverName, thisServerInfo) => {
                    var pid = 0;
                    if(FileExists(thisServerInfo.pidfile)){
                        pid = FileRead(thisServerInfo.pidfile);

                        acc.append([
                            "pid":pid,
                            "Name":thisServerInfo.name,
                            "Status":thisServerInfo.status,
                            "Port": thisServerInfo.port,
                            "Version": thisServerInfo.engineVersion,
                            "HeapSize": thisServerInfo.heapSize
                        ]);
                    }
                    return acc;
                },[])
                if( serverlist.len() ) {
                    setBuffer([print.table(serverlist)])
                } else {
                    setBuffer(['There are no servers running'])
                }

            sleep(5000)
        }
    }



}