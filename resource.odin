package main


import rl "vendor:raylib"


RAW_PNG_JAM_IDLE :: #load("./res/jam_idle.png", []u8)



TEX_JAM_IDLE : rl.Texture2D



load_resources :: proc() {
    TEX_JAM_IDLE = _load_texture(RAW_PNG_JAM_IDLE)

}


@(private="file")
_load_texture :: proc(data: []u8) -> rl.Texture2D {
    img := rl.LoadImageFromMemory("png", raw_data(data), auto_cast len(data))
    defer rl.UnloadImage(img)
    return rl.LoadTextureFromImage(img)
}