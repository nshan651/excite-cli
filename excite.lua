--[[
    excite.lua
--]]

-- Requirements
local json = require "JSON"
local curl = require "cURL"
local argparse = require "argparse"
local Format = require "./format"

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

-- Split function (no string split function in standard lua)
local function split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

-- HTTP GET: curl the data and return decoded json table
local function decode(url)
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

local function cite(decode, url)
    -- Gather basic info: author, title, year, publisher
    print("Fetching Citation...")
    local isbn_data = decode(url)

    -- Get edition from worksID
    local OLID = isbn_data["ISBN:" .. INPUT]["identifiers"]["openlibrary"][1]
    local url2 = "https://openlibrary.org/books/" .. OLID .. ".json"
    local edition = decode(url2)["edition_name"]

    -- Handle authors
    local names = isbn_data["ISBN:" .. INPUT]["authors"]
    local authors = isbn_data["ISBN:" .. INPUT]["authors"][1]["name"]
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

    -- Declare output and Format object
    local output = nil
    local fmt = Format:new(authors, title, nil, nil, year, publisher)

    -- Choose a citation style
    if STYLE == "bibtex" then
        -- Format id
        local first_author = split(isbn_data["ISBN:" .. INPUT]["authors"][1]["name"], "%s")
        local id = nil
        for _,s in pairs(first_author) do; id=s; end
        id = id:lower() .. year
        print("Bibtex selected")
        output = fmt:bibtex(id)
    elseif STYLE == "MLA" then
        print("MLA Selected")
        output = fmt.mla(authors, title, nil, edition, publisher, year)
    elseif STYLE == "APA" then
        print("APA Selected")
        output = fmt.apa(authors, title, nil, edition, publisher, year)
    end

    assert(type(output) == "string", "Failed to format citation")
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

local url = nil
-- Pattern matching query to check for ISBN 10/13
if string.match(INPUT, "%d%d%d%d%d%d%d%d%d%d%d%d%d") then
    -- ISBN search
    url = "https://openlibrary.org/api/books?bibkeys=ISBN:" .. INPUT .. "&jscmd=data&format=json"
else
    -- Text-based search
    local query = split(string.lower(INPUT))
    local output = query[1]
    for i,_ in pairs(query) do
        if i > 1 then
            output = output .. "+" .. query[i]
        end
    end
    url = "http://openlibrary.org/search.json?title=" .. output
end

cite(decode, url)

-- TEST
--[[
local d = decode(url)

local tab = {"yeezy", "MBDTF", nil, "69th Edition", "GOOD Music", "1999"}
local form = fmt:new("yeezy", "MBDTF", nil, "69th Edition", "GOOD Music", "1999")

--form.tab = tab
print(fmt:bibtex("ye420"))
--]]
