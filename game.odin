package main



import "core:runtime"
import "core:strings"
import rl "vendor:raylib"



Game :: struct {
    tweener : Tweener,
}

game : Game

game_begin :: proc() {
    tweener_init(&game.tweener, 10)
    load_resources()

}

game_end :: proc() {
    tweener_release(&game.tweener)
}

game_update :: proc(delta: f32) {
    tweener_update(&game.tweener, delta)

    

}