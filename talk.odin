package main

import "core:log"
import "core:strings"
import rl "vendor:raylib"


StatePhase :: enum {
    Enter, Update, Exit,
}


TalkContext :: struct {
    lines : strings.Builder,
    slice : [dynamic]i32,
    idx : i32,

    // visual things.
    tween : TweenRef,
}

current_talk : TalkContext

// return : finish
_talk_begin :: proc() {
    strings.builder_init(&current_talk.lines)
    current_talk.slice = make([dynamic]i32)
}
_talk_update :: proc(delta: f32) -> bool {
    if rl.IsKeyPressed(.ENTER) || rl.IsMouseButtonPressed(.LEFT) {
        current_talk.idx += 1
    }
    return current_talk.idx >= tk_count()
}
_talk_end :: proc() {
    strings.builder_destroy(&current_talk.lines)
    delete(current_talk.slice)
}

tk_current_line :: proc() -> string {
    return tk_get_line(current_talk.idx)
}
tk_get_line :: proc(idx : i32) -> string {
    using strings
    if idx >= tk_count() do return ""
    str := to_string(current_talk.lines)
    begin := 0 if idx == 0 else current_talk.slice[idx - 1]
    end := current_talk.slice[idx]
    return str[begin:end]
}
tk_count :: #force_inline proc() -> i32 {
    return auto_cast len(current_talk.slice)
}

tk_clear :: proc() {
    strings.builder_reset(&current_talk.lines)
    clear(&current_talk.slice)
    current_talk.idx = 0
    // tween_cancel(current_talk.tween)
}
tk_push :: proc(content: string) {
    using current_talk, strings
    write_string(&lines, content)
    append(&slice, cast(i32)builder_len(lines))
}

talk_resp_eat_good :: proc() {
    tk_clear()
    tk_push("Hello, 1")
    tk_push("Good morning!")
    tk_push("Good night")
}

talk_resp_eat_bad :: proc() {
    tk_clear()
    tk_push("I ate bad")
    tk_push("bye")
}