package react

import ui "../../"
import "base:runtime"
import "core:c"


exit_app :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    ui.exit()
}

main :: proc() {

    // Create new windows
    react_window := ui.new_window()
    
    // Set window size
    ui.set_size(react_window, 550, 450)
    
    // Allow multi-user connection to WebUI window
    //ui.set_config(multi_client, true);
    
    // Disable WebUI's cookies
    //ui.set_config(use_cookies, false);
    
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


    // Set a custom files handler
    path_str: cstring = "/webui-react-example"
    new_verson: ^c.char = transmute(^c.char)path_str
    number: c.int = 30
    number_ptr: ^c.int = &number
    ui.set_file_handler(react_window, vfs(new_verson, number_ptr))
    
    // Show the React window
    // ui.show_browser(react_window, "index.html", Chrome);
    ui.show(react_window, "index.html");
    
    // Wait until all windows get closed
    ui.wait();
    
    // Free all memory resources (Optional)
    ui.clean()

}