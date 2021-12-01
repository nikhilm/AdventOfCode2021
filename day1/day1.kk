module day1

import std/os/file
import std/os/path

fun main() {
    val input = read-text-file(path("input1.txt"))
    val lines = map(lines(input), fn(i) { parse-int-default(i, 0) })
    val increase_count = ref(0)
    foldl1(lines, fn (a, b) {
        if a < b then {
            increase_count := !increase_count + 1
        }
        b
    })
    print("Part 1: ")
    println(!increase_count)
}
