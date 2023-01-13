#!/usr/bin/lua

--[[
    Parse different APIs
--]]

--package.path = package.path .. ";" .. os.getenv("HOME") .. "/git/excite-cli" .. "/src/main/?.lua"

--local Utils = require "utils"

local Parser = {}

local function isbn(payload, input_key)
    -- Retrieve citation by ISBN
    -- Gather basic info: author, title, year, publisher

    -- Handle authors
    local names = payload["ISBN:" .. input_key]["authors"]
    local authors = {}
    for i=1, #names do
        local author = Utils.split(names[i]["name"], "%s")
        authors[i] = { ['given'] = author[1], ['family'] = author[2] }
    end

    -- Split date string to find the year
    local year
    local date = Utils.split(payload["ISBN:" .. input_key]["publish_date"], "%s")
    for _,s in pairs(date) do
        year=s
    end

    -- Title and publisher
    local title = payload["ISBN:" .. input_key]["title"]
    local publisher = payload["ISBN:" .. input_key]["publishers"][1]["name"]

    -- bibtex code
    local bibtex = authors[1]["family"]:lower() .. year

    return
    {
        authors,
        title,
        nil, --container
        nil, -- journal
        year,
        publisher,
        nil, -- pages
        bibtex
    }
end

local function doi(payload)
    -- Retrieve citation by DOI

    -- Standardize author table
    local names = payload["message"]["author"]
    local authors = {}
    for i=1, #names do
        authors[i] = { ["given"] = names[i]["given"], ["family"] = names[i]["family"] }
    end
    local title = payload["message"]["title"][1]
    local journal = payload["message"]["container-title"][1]
    local year = payload["message"]["published"]["date-parts"][1][1]
    local publisher = payload["message"]["publisher"]
    local pages = payload["message"]["page"]

    -- bibtex code
    local bibtex = authors[1]["family"]:lower() .. year

    return
    {
        authors,
        title,
        nil, --container
        journal,
        year,
        publisher,
        pages,
        bibtex
    }

end

--[[
    Search for relevant entries in increments of 5 at a time
    Each entry must have an author name, title, first year published, and an isbn
--]]
local function search(payload)
    local count = 1; local step = 4
    local block
    repeat
        -- Print results menu in increments of 5
        if count < #payload then
            -- Change the step counter if num entries not divisible by 5
            if count+4 > #payload then
                step = #payload - count
            end
            for i = count, count+step, 1 do
                if
                    payload[i]["author_name"] and payload[i]["title"] and
                    payload[i]["first_publish_year"] and payload[i]["isbn"]
                then
                    print("[" .. i .. "]")
                    print("   " .. payload[i]["title"])
                    print("   " .. payload[i]["author_name"][1])
                    print("   " .. payload[i]["first_publish_year"])
                    print("   " .. "ISBN: " ..  payload[i]["isbn"][1])
                    print("__________________________________________")
                end
            end
            print("Press any key for more results")
            count = count+5
        end

        block = io.read()

        local sel = tonumber(block)
        if sel then
            -- Handle authors
            local names = payload[sel]["author_name"]
            local authors = {}
            for i=1, #names do
                local author = Utils.split(names[i], "%s")
                authors[i] = { ['given'] = author[1], ['family'] = author[2] }
            end
            return
            {
                authors,
                payload[sel]["title"],
                nil, --container
                nil, --journal
                payload[sel]["first_publish_year"],
                payload[sel]["publisher"][1],
                nil
            }
        end
    until(not block)
    print("Done")
    return nil
end

function Parser.parse_citation(payload, input_key, api_type)
    local tabcite = {}
    if api_type == "ISBN" then
        tabcite = isbn(payload, input_key)
    elseif api_type == "SEARCH" then
        tabcite = search(payload["docs"])
    elseif api_type == "DOI" then
        tabcite = doi(payload)
    end

    return tabcite
end

return Parser
