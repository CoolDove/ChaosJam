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
    draw_scene()

    line := tk_current_line()
    subtitle_height:i32= 483
    if line != "" {
        cline := strings.clone_to_cstring(line)
        defer delete(cline)
        color :rl.Color= {89, 214, 133, auto_cast (255.0 * current_talk.show)}

        draw_text(cline, Vector2i{ 40, subtitle_height }, color)
    }

    if game.state == .WaitForDrop  && !puzzle_texture_wait_for_click {
        t := time.duration_seconds(app_timer.game_time)
        alpha := math.abs(math.sin(2.0 * t))
        alpha = alpha * 0.3+ 0.4
        color :rl.Color= {188, 188, 188, auto_cast (255.0 * alpha )}
        draw_text("Please drop a file.", {40, subtitle_height}, color)
    } else if game.state == .Finish_FailedToFindTarget {
        msg := fmt.ctprintf("目录{}太小了，换个地方开始游戏吧", filepath.dir(os.args[0]))
        draw_text_center(msg, 400, rl.RED, font_size=30)
    }

    draw_feed_state(457)

    {// Puzzle texture
        @static puzzle_texture_size :f32= 1.0
        if rl.IsTextureReady(puzzle_texture) {
            if !puzzle_texture_wait_for_click {
                puzzle_texture_rect :rl.Rectangle= {0,0, cast(f32)puzzle_texture.width*0.8,cast(f32)puzzle_texture.height*0.8}
                if in_rect(puzzle_texture_rect, app_info.mouse_pos) && !in_rect(puzzle_texture_rect, app_info.mouse_pos_last) {
                    tween(&game.tweener, &puzzle_texture_size, 1.0, 0.2)->set_easing(ease_outcubic)
                } else if !in_rect(puzzle_texture_rect, app_info.mouse_pos) && in_rect(puzzle_texture_rect, app_info.mouse_pos_last) {
                    tween(&game.tweener, &puzzle_texture_size, 0.2, 0.2)->set_easing(ease_outcubic)
                }
            } else if rl.GetKeyPressed() != .KEY_NULL || rl.IsMouseButtonPressed(.LEFT) {
                puzzle_texture_wait_for_click = false
                tween(&game.tweener, &puzzle_texture_size, 0.2, 0.2)->set_easing(ease_outcubic)
            }

            puzzle_tex_color :rl.Color= {255,255,255, cast(u8)(255 * (puzzle_texture_size * 0.8 + 0.2))}

            rl.DrawRectangle(0,0,app_info.width, app_info.height, {0,0,0, cast(u8)(255 * (puzzle_texture_size * 0.6))})
            rl.DrawTextureEx(puzzle_texture, {0,0}, 0, puzzle_texture_size, puzzle_tex_color)

        }
    }

    if cheat_mode {
        cheat_msg := fmt.ctprintf(
            "CHEATMODE\n-{}\nqr piece idx: {}", 
            search_ctx_get_path(game.target_file),
            qr_piece_idx,
        )
        draw_text(cheat_msg, {10, 10}, rl.GREEN, font_size=26)
    }
}


draw_scene :: proc() {
    rl.DrawTexture(TEX_BACKGROUND, 0, 0, rl.WHITE)
    rl.DrawTexture(TEX_GHOST_PEACE, 0, 0, rl.WHITE)

    draw_emotion_wheel()
    
    rl.DrawTexture(TEX_SUPPORT_BACK, 0, 0, rl.WHITE)
    t := time.duration_seconds(app_timer.game_time)

    jam_freq := 1.4 if last_eat.result == .Good else 2.5
    jam_offset := -math.sin(jam_freq * t) * 12 - 15

    rl.DrawTexture(TEX_JAM, 0, cast(i32)jam_offset, rl.WHITE)
    rl.DrawTexture(TEX_SUPPORT_FORE, 0, 0, rl.WHITE)
    rl.DrawTexture(TEX_FRAME, 0, 0, rl.WHITE)
}

emotion_value : f32 = 180
draw_emotion_wheel :: proc() {
    t :f32= auto_cast time.duration_seconds(app_timer.game_time)
    draw_texture(TEX_WHEEL, {app_info.width/2, app_info.height/2}, emotion_value, {0.5, 0.5})
}

draw_feed_state :: proc(height: i32) {
    if game.feed_requirement <= 1 do return
    for i in 0..<game.feed_requirement {
        posx := i * 54 + 53
        if i < game.feed_satisfied {
            draw_texture(TEX_STAR_ON, {posx, height}, 0, {0.5, 0.5})
        } else {
            draw_texture(TEX_STAR_OFF, {posx, height}, 0, {0.5, 0.5})
        }
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
    width :i32= auto_cast rl.MeasureTextEx(FONT_DEFAULT, line, auto_cast fsize, 0).x
    pos := Vector2i{ app_info.width/2 - width/2, y }
    rl.DrawTextEx(
        FONT_DEFAULT, 
        line, 
        vec_i2f(pos), 
        fsize,
        1.0,
        color)
}

draw_texture :: proc(texture: rl.Texture2D, pos: Vector2i, angle: f32, anchor: linalg.Vector2f32, color:= rl.WHITE) {
    using rl
    src_rect :Rectangle= {0,0, cast(f32)texture.width,  cast(f32)texture.height}
    dst_rect :Rectangle= {cast(f32)pos.x, cast(f32)pos.y, cast(f32)texture.width,  cast(f32)texture.height}
    anc :linalg.Vector2f32= {anchor.x * dst_rect.width, anchor.y * dst_rect.height}
    DrawTexturePro(texture, src_rect, dst_rect, anc, angle, color)
}