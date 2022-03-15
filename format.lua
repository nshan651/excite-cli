--[[
    Citation formatting class for bibtex, MLA, and APA
--]]

local Format = {
    authors = "",
    title = "",
    container = "",
    edition = "",
    publisher = "",
    year = ""
}

-- Constructor
function Format:new(authors, title, container, edition, publisher, year)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.authors = authors
    self.title = title
    self.container = container
    self.edition = edition
    self.publisher = publisher
    self.year = year
    return o
end

-- Pseudo-private output function for spacing MLA and APA
local output = function(self, tab)
    if self.container then
        table.insert(tab, 3, self.container)
    end
    if self.edition then
        table.insert(tab, 4, self.edition)
    end
    local new_line = true
    local output = ""
    for i,_ in pairs(tab) do
        if string.len(output) > 80 and new_line then
            output = output .. "\n\t"
            new_line = false
        end
       output = output .. tab[i]
    end
    return output
end

-- Bibtex format
-- Format id: Split the author string, loop through to find last name, format id
-- Return a bibtex string
function Format:bibtex(id)
    return "@book{" .. id .. ",\n" ..
    "author = " .. string.format("\"%s\"", self.authors) .. "\n" ..
    "title = " .. string.format("\"%s\"", self.title) .. "\n" ..
    "year = " .. string.format("\"%s\"", self.year) .. "\n" ..
    "publisher = " .. string.format("\"%s\"", self.publisher) .. "\n" ..
    "}"
end

-- MLA Citation
-- TODO: Implement container
function Format:mla()
    print("publisher is " .. self.publisher)
    local tab = {self.authors .. ". \"", self.title .. ".\" ", self.publisher .. ", ", self.year .. "."}
    return output(self, tab)
end

-- APA Citation
function Format:apa()
    local tab = {self.authors, "(" .. self.year .. "). ", self.title .. ". ", string.upper(self.publisher) .. "."}
    return output(self, tab)
end

return Format
