package main


import rl "vendor:raylib"


RAW_PNG_JAM_IDLE :: #load("./res/jam_idle.png", []u8)



TEX_JAM_IDLE : rl.Texture2D



load_resources :: proc() {
    TEX_JAM_IDLE = _load_texture(RAW_PNG_JAM_IDLE)

}


@(private="file")
_load_texture :: proc(data: []u8) -> rl.Texture2D {
    img := rl.LoadImageFromMemory(".png", raw_data(data), auto_cast len(data))
    defer rl.UnloadImage(img)
    return rl.LoadTextureFromImage(img)
}



// talks
TALK_BEGIN :: proc() -> []string {
    talk :: []string {
        "你的电脑里出现了一只丑陋的茧......",
        "他的口状器官微微翕动，露出一圈锋利的牙齿，从中发出微弱的声音：\nV我50",
    }
    return talk
}

TALK_RESP_NICE :: proc() -> []string {
    talk :: []string {
        "茧缩紧了身体，发出一阵剧烈的颤抖，随后平静了下来。",
        "它说道：食物我喜欢，想要更多exe",
    }
    return talk
}