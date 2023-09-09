package main

import "core:fmt"
import "core:strings"

talk_game_start :: proc() {
    tk_clear()
    tk_push("电脑里出现了一只丑陋的茧......")
    tk_push("你注视着它，它表面的黑色花纹缓缓蠕动，\n看不穿里面有什么。")
    tk_push("它察觉到了你，微弱的声音从空气中渗出：")
    tk_push("“喂，你，把你最重要的文件献给我。”")
    _talk_begin()
}

talk_puzzle:: proc() {
    tk_clear()
    tk_push("*似乎有奇怪的事情发生了*")
    _talk_begin()
}

talk_no_puzzle:: proc() {
    tk_clear()
    tk_push("*茧已经不再有耐心*")
    tk_push("(所有提示都已经给你啦)")
    _talk_begin()
}

talk_resp_eat_good :: proc() {
    tk_clear()
    tk_push("茧缩紧了身体，\n在一阵颤抖后发出了满足的声音：")
    tk_push("“和我想要的略有一些联系，但还不够。")
    tk_push("继续找！”")
    _talk_begin()
}

talk_resp_eat_bad :: proc() {
    tk_clear()
    tk_push("茧扭曲着咆哮：")
    tk_push("“ERROR 201: Unsupported file.”")
    _talk_begin()
}

talk_resp_eat_too_fresh :: proc() {
    tk_clear()
    tk_push("茧扭曲着咆哮：")
    tk_push("“不要拿这么新鲜的文件来糊弄我。”")
    _talk_begin()
}

talk_resp_eat_plain :: proc() {
    tk_clear()
    tk_push("茧接受了你的供奉，但是：")
    tk_push("“这不是我要的东西，相差甚远。”")
    _talk_begin()
}

talk_resp_eat_self :: proc() {
    tk_clear()
    tk_push("茧一动不动地躺着，\n你却感到被它注视。")
    tk_push("沉默之后它开口了：")
    tk_push("“别自作聪明。”")
    _talk_begin()
}

talk_win :: proc() {
    tk_clear()
    tk_push("……")
    tk_push("…………")
    tk_push("………………")
    tk_push("“没错，这正是我要找的东西！”")
    _talk_begin()
}