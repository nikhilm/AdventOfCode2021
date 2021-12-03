import std/text/parse
import std/os/file
import std/os/path

struct counter
    zero_count: int
    one_count: int

fun add-bit(c: counter, bit: char) : counter {
    if bit == '0' then {
        Counter(c.zero_count + 1, c.one_count)
    } else {
        Counter(c.zero_count, c.one_count + 1)
    }
}

fun gamma-bit(c: counter) : int {
    assert("gamma undecidable! zero_count=" ++ c.zero_count.show ++ " one_count=" ++ c.one_count.show, c.zero_count != c.one_count)
    if c.zero_count > c.one_count then {
        0
    } else {
        1
    }
}

fun epsilon-bit(c: counter) : int {
    assert("epsilon undecidable! zero_count=" ++ c.zero_count.show ++ " one_count=" ++ c.one_count.show, c.zero_count != c.one_count)
    if c.zero_count < c.one_count then {
        0
    } else {
        1
    }
}

// Expects a list in reverse order than how humans write it! So least significant bit first.
fun bin-to-int(v: list<char>) : int {
    4
}

fun gamma-epsilon(s: string) : _e (int, int) {
    val lines = lines(s)
    val num_of_bits = count(head(lines, ""))
    assert("non-negative length", num_of_bits > 0);
    // from and to are inclusive.
    var bit_counters := vector(map(list(0, num_of_bits - 1), fn(_) { Counter(0, 0) }))

    foreach(lines, fn(line) {
        // Blog post: gotcha! foreach-index(list) and foreach-indexed(vector) call pos, item in different order!
        foreach-indexed(list(line), fn(pos, bit) {
           bit_counters[pos] := bit_counters[pos].add-bit(bit)
        })
    })

    var power := 0
    var gamma := 0
    var epsilon := 0
    foreach(reverse(list(bit_counters)), fn(counter) {
        gamma := gamma + counter.gamma-bit * pow(2, power)
        epsilon := epsilon + counter.epsilon-bit * pow(2, power)
        power := power + 1
    })
    (gamma, epsilon)
}

fun test1() {
    val (g, e) = gamma-epsilon(@"00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010")
    assert("test 1 failed: g=" ++ g.show ++ " e=" ++ e.show, g * e == 198)
}

fun test2() {
    ()
}

fun main() {
    test1()
    test2()

    val input = read-text-file(path("input.txt"))
    val (g, e) = gamma-epsilon(input)
    println("gamma: " ++ g.show ++ " epsilon: " ++ e.show ++ " product: " ++ (g * e).show)
}
