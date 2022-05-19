--[[
    Parse different APIs
--]]

local Utils = require "./src/utils"
local API = require "./src/api"

local Parser = {}

local function isbn(payload, input)
    -- Retrieve citation by ISBN
    -- Gather basic info: author, title, year, publisher

    -- Handle authors
    local names = payload["ISBN:" .. input]["authors"]
    local first_author = Utils.split(names[1]["name"], "%s")
    local authors = first_author[2] .. ", " .. first_author[1]

    -- Multiple authors case
    if (#names == 2) then
        authors = authors .. ", and " .. names[2]["name"]
    elseif (#names > 2) then
        authors = authors .. ", et al"
    end

    -- Split date string to find the year
    local year
    local date = Utils.split(payload["ISBN:" .. input]["publish_date"], "%s")
    for _,s in pairs(date) do; year=s; end

    -- Title and publisher
    local title = payload["ISBN:" .. input]["title"]
    local publisher = payload["ISBN:" .. input]["publishers"][1]["name"]

    -- Edition
    local edition
    local works_key = payload["ISBN:" .. input]["key"]
    -- NOTE: UNCOMMENT TO GO LIVE
    --local edition_payload = API.decode("https://openlibrary.org" .. works_key .. ".json")
    --[[
    local edition_payload = API.load_cache("long-citation-support")
    if edition_payload["edition_name"] then
        edition = edition_payload["edition_name"]
    end
    --]]

    -- Format id (first author surname + year of publication)
    local id
    for _,s in pairs(first_author) do; id=s; end
    id = id:lower() .. year

    -- Return the values as a table
    return
    {
        authors,
        title,
        nil,
        edition,
        publisher,
        year,
        id
    }
end

-- Retrieve citation by DOI
local function doi(payload, input_key)
    local title = payload["message"]["title"][1]
    local year = payload["message"]["published-print"]["date-parts"][1][1]
    local publisher = payload["message"]["publisher"]
    local bibtex_id = string.lower(payload["message"]["author"][1]["family"]) .. year
    local auth_list = payload["message"]["author"]
    local authors = auth_list[1]["given"] .. ", " ..  auth_list[1]["family"]

    return
    {
        authors,
        title,
        nil, -- container
        nil, -- edition
        publisher,
        year,
        bibtex_id,
        input_key
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
                --doc_index[sel]["first_publish_year"] .. doc_index[sel]["author_name"][1]
            }
        end
    until(not block)
    print("Done")
    return nil
end

function Parser.parse_citation(payload, input_code, api_type)
    local tabcite = {}
    if api_type == "ISBN" then
        tabcite = isbn(payload, input_code)
    elseif api_type == "SEARCH" then
        tabcite = search(payload)
    elseif api_type == "DOI" then
        tabcite = doi(payload)
    end

    return tabcite
end

return Parser
