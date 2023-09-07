package main


import "core:log"
import "core:mem"
import "core:math/rand"
import "core:slice"
import "core:runtime"
import "core:bytes"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:path/filepath"



VALID_EXT :: []string {
    ".txt",
    ".c",
    ".cpp",
    ".cs",
    ".py",
    ".js",
    ".ts",
    ".html",
    ".css",
    ".obj",
    ".odin",
    ".md",
    ".yml",
    ".xml",
    ".yaml",
    ".toml",
    ".sql",
    ".ini",

    ".exe",
    ".dll",
    ".lib",

    ".png",
    ".psd",
    ".tga",
    ".jpg",
    ".zip",
    ".rar",
    ".7z",

    ".ttf",
    ".wav",
    ".mp3",
}

is_file_ext_vaild :: proc(file: string) -> bool {
    ext := filepath.ext(file)
    for e in VALID_EXT {
        if ext == e { return true }
    }
    return false
}


find_target_file :: proc(builder: ^strings.Builder) {
    pwd := os.args[0]

    root := filepath.dir(pwd)
    
    strings.write_string(builder, root)
    ctx : SearchCtx
    search_ctx_init()

    if root_handle, err := os.open(root, os.O_RDONLY); err == os.ERROR_NONE {
        search_tree(root_handle, &ctx)
    }
    search_analyze()
}

ExtMap :: #type map[string]([dynamic]i32)

SearchCtx :: struct { 
    buffer : strings.Builder `fmt:"-"`,
    slice : [dynamic]i32, // slices
    ext : ExtMap, // grouped by extension
    date : [dynamic]i32, // sorted by date
    abandoned_idx : [dynamic]i32,
}

search_ctx : SearchCtx

search_ctx_init :: proc() {
    strings.builder_init(&search_ctx.buffer)
}
search_ctx_destroy :: proc() {
    using search_ctx
    search_ctx_clear_analyze_result()
    strings.builder_destroy(&buffer)
    delete(slice)
}

search_ctx_clear_analyze_result :: proc() {
    using search_ctx
    for k, v in ext do delete(v)
    delete(ext)
    delete(date)
}

search_ctx_add :: proc(path: string) {
    using search_ctx
    strings.write_string(&buffer, path)
    append(&slice, cast(i32)strings.builder_len(buffer))
}

search_analyze :: proc() {
    using search_ctx
    for i in 0..<len(slice) {
        idx := cast(i32)i
        path := search_ctx_get_path(idx)
        extension := filepath.ext(path)
        if !(extension in ext) {
            ext[extension] = make([dynamic]i32)
        }
        append(&ext[extension], idx)
    }
}

search_ctx_get_path :: proc(idx : i32) -> string {
    using search_ctx
    if idx >= auto_cast len(slice) do return ""
    begin := 0 if idx == 0 else slice[idx - 1]
    end := slice[idx]
    str := strings.to_string(buffer)
    return str[begin:end]
}

search_tree :: proc(dir: os.Handle, ctx: ^SearchCtx) {
    stat, stat_err := os.fstat(dir)
    if stat_err != os.ERROR_NONE do return
    fis, read_dir_err := os.read_dir(dir, 0)
    defer delete(fis) 

    for fi in fis  {
        file_handle,_ := os.open(fi.fullpath, os.O_RDONLY)
        defer os.close(file_handle)
        if !fi.is_dir {
            // is file
            if is_file_ext_vaild(fi.fullpath) {
                search_ctx_add(fi.fullpath)
            }
        } else {
            search_tree(file_handle, ctx)
        }
    } 
}