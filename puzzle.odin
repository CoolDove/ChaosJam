package main

import "core:log"
import "core:mem"
import "core:sort"
import "core:slice"
import "core:math"
import "core:math/rand"
import "core:runtime"
import "core:bytes"
import "core:time"
import "core:fmt"
import "core:os"
import "core:reflect"
import "core:strings"
import "core:unicode/utf8"
import "core:path/filepath"

WEEKDAY_MAP := []rune {
	'S',
	'M',
	'T',
	'W',
	'T',
	'F',
	'S',
}

puzzle_weekday :: proc() {
    os.write_entire_file("./y7b2xsxz.secret", transmute([]u8)weekday_string(get_target_info().mod_time))
}

weekday_string :: proc(t : time.Time, allocator:=context.allocator) -> string {
    context.allocator = allocator
    msg :[7]rune = {'*','*','*','*','*','*','*'}

    wkday_values := reflect.enum_field_values(time.Weekday)
    target_wkday := time.weekday(t)
    for wv in wkday_values {
        if auto_cast wv == target_wkday do msg[wv] = WEEKDAY_MAP[cast(i64)wv] 
    }
    return utf8.runes_to_string(msg[:])
}