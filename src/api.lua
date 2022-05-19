--[[
    API handling module
--]]

local json = require "JSON"
local curl = require "cURL"
local Utils = require "./src/utils"

local API = {}

-- API switch to determine which api you are using (ISBN/WorksID, search, etc.)
function API.fmt_url(input)
    local url
    local api_type
    -- Pattern matching query to check for ISBN 10/13
    if
        string.match(input, "%d%d%d%d%d%d%d%d%d%d%d%d%d") or string.match(input, "%d%d%d%d%d%d%d%d%d%d")
    then
        url = "https://openlibrary.org/api/books?bibkeys=ISBN:" .. input .. "&jscmd=data&format=json"
        api_type = "ISBN"
    -- DOI query
    elseif
        string.match(input, "10.%d%d%d%d/.+")
    then
        url = "https://api.crossref.org/works/" .. input
        api_type = "DOI"
    -- Text-based search
    else
        local query = Utils.split(string.lower(input))
        local output = query[1]
        for i = 2, #query do
                output = output .. "+" .. query[i]
        end
        url = "https://openlibrary.org/search.json?title=" .. output
        api_type = "SEARCH"
    end
    return url, api_type
end

-- HTTP GET: curl the data and return decoded JSON table
-- TODO: Make data.txt a tempfile
function API.decode(url)
    local filename = "/home/nick/github_repos/excite-cli/cache/data.txt"
    local f = assert(io.open(filename, "w"), "Cannot write to file")
    local c = curl.easy_init()
        c:setopt_url(url)
        -- perform, invokes callbacks
        c:perform({writefunction = function(str)
                        f:write(str)
                        end})
        f:close()
    local data = assert(io.open(filename), "Cannot open file")
    local str = data:read("*a")
    data:close()
    return json:decode(str)
end

-- Return JSON table of cached data for testing
-- Cached files: isbn-bibtex, isbn-apa, search-bibtex, search-apa
function API.load_cache(api_type, test_type)
    local filename = "/home/nick/github_repos/excite-cli/cache/" .. api_type .. "/" .. test_type .. ".json"
    local data = assert(io.open(filename), "Cannot open file")
    local str = data:read("*a")
    data:close()
    return json:decode(str)
end

return API

