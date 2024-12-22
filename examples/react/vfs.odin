package react

import ui "../../"
import "core:fmt"
import "core:mem"
import "core:os"
import "base:runtime"
import "core:c/libc"
import "core:c"


// Define the VirtualFile struct
VirtualFile :: struct {
    path: ^c.char,
    data: ^c.uchar,
    length: c.int,
}


// Define the virtual_files array with placeholder data
virtual_files: [dynamic]VirtualFile = {
    {
        path = raw_data(string("/example/file1.txt")),
        data = raw_data([]u8{}), // Placeholder: Add actual byte data here
        length = 0,
    },
    {
        path = raw_data(string("/example/file2.txt")),
        data = raw_data([]u8{}), // Placeholder: Add actual byte data here
        length = 0,
    },
    {
        path = raw_data(string("/example/file3.txt")),
        data = raw_data([]u8{}), // Placeholder: Add actual byte data here
        length = 0,
    },
}


index_files: [dynamic]string = {
    "/", "/index.html",
}


// Function to look up a file by its path
virtual_file_system :: proc(path: ^c.char, file: ^^c.uchar, length: ^c.int) -> bool {
    for v_file in virtual_files {
        if libc.strcmp(cstring(v_file.path), cstring(path)) == 0 {
            file^ = v_file.data
            length^ = v_file.length
            return true
        }
    }
    return false
}


// Function to handle HTTP-like responses for debugging purposes
vfs :: proc (path: ^c.char, length: ^c.int) -> rawptr {
    file_data: ^c.uchar
    file_length: c.int

    if virtual_file_system(path, &file_data, &file_length) {
        content_type: ^c.char = ui.webui_get_mime_type(path)
        http_header_template_cstr: cstring = "HTTP/1.1 200 OK\r\nContent-Type: %s\r\nContent-Length: %d\r\nCache-Control: no-cache\r\n\r\n"
        //http_header_template: ^c.char = transmute(^c.char)http_header_template_cstr
        header_length: c.int = libc.snprintf(nil, 0, http_header_template_cstr, content_type, file_length)
        length^ = header_length + file_length
        // TODO: still fixing types and errors, left off here.
        response: ^c.uchar = libc.malloc(length^)
        libc.snprintf(^c.char(response), header_length + 1, http_header_template_cstr, content_type, file_length)
        response = libc.memcpy(response + header_length, file_data, file_length)
        return response
    } else {
        // Check for index file redirection
        redirect_path: [1024]c.char
        libc.snprintf(redirect_path, size_of(redirect_path), "%s", path)
        str_len: c.size_t = libc.strlen(redirect_path)
        if redirect_path[str_len - 1] != '/' {
            redirect_path[str_len] = '/'
            redirect_path[str_len + 1] = nil
        }

        for i := 0; index_files[i] != nil; i+=2 {
            if libc.strcmp(index_files[i], redirect_path) == 0 {
                location_header: ^c.char = ^c.char("HTTP/1.1 302 Found\r\nLocation: %s\r\nCache-Control: no-cache\r\n\r\n")
                header_length: c.int = libc.snprintf(nil, 0, location_header, index_files[i + 1])
                length^ = header_length
                response: ^c.uchar = ^c.uchar(libc.malloc(length^))
                libc.snprintf(^c.char(response), header_length + 1, location_header, index_files[i + 1])
                return response
            }
        }
        return nil
    }
}
