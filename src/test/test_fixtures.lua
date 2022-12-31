--[[
    The test suite for excite using busted
    To add more tests, add json data to test-citations.json
--]]
require "busted.runner"()

package.path = package.path .. ";" .. os.getenv("HOME") .. "/git/excite-cli" .. "/src/main/?.lua"

local json = require "JSON"
local Format = require "format"

-- Builds the system-under-test
local function build_sut()
    local file = io.open("test-citations.json", "r")
    local contents = file:read("*all")
    local data = json:decode(contents)

    return data
end

-- TODO: Add two more describe() functions, one for DOI and one for SEARCH
-- TODO: Make the format object only take a table instead of a bunch of different parameters

describe("a novel using the ISBN API", function ()
    it("should work bibtex cite style", function()
        local sut = build_sut()[1]
        local expected =
[[
@book{murakami2006,
title = "Kafka on the shore",
author = "Haruki Murakami",
year = "2006",
publisher = "Vintage"
}]]
        local tab = {sut["authors"], sut["title"], sut["container"], sut["journal"], sut["year"], sut["publisher"], sut["pages"], sut["bibtex_id"]}
        local fmt = Format:new(
            tab,
            "9781400079278",
            "ISBN",
            "bibtex"
            )
        local actual = fmt:cite()
        assert.are.equals(expected, actual)
    end)
    it("should work using APA cite style", function()
        local sut = build_sut()[1]
        local expected = "Murakami, H.(2006). Kafka on the shore. VINTAGE."
        local tab = {sut["authors"], sut["title"], sut["container"], sut["journal"], sut["year"], sut["publisher"], sut["pages"], sut["bibtex_id"]}
        local fmt = Format:new(
            tab,
            "9781400079278",
            "ISBN",
            "APA"
            )
        local actual = fmt:cite()
        assert.are.equals(expected, actual)
    end)
    it("should work using MLA cite style", function()
        local sut = build_sut()[1]
        local expected = "Murakami, Haruki. \"Kafka on the shore.\" Vintage, 2006."
        local tab = {sut["authors"], sut["title"], sut["container"], sut["journal"], sut["year"], sut["publisher"], sut["pages"], sut["bibtex_id"]}
        local fmt = Format:new(
            tab,
            "9781400079278",
            "ISBN",
            "MLA"
            )
        local actual = fmt:cite()
        assert.are.equals(expected, actual)
    end)
end)


build_sut()
