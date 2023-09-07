package main

import "core:fmt"
import "core:strings"



talk_game_start :: proc() {
    tk_clear()
    tk_push("电脑里出现了一只丑陋的卵......")
    tk_push("你注视着它，它就像是一张薄薄的纸\n包裹着一团蠕动的液体，")
    tk_push("上面有一个口状的器官微微翕动着。\n")
    tk_push("它察觉到了你，微弱的声音从他的口中发出：")
    tk_push("“把你最重要的东西交给我。”")
    _talk_begin()
}


talk_resp_chew:: proc() {
}

talk_resp_eat_good :: proc() {
    tk_clear()
    tk_push("茧缩紧了身体，\n在一阵短促的颤抖后平静了下来。")
    tk_push("“很不错，但也只是接近，”")
    tk_push("“这不是我要的东西。”")
    tk_push("*似乎有奇怪的事情发生了*")
    _talk_begin()
}

talk_resp_eat_bad :: proc() {
    tk_clear()
    tk_push("茧扭曲着发出尖厉的咆哮：")
    tk_push("“不要企图糊弄我，这些东西太新了。”")
    _talk_begin()
}

talk_resp_eat_plain :: proc() {
    tk_clear()
    tk_push("茧接受了你的供奉，")
    tk_push("它静静的咀嚼。")
    tk_push("它吐出几个字：")
    tk_push("“这不是我要的东西，相差甚远。”")
    _talk_begin()
}

talk_resp_eat_self :: proc() {
    tk_clear()
    tk_push("茧一动不动地躺着，\n你却感到被它注视。")
    tk_push("沉默之后它开口说道：")
    tk_push("“别自作聪明。”")
    _talk_begin()
}