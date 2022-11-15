
import system
import times
import strformat
import strutils
import httpclient
import bitops
import parsecfg
import unicode
import sequtils

const time = cpuTime()

# logging (poorly)
proc log*(data:string, mode = 0): void =
    let now = (cpuTime() - time).formatFloat(ffDecimal, 3)
    case mode
    of 1: # err
        echo "\x1B[31m(+) ", now, " ERR: \x1B[0m" & data
    of 2: # warn
        echo "\x1B[33m(?) ", now, " WARN: \x1B[0m" & data
    of 3: #debug
        echo "\x1B[36m(%) ", now, " DEBUG: \x1B[0m" & data
    else:
        echo "\x1B[37m(-) ", now, " INFO: \x1B[0m" & data


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
            
    echo g_cfgFile

proc timestampget*(): auto =
    return now().toTime().toUnix()

proc toString(str: seq[char]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, ch)

proc toReadable*(d:int): string =
    let s = d.intToStr().reversed().toSeq()
    # why
    const b = 1024
    if s.len > 9:
        return &"{(d/b/b/b):0.2f} gb"
    if s.len > 6:
        return &"{(d/b/b):0.2f} mb"
    if s.len > 3:
        return &"{(d/b):0.2f} kb"
    return $d & "bytes"

# http get
proc fetch*(w:string): string =
    var client = newHttpClient()
    return client.getContent(w)

proc isOdd*(n:SomeInteger): bool =
    return testBit(n, 0)

proc isEven*(n:SomeInteger): bool =
    return not isOdd(n)