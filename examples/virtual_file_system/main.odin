package virtual_file_system

// Virtual File System Example

import ui "../../"
import "core:c"
import "base:runtime"


exit_app :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    ui.exit()
}

main :: proc() {
    // Create new windows
    MyWindow: c.size_t = ui.new_window()

    // Bind HTML element IDs with Odin functions
    ui.bind(MyWindow, "Exit", exit_app)

	//set the folder to create the virtual file system from.
	// does what the vfs.py does in the c/example
	build_virtual_file_system("./ui")

    // Set a custom files handler
    ui.set_file_handler(MyWindow, vfs)

    // Show a new window
    ui.show(MyWindow, "index.html")

    // Wait until all windows get closed
    ui.wait()

    // Free all memory resources (Optional)
    ui.clean()
}
