package main



import "core:os"
import "core:log"
import "core:runtime"
import "core:strings"
import rl "vendor:raylib"

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
        os.remove(path)
        return .Good
    }
    return .Bad
}
