--[[
    Unit testing for src/main.lua
--]]

local API = require "./src/api"
local Main = require "./src/main"
local Utils = require "./src/utils"

TESTFILES = {
    ["isbn"] =
    {
        "single-author",
        "two-authors",
        "authors-et-al",
        "long-citation"
    },
    ["search"] =
    {nil},
    ["doi"] =
    {
        "doi-test"
    }
}

local function run_tests(testfiles)
    local cite_format = "bibtex"
    for api_type,_ in pairs(testfiles) do
            for _,test_type in pairs(testfiles[api_type]) do
                local payload = API.load_cache(api_type, test_type)

                local input_code = ""
                for key,_ in pairs(payload) do
                   input_code = Utils.split(key, ":")[2]
                end

                ---[[
                if api_type == "doi" then
                    print("\n             | Testing for: " .. test_type .. " |        \n")
                    Main.run(payload, input_code, "DOI", cite_format)
                end
                --]]
                --[[
                if api_type == "isbn" then
                    Main.run(payload, input_code, "ISBN", cite_format)
                elseif api_type == "search" then
                    Main.run(payload, input_code, "SEARCH", cite_format)
                elseif api_type == "doi" then
                    Main.run(payload, input_code, "DOI", cite_format)
                end
                --]]
            end
    end
end

run_tests(TESTFILES)
