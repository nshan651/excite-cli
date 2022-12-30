#!/usr/bin/lua

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

ap:argument("cite_style", "Cite style")
    :choices {"bibtex", "APA", "MLA"}
ap:argument("input", "ISBN, DOI, or title query")
    :args "+"
ap:flag("-o --output", "Output citation to a file.")
ap:option("-r --rename", "Rename output file.", "citation.txt")
ARGS = ap:parse()
INPUT_KEY = ARGS.input
CITE_STYLE = ARGS.cite_style
OUTPUT_FLAG = ARGS.output
DEFAULT_FILE = ARGS.rename

-- Add local modules to the path
local PROJ_DIR = os.getenv("HOME") .. "/git/excite-cli"
package.path = package.path .. ";" .. os.getenv("HOME") .. "/git/excite-cli" .. "/src/?.lua"

-- Source local modules
--local Main = require("main")
local API = require "api"
local Parser = require "parser"
local Format = require "format"

-- Save citation to clipboard and (optionally) to file
local function put(output, output_flag, default_file, proj_dir)
    local f
    if output_flag then
        f = assert(io.open(proj_dir .. "/" .. default_file, "w"), "Cannot open file")
        f:write(output)
        f:close()
        os.execute(string.format("cat %s/%s | xclip -sel clip", proj_dir, default_file))
    else
        local tempfile = "/tmp/excite-tmpfile"
        f = assert(io.open(tempfile, "w"), "Cannot open file")
        f:write(output)
        f:close()
        os.execute(string.format("cat %s | xclip -sel clip", tempfile))
        os.execute("rm " .. tempfile)
    end
    --os.execute("viu test3.jpg")
    print(output)
end

local function main()

    -- Format url
    local url, api_type = API.fmt_url(INPUT_KEY)
    -- Format JSON data as a lua table
    local payload = API.decode(url)

    local tabcite = Parser.parse_citation(payload, INPUT_KEY, api_type)

    -- Format and output citation
    local fmt = Format:new(tabcite, INPUT_KEY, api_type, CITE_STYLE)
    local output = fmt:cite()

    -- Save citation to clipboard and (optionally) to file
    put(output, OUTPUT_FLAG, DEFAULT_FILE, PROJ_DIR)
    -- Main.run(payload, INPUT_KEY, api_type, STYLE, OUTPUT_FLAG, DEFAULT_FILE, PROJ_DIR)
end

main()

