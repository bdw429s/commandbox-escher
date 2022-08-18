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

    function start();

    function stop();

    function process();

}