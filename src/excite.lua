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
ap:argument("cite_style", "Cite style")
    :choices {"bibtex", "APA", "MLA"}
ap:argument("input", "ISBN, DOI, or title query")
    :args "+"
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

    Main.run(payload, INPUT, api_type, STYLE, OUTPUT_FLAG, DEFAULT_FILE)
end

main()

