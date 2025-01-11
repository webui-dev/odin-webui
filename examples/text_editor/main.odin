package text_editor

// Text Editor in Odin using WebUI

import ui "../../"
import "base:runtime"
import "core:fmt"
import "core:c"


close_app :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    fmt.printfln("Exit.")

    // Close all opened windows
    ui.exit()
}


main :: proc() {
    // Create a new window
    main_window: c.size_t = ui.new_window()

    // Set the root folder for the UI
    ui.set_root_folder(main_window, "ui")

    // Bind HTML elements with the specified ID to Odin functions
    ui.bind(main_window, "close_app", close_app)

    // Show the window, preferably in a chromium based browser
    if !ui.show_browser(main_window, "index.html", .AnyBrowser) {
        ui.show(main_window, "index.html")
    }

    // Wait until all windows get closed
    ui.wait()

    // Free all memory resources (Optional)
    ui.clean()
}