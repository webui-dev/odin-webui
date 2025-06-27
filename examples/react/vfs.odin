package react

import ui "../../"
import "core:fmt"
import "base:runtime"
import "core:strings"
import "core:os"


virtual_files := make(map[string][]byte) // map container of the virtual file system
index_paths := make([dynamic]string) // dynamic array to hold index_files/paths


// Function to walk a directory and populate virtual_files and index_paths
build_virtual_file_system :: proc(root_dir: string) {
	dir_stack: [dynamic]string // stack like array for creating rel paths as we traverse files
	append(&dir_stack, root_dir)

	// loop through stack-like array till empty
	for len(dir_stack) > 0 {
		current_dir: string = pop(&dir_stack)
		//fmt.printfln("Current Directory: %s\n", current_dir)

		file_handle, err := os.open(current_dir)
		if err != os.ERROR_NONE {
		// Print error to stderr and exit with error code
			fmt.eprintln("Could not open directory for reading", err)
			os.exit(1)
		}
		defer(os.close(file_handle))

		entries, dir_err := os.read_dir(file_handle, -1)
		if dir_err != nil {
			fmt.eprintfln("os.read_dir(file_handle, -1) for getting entries failed")
		}
		defer(delete(entries))

		for entry in entries {
			if entry.name == "." || entry.name == ".." {
				break
			}

			fullpath: string = strings.concatenate({current_dir, "/", entry.name})

			if !entry.is_dir {
				data, pass := os.read_entire_file_from_filename(fullpath)
				if !pass {
					fmt.eprintfln("File did not open: %s", fullpath)
					break
				}

				proper_path, _ := strings.remove_all(fullpath, root_dir) // don't include the root directory in the full path
				virtual_files[proper_path] = data

				if strings.contains(entry.name, "index.") {
					append(&index_paths, proper_path) // add index file to index_paths
				}
			} else {
				append(&dir_stack, fullpath) // add directory to stack to loop through
				append(&index_paths, strings.concatenate({"/", entry.name, "/"})) // add to index_paths/files
			}
		}
	}
}


virtual_file_system :: proc(path: cstring, file_data: ^[]byte) -> bool {
	data, ok := virtual_files[string(path)]
	if ok {
		file_data^ = data
		return true
	} else {
		fmt.eprintfln("[%s] was not found in vfs map", path)
	}
	return false
}


vfs :: proc "c" (path: cstring, length: ^i32) -> rawptr {
	context = runtime.default_context()

	file_data: []byte

	// Try to retrieve the file from the virtual file system
	if virtual_file_system(path, &file_data) {
	// Get content type of file
		content_type: string = string(ui.get_mime_type(path))

		// header template buffer and length of the header
		http_header_template: string = fmt.aprintf("HTTP/1.1 200 OK\r\nContent-Type: %s\r\nContent-Length: %d\r\nCache-Control: no-cache\r\n\r\n", content_type, len(file_data))
		header_length: i32 = i32(len(http_header_template))

		// new length of packet for both header and file accomidated
		length^ = header_length + i32(len(file_data))

		file_data_str: string = strings.clone_from_bytes(file_data)

		// Concatenate header_template and file_data to a single string, transmute into a byte array,
		// get the raw data of the bytearray to have a multipointer and then get the the raw pointer of
		// the multipointer to return
		response: rawptr = rawptr(raw_data(transmute([]u8)strings.concatenate({http_header_template, file_data_str})))

		return response
	} else {
	// Check for index file redirection
		redirect_path: string = string(path)
		redirect_length: uint = cast(uint)len(redirect_path)

		if redirect_path[redirect_length - 1] != '/' {
			redirect_path = strings.concatenate({redirect_path, "/"})
		}

		for idx_file, idx in index_paths {
			if strings.compare(idx_file, redirect_path) == 0 {
				location_header: string = fmt.aprintf("HTTP/1.1 302 Found\r\nLocation: %s\r\nCache-Control: no-cache\r\n\r\n", index_paths[idx+1])
				length^ = i32(len(location_header))
				response: rawptr = rawptr(raw_data(transmute([]u8)location_header))
				return response
			}
		}
	}
	return nil
}
