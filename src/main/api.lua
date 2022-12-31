#!/usr/bin/lua

--[[
    API handling module
--]]

local json = require "JSON"
local curl = require "cURL"

local API = {}

-- API switch to determine which api you are using (ISBN/WorksID, search, etc.)
function API.fmt_url(input)
    local url
    local api_type
    -- Ignore dashes when reading ISBN code
    local trim_input = string.gsub(input[1], "-", "")
    -- Pattern matching query to check for ISBN 10/13
    if
        string.match(trim_input, "%d%d%d%d%d%d%d%d%d%d%d%d%d") or string.match(trim_input, "%d%d%d%d%d%d%d%d%d%d")
    then
        url = "https://openlibrary.org/api/books?bibkeys=ISBN:" .. input[1] .. "&jscmd=data&format=json"
        api_type = "ISBN"
    -- DOI query
    elseif
        string.match(input[1], "10.%d%d%d%d/.+")
    then
        url = "https://api.crossref.org/works/" .. input[1]
        api_type = "DOI"
    -- Search API
    else
        local query = string.gsub(input[1], " ", "+")
        url = "https://openlibrary.org/search.json?title=" .. string.lower(query)
        api_type = "SEARCH"
    end
    -- Text-based search
    return url, api_type
end

-- HTTP GET: curl the data and return decoded JSON table
function API.decode(url)
    --local tempfile = "/home/nick/git/excite-cli/cache/data.txt"
    local tempfile = "/tmp/excite-tmpfile"
    local f = assert(io.open(tempfile, "w"), "Cannot write to file")
    local c = curl.easy_init()
        c:setopt_url(url)
        -- perform, invokes callbacks
        c:perform({writefunction = function(str)
                        f:write(str)
                        end})
        f:close()
    local data = assert(io.open(tempfile), "Cannot open file")
    local str = data:read("*a")
    data:close()
    -- Remove tempfile when finished
    os.execute("rm " .. tempfile)
    return json:decode(str)
end

return API

