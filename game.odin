package main



import "core:os"
import "core:log"
import "core:runtime"
import "core:strings"
import rl "vendor:raylib"



cheat_mode : bool = true

Game :: struct {
    tweener : Tweener,
    state : GameState,
}

GameState :: enum {
    Talk,
    WaitForDrop,
}

game : Game

game_begin :: proc() {
    tweener_init(&game.tweener, 10)
    load_resources()

    strings.builder_init(&last_eat.path)

    _talk_init()

}

game_end :: proc() {
    strings.builder_destroy(&last_eat.path)
    _talk_destroy()
    tweener_release(&game.tweener)
}

game_update :: proc(delta: f32) {
    tweener_update(&game.tweener, delta)
    cheat_mode_update()

    switch game.state {
    case .Talk:
        if _talk_update(delta) {
            game.state = .WaitForDrop
        }
    case .WaitForDrop:
        if rl.IsFileDropped() {
            filepath_list := rl.LoadDroppedFiles()
            defer rl.UnloadDroppedFiles(filepath_list)
            path := filepath_list.paths[0]
            result := eat(cast(string)path)

            if result == .Good {
                talk_resp_eat_good()
            } else {
                talk_resp_eat_bad()
            }
        }

        // debug
        if rl.IsMouseButtonPressed(.RIGHT) {
            talk_resp_eat_good()
            game.state = .Talk
        }
    }
}

EatResult :: enum {
    Plain, Good, Bad,
}

EatRecord :: struct {
    path : strings.Builder,
}

last_eat : EatRecord

eat :: proc(path: string) -> EatResult {
    if file, ok := os.read_entire_file(path); ok {
        strings.builder_reset(&last_eat.path)
        strings.write_string(&last_eat.path, path)
        log.debugf("I ate: {}.", path)

        if !cheat_mode {
            os.remove(path)
        }
        return .Good
    }
    return .Bad
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