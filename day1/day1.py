# just part 2
import fileinput
import functools
import typing as T
from itertools import islice
import collections

# Smarter
# from itertools examples
def sliding_window(iterable, n):
    # sliding_window('ABCDEFG', 4) -> ABCD BCDE CDEF DEFG
    it = iter(iterable)
    window = collections.deque(islice(it, n), maxlen=n)
    if len(window) == n:
        yield tuple(window)
    for x in it:
        window.append(x)
        yield tuple(window)

def windowed_increase(l: T.List[str], n: int) -> int:
    inputs = [int(line) for line in l]
    windows = [sum(w) for w in sliding_window(inputs, n)]
    increase_c = 0
    def track_inc(a, b):
        nonlocal increase_c
        if a < b:
            increase_c += 1
        return b
    functools.reduce(track_inc, windows)
    return increase_c
lines = list(fileinput.input())
print(windowed_increase(lines, 1))
print(windowed_increase(lines, 3))
