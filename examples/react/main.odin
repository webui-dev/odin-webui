package react

import ui "../../"
import "base:runtime"
import "core:c"


exit_app :: proc "c" (e: ^ui.EventType) {
    context = runtime.default_context()
    ui.exit()
}

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
    // 1. Run Python script to generate header file of a folder
    //    python vfs.py "/path/to/folder" "vfs.h"
    //
    // 2. Include header file in your C project
    //    #include "vfs.h"
    //
    // 3. use vfs in your custom files handler `ui.set_file_handler()`
    //    ui.set_file_handler(react_window, vfs);

    build_virtual_file_system(".\\webui-react-example\\build")


    // Set a custom files handler
    ui.set_file_handler(react_window, vfs)
    
    // Show the React window
    // ui.show_browser(react_window, "index.html", Chrome);
    ui.show_browser(react_window, "index.html", cast(uint)ui.Browser.Firefox)
    
    // Wait until all windows get closed
    ui.wait()
    
    // Free all memory resources (Optional)
    ui.clean()

}