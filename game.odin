package main



import "core:os"
import "core:path/filepath"
import "core:log"
import "core:runtime"
import "core:strings"
import rl "vendor:raylib"


when ODIN_DEBUG {
INIT_CHEAT_MODE :: true
} else {
INIT_CHEAT_MODE :: false
}

cheat_mode : bool = true

Game :: struct {
    tweener : Tweener,
    state : GameState,

    target_file : i32,// refers to a idx in the search_ctx
}

GameState :: enum {
    Talk,
    WaitForDrop,
    Finish_FailedToFindTarget,
    Finish_TargetLost,
    Finish_Succeed,
}

game : Game

game_begin :: proc() {
    cheat_mode = INIT_CHEAT_MODE
    
    tweener_init(&game.tweener, 10)
    load_resources()

    strings.builder_init(&last_eat.path)


    search_ctx_init()

    if find_target_file() {
        _talk_init()
        talk_game_start()
    } else {
        game.state = .Finish_FailedToFindTarget
    }

}

game_end :: proc() {

    strings.builder_destroy(&last_eat.path)
    _talk_destroy()


    search_ctx_destroy()
    
    tweener_release(&game.tweener)
}


game_update :: proc(delta: f32) {
    tweener_update(&game.tweener, delta)
    cheat_mode_update()

    switch game.state {
    case .Talk:
        if rl.IsKeyPressed(.L) {
            log.debugf("the ctx: {}", search_ctx)
        }
        
        if _talk_update(delta) {
            rl.UnloadDroppedFiles(rl.LoadDroppedFiles())
            game.state = .WaitForDrop
        }
    case .WaitForDrop:
        if rl.IsFileDropped() {
            filepath_list := rl.LoadDroppedFiles()
            defer rl.UnloadDroppedFiles(filepath_list)
            path := filepath_list.paths[0]
            result := eat(cast(string)path)

            switch result {
            case .Bad:
                talk_resp_eat_bad()
            case .Good:
                talk_resp_eat_good()
            case .Plain:
                talk_resp_eat_plain()
            case .EatSelf:
                talk_resp_eat_self()
            }
        }

        // debug
        if cheat_mode && rl.IsMouseButtonPressed(.RIGHT) {
            talk_resp_eat_good()
            game.state = .Talk
        }
    case .Finish_FailedToFindTarget:
    case .Finish_TargetLost:
    case .Finish_Succeed:
        if rl.GetKeyPressed() != .KEY_NULL {
            rl.CloseWindow()
        }
    }
}

cheat_mode_update :: proc() {
    using rl
    @static cheat_mode_state : i32 = 0
    switch cheat_mode_state {
    case 0:
        if IsKeyPressed(.K) {
            cheat_mode_state = 1            
        } else if GetKeyPressed() != .KEY_NULL {
            cheat_mode_state = 0
        }
    case 1:
        if IsKeyPressed(.K) {
            cheat_mode_state = 2            
        } else if GetKeyPressed() != .KEY_NULL {
            cheat_mode_state = 0
        }
    case 2:
        if IsKeyPressed(.S) {
            cheat_mode_state = 3            
        } else if IsKeyPressed(.K) {
            cheat_mode_state = 2
        } else if GetKeyPressed() != .KEY_NULL {
            cheat_mode_state = 0
        }
    case 3:
        if IsKeyPressed(.K) {
            cheat_mode_state = 0
            cheat_mode = !cheat_mode
        } else if GetKeyPressed() != .KEY_NULL {
            cheat_mode_state = 0
        }
    }

}