package main



import "core:os"
import "core:path/filepath"
import "core:log"
import "core:runtime"
import "core:unicode/utf8"
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

    puzzle_arranged : bool,

    fail_count : i32,
    mercy_tipped : bool,

    feed_requirement, feed_satisfied : i32,
    
}

GameState :: enum {
    Talk,
    WaitForDrop,
    Puzzle,
    Finish_FailedToFindTarget,
    Finish_TargetLost,
    Finish_Succeed,
}

game : Game



game_begin :: proc() {
    cheat_mode = INIT_CHEAT_MODE

    icon_img := rl.LoadImageFromMemory(".png", raw_data(RAW_PNG_ICON), auto_cast len(RAW_PNG_ICON))
    defer rl.UnloadImage(icon_img)
    rl.SetWindowIcon(icon_img)
    
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

    hexmap_build()

    set_feed(get_puzzle_requirements_feed())
}

game_end :: proc() {
    strings.builder_destroy(&last_eat.path)
    _talk_destroy()

    search_ctx_destroy()
    tweener_release(&game.tweener)
    // tree_secret_sheet_destroy()
}

game_update :: proc(delta: f32) {
    tweener_update(&game.tweener, delta)
    cheat_mode_update()

    if cheat_mode  {
        if rl.IsKeyPressed(.L) {
            log.debugf("the ctx: {}", search_ctx)
        }
        if rl.IsKeyPressed(.N) {
            os.write_entire_file("./DEV_HEXSHEET.txt", transmute([]u8)hex_sheet())
        }
        if rl.IsKeyPressed(.U) {
            qr_rip_mode_begin()
        }

        if rl.IsKeyPressed(.P) {
            puzzle_extension()
        }
        if rl.IsKeyPressed(.E) {
            win_game()
        }
    }

    switch game.state {
    case .Talk:
        if _talk_update(delta) {
            rl.UnloadDroppedFiles(rl.LoadDroppedFiles())
            if reset_feed_flag {
                game.feed_requirement = reset_feed
                game.feed_satisfied = 0
                reset_feed = -1
                reset_feed_flag = false
            }
            if game.puzzle_arranged {
                game.state = .Puzzle
            } else if the_game_has_win {
                game.state = .Finish_Succeed
            } else {
                game.state = .WaitForDrop
            }
        }
    case .WaitForDrop:
        cheat_drop := false
        cheat_drop_file : string
        if cheat_mode && rl.IsMouseButtonPressed(.LEFT) && last_eat.result == .Good {
            cheat_drop = true
            cheat_drop_file = strings.to_string(last_eat.path)
        }
        if !puzzle_texture_wait_for_click && (rl.IsFileDropped() || cheat_drop) {
            filepath_list := rl.LoadDroppedFiles()
            defer rl.UnloadDroppedFiles(filepath_list)
            path :cstring

            if cheat_drop do path = strings.clone_to_cstring(cheat_drop_file, context.temp_allocator)
            else do path = filepath_list.paths[0]

            if os.is_file(cast(string)path) {
                result := eat(cast(string)path)
                switch result {
                case .Bad:
                    talk_resp_eat_bad()
                case .Good:
                    if game.feed_satisfied >= game.feed_requirement {
                        arrange_puzzle()
                    }
                    talk_resp_eat_good()
                case .Plain:
                    game.fail_count += 1 
                    if !game.mercy_tipped && game.fail_count >= 2 {
                        game.mercy_tipped = true;
                        arrange_puzzle()
                    }
                    talk_resp_eat_plain()
                case .EatSelf:
                    talk_resp_eat_self()
                case .TooFresh:
                    talk_resp_eat_too_fresh()
                case .Win:
                    win_game()
                    talk_win()
                }
            }
        }
        // debug
    case .Puzzle:
        if puzzle() {
            talk_puzzle()
            set_feed(get_puzzle_requirements_feed())
        } else {
            talk_no_puzzle()
            set_feed(0)
        }
        game.puzzle_arranged = false
    case .Finish_FailedToFindTarget:
    case .Finish_TargetLost:
    case .Finish_Succeed:
        game_end_update()
    }
}

reset_feed : i32
reset_feed_flag : bool


set_feed :: proc(require: i32) {
    reset_feed = require
    reset_feed_flag = true
}

arrange_puzzle :: proc() {
    game.puzzle_arranged = true
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

get_target_info :: proc() -> GameFileInfo {
    return search_ctx.infos[game.target_file]
}