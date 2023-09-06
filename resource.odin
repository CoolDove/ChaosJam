package main


import "core:unicode/utf8"
import rl "vendor:raylib"


// -- Raw
RAW_TTF_SMILEY :: #load("./res/smiley.ttf", []u8)
RAW_PNG_JAM_IDLE :: #load("./res/jam_idle.png", []u8)


// -- In game
TEX_JAM_IDLE : rl.Texture2D
FONT_DEFAULT : rl.Font


load_resources :: proc() {
    TEX_JAM_IDLE = _load_texture(RAW_PNG_JAM_IDLE)

    runes := utf8.string_to_runes(_char_sheet)
    defer delete(runes)

    FONT_DEFAULT = rl.LoadFontFromMemory(
        ".ttf", 
        raw_data(RAW_TTF_SMILEY), 
        cast(i32)len(RAW_TTF_SMILEY), 
        get_font_size(), 
        &runes[0], 
        cast(i32)len(runes))

}

release_resources :: proc() {
    rl.UnloadTexture(TEX_JAM_IDLE)
    rl.UnloadFont(FONT_DEFAULT)
}

@(private="file")
_load_texture :: proc(data: []u8) -> rl.Texture2D {
    img := rl.LoadImageFromMemory(".png", raw_data(data), auto_cast len(data))
    defer rl.UnloadImage(img)
    return rl.LoadTextureFromImage(img)
}

_char_sheet := #load("./char_sheet.txt", string)