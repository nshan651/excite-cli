--[[
    excite.lua
--]]
local argparse = require "argparse"

local ascii_logo = [[
    ███████╗██╗  ██╗ ██████╗██╗████████╗███████╗
    ██╔════╝╚██╗██╔╝██╔════╝██║╚══██╔══╝██╔════╝
    █████╗   ╚███╔╝ ██║     ██║   ██║   █████╗  
    ██╔══╝   ██╔██╗ ██║     ██║   ██║   ██╔══╝  
    ███████╗██╔╝ ██╗╚██████╗██║   ██║   ███████╗
    ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝   ╚═╝   ╚══════╝
    [*] A terminal-based citation generator]]

local ap = argparse("excite", ascii_logo)

ap:argument("proj_dir", "Project directory location")
ap:argument("cite_style", "Cite style")
    :choices {"bibtex", "APA", "MLA"}
ap:argument("input", "ISBN, DOI, or title query")
    :args "+"
ap:flag("-o --output", "Output citation to a file.")
ap:option("-r --rename", "Rename output file.", "citation.txt")
ARGS = ap:parse()
PROJ_DIR = ARGS.proj_dir
INPUT = ARGS.input
STYLE = ARGS.cite_style
OUTPUT_FLAG = ARGS.output
DEFAULT_FILE = ARGS.rename

-- Add local modules to the path
package.path = package.path .. ";" .. PROJ_DIR .. "/src/?.lua"

-- Source local modules
local Main = require("main")
local API = require("api")

local function main()

    -- Format url
    local url, api_type = API.fmt_url(INPUT)
    -- Format JSON data as a lua table
    local payload = API.decode(url)

    Main.run(payload, INPUT, api_type, STYLE, OUTPUT_FLAG, DEFAULT_FILE, PROJ_DIR)
end

main()

