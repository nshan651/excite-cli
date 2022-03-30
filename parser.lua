--[[
    Parse different APIs
--]]

local Parser = {}

-- Retrieve citation by ISBN
local function isbn()
    -- Gather basic info: author, title, year, publisher

    -- Get edition from worksID
    local OLID = isbn_data["ISBN:" .. INPUT]["identifiers"]["openlibrary"][1]
    local edition = decode("https://openlibrary.org/books/" .. OLID .. ".json")["edition_name"]

    -- Handle authors
    local names = isbn_data["ISBN:" .. INPUT]["authors"]
    local authors = names[1]["name"]
    local first_author = split(names[1]["name"], "%s")
    for i,v in pairs(names) do
        if (i > 1) then
            authors = authors .. ", " .. v["name"]
        end
    end

    -- Split date string to find the year
    local year = nil
    local date = split(isbn_data["ISBN:" .. INPUT]["publish_date"], "%s")
    for _,s in pairs(date) do; year=s; end
    -- Title and publisher
    local title = isbn_data["ISBN:" .. INPUT]["title"]
    local publisher = isbn_data["ISBN:" .. INPUT]["publishers"][1]["name"]

    -- Format id (first author surname + year of publication)
    local id
    for _,s in pairs(first_author) do; id=s; end
    id = id:lower() .. year

    local output = cite(id, authors, title, nil, nil, publisher, year)

    assert(type(output) == "string", "Failed to format citation")

end
-- Search for relevant entries
local function search(decode, url)
    local search_data = decode(url)
    local doc_index = search_data["docs"]
    local count = 1; local step = 4
    local block
    repeat
        -- TODO: Input checking for this function!
        local sel = tonumber(block)
        if sel then
            tmp(
                doc_index[sel]["title"],
                doc_index[sel]["author_name"][1],
                doc_index[sel]["first_publish_year"],
                nil
            )
        end
        -- Change the step counter if num entries not divisible by 5
        if count+4 > #doc_index then
            step = #doc_index - count
        end
        for i = count, count+step, 1 do
            ---[[
            if doc_index[i]["author_name"] then
                print("[" .. i .. "]")
                print(doc_index[i]["title"])
                print(doc_index[i]["author_name"][1])
                print(doc_index[i]["first_publish_year"])
                print("-------------------------")
            end
            --]]
        end
        print("Press any key for more results")
        count = count+5
        block = io.read()
        --block = true
        print("-------------------------")
    until(not block or count >= #doc_index)
    print("Done")
end

return Parser
