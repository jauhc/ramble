# Package

version       = "0.2.0"
author        = "jauhc"
description   = "file hosting with ram"
license       = "AGPL-3.0-or-later"
srcDir        = "src"
bin           = @["ramble"]


# Dependencies

#todo OS specific shit
import os

requires "nim >= 1.6.6"

task r, "try and build&run":
    exec "nim c --gc:arc --colors:on --noNimblePath -d:ssl -o:ramble.exe src/ramble.nim"
    exec "ramble.exe"

task codegen, "clears cache + generates code":
    exec "nim scripts/clearcache.nims"
    # todo: platform specific stuff
    exec "nim c --gc:arc --colors:on --cpu:amd64 --os:windows --nimcache:nimcache/ -d:ssl --compileonly --genscript ./src/ramble.nim"

# figure out how to simplify this

task codegenpi, "clears cache + generates code for pi":
    exec "nim scripts/clearcache.nims"
    exec "nim c --gc:arc --colors:on --cpu:arm64 --os:linux --nimcache:nimcache/ -d:ssl --compileonly --genscript ./src/ramble.nim"

task omegabuild, "generates c code then builds it with zig c compiler":
    exec "nimble codegen"
    exec "nim scripts/buildreplace.nims"
    cd "nimcache"
    exec "compile_ramble.bat"
    mvFile("ramble", "..\\ramble.exe")

task minr, "try and build small":
    exec "nim c --gc:arc --colors:on --noNimblePath -d:ssl -o:ramble.exe --d:release --opt:size --passL:-s --deadCodeElim:on src/ramble.nim"
    exec "ramble.exe"

# pretty nice
task tests, "run full tests":
# --print for more info
    exec "testament pattern tests/test*.nim"
