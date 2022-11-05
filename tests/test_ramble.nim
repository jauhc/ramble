include "../src/utils"
import unittest

# ramble
import os
import strformat

suite "ramble (main) shit":
    setup:
        echo "run before each test"
    const testdir: string = "temp/testfile_"
    const howmanyfiles: int = 5
    test "file creation":
        for i in 0..howmanyfiles:
            writeFile(&"{testdir}{i}", &"{i}")
    test "file reading":
        for i in 0..howmanyfiles:
            assert readFile(&"{testdir}{i}") == &"{i}"
    test "file deleting":
        for i in 0..howmanyfiles:
            assert tryRemoveFile(&"{testdir}{i}") == true