package webui

import "base:intrinsics"
import "base:runtime"
import "core:c"
import "core:encoding/json"
import "core:fmt"
import "core:strings"
import "core:time"

when ODIN_OS == .Windows {
	when ODIN_DEBUG {
		foreign import webui {"webui/debug/webui-2-static.lib", "system:Ws2_32.lib", "system:Ole32.lib", "system:Advapi32.lib", "system:User32.lib", "system:Shell32.lib"}} else {
		foreign import webui {"webui/webui-2-static.lib", "system:Ws2_32.lib", "system:Ole32.lib", "system:Advapi32.lib", "system:User32.lib", "system:Shell32.lib"}
	}
} else when ODIN_OS == .Darwin {
	when ODIN_DEBUG {
		@(extra_linker_flags = "-framework Cocoa -framework WebKit")
		foreign import webui "webui/debug/libwebui-2-static.a"} else {
		@(extra_linker_flags = "-framework Cocoa -framework WebKit")
		foreign import webui "webui/libwebui-2-static.a"}
} else {
	when ODIN_DEBUG {
		foreign import webui "webui/debug/libwebui-2-static.a"} else {
		foreign import webui "webui/libwebui-2-static.a"}
}


// == WebUI C Enums ===========================================================


// C-version: webui_browser
Browser :: enum {
	NoBrowser,  	// 0. No web browser
	AnyBrowser, 	// 1. Default recommended web browser
	Chrome,         // 2. Google Chrome
	Firefox,        // 3. Mozilla Firefox
	Edge,           // 4. Microsoft Edge
	Safari,         // 5. Apple Safari
	Chromium,       // 6. The Chromium Project
	Opera,          // 7. Opera Browser
	Brave,          // 8. The Brave Browser
	Vivaldi,        // 9. The Vivaldi Browser
	Epic,           // 10. The Epic Browser
	Yandex,         // 11. The Yandex Browser
	ChromiumBased,  // 12. Any Chromium based browser
	Webview,        // 13. WebView (Non-web-browser)
}


// C-version: webui_runtime
WebuiJSRuntime :: enum {
	None, 		// 0. Prevent WebUI from using any runtime for .js and .ts files
	Deno,     	// 1. Use Deno runtime for .js and .ts files
	NodeJS,   	// 2. Use Nodejs runtime for .js files
	Bun,      	// 3. Use Bun runtime for .js and .ts files
}


// C-version: webui_event
EventType :: enum {
	Disconnected, 		// 0. Window disconnection event
	Connected,        	// 1. Window connection event
	MouseClick,      	// 2. Mouse click event
	Navigation,       	// 3. Window navigation event
	Callback,         	// 4. Function call event
}


// C-version: webui_config
Config :: enum {
	// Control if `webui_show()`, `webui_show_browser()` and
	// `webui_show_wv()` should wait for the window to connect
	// before returns or not.
	//
	// Default: True
	show_wait_connection,
	// Control if WebUI should block and process the UI events
	// one a time in a single thread `True`, or process every
	// event in a new non-blocking thread `False`. This updates
	// all windows. You can use `webui_set_event_blocking()` for
	// a specific single window update.
	//
	// Default: False
	ui_event_blocking,
	// Automatically refresh the window UI when any file in the
	// root folder gets changed.
	//
	// Default: False
	folder_monitor,
	// Allow multiple clients to connect to the same window,
	// This is helpful for web apps (non-desktop software),
	// Please see the documentation for more details.
	//
	// Default: False
	multi_client,
	// Allow or prevent WebUI from adding `webui_auth` cookies.
	// WebUI uses these cookies to identify clients and block
	// unauthorized access to the window content using a URL.
	// Please keep this option to `True` if you want only a single
	// client to access the window content.
	//
	// Default: True
	use_cookies,
	// If the backend uses asynchronous operations, set this
	// option to `True`. This will make webui wait until the
	// backend sets a response using `webui_return_x()`.
	asynchronous_response
}


// == WebUI C Structs =========================================================


// C-version: webui_event_t
Event :: struct {
	window: c.size_t,
	event_type: EventType,
	element: cstring,
	event_number: c.size_t,
	bind_id: c.size_t,
	client_id: c.size_t,
	connection_id: c.size_t,
	cookies: cstring,
}


// == WebUI C functions =======================================================


// == Definitions =============================================================
foreign webui {
	/**
	 * @brief Create a new WebUI window object.
	 *
	 * @return Returns the window number.
	 *
	 * @example myWindow: c.size_t = ui.new_window()
	 */
	@(link_name="webui_new_window")
	new_window :: proc() -> c.size_t ---

	/**
	 * @brief Create a new webui window object using a specified window number.
	 *
	 * @param window_number The window number (should be > 0, and < WEBUI_MAX_IDS)
	 *
	 * @return Returns the same window number if success.
	 *
	 * @example myWindow: c.size_t = ui.new_window_id(123)
	 */
	@(link_name="webui_new_window_id")
	new_window_id :: proc(window_number: c.size_t ) -> c.size_t ---

	/**
	 * @brief Get a free window number that can be used with
	 * `webui_new_window_id()`.
	 *
	 * @return Returns the first available free window number. Starting from 1.
	 *
	 * @example myWindowNumber: c.size_t = ui.get_new_window_id()
	 */
	@(link_name="webui_get_new_window_id")
	get_new_window_id :: proc() -> c.size_t ---

	/**
	 * @brief Bind an HTML element and a JavaScript object with a backend function. Empty
	 * element name means all events.
	 *
	 * @param window The window number
	 * @param element The HTML element / JavaScript object
	 * @param func The callback function
	 *
	 * @return Returns a unique bind ID.
	 *
	 * @example ui.bind(myWindow, "myFunction", myFunction)
	 */
	@(link_name="webui_bind")
	bind :: proc(window: c.size_t, element: cstring, func: proc(e: ^Event)) -> c.size_t ---

	/**
	 * @brief Get the recommended web browser ID to use. If you
	 * are already using one, this function will return the same ID.
	 *
	 * @param window The window number
	 *
	 * @return Returns a web browser ID.
	 *
	 * @example browserID: c.size_t = ui.get_best_browser(myWindow)
	 */
	@(link_name="webui_get_best_browser")
	get_best_browser :: proc(window: c.size_t) -> c.size_t ---

	/**
	 * @brief Show a window using embedded HTML, or a file. If the window is already
	 * open, it will be refreshed. This will refresh all windows in multi-client mode.
	 *
	 * @param window The window number
	 * @param content The HTML, URL, Or a local file
	 *
	 * @return Returns True if showing the window is successed.
	 *
	 * @example ui.show(myWindow, "<html>...</html>") |
	 * ui.show(myWindow, "index.html") | ui.show(myWindow, "http://...")
	 */
	@(link_name="webui_show")
	webui_show :: proc(window: c.size_t, content: cstring) -> c.bool ---

	/**
	 * @brief Show a window using embedded HTML, or a file. If the window is already
	 * open, it will be refreshed. Single client.
	 *
	 * @param e The event struct
	 * @param content The HTML, URL, Or a local file
	 *
	 * @return Returns True if showing the window is successed.
	 *
	 * @example ui.show_client(e, "<html>...</html>") |
	 * ui.show_client(e, "index.html") | ui.show_client(e, "http://...")
	 */
	@(link_name="webui_show_client")
	show_client :: proc(e: ^Event, content: cstring) -> c.bool ---

	/**
	 * @brief Same as `show()`. But using a specific web browser.
	 *
	 * @param window The window number
	 * @param content The HTML, Or a local file
	 * @param browser The web browser to be used
	 *
	 * @return Returns True if showing the window is successed.
	 *
	 * @example ui.show_browser(myWindow, "<html>...</html>", .Chrome) |
	 * ui.show(myWindow, "index.html", .Firefox)
	 */
	@(link_name="webui_show_browser")
	show_browser :: proc(window: c.size_t, content: cstring, browser: Browser) -> c.bool ---

	/**
	 * @brief Same as `show()`. But start only the web server and return the URL.
	 * No window will be shown.
	 *
	 * @param window The window number
	 * @param content The HTML, Or a local file
	 *
	 * @return Returns the url of this window server.
	 *
	 * @example url: cstring = ui.start_server(myWindow, "/full/root/path")
	 */
	@(link_name="webui_start_server")
	start_server:: proc(window: c.size_t, content: cstring) -> cstring ---

	/**
	 * @brief Show a WebView window using embedded HTML, or a file. If the window is already
	 * open, it will be refreshed. Note: Win32 need `WebView2Loader.dll`.
	 *
	 * @param window The window number
	 * @param content The HTML, URL, Or a local file
	 *
	 * @return Returns True if showing the WebView window is successed.
	 *
	 * @example ui.show_wv(myWindow, "<html>...</html>") | webui_show_wv(myWindow,
	 * "index.html") | ui.show_wv(myWindow, "http://...")
	 */
	@(link_name="webui_show_wv")
	show_wv :: proc(window: c.size_t, content: cstring) -> c.bool ---

	/**
	 * @brief Set the window in Kiosk mode (Full screen).
	 *
	 * @param window The window number
	 * @param status True or False
	 *
	 * @example ui.set_kiosk(myWindow, true)
	 */
	@(link_name="webui_set_kisok")
	set_kiosk :: proc(window: c.size_t, status: c.bool) ---

	/**
	 * @brief Add a user-defined web browser's CLI parameters.
	 *
	 * @param window The window number
	 * @param params Command line parameters
	 *
	 * @example ui.set_custom_parameters(myWindow, "--remote-debugging-port=9222")
	 */
	@(link_name="webui_set_custom_parameters")
	set_custom_parameters :: proc(window: c.size_t, params: cstring) ---

	/**
	 * @brief Set the window with high-contrast support. Useful when you want to
	 * build a better high-contrast theme with CSS.
	 *
	 * @param window The window number
	 * @param status True or False
	 *
	 * @example ui.set_high_contrast(myWindow, true)
	 */
	@(link_name="webui_set_high_contrast")
	set_high_contrast :: proc(window: c.size_t, status: c.bool) ---

	/**
	 * @brief Get OS high contrast preference.
	 *
	 * @return Returns True if OS is using high contrast theme
	 *
	 * @example hc: bool = ui.is_high_contrast()
	 */
	@(link_name="webui_is_high_contrast")
	is_high_contrast :: proc() -> c.bool ---

	/**
	 * @brief Check if a web browser is installed.
	 *
	 * @return Returns True if the specified browser is available
	 *
	 * @example status: bool = ui.browser_exist(.Chrome)
	 */
	@(link_name="webui_browser_exist")
	browser_exist :: proc(browser: Browser) -> c.bool ---

	/**
	 * @brief Wait until all opened windows get closed.
	 *
	 * @example ui.wait()
	 */
	@(link_name="webui_wait")
	wait :: proc() ---

	/**
	 * @brief Close a specific window only. The window object will still exist.
	 * All clients.
	 *
	 * @param window The window number
	 *
	 * @example ui.close(myWindow)
	 */
	@(link_name="webui_close")
	close :: proc(window: c.size_t) ---

	/**
	 * @brief Close a specific client.
	 *
	 * @param e The event struct
	 *
	 * @example ui.close_client(e)
	 */
	@(link_name="webui_close_client")
	close_client :: proc(e: ^Event) ---

	/**
	 * @brief Close a specific window and free all memory resources.
	 *
	 * @param window The window number
	 *
	 * @example ui.destroy(myWindow)
	 */
	@(link_name="webui_destroy")
	destroy :: proc(window: c.size_t) ---

	/**
	 * @brief Close all open windows. `webui_wait()` will return (Break).
	 *
	 * @example ui.exit()
	 */
	@(link_name="webui_exit")
	exit :: proc() ---

	/**
	 * @brief Set the web-server root folder path for a specific window.
	 *
	 * @param window The window number
	 * @param path The local folder full path
	 *
	 * @example ui.set_root_folder(myWindow, "/home/Foo/Bar/")
	 */
	@(link_name="webui_set_root_folder")
	set_root_folder :: proc(window: c.size_t, path: cstring) -> c.bool ---

	/**
	 * @brief Set the web-server root folder path for all windows. Should be used
	 * before `show()`.
	 *
	 * @param path The local folder full path
	 *
	 * @example ui.set_default_root_folder("/home/Foo/Bar/")
	 */
	@(link_name="webui_set_default_root_folder")
	set_default_root_folder :: proc(path: cstring) -> c.bool ---

	/**
	 * @brief Set a custom handler to serve files. This custom handler should
	 * return full HTTP header and body.
	 * This deactivates any previous handler set with `set_file_handler_window`
	 *
	 * @param window The window number
	 * @param handler The handler function: `handler: proc(filename: cstring,
	 * length: ^c.int) -> rawptr`
	 *
	 * @example ui.set_file_handler(myWindow, myHandlerFunction)
	 */
	@(link_name="webui_set_file_handler")
	set_file_handler :: proc(window: c.size_t, handler: proc(filename: cstring, length: ^c.int) -> rawptr) ---

	/**
	 * @brief Set a custom handler to serve files. This custom handler should
	 * return full HTTP header and body.
	 * This deactivates any previous handler set with `set_file_handler`
	 *
	 * @param window The window number
	 * @param handler The handler function: `handler: proc(window: c.size_t, filename: cstring,
	 * length: ^c.int) -> rawptr`
	 *
	 * @example ui.set_file_handler_window(myWindow, myHandlerFunction)
	 */
	@(link_name="webui_set_file_handler_window")
	set_file_handler_window :: proc(window: c.size_t, handler: proc(window: c.size_t, filename: cstring, length: ^c.int) -> rawptr) ---


	/**
	 * @brief Check if the specified window is still running.
	 *
	 * @param window The window number
	 *
	 * @example ui.is_shown(myWindow)
	 */
	@(link_name="webui_is_shown")
	is_shown :: proc(window: c.size_t) -> c.bool ---

	/**
	 * @brief Set the maximum time in seconds to wait for the window to connect.
	 * This effect `show()` and `wait()`. Value of `0` means wait forever.
	 *
	 * @param second The timeout in seconds
	 *
	 * @example ui.set_timeout(30)
	 */
	@(link_name="webui_set_timeout")
	set_timeout :: proc(second: c.size_t) ---

	/**
	 * @brief Set the default embedded HTML favicon.
	 *
	 * @param window The window number
	 * @param icon The icon as string: `<svg>...</svg>`
	 * @param icon_type The icon type: `image/svg+xml`
	 *
	 * @example ui.set_icon(myWindow, "<svg>...</svg>", "image/svg+xml")
	 */
	@(link_name="webui_set_icon")
	set_icon :: proc(window: c.size_t, icon: cstring, icon_type: cstring) ---

	/**
	 * @brief Encode text to Base64. The returned buffer need to be freed.
	 *
	 * @param str The string to encode (Should be null terminated)
	 *
	 * @return Returns the base64 encoded string
	 *
	 * @example base64: cstring = ui.encode("Foo Bar")
	 */
	@(link_name="webui_encode")
	encode :: proc(str: cstring) -> cstring ---

	/**
	 * @brief Decode a Base64 encoded text. The returned buffer need to be freed.
	 *
	 * @param str The string to decode (Should be null terminated)
	 *
	 * @return Returns the base64 decoded string
	 *
	 * @example str: cstring = ui.decode("SGVsbG8=")
	 */
	@(link_name="webui_decode")
	decode :: proc(str: cstring) -> cstring ---

	/**
	 * @brief Safely free a buffer allocated by WebUI using `malloc()`.
	 *
	 * @param ptr The buffer to be freed
	 *
	 * @example ui.free(myBuffer)
	 */
	@(link_name="webui_free")
	free :: proc(ptr: rawptr) ---

	/**
	 * @brief Safely allocate memory using the WebUI memory management system. It
	 * can be safely freed using `free()` at any time.
	 *
	 * @param size The size of memory in bytes
	 *
	 * @example myBuffer := cast(^u8)malloc(1024)
	 */
	@(link_name="webui_malloc")
	malloc :: proc(size: c.size_t) -> rawptr ---

	/**
	 * @brief Safely send raw data to the UI. All clients.
	 *
	 * @param window The window number
	 * @param function The JavaScript function to receive raw data: `function
	 * myFunc(myData){}`
	 * @param raw The raw data buffer
	 * @param size The raw data size in bytes
	 *
	 * @example ui.send_raw(myWindow, "myJavaScriptFunc", myBuffer, 64)
	 */
	@(link_name="webui_send_raw")
	send_raw :: proc(window: c.size_t, function: cstring, raw: rawptr, size: c.size_t) ---

	/**
	 * @brief Safely send raw data to the UI. Single client.
	 *
	 * @param e The event struct
	 * @param function The JavaScript function to receive raw data: `function
	 * myFunc(myData){}`
	 * @param raw The raw data buffer
	 * @param size The raw data size in bytes
	 *
	 * @example ui.send_raw_client(e, "myJavaScriptFunc", myBuffer, 64)
	 */
	@(link_name="webui_send_raw_client")
	send_raw_client :: proc(e: ^Event, function: cstring, raw: rawptr, size: c.size_t) ---

	/**
	 * @brief Set a window in hidden mode. Should be called before `webui_show()`.
	 *
	 * @param window The window number
	 * @param status The status: True or False
	 *
	 * @example ui.set_hide(myWindow, true)
	 */
	@(link_name="webui_set_hide")
	set_hide :: proc(window: c.size_t, status: c.bool) ---

	/**
	 * @brief Set the window size.
	 *
	 * @param window The window number
	 * @param width The window width
	 * @param height The window height
	 *
	 * @example ui.set_size(myWindow, 800, 600)
	 */
	@(link_name="webui_set_size")
	set_size :: proc(window: c.size_t, width: c.uint, height: c.uint) ---

	/**
	 * @brief Set the window minimum size.
	 *
	 * @param window The window number
	 * @param width The window width
	 * @param height The window height
	 *
	 * @example ui.set_minimum_size(myWindow, 800, 600)
	 */
	@(link_name="webui_set_minimum_size")
	set_minimum_size :: proc(window: c.size_t, width: c.uint, height: c.uint) ---

	/**
	 * @brief Set the window position.
	 *
	 * @param window The window number
	 * @param x The window X
	 * @param y The window Y
	 *
	 * @example ui.set_position(myWindow, 100, 100)
	 */
	@(link_name="webui_set_position")
	set_position :: proc(window: c.size_t, x: c.uint, y: c.uint) ---

	/**
	 * @brief Set the web browser profile to use. An empty `name` and `path` means
	 * the default user profile. Need to be called before `show()`.
	 *
	 * @param window The window number
	 * @param name The web browser profile name
	 * @param path The web browser profile full path
	 *
	 * @example ui.set_profile(myWindow, "Bar", "/Home/Foo/Bar") |
	 * ui.set_profile(myWindow, "", "")
	 */
	@(link_name="webui_set_profile")
	set_profile :: proc(window: c.size_t, name: cstring, path: cstring) ---

	/**
	 * @brief Set the web browser proxy server to use. Need to be called before `show()`.
	 *
	 * @param window The window number
	 * @param proxy_server The web browser proxy_server
	 *
	 * @example ui.set_proxy(myWindow, "http://127.0.0.1:8888")
	 */
	@(link_name="webui_set_proxy")
	set_proxy :: proc(window: c.size_t, proxy_server: cstring) ---

	/**
	 * @brief Get current URL of a running window.
	 *
	 * @param window The window number
	 *
	 * @return Returns the full URL string
	 *
	 * @example url: cstring = ui.get_url(myWindow)
	 */
	@(link_name="webui_get_url")
	get_url :: proc(window: c.size_t) -> cstring ---

	/**
	 * @brief Open an URL in the native default web browser.
	 *
	 * @param url The URL to open
	 *
	 * @example ui.open_url("https://webui.me")
	 */
	@(link_name="webui_open_url")
	open_url :: proc(url: cstring) ---

	/**
	 * @brief Allow a specific window address to be accessible from a public network.
	 *
	 * @param window The window number
	 * @param status True or False
	 *
	 * @example ui.set_public(myWindow, true)
	 */
	@(link_name="webui_set_public")
	set_public :: proc(window: c.size_t, status: c.bool) ---

	/**
	 * @brief Navigate to a specific URL. All clients.
	 *
	 * @param window The window number
	 * @param url Full HTTP URL
	 *
	 * @example ui.navigate(myWindow, "http://domain.com")
	 */
	@(link_name="webui_navigate")
	webui_navigate :: proc(window: c.size_t, url: cstring) ---

	/**
	 * @brief Navigate to a specific URL. Single client.
	 *
	 * @param e The event struct
	 * @param url Full HTTP URL
	 *
	 * @example ui.navigate_client(e, "http://domain.com")
	 */
	@(link_name="webui_navigate_client")
	navigate_client :: proc(e: ^Event, url: cstring) ---

	/**
	 * @brief Free all memory resources. Should be called only at the end.
	 *
	 * @example
	 * ui.wait()
	 * ui.clean()
	 */
	@(link_name="webui_clean")
	clean :: proc() ---

	/**
	 * @brief Delete all local web-browser profiles folder. It should be called at the
	 * end.
	 *
	 * @example
	 * ui.wait()
	 * ui.delete_all_profiles()
	 * ui.clean()
	 */
	@(link_name="webui_delete_all_profiles")
	delete_all_profiles :: proc() ---

	/**
	 * @brief Delete a specific window web-browser local folder profile.
	 *
	 * @param window The window number
	 *
	 * @example
	 * ui.wait()
	 * ui.delete_profile(myWindow)
	 * ui.clean()
	 *
	 * @note This can break functionality of other windows if using the same
	 * web-browser.
	 */
	@(link_name="webui_delete_profile")
	delete_profile :: proc(window: c.size_t) ---

	/**
	 * @brief Get the ID of the parent process (The web browser may re-create
	 * another new process).
	 *
	 * @param window The window number
	 *
	 * @return Returns the the parent process id as integer
	 *
	 * @example id: c.size_t = ui.get_parent_process_id(myWindow)
	 */
	@(link_name="webui_get_parent_process_id")
	get_parent_process_id :: proc(window: c.size_t) -> c.size_t ---

	/**
	 * @brief Get the ID of the last child process.
	 *
	 * @param window The window number
	 *
	 * @return Returns the the child process id as integer
	 *
	 * @example id: c.size_t = ui.get_child_process_id(myWindow)
	 */
	@(link_name="webui_get_child_process_id")
	get_child_process_id :: proc(window: c.size_t) -> c.size_t ---

	/**
	 * @brief Get the network port of a running window.
	 * This can be useful to determine the HTTP link of `webui.js`
	 *
	 * @param window The window number
	 *
	 * @return Returns the network port of the window
	 *
	 * @example port: c.size_t = ui.get_port(myWindow)
	 */
	@(link_name="webui_get_port")
	get_port :: proc(window: c.size_t) -> c.size_t ---

	/**
	 * @brief Set a custom web-server/websocket network port to be used by WebUI.
	 * This can be useful to determine the HTTP link of `webui.js` in case
	 * you are trying to use WebUI with an external web-server like NGNIX.
	 *
	 * @param window The window number
	 * @param port The web-server network port WebUI should use
	 *
	 * @return Returns True if the port is free and usable by WebUI
	 *
	 * @example ret: bool = ui.set_port(myWindow, 8080)
	 */
	@(link_name="webui_set_port")
	set_port :: proc(window: c.size_t, port: c.size_t) -> c.bool ---

	/**
	 * @brief Get an available usable free network port.
	 *
	 * @return Returns a free port
	 *
	 * @example port: c.size_t = ui.get_free_port()
	 */
	@(link_name="webui_get_free_port")
	get_free_port :: proc() -> c.size_t ---

	/**
	 * @brief Control the WebUI behaviour. It's recommended to be called at the beginning.
	 *
	 * @param option The desired option from `Config` enum
	 * @param status The status of the option, `true` or `false`
	 *
	 * @example ui.set_config(show_wait_connection, false)
	 */
	@(link_name="webui_set_config")
	set_config :: proc(option: Config, status: c.bool) ---

	/**
	 * @brief Control if UI events comming from this window should be processed
	 * one a time in a single blocking thread `True`, or process every event in
	 * a new non-blocking thread `False`. This update single window. You can use
	 * `set_config(ui_event_blocking, ...)` to update all windows.
	 *
	 * @param window The window number
	 * @param status The blocking status `true` or `false`
	 *
	 * @example ui.set_event_blocking(myWindow, true)
	 */
	@(link_name="webui_set_event_blocking")
	set_event_blocking :: proc(window: c.size_t, status: c.bool) ---

	/**
	 * @brief Get the HTTP mime type of a file.
	 *
	 * @return Returns the HTTP mime string
	 *
	 * @example mime: cstring = ui.get_mime_type("foo.png")
	 */
	@(link_name="webui_get_mime_type")
	get_mime_type :: proc(file: cstring) -> cstring ---

	// == SSL/TLS =============================================================

	/**
	 * @brief Set the SSL/TLS certificate and the private key content, both in PEM
	 * format. This works only with `webui-2-secure` library. If set empty WebUI
	 * will generate a self-signed certificate.
	 *
	 * @param certificate_pem The SSL/TLS certificate content in PEM format
	 * @param private_key_pem The private key content in PEM format
	 *
	 * @return Returns True if the certificate and the key are valid.
	 *
	 * @example ret: bool = ui.set_tls_certificate("-----BEGIN
	 * CERTIFICATE-----\n...", "-----BEGIN PRIVATE KEY-----\n...")
	 */
	@(link_name="webui_set_tls_certificate")
	set_tls_certificate :: proc(certificate_pem: cstring, private_key_pem: cstring) -> c.bool ---

	// == JavaScript ==========================================================

	/**
	 * @brief Run JavaScript without waiting for the response. All clients.
	 *
	 * @param window The window number
	 * @param script The JavaScript to be run
	 *
	 * @example ui.webui_run(myWindow, cstring("alert('Hello');"))
	 */
	@(link_name="webui_run")
	webui_run :: proc(window: c.size_t, script: cstring) ---

	/**
	 * @brief Run JavaScript without waiting for the response. Single client.
	 *
	 * @param e The event struct
	 * @param script The JavaScript to be run
	 *
	 * @example ui.run_client(e, cstring("alert('Hello');"))
	 */
	@(link_name="webui_run_client")
	run_client :: proc(e: ^Event, script: cstring) ---

	/**
	 * @brief Run JavaScript and get the response back. Work only in single client mode.
	 * Make sure your local buffer can hold the response.
	 *
	 * @param window The window number
	 * @param script The JavaScript to be run
	 * @param timeout The execution timeout in seconds
	 * @param buffer The local buffer to hold the response
	 * @param buffer_length The local buffer size
	 *
	 * @return Returns True if there is no execution error
	 *
	 * @example err: bool = ui.webui_script(myWindow, cstring("return 4 + 6;"), 0, myBuffer, myBufferSize)
	 */
	@(link_name="webui_script")
	webui_script :: proc(window: c.size_t, script: cstring, timeout: c.size_t, buffer: cstring, buffer_length: c.size_t) -> c.bool ---

	/**
	 * @brief Run JavaScript and get the response back. Single client.
	 * Make sure your local buffer can hold the response.
	 *
	 * @param e The event struct
	 * @param script The JavaScript to be run
	 * @param timeout The execution timeout in seconds
	 * @param buffer The local buffer to hold the response
	 * @param buffer_length The local buffer size
	 *
	 * @return Returns True if there is no execution error
	 *
	 * @example err: bool = ui.script_client(e, cstring("return 4 + 6;"), 0, myBuffer, myBufferSize)
	 */
	@(link_name="webui_script_client")
	script_client :: proc(e: ^Event, script: cstring, timeout: c.size_t, buffer: cstring, buffer_length: c.size_t) -> c.bool ---

	/**
	 * @brief Chose between Deno and Nodejs as runtime for .js and .ts files.
	 *
	 * @param window The window number
	 * @param runtime Deno | Bun | Nodejs | None
	 *
	 * @example ui.set_runtime(myWindow, .Deno)
	 */
	@(link_name="webui_set_runtime")
	set_runtime :: proc(window: c.size_t, runtime: WebuiJSRuntime) ---

	/**
	 * @brief Get how many arguments there are in an event.
	 *
	 * @param e The event struct
	 *
	 * @return Returns the arguments count.
	 *
	 * @example count: c.size_t = ui.get_count(e)
	 */
	@(link_name="webui_get_count")
	get_count :: proc(e: ^Event) -> c.size_t ---

	/**
	 * @brief Get an argument as integer at a specific index.
	 *
	 * @param e The event struct
	 * @param index The argument position starting from 0
	 *
	 * @return Returns argument as integer
	 *
	 * @example myNum: i64 = ui.get_int_at(e, 0)
	 */
	@(link_name="webui_get_int_at")
	get_int_at :: proc(e: ^Event, index: c.size_t) -> c.longlong ---

	/**
	 * @brief Get the first argument as integer.
	 *
	 * @param e The event struct
	 *
	 * @return Returns argument as integer
	 *
	 * @example myNum: i64 = ui.get_int(e)
	 */
	@(link_name="webui_get_int")
	get_int :: proc(e: ^Event) -> c.longlong ---

	/**
	 * @brief Get an argument as float at a specific index.
	 *
	 * @param e The event struct
	 * @param index The argument position starting from 0
	 *
	 * @return Returns argument as float
	 *
	 * @example myNum: f64 = ui.get_float_at(e, 0)
	 */
	@(link_name="webui_get_float_at")
	get_float_at :: proc(e: ^Event, index: c.size_t) -> c.double ---

	/**
	 * @brief Get the first argument as float.
	 *
	 * @param e The event struct
	 *
	 * @return Returns argument as float
	 *
	 * @example myNum: f64 = ui.get_float(e)
	 */
	@(link_name="webui_get_float")
	get_float :: proc(e: ^Event) -> c.double ---

	/**
	 * @brief Get an argument as string at a specific index.
	 *
	 * @param e The event struct
	 * @param index The argument position starting from 0
	 *
	 * @return Returns argument as string
	 *
	 * @example myStr: cstring = ui.get_string_at(e, 0)
	 */
	@(link_name="webui_get_string_at")
	get_string_at :: proc(e: ^Event, index: c.size_t) -> cstring ---

	/**
	 * @brief Get the first argument as string.
	 *
	 * @param e The event struct
	 *
	 * @return Returns argument as string
	 *
	 * @example myStr: cstring = ui.get_string(e)
	 */
	@(link_name="webui_get_string")
	get_string :: proc(e: ^Event) -> cstring ---

	/**
	 * @brief Get an argument as boolean at a specific index.
	 *
	 * @param e The event struct
	 * @param index The argument position starting from 0
	 *
	 * @return Returns argument as boolean
	 *
	 * @example myBool: bool = ui.get_bool_at(e, 0)
	 */
	@(link_name="webui_get_bool_at")
	get_bool_at :: proc(e: ^Event, index: c.size_t) -> c.bool ---

	/**
	 * @brief Get the first argument as boolean.
	 *
	 * @param e The event struct
	 *
	 * @return Returns argument as boolean
	 *
	 * @example myBool: bool = ui.get_bool(e)
	 */
	@(link_name="webui_get_bool")
	get_bool :: proc(e: ^Event) -> c.bool ---

	/**
	 * @brief Get the size in bytes of an argument at a specific index.
	 *
	 * @param e The event struct
	 * @param index The argument position starting from 0
	 *
	 * @return Returns size in bytes
	 *
	 * @example argLen: uint = ui.get_size_at(e, 0)
	 */
	@(link_name="webui_get_size_at")
	get_size_at :: proc(e: ^Event, index: c.size_t) -> c.size_t ---

	/**
	 * @brief Get size in bytes of the first argument.
	 *
	 * @param e The event struct
	 *
	 * @return Returns size in bytes
	 *
	 * @example argLen: uint = ui.get_size(e)
	 */
	@(link_name="webui_get_size")
	get_size :: proc(e: ^Event) -> c.size_t ---

	/**
	 * @brief Return the response to JavaScript as integer.
	 *
	 * @param e The event struct
	 * @param n The integer to be send to JavaScript
	 *
	 * @example ui.return_int(e, 123)
	 */
	@(link_name="webui_return_int")
	return_int :: proc(e: ^Event, n: c.longlong) -> c.size_t ---

	/**
	 * @brief Return the response to JavaScript as float.
	 *
	 * @param e The event struct
	 * @param f The float number to be send to JavaScript
	 *
	 * @example ui.return_float(e, 123.456)
	 */
	@(link_name="webui_return_float")
	return_float :: proc(e: ^Event, f: c.double) ---

	/**
	 * @brief Return the response to JavaScript as string.
	 *
	 * @param e The event struct
	 * @param n The string to be send to JavaScript
	 *
	 * @example ui.return_string(e, "Response...")
	 */
	@(link_name="webui_return_string")
	return_string :: proc(e: ^Event, s: cstring) ---

	/**
	 * @brief Return the response to JavaScript as boolean.
	 *
	 * @param e The event struct
	 * @param n The boolean to be send to JavaScript
	 *
	 * @example ui.return_bool(e, true)
	 */
	@(link_name="webui_return_bool")
	return_bool :: proc(e: ^Event, b: c.bool) ---

	// == Wrapper's Interface =================================================

	/**
	 * @brief Bind a specific HTML element click event with a function. Empty element means all events.
	 *
	 * @param window The window number
	 * @param element The element ID
	 * @param func The callback as myFunc(Window, EventType, Element, EventNumber, BindID)
	 *
	 * @return Returns unique bind ID
	 *
	 * @example id: c.size_t = ui.interface_bind(myWindow, cstring("myID"), myCallback)
	 */
	@(link_name="webui_interface_bind")
	interface_bind :: proc(window: c.size_t, element: cstring, func: proc(n1: c.size_t, n2: c.size_t, str: cstring, n3: c.size_t, n4: c.size_t)) -> c.size_t ---

	/**
	 * @brief When using `webui_interface_bind()`, you may need this function to easily set a response.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param response The response as string to be send to JavaScript
	 *
	 * @example ui.interface_set_response(myWindow, e.event_number, cstring("Response..."))
	 */
	@(link_name="webui_interface_set_response")
	interface_set_response :: proc(window: c.size_t, event_number: c.size_t, response: cstring) ---

	/**
	 * @brief Check if the app still running.
	 *
	 * @return Returns True if app is running
	 *
	 * @example status: bool = ui.interface_is_app_running()
	 */
	@(link_name="webui_interface_is_app_running")
	interface_is_app_running :: proc() -> c.bool ---

	/**
	 * @brief Get a unique window ID.
	 *
	 * @param window The window number
	 *
	 * @return Returns the unique window ID as integer
	 *
	 * @example id: c.size_t = ui.interface_get_window_id(myWindow)
	 */
	@(link_name="webui_interface_get_window_id")
	interface_get_window_id :: proc(window: c.size_t) -> c.size_t ---

	/**
	 * @brief Get an argument as string at a specific index.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param index The argument position
	 *
	 * @return Returns argument as string
	 *
	 * @example myStr: cstring = ui.interface_get_string_at(myWindow, e.event_number, 0)
	 */
	@(link_name="webui_interface_get_string_at")
	interface_get_string_at :: proc(window: c.size_t, event_number: c.size_t, index: c.size_t) -> cstring ---

	/**
	 * @brief Get an argument as integer at a specific index.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param index The argument position
	 *
	 * @return Returns argument as integer
	 *
	 * @example myNum: i64 = ui.interface_get_int_at(myWindow, e.event_number, 0)
	 */
	@(link_name="webui_interface_get_int_at")
	interface_get_int_at :: proc(window: c.size_t, event_number: c.size_t, index: c.size_t) -> c.longlong ---

	/**
	 * @brief Get an argument as float at a specific index.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param index The argument position
	 *
	 * @return Returns argument as float
	 *
	 * @example myFloat: f64 = ui.interface_get_int_at(myWindow, e.event_number, 0)
	 */
	@(link_name="webui_interface_get_float_at")
	interface_get_float_at :: proc(window: c.size_t, event_number: c.size_t, index: c.size_t) -> c.double ---

	/**
	 * @brief Get an argument as boolean at a specific index.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param index The argument position
	 *
	 * @return Returns argument as boolean
	 *
	 * @example myBool: bool = ui.interface_get_bool_at(myWindow, e.event_number, 0)
	 */
	@(link_name="webui_interface_get_bool_at")
	interface_get_bool_at :: proc(window: c.size_t, event_number: c.size_t, index: c.size_t) -> c.bool ---

	/**
	 * @brief Get the size in bytes of an argument at a specific index.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param index The argument position
	 *
	 * @return Returns size in bytes
	 *
	 * @example argLen: uint = ui.interface_get_size_at(myWindow, e.event_number, 0)
	 */
	@(link_name="webui_interface_get_size_at")
	interface_get_size_at :: proc(window: c.size_t, event_number: c.size_t, index: c.size_t) -> c.size_t ---

	/**
	 * @brief Show a window using embedded HTML, or a file. If the window is already
	 * open, it will be refreshed. Single client.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param content The HTML, URL, Or a local file
	 *
	 * @return Returns True if showing the window is successed.
	 *
	 * @example ui.interface_show_client(e, "<html>...</html>") |
	 * ui.interface_show_client(e, "index.html") | ui.interface_show_client(e, "http://...")
	 */
	@(link_name="webui_interface_show_client")
	interface_show_client :: proc(window: c.size_t, event_number: c.size_t, content: cstring) -> c.bool ---

	/**
	 * @brief Close a specific client.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 *
	 * @example ui.interface_close_client(e)
	 */
	@(link_name="webui_interface_close_client")
	interface_close_client :: proc(window: c.size_t, event_number: c.size_t) ---

	/**
	 * @brief Safely send raw data to the UI. Single client.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param function The JavaScript function to receive raw data: `function
	 * myFunc(myData){}`
	 * @param raw The raw data buffer
	 * @param size The raw data size in bytes
	 *
	 * @example ui.interface_send_raw_client(e.window, e.event_number, "myJavaScriptFunc", rawptr(myBuffer), 64)
	 */
	@(link_name="webui_interface_send_raw_client")
	interface_send_raw_client :: proc(window: c.size_t, event_number: c.size_t, function: cstring, raw: rawptr, size: c.size_t) ---

	/**
	 * @brief Navigate to a specific URL. Single client.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param url Full HTTP URL
	 *
	 * @example ui.interface_navigate_client(e.window, e.event_number, cstring("http://domain.com"))
	 */
	@(link_name="webui_interface_navigate_client")
	interface_navigate_client :: proc(window: c.size_t, event_number: c.size_t, url: cstring) ---

	/**
	 * @brief Run JavaScript without waiting for the response. Single client.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param script The JavaScript to be run
	 *
	 * @example ui.interface_run_client(e.window, e.event_number, cstring("alert('Hello');"))
	 */
	@(link_name="webui_interface_run_client")
	interface_run_client :: proc(window: c.size_t, event_number: c.size_t, script: cstring) ---

	/**
	 * @brief Run JavaScript and get the response back. Single client.
	 * Make sure your local buffer can hold the response.
	 *
	 * @param window The window number
	 * @param event_number The event number
	 * @param script The JavaScript to be run
	 * @param timeout The execution timeout in seconds
	 * @param buffer The local buffer to hold the response
	 * @param buffer_length The local buffer size
	 *
	 * @return Returns True if there is no execution error
	 *
	 * @example err: bool = ui.interface_script_client(e.window, e.event_number, cstring("return 4 + 6;"), 0, myBuffer, myBufferSize)
	 */
	@(link_name="webui_interface_script_client")
	interface_script_client :: proc(window: c.size_t, event_number: c.size_t, script: cstring, timeout: c.size_t, buffer: cstring, buffer_length: c.size_t) -> c.bool ---

}



//// == Wrapper functions =======================================================
//
Error :: enum {
	None,
	Failed,
}

// Show a window using embedded HTML, or a file. If the window is already open, it will be refreshed.
show :: proc(win: c.size_t, content: string, await: bool = false, timeout: uint = 10) -> Error {
	res := webui_show(win, strings.unsafe_string_to_cstring(content))
	if !await {
		return .Failed
	}
	for _ in 0 ..< timeout * 100 {
		if is_shown(win) {
			return nil
		}
		// Slow down check interval to reduce load.
		time.sleep(10 * time.Millisecond)
	}
	return .Failed
}

// Navigate to a specific URL
navigate :: proc(win: c.size_t, url: string) {
	webui_navigate(win, strings.unsafe_string_to_cstring(url))
}

// Run JavaScript without waiting for the response.
run :: proc(win: c.size_t, script: string) {
	webui_run(win, strings.unsafe_string_to_cstring(script))
}

// Run JavaScript and get the response back (Make sure your local buffer can hold the response).
script :: proc(
	win: c.size_t,
	script: string,
	buffer_len: uint = 8 * 1024,
	timeout: uint = 0,
) -> (
	string,
	Error,
) {
buf := make([^]byte, buffer_len)
	res := webui_script(
	win,
		strings.unsafe_string_to_cstring(script),
		timeout,
		cstring(buf),
		buffer_len,
	)
	if !res {
		return "", .Failed
	}
	return strings.string_from_ptr(buf, int(buffer_len)), .None
}

GetArgError :: union {
	enum {
		None,
		No_Argument,
	},
	json.Unmarshal_Error,
}

// Parse a JS argument as Odin data type.
get_arg :: proc($T: typeid, e: ^Event, idx: uint = 0) -> (res: T, err: GetArgError) {
	if get_size_at(e, idx) == 0 {
		return res, .No_Argument
	}
	when intrinsics.type_is_numeric(T) {
		return auto_cast get_int_at(e, idx), nil
	} else when T == string {
		return string(get_string_at(e, idx)), nil
	} else when T == bool {
		return get_bool_at(e, idx), nil
	}
	json.unmarshal_string(string(get_string_at(e, idx)), &res) or_return
	return
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






