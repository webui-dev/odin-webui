package main

import ui "../"

main :: proc() {
	my_window: uint = ui.new_window()
	ui.show(my_window, "<html><script src=\"webui.js\"></script> Hello, World! </html>")
	ui.wait()
}
