--[[
    excite.lua
--]]

-- Requirements
local argparse = require "argparse"

local Parser = require "./parser"
local API = require "./api"
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
local ap = argparse("excite", ascii_logo)
ap:argument("input", "ISBN code")
ap:argument("cite_style")
    :choices {"bibtex", "APA", "MLA"}
ap:flag("-o --output", "Output citation to a file.")
ap:option("-r --rename", "Rename output file.", "citation.txt")

-- Parse args
ARGS = ap:parse()
INPUT = ARGS.input
STYLE = ARGS.cite_style
OUTPUT = ARGS.output
DEFAULT_FILE = ARGS.rename

--[[
    Some example ISBNs:
    local isbn = "9781590171332" --"9780262033848" --"0140286802"
    local worksid = "OL23170657M" --"OL45883W"
    local doi = 10.1016/j.cose.2020.101892

--]]

-- Save citation to clipboard and (optionally) to file
local function put(output)
    local f = assert(io.open("/home/nick/github_repos/excite-cli/output.txt", "w"), "Cannot open file")
    f:write(output)
    f:close()
    os.execute(string.format("cat output.txt | xclip -sel clip", output))
    --os.execute("viu test3.jpg")

    print("---------------------------------------------------------")
    print(output)
    print("---------------------------------------------------------")
    print("Citation copied to clipboard")
end

-- Main method
local function main()
    print("Fetching Citation...")

    --[[
        Swtich between formatting the url/making API calls and loading from local cache
        TODO: A more elegant testing system
    --]]

    -- Format url
    local url, api_type = API.fmt_url(INPUT)

    -- Format JSON data as a lua table
    --local payload = API.decode(url)
    local payload = API.load_cache("doi") -- Cached files: isbn-bibtex, isbn-apa, search-bibtex, search-apa

    ---[[
    -- Handle different APIs to get the required information
    local tabcite = {}
    if api_type == "ISBN" then
        tabcite = Parser.isbn(payload, INPUT)
    elseif api_type == "SEARCH" then
        tabcite = Parser.search(payload)
    elseif api_type == "DOI" then
        tabcite = Parser.doi(payload)
    end

    --[[
    -- Format and output citation
    local fmt = Format:new(tabcite)
    local output = fmt:cite(STYLE)

    -- Save citation to clipboard and (optionally) to file
    put(output)
    --]]
end

main()
