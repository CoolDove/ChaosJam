package main

import "core:time"
import "core:math"
import "core:log"
import "core:strings"
import rl "vendor:raylib"

draw :: proc() {
    rl.DrawTexture(TEX_JAM_IDLE, 30, 30, rl.WHITE)

    line := tk_current_line()
    if line != "" {
        cline := strings.clone_to_cstring(line)
        defer delete(cline)
        width := rl.MeasureText(cline, get_font_size())

        color :rl.Color= {128, 200, 60, auto_cast (255.0 * current_talk.show)}

        draw_text(cline, Vector2i{ app_info.width/2 - width/2, 400 }, color)
    }

    if game.state == .WaitForDrop {
        t := time.duration_seconds(app_timer.game_time)
        alpha := math.abs(math.sin(2.0 * t))
        alpha = alpha * 0.8+0.2
        color :rl.Color= {188, 188, 188, auto_cast (255.0 * alpha )}
        draw_text_center("Please drop a file.", 400, color)
    }

    if cheat_mode {
        draw_text("CHEATMODE", {10, 10}, rl.GREEN)
        // rl.DrawTextEx(
        // )
    }
    
}

draw_text :: proc(line: cstring, pos: Vector2i, color: rl.Color) {
    rl.DrawTextEx(
        FONT_DEFAULT, 
        line, 
        vec_i2f(pos), 
        auto_cast get_font_size(),
        1.0,
        color)
}

draw_text_center :: proc(line: cstring, y : i32, color: rl.Color) {
    width := rl.MeasureText(line, get_font_size())
    pos := Vector2i{ app_info.width/2 - width/2, y }
    rl.DrawTextEx(
        FONT_DEFAULT, 
        line, 
        vec_i2f(pos), 
        auto_cast get_font_size(),
        1.0,
        color)
}