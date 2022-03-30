--[[
    API handling module
--]]

local json = require "JSON"
local curl = require "cURL"
local Utils = require "./utils"

local API = {}

-- API switch to determine which api you are using (ISBN/WorksID, search, etc.)
function API.fmt_url(input)
    local url
    local api_type
    -- Pattern matching query to check for ISBN 10/13
    if
        string.match(input, "%d%d%d%d%d%d%d%d%d%d%d%d%d") or string.match(input, "%d%d%d%d%d%d%d%d%d%d")
    then
        -- ISBN search
        url = "https://openlibrary.org/api/books?bibkeys=ISBN:" .. input .. "&jscmd=data&format=json"
        api_type = "ISBN"
    else
        -- Text-based search
        local query = Utils.split(string.lower(input))
        local output = query[1]
        for i = 2, #query do
                output = output .. "+" .. query[i]
        end
        url = "http://openlibrary.org/search.json?title=" .. output
        api_type = "SEARCH"
    end
    return url, api_type
end

-- HTTP GET: curl the data and return decoded json table
function API.decode(url)
    local filename = "/home/nick/github_repos/excite-cli/data.txt"
    local f = io.open(filename, "w")
    local c = curl.easy_init()
        c:setopt_url(url)
        -- perform, invokes callbacks
        c:perform({writefunction = function(str)
                        f:write(str)
                        end})
        f:close()
    local data = io.open(filename)
    local str = data:read("*a")
    data:close()
    return json:decode(str)
end

return API

