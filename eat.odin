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

        if clean_path == clean_self_path { return .EatSelf }

        result : EatResult= .Plain

        {// analyze eat result
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
            }
        }

        _update_last_eat(clean_path)

        if !cheat_mode {
            os.remove(clean_path)
        }
        return result
    }
    return .Bad
}


@(private="file")
_update_last_eat :: proc(path: string) {
    strings.builder_reset(&last_eat.path)
    strings.write_string(&last_eat.path, path)
    log.debugf("I ate: {}.", path)
}