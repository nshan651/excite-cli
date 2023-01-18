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
    local success, data = pcall(function()
        local file = io.open("test-citations.json", "r")
        local contents = file:read("*all")
        local data = json:decode(contents)
        return data
    end)
    if not success then
        error("An error occured while reading or decoding the test file")
    end
    return data
end

local function test_instance(data)
    return
    {
        [data["test_name"]] = {
            data["authors"],
            data["title"],
            data["container"],
            data["journal"],
            data["year"],
            data["publisher"],
            data["pages"],
            data["bibtex_id"]
        }
    }
end

-- TODO: Add two more describe() functions, one for DOI and one for SEARCH

-- Create the global system-under-test
SUT = build_sut()

-- Begin tests
describe("a novel cited with the ISBN API", function ()
    it("should work using bibtex cite style", function()
        local inst = test_instance(SUT[1])
        local expected =
[[
@book{murakami2006,
title = "Kafka on the shore",
author = "Haruki Murakami",
year = "2006",
publisher = "Vintage"
}]]
        local fmt = Format:new(
            inst["ISBN"],
            "9781400079278",
            "ISBN",
            "bibtex"
            )
        local actual = fmt:cite()
        assert.are.equals(expected, actual)
    end)
    it("should work using APA cite style", function()
        local inst = test_instance(SUT[1])
        local expected = "Murakami, H.(2006). Kafka on the shore. VINTAGE."
        local fmt = Format:new(
            inst["ISBN"],
            "9781400079278",
            "ISBN",
            "APA"
            )
        local actual = fmt:cite()
        assert.are.equals(expected, actual)
    end)
    it("should work using MLA cite style", function()
        local inst = test_instance(SUT[1])
        local expected = "Murakami, Haruki. \"Kafka on the shore.\" Vintage, 2006."
        local fmt = Format:new(
            inst["ISBN"],
            "9781400079278",
            "ISBN",
            "MLA"
            )
        local actual = fmt:cite()
        assert.are.equals(expected, actual)
    end)
end)

describe("a paper cited with the DOI API", function ()
    it("should work using bibtex cite style", function()
        local inst = test_instance(SUT[2])
        local expected =
[[
@article{comer1979,
author = "Douglas Comer",
title = "Ubiquitous B-Tree",
journal = "ACM Computing Surveys",
year = "1979",
publisher = "Association for Computing Machinery (ACM)",
pages = "121-137",
doi = "10.1145/356770.356776"
}]]
        local fmt = Format:new(
            inst["DOI"],
            "10.1145/356770.356776",
            "DOI",
            "bibtex"
            )
        local actual = fmt:cite()
        assert.are.equals(expected, actual)
    end)
    it("should work using APA cite style", function()
        local inst = test_instance(SUT[2])
        local expected = "Comer, D.(1979). Ubiquitous B-Tree. ASSOCIATION FOR COMPUTING MACHINERY (ACM)."
        local fmt = Format:new(
            inst["DOI"],
            "10.1145/356770.356776",
            "DOI",
            "APA"
            )
        local actual = fmt:cite()
        assert.are.equals(expected, actual)
    end)
    it("should work using MLA cite style", function()
        local inst = test_instance(SUT[2])
        local expected = "Comer, Douglas. \"Ubiquitous B-Tree.\" Association for Computing Machinery (ACM), 1979."
        local fmt = Format:new(
            inst["DOI"],
            "10.1145/356770.356776",
            "DOI",
            "MLA"
            )
        local actual = fmt:cite()
        assert.are.equals(expected, actual)
    end)
end)
