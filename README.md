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

## Contents

- [Features](#features)
- [Installation](#installation)
- [UI & The Web Technologies](#ui--the-web-technologies)
- [Examples](#minimal-example)
- [Debugging](#debugging)
- [Documentation](#documentation)
- [Wrappers](#wrappers)
- [Supported Web Browsers](#supported-web-browsers)
- [License](#license)

## Features

- Portable (*Needs only a web browser at runtime*)
- Lightweight (*Few Kb library*) & Small memory footprint
- Fast binary communication protocol
- Multi-platform & Multi-Browser
- Using private profile for safety
- Original library is written in Pure C

## Installation

```sh
# Add odin-webui as a submodule to your project
git submodule add https://github.com/webui-dev/odin-webui.git webui

# Linux/MacOS
webui/setup.sh 

# Windows
webui/setup.ps1
```

<details>
<summary><kbd>toggle</kbd> <b>Full example creating a project and adding odin-webui as a submodule.</b></summary>

```sh
# Create your project directory
mkdir my_proj 

# Change Directory into the project Directory
cd my_proj

# Initialize the directory to be a git repository
git init

# Add odin-webui as a submodule to your project
git submodule add https://github.com/webui-dev/odin-webui.git webui

# Build the linkers used for the binding from the C library.
# Linux/MacOS
webui/setup.sh
# Windows
webui/setup.ps1 

# Create a file called 'main.odin' in your project directory. 
# Copy the minimal example code in the next step and paste into 'main.odin'.
# Run the example with the command: 'odin run main.odin -file'.
```
</details>

## Minimal Example

```odin
// main.odin
package main

import ui "webui"

main :: proc() {
    my_window: uint = ui.new_window()
    ui.show(my_window, "<html> Thanks for using WebUI! </html>")
    ui.wait()
}
```
[More examples](https://github.com/webui-dev/odin-webui/tree/main/examples)



## Debugging

To use WebUI's debug build in your Odin-WebUI application, add the `-debug` switch. E.g.:

```sh
odin run examples/minimal.odin -file -debug
```

## Documentation
- [Online Documentation](https://webui.me/docs/2.5/#/)

## UI & The Web Technologies

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

| Language        | v2.4.0 API | v2.5.0 API | Link                                                    |
| --------------- | --- | -------------- | ---------------------------------------------------------  |
| Python          | ✔️ | _not complete_ | [Python-WebUI](https://github.com/webui-dev/python-webui)  |
| Go              | ✔️ | _not complete_ | [Go-WebUI](https://github.com/webui-dev/go-webui)          |
| Zig             | ✔️ |  _not complete_ | [Zig-WebUI](https://github.com/webui-dev/zig-webui)        |
| Nim             | ✔️ |  _not complete_ | [Nim-WebUI](https://github.com/webui-dev/nim-webui)        |
| V               | ✔️ |  _not complete_ | [V-WebUI](https://github.com/webui-dev/v-webui)            |
| Rust            | _not complete_ |  _not complete_ | [Rust-WebUI](https://github.com/webui-dev/rust-webui)      |
| TS / JS (Deno)  | ✔️ |  _not complete_ | [Deno-WebUI](https://github.com/webui-dev/deno-webui)      |
| TS / JS (Bun)   | _not complete_ |  _not complete_ | [Bun-WebUI](https://github.com/webui-dev/bun-webui)        |
| Swift           | _not complete_ |  _not complete_ | [Swift-WebUI](https://github.com/webui-dev/swift-webui)    |
| Odin            | _not complete_ |  _not complete_ | [Odin-WebUI](https://github.com/webui-dev/odin-webui)      |
| Pascal          | _not complete_ |  _not complete_ | [Pascal-WebUI](https://github.com/webui-dev/pascal-webui)  |
| Purebasic       | _not complete_ |  _not complete_ | [Purebasic-WebUI](https://github.com/webui-dev/purebasic-webui)|
| - |  |  |
| Common Lisp     | _not complete_ |  _not complete_ | [cl-webui](https://github.com/garlic0x1/cl-webui)          |
| Delphi          | _not complete_ |  _not complete_ | [WebUI4Delphi](https://github.com/salvadordf/WebUI4Delphi) |
| C#              | _not complete_ |  _not complete_ | [WebUI4CSharp](https://github.com/salvadordf/WebUI4CSharp) |
| WebUI.NET       | _not complete_ |  _not complete_ | [WebUI.NET](https://github.com/Juff-Ma/WebUI.NET)          |
| QuickJS         | _not complete_ |  _not complete_ | [QuickUI](https://github.com/xland/QuickUI)                |
| PHP             | _not complete_ |  _not complete_ | [PHPWebUiComposer](https://github.com/KingBes/php-webui-composer) |

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

### License

> Licensed under the MIT License.

### Stargazers

[![stargazers](https://reporoster.com/stars/webui-dev/odin-webui)](https://github.com/webui-dev/odin-webui/stargazers)


