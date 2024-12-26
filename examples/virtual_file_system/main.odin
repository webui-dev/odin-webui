package virtual_file_system

// Virtual File System Example

import ui "../../"
import "core:c"
import "base:runtime"


exit_app :: proc "c" (e: ^ui.EventType) {
    context = runtime.default_context()
    ui.exit()
}

main :: proc() {
    // build virtual file system
    get_all_files("ui")

    // Create new windows
    MyWindow: c.size_t = ui.new_window()

    // Bind HTML element IDs with a C functions
    ui.bind(MyWindow, "Exit", exit_app)

    // Set a custom files handler
    ui.set_file_handler(MyWindow, vfs)

    // Show a new window
    // webui_show_browser(MyWindow, "index.html", Chrome);
    ui.show(MyWindow, "index.html")

    // Wait until all windows get closed
    ui.wait()

    // Free all memory resources (Optional)
    ui.clean()


}
