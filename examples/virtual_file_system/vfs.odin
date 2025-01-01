package virtual_file_system

import ui "../../"
import "core:c"
import "core:fmt"
import "base:runtime"
import "core:path/filepath"
import "core:strings"
import "core:mem"
import "core:c/libc"
import "core:os"

VirtualFile :: struct {
    path: cstring,
    data: []u8,
    length: i32,
}

virtual_files := [dynamic]VirtualFile {
    VirtualFile {
        "/index.html",
        {},
        0
    },
    VirtualFile {
        "/sub/index.html",
        {},
        0
    },
    VirtualFile {
        "/svg/webui.svg",
        {},
        0
    },
}


index_files := [dynamic]cstring {
    "//", "/index.html",
    "/sub/", "/sub/index.html"
}

get_all_files :: proc(dir: string) {
// https://pkg.odin-lang.org/core/path/filepath/

}

virtual_file_system :: proc (path: cstring, file: ^[]u8, length: ^i32) -> bool {

    for &vf in virtual_files {
        vf.data, _ = os.read_entire_file_from_filename(fmt.aprintf("ui/%s", string(path)))
        //vf.data, _ = os.read_entire_file_from_filename(string(path))
        fmt.printfln("%v", vf.data)
        vf.length = i32(len(vf.data))
        fmt.printfln("\n%d\n", vf.length)
        if libc.strcmp(vf.path, path) == 0 {
            file^ = vf.data
            length^ = vf.length
            return true
        }
    }
    return false
}

vfs :: proc "c" (path: cstring, length: ^i32) -> rawptr {
    context = runtime.default_context()

    file_data: []u8
    file_length: c.int

    // Try to retrieve the file from the virtual file system
    if virtual_file_system(path, &file_data, &file_length) {
        fmt.printfln("vf was true: %s", path)
        content_type := ui.get_mime_type(path)

        http_header_template: cstring = "HTTP/1.1 200 OK\r\n" +
        "Content-Type: %s\r\n" +
        "Content-Length: %d\r\n" +
        "Cache-Control: no-cache\r\n\r\n"

        // Calculate the header length using libc.sprintf
        header_length: c.int = libc.snprintf(nil, 0, http_header_template, content_type, file_length)

        // Calculate the total response length
        length^ = header_length + file_length;

        // Allocate memory for the response using libc.malloc
        response: [^]u8 = cast([^]u8) libc.malloc(c.size_t(length^));
        if response == nil {
            return nil; // Return null if memory allocation fails
        }

        // Write the formatted header into the response
        libc.snprintf(cast(^c.char) response, cast(uint)header_length + 1, http_header_template, content_type, file_length);

        // Copy the file data into the response buffer using libc.memcpy
        libc.memcpy(raw_data(response[:header_length]), raw_data(file_data), cast(c.size_t)file_length)

        return rawptr(response);
    } else {
        fmt.printfln("vf was false")
        // Handle index file redirection
        redirect_path: [^]u8
        libc.snprintf(redirect_path, size_of(redirect_path), "%s", path)

        // Ensure path ends with a '/'
        leng: c.size_t = libc.strlen(cstring(redirect_path))
        if redirect_path[leng - 1] != '/' {
            redirect_path[leng] = '/'
        }

        // Search for matching index files
        for i: c.int = 0; index_files[i] != nil; i += 2 {
            if libc.strcmp(index_files[i], cstring(redirect_path)) == 0 {
                location_header: cstring = "HTTP/1.1 302 Found\r\n" +
                "Location: %s\r\n" +
                "Cache-Control: no-cache\r\n\r\n"

                header_length := libc.snprintf(nil, 0, location_header, index_files[i + 1])
                length^ = header_length

                response := cast(^u8) libc.malloc(c.size_t(header_length))
                if response == nil {
                    return nil // Return null if memory allocation fails
                }

                libc.snprintf(cast(^c.char) response, cast(uint)header_length + 1, location_header, index_files[i + 1])

                return rawptr(response)
            }
        }
        return nil
    }
}

