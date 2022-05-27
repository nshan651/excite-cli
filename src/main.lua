local Parser = require "./src/parser"
local Format = require "./src/format"

local Main = {}

-- Save citation to clipboard and (optionally) to file
local function put(output, output_flag, default_file)
    if output_flag then
        local f = assert(io.open("/home/nick/github_repos/excite-cli/" .. default_file, "w"), "Cannot open file")
        f:write(output)
        f:close()
    end
    os.execute(string.format("cat output.txt | xclip -sel clip", output))
    --os.execute("viu test3.jpg")
    print(output)
end

--[[
    Parse citation from API request, format citation based on style, output to the terminal

    Params:
        payload: JSON API request data
        input_code: ISBN, DOI
--]]
function Main.run(payload, input_key, api_type, cite_style, output_flag, default_file)

    local tabcite = Parser.parse_citation(payload, input_key, api_type)

    -- Format and output citation
    local fmt = Format:new(tabcite, input_key, api_type, cite_style)
    local output = fmt:cite()

    -- Save citation to clipboard and (optionally) to file
    put(output, output_flag, default_file)
end

return Main
