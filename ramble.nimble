# Package

version       = "0.2.0"
author        = "jauhc"
description   = "file hosting with ram"
license       = "AGPL-3.0-or-later"
srcDir        = "src"
bin           = @["ramble"]


# Dependencies

#todo OS specific shit

requires "nim >= 1.6.6"

task r, "try and build&run":
    exec "nim c --gc:arc --colors:on --noNimblePath -d:ssl -o:ramble.exe src/ramble.nim"
    exec "ramble.exe"

task minr, "try and build small":
    exec "nim c --gc:arc --colors:on --noNimblePath -d:ssl -o:ramble.exe --d:release --opt:size --passL:-s --deadCodeElim:on src/ramble.nim"
    exec "ramble.exe"

# pretty nice
task tests, "run full tests":
# --print for more info
    exec "testament pattern tests/test*.nim"
