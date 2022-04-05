--[[
    Parse different APIs
--]]

local API = require "./api"
local Utils = require "./utils"

local Parser = {}

-- Retrieve citation by ISBN
-- TODO: Handle container
function Parser.isbn(payload, input)
    -- Gather basic info: author, title, year, publisher

    -- Get edition from worksID (Make a separate call to WorksID API)
    --local OLID = payload["ISBN:" .. input]["identifiers"]["openlibrary"][1]
    --local edition = API.decode("https://openlibrary.org/books/" .. OLID .. ".json")["edition_name"]

    local edition = API.load_cache("worksID-test")["edition_name"]

    -- Handle authors
    local names = payload["ISBN:" .. input]["authors"]
    local authors = names[1]["name"]
    local first_author = Utils.split(names[1]["name"], "%s")
    for i,v in pairs(names) do
        if (i > 1) then
            authors = authors .. ", " .. v["name"]
        end
    end

    -- Split date string to find the year
    local year = nil
    local date = Utils.split(payload["ISBN:" .. input]["publish_date"], "%s")
    for _,s in pairs(date) do; year=s; end
    -- Title and publisher
    local title = payload["ISBN:" .. input]["title"]
    local publisher = payload["ISBN:" .. input]["publishers"][1]["name"]

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

-- Search for relevant entries
-- TODO: Handle container, edition name for SearchAPI, convert ID
function Parser.search(payload)
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

return Parser
