package main


import c "core:c/libc"
import rl "vendor:raylib"


// when ODIN_OS == .Windows { foreign import stbiw "./stb_image_write.lib" }

// @(default_calling_convention="c", link_prefix="stbi_")
// foreign stbiw {
// 	write_png :: proc(filename: cstring, w, h, comp: c.int, data: rawptr, stride_in_bytes: c.int)     -> c.int ---
// }


save_img_as_png :: proc(path: cstring, width, height: i32, data: rawptr, allocator:=context.allocator) {
    rl.stbi_write_png(path, width, height, 4, data, 0)
}