package main


import "core:unicode/utf8"
import rl "vendor:raylib"

// -- Raw
RAW_TTF_SMILEY :: #load("./res/smiley.ttf", []u8)
RAW_PNG_JAM_IDLE :: #load("./res/jam_idle.png", []u8)
RAW_PNG_SUBTITLE_MASK :: #load("./res/subtitle_mask.png", []u8)

RAW_PNG_STAR_ON :: #load("./res/star_on.png", []u8)
RAW_PNG_STAR_OFF :: #load("./res/star_off.png", []u8)

RAW_PNG_BACKGROUND :: #load("./res/background.png", []u8)
RAW_PNG_GHOST_PEACE :: #load("./res/ghost_peace.png", []u8)
RAW_PNG_GHOST_ANGRY :: #load("./res/ghost_angry.png", []u8)
RAW_PNG_FRAME :: #load("./res/frame.png", []u8)
RAW_PNG_SUPPORT_BACK :: #load("./res/support_back.png", []u8)
RAW_PNG_SUPPORT_FORE :: #load("./res/support_fore.png", []u8)
RAW_PNG_WHEEL :: #load("./res/wheel.png", []u8)
RAW_PNG_JAM :: #load("./res/jam.png", []u8)

RAW_PNG_FOLDER :: #load("./res/folder.png", []u8)

RAW_PNG_PERSISTENCE_OF_MEMORY :: #load("./res/The_Persistence_of_Memory.png", []u8)
RAW_PNG_GRAVESTONE :: #load("./res/gravestone.png", []u8)


// -- In game
TEX_JAM_IDLE : rl.Texture2D
TEX_SUBTITLE_MASK : rl.Texture2D
TEX_STAR_ON : rl.Texture2D
TEX_STAR_OFF : rl.Texture2D

TEX_BACKGROUND : rl.Texture2D
TEX_GHOST_PEACE : rl.Texture2D
TEX_GHOST_ANGRY : rl.Texture2D
TEX_FRAME : rl.Texture2D
TEX_SUPPORT_BACK : rl.Texture2D
TEX_SUPPORT_FORE : rl.Texture2D
TEX_WHEEL : rl.Texture2D
TEX_JAM : rl.Texture2D


FONT_DEFAULT : rl.Font

load_resources :: proc() {
    TEX_JAM_IDLE = _load_texture(RAW_PNG_JAM_IDLE)
    TEX_SUBTITLE_MASK = _load_texture(RAW_PNG_SUBTITLE_MASK)
    TEX_STAR_ON = _load_texture(RAW_PNG_STAR_ON)
    TEX_STAR_OFF = _load_texture(RAW_PNG_STAR_OFF)

    TEX_BACKGROUND = _load_texture(RAW_PNG_BACKGROUND)
    TEX_GHOST_PEACE = _load_texture(RAW_PNG_GHOST_PEACE)
    TEX_GHOST_ANGRY = _load_texture(RAW_PNG_GHOST_ANGRY)
    TEX_FRAME = _load_texture(RAW_PNG_FRAME)
    TEX_SUPPORT_BACK = _load_texture(RAW_PNG_SUPPORT_BACK)
    TEX_SUPPORT_FORE = _load_texture(RAW_PNG_SUPPORT_FORE)
    TEX_WHEEL = _load_texture(RAW_PNG_WHEEL)
    TEX_JAM = _load_texture(RAW_PNG_JAM)
    
    
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
    rl.UnloadTexture(TEX_SUBTITLE_MASK)
    rl.UnloadTexture(TEX_STAR_ON)
    rl.UnloadTexture(TEX_STAR_OFF)

    rl.UnloadTexture(TEX_BACKGROUND)
    rl.UnloadTexture(TEX_GHOST_PEACE)
    rl.UnloadTexture(TEX_GHOST_ANGRY)
    rl.UnloadTexture(TEX_FRAME)
    rl.UnloadTexture(TEX_SUPPORT_BACK)
    rl.UnloadTexture(TEX_SUPPORT_FORE)
    rl.UnloadTexture(TEX_WHEEL)
    
    rl.UnloadFont(FONT_DEFAULT)
}

@(private="file")
_load_texture :: proc(data: []u8) -> rl.Texture2D {
    img := rl.LoadImageFromMemory(".png", raw_data(data), auto_cast len(data))
    defer rl.UnloadImage(img)
    return rl.LoadTextureFromImage(img)
}

_char_sheet := #load("./char_sheet.txt", string)