require "busted.runner"()

package.path = package.path .. ";" .. os.getenv("HOME") .. "/git/excite-cli" .. "/src/main/?.lua"

local json = require "JSON"
--local Excite = require "../main/excite"
--local Init = require "../main/init"
local Init = require "init"


local function build_sut()
    local lines = ""
    for line in io.lines("test-citations.json") do
        print(line)
        lines = lines .. line
    end
    local e = json:decode(lines)
    for k,v in pairs(e[1]) do
        print(k, v)
    end
    --print(e)
end

--[[
describe("a test", function ()
    it("should work", function()
        assert.truthy("Yuh")
    end)
end)
--]]

--build_sut()
Init.main('9781400079278', 'bibtex', nil, nil, os.getenv("HOME") .. "/git/excite-cli")
