
import system
import times
import strformat
import strutils
import httpclient
import bitops
import parsecfg

const g_fStartTime = cpuTime()

# logging (poorly)
proc log*(data:string, mode = 0): void =
    let now = (cpuTime() - g_fStartTime).formatFloat(ffDecimal, 3)
    case mode
    of 1: # err
        echo "\x1B[31m(+) ", now, " ERR: \x1B[0m" & data
    of 2: # warn
        echo "\x1B[33m(?) ", now, " WARN: \x1B[0m" & data
    of 3: #debug
        echo "\x1B[36m(%) ", now, " DEBUG: \x1B[0m" & data
    else:
        echo "\x1B[37m(-) ", now, " INFO: \x1B[0m" & data

proc toReadable*(d:int): string =
    # why
    const b = 1024
    # uncomment if you actually go beastmode
    #if s.len > 12: 
        #return &"{(d/b/b/b/b):0.2f} tb"
    if ($d).len > 9:
        return &"{(d/b/b/b):0.2f} gb"
    if ($d).len > 6:
        return &"{(d/b/b):0.2f} mb"
    if ($d).len > 3:
        return &"{(d/b):0.2f} kb"
    return $d & " bytes"

var g_cfgFile* {.threadvar.}: Config

proc readCfg*(val:string): string =
    return g_cfgFile.getSectionValue("", val)

proc reloadCfg*() =
    log("config reloaded", 3)
    g_cfgFile = loadConfig("config.ini")

proc dumpCfg*(safe:bool = true) =
    var tempcopy: Config = g_cfgFile
    if safe:
        tempcopy.setSectionKey("", "token", "<HIDDEN>")
    
    tempcopy.setSectionKey("", "maxsize", toReadable(tempcopy.getSectionValue("", "maxsize").parseInt))
    const sep = '='
    echo sep.repeat(8) & "CONFIG_START" & sep.repeat(8) & '\n'
    echo g_cfgFile
    echo sep.repeat(8) & "CONFIG_END" & sep.repeat(8)

proc timestampget*(): auto =
    return now().toTime().toUnix()

# http get
proc fetch*(w:string): string =
    var client = newHttpClient()
    return client.getContent(w)

proc isOdd*(n:SomeInteger): bool =
    return testBit(n, 0)

proc isEven*(n:SomeInteger): bool =
    return not isOdd(n)