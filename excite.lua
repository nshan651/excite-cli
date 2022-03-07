-- excite.lua
-- Requirements
local json = require "JSON"
local curl = require "cURL"
local argparse = require "argparse"

-- Define arguments
local parser = argparse("excite", "A terminal-based citation generator")
parser:argument("input", "ISBN code")
parser:flag("-o --output", "Output citation to a file")
parser:option("-r --rename", "Output citation to a file", "citation.txt")

-- Parse args
local args = parser:parse()
local input = args.input
local output = args.output
local default_file = args.rename

io.stdout:write([[

    ███████╗██╗  ██╗ ██████╗██╗████████╗███████╗
    ██╔════╝╚██╗██╔╝██╔════╝██║╚══██╔══╝██╔════╝
    █████╗   ╚███╔╝ ██║     ██║   ██║   █████╗  
    ██╔══╝   ██╔██╗ ██║     ██║   ██║   ██╔══╝  
    ███████╗██╔╝ ██╗╚██████╗██║   ██║   ███████╗
    ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝   ╚═╝   ╚══════╝

 ]])
io.stdout:flush()
local isbn = "9780140328721"
local filename = "/home/nick/github_repos/excite-cli/data.txt"
--local url = "https://openlibrary.org/works/OL45883W.json"
--local url = "https://openlibrary.org/isbn/9780140328721" -- BROKEN
local url = "http://openlibrary.org/api/books?bibkeys=ISBN:9780140328721&jscmd=data&format=json"

-- Split function ** because lua does not have a built in str split ;(
function split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

-- HTTP GET: curl the data and return decoded json table
function decode(url)
    local f = io.open(filename, "w")
    local c = curl.easy_init()
        -- setup url
        c:setopt_url(url)
        -- perform, invokes callbacks
        c:perform({writefunction = function(str)
                        f:write(str)
                        end})
        -- close output file
        f:close()
    local data = io.open(filename)
    local str = data:read("*a")
    data:close()
    return json:decode(str)
end

-- Bibtex format
function bibtex(decode)
    -- Gather basic info: title, author, year, publisher
    local title = decode["ISBN:" .. isbn]["title"]
    local author = decode["ISBN:" .. isbn]["authors"][1]["name"]
    -- Split date string to find the year
    local year = nil
    local date = split(decode["ISBN:" .. isbn]["publish_date"], "%s")
    for _,s in pairs(date) do; year=s; end
    local publisher = decode["ISBN:" .. isbn]["publishers"][1]["name"]

    -- Split the author string, loop through to find last name, format id
    local authors = split(decode["ISBN:" .. isbn]["authors"][1]["name"], "%s")
    local id = nil
    for _,s in pairs(authors) do; id=s; end
    id = id:lower() .. year

    --print("title: " .. title .. " \nauthor: " .. author .. " \nyear: " .. year .. "\npublisher: " .. publisher)

    local output = "@book{" .. id .. ",\n" ..
        "\ttitle = " .. string.format("\"%s\"", title) .. "\n" ..
        "\tauthor = " .. string.format("\"%s\"", author) .. "\n" ..
        "\tyear = " .. string.format("\"%s\"", year) .. "\n" ..
        "\tpublisher = " .. string.format("\"%s\"", publisher) .. "\n" ..
        "}"

    -- Copy citation clipboard
    -- echo "text" | xclip -sel clip
    os.execute(string.format("echo \"%s\" | xclip -sel clip", output))
    print("\tCitation copied to clipboard...")
    local f = io.open("/home/nick/github_repos/excite-cli/output.txt", "w")
    f:write(output)
    f:close()
    print("\tCitation successfully saved to file")
end

-- Function calls

bibtex(decode(url))

