<div align="center">

![Logo](https://raw.githubusercontent.com/webui-dev/webui-logo/main/webui_odin.png)

# Odin-WebUI

[build-status]: https://img.shields.io/github/actions/workflow/status/webui-dev/odin-webui/ci.yml?branch=main&style=for-the-badge&logo=githubactions&labelColor=414868&logoColor=C0CAF5
[last-commit]: https://img.shields.io/github/last-commit/webui-dev/odin-webui?style=for-the-badge&logo=github&logoColor=C0CAF5&labelColor=414868
[release-version]: https://img.shields.io/github/v/tag/webui-dev/odin-webui?style=for-the-badge&logo=webtrees&logoColor=C0CAF5&labelColor=414868&color=7664C6
[license]: https://img.shields.io/github/license/webui-dev/odin-webui?style=for-the-badge&logo=opensourcehardware&label=License&logoColor=C0CAF5&labelColor=414868&color=8c73cc

[![][build-status]](https://github.com/webui-dev/odin-webui/actions?query=branch%3Amain)
[![][last-commit]](https://github.com/webui-dev/odin-webui/pulse)
[![][release-version]](https://github.com/webui-dev/odin-webui/releases/latest)
[![][license]](https://github.com/webui-dev/odin-webui/blob/main/LICENSE)

> Use any web browser or WebView as GUI.\
> With Odin in the backend and modern web technologies in the frontend.

![Screenshot](https://raw.githubusercontent.com/webui-dev/webui-logo/main/screenshot.png)

</div>

## Usage

> **Note**
> Odin-WebUI is under development and is currently only tested on macOS and Linux.

### Setup as a submodule in your Odin project

Add odin-webui as a submodule in your Odin git project:

```sh
git submodule add https://github.com/webui-dev/odin-webui.git webui
webui/setup.sh
```

Import the package using the relative path

```odin
import ui "webui"
```

<details>
<summary><kbd>toggle</kbd> <b>Full example creating a project and adding odin-webui as a submodule.</b></summary>

```sh
mkdir my_proj && cd my_proj
git init
git submodule add https://github.com/webui-dev/odin-webui.git webui
# Setup the WebUI C library.
weubi/setup.sh
# Create a the main file for the project. And use it in the next step.
touch main.odin
```

```odin
// main.odin
package main

import ui "webui"

main :: proc() {
	w := ui.new_window()
	ui.show(w, "<html>Thanks for using WebUI!</html>")
	ui.wait()
}
```

</details>

### Setup as regular git clone

_This approach can be useful for quick testing and for development and contribution purposes._

1. Clone the repository

```sh
git clone https://github.com/webui-dev/odin-webui.git
```

2. Setup the WebUI C library

```sh
cd odin-webui

# Setup the WebUI C library.
./setup.sh
```

## Example - Call Odin from JavaScript

```odin
package main

import "base:runtime"
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
my_odin_func :: proc "c" (e: ^ui.Event) {
	context := runtime.default_context()

	str_arg := ui.get_arg(string, e)
	fmt.printf("JS argument: %s\n", str_arg)
}

main :: proc() {
	w := ui.new_window()
	ui.bind(w, "my_odin_func", my_odin_func)
	// Bind to an ID with a click event.
	ui.bind(w, "exit", proc "c" (_: ^ui.Event) {
		context := runtime.default_context()
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
odin run examples/minimal.odin -file -debug
```

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

[![stargazers](https://reporoster.com/stars/webui-dev/odin-webui)](https://github.com/webui-dev/odin-webui/stargazers)

### License

> Licensed under the MIT License.
