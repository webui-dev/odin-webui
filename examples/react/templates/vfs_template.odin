package template

import ui "../../../"
import "core:fmt"
import "core:mem"
import "core:os"
import "base:runtime"
import "core:c/libc"
import "core:c"
import "core:strings"

VirtualFile := map[string][dynamic]u8 {}


index_files := [dynamic]string{
    "//", "/index.html",
}

virtual_file_system :: proc(path: string, file: ^[dynamic]u8) -> bool {
    data, ok := VirtualFile[path]
    if ok {
        file^ = data
        return true
    }
    return false
}

vfs :: proc "c" (path: cstring, length: ^c.int) -> rawptr {
    context = runtime.default_context()

    path_odin := string(path)
    length_odin: ^int = cast(^int)length

    file_data: [dynamic]u8


    fmt.printfln("file_date before: %v", file_data)
    if virtual_file_system(path_odin, &file_data) {
        fmt.printfln("vfs was TRUE")
        fmt.printfln("file_date after: %v", file_data)
        content_type := string(ui.get_mime_type(strings.unsafe_string_to_cstring(path_odin)))
        if strings.starts_with(content_type, "text/") {
            content_type = strings.concatenate({content_type, "; charset=UTF-8"})
        }
        fmt.printfln(string(ui.get_mime_type(strings.unsafe_string_to_cstring(path_odin))))

        http_header_template: cstring = strings.unsafe_string_to_cstring("HTTP/1.1 200 OK\r\nContent-Type: %s\r\nContent-Length: %d\r\nCache-Control: no-cache\r\n\r\n")
        fmt.printfln(string(http_header_template), content_type, len(file_data))

        header_length: int = cast(int)libc.snprintf(nil, 0, http_header_template, content_type, len(file_data))
        length_odin^ = header_length + len(file_data)

        response: rawptr = ui.malloc(cast(uint)length_odin^)
        libc.snprintf(cast([^]u8)response, cast(uint)header_length + 1, http_header_template, content_type, len(file_data))
        response = cast(rawptr)(cast(uintptr)response + cast(uintptr)header_length)
        mem.copy(response, &file_data, len(file_data))
        return response

    } else {
    // Handle redirections for index files
        fmt.printfln("endered else statement, vfs was FALSE")
        redirect_path := string(path)
        if !strings.ends_with(redirect_path, "/") {
            redirect_path = strings.concatenate({redirect_path, "/"})
        }

        for i := 0; i < len(index_files); i += 2 {
            if index_files[i] == redirect_path {
                location_header: cstring = strings.unsafe_string_to_cstring("HTTP/1.1 302 Found\r\nLocation: %s\r\nCache-Control: no-cache\r\n\r\n")

                header_length: int = cast(int)libc.snprintf(nil, 0, location_header, index_files[i+1])
                length_odin^ = header_length
                response: rawptr = ui.malloc(cast(uint)length_odin^)
                libc.snprintf(cast([^]u8)response, cast(uint)header_length + 1, location_header, index_files[i + 1])
                return response
            }
        }

    }
    return nil
}
