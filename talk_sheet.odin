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

talk_resp_eat_good :: proc() {
    tk_clear()
    tk_push(fmt.tprintf("茧吃掉了你的\n\"{}\"。", strings.to_string(last_eat.path)))
    tk_push("茧缩紧了身体，\n发出一阵剧烈的颤抖，\n随后平静了下来。")
    tk_push("它说道：食物我喜欢，想要更多exe")
    tk_push("Good night")
    tk_push("Good dd")
    _talk_begin()
}

talk_resp_eat_bad :: proc() {
    tk_clear()
    tk_push("I ate bad")
    tk_push("bye")
    _talk_begin()
}

talk_resp_eat_self :: proc() {
    tk_clear()
    tk_push("茧一动不动地躺着，\n你却感到被它注视。")
    tk_push("沉默之后它开口说道：")
    tk_push("“别自作聪明。”")
    _talk_begin()
}