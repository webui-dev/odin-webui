package webui

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:intrinsics"
import "core:strings"
import "core:time"

when ODIN_DEBUG {
	when ODIN_OS == .Windows {
		foreign import webui {"webui/debug/webui-2-static.lib", "system:Ws2_32.lib", "system:Ole32.lib", "system:Advapi32.lib", "system:User32.lib", "system:Shell32.lib"}
	} else {
		foreign import webui "webui/debug/libwebui-2-static.a"
	}
} else {
	when ODIN_OS == .Windows {
		foreign import webui {"webui/webui-2-static.lib", "system:Ws2_32.lib", "system:Ole32.lib", "system:Advapi32.lib", "system:User32.lib", "system:Shell32.lib"}
	} else {
		foreign import webui "webui/libwebui-2-static.a"
	}
}

Window :: c.size_t

Event :: struct {
	window:       Window,
	event_type:   EventType,
	element:      cstring,
	event_number: c.size_t,
	bind_id:      c.size_t,
}

Runtime :: enum {
	None,
	Deno,
	Node,
}

Browser :: enum {
	NoBrowser,
	AnyBrowser,
	Chrome,
	Firefox,
	Edge,
	Safari,
	Chromium,
	Opera,
	Brave,
	Vivaldi,
	Epic,
	Yandex,
	ChromiumBased,
}

EventType :: enum {
	Disconnected,
	Connected,
	MouseClick,
	Navigation,
	Callback,
}


// == WebUI C functions =======================================================


// -- Definitions --------------------- TODO:
@(link_prefix = "webui_")
foreign webui {
	// Create a new WebUI window object.
	new_window :: proc() -> Window ---
	// Create a new webui window object using a specified window number.
	new_window_id :: proc(id: c.size_t) -> Window ---
	// Bind a specific html element click event with a function. Empty element means all events.
	bind :: proc(win: Window, name: cstring, fn: proc "c" (e: ^Event)) -> c.size_t ---
	// Same as `webui_show()`. But using a specific web browser.
	show_browser :: proc(win: Window, content: cstring, browser: Browser) -> bool ---
	// Wait until all opened windows get closed.
	wait :: proc() ---
	// Close a specific window only. The window object will still exist.
	close :: proc(win: Window) -> bool ---
	// Close a specific window and free all memory resources.
	destroy :: proc(win: Window) ---
	// Close all open windows. `webui_wait()` will return (Break).
	exit :: proc() ---
	// Set the web-server root folder path for a specific window.
	set_root_folder :: proc(win: Window, path: cstring) -> bool ---
	// Set the web-server root folder path for all windows. Should be used
	set_default_root_folder :: proc(path: cstring) -> bool ---
	// Set a custom handler to serve files. TODO:
	// set_file_handler :: proc(win: Window, handler: rawptr) -> c.size_t ---
	// Check if the specified window is still running.
	is_shown :: proc(win: Window) -> bool ---
	// Set the maximum time in seconds to wait for the browser to start.
	set_timeout :: proc(second: c.size_t) ---
	// Set the default embedded HTML favicon.
	set_icon :: proc(win: Window, icon: cstring, icon_type: cstring) -> bool ---
	// Base64 encoding. Use this to safely send text based data to the UI. If
	encode :: proc(str: cstring) -> cstring ---
	// Base64 decoding. Use this to safely decode received Base64 text from
	decode :: proc(str: cstring) -> cstring ---
	// -- Last State --
	// Free all memory resources. Should be called only at the end.
	clean :: proc() ---
}
// The use of the private functions is simplified by their wrapper functions.
@(private)
foreign webui {
	// Show a window using embedded HTML, or a file. If the window is already open, it will be refreshed.
	@(link_name = "webui_show")
	webui_show :: proc(win: Window, content: cstring) -> bool ---
	// Navigate to a specific URL
	@(link_name = "webui_navigate")
	webui_navigate :: proc(win: Window, url: cstring) ---
}

// -- JavaScript ---------------------- DONE:
@(link_prefix = "webui_")
foreign webui {
	// Chose between Deno and Nodejs as runtime for .js and .ts files.
	set_runtime :: proc(win: Window, runtime: Runtime) ---
}
// The use of the private functions is simplified by their wrapper functions.
@(private)
@(link_prefix = "webui_")
foreign webui {
	@(link_name = "webui_run")
	// Run JavaScript without waiting for the response.
	webui_run :: proc(win: Window, script: cstring) ---
	@(link_name = "webui_script")
	// Run JavaScript and get the response back (Make sure your local buffer can hold the response).
	webui_script :: proc(win: Window, script: cstring, timeout: c.size_t, buffer: cstring, buffer_length: c.size_t) -> bool ---
	// Get an argument as integer at a specific index.
	get_int_at :: proc(e: ^Event, idx: c.size_t) -> i64 ---
	// Get an argument as string at a specific index.
	get_string_at :: proc(e: ^Event, idx: c.size_t) -> cstring ---
	// Get an argument as boolean at a specific index.
	get_bool_at :: proc(e: ^Event, idx: c.size_t) -> bool ---
	// Get the size in bytes of an argument at a specific index.
	get_size_at :: proc(e: ^Event, idx: c.size_t) -> c.size_t ---
	// Return the response to JavaScript as integer.
	return_int :: proc(e: ^Event, n: i64) ---
	// Return the response to JavaScript as string.
	return_string :: proc(e: ^Event, s: cstring) ---
	// Return the response to JavaScript as boolean.
	return_bool :: proc(e: ^Event, b: bool) ---
	// When using `webui_interface_bind()`, you may need this function to easily set your callback response.
	interface_set_response :: proc(win: Window, event_number: c.size_t, response: cstring) ---
}


// == Wrapper functions =======================================================


// Show a window using embedded HTML, or a file. If the window is already open, it will be refreshed.
show :: proc(win: Window, content: string, await: bool = false, timeout: uint = 10) -> bool {
	res := webui_show(win, strings.unsafe_string_to_cstring(content))
	if !res {
		return false
	}
	if await {
		for _ in 0 ..< timeout * 100 {
			if is_shown(win) {
				return true
			}
			// Slow down check interval to reduce load.
			time.sleep(10 * time.Millisecond)
		}
	}
	return false
}

// Navigate to a specific URL
navigate :: proc(win: Window, url: string) {
	webui_navigate(win, strings.unsafe_string_to_cstring(url))
}

Error :: enum {
	None,
	Failed,
}

// Run JavaScript without waiting for the response.
run :: proc(win: Window, script: string) {
	webui_run(win, strings.unsafe_string_to_cstring(script))
}

// Run JavaScript and get the response back (Make sure your local buffer can hold the response).
script :: proc "c" (
	win: Window,
	script: string,
	buffer_len: uint = 8 * 1024,
	timeout: uint = 0,
) -> (
	string,
	Error,
) {
	context = runtime.default_context()
	buf := make([^]byte, buffer_len)
	res := webui_script(
		win,
		strings.unsafe_string_to_cstring(script),
		timeout,
		cstring(buf),
		buffer_len,
	)
	str := fmt.tprintf("%s", buf)
	if !res {
		return str, .Failed
	}
	return str, .None
}

// Parse a JS argument as Odin data type.
get_arg :: proc($T: typeid, e: ^Event, idx: uint = 0) -> T {
	when intrinsics.type_is_numeric(T) {
		return auto_cast get_int_at(e, idx)
	} else when T == string {
		return string(get_string_at(e, idx))
	} else when T == bool {
		return get_bool_at(e, idx)
	}
	// TODO: unmarshal other types from JSON
	return {}
}

// Return the response to JavaScript.
result :: proc(e: ^Event, resp: $T) {
	when intrinsics.type_is_numeric(T) {
		return_int(e, auto_cast resp)
	} else when T == string {
		return_string(e, resp)
	} else when T == bool {
		return_bool(e, resp)
	}
	// TODO: marshal other types into JSON
}
