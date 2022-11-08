
import system
import times
import strutils
import httpclient
import bitops
import parsecfg

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

var g_cfgFile = loadConfig("config.ini")

proc readCfg*(val:string): string =
  return g_cfgFile.getSectionValue("", val)

proc reloadCfg*() =
  g_cfgFile = loadConfig("config.ini")

proc timestampget*(): auto =
  return now().toTime().toUnix()

# http get
proc fetch*(w:string): string =
  var client = newHttpClient()
  return client.getContent(w)

#proc isOdd*[T: SomeNumber](n:T): bool =
proc isOdd*(n:SomeInteger): bool =
  return testBit(n, 0)

#proc isEven*[T: SomeNumber](n:T): bool =
proc isEven*(n:SomeInteger): bool =
  return not isOdd(n)