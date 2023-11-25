package main

import ui "../"
import "core:fmt"
import "core:strconv"
import "core:strings"

DOC :: `<!DOCTYPE html>
<html>
	<head>
		<title>Call JavaScript from V Example</title>
		<script src="webui.js"></script>
		<style>
			body {
				background: linear-gradient(to left, #36265a, #654da9);
				color: AliceBlue;
				font: 16px sans-serif;
				text-align: center;
				margin-top: 30px;
			}
			button {
				margin: 5px 0 10px;
			}
		</style>
	</head>
	<body>
		<h1>WebUI - Call JavaScript from V</h1>
		<br>
		<button id="increment-js">Count <span id="count">0</span></button>
		<br>
		<button id="exit">Exit</button>
		<script>
			let count = document.getElementById("count").innerHTML;
			function setCount(number) {
				document.getElementById("count").innerHTML = number;
				count = number;
			}
		</script>
	</body>
</html>`


increment_js :: proc(e: ^ui.Event) {
	count, err := ui.script(e.window, "return count;")
	if err != nil {
		return
	}
	new_count := strconv.atoi(count) + 1
	fmt.println(new_count)
	// TODO:
	// buf: [1]byte
	// new_count_str := strconv.itoa(buf[:], new_count)
	// script := strings.concatenate({"setCount(", new_count_str, ");"})
	// ui.run(e.window, script)
}

main :: proc() {
	// Create a new window.
	w := ui.new_window()

	// Bind odin functions.
	ui.bind(w, "increment-js", increment_js)
	// Bind to an ID with a click event.
	ui.bind(w, "exit", proc(_: ^ui.Event) {
		fmt.println("Bye!")
		ui.exit()
	})

	// Show the HTML UI.
	ui.show(w, DOC)

	// Wait until all windows get closed.
	ui.wait()
	// ui.clean()
}
