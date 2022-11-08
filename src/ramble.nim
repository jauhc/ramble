import system
import os
import utils
import strformat
import strutils

# TODO
#  secure
#  or just use some framework like jester

# 1 gb = 1024 * 1024 * 1024
const # holy fuck this became cluttered but const is comptime so its ok i guess
    devmode = true
    host = "localhost"
    port = 8080

    isSecure = false # todo, TLS/SSL or whatever its called today

    protocol: string = if isSecure: "https" else: "http"
    endpoint = case port
        of 80, 443: &"{protocol}://{host}/"
        else: &"{protocol}://{host}:{port}/"

    one_meg = 1024 * 1024 # 1 mb
    storage_capacity = one_meg * (256)  # mb
#const storage_size = 1024 * 1024 * 1024 # 128 mb

#import base64
const areyoulost = readFile("lost.png")

import std/tables
var storage {.threadvar.}: OrderedTableRef[int64, string]
storage = newOrderedTable[int64, string]()

proc storage_size(): int =
    var t = 0
    for v in storage.values:
        t = t + len(v)
        echo "[scan] found file with size ", len(v)
    return t

proc storagedump() =
    var size = storage_size()
    utils.log("storage stats", 3)
    utils.log(&"storage size: {size}", 3)
    utils.log("contents: ", 3)
    for i in storage.keys:
        utils.log(&"key: {i}, resource size: {len(storage[i])}", 3)
    utils.log(&"TOTAL USAGE: {size} / {storage_capacity}", 3)
    #echo GC_getStatistics()

proc checkStorage(datalen:int) =
    #utils.log(&"checking storage..", 3)
    while storage_size() + datalen > storage_capacity:
        for k, v in storage.pairs:
            utils.log(&"storage full, removing {k}...", 3)
            storage.del(k)
            break

proc createDevResource(res:string, optname:int64 = 0) =
    let curt = utils.timestampget()
    checkStorage(len(res))
    if optname == 0:
        storage[curt] = res
    else:
        storage[optname] = res

    log(&"(+) resource added, name: {optname}, len: {len(res)}",3) #\
    #log(&"(+) resource: {storage[curt]}",3) # prints entire image as text (dont do this)
    #storagedump()

proc createResource(res:string): string =
    let curt = utils.timestampget()
    checkStorage(len(res))
    storage[curt] = res

    log(&"(+) resource added, name: {curt}, len: {len(res)}",3) #\
    #log(&"(+) resource: {storage[curt]}",3) # prints entire image as text (dont do this)
    #storagedump()
    return $curt

# temp dev shit dont mind
when defined(devmode):
    import std/random
    randomize()
    proc tempfile(path:string, optname: int64) =
        {.used.}
        let cols = ["red", "blue", "green", "yellow", "purple"]
        let pick = sample(cols)
        let rn = rand(100)

        var d = readFile(path)
        createDevResource(d, optname)
        writeFile(&"temp/TEMPFILE_{pick}_{rn}", d) # no clue why this


proc waitforinput() {.used.} = # not really used, just a relic before async
    storagedump()
    utils.log("***waiting for input***", 3)
    utils.log("***END***", 3)
    discard readLine(stdin)

# server below
import std/asynchttpserver
import std/mimetypes
import std/asyncdispatch
proc serve {.async.} =
    var m = newMimetypes()
    var server = newAsyncHttpServer()
    proc cb(req: Request) {.async, gcsafe.} =

        proc bozofound(path:string, who:string) {.async.} =
            utils.log(&"bozo ({who}) found nowhere {path}", 3)
            let headers = {"Content-type": "image/png; charset=utf-8"}
            await req.respond(Http200, areyoulost, headers.newHttpHeaders())

        case req.reqMethod
        of HttpPost: # POST, duh
            #utils.log(&"POST: {req}", 3)
            if req.url.path == "/upload":
                if req.headers["header_token"] == utils.readCfg("token"):
                    utils.log("wow POSTing works")
                    if len(req.body) > storage_capacity: # dunno if this is called BEFORE or after entire upload
                        utils.log("file too big", 3)
                        let headers = {"Content-type": "plain/text; charset=utf-8"}
                        await req.respond(Http200, "fatass", headers.newHttpHeaders())
                        return
                    let filename = createResource(req.body) # could return name if needed for response
                    let headers = {"Content-type": "plain/text; charset=utf-8"}
                    await req.respond(Http200, &"{endpoint}{filename}", headers.newHttpHeaders())
                    return
                else:
                    await bozofound(req.url.path, req.hostname)
                    return
            if req.url.path == "/getip":
                let headers = {"Content-type": "plain/text; charset=utf-8"}
                await req.respond(Http200, &"{req.hostname}", headers.newHttpHeaders())
                return
            await bozofound(req.url.path, req.hostname)
            return

        of HttpGet: # GET
            var (dir, requested_file, ext) = splitFile(req.url.path) #/coffee | poopfile | .png
            var mimevar = m.getMimetype(ext)#requested_file.split(".")[^1])
            var wanted_file: int64
            if (requested_file == "favicon" and mimevar == "image/x-icon"): # favicon GET
                let headers = {"Content-type": "plain/text; charset=utf-8"}
                await req.respond(Http200, "\0", headers.newHttpHeaders())
                return

            log(&"{req.hostname} requested file: {requested_file} type: {mimevar}, in {dir}", 3)
            try:
                wanted_file = parseInt(requested_file)
                if not storage.hasKey(wanted_file) or wanted_file == 0:
                    await bozofound(req.url.path, req.hostname)
                    return
            except: # catchall
                await bozofound(req.url.path, req.hostname)
                return

            let headers = {"Content-type": &"image/jpg; charset=utf-8"}
            await req.respond(Http200, (storage[wanted_file]), headers.newHttpHeaders())
        else:
            let headers = {"Content-type": "plain/text; charset=utf-8"}
            await req.respond(Http200, "", headers.newHttpHeaders())


    server.listen(Port(port))#, "0.0.0.0")
    
    while true:
        if server.shouldAcceptRequest():
            await server.acceptRequest(cb)
        else:
            await sleepAsync(500)
            # could check for hanging clients here

proc main(): void =
    when defined(devmode): # remove
        tempfile("3.jpg", 1)
        tempfile("4.png", 2)
        tempfile("5.jpg", 3)
        tempfile("1.jpg", 4)
        tempfile("2.jpg", 5)
        storagedump()
    #waitforinput()
    waitFor serve()
    return

proc init(): bool =
    if not fileExists("config.ini"):
        log("no config.ini present >:(", 1)
        return false
    utils.reloadCfg()
    when defined(devmode):
        if dirExists("temp"):
            for k in walkDir("temp"):
                log(&"(!) file found: {k.path}", 3)
                if not tryRemoveFile(k.path):
                    return false
    return true

# aka main()
when isMainModule:
  if init() == false: # if init fails, quit yo
    quit(1)
  main()
