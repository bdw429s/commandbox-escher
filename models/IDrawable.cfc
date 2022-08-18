/**
 * I am the interface you need to implement to create a drawable widget on the screen using the Painter
 * You can implement me directly, or extend the AbstractWidget
 */
interface {

    /**
     * @Returns true/false if widget is active
     */
    boolean function isActive();

    /**
     * Renders contents of UI widget
     *
     * @height max height of renderable space
     * @width max width of renderable space
     *
     * @Returns struct with following keys:
     * - lines - contains array of strings representing output
     * - cursorPosition - contains struct with row/col keys representing row/col of cursor starting from upper left
     */
    struct function render( required numeric height, required numeric width );

    /**
     * Start the widget.  This will fire the process() method in a thread and mark the widget as active.
     * You are responsible for also starting any composed widgets here
     */
    function start();

    /**
     * Stop the widget.  This will interrupt the process() method and mark the widget as inactive.
     * You are responsible for also stopping any composed widgets here
     */
    function stop();

    /**
     * An asynchronous method that will be called in its own thread when the widget is started.  This is where you update the internal state of
     * the widget so it's ready the next time the render() method is run.  This method may keep running as long as the widget is active, but
     * it should be interruptable so a while try/sleep is recommended if you want to periodically update the widgets state.
     * If this method is empty, the thread will simply exist immediatly, leaving the widget active.  In this case, you would need to
     * update the widget state from outside.
     */
    function process();

}