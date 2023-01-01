#!/usr/bin/lua

local API = require "api"
local Parser = require "parser"
local Format = require "format"

local Init = {}

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

function Init.main(input_key, cite_style, output_flag, default_file, proj_dir)
    -- Format url
    local url, api_type = API.fmt_url(input_key)
    -- Format JSON data as a lua table
    local payload = API.decode(url)

    local tabcite = Parser.parse_citation(payload, input_key, api_type, cite_style)

    -- Format and output citation
    local fmt = Format:new(tabcite, input_key, api_type, cite_style)
    local output = fmt:cite()

    -- Save citation to clipboard and (optionally) to file
    put(output, output_flag, default_file, proj_dir)
end

return Init
