package main
import "core:os"
import "core:path/filepath"
import "core:log"
import "core:time"
import "core:runtime"
import "core:strings"
import rl "vendor:raylib"




EatResult :: enum {
    Plain, Good, Bad, TooFresh, EatSelf, Win
}

EatRecord :: struct {
    path : strings.Builder,
    result : EatResult,
}

last_eat : EatRecord

eat :: proc(path: string) -> EatResult {
    if file, err := os.open(path, os.O_RDONLY); err == os.ERROR_NONE {
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
        stat, stat_err := os.fstat(file, context.temp_allocator)

        if stat_err != os.ERROR_NONE {
            result = .Bad
        }
        if created_time := time.diff(stat.creation_time, time.now()); time.duration_hours(created_time) < 24 {
            result = .TooFresh
        }

        if result == .Plain {// analyze eat result
            ext := filepath.ext(path)
            target_info := search_ctx.infos[game.target_file]
        
            if ext == filepath.ext(search_ctx_get_path(game.target_file)) {
                log.debugf("Eat: Same ext")
                result = .Good
            }
            if time.weekday(stat.modification_time) == time.weekday(target_info.mod_time) {
                log.debugf("Eat: Same weekday")
                result = .Good
            }

            if path == search_ctx_get_path(game.target_file) {
                result = .Win
            }

            if result != .Win {
                wkstr := weekday_string(stat.modification_time, allocator=context.temp_allocator)
                rl.SetWindowTitle(strings.clone_to_cstring(hex_encrypt_string(filepath.base(path)), context.temp_allocator))
            } else {
                rl.SetWindowTitle("You Win!!")
            }

            rip_file(clean_path, result == .Good || result == .Win, result==.Win)

            if !cheat_mode {
                os.remove(clean_path)
            }
        }

        if result == .Good || result == .Win {
            game.feed_satisfied += 1
            set_emotion(.Peace)
        } else {
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