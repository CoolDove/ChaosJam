package main
import "core:os"
import "core:path/filepath"
import "core:log"
import "core:time"
import "core:runtime"
import "core:strings"
import rl "vendor:raylib"




EatResult :: enum {
    Plain, Good, Bad, EatSelf
}

EatRecord :: struct {
    path : strings.Builder,
    result : EatResult,
}

last_eat : EatRecord

eat :: proc(path: string) -> EatResult {
    if file, ok := os.read_entire_file(path); ok {
        clean_path := filepath.clean(path)
        clean_self_path := filepath.clean(os.args[0])
        defer {
            delete(clean_path)
            delete(clean_self_path)
        }
        result : EatResult= .Plain

        if clean_path == clean_self_path { 
            result = .EatSelf 
        }

        if result == .Plain {// analyze eat result
            ext := filepath.ext(path)
            target_info := search_ctx.infos[game.target_file]
            
            if stat, err := os.stat(path); err == os.ERROR_NONE {
                if ext == filepath.ext(search_ctx_get_path(game.target_file)) {
                    log.debugf("Eat: Same ext")
                    result = .Good
                }
                if time.weekday(stat.modification_time) == time.weekday(target_info.mod_time) {
                    log.debugf("Eat: Same weekday")
                    result = .Good
                }

                wkstr := weekday_string(stat.modification_time, allocator=context.temp_allocator)
                rl.SetWindowTitle(strings.clone_to_cstring(hex_encrypt_string(filepath.base(path)), context.temp_allocator))
            }
            rip_file(clean_path, result == .Good)

            if !cheat_mode {
                os.remove(clean_path)
            }        
        }

        if result ==  .Good {
            game.feed_satisfied += 1
            set_emotion(.Peace)
        } else if result == .EatSelf || result == .Bad || result == .Plain {
            set_emotion(.Angry)
        }

        _update_last_eat(clean_path, result)


        return result
    }
    return .Bad
}

@(private="file")
_update_last_eat :: proc(path: string, result: EatResult) {
    strings.builder_reset(&last_eat.path)
    strings.write_string(&last_eat.path, path)
    last_eat.result = result
    log.debugf("last eat: {}", result)
}

Emotion :: enum {
    Peace,  Angry,
}
set_emotion :: proc(emotion: Emotion) {
    target :f32= 0 if emotion == .Angry else 180
    tween(&game.tweener, &emotion_value, target, 1.0)

    log.debugf("emo target: {}.{}", emotion, target)
}