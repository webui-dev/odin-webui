package main

import ui "../"

main :: proc() {
	w := ui.new_window()
	ui.show(w, "<html>Hello World</html>")
	ui.wait()
}
