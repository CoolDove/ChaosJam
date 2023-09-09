package main

import "core:log"
import "core:mem"
import "core:sort"
import "core:slice"
import "core:math"
import "core:strconv"
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
    puzzle_hex,
}
_require_sheet : []i32 = {
    1,
    4,
    9,
    -1,
}
_puzzle_idx := 0

is_the_game_last_phase :: proc() -> bool {
    return get_puzzle_requirements_feed() == -1
}

get_puzzle_requirements_feed :: proc() -> i32 {
    if _puzzle_idx >= len(_require_sheet) do return -1
    return _require_sheet[_puzzle_idx]
}

puzzle :: proc() -> bool {
    if _puzzle_idx >= len(_puzzle_sheet) do return false
    _puzzle_sheet[_puzzle_idx]()
    _puzzle_idx += 1
    return true
}

puzzle_weekday :: proc() {
    sb : strings.Builder
    strings.builder_init(&sb)
    defer strings.builder_destroy(&sb)

    strings.write_rune(&sb, weekday_rune(time.weekday(get_target_info().mod_time)))
    os.write_entire_file("./secret.txt", transmute([]u8)strings.to_string(sb))
}

weekday_string :: proc(t : time.Time, unknown_rune: rune='?', allocator:=context.temp_allocator) -> string {
    context.allocator = allocator
    msg :[7]rune = {'日','月','火','水','木','金','土'} 

    wkday_values := reflect.enum_field_values(time.Weekday)
    target_wkday := time.weekday(t)
    for wv in wkday_values {
        if auto_cast wv == target_wkday do msg[wv] = unknown_rune
    }
    return utf8.runes_to_string(msg[:])
}

weekday_string_inv :: proc(t : time.Time, unknown_rune: rune='?', allocator:=context.temp_allocator) -> string {
    context.allocator = allocator
    msg :[7]rune = {unknown_rune,unknown_rune,unknown_rune,unknown_rune,unknown_rune,unknown_rune,unknown_rune} 

    wkday_values := reflect.enum_field_values(time.Weekday)
    target_wkday := time.weekday(t)
    for wv in wkday_values {
        if auto_cast wv == target_wkday do msg[wv] = weekday_rune(transmute(time.Weekday)wv)
    }
    return utf8.runes_to_string(msg[:])
}
weekday_rune :: proc(weekday: time.Weekday) -> rune {
    runes :[7]rune= {'日','月','火','水','木','金','土'} 
    return runes[transmute(int)weekday]
}

puzzle_texture : rl.Texture2D
puzzle_texture_wait_for_click : bool = false

puzzle_extension :: proc() {
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
        measure :i32= auto_cast rl.MeasureTextEx(FONT_DEFAULT, cstr, auto_cast font_size, 0).x
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

    // After this puzzle, begin to generate the qr code pieces for hex sheet puzzle.
    qr_rip_mode_begin()
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

puzzle_hex :: proc() {
    log.debugf("Hex puzzle!")
}

tree_secret_sheet : map[rune]rune

hexmap := [16]rune {
    'α', 'β', 'γ', 'δ', 'ε', 'ζ', 'ν', 'ξ', 'ο', 'π',
    '♠', '♣', '♥', '♦',
    '☾', '☼',
}

hexsheet : strings.Builder

hexmap_build :: proc() {
    shuffle_seed :u64: 42

    r := rand.create(shuffle_seed)

    for t in 0..<64 {
        from := rand.int63_max(16, &r)
        to := rand.int63_max(16, &r)
        hexmap[from],hexmap[to] = hexmap[to],hexmap[from]
    }

}

hex_encrypt_string :: proc(content: string, allocator:= context.allocator) -> string {
    context.allocator = allocator
    strbuffer :[]u8= transmute([]u8)content

    start := 0
    length_max := 16
    if len(strbuffer) > length_max do start = len(strbuffer)-length_max
    data :[]u8= strbuffer[start:]

    sb : strings.Builder 
    using strings 
    builder_init(&sb)
    defer builder_destroy(&sb)

    for b in data {
        // write_byte(&sb, b)
        write_int(&sb, auto_cast b, 16)
        write_rune(&sb, ' ')
    }
    log.debugf("secret: {}", to_string(sb))
    msg := utf8.string_to_runes(to_string(sb))
    defer delete(msg)

    for &r in msg {
        r = hex_encrypt(r)
    }
    builder_reset(&sb)
    for r in msg do write_rune(&sb, r)

    return clone(to_string(sb))
}

hex_encrypt :: proc(char : rune) -> rune {
    ascii :int= auto_cast char
    idx := -1
    if ascii >= 48 && ascii <= 57 {// numbers
        idx = ascii - 48
    } else if ascii >= 65 && ascii <= 70 {
        idx = ascii - 65 + 10
    } else if ascii >= 98 && ascii <= 102 {
        idx = ascii - 98 + 10
    }

    if idx == -1 do return ' '
    return hexmap[idx]
}

hex_sheet :: proc() -> string {
    using strings
    if builder_cap(hexsheet) == 0 {
        builder_init(&hexsheet)
        for r, idx in hexmap {
            write_rune(&hexsheet, '[')
            write_int(&hexsheet, idx)
            write_rune(&hexsheet, ':')
            write_rune(&hexsheet, r)
            write_rune(&hexsheet, ']')
            write_rune(&hexsheet, '\n')
        }
    }
    return to_string(hexsheet)
}