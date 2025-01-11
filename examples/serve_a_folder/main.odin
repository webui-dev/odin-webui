// This examples needs to be executed relative to the examples directory.
// E.g.: `cd examples/serve_a_folder` then `odin run .` NOT `odin run examples/serve_a_folder`.
package main

import ui "../../"
import "base:runtime"
import "core:fmt"
import "core:c"

w : c.size_t : 1
w2 : c.size_t : 2

// // This function gets called every time there is an event.
events :: proc "c" (e: ^ui.Event) {
	context = runtime.default_context()

	switch e.event_type {
		case .Connected:
			fmt.println("Connected.")
		case .Disconnected:
			fmt.println("Disconnected.")
		case .MouseClick:
			fmt.println("Click.")
		case .Navigation:
			target, _ := ui.get_arg(string, e)
			fmt.println("Starting navigation to:", target)
			ui.navigate(e.window, target)
		case .Callback:
			fmt.println("Callback")
	}
}

// Switch to `/second.html` in the same opened window.
switch_to_second_page :: proc "c" (e: ^ui.Event) {
	context = runtime.default_context()
	ui.show(e.window, "second.html")
}

show_second_window :: proc "c" (e: ^ui.Event) {
	context = runtime.default_context()
	ui.show(w2, "second.html", await = true)
	// Remove the Go Back button when showing the second page in another window.
	ui.run(w2, "document.getElementById('go-back').remove();")
}

close_window :: proc "c" (e: ^ui.Event) {
	context = runtime.default_context()
	ui.close(e.window)
}

main :: proc() {
	// Set the root folder for the UI.
	ui.set_default_root_folder("ui")

	// Prepare the main window.
	ui.new_window_id(w)

	// Bind HTML elements to functions.
	ui.bind(w, "switch-to-second-page", switch_to_second_page)
	ui.bind(w, "open-new-window", show_second_window)
	ui.bind(w, "exit", close_window)
	ui.bind(w, "", events) // Bind all events.

	// Show the main window.
	ui.show(w, "index.html")

	// Prepare the second window.
	ui.new_window_id(w2)
	ui.bind(w2, "exit", close_window)

	// Wait until all windows get closed.
	ui.wait()
	ui.clean()
}
