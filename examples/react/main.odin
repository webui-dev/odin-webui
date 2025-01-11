package react

import ui "../../"
import "base:runtime"
import "core:c"


exit_app :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    ui.exit()
}

// use the build_react.bat/.sh file to build npm files and create the odin executable in one go.
main :: proc() {
    // Create new windows
    react_window := ui.new_window()

    // Set window size
    ui.set_size(react_window, 1920, 1080)

    // Allow multi-user connection to WebUI window
    ui.set_config(ui.Config.multi_client, true)

    // Disable WebUI's cookies
    ui.set_config(ui.Config.use_cookies, false)

    // Bind React HTML element IDs with a C functions
    ui.bind(react_window, "Exit", exit_app)

    // VSF (Virtual File System) Example
    //
    // 1. Make sure to run the `build_virtual_file_system()`
    //    function and include a string path to the npm files
    //    build directory.
    //
    // 2. use vfs in your custom files handler `ui.set_file_handler()`
    //    ui.set_file_handler(react_window, vfs)
    build_virtual_file_system("./webui-react-example/build")

    // Set a custom files handler
    ui.set_file_handler(react_window, vfs)

    // Show the React window
    ui.show_browser(react_window, "index.html", .AnyBrowser)

    // Wait until all windows get closed
    ui.wait()

    // Free all memory resources (Optional)
    ui.clean()
}
