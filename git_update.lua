local pretty = require "cc.pretty"
local etag = {}
local fileTree = {}

if fs.exists("etag.data") then
    print("reading etag datafile")
    local file = fs.open("etag.data", "r")
    etag = file.readAll()
    etag = textutils.unserialise(etag)
    file.close()
end

if fs.exists("fileTree.data") then
    print("reading content tree datafile")
    local file = fs.open("fileTree.data", "r")
    fileTree = file.readAll()
    fileTree = textutils.unserialise(fileTree)
end

local function decodeUrl(url)
    local segment = string.gmatch(url, "(.-)/")
    local protocol, domain, usr, repo, contents = segment(), segment(), segment(), segment(), segment()
    local path = {}
    for v in segment do table.insert(path, v) end
    return {
        ["protocol"] = protocol,
        ["domain"] = domain,
        ["user"] = usr,
        ["repo"] = repo,
        ["contents"] = contents,
        ["path"] = path
    }
end

local function fetchRequest(request)
    if etag[request.url] then
        request.headers["If-None-Match"] = etag[request.url]
    end
    if not request["User-Agent"] then
        request.headers["User-Agent"] = "mms92-cc-app"
    end
    if not request["Accept"] then
        request.headers["Accept"] = "application/vnd.github.v3.object+json"
    end
    http.request(request)
end

local function receive()
    local event_data
    repeat
        event_data = {os.pullEvent()}
    until event_data[1] == "http_success" or event_data[1] == "http_failure"
    
    local response = false
    local url = event_data[2]
    --print(event_data[2] .. " : " .. event_data[1])
    
    if event_data[1] == "http_success" then
        response = event_data[3]
    else
        local err_message = event_data[3]
        response = event_data[4]
        printError(("error, can't reach github, '%s'"):format(err_message))
    end
    
    if response then
        --print("http code : " .. response.getResponseCode())
        --textutils.pagedPrint( textutils.serialise( response.getResponseHeaders() ) )
        --textutils.pagedPrint( response.readAll() )
        code = response.getResponseCode()
        headers = response.getResponseHeaders()
        data = response.readAll()
        data = textutils.unserialiseJSON(data)
        response = {
            ["url"] = url
            ["code"] = code
            ["headers"] = headers,
            ["body"] = data
        }
        fetchResponse(response)
    end
end

local function fetchResponse(response)
    if code == 304 then
        --nothing
    elseif code == 404 then
        --nothing
    elseif code == 200 then
        local url_sub = decodeUrl(response.url)

    end
        
end

local request = {
    ["url"] = "https://api.github.com/mms92/Lua-ComputerCraft/contents",
    ["body"] =  "",
    ["headers"] = {
        ["User-Agent"] = "mms92-cc-app",
        ["Accept"] = "application/vnd.github.v3.object+json"
    },
    ["binary"] = false,
    ["method"] = "GET",
    ["redirect"] = true
}

http.request( request )

