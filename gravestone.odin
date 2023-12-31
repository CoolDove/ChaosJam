package main


import "core:math/linalg"
import "core:strings"
import rl "vendor:raylib"
import "core:os"
import "core:math"
import "core:fmt"
import "core:time"
import "core:path/filepath"


rip_file :: proc(path: string, correct: bool, win: bool) {
    gravestone := rl.LoadImageFromMemory(
        ".png", 
        raw_data(RAW_PNG_GRAVESTONE), 
        auto_cast len(RAW_PNG_GRAVESTONE))

    defer rl.UnloadImage(gravestone)

    using rl
    height :i32= 130
    color := rl.BLACK
    _push_line(&gravestone, "RIP", &height, color)

    fhandle, handle_err := os.open(path)
    if handle_err != os.ERROR_NONE do return
    defer os.close(fhandle)

    fi, fi_err := os.fstat(fhandle, context.temp_allocator)

    if handle_err != os.ERROR_NONE do return
    
    expadding :i32= 24
    if !win {
        _push_line(&gravestone, strings.clone_to_cstring(filepath.base(path), context.temp_allocator), &height, color, expadding = expadding)
        _push_line(&gravestone, "修改日期", &height, color)
        _push_line(&gravestone, fmt.ctprintf("{}", time_string(fi.modification_time)), &height, color, expadding = expadding)
        _push_line(&gravestone, "大小", &height, color)
        size_str := fmt.ctprintf("{}", strings.trim_left(readable_format_bytes(cast(int)fi.size, context.temp_allocator), " "))
        _push_line(&gravestone, size_str, &height, color, expadding = 2*expadding)
        _push_line(&gravestone, fmt.ctprintf("{}", weekday_string(fi.modification_time, unknown_rune='*')), &height, {60, 100, 180, 80})
    } else {
        _push_line(&gravestone, "这正是我想要的文件", &height, color, expadding=expadding)
        _push_line(&gravestone, "那么我就收下了", &height, color, expadding=expadding)
        _push_line(&gravestone, "感谢你的付出", &height, color, expadding=expadding*4)
        _push_line(&gravestone, "BV1Qv4y1r791", &height, {20,20,20, 64}, expadding=expadding)
    }

    if correct && qr_piece_idx > -1 do integrate_qrcode(&gravestone)

    rl.stbi_write_png(
        fmt.ctprintf("{}/{}_RIP.png", filepath.dir(path, context.temp_allocator), filepath.stem(path)),
        gravestone.width, gravestone.height, 4, gravestone.data, 0)
}

qr_piece_idx : i32 = -1

qr_rip_mode_begin :: proc() {
    qr_piece_idx = 0
}

@(private="file")
integrate_qrcode :: proc(img: ^rl.Image) {
    if qr_piece_idx > 8 do return
    qr_piece := RAW_PNG_QR_PIECES[qr_piece_idx]
    qr := rl.LoadImageFromMemory(
        ".png", 
        raw_data(qr_piece), 
        auto_cast len(qr_piece))
    defer rl.UnloadImage(qr)
    pixels_img : [^][4]u8 = auto_cast img.data
    pixels_qr : [^][4]u8 = auto_cast qr.data
    assert(qr.height == img.height && qr.width == img.width, "BOOOOOM")
    for y in 0..<img.height {
        for x in 0..< img.width {
            idx := x + y * img.width
            if pixels_qr[idx].a > 128 { 
                pix := pixels_img[idx]
                pixels_img[idx] = {pix.r + 128, pix.g, pix.b, pix.a}
            }

        }
    }
    qr_piece_idx += 1
}

@(private="file")
_push_line :: proc(img: ^rl.Image, text: cstring, height: ^i32, color: rl.Color, expadding : i32=0) {
    font_size :f32= 30
    measure := vec_f2i(rl.MeasureTextEx(FONT_DEFAULT, text, font_size, 1.0))
    pos := vec_i2f(Vector2i{img.width/2-measure.x/2, height^})
    rl.ImageDrawTextEx(img, FONT_DEFAULT, text, pos, font_size, 1.0, color)
    height^ = height^ + measure.y + expadding
}


time_string :: proc(t: time.Time, allocator:= context.temp_allocator) -> string {
    context.allocator = allocator
    using strings
    sb : Builder
    builder_init(&sb)

    write_int(&sb, time.year(t))
    write_rune(&sb, '/')
    write_int(&sb, cast(int)time.month(t))
    write_rune(&sb, '/')
    write_int(&sb, time.day(t))
    write_rune(&sb, ' ')
    write_string(&sb, chinese_weekday_name(time.weekday(t)))
    return to_string(sb)
}

chinese_weekday_name :: proc(weekday: time.Weekday) -> string {
    switch weekday {
	case .Sunday:
        return "星期日"
	case .Monday:
        return "星期一"
	case .Tuesday:
        return "星期二"
	case .Wednesday:
        return "星期三"
	case .Thursday:
        return "星期四"
	case .Friday:
        return "星期五"
	case .Saturday:
        return "星期六"
    }
    return ""
}