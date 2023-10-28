<div align="center">

# Odin-WebUI

<!-- ![][release_version] -->

[![][build_status]](https://github.com/webui-dev/odin-webui/actions?query=branch%3Amain) [![][last_commit]](https://github.com/webui-dev/odin-webui/pulse) [![][license]](https://github.com/webui-dev/odin-webui/blob/main/LICENSE)

![Screenshot](https://github.com/webui-dev/webui/assets/34311583/57992ef1-4f7f-4d60-8045-7b07df4088c6)

> WebUI is not a web-server solution or a framework, but it allows you to use any web browser as a GUI, with your preferred language in the backend and HTML5 in the frontend. All in a lightweight portable lib.

</div>

## Usage

> **Note**
> Odin-WebUI is under development and is currently only tested on macOS and Linux.

### Setup as a submodule in your Odin project

TODO:

### Setup as regular git clone

1. Clone the repository

```sh
git clone https://github.com/webui-dev/odin-webui.git
```

2. Setup the WebUI C library

```sh
cd odin-webui

# Setup WebUI C relative to the current path
# Linux & macOS
./setup.sh
```

## Example

```odin
package main

import ui "webui"
import "core:fmt"

UI :: `<!DOCTYPE html>
<html lang="en">
  <head>
    <style>
      body {
        background: linear-gradient(to left, #36265a, #654da9);
        color: AliceBlue;
        font: 16px sans-serif;
        text-align: center;
      }
    </style>
    <script src="webui.js"></script>
  </head>
  <body>
    <h1>Thanks for using WebUI!</h1>
    <button onclick="webui.my_odin_func('myJSArg')">Call Odin!</button>
    <button id="exit">Exit</button>
  </body>
</html>`

// Odin function used as bind callback.
my_odin_func :: proc(e: ^ui.Event) {
	str_arg := ui.get_arg(string, e)
	fmt.printf("JS argument: %s\n", str_arg)
}

main :: proc() {
	w := ui.new_window()
	ui.bind(w, "my_odin_func", my_odin_func)
	// Bind to an ID with a click event.
	ui.bind(w, "exit", proc(_: ^ui.Event) {
		fmt.println("Bye!")
		ui.exit()
	})
	ui.show(w, UI)
	ui.wait()
}
```

Running exmples from the [`examples`](https://github.com/webui-dev/odin-webui/tree/main/examples) directory:

```
odin run examples/call_odin.odin -file
```

### Debugging

To use WebUI's debug build in your Odin-WebUI application, add the `-debug` switch. E.g.:

```sh
odin run examples/miniml.odin -file -debug
```

### License

> Licensed under the MIT License.

## About WebUI

[Borislav Stanimirov](https://ibob.bg/) discusses using HTML5 in the web browser as GUI at the [C++ Conference 2019 (_YouTube_)](https://www.youtube.com/watch?v=bbbcZd4cuxg).

<!-- <div align="center">
  <a href="https://www.youtube.com/watch?v=bbbcZd4cuxg"><img src="https://img.youtube.com/vi/bbbcZd4cuxg/0.jpg" alt="Embrace Modern Technology: Using HTML 5 for GUI in C++ - Borislav Stanimirov - CppCon 2019"></a>
</div> -->

<div align="center">

![CPPCon](https://github.com/webui-dev/webui/assets/34311583/4e830caa-4ca0-44ff-825f-7cd6d94083c8)

</div>

Web application UI design is not just about how a product looks but how it works. Using web technologies in your UI makes your product modern and professional, And a well-designed web application will help you make a solid first impression on potential customers. Great web application design also assists you in nurturing leads and increasing conversions. In addition, it makes navigating and using your web app easier for your users.

### Why Use Web Browsers?

Today's web browsers have everything a modern UI needs. Web browsers are very sophisticated and optimized. Therefore, using it as a GUI will be an excellent choice. While old legacy GUI lib is complex and outdated, a WebView-based app is still an option. However, a WebView needs a huge SDK to build and many dependencies to run, and it can only provide some features like a real web browser. That is why WebUI uses real web browsers to give you full features of comprehensive web technologies while keeping your software lightweight and portable.

### How Does it Work?

<div align="center">

![Diagram](https://github.com/ttytm/webui/assets/34311583/dbde3573-3161-421e-925c-392a39f45ab3)

</div>

Think of WebUI like a WebView controller, but instead of embedding the WebView controller in your program, which makes the final program big in size, and non-portable as it needs the WebView runtimes. Instead, by using WebUI, you use a tiny static/dynamic library to run any installed web browser and use it as GUI, which makes your program small, fast, and portable. **All it needs is a web browser**.

### Runtime Dependencies Comparison

|                                 | WebView           | Qt                         | WebUI               |
| ------------------------------- | ----------------- | -------------------------- | ------------------- |
| Runtime Dependencies on Windows | _WebView2_        | _QtCore, QtGui, QtWidgets_ | **_A Web Browser_** |
| Runtime Dependencies on Linux   | _GTK3, WebKitGTK_ | _QtCore, QtGui, QtWidgets_ | **_A Web Browser_** |
| Runtime Dependencies on macOS   | _Cocoa, WebKit_   | _QtCore, QtGui, QtWidgets_ | **_A Web Browser_** |

## Wrappers

| Language                | Status         | Link                                                      |
| ----------------------- | -------------- | --------------------------------------------------------- |
| Go                      | ✔️             | [Go-WebUI](https://github.com/webui-dev/go-webui)         |
| Nim                     | ✔️             | [Nim-WebUI](https://github.com/webui-dev/nim-webui)       |
| Pascal                  | ✔️             | [Pascal-WebUI](https://github.com/webui-dev/pascal-webui) |
| Python                  | ✔️             | [Python-WebUI](https://github.com/webui-dev/python-webui) |
| Rust                    | _not complete_ | [Rust-WebUI](https://github.com/webui-dev/rust-webui)     |
| TypeScript / JavaScript | ✔️             | [Deno-WebUI](https://github.com/webui-dev/deno-webui)     |
| V                       | ✔️             | [V-WebUI](https://github.com/webui-dev/v-webui)           |
| Zig                     | _not complete_ | [Zig-WebUI](https://github.com/webui-dev/zig-webui)       |

## Supported Web Browsers

| Browser         | Windows         | macOS         | Linux           |
| --------------- | --------------- | ------------- | --------------- |
| Mozilla Firefox | ✔️              | ✔️            | ✔️              |
| Google Chrome   | ✔️              | ✔️            | ✔️              |
| Microsoft Edge  | ✔️              | ✔️            | ✔️              |
| Chromium        | ✔️              | ✔️            | ✔️              |
| Yandex          | ✔️              | ✔️            | ✔️              |
| Brave           | ✔️              | ✔️            | ✔️              |
| Vivaldi         | ✔️              | ✔️            | ✔️              |
| Epic            | ✔️              | ✔️            | _not available_ |
| Apple Safari    | _not available_ | _coming soon_ | _not available_ |
| Opera           | _coming soon_   | _coming soon_ | _coming soon_   |

### Stargazers

[![][startgazers]](https://github.com/webui-dev/odin-webui/stargazers)

<!-- Images -->

[build_status]: https://img.shields.io/github/actions/workflow/status/webui-dev/odin-webui/ci.yml?branch=main&style=for-the-badge&logo=circle&labelColor=414868&logoColor=C0CAF5
[last_commit]: https://img.shields.io/github/last-commit/webui-dev/odin-webui?style=for-the-badge&logo=github&logoColor=C0CAF5&labelColor=414868
[release_version]: https://img.shields.io/github/v/release/webui-dev/odin-webui?style=for-the-badge&logo=webtrees&logoColor=C0CAF5&labelColor=414868&color=7664C6
[license]: https://img.shields.io/github/license/webui-dev/odin-webui?style=for-the-badge&logo=opensourcehardware&label=License&logoColor=C0CAF5&labelColor=414868&color=8c73cc
[startgazers]: https://reporoster.com/stars/webui-dev/odin-webui
