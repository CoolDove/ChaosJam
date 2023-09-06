package main

import "core:runtime"
import "core:strings"
import rl "vendor:raylib"
import "core:math/linalg"
import "core:c/libc"
import "core:log"
import "core:fmt"
import "core:math"
import "core:time"
import "core:slice"
import win32 "core:sys/windows"

import sdl "vendor:sdl2"
import gl "vendor:OpenGL"


WindowMode :: enum {
    Default, Fullscreen,
    // `Fullscreen` is for the monster to jump out.
}


window_mode : WindowMode = .Default

stopwatch : time.Stopwatch

AppTimer :: struct {
    game_time : time.Duration,// 0 when the game start.
    game_begin : time.Time,
    delta : time.Duration,
}
app_timer : AppTimer

main :: proc() {
    context.logger = log.create_console_logger()

    rl.SetWindowState({ 
        rl.ConfigFlag.WINDOW_MAXIMIZED,
        // .WINDOW_UNDECORATED,
    })
    rl.InitWindow(800, 800, "霸王之茧");

    gl.load_up_to(3,3,win32.gl_set_proc_address)

    rl.SetExitKey(rl.KeyboardKey.KEY_NULL)


    game_begin()

    for (!rl.WindowShouldClose()) {

        old_time := app_timer.game_time
        app_timer.game_time = time.stopwatch_duration(stopwatch)
        delta := app_timer.game_time - old_time
        app_timer.delta = delta
        
        
        rl.BeginDrawing()
        gl.Enable(gl.BLEND)
        rl.ClearBackground({0,0,0,0})

        game_update(cast(f32)time.duration_seconds(delta))
        

        rl.DrawTexture(TEX_JAM_IDLE, 30, 30, rl.WHITE)


        rl.DrawText("Hello, world", 300, 400, 40, rl.WHITE)

        if rl.IsKeyPressed(.K) {
            toggle_window_mode()
        }
        
        rl.EndDrawing()
    }
    game_end()
}


toggle_window_mode :: proc() {
    if window_mode == .Default {
        set_window_mode(.Fullscreen)
    } else {
        set_window_mode(.Default)
    }

}

set_window_mode :: proc(mode: WindowMode) {
    if mode == .Fullscreen {
        rl.SetWindowState({ .WINDOW_MAXIMIZED, .WINDOW_UNDECORATED, .WINDOW_TOPMOST })

        hwnd := transmute(win32.HWND)rl.GetWindowHandle()
        win32.SetWindowLongW(hwnd, win32.GWL_EXSTYLE, 0x00080000)
        
        win32.SetLayeredWindowAttributes(hwnd, 0, 0, 0x00000001)

        window_mode = mode
    } else {
        rl.ClearWindowState({ .WINDOW_MAXIMIZED, .WINDOW_UNDECORATED, .WINDOW_TOPMOST })

        hwnd := transmute(win32.HWND)rl.GetWindowHandle()
        win32.SetWindowLongW(hwnd, win32.GWL_EXSTYLE, transmute(i32)win32.WS_EX_APPWINDOW)
        rl.SetWindowSize(800, 800)

        window_mode = mode
    }
}