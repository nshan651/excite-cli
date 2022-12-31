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
package.path = package.path .. ";" .. os.getenv("HOME") .. "/git/excite-cli" .. "/src/main/?.lua"

-- Source local modules
local Init = require "init"

--Init.main(INPUT_KEY, CITE_STYLE, OUTPUT_FLAG, DEFAULT_FILE, PROJ_DIR)
Init.main(INPUT_KEY[1], CITE_STYLE, OUTPUT_FLAG, DEFAULT_FILE, PROJ_DIR)
