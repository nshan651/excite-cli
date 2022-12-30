require "busted.runner"
local json = require "JSON"

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

build_sut()
