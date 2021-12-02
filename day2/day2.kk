import std/text/parse
import std/os/file
import std/os/path

type movement
    Up(i : int)
    Down(i : int)
    Forward(i : int)

fun show-movement(m : movement) : string {
    match m {
        Up(i) -> "up " ++ i.show
        Down(i) -> "down " ++ i.show
        Forward(i) -> "forward " ++ i.show
    }
}

fun sub-line-parser() {
    val ins-fun = fn(s: string) {
        // the "parser" (just a function that has a parse effect)
        fn() { pstring(s) }
    }
    val instruction = fn() { choose([ins-fun("forward"), ins-fun("down"), ins-fun("up")]) }

    val ctor = choose([
        {
            pstring("forward")
            whitespace()
            Forward(pnat())
        },
        {
            pstring("up")
            whitespace()
            Up(pnat())
        },
        {
            pstring("down")
            whitespace()
            Down(pnat())
        },
    ])
    ctor
}

fun interpret(s: string) {
    val lines = lines(s)
    val horiz = ref(0)
    val depth = ref(0)
    foreach(lines, fn(line) {
        match parse(slice(line), sub-line-parser) {
            ParseOk(result, _) -> {
                match result {
                    Forward(i) -> { horiz := !horiz + i }
                    Down(i) -> { depth := !depth + i }
                    Up(i) -> { depth := !depth - i }
                }
            }
            ParseError(msg, _rest) -> { print("parse error "); println(msg) }
        }
    })
    (!horiz, !depth)
}

fun test1() {
    val (h, d) = interpret(@"forward 5
down 5
forward 8
up 3
down 8
forward 2")
    h * d
}

fun main() {
    // print("Test 1: ")
    // println(test1())
    val input = read-text-file(path("input.txt"))
    val (h, d) = interpret(input)
    println("part 1: " ++ show(h * d))
}
