include "../src/utils"
import unittest

suite "Tests for utils.nim":
    echo "Start of utils.nim tests"

    test "implemented bitwise ops":
        for i in 1..100_000:
            if isEven(i) != (i mod 2 == 0):
                assert false
        assert true
