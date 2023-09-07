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
    search_ctx_init(&ctx)
    defer search_ctx_destroy(&ctx)

    if root_handle, err := os.open(root, os.O_RDONLY); err == os.ERROR_NONE {
        search_tree(root_handle, &ctx)
    }

    // log.debugf("The search ctx: {}", ctx)

}




ExtMap :: #type map[string]([dynamic]i32)

SearchCtx :: struct { 
    buffer : strings.Builder,
    slice : [dynamic]i32,
    ext : ExtMap,
    date : [dynamic]i32,
}

search_ctx_init :: proc(ctx: ^SearchCtx) {
    strings.builder_init(&ctx.buffer)
}
search_ctx_destroy :: proc(using ctx: ^SearchCtx) {
    delete(slice)
    for k, v in ext do delete(v)
    delete(ext)
    delete(date)
    strings.builder_destroy(&buffer)
}

search_ctx_add :: proc(using ctx: ^SearchCtx, path: string) {
    strings.write_string(&ctx.buffer, path)
    append(&ctx.slice, cast(i32)strings.builder_len(ctx.buffer))
}

search_ctx_get_path :: proc(using ctx : ^SearchCtx, idx : i32) -> string {
    if idx >= auto_cast len(ctx.slice) do return ""
    begin := 0 if idx == 0 else ctx.slice[idx - 1]
    end := ctx.slice[idx]
    str := strings.to_string(ctx.buffer)
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
                log.debugf("Find file : {}", fi.fullpath)
                search_ctx_add(ctx, fi.fullpath)
            }
            // content,_ := os.read_entire_file_from_handle(file_handle)
            // defer delete(content)
            // append_content(writer, fmt.aprintf("{}{}", strings.to_string(prefix^), fi.name), content)
        } else {
            search_tree(file_handle, ctx)
            // _prefix_push(prefix, fi.name)
            // _pac_directory(writer, file_handle, prefix)
            // _prefix_pop(prefix)
        }
    } 
}