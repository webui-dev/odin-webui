package react

import ui "../../"
import "core:fmt"
import "core:mem"
import "core:os"
import "base:runtime"
import "core:c/libc"
import "core:c"
import "core:strings"


virtual_files := make(map[string][]u8)
index_paths := [dynamic]string{}


// Function to walk a directory and populate VirtualFile and index_files
build_virtual_file_system :: proc(target_dir: string) {
    fmt.println("Current working directory:", target_dir)

    fd, err := os.open(target_dir)
    defer os.close(fd)
    if err != os.ERROR_NONE {
    // Print error to stderr and exit with error code
        fmt.eprintln("Could not open directory for reading", err)
        os.exit(1)
    }

    all_files: [dynamic]os.File_Info = get_all_files(target_dir)

    for &file in all_files {
        if strings.contains(file.name, target_dir) {
            fmt.printf("[%s] was changed to ", file.name)
            file.name = strings.cut(file.name, len(target_dir), len(file.name))
            fmt.printfln("[%s]", file.name)
        }

        file_data, ok := os.read_entire_file_from_handle(fd)
        if ok {
            virtual_files[file.name] = file_data
            fmt.printfln("File [%s] was read successfully", file.name)
        } else {
            fmt.eprintfln("File [%s] did not read/open properly", file.name)
        }

        if strings.contains(file.name, "index.") {
            append(&index_paths, file.name)
        }
    }

    //fmt.printfln("\nvirtual files:\n%v", virtual_files)
    fmt.printfln("\nindex paths:\n%v", index_paths)

    fmt.printfln("all done!\n\n")
}

get_all_files :: proc(dir: string) -> [dynamic]os.File_Info {
    file_list: [dynamic]os.File_Info

    fd, err := os.open(dir)
    defer os.close(fd)
    if err != os.ERROR_NONE {
        fmt.eprintln("Could not open directory", err)
        os.exit(2)
    }

    file_slice: []os.File_Info
    defer delete(file_slice) // file_slice is a slice, we need to remember to free it
    file_slice = read_slice(fd)

    differentiate(dir, &file_list, file_slice)

    return file_list
}

differentiate :: proc(dir:string, file_list: ^[dynamic]os.File_Info, files: []os.File_Info) {
    for &file in files {
        full_path := fmt.aprintf("%s/%s", dir, file.name)
        if file.is_dir {
            fmt.printfln("entering directory -> %s", full_path)
            more_files := get_all_files(full_path)
            differentiate(dir, file_list, more_files[:])
            fmt.printfln("leaving directory <- %s", full_path)
        } else {
            //file.name = full_path
            fmt.printfln(full_path)
            append(&file_list^, file)
        }
    }
}

read_slice :: proc(fd: os.Handle) -> []os.File_Info {
    file_slice, fserr := os.read_dir(fd, -1) // -1 reads all file infos
    if fserr != os.ERROR_NONE {
        fmt.eprintln("Could not read directory", fserr)
        os.exit(3)
    }
    return file_slice
}




virtual_file_system :: proc(path: string, file: ^[]u8) -> bool {
    data, ok := virtual_files[path]
    if ok {
        file^ = data
        return true
    } else {
        fmt.eprintfln("[%s] was not found in vfs", path)
    }
    return false
}

vfs :: proc "c" (path: cstring, length: ^c.int) -> rawptr {
    context = runtime.default_context()

    path_odin := string(path)
    length_odin: ^int = cast(^int)length

    file_data: []u8


    fmt.printfln("file_data before: %v", file_data)
    if virtual_file_system(path_odin, &file_data) {

        f, err := os.open(path_odin)
        defer os.close(f)
        fmt.printfln("vfs was TRUE")
        fmt.printfln("file_date after: %v", file_data)
        fmt.printfln("\n%s", path_odin)
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
        fmt.printfln("file_path: %s", redirect_path)
        if !strings.ends_with(redirect_path, "/") {
            redirect_path = strings.concatenate({redirect_path, "/"})
        }

        for i := 0; i < len(index_paths); i += 2 {
            if index_paths[i] == redirect_path {
                location_header: cstring = strings.unsafe_string_to_cstring("HTTP/1.1 302 Found\r\nLocation: %s\r\nCache-Control: no-cache\r\n\r\n")

                header_length: int = cast(int)libc.snprintf(nil, 0, location_header, index_paths[i+1])
                length_odin^ = header_length
                response: rawptr = ui.malloc(cast(uint)length_odin^)
                libc.snprintf(cast([^]u8)response, cast(uint)header_length + 1, location_header, index_paths[i + 1])
                return response
            }
        }

    }
    return nil
}
