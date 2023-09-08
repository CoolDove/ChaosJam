package main

import "core:log"
import "core:mem"
import "core:sort"
import "core:slice"
import "core:math"
import "core:math/rand"
import "core:runtime"
import "core:bytes"
import "core:time"
import "core:fmt"
import "core:os"
import "core:reflect"
import "core:strings"
import "core:unicode/utf8"
import "core:path/filepath"

import rl "vendor:raylib"

_puzzle_sheet : []proc() = {
    puzzle_weekday,
    puzzle_extension,
    puzzle_tree,
}
_require_sheet : []i32 = {
    1,
    3,
    5,
}
_puzzle_idx := 0

get_puzzle_requirements_feed :: proc() -> i32 {
    return _require_sheet[_puzzle_idx]
}

puzzle :: proc() -> bool {
    if _puzzle_idx >= len(_puzzle_sheet) do return false
    _puzzle_sheet[_puzzle_idx]()
    _puzzle_idx += 1
    return true
}


WEEKDAY_MAP := []rune {
	'S',
	'M',
	'T',
	'W',
	'T',
	'F',
	'S',
}

puzzle_weekday :: proc() {
    os.write_entire_file("./secret.txt", transmute([]u8)weekday_string(get_target_info().mod_time))
}

weekday_string :: proc(t : time.Time, allocator:=context.allocator) -> string {
    context.allocator = allocator
    msg :[7]rune = {'日','月','火','水','木','金','土'} 

    wkday_values := reflect.enum_field_values(time.Weekday)
    target_wkday := time.weekday(t)
    for wv in wkday_values {
        if auto_cast wv == target_wkday do msg[wv] = '?'
    }
    return utf8.runes_to_string(msg[:])
}

puzzle_texture : rl.Texture2D
puzzle_texture_wait_for_click : bool = false

puzzle_extension :: proc() {
    // get_target_info()
    target_path := search_ctx_get_path(game.target_file)
    target_extension := filepath.ext(target_path)

    img := rl.LoadImageFromMemory(
        ".png", 
        raw_data(RAW_PNG_PERSISTENCE_OF_MEMORY), 
        auto_cast len(RAW_PNG_PERSISTENCE_OF_MEMORY))
    rect :rl.Rectangle = {0,0,auto_cast img.width, auto_cast img.height}

    img_text_ext := rl.ImageFromImage(img, rect)
    img_text_obs := rl.ImageFromImage(img, rect)
    img_card := rl.ImageFromImage(img, rect)
    mem.set(img_text_ext.data, 0, cast(int)(img.width * img.height) * size_of(u32))
    mem.set(img_text_obs.data, 0, cast(int)(img.width * img.height) * size_of(u32))
    mem.set(img_card.data, 255, cast(int)(img.width * img.height) * size_of(u32))
    defer {
        rl.UnloadImage(img)
        rl.UnloadImage(img_text_ext)
        rl.UnloadImage(img_text_obs)
        rl.UnloadImage(img_card)
    }

    text_center :: proc(target: ^rl.Image, text: string, font_size :i32= 40) {
        cstr := strings.clone_to_cstring(text, context.temp_allocator)
        measure := rl.MeasureText(cstr, font_size)
        pos :Vector2i= {target.width/2-measure/2, target.height/2 - 20}
        log.debugf("pos for {}: {}, measure: {}", text, pos, measure)
        rl.ImageDrawTextEx(target, FONT_DEFAULT,
            cstr,
            vec_i2f(pos), 40, 0, {0,255,0, 128})
    }

    textcolor :rl.Color= {0,255,0, 255}

    text_center(&img_text_ext, strings.to_upper(target_extension, context.temp_allocator))
    rl.ImageDrawTextEx(&img_text_obs, FONT_DEFAULT,
            "WHYDOESTHSEARUSHTOSHORE", 
            {0, cast(f32)img.height/2-20}, 40, 0, textcolor)
    
    img_rastslice(&img_text_ext, 1, 0)
    img_rastslice(&img_text_obs, 1, 1)
    img_rastslice(&img_card, 1, 0)

    stretch_rect :rl.Rectangle= {rect.x, rect.y-600, rect.width, rect.height+1200}

    rl.ImageDraw(&img, img_text_ext, rect, stretch_rect, rl.WHITE)
    rl.ImageDraw(&img, img_text_obs, rect, stretch_rect, rl.WHITE)

    puzzle_texture = rl.LoadTextureFromImage(img)
    
    // save_img_as_png("./the_persistence_of_memory.png", img.width, img.height, img.data)
    save_img_as_png("./secret_card", img.width, img.height, img_card.data)
    puzzle_texture_wait_for_click = true
}

// step: 0 or 1
img_rastslice :: proc(img: ^rl.Image, segment_px: i32, step: i32) {
    pixels : [^][4]u8 = auto_cast img.data
    for x in 0..<img.width {
        for y in 0..<img.height {
            s := (x / segment_px)%2
            idx := x + y * img.width
            if s == step {
                pixels[idx].a = 0
            }
        }
    }
}

puzzle_tree :: proc() {

}