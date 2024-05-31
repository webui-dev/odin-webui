package main

import ui "../"

main :: proc() {
	w := ui.new_window()
	ui.show(w, "<html>Hellope</html>")
	ui.wait()
}
