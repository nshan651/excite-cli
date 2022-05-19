local Parser = require "./src/parser"
local Format = require "./src/format"

local Main = {}

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

function Main.run(payload, input_code, api_type, cite_style)
    print("Fetching Citation...")

    local tabcite = Parser.parse_citation(payload, input_code, api_type)

    -- Format and output citation
    local fmt = Format:new(tabcite, api_type)
    local output = fmt:cite(cite_style)

    -- Save citation to clipboard and (optionally) to file
    put(output)
end

return Main
