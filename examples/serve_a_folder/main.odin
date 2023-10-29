// This examples needs to be executed relative to the examples directory.
// E.g.: `cd examples/serve_a_folder` then `odin run .` NOT `odin run examples/serve_a_folder`.
package main

import ui "../../"
import "core:fmt"

w :: ui.Window(1)
w2 :: ui.Window(2)

// // This function gets called every time there is an event.
events :: proc(e: ^ui.Event) {
	if e.event_type == .Connected {
		fmt.println("Connected.")
	} else if e.event_type == .Disconnected {
		fmt.println("Disconnected.")
	} else if e.event_type == .MouseClick {
		fmt.println("Click.")
	} else if e.event_type == .Navigation {
		target := ui.get_arg(string, e)
		fmt.println("Starting navigation to:", target)
		ui.navigate(e.window, target)
	}
}

// Switch to `/second.html` in the same opened window.
switch_to_second_page :: proc(e: ^ui.Event) {
	ui.show(e.window, "second.html")
}

show_second_window :: proc(e: ^ui.Event) {
	ui.show(w2, "second.html", await = true)
	// Remove the Go Back button when showing the second page in another window.
	ui.run(w2, "document.getElementById('go-back').remove();")
}

close_window :: proc(e: ^ui.Event) {
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
