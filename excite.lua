--[[
    excite.lua
--]]

-- Requirements
local json = require "JSON"
local curl = require "cURL"
local argparse = require "argparse"
local Utils = require "./utils"
local Format = require "./format"
local API = require "./api"

local ascii_logo = [[
    ███████╗██╗  ██╗ ██████╗██╗████████╗███████╗
    ██╔════╝╚██╗██╔╝██╔════╝██║╚══██╔══╝██╔════╝
    █████╗   ╚███╔╝ ██║     ██║   ██║   █████╗  
    ██╔══╝   ██╔██╗ ██║     ██║   ██║   ██╔══╝  
    ███████╗██╔╝ ██╗╚██████╗██║   ██║   ███████╗
    ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝   ╚═╝   ╚══════╝
    [*] A terminal-based citation generator]]

-- Define arguments
local parser = argparse("excite", ascii_logo)
parser:argument("input", "ISBN code")
parser:argument("cite_style")
    :choices {"bibtex", "APA", "MLA"}
parser:flag("-o --output", "Output citation to a file.")
parser:option("-r --rename", "Rename output file.", "citation.txt")

-- Parse args
ARGS = parser:parse()
INPUT = ARGS.input
STYLE = ARGS.cite_style
OUTPUT = ARGS.output
DEFAULT_FILE = ARGS.rename

local filename = "/home/nick/github_repos/excite-cli/data.txt"

--[[
    Some example ISBNs:
    local isbn = "9781590171332" --"9780262033848" --"0140286802"
    local worksid = "OL23170657M" --"OL45883W"
--]]

local function cite(id, authors, title, container, edition, publisher, year)
    print("\n\nYOU SELECTED: ")
    print(authors .. ", " .. title .. ", " .. year)
    -- Declare output and Format object
    local output
    local fmt = Format:new(authors, title, nil, edition, publisher, year)

    -- Choose a citation style
    if STYLE == "bibtex" then
        print("Bibtex selected")
        output = fmt:bibtex(id)
    elseif STYLE == "MLA" then
        print("MLA Selected")
        output = fmt:mla()
    elseif STYLE == "APA" then
        print("APA Selected")
        output = fmt:apa()
    end

    return output
end

-- Search for relevant entries
local function search(payload)
    local doc_index = payload["docs"]
    local count = 1; local step = 4
    local block
    repeat
        local selection = tonumber(block)
        if selection and selection <= count and selection >= 1 then
            return cite(
                doc_index[selection]["title"],
                doc_index[selection]["author_name"][1],
                nil,
                nil,
                doc_index[selection]["publisher"][1],
                doc_index[selection]["first_publish_year"]
            )
        end
        -- Change the step counter if num entries not divisible by 5
        if count+4 > #doc_index then
            step = #doc_index - count
        end
        for i = count, count+step do
            ---[[
            if doc_index[i]["author_name"] then
                print("[" .. i .. "]")
                print(doc_index[i]["title"])
                print(doc_index[i]["author_name"][1])
                print(doc_index[i]["publisher"][1])
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

-- Save citation to clipboard and (optionally) to file
local function put(output)
    local f = assert(io.open("/home/nick/github_repos/excite-cli/output.txt", "w"), "Cannot open file")
    f:write(output)
    f:close()
    --os.execute(string.format("echo \"%s\" | xclip -sel clip", output))
    os.execute(string.format("cat output.txt | xclip -sel clip", output))
    --os.execute("viu test3.jpg")

    ---[[
    print("---------------------------------------------------------")
    print(output)
    print("---------------------------------------------------------")
    --]]
    print("Citation copied to clipboard")
end

-- Main method
local function main()
    print("Fetching Citation...")

    -- Format url
    local url, api_type = API.fmt_url()

    -- Format JSON data as a lua table
    local payload = API.decode(url)

    -- Handle different APIs to get the required information
    --[[
    local tabcite = {}

    if api_type == "ISBN" then
        tabcite = isbn(payload)
    elseif api_type == "SEARCH" then
        tabcite= search(payload)
    end

    -- Format citation using the table of parameters
    local output = cite(tabcite)
    assert(type(output) == "string", "Failed to format citation")

    -- Save citation to clipboard and (optionally) to file
    -- local put = put(output)

    --[[
    local isbn_data = decode(url)

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
--]]
end


main()
--main(decode, url)
--search(decode, url)
