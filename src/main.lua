#!/usr/bin/lua

local Parser = require "parser"
local Format = require "format"

local Main = {}

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

--[[
    Parse citation from API request, format citation based on style, output to the terminal

    Params:
        payload: JSON API request data
        input_code: ISBN, DOI
--]]
function Main.run(payload, input_key, api_type, cite_style, output_flag, default_file, proj_dir)

    local tabcite = Parser.parse_citation(payload, input_key, api_type)

    -- Format and output citation
    local fmt = Format:new(tabcite, input_key, api_type, cite_style)
    local output = fmt:cite()

    -- Save citation to clipboard and (optionally) to file
    put(output, output_flag, default_file, proj_dir)
end

return Main
