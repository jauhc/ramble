import system
import os
import utils
import strformat
import strutils

const
    areyoulost = readFile("res/lost.png")
    devmode* = true

var 
    iStorage_capacity: int = 1
    bSecure: bool = false

import std/tables
var storage {.threadvar.}: OrderedTableRef[int64, string]
storage = newOrderedTable[int64, string]()

proc storage_size(): int =
    var t = 0
    for v in storage.values:
        t = t + len(v)
        echo "[scan] found file with size ", utils.toReadable(len(v))
    return t

proc storagedump() =
    var size = storage_size()
    utils.log("storage stats", 3)
    utils.log(&"storage size: {utils.toReadable(size)}", 3)
    utils.log("contents: ", 3)
    for i in storage.keys:
        utils.log(&"key: {i}, resource size: {utils.toReadable(len(storage[i]))}", 3)
    utils.log(&"TOTAL USAGE: {utils.toReadable(size)} / {utils.toReadable(iStorage_capacity)}", 3)
    #echo GC_getStatistics()

# returns false if too big
proc checkStorage(datalen:int): bool =
    utils.log(&"checking storage..", 3)

    if (datalen > iStorage_capacity):
        utils.log("file too big! :(", 3)
        return false

    while storage_size() + datalen > iStorage_capacity:
        for k, v in storage.pairs:
            utils.log(&"storage full, removing {k}...", 3)
            storage.del(k)
            break
    return true

proc createResource(res:string, optname:int64 = 0): string =
    let curt = (if optname == 0: utils.timestampget() else: optname)
    if checkStorage(len(res)):
        storage[curt] = res
    else:
        return "fatass"

    log(&"(+) resource added, name: {curt}, len: {utils.toReadable(len(res))}",3) #\
    #log(&"(+) resource: {storage[curt]}",3) # prints entire image as text (dont do this)
    #storagedump()
    return $curt

proc waitforinput() {.used.} = # not really used, just a relic before async
    storagedump()
    utils.log("***waiting for input***", 3)
    utils.log("***END***", 3)
    discard readLine(stdin)

# server below
import std/asynchttpserver
import std/mimetypes
import std/asyncdispatch
import std/net

proc serve {.async, gcsafe.} =
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
                    if len(req.body) > iStorage_capacity: # dunno if this is called BEFORE or after entire upload
                        utils.log("file too big", 3)
                        let headers = {"Content-type": "text/plain; charset=utf-8"}
                        await req.respond(Http200, "fatass", headers.newHttpHeaders())
                        return
                    let filename = createResource(req.body) # could return name if needed for response
                    let headers = {"Content-type": "text/plain; charset=utf-8"}
                    let endpoint: string = 
                        (if bSecure: "https" else: "http") & "://" & utils.readCfg("host") & ":" & utils.readCfg("port")
                    await req.respond(Http200, &"{endpoint}/{filename}", headers.newHttpHeaders())
                    return
                else: # make more sane or dont
                    await bozofound(req.url.path, req.hostname)
                    return
            await bozofound(req.url.path, req.hostname)
            return

        of HttpGet: # GET
            if req.url.path == "/getip": # why the FUCK cant this work
                let headers = {"Content-type": "text/plain; charset=utf-8"}
                await req.respond(Http200, req.hostname, headers.newHttpHeaders())
                return
            var (dir, requested_file, ext) = splitFile(req.url.path) #/coffee | poopfile | .png
            var mimevar = m.getMimetype(ext)#requested_file.split(".")[^1])
            var wanted_file: int64
            if (requested_file == "favicon" and mimevar == "image/x-icon"): # favicon GET
                let headers = {"Content-type": "text/plain; charset=utf-8"}
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

            let headers = {"Content-type": "image/jpg; charset=utf-8"}
            await req.respond(Http200, (storage[wanted_file]), headers.newHttpHeaders())
        else:
            let headers = {"Content-type": "text/plain; charset=utf-8"}
            await req.respond(Http200, "", headers.newHttpHeaders())

    server.listen(Port(utils.readCfg("port").parseInt))#, "0.0.0.0") 

    while true:
        if server.shouldAcceptRequest():
            await server.acceptRequest(cb)
        else:
            await sleepAsync(500)
            # could check for hanging clients here

proc main(): void =
    log("@main", 3)
    when (devmode == true): # remove
        discard createResource(readFile("res/3.jpg"), 1)
        discard createResource(readFile("res/4.png"), 2)
        discard createResource(readFile("res/5.jpg"), 3)
        discard createResource(readFile("res/1.jpg"), 4)
        discard createResource(readFile("res/2.jpg"), 5)
        storagedump()
        utils.dumpCfg() # false shows token (kinda insecure)
    #waitforinput()
    waitFor serve()
    return

proc init(): bool =
    if not fileExists("config.ini"):
        log("no config.ini present >:(", 1)
        return false
    utils.reloadCfg()
    iStorage_capacity = utils.readCfg("maxsize").parseInt
    bSecure = utils.readCfg("secure").parseBool
    utils.log("init successful", 3)
    return true

# aka main()
when isMainModule:
  if init() == false: # if init fails, quit yo
    quit(1)
  main()
