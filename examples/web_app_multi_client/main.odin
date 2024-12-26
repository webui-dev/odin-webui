package web_app_multi_client

import ui "../../"
import "base:runtime"
import "core:fmt"
import "core:c"
import "core:strings"


privateInput_arr := make(map[c.size_t]string)
publicInput_arr: [dynamic]string
users_count: uint = 0
tab_count: uint = 0


exit_app :: proc "c" (e: ^ui.EventType) {
    context = runtime.default_context()
    // Close all opened windows
    ui.exit()
}


save :: proc "c" (e: ^ui.EventType) {
    context = runtime.default_context()
    // Get input value
    privateInput, err := ui.get_arg(string, e)
    // Save it in the map
    privateInput_arr[e.client_id] = privateInput
}


saveAll :: proc "c" (e: ^ui.EventType) {
    context = runtime.default_context()
    // Get input value
    publicInput: string = string(ui.get_string(e))
    // Save it in the array
    append(&publicInput_arr, publicInput)
    // Update all users
    ui.run(e.window, fmt.aprintf("document.getElementById(\"publicInput\").value = \"%s\";", publicInput))
}


events :: proc "c" (e: ^ui.EventType) {
    context = runtime.default_context()
    // This function gets called every time
    // there is an event.

    // Full web browser cookies
    cookies: cstring = e.cookies

    // Static client (based on web browser cookes)
    client_id: c.size_t = e.client_id

    // Dynamic client connection ID (Changes on connect/disconnect events)
    connection_id: c.size_t = e.connection_id

    if e.event_type == cast(uint)ui.Event.WEBUI_EVENT_CONNECTED {
        // New connection
        if users_count < (e.client_id + 1) { // +1 because it start from 0
            users_count = (e.client_id + 1)
        }
        tab_count += 1
    } else if e.event_type == cast(uint)ui.Event.WEBUI_EVENT_DISCONNECTED {
        // Disconnection
        if tab_count > 0 {
            tab_count -= 1
        }
    }

    // Update this current user only

    // status
    ui.run_client(e, strings.unsafe_string_to_cstring("document.getElementById(\"status\").innerText = \"Connected!\";"))

    // userNumber
    ui.run_client(e, strings.unsafe_string_to_cstring(fmt.aprintf("document.getElementById(\"userNumber\").innerText = \"%d\";", client_id)))

    // connectionNumber
    ui.run_client(e, strings.unsafe_string_to_cstring(fmt.aprintf("document.getElementById(\"connectionNumber\").innerText = \"%d\";", connection_id)))

    // privateInput
    input_string: string = privateInput_arr[client_id]
    ui.run_client(e, strings.unsafe_string_to_cstring(fmt.aprintf("document.getElementById(\"privateInput\").value = \"%s\";", input_string)))

    // publicInput
    ui.run_client(e, strings.unsafe_string_to_cstring(fmt.aprintf("document.getElementById(\"publicInput\").value = \"%s\";", publicInput_arr)))


    // Update all connected users

    // userCount
    ui.run(e.window, fmt.aprintf("document.getElementById(\"userCount\").innerText = \"%d\";", users_count))

    // tabCount
    ui.run(e.window, fmt.aprintf("document.getElementById(\"tabCount\").innerText = \"%d\";", tab_count))
}


main :: proc() {

    // Allow multi-user connection
    ui.set_config(ui.Config.multi_client, true)

    // Allow cookies
    ui.set_config(ui.Config.use_cookies, true)

    // Create new window
    win: c.size_t = ui.new_window()

    // Bind HTML with a Odin functions
    ui.bind(win, "save", save)
    ui.bind(win, "saveAll", saveAll)
    ui.bind(win, "exit_app", exit_app)

    // Bind all events
    ui.bind(win, "", events)

    // Start server only
    url: cstring = ui.start_server(win, cstring("index.html"))

    // Open a new page in the default native web browser
    ui.open_url(url)

    // Wait until all windows get closed
    ui.wait()

    // Free all memory resources (Optional)
    ui.clean()
}
