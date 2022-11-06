include "../src/utils"
import unittest

suite "Tests for utils.nim":
    echo "Start of utils.nim tests"

    test "implemented bitwise ops":
        for i in 1..100_000:
            if isEven(i) != (i mod 2 == 0):
                assert false
        assert true

    test "http fetching":
        const poop = "https://gist.githubusercontent.com/jauhc/d6a04c619f87c33bf5c7dcdb5a254352/raw/639b9eb6d828a4c31cb0a710ccc57270549e53b2/poop"
        assert fetch(poop) == "poop"
