package virtual_file_system

import ui "../../"
import "core:c"
import "core:fmt"
import "base:runtime"
import "core:path/filepath"


VirtualFile :: struct {
    path: cstring,
    data: [dynamic]u8,
    length: i32,
}

virtual_files := [dynamic]VirtualFile {
    VirtualFile {
        path = "",
        data = {},
        length = 0,
    },
    VirtualFile {
        path = "",
        data = {},
        length = 0,
    },
}


index_files := [dynamic]cstring {

}

get_all_files :: proc(dir: string) {
// https://pkg.odin-lang.org/core/path/filepath/
//    filepath.walk(
//        dir,
//        filepath.Walk_Proc(
//
//        )
//    )
}

virtual_file_system :: proc (path: cstring, file: ^[dynamic]u8) -> bool {
    return false
}

vfs :: proc "c" (path: cstring, length: ^c.int) -> rawptr {
    context = runtime.default_context()
    return nil
}

