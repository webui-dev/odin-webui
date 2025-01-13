package main

import ui "../"
import "base:runtime"
import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:c"
import "core:c/libc"
import "core:os"
import "core:sys/posix"


MY_HTML :: `<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <script src="webui.js"></script>
    <title>Call JavaScript from C Example</title>
    <style>
       body {
            font-family: 'Arial', sans-serif;
            color: white;
            background: linear-gradient(to right, #507d91, #1c596f, #022737);
            text-align: center;
            font-size: 18px;
        }
       button, input {
            padding: 10px;
            margin: 10px;
            border-radius: 3px;
            border: 1px solid #ccc;
            box-shadow: 0 3px 5px rgba(0,0,0,0.1);
            transition: 0.2s;
        }
button {
           background: #3498db;
            color: #fff;
            cursor: pointer;
            font-size: 16px;
        }
       h1 { text-shadow: -7px 10px 7px rgb(67 57 57 / 76%); }
        button:hover { background: #c9913d; }
       input:focus { outline: none; border-color: #3498db; }
    </style>
  </head>
  <body>
    <h1>WebUI - Call JavaScript from C</h1>
    <br>
    <h1 id="count">0</h1>
    <br>
    <button OnClick="my_function_count();">Manual Count</button>
    <br>
   <button id="MyTest" OnClick="AutoTest();">Auto Count (Every 10ms)</button>
    <br>
    <button OnClick="my_function_exit();">Exit</button>
    <script>
      let count = 0;
      function GetCount() {
        return count;
      }
      function SetCount(number) {
        document.getElementById('count').innerHTML = number;
        count = number;
      }
     function AutoTest(number) {
       setInterval(function(){ my_function_count(); }, 10);
      }
    </script>
  </body>
</html>`


my_function_exit :: proc "c" (e: ^ui.Event) {
	context = runtime.default_context()
	ui.exit()
}


my_function_count :: proc "c" (e: ^ui.Event) {
	context = runtime.default_context()

	count, err := ui.script(e.window, "return GetCount();")
	if err != nil {
		if !ui.is_shown(e.window) {
			fmt.printf("Window closed.\n")
		} else {
			fmt.printf("javascript error %s\n", err)
		}
		return;
	}

	// Increment
	new_count := strconv.atoi(count) + 1

	// Run JavaScript (Quick Way)
	ui.run(e.window, fmt.aprintf("SetCount(%d);", new_count))
}

main :: proc() {
	// Create a new window.
	w := ui.new_window()

	// Bind Odin functions.
	ui.bind(w, cast(cstring)"my_function_count", my_function_count)
	ui.bind(w, cast(cstring)"my_function_exit", my_function_exit)


	// Show the HTML UI.
	ui.show_browser(w, MY_HTML, .AnyBrowser)

	// Wait until all windows get closed.
	ui.wait()
	ui.clean()
}
