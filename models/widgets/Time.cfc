component extends='escher.models.AbstractWidget' {
    processingdirective pageEncoding='UTF-8';

    struct function render( required numeric height, required numeric width ) {
        var dateTime = dateTimeFormat( now(), 'mm/dd/yyyy hh:nn:ss tt' ).listtoArray( '' );
        setLines(
            [
                dateTime.map( (c)=>rows[1][ rowMap[c] ] ).toList( '' ),
                dateTime.map( (c)=>rows[2][ rowMap[c] ] ).toList( '' ),
                dateTime.map( (c)=>rows[3][ rowMap[c] ] ).toList( '' ),
                dateTime.map( (c)=>rows[4][ rowMap[c] ] ).toList( '' ),
                dateTime.map( (c)=>rows[5][ rowMap[c] ] ).toList( '' )
            ]
        );

        return super.render( argumentCollection=arguments );
    }

    rows = [[' ██████  ',' ██ ','██████  ','██████  ','██   ██ ','███████ ',' ██████  ','███████ ',' █████  ',' █████  ','    ','   ','    ██ ',' █████  ','██████  ','███    ███ '],
            ['██  ████ ','███ ','     ██ ','     ██ ','██   ██ ','██      ','██       ','     ██ ','██   ██ ','██   ██ ','    ','██ ','   ██  ','██   ██ ','██   ██ ','████  ████ '],
            ['██ ██ ██ ',' ██ ',' █████  ',' █████  ','███████ ','███████ ','███████  ','    ██  ',' █████  ',' ██████ ','    ','   ','  ██   ','███████ ','██████  ','██ ████ ██ '],
            ['████  ██ ',' ██ ','██      ','     ██ ','     ██ ','     ██ ','██    ██ ','   ██   ','██   ██ ','     ██ ','    ','██ ',' ██    ','██   ██ ','██      ','██  ██  ██ '],
            [' ██████  ',' ██ ','███████ ','██████  ','     ██ ','███████ ',' ██████  ','   ██   ',' █████  ',' █████  ','    ','   ','██     ','██   ██ ','██      ','██      ██ '] ];

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