package main

import "core:time"
import "core:math"
import "core:math/linalg"
import "core:log"
import "core:path/filepath"
import "core:os"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

draw :: proc() {
    rl.DrawTexture(TEX_JAM_IDLE, 0, 0, rl.WHITE)
    rl.DrawTexture(TEX_SUBTITLE_MASK, 0, 0, rl.WHITE)

    line := tk_current_line()
    if line != "" {
        cline := strings.clone_to_cstring(line)
        defer delete(cline)
        color :rl.Color= {128, 200, 60, auto_cast (255.0 * current_talk.show)}

        width := rl.MeasureText(cline, get_font_size())
        draw_text(cline, Vector2i{ 40, 460 }, color)
    }

    if game.state == .WaitForDrop {
        t := time.duration_seconds(app_timer.game_time)
        alpha := math.abs(math.sin(2.0 * t))
        alpha = alpha * 0.3+ 0.4
        color :rl.Color= {188, 188, 188, auto_cast (255.0 * alpha )}
        draw_text("Please drop a file.", {40, 460}, color)
    } else if game.state == .Finish_FailedToFindTarget {
        msg := fmt.ctprintf("目录{}太小了，换个地方开始游戏吧", filepath.dir(os.args[0]))
        draw_text_center(msg, 400, rl.RED, font_size=30)
    }
    
    {// Puzzle texture
        @static puzzle_texture_size :f32= 1.0
        if rl.IsTextureReady(puzzle_texture) {
            puzzle_texture_rect :rl.Rectangle= {0,0, cast(f32)puzzle_texture.width*0.5,cast(f32)puzzle_texture.height*0.5}
            if in_rect(puzzle_texture_rect, app_info.mouse_pos) && !in_rect(puzzle_texture_rect, app_info.mouse_pos_last) {
                tween(&game.tweener, &puzzle_texture_size, 1.0, 0.2)
                log.debugf("In")
            } else if !in_rect(puzzle_texture_rect, app_info.mouse_pos) && in_rect(puzzle_texture_rect, app_info.mouse_pos_last) {
                tween(&game.tweener, &puzzle_texture_size, 0.2, 0.2)
                log.debugf("Out")
            }

            puzzle_tex_color :rl.Color= {255,255,255,255}

            rl.DrawTextureEx(puzzle_texture, {0,0}, 0, puzzle_texture_size, rl.WHITE)
        }
    }

    if cheat_mode {
        cheat_msg := fmt.ctprintf("CHEATMODE\n-{}", search_ctx_get_path(game.target_file))
        draw_text(cheat_msg, {10, 10}, rl.GREEN, font_size=26)
    }
}

in_rect :: proc(rect: rl.Rectangle, pos: Vector2i) -> bool {
    pos := vec_i2f(pos)
    min :linalg.Vector2f32= {rect.x, rect.y}
    max :linalg.Vector2f32= {rect.x+rect.width, rect.y+rect.height}
    return !(pos.x > max.x || pos.x < min.x || pos.y > max.y || pos.y < min.y)
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