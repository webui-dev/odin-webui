package main

import ui "../"
import "core:fmt"

DOC :: `<!DOCTYPE html>
<html>
	<head>
		<title>Call Odin from JavaScript Example</title>
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
		<h1>WebUI - Call Odin from JavaScript</h1>
		<br>
		<p>Call Odin functions with arguments (<em>See the logs in your terminal</em>)</p>
		<button onclick="webui.handleStr('Hello', 'World');">Call handleStr()</button>
		<br>
		<button onclick="webui.handleInt(123, 456, 789);">Call handleInt()</button>
		<br>
		<button onclick="webui.handleBool(true, false);">Call handleBool()</button>
		<br>
		<p>Call an Odin function that returns a response</p>
		<button onclick="getRespFromOdin();">Call getResponse()</button>
		<div>Double: <input type="text" id="my-input" value="2"></div>
		<script>
			async function getRespFromOdin() {
				const myInput = document.getElementById('my-input');
				const number = myInput.value;
				const resp = await webui.getResponse(number);
				myInput.value = resp;
			}
		</script>
	</body>
</html>`

// JavaScript: `webui.handleStr('Hello', 'World');`
handle_string :: proc(e: ^ui.Event) {
	str1 := ui.get_arg(string, e)
	str2 := ui.get_arg(string, e, 1)

	fmt.printf("handle_string 1: %s\n", str1) // Hello
	fmt.printf("handle_string 2: %s\n", str2) // World
}

// JavaScript: `webui.handleInt(123, 456, 789);`
handle_int :: proc(e: ^ui.Event) {
	num1 := ui.get_arg(int, e)
	num2 := ui.get_arg(int, e, 1)
	num3 := ui.get_arg(int, e, 2)

	fmt.printf("handle_int 1: %d\n", num1) // 123
	fmt.printf("handle_int 2: %d\n", num2) // 456
	fmt.printf("handle_int 3: %d\n", num3) // 789
}

// JavaScript: webui.handleBool(true, false);
handle_bool :: proc(e: ^ui.Event) {
	status1 := ui.get_arg(bool, e)
	status2 := ui.get_arg(bool, e, 1)

	fmt.printf("handle_bool 1: %t\n", status1) // true
	fmt.printf("handle_bool 2: %t\n", status2) // false
}

// JavaScript: `const result = await webui.getResponse(number);`
get_response :: proc(e: ^ui.Event) {
	num := ui.get_arg(int, e)

	resp := num * 2
	fmt.printf("handle_response: %d\n", resp)

	ui.result(e, resp)
}

main :: proc() {
	// Create a new window.
	w := ui.new_window()
	defer ui.clean()

	// Bind Odin functions.
	ui.bind(w, "handleStr", handle_string)
	ui.bind(w, "handleInt", handle_int)
	ui.bind(w, "handleBool", handle_bool)
	ui.bind(w, "getResponse", get_response)

	// Show the HTML UI.
	ui.show(w, DOC)

	// Wait until all windows get closed.
	ui.wait()
}
