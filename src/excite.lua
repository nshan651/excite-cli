--[[
    excite.lua
--]]

local argparse = require "argparse"
local Main = require "./src/main"
local API = require "./src/api"

local ascii_logo = [[
    ███████╗██╗  ██╗ ██████╗██╗████████╗███████╗
    ██╔════╝╚██╗██╔╝██╔════╝██║╚══██╔══╝██╔════╝
    █████╗   ╚███╔╝ ██║     ██║   ██║   █████╗  
    ██╔══╝   ██╔██╗ ██║     ██║   ██║   ██╔══╝  
    ███████╗██╔╝ ██╗╚██████╗██║   ██║   ███████╗
    ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝   ╚═╝   ╚══════╝
    [*] A terminal-based citation generator]]

local ap = argparse("excite", ascii_logo)
ap:argument("input", "ISBN, DOI, or title query")
ap:argument("cite_style")
    :choices {"bibtex", "APA", "MLA"}
ap:flag("-o --output", "Output citation to a file.")
ap:option("-r --rename", "Rename output file.", "citation.txt")

ARGS = ap:parse()
INPUT = ARGS.input
STYLE = ARGS.cite_style
OUTPUT_FLAG = ARGS.output
DEFAULT_FILE = ARGS.rename

local function main()

    -- Format url
    local url, api_type = API.fmt_url(INPUT)
    -- Format JSON data as a lua table
    local payload = API.decode(url)

    -- Test: https://doi.org/10.1109/5.771073
    --Utils.recurse_table(payload)
    Main.run(payload, INPUT, api_type, STYLE, OUTPUT_FLAG, DEFAULT_FILE)
end

main()

