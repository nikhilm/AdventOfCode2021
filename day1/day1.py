# just part 2
import fileinput
import functools
import typing as T

class Windows:
    def __init__(self):
        self.windows: T.List[T.List[int]] = []
        self.active_windows = [[], [], []]
        self.added = 0

    def rotating_add(self, x: int):
        self.active_windows[0].append(x)
        self.active_windows[1].append(x)
        self.active_windows[2].append(x)

        assert len(self.active_windows[0]) == 3
        self.windows.append(list(self.active_windows[0]))
        self.active_windows.pop(0)
        self.active_windows.append([])

    def add(self, x: int):
        # some of the starting cases
        if self.added == 0:
            self.active_windows[0].append(x)
        elif self.added == 1:
            self.active_windows[0].append(x)
            self.active_windows[1].append(x)
        else:
            self.rotating_add(x)
        self.added += 1 

    def __repr__(self) -> str:
        return f"{self.windows} ({self.active_windows})"

    def increase_count(self) -> int:
        summed = [sum(w) for w in self.windows]
        increase_c = 0
        def track_inc(a, b):
            nonlocal increase_c
            if a < b:
                increase_c += 1
            return b
        functools.reduce(track_inc, summed)
        return increase_c

windows = Windows()
for line in fileinput.input():
    item = int(line)
    windows.add(item)

print(windows)
print(windows.increase_count())
