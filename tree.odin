package main


import "core:log"
import "core:mem"
import "core:sort"
import "core:slice"
import "core:math"
import "core:math/rand"
import "core:runtime"
import "core:bytes"
import "core:time"
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


find_target_file :: proc(builder: ^strings.Builder) -> bool {
    pwd := os.args[0]

    root := filepath.dir(pwd)
    
    // strings.write_string(builder, root)
    ctx : SearchCtx
    search_ctx_init()

    if root_handle, err := os.open(root, os.O_RDONLY); err == os.ERROR_NONE {
        search_tree(root_handle, &ctx)
    }
    search_analyze()

    if len(search_ctx.ext) < 5 do return false

    {// pick the target file
        candidate : [dynamic]i32 = make([dynamic]i32)
        defer delete(candidate)
        using search_ctx

        // sorted_ext_key : [dynamic]string = make([dynamic]string)
        // defer delete(sorted_ext_key)
        for k, v in ext {
            // append(&sorted_ext_key, k)
            if len(v) > 3 { append(&candidate, ..v[:]) }
        }
        // slice.sort_by(sorted_ext_key[:], proc(i,j: string)->bool {
        //     return len(ext[i]) < len(ext[j])
        // })

        // target_ext := sorted_ext_key[len(sorted_ext_key)/2]

        // for idx in ext[target_ext] {
        for idx, i in candidate {
            weekday := time.weekday(infos[idx].mod_time)
            if wkgroup, ok := weekday_grouped[weekday]; ok {
                if len(wkgroup) <= 3 {
                    unordered_remove(&candidate, i)
                    // strings.write_string(builder, path)
                    // return true
                }
            }
        }

        if len(candidate) < 1 do return false

        log.debugf("Candidates: {}", len(candidate))
        r := rand.float32() * 0.99

        target := candidate[cast(int) (cast(f32)len(candidate) * r)]
        strings.write_string(builder, search_ctx_get_path(target))
        return true
    }

    return false
}

ExtMap :: #type map[string]([dynamic]i32)
WeekdayMap :: #type map[time.Weekday]([dynamic]i32)

SearchCtx :: struct { 
    buffer : strings.Builder `fmt:"-"`,

    infos : [dynamic]GameFileInfo `fmt:"-"`,
    
    fragments : [dynamic]i32 `fmt:"-"`, // fragmentss
    
    ext : ExtMap, // grouped by extension

    weekday_grouped : WeekdayMap,
    mod_time_sorted : [dynamic]i32,

    abandoned_idx : [dynamic]i32,
}
GameFileInfo :: struct {
    mod_time : time.Time,
    size : i64,
}

search_ctx : SearchCtx

search_ctx_init :: proc() {
    strings.builder_init(&search_ctx.buffer)
}
search_ctx_destroy :: proc() {
    using search_ctx
    search_ctx_clear_analyze_result()
    strings.builder_destroy(&buffer)
    delete(fragments)
}

search_ctx_clear_analyze_result :: proc() {
    using search_ctx
    for k, v in ext do delete(v)
    delete(ext)
    delete(mod_time_sorted)
}

search_ctx_add :: proc(path: string, info : GameFileInfo) {
    using search_ctx
    strings.write_string(&buffer, path)
    append(&fragments, cast(i32)strings.builder_len(buffer))
    append(&infos, info)
}

search_analyze :: proc() {
    using search_ctx
    for i in 0..<len(fragments) {
        // extension
        idx := cast(i32)i
        path := search_ctx_get_path(idx)
        extension := filepath.ext(path)
        if !(extension in ext) {
            ext[extension] = make([dynamic]i32)
        }
        append(&ext[extension], idx)

        // weekday
        wkday := time.weekday(infos[idx].mod_time)
        if !(wkday in weekday_grouped) {
            weekday_grouped[wkday] = make([dynamic]i32)
        }
        append(&weekday_grouped[wkday], idx)

        // prepare for mod_time_sorted
        append(&mod_time_sorted, idx)
    }

    comp :: proc(i,j: i32) -> bool {
        using search_ctx
        return infos[i].mod_time._nsec < infos[j].mod_time._nsec
    }
    slice.sort_by(mod_time_sorted[:], comp)
}

search_ctx_get_path :: proc(idx : i32) -> string {
    using search_ctx
    if idx >= auto_cast len(fragments) do return ""
    begin := 0 if idx == 0 else fragments[idx - 1]
    end := fragments[idx]
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
            if is_file_ext_vaild(fi.fullpath) && fi.fullpath != os.args[0] {
                search_ctx_add(fi.fullpath, 
                    GameFileInfo {
                        mod_time = fi.modification_time,
                        size = fi.size,
                    }
                )
            }
        } else {
            search_tree(file_handle, ctx)
        }
    } 
}