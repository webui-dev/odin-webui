package webui

import "core:c"
import "core:intrinsics"
import "core:runtime"
when ODIN_DEBUG {
	foreign import webui "webui/debug/libwebui-2-static.a"
} else {
	foreign import webui "webui/libwebui-2-static.a"
}

Window :: c.size_t

Event :: struct {
	window:       Window,
	event_type:   c.size_t,
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

BindCallback :: proc(e: ^Event)

// -- Definitions --------------------- TODO:
@(link_prefix = "webui_")
foreign webui {
	// Create a new WebUI window object.
	new_window :: proc() -> Window ---
	// Bind a specific html element click event with a function. Empty element means all events.
	@(link_name = "webui_bind")
	webui_bind :: proc(win: Window, name: cstring, fn: BindCallback) -> c.size_t ---
	// Show a window using embedded HTML, or a file. If the window is already open, it will be refreshed.
	show :: proc(win: Window, content: cstring) -> bool ---
	// Same as `webui_show()`. But using a specific web browser.
	show_browser :: proc(win: Window, content: cstring, browser: Browser) -> bool ---
	// Wait until all opened windows get closed.
	wait :: proc() ---
	// Close a specific window and free all memory resources.
	destroy :: proc(win: Window) ---
	// Close all open windows. `webui_wait()` will return (Break).
	exit :: proc() ---
	// Free all memory resources. Should be called only at the end.
	clean :: proc() ---
}
// -- JavaScript ---------------------- DONE:
@(link_prefix = "webui_")
foreign webui {
	// Run JavaScript without waiting for the response.
	run :: proc(win: Window, script: cstring) ---
	// Run JavaScript and get the response back (Make sure your local buffer can hold the response).
	script :: proc(win: Window, script: cstring, timeout: c.size_t, buffer: cstring, buffer_length: c.size_t) -> bool ---
	// Chose between Deno and Nodejs as runtime for .js and .ts files.
	set_runtime :: proc(win: Window, runtime: Runtime) ---
}
// The use of the following functions is simplified by their wrapper functions below and therefore set to private.
@(private)
@(link_prefix = "webui_")
foreign webui {
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

// Bind a specific html element click event with a function. Empty element means all events.
bind :: proc(win: Window, name: cstring, fn: BindCallback) -> c.size_t {
	return webui_bind(win, name, fn)
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
