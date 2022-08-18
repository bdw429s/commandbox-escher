/**
 * I ouptut the current date/time as ASCII arg
 * I am just a proof of concept.
 */
component extends='escher.models.AbstractWidget' {
    processingdirective pageEncoding='UTF-8';

    function process() {
        while( isActive() ) {
            var dateTime = dateTimeFormat( now(), 'mm/dd/yyyy hh:nn:ss tt' ).listtoArray( '' );
            // My ASCII art letters are 5 rows tall, so map the characters inour string to each of the rows below
            setLines(
                [
                    dateTime.map( (c)=>rows[1][ rowMap[c] ] ).toList( '' ),
                    dateTime.map( (c)=>rows[2][ rowMap[c] ] ).toList( '' ),
                    dateTime.map( (c)=>rows[3][ rowMap[c] ] ).toList( '' ),
                    dateTime.map( (c)=>rows[4][ rowMap[c] ] ).toList( '' ),
                    dateTime.map( (c)=>rows[5][ rowMap[c] ] ).toList( '' )
                ]
            );
            sleep( 1000 );
        }

    }

    // TODO, support other fonts?  Perhaps an entire library that converts text to ASCII art?
    rows = [[' ██████  ',' ██ ','██████  ','██████  ','██   ██ ','███████ ',' ██████  ','███████ ',' █████  ',' █████  ','    ','   ','    ██ ',' █████  ','██████  ','███    ███ '],
            ['██  ████ ','███ ','     ██ ','     ██ ','██   ██ ','██      ','██       ','     ██ ','██   ██ ','██   ██ ','    ','██ ','   ██  ','██   ██ ','██   ██ ','████  ████ '],
            ['██ ██ ██ ',' ██ ',' █████  ',' █████  ','███████ ','███████ ','███████  ','    ██  ',' █████  ',' ██████ ','    ','   ','  ██   ','███████ ','██████  ','██ ████ ██ '],
            ['████  ██ ',' ██ ','██      ','     ██ ','     ██ ','     ██ ','██    ██ ','   ██   ','██   ██ ','     ██ ','    ','██ ',' ██    ','██   ██ ','██      ','██  ██  ██ '],
            [' ██████  ',' ██ ','███████ ','██████  ','     ██ ','███████ ',' ██████  ','   ██   ',' █████  ',' █████  ','    ','   ','██     ','██   ██ ','██      ','██      ██ '] ];

    // array Lookup to find digits above
    rowMap = {
        '0' : 1,
        '1' : 2,
        '2' : 3,
        '3' : 4,
        '4' : 5,
        '5' : 6,
        '6' : 7,
        '7' : 8,
        '8' : 9,
        '9' : 10,
        ' ' : 11,
        ':' : 12,
        '/' : 13,
        'A' : 14,
        'P' : 15,
        'M' : 16,
    }

}