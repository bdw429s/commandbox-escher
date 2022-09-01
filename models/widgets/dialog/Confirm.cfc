/**
 * I show a yes/no confirmation to the user. Options can be selected with left, right, tab, shift tab, Y, and N
 * Press enter to submit
 */
component extends='Dialog' accessors=true {
    // This is here so you can get the response back out of the widget instance after the user closes it if you don't have an onSubmit registered
    property name='response' type='boolean' default=true;

    function putResponse( required boolean response ) {
        variables.response = arguments.response;
        return arguments.response;
    }

    function init( string message='', onSubmit=()=>{}, label='', struct boxOptions={} ) {
        boxOptions.borderColor = boxOptions.borderColor ?: 'blue';

        return super.init(
            message : message,
            label : label,
            buttons : [
				{
                    label : ' Yes ',
                    selected : true,
					onSubmit : (dialog)=>onSubmit( putResponse( true ), dialog )
				},
				{
                    label : ' No ',
					onSubmit : (dialog)=>onSubmit( putResponse( false ), dialog )
				}
            ],
            boxOptions : boxOptions
         );
    }

}