#!/usr/bin/lua

--[[
    Citation formatting class for bibtex, MLA, and APA
--]]

local Utils = require "utils"

local Format = {}

function Format:new(tab, input_key, api_type, cite_style)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.authors = tab[1]
    self.title = tab[2]
    self.container = tab[3] or nil
    self.journal = tab[4] or nil
    self.year = tab[5]
    self.publisher = tab[6]
    self.pages = tab[7]
    self.bibtex_id = tab[8]
    self.input_key = input_key
    self.api_type = api_type
    self.cite_style = cite_style
    return o
end

-- Pseudo-private output function for spacing MLA and APA
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
            if i == 1 and j == 1 then
                output = output .. substr[j]
            else
                output = output .. " " .. substr[j]
            end
        end
    end
    return output
end

-- Bibtex format
-- Format bibtex_id: Split the author string, loop through to find last name, format id
-- Return a bibtex string (Only return DOI if of type @article)
local function bibtex(self)
    local auth = self.authors[1]["given"] .. " " .. self.authors[1]["family"]

    for i=2, #self.authors do
        auth = auth .. " and " .. self.authors[i]["given"] .. " " .. self.authors[i]["family"]
    end

    if self.api_type == "ISBN" or self.api_type == "SEARCH" then
        return "@book{" .. self.bibtex_id .. ",\n" ..
        "title = " .. string.format("\"%s\",\n", self.title) ..
        "author = " .. string.format("\"%s\",\n", auth) ..
        "year = " .. string.format("\"%s\",\n", self.year) ..
        "publisher = " .. string.format("\"%s\"\n", self.publisher) ..
        "}"

    elseif self.api_type == "DOI" then
        return "@article{" .. self.bibtex_id .. ",\n" ..
        "author = " .. string.format("\"%s\",\n", auth) ..
        "title = " .. string.format("\"%s\",\n", self.title) ..
        "journal = " .. string.format("\"%s\",\n", self.journal) ..
        "year = " .. string.format("\"%s\",\n", self.year) ..
        "publisher = " .. string.format("\"%s\",\n", self.publisher) ..
        "pages = " .. string.format("\"%s\",\n", self.pages) ..
        "doi = " .. string.format("\"%s\"\n", self.input_key) ..
        "}"
    end

end

-- MLA Citation
local function mla(self)
    --local auth = mla_auth(self)
    local auth = self.authors[1]["family"] .. ", " .. self.authors[1]["given"]
    if #self.authors == 2 then
        auth = auth .. ", and " .. self.authors[2]["family"] .. ", " .. self.authors[2]["given"]
    elseif #self.authors > 2 then
        auth = auth .. ", et. al"
    end

    local tab = {auth .. ". \"" .. self.title .. ".\" ", self.publisher .. ", ", self.year .. "."}
    return spacing(self, tab)
end

-- APA Citation
local function apa(self)
    local auth = self.authors[1]["family"] .. ", " .. self.authors[1]["given"]:sub(1,1) .. "."

    if #self.authors == 2 then
        auth = auth .. " & " .. self.authors[2]["family"] .. ", " .. self.authors[2]["given"]:sub(1,1) .. "."
    elseif #self.authors > 2 then
        for i=2, #self.authors do
            if i < 20 and i < #self.authors then
                auth = auth .. self.authors[i]["family"] .. ", " .. self.authors[i]["given"]:sub(1,1) .. "., "
            elseif i < 20 and i == #self.authors then
                auth = auth .. "& " .. self.authors[i]["family"] .. ", " .. self.authors[i]["given"]:sub(1,1) .. "., "
            end
        end
    end
    if #self.authors >= 20 then
        auth = " ... " .. self.authors[#self.authors]["family"] .. ", " .. self.authors[#self.authors]["given"]:sub(1,1) .. "."
    end

    local tab = {auth ..  "(" .. self.year .. "). ", self.title .. ". ", string.upper(self.publisher) .. "."}
    return spacing(self, tab)
end

-- Public function to choose citation
function Format:cite()
    -- Declare output and Format object
    local citation

    -- Choose a citation style
    if self.cite_style == "bibtex" then
        citation = bibtex(self)
    elseif self.cite_style == "MLA" then
        citation = mla(self)
    elseif self.cite_style == "APA" then
        citation = apa(self)
    end

    return citation
end

return Format
