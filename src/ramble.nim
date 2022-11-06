import system
import os
import utils
import strformat
import strutils
import times

# TODO
#  secure
#  or just use some framework like jester

# 1 gb = 1024 * 1024 * 1024
const # holy fuck this became cluttered but const is comptime so its ok i guess
    devmode = true
    host = "localhost"
    port = 8080
    name: string = if devmode:
            "totallysecurestringfrfr"
        else:
            "qLiRZxH7f$ei&HTkq9#4doW9b%2eEch3$MTopFpctnCc4YPjZjHXaRbk%ZtobeD@ouAE9gncP5Nfdfq~cjvuLWYvcZi3^kA2D"

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
#const areyoulost = decode("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IYcs/FVCF1101wxddNFds6quG3CHPAQN6Q4R63uju2/Dultzhxyy5tcL3cyhmzl0M4du5kTXQaxVqUq2de0rh3R1SHTjHbDRrd0CrIVu5tDNHLqZQzd9tiodxG4x27BO175oiLht4DirsO0H7xac0c0cuplDN3Popq9KrLUQcTRqW5+UtOV01biuPg7Btp8+jV5voQ8J3cyhmzl0M4fubSS6f5bcWsjeOX8SVNW1gTax41S9sHrS3NOngRskRjdz6GYO3cyhmzQtoU35X6VoGbQ1rqszztSNqurqNty+GyRGF1101wxddNFdLifUBuvYF+lGLlXitq47rgrb1o2cUxKjiy66a4YuuuiulJbrTMQq7BZdtxXBuq3Nuu7gg1kuFLroortm6KKL7nK1XSK6y+hKUmm0+rrsngId3IZt6356Khsxuuiiu2booovumsmlilg9ZLOuY9Jo9Kb8LEijbdjoJj8Nqp52JNGG0EUX3TVDF110F06L5Cb1WamDrmN97k+1dXVD7tYiXV3A6VbfgMd1lydGF1101wxddNFdM81bW7ZS9vHfpV5dt1K25ayqQhGxzrgPcrcbqUW60e3mJUYXXXTRRXe20M2sa2nyWi4Rj+u6nFVV1xXB/qfkdKtq6FrooovumqGLLrprpsk/PK6q2wsr3erLr3sNtqLR/5Z0XMf3nnm7iWAtdNFFd83QRRfdlbp7nNONYDV5G/1fqVe3Det022d0WDkcmxG66KKL7vyhiy66y+k6uqpue816lysidjdU1Y0O0ZOGbhS66KKLLrqzhe4N6bplaOuOw0q3ekOi01b1xoeEtujqSdtNYo/Q7T8X3Y7QvVro9p+LbkfoXq22bhV2i67VXqm2ru55XGjoJt252trX5HKh238uur2he43Q7T8X3d7QvUaRrntddusYPQpjsqUhXXdw71duudPoWUcX3ZlCF1100UV3tpzuEOx+xFXd6K6GhHrP0Gqgi+6coYsuuuiiO1sdur25M3p17eDorrboRrDjuu5cdNGdKXTRRRdddGfrMrrVgzsWM1oux6mGrhwxVQ9xaQ3QRXfO0EUXXXTRPa//A/sThXi9zrbOAAAAAElFTkSuQmCCICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIA==")

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
import std/random
randomize()
proc tempfile(path:string, optname: int64) =
    {.used.}
    let cols = ["red", "blue", "green", "yellow", "purple"]
    let pick = sample(cols)
    let rn = rand(100)

    var d = readFile(path)
    #echo &"addr: {createResource(path, d)}"
    createDevResource(d, optname)
    writeFile(&"temp/TEMPFILE_{pick}_{rn}", d) # no clue why this

proc waitforinput() =
    storagedump()
    utils.log("***waiting for input***", 3)
    utils.log("***END***", 3)
    discard readLine(stdin)

# server below
import std/asynchttpserver
import std/mimetypes
import std/asyncdispatch
import parseutils
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
                if req.headers["header_token"] == name:
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

proc main(): void =
    if devmode: # remove
        tempfile("1655487339358.jpg", 1)
        tempfile("1666295383340844.png", 2)
        tempfile("FenxBtiakAEYj7f.jpg", 3)
        tempfile("1.jpg", 4)
        tempfile("2.jpg", 5)
        storagedump()
    #waitforinput()
    waitFor serve()
    return

proc init(): bool =
    if devmode:
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
