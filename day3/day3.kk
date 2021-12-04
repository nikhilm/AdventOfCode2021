import std/text/parse
import std/os/file
import std/os/path

struct counter
    zero_count: int
    one_count: int

type keeper
    More
    Fewer

fun add-bit(c: counter, bit: char) : counter {
    if bit == '0' then {
        Counter(c.zero_count + 1, c.one_count)
    } else {
        Counter(c.zero_count, c.one_count + 1)
    }
}

fun gamma-bit(c: counter) : int {
    // Sure there is a better way to do this with effects and exceptions, but just want to solve it for now
    // assert("gamma undecidable! zero_count=" ++ c.zero_count.show ++ " one_count=" ++ c.one_count.show, c.zero_count != c.one_count)
    if c.zero_count > c.one_count then {
        0
    } else {
        1
    }
}

fun epsilon-bit(c: counter) : int {
    // assert("epsilon undecidable! zero_count=" ++ c.zero_count.show ++ " one_count=" ++ c.one_count.show, c.zero_count != c.one_count)
    if c.zero_count <= c.one_count then {
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

fun to-decimal(number: vector<char>) : int {
    var power := 0
    var decimal := 0
    foreach(reverse(list(number)), fn(element) {
        decimal := decimal + (int(element) - int('0')) * pow(2, power)
        power := power + 1
    })
    // assert("TODO", False);
    decimal
}

fun calculate-rating(numbers: list<vector<char>>, bit_pos: int, k: keeper) : <div|_e> int {
    println("BIT " ++ bit_pos.show)
    // length might be O(n), but shouldn't matter for our purposes.
    if length(numbers) == 1 then {
        return match head(numbers) {
            Just(n) -> to-decimal(n)
            Nothing -> 0
        }
    }

    // OK Seems like the use of locals is a problem, but not obvious at all from the error messages.
    val bit_counter = ref(Counter(0, 0))
    foreach(numbers, fn(number) {
        bit_counter := (!bit_counter).add-bit(number[bit_pos])
    })
    val to_match = char(int('0') + (match k {
        More -> (!bit_counter).gamma-bit
        Fewer -> (!bit_counter).epsilon-bit
    }))

    // Blog post: What I appreciate about languages like Python is that all the default types can be easily, recursively printed.
    // Makes debugging easier.
    val to_keep = filter(numbers, fn(number) {
        number[bit_pos] == to_match
    })

    return calculate-rating(to_keep, bit_pos + 1, k)
}

fun life-support(input: string) : _e (int, int) {
    val lines = lines(input)
    val initial_numbers = map(lines, fn(line) { vector(list(line)) })
    // Ok now we need to start some recursive, state maintaining function, that as its base case should yield the rating.
    val o = calculate-rating(initial_numbers, 0, More)
    val co = calculate-rating(initial_numbers, 0, Fewer)
    (o, co)
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
    val (o, co) = life-support(@"00100
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
    assert("test 2 failed: o=" ++ o.show ++ " co=" ++ co.show, o * co == 230)
}

fun main() {
    test1()
    test2()

    val input = read-text-file(path("input.txt"))
    val (g, e) = gamma-epsilon(input)
    println("gamma: " ++ g.show ++ " epsilon: " ++ e.show ++ " product: " ++ (g * e).show)

    val (o, co) = life-support(input)
    ()
}
