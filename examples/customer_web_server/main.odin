package customer_web_server

// Serve a Folder Example

import "core:fmt"
import ui "../../"
import "base:runtime"
import "core:c"


events :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()

    switch e.event_type {
    case .Connected:
        fmt.printfln("\nConnected. \n")
    case .Disconnected:
        fmt.printfln("\nDisconnected. \n")
    case .MouseClick:
        fmt.printfln("\nClick. \n")
    case .Navigation:
        url: cstring = ui.get_string(e)
        fmt.printfln("\nStarting navigation to: %s \n", string(url))

        // Because we used `bind(MyWindow, "", events)`
        // WebUI will block all `href` link clicks and send here instead.
        // We can then control the behaviour of links as needed.
        ui.webui_navigate(e.window, url)
    case .Callback:
        fmt.println("Callback")
    }
}


my_backend_func :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()

    // JavaScript
    // my_backend_func(123, 456, 789);
    // or webui.my_backend_func(...);

    number_1: i64 = ui.get_int_at(e, 0)
    number_2: i64 = ui.get_int_at(e, 1)
    number_3: i64 = ui.get_int_at(e, 2)

    fmt.printfln("my_backend_func 1: %d\n", number_1) // 123
    fmt.printfln("my_backend_func 2: %d\n", number_2) // 456
    fmt.printfln("my_backend_func 3: %d\n", number_3) // 789
}


main :: proc() {
    // Create new windows
    window: c.size_t = ui.new_window()

    // Bind all events
    ui.bind(window, "", events)

    // Bind HTML elements with Odin functions
    ui.bind(window, "my_backend_func", my_backend_func)

    // Set the web-server/WebSocket port that WebUI should
    // use. This means `webui.js` will be available at:
    // http://localhost:MY_PORT_NUMBER/webui.js
    ui.set_port(window, 8081)

    // Show a new window and show our custom web server
    // Assuming the custom web server is running on port
    // 8080...
    ui.show(window, "http://localhost:8080/")

    // Wait until all windows get closed
    ui.wait()

    // Free all memory resources (Optional)
    ui.clean()
}


