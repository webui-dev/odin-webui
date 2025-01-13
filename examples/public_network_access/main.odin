package public_network_access

import ui "../../"
import "core:c"
import "core:c/libc"
import "base:runtime"
import "core:fmt"

private_window: c.size_t
public_window: c.size_t


app_exit :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    ui.exit()
}


public_window_events :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    if e.event_type == ui.EventType.Connected {
        // New connection
        ui.run(private_window, "document.getElementById(\"Logs\").value += \"New connection.\\n\";")
    } else if e.event_type == ui.EventType.Disconnected {
        // Disconnection
        ui.run(private_window, "document.getElementById(\"Logs\").value += \"Disconnected.\\n\";")
    }

}


private_window_events :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    if e.event_type == ui.EventType.Connected {
        public_win_url: string = string(ui.get_url(public_window))
        ui.run(private_window, fmt.aprintf( "document.getElementById('urlSpan').innerHTML = '%s';", public_win_url))
    }
}

main :: proc() {
    // Main Private Window HTML
    PRIVATE_HTML ::
    `<!DOCTYPE html>
		<html>
		  <head>
		    <meta charset="UTF-8">
		    <script src="webui.js"></script>
		    <title>Public Network Access Example</title>
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
		    <h1>WebUI - Public Network Access Example</h1>
		    <br>
		    The second public window is configured to be accessible from <br>
		    any device in the public network. <br>
		    <br>
		    Second public window link: <br>
		    <h1 id="urlSpan" style="color:#c9913d">...</h1>
		    Second public window events: <br>
		    <textarea id="Logs" rows="4" cols="50" style="width:80%"></textarea>
		    <br>
		   <button id="Exit">Exit</button>
		  </body>
		</html>`


    // Public Window HTML
    PUBLIC_HTML ::
    `<!DOCTYPE html>
		<html>
		  <head>
		    <meta charset="UTF-8">
		    <script src="webui.js"></script>
		    <title>Welcome to Public UI</title>
		  </head>
		  <body>
		    <h1>Welcome to Public UI!</h1>
		  </body>
		</html>`


    // Create windows
    private_window = ui.new_window()
    public_window = ui.new_window()

    // App
    ui.set_timeout(0)  // Wait forever (never timeout)

    // Public Window
    ui.set_public(public_window, true)  // Make URL accessible from public networks
    ui.bind(public_window, "", public_window_events)  // Bind all events
    ui.show_browser(public_window, PUBLIC_HTML, .NoBrowser)  // Set public window HTML

    // Private Window
    ui.bind(private_window, "", private_window_events); // Run JS
    ui.bind(private_window, "Exit", app_exit); // Bind exit button
    ui.show(private_window, PRIVATE_HTML); // Show the window

    // Wait until all windows get closed
    ui.wait()

    // Free all memory resources (Optional)
    ui.clean()
}