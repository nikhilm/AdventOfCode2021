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

/*
Blog note:
Love how straightforward parsing is, but took a bit to figure out that the
parser is written in an imperative style because it uses the effect to perform
the actual parse at the point of calling parse(), where the parse() presumably
handles each parser raising the parse effect and feeding it input. So it seems
like your imperative parser is just operating on input from the ether.

Noticed that the koka compiler does not allow type constructors as first class
functions (the koka compiler passes but generated code fails gcc. For example,
this will fail, preventing some refactoring of the block below.
    val ctor = choose([
        {
            pstring("forward")
            Forward
        },
        ...
    ])
    whitespace()
    ctor(pnat())
*/
fun sub-line-parser() : parse movement {
    choose([
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
}

// Blog note: Turns out the _ before the effect name has meaning.
// It seems like without it, interpret's return type will change to somehow encapsulate e and start failing
// With it, the compiler seems to understand we don't care what effect it is and discards it.
fun interpret(s: string, on-movement: (movement) -> _e ()) : _e1 () {
    val lines = lines(s)
    foreach-indexed(lines, fn(lineno, line) {
        // skip EOF at end of file
        if line == "" then { return () }
        match parse(slice(line), sub-line-parser) {
            ParseOk(result, _) -> {
                on-movement(result)
            }
            ParseError(msg, _rest) -> { print("parse error " ++ lineno.show ++ ": "); println(msg) }
        }
    })
    ()
}

fun interpret1(s: string) : _ (int, int) {
    val horiz = ref(0)
    val depth = ref(0)
    val on-movement = fn(m: movement) {
        match m {
            Forward(i) -> { horiz := !horiz + i }
            Down(i) -> { depth := !depth + i }
            Up(i) -> { depth := !depth - i }
        }
    }
    interpret(s, on-movement)
    (!horiz, !depth)
}

fun interpret2(s: string) : _ (int, int) {
    val horiz = ref(0)
    val depth = ref(0)
    val aim = ref(0)
    val on-movement = fn(m: movement) {
        match m {
            Forward(i) -> { horiz := !horiz + i; depth := !depth + !aim * i }
            Down(i) -> { aim := !aim + i }
            Up(i) -> { aim := !aim - i }
        }
    }
    interpret(s, on-movement)
    (!horiz, !depth)
}

fun test1() {
    val (h, d) = interpret1(@"forward 5
down 5
forward 8
up 3
down 8
forward 2")
    assert("test 1 failed: h=" ++ h.show ++ " d=" ++ d.show, h * d == 150)
}

fun test2() {
    val (h, d) = interpret2(@"forward 5
down 5
forward 8
up 3
down 8
forward 2")
    assert("test 2 failed: h=" ++ h.show ++ " d=" ++ d.show, h * d == 900)
}

fun main() {
    test1()
    test2()

    val input = read-text-file(path("input.txt"))
    val (h, d) = interpret1(input)
    println("part 1: " ++ show(h * d))
    val (h, d) = interpret2(input)
    println("part 2: " ++ show(h * d))
}
