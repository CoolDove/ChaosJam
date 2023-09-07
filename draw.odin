package main

import "core:time"
import "core:math"
import "core:log"
import "core:path/filepath"
import "core:os"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

draw :: proc() {
    rl.DrawTexture(TEX_JAM_IDLE, 30, 30, rl.WHITE)

    line := tk_current_line()
    if line != "" {
        cline := strings.clone_to_cstring(line)
        defer delete(cline)
        color :rl.Color= {128, 200, 60, auto_cast (255.0 * current_talk.show)}

        width := rl.MeasureText(cline, get_font_size())
        draw_text(cline, Vector2i{ app_info.width/2 - width/2, 400 }, color)
    }

    if game.state == .WaitForDrop {
        t := time.duration_seconds(app_timer.game_time)
        alpha := math.abs(math.sin(2.0 * t))
        alpha = alpha * 0.8+0.2
        color :rl.Color= {188, 188, 188, auto_cast (255.0 * alpha )}
        draw_text_center("Please drop a file.", 500, color)
    } else if game.state == .Finish_FailedToFindTarget {
        msg := fmt.ctprintf("目录{}太小了，换个地方开始游戏吧", filepath.dir(os.args[0]))
        draw_text_center(msg, 400, rl.RED, font_size=30)
    }


    if cheat_mode {
        cheat_msg := fmt.ctprintf("CHEATMODE\n-{}", strings.to_string(game.target_file))
        draw_text(cheat_msg, {10, 10}, rl.GREEN, font_size=26)
    }
    
}

draw_text :: proc(line: cstring, pos: Vector2i, color: rl.Color, font_size:i32=-1) {
    fsize :f32= auto_cast get_font_size() if font_size == -1 else auto_cast font_size
    rl.DrawTextEx(
        FONT_DEFAULT, 
        line, 
        vec_i2f(pos), 
        fsize,
        1.0,
        color)
}

draw_text_center :: proc(line: cstring, y : i32, color: rl.Color, font_size :i32= -1) {
    fsize :f32= auto_cast get_font_size() if font_size == -1 else auto_cast font_size
    width := rl.MeasureText(line, auto_cast fsize)
    pos := Vector2i{ app_info.width/2 - width/2, y }
    rl.DrawTextEx(
        FONT_DEFAULT, 
        line, 
        vec_i2f(pos), 
        fsize,
        1.0,
        color)
}