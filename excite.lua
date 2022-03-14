-- excite.lua

-- Requirements
local json = require "JSON"
local curl = require "cURL"
local argparse = require "argparse"
local fmt = require "./format"

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
--parser:argument("input", "ISBN code")
parser:argument("cite_style")
--    :choices {"bibtex", "APA", "MLA"}
parser:flag("-o --output", "Output citation to a file.")
parser:option("-r --rename", "Rename output file.", "citation.txt")

-- Parse args
ARGS = parser:parse()
INPUT = ARGS.input
STYLE = ARGS.cite_style
OUTPUT = ARGS.output
DEFAULT_FILE = ARGS.rename

local isbn = "9780262033848" --"0140286802"
--local worksid = "OL23170657M" --"OL45883W" 
local filename = "/home/nick/github_repos/excite-cli/data.txt"
--local url = string.format("https://openlibrary.org/works/%s.json", worksid)
local url = "https://openlibrary.org/api/books?bibkeys=ISBN:" .. isbn .. "&jscmd=data&format=json"


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
        -- setup url
        c:setopt_url(url)
        -- perform, invokes callbacks
        c:perform({writefunction = function(str)
                        f:write(str)
                        end})
        -- close output file
        f:close()
    local data = io.open(filename)
    local str = data:read("*a")
    data:close()
    return json:decode(str)
end

--[[
-- Bibtex format
local function bibtex(decode, authors, title, year, publisher)
    -- Format id: Split the author string, loop through to find last name, format id
    local first_author = split(decode["ISBN:" .. isbn]["authors"][1]["name"], "%s")
    local id = nil
    for _,s in pairs(first_author) do; id=s; end
    id = id:lower() .. year
    -- Return a bibtex string
    return "@book{" .. id .. ",\n" ..
    "author = " .. string.format("\"%s\"", authors) .. "\n" ..
    "title = " .. string.format("\"%s\"", title) .. "\n" ..
    "year = " .. string.format("\"%s\"", year) .. "\n" ..
    "publisher = " .. string.format("\"%s\"", publisher) .. "\n" ..
    "}"
end

local function mla(authors, title, container, edition, publisher, year)
    return authors .. ". \"" .. title .. ".\" \n\t" .. edition .. ", " .. publisher .. ", \t" .. year .. ", Accessed 08 March 2022."
end

local function apa()
end

--]]

local function cite(decode, url)
    -- Gather basic info: author, title, year, publisher
    print("Fetching Citation...")
    local isbn_data = decode(url)

    -- Get edition from worksID
    local OLID = isbn_data["ISBN:" .. isbn]["identifiers"]["openlibrary"][1]
    local url2 = "https://openlibrary.org/books/" .. OLID .. ".json"
    local edition = decode(url2)["edition_name"]

    -- Handle authors
    local names = isbn_data["ISBN:" .. isbn]["authors"]
    local authors = isbn_data["ISBN:" .. isbn]["authors"][1]["name"]
    for i,v in pairs(names) do
        if (i > 1) then
            authors = authors .. ", " .. v["name"]
        end
    end

    -- Split date string to find the year
    local year = nil
    local date = split(isbn_data["ISBN:" .. isbn]["publish_date"], "%s")
    for _,s in pairs(date) do; year=s; end
    -- Title and publisher
    local title = isbn_data["ISBN:" .. isbn]["title"]
    local publisher = isbn_data["ISBN:" .. isbn]["publishers"][1]["name"]

    local output = nil

    -- test fmt
    --output = fmt.bibtex(id, authors, title, year, publisher)
    --output = fmt.mla(authors, title, nil, edition, publisher, year)

    if STYLE == "bibtex" then
        print("HERE")
        -- Format id
        local first_author = split(isbn_data["ISBN:" .. isbn]["authors"][1]["name"], "%s")
        local id = nil
        for _,s in pairs(first_author) do; id=s; end
        id = id:lower() .. year
        print("Bibtex selected")
        output = fmt.bibtex(id, authors, title, year, publisher)
    elseif STYLE == "MLA" then
        print("MLA Selected")
        output = fmt.mla(authors, title, nil, edition, publisher, year)
    elseif STYLE == "APA" then
        print("APA Selected")
    end

    assert(type(output) == "string", "Failed to format citation")
    local f = assert(io.open("/home/nick/github_repos/excite-cli/output.txt", "w"), "Cannot open file")
    f:write(output)
    f:close()
    --os.execute(string.format("echo \"%s\" | xclip -sel clip", output))
    os.execute(string.format("cat output.txt | xclip -sel clip", output))
    -- os.execute("viu test3.jpg")

    ---[[
    print("---------------------------------------------------------")
    print(output)
    print("---------------------------------------------------------")
    --]]
    print("Citation copied to clipboard")
end


cite(decode, url)

