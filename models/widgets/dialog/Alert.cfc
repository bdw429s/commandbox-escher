/**
 * I display an alert for the user which can be dismissed with enter or escape
 * Types are info, warn, error, and success.
 */
component extends='Dialog' accessors=true {

    function init( string message='', type='info', onSubmit=()=>{}, struct boxOptions={} ) {
        var colorMap = {
            'warn' : 'yellow',
            'error' : 'red',
            'success' : 'green'
        };

        boxOptions.borderColor = boxOptions.borderColor ?: colorMap[ type ] ?: 'blue';

        return super.init(
            message : message,
            label : type,
            buttons : [
				{
                    label : ' OK ',
                    selected : true,
					onSubmit : onSubmit
				}
            ],
            boxOptions : boxOptions
         );
    }

}