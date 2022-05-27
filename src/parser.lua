--[[
    Parse different APIs
--]]

local Utils = require "./src/utils"
local API = require "./src/api"

local Parser = {}

--[[ Standardize the author table to the form:
    t = {
        [1] =
        {
            { ['given'] = 'given'},
            { ['family'] = 'family'},
        }
        [etc...]
--]]

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
    for _,s in pairs(date) do; year=s; end

    -- Title and publisher
    local title = payload["ISBN:" .. input_key]["title"]
    local publisher = payload["ISBN:" .. input_key]["publishers"][1]["name"]

    return
    {
        authors,
        title,
        nil, --container
        nil, -- journal
        year,
        publisher,
        nil -- pages
    }
end

local function doi(payload)
    -- Retrieve citation by DOI

    -- Standardized author table
    local names = payload["message"]["author"]
    local authors = {}
    for i=1, #names do
        authors[i] = { ["given"] = names[i]["given"], ["family"] = names[i]["family"] }
    end
    local title = payload["message"]["title"][1]
    local journal = payload["message"]["container-title"][1]
    local year = payload["message"]["indexed"]["date-parts"][1][1]
    local publisher = payload["message"]["publisher"]
    local pages = payload["message"]["page"]

    return
    {
        authors,
        title,
        nil, --container
        journal,
        year,
        publisher,
        pages
    }

end

-- Search for relevant entries
-- TODO: Handle container, edition name for SearchAPI, convert ID
local function search(payload)
    local doc_index = payload["docs"]
    local count = 1; local step = 4
    local block
    repeat
        -- Print results menu in increments of 5
        if count < #doc_index then
            -- Change the step counter if num entries not divisible by 5
            if count+4 > #doc_index then
                step = #doc_index - count
            end
            for i = count, count+step, 1 do
                if doc_index[i]["author_name"] then
                    print("[" .. i .. "]")
                    print("   " .. doc_index[i]["title"])
                    print("   " .. doc_index[i]["author_name"][1])
                    print("   " .. doc_index[i]["first_publish_year"])
                    print("-------------------------")
                end
            end
            print("Press any key for more results")
            count = count+5
        end

        block = io.read()
        local sel = tonumber(block)
        if sel then
            return
            {
                doc_index[sel]["author_name"][1],
                doc_index[sel]["title"],
                nil,
                nil,
                doc_index[sel]["publisher"][1],
                doc_index[sel]["first_publish_year"],
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
        tabcite = search(payload)
    elseif api_type == "DOI" then
        tabcite = doi(payload)
    end

    return tabcite
end

return Parser
