package main

import "core:strings"
import rl "vendor:raylib"

draw :: proc() {
    rl.DrawTexture(TEX_JAM_IDLE, 30, 30, rl.WHITE)

    line := tk_current_line()
    if line != "" {
        cline := strings.clone_to_cstring(line)
        defer delete(cline)
        width := rl.MeasureText(cline, get_font_size())

        rl.DrawTextEx(
            FONT_DEFAULT, 
            cline, 
            vec_i2f(Vector2i{ app_info.width/2 - width/2, 600 }), 
            auto_cast get_font_size(),
            1.0,
            rl.RED)
    }

    if game.state == .WaitForDrop {
        rl.DrawText("Please drop a file.", 300, 400, 40, rl.WHITE)
    }
}