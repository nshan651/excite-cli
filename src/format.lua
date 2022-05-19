--[[
    Citation formatting class for bibtex, MLA, and APA
--]]

local Utils = require "./src/utils"

local Format = {
    authors = "",
    title = "",
    container = "",
    edition = "",
    publisher = "",
    year = "",
    bibtex_id = "",
    input_key = ""
}

function Format:new(tab, api_type)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.api_type = api_type
    self.authors = tab[1]
    self.title = tab[2]
    self.container = tab[3]
    self.edition = tab[4]
    self.publisher = tab[5]
    self.year = tab[6]
    self.bibtex_id = tab[7]
    self.input_key = tab[8]
    return o
end

-- Pseudo-private output function for spacing MLA and APA
-- TODO: Implement container
local function spacing(self, tab)
    if self.container then
        table.insert(tab, 3, self.container)
    end
    if self.edition then
        table.insert(tab, 4, self.edition)
    end
    local first_line = true
    local output = ""
    local char_count = 0
    for i=1, #tab do
        local substr = Utils.split(tab[i])
        for j=1, #substr do
            char_count = char_count + string.len(substr[j])
            if char_count > 87 and first_line then
                output = output .. "\n\t"
                first_line = false
                char_count = 0
            elseif char_count > 80 then
                output = output .. "\n\t"
                char_count = 0
            end
            output = output .. " " .. substr[j]
        end
    end
    return output
end

-- Bibtex format
-- Format bibtex_id: Split the author string, loop through to find last name, format id
-- Return a bibtex string
local function bibtex(self)
    if self.api_type == "ISBN" or self.api_type == "SEARCH" then
        print("HERE")
        return "@book{" .. self.bibtex_id .. ",\n" ..
        "author = " .. string.format("\"%s\"", self.authors) .. "\n" ..
        "title = " .. string.format("\"%s\"", self.title) .. "\n" ..
        "year = " .. string.format("\"%s\"", self.year) .. "\n" ..
        "publisher = " .. string.format("\"%s\"", self.publisher) .. "\n" ..
        "}"
    elseif self.api_type == "DOI" then
        return "@article{" .. self.bibtex_id .. ",\n" ..
        "author = " .. string.format("\"%s\"", self.authors) .. "\n" ..
        "title = " .. string.format("\"%s\"", self.title) .. "\n" ..
        "year = " .. string.format("\"%s\"", self.year) .. "\n" ..
        "publisher = " .. string.format("\"%s\"", self.publisher) .. "\n" ..
        "}"
    end
end

-- MLA Citation
local function mla(self)
    local tab = {self.authors .. ". \"", self.title .. ".\" ", self.publisher .. ", ", self.year .. "."}
    return spacing(self, tab)
end

-- APA Citation
local function apa(self)
    local tab = {self.authors, "(" .. self.year .. "). ", self.title .. ". ", string.upper(self.publisher) .. "."}
    return spacing(self, tab)
end

-- Public function to choose citation
function Format:cite(cite_style)
    -- Declare output and Format object
    local citation
    print("api_type ", self.api_type)

    -- Choose a citation style
    if cite_style == "bibtex" then
        print("\nBibtex selected")
        citation = bibtex(self)
    elseif cite_style == "MLA" then
        print("\nMLA Selected")
        citation = mla(self)
    elseif cite_style == "APA" then
        print("\nAPA Selected")
        citation = apa(self)
    end

    return citation
end

return Format
