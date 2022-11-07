#mode = ScriptMode.Verbose

import os
import strformat

if dirExists("nimcache"):
    for k in walkDir(&"{projectDir()}\\..\\nimcache"): # holy fuck
        if k.kind == pcFile: # dont remove folders or their contents
            #echo k.path
            rmFile(k.path)
    echo "nimcache cleaned!"