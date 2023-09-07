package main

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

        draw_text(cline, Vector2i{ app_info.width/2 - width/2, 600 }, color)
    }

    if game.state == .WaitForDrop {
        rl.DrawText("Please drop a file.", 300, 400, 40, rl.WHITE)
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