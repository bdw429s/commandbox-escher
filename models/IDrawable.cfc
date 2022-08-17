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


}