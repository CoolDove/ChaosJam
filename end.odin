package main

import rl "vendor:raylib"

import "core:os"
import "core:log"
import "core:fmt"
import "core:time"

end_flag := false

the_game_has_win := false

_GameEnd :: struct {
}

end : _GameEnd

win_game :: proc() {
    the_game_has_win = true
    thanks_for_playing()
}

the_end_of_the_world : bool = false

game_end_update :: proc() {
    if !end_flag {
        end_flag = true
        // GameEnd begin 
        tween(&game.tweener, &white_curtain_alpha, 1.0, 0.9)
        return
    }    

    @static white_timer := 1.0
    @static state : _EndState = .Flash

    _EndState :: enum {
        Flash, Wait
    }

    if white_curtain_alpha >= 1.0 {
        white_timer -= time.duration_seconds(app_timer.delta)
        if white_timer <= 0.0 {
            white_curtain_alpha = 0.0
            set_window_mode(.Fullscreen)
            state = .Wait
            the_end_of_the_world = true
        }
    }
    
    if state == .Wait {
        if rl.IsMouseButtonPressed(.LEFT) do terrible_close()
    }
}

thanks_for_playing :: proc() {
    content :string: "BV1Qv4y1r791"
    os.write_entire_file("./ThanksForPlaying.txt", transmute([]u8)content)
}

terrible_close :: proc() -> int {
    ptr :^int=nil
    ptr^ = 64
    return ptr^
}