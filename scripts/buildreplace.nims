#mode = ScriptMode.Verbose

import os
import strformat
import std/strutils

let buildfile = "nimcache\\compile_ramble.bat"
echo "curdir: ", getCurrentDir()
echo "looking for file: ", buildfile

if fileExists(buildfile):
    echo "buildfile found"
    var data = readFile(buildfile)
    var d = data.replace("gcc.exe", "zig cc")
    d = d.replace("gcc", "zig cc")
    d = d.replace("@", "")
    
    for k in walkDir("nimcache"):
        if k.kind == pcFile and k.path.find('@') > -1:
            mvFile(k.path, k.path.replace("@",""))



    #var buffer = ""
    #for line in buildfile.lines:
        #buffer.add(line.replace("@", "").replace("gcc ", "zig cc ").replace("gcc.exe","zig cc") & '\n')
    writeFile(buildfile, d)
else: echo "buildreplace.nims failed to find buildfile :("