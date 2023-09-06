package main

import "core:fmt"
import "core:log"
import "core:strings"
import rl "vendor:raylib"


TalkContext :: struct {
    lines : strings.Builder,
    slice : [dynamic]i32,
    idx : i32,
    show : f32,// [0,1]

    // visual things.
    // tween : TweenRef,
}

current_talk : TalkContext

// return : finish
_talk_init :: proc() {
    strings.builder_init(&current_talk.lines)
    current_talk.slice = make([dynamic]i32)
}
_talk_begin :: proc() {
    game.state = .Talk
    current_talk.show = 0.0
    tween(&game.tweener, &current_talk.show, 1.0, 0.2)
}
_talk_update :: proc(delta: f32) -> bool {
    if rl.IsKeyPressed(.ENTER) || rl.IsMouseButtonPressed(.LEFT) {
        current_talk.idx += 1
        current_talk.show = 0.0
        tween(&game.tweener, &current_talk.show, 1.0, 0.2)
    }

    return current_talk.idx >= tk_count()
}
_talk_destroy :: proc() {
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
    tk_push(fmt.tprintf("茧吃掉了你的\n\"{}\"。", strings.to_string(last_eat.path)))
    tk_push("茧缩紧了身体，\n发出一阵剧烈的颤抖，\n随后平静了下来。")
    tk_push("它说道：食物我喜欢，想要更多exe")
    tk_push("Good night")
    tk_push("Good dd")
    _talk_begin()
}

talk_resp_eat_bad :: proc() {
    tk_clear()
    tk_push("I ate bad")
    tk_push("bye")
    _talk_begin()
}


// talks
// TALK_BEGIN :: proc() -> []string {
//     talk :: []string {
//         "你的电脑里出现了一只丑陋的茧......",
//         "他的口状器官微微翕动，露出一圈锋利的牙齿，从中发出微弱的声音：\nV我50",
//     }
//     return talk
// }